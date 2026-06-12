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
import sys

from BaseRunner import BaseRunner
from CIRCTSupport import force_failure_on_assertion_output_mismatch
from CIRCTSupport import force_failure_on_fatal_diagnostics
from CIRCTSupport import force_failure_on_missing_runtime_output
from CIRCTSupport import force_failure_on_self_reported_failure
from CIRCTSupport import has_hierarchical_printtimescale

DPI_SOURCE_EXTENSIONS = frozenset({".c", ".cc", ".cpp", ".cxx"})
DPI_HEADER_EXTENSIONS = frozenset({".h", ".hh", ".hpp", ".hxx"})

# Minimal subset of the standard SystemVerilog DPI scope API. It is enough to
# compile the DPI C sources used by the imported UVM examples without
# depending on a simulator-specific header installation.
MINIMAL_SV_DPI_H = """\
#ifndef ARCILATOR_MINIMAL_SV_DPI_H
#define ARCILATOR_MINIMAL_SV_DPI_H

typedef const char *svScope;

svScope svGetScope(void);
svScope svGetScopeFromName(const char *name);
svScope svSetScope(svScope scope);
const char *svGetNameFromScope(svScope scope);

#endif
"""

# UVM testbenches JIT-compiled by arcilator can allocate large amounts of
# memory before their own pass/fail checks fire. Bound the backend stage so a
# runaway run fails deterministically instead of starving the test host.
UVM_VMEM_LIMIT_KB = "10485760"  # 10 GiB

