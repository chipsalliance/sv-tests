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

import os
import shutil

from BaseRunner import BaseRunner


class Verilator(BaseRunner):
    def __init__(self):
        super().__init__("verilator", "verilator")

        self.url = "https://verilator.org"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']
        conf = os.environ['CONF_DIR']
        scr = os.path.join(tmp_dir, 'scr.sh')

        shutil.copy(os.path.join(conf, 'runners', 'vmain.cpp'), tmp_dir)

        build_dir = 'vbuild'
        build_exe = 'vmain'

        with open(scr, 'w') as f:
            f.write('set -x\n')
            f.write('{0} $@ || exit $?\n'.format(self.executable))
            if mode == 'simulation':
                f.write('make -C {} -f Vtop.mk\n'.format(build_dir))
                f.write('./vbuild/{}'.format(build_exe))

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', 'scr.sh']

        if mode == 'simulation':
            self.cmd += ['--cc']
        elif mode == 'preprocessing':
            self.cmd += ['-E']
        else:
            self.cmd += ['--lint-only']

        self.cmd += ['-Wno-fatal', '-Wno-UNOPTFLAT', '-Wno-BLKANDNBLK']
        # Flags for compliance testing:
        self.cmd += ['-Wpedantic', '-Wno-context']

        if params['top_module'] != '':
            self.cmd.append('--top-module ' + params['top_module'])

        if mode == 'preprocessing':
            self.cmd += ['-P', '-E']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        if mode == 'simulation':
            self.cmd += [
                '--Mdir', build_dir, '--prefix', 'Vtop', '--exe', '-o',
                build_exe
            ]
            self.cmd.append('vmain.cpp')

        if 'runner_verilator_flags' in params:
            self.cmd += [params['runner_verilator_flags']]

        for define in params['defines']:
            self.cmd.append('-D' + define)

        self.cmd += params['files']
