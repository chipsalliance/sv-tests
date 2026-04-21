#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2020 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

import os
import shlex
import shutil

from BaseRunner import BaseRunner


class arcilator(BaseRunner):
    def __init__(self):
        super().__init__(
            "arcilator", "arcilator", {
                "preprocessing", "parsing", "elaboration"
            })

        self.submodule = "third_party/tools/circt-verilog"
        self.display_name = "Arcilator"
        self.url = f"https://github.com/llvm/circt/tree/{self.get_commit()}"
        self.frontend_executable = "circt-verilog"

    def can_run(self):
        return (shutil.which(self.executable) is not None
                and shutil.which(self.frontend_executable) is not None)

    def prepare_run_cb(self, tmp_dir, params):
        mode = params["mode"]
        frontend_cmd = [self.frontend_executable]

        # Reuse the same SystemVerilog frontend options as the circt-verilog
        # runner, then hand the lowered HW dialect MLIR to arcilator.
        if mode == "preprocessing":
            frontend_cmd += ["-E"]
        elif mode == "parsing":
            frontend_cmd += ["--parse-only"]
        else:
            frontend_cmd += ["--ir-hw"]

        for incdir in params["incdirs"]:
            frontend_cmd.extend(["-I", incdir])

        for define in params["defines"]:
            frontend_cmd.extend(["-D", define])

        frontend_cmd += ["--timescale=1ns/1ns", "--single-unit"]
        frontend_cmd += ["-Wno-implicit-conv"]
        frontend_cmd += [
            "-Wno-error=index-oob",
            "-Wno-error=range-oob",
            "-Wno-error=range-width-oob",
        ]

        top = self.get_top_module_or_guess(params)
        if top is not None:
            frontend_cmd += ["--top=" + top]

        tags = params["tags"]

        if "ariane" in tags or "ibex" in tags:
            frontend_cmd += ["-Wno-duplicate-definition"]

        if "ariane" in tags:
            frontend_cmd += ["--allow-self-determined-stream-concat"]

        if "black-parrot" in tags and mode != "parsing":
            frontend_cmd += ["--allow-use-before-declare"]

            name = params["name"]
            if "bp_lce" in name or "bp_uce" in name or "bp_multicore" in name:
                frontend_cmd += ["--parse-only"]

        if "fx68k" in tags:
            frontend_cmd += ["--allow-dup-initial-drivers"]

        frontend_cmd += params["files"]

        runner_scr = os.path.join(tmp_dir, "scr.sh")
        mlir_file = os.path.join(tmp_dir, "input.mlir")

        with open(runner_scr, "w") as f:
            f.write("set -e\n")
            f.write("set -x\n")
            if mode == "elaboration":
                f.write(f"{shlex.join(frontend_cmd)} -o {shlex.quote(mlir_file)}\n")
                backend_cmd = [self.executable, "--disable-output", mlir_file]
                if "runner_arcilator_flags" in params:
                    backend_cmd += shlex.split(params["runner_arcilator_flags"])
                f.write(f"{shlex.join(backend_cmd)}\n")
            else:
                f.write(f"{shlex.join(frontend_cmd)}\n")

        self.cmd = ["sh", runner_scr]
