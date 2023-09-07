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

import re
from BaseRunner import BaseRunner


class moore(BaseRunner):
    def __init__(
            self,
            name="moore",
            supported_features={'preprocessing', 'parsing'}):
        super().__init__(
            name, executable="moore", supported_features=supported_features)

        self.submodule = "third_party/tools/moore"
        self.url = f"https://github.com/fabianschuiki/moore/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        for incdir in params['incdirs']:
            self.cmd.append('-I')
            self.cmd.append(incdir)

        tl = self.get_top_module_or_guess(params)
        if tl:
            self.cmd.append('-e')
            self.cmd.append(tl)

        self.cmd += params['files']

    def run_subprocess(self, tmp_dir, params):
        # Immediately fail some tests which otherwise completely break the
        # compiler.
        # TODO: Remove once #378 lands.
        blacklist = [
            "std2017/p220.sv",
            "std2017/p221.sv",
            "std2017/p745.sv",
            "std2017/p341.sv",
            "std2017/p371.sv",
            "std2017/p759.sv",
            "std2017/p773.sv",
        ]
        for arg in params['files']:
            for bl in blacklist:
                if bl in arg:
                    return ("Skipping blacklisted " + arg, 1)
        return super().run_subprocess(tmp_dir, params)

    def transform_log(self, log):
        # Strip away terminal escape codes. Moore does not yet check if the
        # stdout is a tty that supports colorization.
        log = re.sub(r'\x1B\[[0-?]*[ -/]*[@-~]', '', log)
        return log
