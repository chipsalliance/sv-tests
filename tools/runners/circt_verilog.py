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

from BaseRunner import BaseRunner


class circt_verilog(BaseRunner):
    def __init__(
        self,
        name="circt-verilog",
        supported_features={"preprocessing", "parsing", "elaboration"},
    ):
        super().__init__(
            name,
            executable="circt-verilog",
            supported_features=supported_features)

        self.submodule = "third_party/tools/circt-verilog"
        self.url = f"https://github.com/llvm/circt/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]
        mode = params["mode"]

        # To process the input: The preprocessor indicates only run and print preprocessed files;
        # parsing means only lint the input, without elaboration and mapping to CIRCT IR.
        if mode == "preprocessing":
            self.cmd += ["-E"]
        elif mode == "parsing":
            self.cmd += ["--parse-only"]

        # The following options are mostly borrowed from the Slang runner, since circt-verilog
        # uses Slang as its Verilog frontend.

        # Setting for additional include search paths.
        for incdir in params["incdirs"]:
            self.cmd.extend(["-I", incdir])

        # Setting for macro or value defines in all source files.
        for define in params["defines"]:
            self.cmd.extend(["-D", define])

        # Borrow from slang config for some modules which get errors without a default timescale.
        self.cmd += ["--timescale=1ns/1ns"]

        # Combine all input files for the tests that need a single compilation unit.
        self.cmd += ["--single-unit"]

        # Disable certain warnings to make the output less noisy.
        # Some tests access array elements out of bounds. Make that not an error.
        self.cmd += [
            "-Wno-implicit-conv",
            "-Wno-index-oob",
            "-Wno-range-oob",
            "-Wno-range-width-oob",
        ]

        top = self.get_top_module_or_guess(params)
        if top is not None:
            self.cmd += ["--top=" + top]

        tags = params["tags"]

        # The Ariane core does not build correctly if VERILATOR is not defined -- it will attempt
        # to reference nonexistent modules, for example.
        if "ariane" in tags:
            self.cmd += ["-DVERILATOR"]

        # The earlgrey core requires non-standard functionality, so enable VCS compat.
        if "earlgrey" in tags:
            self.cmd += ["--compat=vcs"]

        # black-parrot has syntax errors where variables are used before they are declared.
        # This is being fixed upstream, but it might take a long time to make it to master
        # so this works around the problem in the meantime.
        if "black-parrot" in tags and mode != "parsing":
            self.cmd += ["--allow-use-before-declare"]

            # These tests simply cannot be elaborated because they target
            # modules that have invalid parameter values for a top-level module,
            # or have an invalid configuration that results in $fatal calls.
            name = params["name"]
            if 'bp_lce' in name or 'bp_uce' or 'bp_multicore' in name:
                self.cmd += ["--parse-only"]

        self.cmd += params["files"]
