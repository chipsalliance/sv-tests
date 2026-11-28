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

from BaseRunner import BaseRunner


class uhdm2rtlil(BaseRunner):
    """Yosys with the uhdm2rtlil plugin: Surelog elaborates the design and the
    plugin imports the in-memory UHDM model into RTLIL (`read_sv`).  Modes and
    per-mode scripts are the Yosys runner's."""
    def __init__(self):
        super().__init__(
            "uhdm2rtlil", "yosys-uhdm2rtlil", {
                "preprocessing", "parsing", "elaboration", "simulation",
                "simulation_without_run"
            })

        self.submodule = "third_party/tools/uhdm2rtlil"
        self.url = f"https://github.com/chipsalliance/uhdm2rtlil/tree/{self.get_commit()}"

    def get_mode(self, params):
        unsynthesizable = int(params['unsynthesizable'])
        if unsynthesizable:
            return None
        return super().get_mode(params)

    def prepare_run_cb(self, tmp_dir, params):
        run = os.path.join(tmp_dir, "run.sh")
        scr = os.path.join(tmp_dir, "scr.ys")
        mode = params['mode']

        top = params['top_module'].strip() or None

        # read_sv runs Surelog in-process with the uhdm2rtlil flow's default
        # options (-parse -nobuiltin -nocache -sverilog -DSYNTHESIS
        # -filterprotected), writes no .uhdm file, and fails the read on any
        # Surelog syntax, fatal or error.  Only the messages are silenced.
        read = ["read_sv", "-nonote", "-noinfo", "-nowarning"]
        if top is not None:
            read += ["--top-module", top]
        read += [f"-I{incdir}" for incdir in params['incdirs']]
        read += [f"-D{define}" for define in params['defines']]
        read += params['files']

        with open(scr, "w") as f:
            f.write("plugin -i uhdm2rtlil\n")
            f.write(" ".join(read) + "\n")

            if mode not in ["preprocessing", "parsing"]:
                # prep (without optimizations), as in the Yosys runner
                top_opt = f"-top \\{top}" if top is not None else "-auto-top"
                f.write(
                    f"hierarchy {top_opt}\n"
                    "proc\n"
                    "check\n"
                    "clean\n"
                    "memory_dff\n"
                    "memory_collect\n"
                    "stat\n"
                    "check\n")
            if mode in ["simulation", "simulation_without_run"]:
                f.write("sim -assert\n")

        with open(run, "w") as f:
            f.write("set -x\n")
            f.write(f"cat {scr}\n")
            f.write(f"{self.executable} -Q -T {scr}\n")

        self.cmd = ["sh", run]

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def get_version(self):
        # The yosys version is the host's; the frontend is identified by
        # its commit.
        return f"{self.name} {self.get_commit()[:9]}"
