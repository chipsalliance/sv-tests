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
        super().__init__(
            'icarus', 'iverilog', {
                'preprocessing', 'parsing', 'elaboration', 'simulation',
                'simulation_without_run'
            })

        self.submodule = "third_party/tools/icarus"
        self.url = f"https://github.com/steveicarus/iverilog/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        ofile = 'iverilog.out'

        self.cmd = [self.executable, '-g2012']

        self.cmd += ['-o', ofile]

        if params['mode'] == 'preprocessing':
            self.cmd.append('-E')
        elif params['mode'] == 'parsing':
            self.cmd += ['-t', 'null']

        if params['top_module'] != '':
            self.cmd += ['-s', params['top_module']]

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        for define in params['defines']:
            self.cmd.append('-D' + define)

        self.cmd += params['files']

        if params['mode'] != 'simulation':
            return

        # For simulation a wrapper script is created
        scr = os.path.join(tmp_dir, 'scr.sh')
        with open(scr, 'w') as f:
            f.write('set -x\n')
            f.write('{0} "$@" || exit $?\n'.format(self.cmd[0]))
            f.write(f'./iverilog.out\n')
        self.cmd = ['sh', 'scr.sh'] + self.cmd[1:]

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def get_version(self):
        version = super().get_version()

        # The full version is the 4th word to the end of 1st line
        version = version.splitlines()[0].split()[3:]

        version.insert(0, self.name)

        return " ".join(version)
