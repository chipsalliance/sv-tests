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
import sys

from BaseRunner import BaseRunner


class UhdmYosys(BaseRunner):
    def __init__(self):
        super().__init__("uhdm-yosys", "uhdm-yosys", {"parsing"})

        self.url = "https://github.com/alainmarcel/uhdm-integration"

    def prepare_run_cb(self, tmp_dir, params):
        runner_scr = os.path.join(tmp_dir, "scr.sh")
        yosys_scr = os.path.join(tmp_dir, "yosys-script")

        top = self.get_top_module_or_guess(params)

        # generate yosys script
        with open(yosys_scr, "w") as f:
            f.write("plugin -i uhdm\n")
            f.write("read_uhdm slpp_all/surelog.uhdm\n")

            # prep (without optimizations)
            f.write(
                f"hierarchy -top \\{top}\n"
                "proc\n"
                "check\n"
                "memory_dff\n"
                "memory_collect\n"
                "stat\n"
                "check\n"
                "write_json\n"
                "write_verilog\n")

        # generate runner script
        with open(runner_scr, "w") as f:
            f.write("set -e\n")
            f.write("set -x\n")
            f.write(
                f"surelog -nopython -nobuiltin --disable-feature=parametersubstitution -parse -sverilog -nonote -noinfo -nowarning"
            )
            for i in params["incdirs"]:
                f.write(f" -I{i}")

            for d in params["defines"]:
                f.write(f" -D{d}")

            for fn in params["files"]:
                f.write(f" {fn}")

            f.write("\n")

            f.write(f"cat {yosys_scr}\n")

            f.write(f"{self.executable} -s {yosys_scr}\n")

        self.cmd = ["sh", runner_scr]
