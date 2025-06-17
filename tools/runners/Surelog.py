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
from distutils.util import strtobool


class Surelog(BaseRunner):
    def __init__(self):
        super().__init__("Surelog", "surelog")

        self.submodule = "third_party/tools/Surelog"
        self.url = f"https://github.com/chipsalliance/Surelog/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, '-nopython', '-parse']

        if params['mode'] in ["parsing", "preprocessing"]:
            self.cmd.append('-noelab')

        # silence surelog
        self.cmd.append("-nonote")
        self.cmd.append("-noinfo")
        self.cmd.append("-nowarning")

        # force sverilog mode for .v files
        if "black-parrot" in params["tags"]:
            self.cmd.append('-sverilog')

        if "basejump" in params["tags"]:
            self.cmd.append('-sverilog')

        if "ivtest" in params["tags"]:
            self.cmd.append('-sverilog')

        top = params['top_module'].strip()
        if top:
            self.cmd.append('--top-module ' + top)

        # lowmem option
        if "black-parrot" in params["tags"]:
            self.cmd.append('-lowmem')

        for define in params['defines']:
            self.cmd.append('-D' + define)

        # regular options
        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']

    def is_success_returncode(self, rc, params):
        # We're only interested in
        # syntax, fatal and errors.
        return rc & 0x07 == 0
