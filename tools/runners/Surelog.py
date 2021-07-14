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

        self.url = "https://github.com/alainmarcel/Surelog"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, '-nopython', '-nobuiltin', '-parse']

        if not strtobool(params['allow_elaboration']):
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

        # lowmem option
        if "black-parrot" in params["tags"]:
            self.cmd.append('-lowmem')

        if "earlgrey" in params["tags"]:
            self.cmd.append('-lowmem')

        # regular options
        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']

    def is_success_returncode(self, rc, params):
        # We're only interested in
        # syntax, fatal and errors.
        return rc & 0x07 == 0
