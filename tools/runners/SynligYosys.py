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


class SynligYosys(BaseRunner):
    def __init__(self):
        super().__init__(
            "yosys-synlig", "yosys-synlig",
            {"preprocessing", "parsing", "elaboration"})

        self.submodule = "third_party/tools/synlig"
        self.url = f"https://github.com/chipsalliance/synlig/tree/{self.get_commit()}"

    def get_mode(self, params):
        unsynthesizable = int(params['unsynthesizable'])
        if unsynthesizable:
            return None
        return super().get_mode(params)

    def prepare_run_cb(self, tmp_dir, params):
        runner_scr = os.path.join(tmp_dir, "scr.sh")
        yosys_scr = os.path.join(tmp_dir, "yosys-script")
        mode = params['mode']

        top = params['top_module'] or None

        # generate yosys script
        with open(yosys_scr, "w") as f:
            f.write("plugin -i systemverilog\n")
            f.write(
                "read_systemverilog -nopython -parse -sverilog -nonote -noinfo -nowarning -DSYNTHESIS"
            )

            if mode != "elaboration":
                f.write(" -parse-only")

            if top is not None:
                f.write(f' --top-module {top}')

            if mode in ["parsing", "preprocessing"]:
                f.write(' -noelab')

            for i in params["incdirs"]:
                f.write(f" -I{i}")

            for d in params["defines"]:
                f.write(f" -D{d}")

            mem_path = None
            for fn in params["files"]:
                # Remove unsynthesizable memory modules
                if not fn.endswith("bsg_mem_1rw_sync_mask_write_bit_synth.v") \
                   and not fn.endswith("bsg_mem_1rw_sync_mask_write_bit.v"):
                    f.write(f" {fn}")
                else:
                    mem_path = fn.split("/")

            # Replace removed modules with synthesizable memory
            if mem_path != None:
                mem_path = mem_path[:-2]
                str_mem_path = "/"

                for p in mem_path:
                    str_mem_path = os.path.join(str_mem_path, p)
                str_mem_path += "/hard/ultrascale_plus/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v"

                f.write(f" {str_mem_path}")

            f.write("\n")

            if mode == "elaboration":
                # prep (without optimizations)
                if top is not None:
                    f.write(f"hierarchy -top \\{top}\n")
                else:
                    f.write("hierarchy -auto-top\n")

                f.write(
                    "proc\n"
                    "check\n"
                    "memory_dff\n"
                    "memory_collect\n"
                    "stat\n"
                    "check\n")

        # generate runner script
        with open(runner_scr, "w") as f:
            f.write("set -e\n")
            f.write("set -x\n")
            f.write(f"cat {yosys_scr}\n")
            f.write(f"{self.executable} -s {yosys_scr}\n")

        self.cmd = ["sh", runner_scr]
