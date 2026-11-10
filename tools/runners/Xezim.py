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


class Xezim(BaseRunner):
    def __init__(self):
        super().__init__(
            "xezim", "xezim", {
                "preprocessing", "parsing", "elaboration", "simulation",
                "simulation_without_run"
            })

        self.submodule = "third_party/tools/xezim"
        self.url = f"https://github.com/aionhw/xezim/tree/{self.get_commit()}"

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, "--sv2017"]

        mode = params['mode']
        if mode == 'preprocessing':
            self.cmd.append('--preprocess')
        elif mode == 'parsing':
            self.cmd.append('--parse')
        elif mode in ('elaboration', 'simulation_without_run'):
            self.cmd.append('--compile')
        else:  # simulation
            self.cmd.append('--simulate')

        if params['top_module'] != '':
            self.cmd += ['-s', params['top_module']]

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        for define in params['defines']:
            self.cmd.append('-D' + define)

        self.cmd += params['files']
