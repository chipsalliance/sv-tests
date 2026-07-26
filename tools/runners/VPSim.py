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

import json
import os
import re

from BaseRunner import BaseRunner


class VPSim(BaseRunner):
    def __init__(self):
        super().__init__("vpsim", "vpsim", {"simulation"})

        self.submodule = "third_party/tools/vpsim"
        self.url = f"https://github.com/Kyungsang/vpsim/tree/{self.get_commit()}"

    @staticmethod
    def _references_uvm(path):
        try:
            with open(path, encoding="utf-8", errors="replace") as source:
                text = source.read().lower()
        except OSError:
            return False
        return (
            "uvm_pkg::" in text or "import uvm_pkg::" in text
            or "uvm_macros.svh" in text or "run_test" in text)

    def prepare_run_cb(self, tmp_dir, params):
        files = list(params["files"])
        top = self.get_top_module_or_guess(params)
        if not top:
            top = "__vpsim_sv_tests_neutral_top"
            wrapper = os.path.join(tmp_dir, "_vpsim_sv_tests_neutral_top.sv")
            with open(wrapper, "w", encoding="utf-8") as output:
                output.write(f"module {top}; initial $finish; endmodule\n")
            files.append(wrapper)

        self.cmd = [
            self.executable, "sim", *files, "--top", top or "top", "--backend",
            "auto", "--json", "--max-time",
            os.environ.get("VPSIM_SV_TESTS_MAX_TIME", "10000")
        ]

        for incdir in params["incdirs"]:
            self.cmd += ["-I", incdir]
        for define in params["defines"]:
            self.cmd += ["-D", define]

        if any(self._references_uvm(path) for path in files):
            uvm_home = os.path.join(
                os.environ["THIRD_PARTY_DIR"], "tests", "uvm-1.2")
            if os.path.isfile(os.path.join(uvm_home, "src", "uvm_pkg.sv")):
                self.cmd += ["--uvm-home", uvm_home]

    def run_subprocess(self, tmp_dir, params):
        output, returncode = super().run_subprocess(tmp_dir, params)
        try:
            invocation, json_output = output.split("\n", 1)
            payload = json.loads(json_output)
        except (ValueError, json.JSONDecodeError):
            return output, returncode

        rendered = [invocation]
        for key in ("stdout", "stderr"):
            text = str(payload.get(key) or "").strip()
            if text:
                rendered.append(text)
        diagnostics = payload.get("diagnostics") or []
        if diagnostics:
            rendered.append("\n".join(str(item) for item in diagnostics))

        simulation_error = re.search(
            r"(?mi)^\s*(?:error|fatal):",
            str(payload.get("stdout") or ""),
        )
        if returncode == 0 and (not payload.get("success")
                                or simulation_error is not None):
            # The upstream runner inverts the executable status for
            # should_fail_because cases.  VPSim keeps $error in its structured
            # payload, so map that standard simulator failure to a nonzero
            # tool status before the upstream inversion is applied.
            returncode = 1

        return "\n".join(rendered) + "\n", returncode

    def get_version_cmd(self):
        python = os.path.join(
            os.path.abspath(os.environ["OUT_DIR"]), "runners", "vpsim-venv",
            "bin", "python")
        return [
            python, "-c", "import importlib.metadata; "
            "print('vpsim', importlib.metadata.version('vpsim'))"
        ]
