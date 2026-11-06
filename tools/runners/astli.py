#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2026 The sv-tests Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

from BaseRunner import BaseRunner


class astli(BaseRunner):
    def __init__(self):
        super().__init__(
            "astli", "astli", {"preprocessing", "parsing", "elaboration"})

        self.submodule = "third_party/tools/astli"
        self.url = f"https://github.com/fischeti/astli/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']
        commands = {
            'preprocessing': 'preprocess',
            'parsing': 'parse',
            'elaboration': 'check',
        }
        self.cmd = [self.executable, commands[mode], '--jobs', '1']

        if mode == 'parsing':
            self.cmd.extend(['--expand', '--quiet'])
        elif mode == 'elaboration':
            top = params['top_module'].strip()
            if top:
                self.cmd.extend(['--top', top])

        for incdir in params['incdirs']:
            self.cmd.extend(['-I', incdir])

        for define in params['defines']:
            self.cmd.extend(['-D', define])

        self.cmd += params['files']