MODULE_DEF_RE = re.compile(
    r"\bmodule\s+([A-Za-z_][A-Za-z0-9_$]*)"
    r"\s*(?:#\s*\([^;]*?\)\s*)?([(;])", re.DOTALL)


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
        self.allowed_extensions += sorted(
            DPI_SOURCE_EXTENSIONS | DPI_HEADER_EXTENSIONS)

    def can_run(self):
        return all(
            shutil.which(tool) is not None
            for tool in ("circt-verilog", "arcilator"))

    def run_subprocess(self, tmp_dir, params):
        output, rc = super().run_subprocess(tmp_dir, params)
        # On should_fail rows any nonzero status is published as the expected
        # failure, so a strict demotion would turn a run the toolchain wrongly
        # accepted into a green cell. Never demote those rows.
        if params.get("should_fail") == "1":
            return output, rc
        # Preprocessed (-E) output is source text, not diagnostics.
        if params.get("mode") != "preprocessing":
            output, rc = force_failure_on_fatal_diagnostics(output, rc)
        output, rc = force_failure_on_assertion_output_mismatch(output, rc)
        output, rc = force_failure_on_self_reported_failure(output, rc, params)
        return force_failure_on_missing_runtime_output(output, rc, params)

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

    def _split_frontend_and_dpi_files(self, files):
        frontend_files = []
        dpi_sources = []
        dpi_headers = []
        for path in files:
            ext = os.path.splitext(path)[1].lower()
            if ext in DPI_SOURCE_EXTENSIONS:
                dpi_sources.append(path)
            elif ext in DPI_HEADER_EXTENSIONS:
                dpi_headers.append(path)
            else:
                frontend_files.append(path)
        return frontend_files, dpi_sources, dpi_headers

    def _dpi_compiler(self):
        return shutil.which("clang") or shutil.which("cc")

    def _write_minimal_sv_dpi_header(self, tmp_dir):
        path = os.path.join(tmp_dir, "sv_dpi.h")
        with open(path, "w") as f:
            f.write(MINIMAL_SV_DPI_H)
        return path

    def _dpi_shared_library_ext(self):
        return ".dylib" if sys.platform == "darwin" else ".so"

    def _dpi_linker_flags(self):
        if sys.platform == "darwin":
            return ["-Wl,-undefined,dynamic_lookup"]
        return ["-Wl,--unresolved-symbols=ignore-all"]

    def _build_dpi_compile_cmd(self, tmp_dir, incdirs, defines, dpi_sources):
        compiler = self._dpi_compiler()
        if not compiler:
            return None, None

        self._write_minimal_sv_dpi_header(tmp_dir)
        shared_lib = os.path.join(
            tmp_dir, "arcilator_dpi" + self._dpi_shared_library_ext())
        cmd = [
            compiler, "-shared", "-fPIC", "-Wno-implicit-function-declaration"
        ]
        cmd.extend(["-I", tmp_dir])
        for incdir in incdirs:
            cmd.extend(["-I", incdir])
        for define in defines:
            cmd.append("-D" + define)
        cmd.extend(dpi_sources)
        cmd.extend(["-o", shared_lib])
        cmd.extend(self._dpi_linker_flags())
        return cmd, shared_lib

    def _user_source_texts(self, params):
        for path in params.get("files", []):
            try:
                with open(path, encoding="utf-8", errors="ignore") as source:
                    yield source.read()
            except OSError:
                continue

    def _module_definitions(self, params):
        modules = []
        seen = set()
        for text in self._user_source_texts(params):
            for match in MODULE_DEF_RE.finditer(text):
                name = match.group(1)
                if name not in seen:
                    modules.append(name)
                    seen.add(name)
        return modules

    def _portless_module_definitions(self, params):
        modules = set()
        for text in self._user_source_texts(params):
            for match in MODULE_DEF_RE.finditer(text):
                if self._is_portless_module_definition(text, match):
                    modules.add(match.group(1))
        return modules

    def _is_portless_module_definition(self, text, match):
        if match.group(2) == ";":
            return True
        pos = match.end()
        while pos < len(text) and text[pos].isspace():
            pos += 1
        return pos < len(text) and text[pos] == ")"

    def _module_references(self, params, module_names):
        references = set()
        for text in self._user_source_texts(params):
            for name in module_names:
                pattern = (
                    r"(?<!\bmodule\s)\b" + re.escape(name) +
                    r"\s*(?:#\s*\([^;]*?\)\s*)?[A-Za-z_][A-Za-z0-9_$]*\s*\(")
                if re.search(pattern, text, re.DOTALL):
                    references.add(name)
        return references

    def _module_roots(self, params):
        modules = self._module_definitions(params)
        if not modules:
            return []
        references = self._module_references(params, modules)
        return [name for name in modules if name not in references]

    def _guess_runnable_top(self, params):
        modules = self._module_definitions(params)
        if not modules:
            return None
        roots = self._module_roots(params)
        if "top" in roots:
            return "top"
        if len(roots) == 1:
            return roots[0]
        if len(modules) == 1:
            return modules[0]
        return None

    def _select_top(self, params, mode):
        explicit_top = params["top_module"] or None
        if mode in {"preprocessing", "parsing"}:
            return explicit_top
        if explicit_top is None and has_hierarchical_printtimescale(params):
            return None
        return explicit_top or self._guess_runnable_top(params)

    def _wrapper_roots(self, params):
        if has_hierarchical_printtimescale(params):
            return []
        roots = self._module_roots(params)
        if len(roots) <= 1:
            return []
        portless = self._portless_module_definitions(params)
        if all(root in portless for root in roots):
            return self._ordered_wrapper_roots(roots)
        return []

    def _ordered_wrapper_roots(self, roots):
        # UVM dual-top testbenches conventionally split into an hdl_* and an
        # hvl_* top; instantiate the DUT side first.
        def key(root):
            name = root.lower()
            if name == "hdl_top" or name.startswith("hdl_"):
                return 0
            if name == "hvl_top" or name.startswith("hvl_"):
                return 2
            return 1

        return sorted(roots, key=key)

    def _write_root_wrapper(self, tmp_dir, roots):
        wrapper_top = "__arcilator_svtests_top"
        wrapper_file = os.path.join(tmp_dir, wrapper_top + ".sv")
        with open(wrapper_file, "w", encoding="utf-8") as f:
            f.write("module " + wrapper_top + ";\n")
            for index, root in enumerate(roots):
                f.write(f"  {root} __arcilator_root_{index}();\n")
            f.write("endmodule\n")
        return wrapper_top, wrapper_file

    def _uses_uvm_runtime(self, params):
        if "uvm" in params.get("tags", "").split():
            return True
        return any(
            "run_test" in text for text in self._user_source_texts(params))

    def prepare_run_cb(self, tmp_dir, params):
        mode = params["mode"]
        scr = os.path.join(tmp_dir, "scr.sh")
        design_mlir = os.path.join(tmp_dir, "design.mlir")

        frontend_cmd = ["circt-verilog"]
        if mode == "preprocessing":
            frontend_cmd += ["-E"]
        elif mode == "parsing":
            frontend_cmd += ["--parse-only"]
        else:
            frontend_cmd += ["-o", design_mlir]

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

        top = self._select_top(params, mode)
        wrapper_roots = []
        wrapper_file = None
        if mode == "simulation" and top is None:
            wrapper_roots = self._wrapper_roots(params)
            if wrapper_roots:
                top, wrapper_file = self._write_root_wrapper(
                    tmp_dir, wrapper_roots)
        if top is not None:
            frontend_cmd += ["--top=" + top]

        frontend_files, dpi_sources, dpi_headers = (
            self._split_frontend_and_dpi_files(params["files"]))
        if wrapper_file:
            frontend_files.append(wrapper_file)
        frontend_cmd += frontend_files

        dpi_compile_cmd = None
        dpi_shared_lib = None
        if mode == "simulation" and dpi_sources:
            dpi_compile_cmd, dpi_shared_lib = self._build_dpi_compile_cmd(
                tmp_dir, params["incdirs"], defines, dpi_sources)

        backend_cmd = [self.executable, design_mlir, "--disable-output"]
        if mode == "simulation":
            backend_cmd = [self.executable, design_mlir, "--run"]
            if dpi_shared_lib:
                backend_cmd += ["--shared-libs=" + dpi_shared_lib]

        simvariants = params["simvariants"]
        uvm_runtime = mode == "simulation" and self._uses_uvm_runtime(params)
        missing_top = (
            mode == "simulation" and top is None
            and not has_hierarchical_printtimescale(params))

        self.cmd = ["sh", "scr.sh"]
        with open(scr, "w") as f:
            f.write("set -x\n")
            f.write(
                "printf '%s\\n' " +
                shlex.quote(f"[Arcilator] mode={mode} top={top or ''}") + "\n")
            if dpi_sources:
                f.write(
                    "printf '%s\\n' " + shlex.quote(
                        "[Arcilator] treating C/C++ inputs as DPI sources, not "
                        "SystemVerilog frontend files: "
                        f"{', '.join(dpi_sources)}") + "\n")
                if dpi_headers:
                    f.write(
                        "printf '%s\\n' " + shlex.quote(
                            "[Arcilator] C/C++ header inputs are available "
                            "through include directories and are not passed to "
                            "circt-verilog") + "\n")
            if wrapper_roots:
                f.write(
                    "printf '%s\\n' " + shlex.quote(
                        "[Arcilator] simulation test has multiple portless "
                        "module-root tops; using a generated wrapper top that "
                        "instantiates: " + ", ".join(wrapper_roots)) + "\n")
            f.write("echo '[Arcilator] CIRCT frontend stage'\n")
            f.write(shlex.join(frontend_cmd) + " || exit $?\n")
            if mode == "simulation" and dpi_sources:
                if dpi_compile_cmd is None:
                    f.write(
                        "printf '%s\\n' " + shlex.quote(
                            "[Arcilator] unable to find clang or cc to compile "
                            "DPI C sources") + "\n")
                    # Exit in the crash range so a runner-side refusal can
                    # never satisfy a should_fail row.
                    f.write("exit 126\n")
                    return
                f.write("echo '[Arcilator] DPI C build stage'\n")
                f.write(shlex.join(dpi_compile_cmd) + " || exit $?\n")
            if mode in {"preprocessing", "parsing"}:
                return
            if missing_top:
                # Choosing an arbitrary internal module as the simulation
                # entry point could simulate something other than what the
                # test intends and report a pass for it.
                f.write(
                    "printf '%s\\n' " + shlex.quote(
                        "[Arcilator] simulation test has no declared or "
                        "unambiguous module-root top; refusing to pick an "
                        "arbitrary arcilator entry point") + "\n")
                # Exit in the crash range so a runner-side refusal can never
                # satisfy a should_fail row.
                f.write("exit 126\n")
                return
            f.write("echo '[Arcilator] Arcilator backend stage'\n")
            if uvm_runtime:
                f.write("ulimit -v " + UVM_VMEM_LIMIT_KB + "\n")
            if mode == "simulation" and simvariants:
                f.write("status=0\n")
                for index, variant in enumerate(simvariants, start=1):
                    f.write(
                        "printf '%s\\n' " + shlex.quote(
                            "[Arcilator] running sv-tests simvariant "
                            f"{index}/{len(simvariants)} as arcilator "
                            f"--extra-runtime-args={variant}") + "\n")
                    variant_cmd = backend_cmd + [
                        "--extra-runtime-args=" + variant
                    ]
                    f.write(shlex.join(variant_cmd) + " || status=$?\n")
                f.write("exit $status\n")
            else:
                f.write(shlex.join(backend_cmd) + " || exit $?\n")
