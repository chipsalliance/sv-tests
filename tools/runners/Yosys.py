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

import os

from BaseRunner import BaseRunner


class Yosys(BaseRunner):
    def __init__(self):
        super().__init__("yosys", "yosys")

        self.url = "https://github.com/YosysHQ/yosys"

    def prepare_run_cb(self, tmp_dir, params):
        run = os.path.join(tmp_dir, "run.sh")
        scr = os.path.join(tmp_dir, 'scr.ys')

        inc = ""
        for incdir in params['incdirs']:
            inc += f' -I {incdir}'

        defs = ""
        for define in params['defines']:
            defs += f' -D {define}'

        # prepare yosys script
        with open(scr, 'w') as f:
            for svf in params['files']:
                f.write(f'read_verilog -sv {inc} {defs} {svf}\n')

        # prepare wrapper script
        with open(run, 'w') as f:
            f.write('set -x\n')
            f.write(f'cat {scr}\n')
            f.write(f'{self.executable} -Q -T {scr}\n')

        self.cmd = ['sh', run]

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def get_version(self):
        version = super().get_version()

        return " ".join([self.name, version.split()[1]])
