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


class sv_parser(BaseRunner):
    def __init__(self):
        super().__init__("sv-parser", "parse_sv", {"preprocessing", "parsing"})

        self.submodule = "third_party/tools/sv-parser"
        self.url = f"https://github.com/dalance/sv-parser/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        for incdir in params['incdirs']:
            self.cmd.append('--include')
            self.cmd.append(incdir)

        for define in params['defines']:
            self.cmd.append('--define')
            self.cmd.append(define)

        self.cmd += params['files']
