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
import subprocess

from BaseRunner import BaseRunner

# UVM testbenches JIT-compiled by arcilator can allocate large amounts of
# memory before their own pass/fail checks fire. Bound the simulation stage
# so a runaway run fails deterministically instead of starving the test host.
UVM_VMEM_LIMIT_KB = "10485760"  # 10 GiB

MODULE_DEF_RE = re.compile(
    r"\bmodule\s+([A-Za-z_][A-Za-z0-9_$]*)"
    r"\s*(?:#\s*\([^;]*?\)\s*)?[(;]", re.DOTALL)

# A simulation that exits with status 0 while printing one of these lines
# reported its own failure; such a run must not be counted as a pass. These
# checks only ever demote a status-0 run; they never promote a failing one.
SELF_REPORTED_FAILURE_RES = (
    re.compile(r"^UVM_FATAL\b(?!\s*:\s*0\b)"),
    re.compile(r"^UVM_ERROR\b(?!\s*:\s*0\b)"),
    re.compile(r"\bTEST\s+FAILED\b", re.IGNORECASE),
)


class Arcilator(BaseRunner):
    """Run tests through the CIRCT Verilog frontend and arcilator.

    Simulation rows are compiled with circt-verilog to CIRCT IR and executed
    with ``arcilator --run`` (JIT). Elaboration and simulation_without_run
    rows stop after ``arcilator --disable-output``, which exercises the full
    arcilator lowering pipeline without running the design.
    """
    def __init__(self):
        super().__init__(
            "Arcilator",
            executable="arcilator",
            supported_features={
                "preprocessing", "parsing", "elaboration", "simulation",
                "simulation_without_run"
            })

        self.submodule = "third_party/tools/circt-verilog"
        self.url = f"https://github.com/llvm/circt/tree/{self.get_commit()}"

    def can_run(self):
        return all(
            shutil.which(tool) is not None
            for tool in ("circt-verilog", "arcilator"))

    def get_version(self):
        outputs = []
        for tool in ("circt-verilog", "arcilator"):
            try:
                proc = subprocess.Popen(
                    [tool, "--version"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT)
                log, _ = proc.communicate(timeout=30)
                if proc.returncode == 0:
                    outputs.append(
                        f"$ {tool} --version\n" +
                        log.decode("utf-8", "ignore").strip())
                else:
                    outputs.append(f"$ {tool} --version\n{tool}")
            except (OSError, subprocess.TimeoutExpired):
                outputs.append(f"$ {tool} --version\n{tool}")
        return "\n\n".join(outputs) + "\n"

    def run_subprocess(self, tmp_dir, params):
        output, rc = super().run_subprocess(tmp_dir, params)
        # On should_fail rows any nonzero status is published as the expected
        # failure, so a demotion would wrongly turn a run the toolchain
        # accepted into a green cell. Never demote those rows.
        if rc != 0 or params.get("should_fail") == "1":
            return output, rc
        if params.get("mode") == "simulation" and any(
                pattern.search(line)
                for line in output.splitlines()
                for pattern in SELF_REPORTED_FAILURE_RES):
            return output, 1
        return output, rc

    def _source_texts(self, params):
        for path in params["files"]:
            try:
                with open(path, encoding="utf-8", errors="ignore") as f:
                    yield f.read()
            except OSError:
                continue

    def _unique_module_root(self, params):
        """Return the sole module that is defined but never instantiated.

        Unlike a first-module or name-based guess this cannot silently pick a
        submodule; with zero or several candidate roots it returns None and
        the caller decides what an ambiguous top means for its mode.
        """
        texts = list(self._source_texts(params))
        modules = []
        for text in texts:
            for name in MODULE_DEF_RE.findall(text):
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
        if "uvm" in params.get("tags", "").split():
            return True
        return any("run_test" in text for text in self._source_texts(params))

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

        # arcilator does not provide the full UVM DPI runtime; build the UVM
        # library without its DPI imports, like the Verilator runner does.
        defines = list(params["defines"])
        if "UVM_NO_DPI" not in defines:
            defines.append("UVM_NO_DPI")
        for define in defines:
            frontend_cmd.extend(["-D", define])

        # The frontend options below mirror tools/runners/circt_verilog.py so
        # the two CIRCT-backed columns agree on what the frontend accepts.
        frontend_cmd += ["--timescale=1ns/1ns", "--single-unit"]
        frontend_cmd += ["-Wno-implicit-conv"]
        frontend_cmd += [
            "-Wno-error=index-oob",
            "-Wno-error=range-oob",
            "-Wno-error=range-width-oob",
        ]

        tags = set(params["tags"].split())
        if "uvm" in tags and mode != "preprocessing":
            # UVM sources frequently reference identifiers before their
            # declaration point.
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

        # Top selection: an explicit :top_module: wins, otherwise accept only
        # an unambiguous instantiation root. Without either, frontend-only
        # modes let slang elaborate all root modules, while simulation
        # refuses to run below.
        top = params["top_module"] or self._unique_module_root(params)
        if top is not None and mode not in ("preprocessing", "parsing"):
            frontend_cmd += ["--top=" + top]

        frontend_cmd += params["files"]

        if mode in ("preprocessing", "parsing"):
            self.cmd = frontend_cmd
            return

        backend_cmd = ["arcilator", "design.mlir"]
        if mode == "simulation":
            backend_cmd += ["--run"]
        else:
            backend_cmd += ["--disable-output"]

        self.cmd = ["sh", "scr.sh"]
        with open(os.path.join(tmp_dir, "scr.sh"), "w") as f:
            f.write("set -x\n")
            if mode == "simulation" and top is None:
                # Choosing an arbitrary module as the simulation entry point
                # could simulate something other than what the test intends
                # and report a pass for it. Exit in the crash range so a
                # runner-side refusal can never satisfy a should_fail row.
                f.write(
                    "printf '%s\\n' " + shlex.quote(
                        "[Arcilator] simulation test has no declared or "
                        "unambiguous module-root top; refusing to pick an "
                        "arbitrary arcilator entry point") + "\n")
                f.write("exit 126\n")
                return
            f.write(shlex.join(frontend_cmd) + " || exit $?\n")
            if mode == "simulation" and self._uses_uvm_runtime(params):
                f.write("ulimit -v " + UVM_VMEM_LIMIT_KB + "\n")
            f.write(shlex.join(backend_cmd) + "\n")
