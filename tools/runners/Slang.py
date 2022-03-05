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
    def __init__(self):
        super().__init__(
            "slang", "slang-driver",
            {'preprocessing', 'parsing', 'elaboration'})

        self.url = "https://github.com/MikePopoloski/slang"

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

        top = params['top_module'].strip()
        if top:
            self.cmd.append('--top=' + top)

        for incdir in params['incdirs']:
            self.cmd.extend(['-I', incdir])

        for define in params['defines']:
            self.cmd.extend(['-D', define])

        tags = params["tags"]

        # The Ariane core does not build correctly if VERILATOR is not defined -- it will attempt
        # to reference nonexistent modules, for example.
        if "ariane" in tags:
            self.cmd.append("-DVERILATOR")

        # black-parrot has syntax errors where variables are used before they are declared.
        # This is being fixed upstream, but it might take a long time to make it to master
        # so this works around the problem in the meantime.
        if "black-parrot" in tags:
            self.cmd.append("--allow-use-before-declare")

            # These tests simply cannot be elaborated because they target
            # modules that have invalid parameter values for a top-level module,
            # or have an invalid configuration that results in $fatal calls.
            name = params["name"]
            if 'bp_lce' in name or 'bp_uce' or 'bp_multicore' in name:
                self.cmd.append("--parse-only")

        self.cmd += params['files']

    def get_version(self):
        version = super().get_version()

        return " ".join([self.name, version.split()[2]])
