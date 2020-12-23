#!/bin/false python3
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


class Sv2v_zachjs(BaseRunner):
    def __init__(self):
        super().__init__(
            "zachjs-sv2v", "zachjs-sv2v", {"preprocessing", "parsing"})

        self.url = "https://github.com/zachjs/sv2v"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']

    def get_version(self):
        version = super().get_version()

        # sv2v stores the actual version at the second position
        revision = version.split()[1]

        # return it without the trailing comma
        return " ".join([self.name, revision[:-1]])
