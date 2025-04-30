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


class yosys_slang(BaseRunner):
    def __init__(self):
        super().__init__("yosys-slang", "yosys-slang", {"elaboration"})

        self.submodule = "third_party/tools/yosys-slang"
        self.url = f"https://github.com/povik/yosys-slang/tree/{self.get_commit()}"

    def get_mode(self, params):
        unsynthesizable = int(params['unsynthesizable'])
        if unsynthesizable:
            return None

        # These tests simply cannot be elaborated because they target
        # modules that have invalid parameter values for a top-level module,
        # or have an invalid configuration that results in $fatal calls.
        name = params["name"]
        tags = params["tags"]
        if "black-parrot" in tags and ('bp_lce' in name or 'bp_uce'
                                       or 'bp_multicore' in name):
            return None

        return super().get_mode(params)

    def prepare_run_cb(self, tmp_dir, params):
        yosys_scr = os.path.join(tmp_dir, "yosys-script")
        mode = params['mode']

        slang_cmd = ['-DSYNTHESIS']

        # Ignore content which is unsynthesizable or likely irrelevant for synthesis. The inclusion
        # of `--ignore-initial` is objectionable as it means the frontend won't pick up memory
        # initialization.
        slang_cmd += [
            '--ignore-timing', '--ignore-initial', '--ignore-assertions'
        ]

        # Some tests expect that all input files will be concatenated into
        # a single compilation unit, so ask slang to do that.
        slang_cmd += ['--single-unit']

        # Set a default timescale so we don't get errors about some
        # modules not having one.
        slang_cmd += ['--timescale=1ns/1ns']

        top = params['top_module'].strip() or None
        if top:
            slang_cmd.append('--top=' + top)

        for incdir in params['incdirs']:
            slang_cmd.extend(['-I', incdir])

        for define in params['defines']:
            slang_cmd.extend(['-D', define])

        # Some tests access array elements out of bounds. Make that not an error.
        slang_cmd.append("-Wno-error=index-oob")
        slang_cmd.append("-Wno-error=range-oob")
        slang_cmd.append("-Wno-error=range-width-oob")

        tags = params["tags"]

        # The Ariane core does not build correctly if VERILATOR is not defined -- it will attempt
        # to reference nonexistent modules, for example.
        if "ariane" in tags:
            slang_cmd.append("-DVERILATOR")

        # The earlgrey core requires non-standard functionality, so enable VCS compat.
        if "earlgrey" in tags:
            slang_cmd.append("--compat=vcs")

        # black-parrot has syntax errors where variables are used before they are declared.
        # This is being fixed upstream, but it might take a long time to make it to master
        # so this works around the problem in the meantime.
        if "black-parrot" in tags:
            slang_cmd.append("--allow-use-before-declare")

        # These cores use a non-standard extension to write to the same variable
        # from multiple procedures.
        if "earlgrey" in tags or "fx68k" in tags:
            slang_cmd.append("--allow-dup-initial-drivers")

        slang_cmd += params['files']

        # generate yosys script
        with open(yosys_scr, "w") as f:
            f.write("plugin -i slang\n")
            f.write(f"read_slang {' '.join(slang_cmd)}\n")

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

        self.cmd = [self.executable, "-s", yosys_scr]
