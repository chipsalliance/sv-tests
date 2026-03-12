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


class Slang(BaseRunner):
    def __init__(
            self,
            name="slang",
            supported_features={'preprocessing', 'parsing', 'elaboration'}):
        super().__init__(
            name,
            executable="slang-driver",
            supported_features=supported_features)

        self.submodule = "third_party/tools/slang"
        self.url = f"https://github.com/MikePopoloski/slang/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']

        self.cmd = [self.executable]
        if mode == 'preprocessing':
            self.cmd += ['-E']
        elif mode == "parsing":
            self.cmd.append("--parse-only")

        # Some tests expect that all input files will be concatenated into
        # a single compilation unit, so ask slang to do that.
        self.cmd += ['--single-unit']

        # Set a default timescale so we don't get errors about some
        # modules not having one.
        self.cmd += ['--timescale=1ns/1ns']

        top = params['top_module'].strip()
        if top:
            self.cmd.append('--top=' + top)

        for incdir in params['incdirs']:
            self.cmd.extend(['-I', incdir])

        for define in params['defines']:
            self.cmd.extend(['-D', define])

        # Some tests access array elements out of bounds. Make that not an error.
        self.cmd.append("-Wno-error=index-oob")
        self.cmd.append("-Wno-error=range-oob")
        self.cmd.append("-Wno-error=range-width-oob")

        tags = params["tags"]

        # The Ariane core has syntax errors with stream concat operators and duplicate definitions.
        if "ariane" in tags:
            self.cmd.append("--allow-self-determined-stream-concat")
            self.cmd.append("-Wno-duplicate-definition")

        # black-parrot has syntax errors where variables are used before they are declared.
        # This is being fixed upstream, but it might take a long time to make it to master
        # so this works around the problem in the meantime.
        if "black-parrot" in tags and mode != "parsing":
            self.cmd.append("--allow-use-before-declare")

            # These tests simply cannot be elaborated because they target
            # modules that have invalid parameter values for a top-level module,
            # or have an invalid configuration that results in $fatal calls.
            name = params["name"]
            if 'bp_lce' in name or 'bp_uce' or 'bp_multicore' in name:
                self.cmd.append("--parse-only")

        # These cores use a non-standard extension to write to the same variable
        # from multiple procedures.
        if "fx68k" in tags:
            self.cmd.append("--allow-dup-initial-drivers")

        self.cmd += params['files']

    def get_version(self):
        version = super().get_version()

        return " ".join([self.name, version.split()[2]])
