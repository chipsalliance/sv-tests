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
import shlex

from BaseRunner import BaseRunner


class Verilator(BaseRunner):
    def __init__(self):
        super().__init__(
            "verilator", "verilator", {
                "preprocessing", "parsing", "elaboration", "simulation",
                "simulation_without_run"
            })

        self.c_extensions = ['.cc', '.c', '.cpp', '.h', '.hpp']
        self.allowed_extensions.extend(['.vlt'] + self.c_extensions)
        self.submodule = "third_party/tools/verilator"
        self.url = f"https://github.com/verilator/verilator/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']
        conf = os.environ['CONF_DIR']
        scr = os.path.join(tmp_dir, 'scr.sh')

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', 'scr.sh']

        # Enable timing control support:
        self.cmd.append('--timing')

        if mode in ['simulation', 'simulation_without_run']:
            self.cmd += ['--cc']
        elif mode == 'preprocessing':
            self.cmd += ['-P', '-E']
        else:  # parsing and elaboration
            self.cmd += ['--lint-only']

        self.cmd += ['-Wno-fatal', '-Wno-UNOPTFLAT', '-Wno-BLKANDNBLK']
        # Flags for compliance testing:
        self.cmd += ['-Wpedantic', '-Wno-context']

        if params['top_module'] != '':
            self.cmd += ['--top-module', params['top_module']]
            top = params['top_module']
        else:
            top = 'top'

        # top is None only if the test contains no module
        # if that test would be run with simulation related options
        # Verilator throws error on that test before the build stage
        build_name = f'V{top}'
        build_dir = 'vbuild'

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        if all(os.path.splitext(filename)[1] not in self.c_extensions
               for filename in params['files']):
            # Test doesn't contain any c related file,
            # but one is required for the simulation.
            # We need to provide file with main function
            is_simple_test = True
            self.cmd.append('--main')

        if mode in ['simulation', 'simulation_without_run']:
            self.cmd += [
                '--Mdir', build_dir, '--prefix', build_name, '--exe', '-o',
                build_name
            ]

        if 'runner_verilator_flags' in params:
            self.cmd += shlex.split(params['runner_verilator_flags'])

        for define in params['defines']:
            self.cmd.append('-D' + define)

        self.cmd += params['files']

        with open(scr, 'w') as f:
            f.write('set -x\n')
            f.write('{0} "$@" || exit $?\n'.format(self.executable))
            if mode in ['simulation', 'simulation_without_run']:
                f.write(f'make -C {build_dir} -f {build_name}.mk\n')
            if mode == 'simulation':
                f.write(f'./{build_dir}/{build_name}')
