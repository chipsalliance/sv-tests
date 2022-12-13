#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2020-2021 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

from BaseRunner import BaseRunner
import os


class Icarus(BaseRunner):
    def __init__(self):
        super().__init__("icarus", "iverilog", {"parsing"})

        self.url = "http://iverilog.icarus.com/"

    def prepare_run_cb(self, tmp_dir, params):
        ofile = 'iverilog.out'

        self.cmd = [self.executable, "-g2012"]

        self.cmd += ["-o", ofile]

        if params['top_module'] != '':
            self.cmd += ['-s', params['top_module']]

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        for define in params['defines']:
            self.cmd.append('-D' + define)

        self.cmd += params['files']

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def get_version(self):
        version = super().get_version()

        # The full version is the 4th word to the end of 1st line
        version = version.splitlines()[0].split()[3:]

        version.insert(0, self.name)

        return " ".join(version)
