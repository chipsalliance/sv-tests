#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2026 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

import os
import re
import shlex
import shutil

from BaseRunner import BaseRunner

# Demote-only: a status-0 simulation printing one of these failed itself.
SELF_REPORTED_FAILURE_RES = (
    re.compile(r"^UVM_FATAL\b(?!\s*:\s*0\b)"),
    re.compile(r"^UVM_ERROR\b(?!\s*:\s*0\b)"),
    re.compile(r"\bTEST\s+FAILED\b", re.IGNORECASE),
)


class Arcilator(BaseRunner):
    """Run tests through the CIRCT Verilog frontend and arcilator.

    Simulation rows are compiled ahead of time (``arcilator --emit-llvm``,
    ``llc``, link against CIRCT's shipped arc runtime) and run to
    quiescence by the generated ``<top>_main`` driver. Unsupported
    constructs are rejected while compiling, so this column can score
    fewer green cells than an in-process ``--run`` column. Other rows
    stop after ``arcilator --disable-output``.
    """
    def __init__(self):
        super().__init__(
            "arcilator",
            executable="arcilator",
            supported_features={
                "preprocessing", "parsing", "elaboration", "simulation",
                "simulation_without_run"
            })
        self.submodule = "third_party/tools/circt-verilog"
        self.url = f"https://github.com/llvm/circt/tree/{self.get_commit()}"

    def can_run(self):
        return all(map(shutil.which, ("circt-verilog", "arcilator", "llc")))

    def run_subprocess(self, tmp_dir, params):
        output, rc = super().run_subprocess(tmp_dir, params)
        should_fail = params.get("should_fail") == "1"
        if rc == 71 and should_fail:
            return (
                output + "[arcilator] timed out; a timeout is not a "
                "toolchain rejection and must not satisfy should_fail\n", 126)
        # Never demote should_fail rows; that would create a green cell.
        if rc != 0 or should_fail:
            return output, rc
        if params["mode"] == "simulation":
            if any(pattern.search(line)
                   for line in output.splitlines()
                   for pattern in SELF_REPORTED_FAILURE_RES):
                return output, 1
            # A run printing zero ':assert:' lines passes the harness check
            # vacuously; demote when the sources print them unconditionally.
            if ":assert:" not in output and any(
                    '$display(":assert:' in text
                    for text in self._source_texts(params)):
                return (
                    output + "[arcilator] exited 0 without printing the "
                    "test's ':assert:' verdict lines; demoting\n", 1)
        return output, rc

    def _source_texts(self, params):
        for path in params["files"]:
            try:
                with open(path, encoding="utf-8", errors="ignore") as f:
                    yield f.read()
            except OSError:
                continue

    def _unique_module_root(self, params):
        """Return the sole uninstantiated module, or None if ambiguous."""
        texts = list(self._source_texts(params))
        module_def_re = re.compile(
            r"\bmodule\s+([A-Za-z_][A-Za-z0-9_$]*)"
            r"\s*(?:#\s*\([^;]*?\)\s*)?[(;]", re.DOTALL)
        modules = []
        for text in texts:
            for name in module_def_re.findall(text):
                if name not in modules:
                    modules.append(name)
        roots = [
            name for name in modules if not any(
                re.search(
                    r"(?<!\bmodule\s)\b" + re.escape(name) +
                    r"\s*(?:#\s*\([^;]*?\)\s*)?[A-Za-z_][A-Za-z0-9_$]*\s*\(",
                    text, re.DOTALL) for text in texts)
        ]
        return roots[0] if len(roots) == 1 else None

    def _uses_uvm_runtime(self, params):
        return "uvm" in params["tags"] or any(
            "run_test" in text for text in self._source_texts(params))

    def _write_simulation_stages(self, f, tmp_dir, params, top):
        # <top>_main is arcilator's generated driver; it returns at
        # quiescence, once no model-side wakeup remains pending.
        with open(os.path.join(tmp_dir, "driver.cpp"), "w") as drv:
            drv.write(
                f"extern \"C\" void {top}_main(void);\n"
                f"int main(void) {{ {top}_main(); return 0; }}\n")
        libdir = os.path.join(
            os.path.dirname(os.path.dirname(shutil.which("llc"))), "lib")
        cxx = "clang++" if shutil.which("clang++") else "c++"

        f.write("arcilator design.mlir --emit-llvm -o design.ll || exit $?\n")
        # PIC code, since the driver links into a default (PIE) executable.
        f.write(
            "llc --relocation-model=pic -O1 --filetype=obj design.ll"
            " -o design.o || exit $?\n")
        f.write(
            shlex.join(
                [cxx, "driver.cpp", "design.o"] + [
                    os.path.join(libdir, f"lib{lib}.a") for lib in
                    ("CIRCTArcRuntime", "LLVMSupport", "LLVMDemangle")
                ] + ["-lpthread", "-o", "sim"]) + " || exit $?\n")

        # Bound livelocks with a wall clock inside the row's timeout; the
        # loud crash-range exit can never satisfy a should_fail row.
        budget = max(5, int(params["timeout"]) - 5)
        f.write(
            f"timeout -k 5 {budget} ./sim\nrc=$?\n"
            "if [ $rc -eq 124 ] || [ $rc -eq 137 ]; then\n")
        f.write(
            "    printf '%s\\n' " + shlex.quote(
                f"[arcilator] simulation exceeded its {budget}s wall-clock "
                "budget; treating this as a runner failure, not a verdict") +
            "\n    exit 126\nfi\nexit $rc\n")

    def prepare_run_cb(self, tmp_dir, params):
        mode = params["mode"]

        frontend_cmd = ["circt-verilog"]
        if mode == "preprocessing":
            frontend_cmd += ["-E"]
        elif mode == "parsing":
            frontend_cmd += ["--parse-only"]
        else:
            frontend_cmd += ["-o", "design.mlir"]
        for incdir in params["incdirs"]:
            frontend_cmd.extend(["-I", incdir])
        # Build the UVM library without its DPI imports, like Verilator.
        for define in dict.fromkeys(params["defines"] + ["UVM_NO_DPI"]):
            frontend_cmd.extend(["-D", define])

        # Mirror circt_verilog.py so the CIRCT columns accept the same input.
        frontend_cmd += [
            "--timescale=1ns/1ns", "--single-unit", "-Wno-implicit-conv",
            "-Wno-error=index-oob", "-Wno-error=range-oob",
            "-Wno-error=range-width-oob"
        ]
        tags = params["tags"]
        if "uvm" in tags and mode != "preprocessing":
            frontend_cmd += ["--allow-use-before-declare"]
        if "ariane" in tags or "ibex" in tags:
            frontend_cmd += ["-Wno-duplicate-definition"]
        if "ariane" in tags:
            frontend_cmd += ["-Xslang=--allow-self-determined-stream-concat"]
        if ("black-parrot" in tags and mode != "parsing"
                and "--allow-use-before-declare" not in frontend_cmd):
            frontend_cmd += ["--allow-use-before-declare"]
        if "fx68k" in tags:
            frontend_cmd += ["--allow-dup-initial-drivers"]

        # An explicit :top_module: wins, else the unique uninstantiated
        # module; simulating an arbitrary guess could pass for the wrong one.
        top = params["top_module"] or self._unique_module_root(params)
        if top is not None and mode not in ("preprocessing", "parsing"):
            frontend_cmd += ["--top=" + top]
        frontend_cmd += params["files"]

        if mode in ("preprocessing", "parsing"):
            self.cmd = frontend_cmd
            return

        self.cmd = ["sh", "scr.sh"]
        with open(os.path.join(tmp_dir, "scr.sh"), "w") as f:
            f.write("set -x\n")
            refusal = None
            if mode == "simulation" and top is None:
                refusal = (
                    "no declared or unambiguous module-root top; "
                    "refusing to pick an arbitrary entry point")
            elif mode == "simulation" and params["simvariants"]:
                refusal = (
                    "cannot select a simulation variant in a "
                    "compiled model; refusing to run an arbitrary one")
            if refusal is not None:
                # A crash-range exit can never satisfy a should_fail row.
                f.write(
                    "printf '%s\\n' " + shlex.quote("[arcilator] " + refusal) +
                    "\nexit 126\n")
                return
            f.write(shlex.join(frontend_cmd) + " || exit $?\n")
            if mode == "simulation":
                if self._uses_uvm_runtime(params):
                    # 10 GiB cap: a runaway UVM row fails, not the host.
                    f.write("ulimit -v 10485760\n")
                self._write_simulation_stages(f, tmp_dir, params, top)
            else:
                f.write("arcilator design.mlir --disable-output\n")
