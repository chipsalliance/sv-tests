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


class UhdmVerilator(BaseRunner):
    def __init__(self):
        super().__init__("verilator-uhdm", "verilator-uhdm")

        self.allowed_extensions.extend(['.vlt', '.cc'])
        self.url = "https://github.com/alainmarcel/uhdm-integration"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']
        conf = os.environ['CONF_DIR']
        scr = os.path.join(tmp_dir, 'scr.sh')

        shutil.copy(os.path.join(conf, 'runners', 'vmain.cpp'), tmp_dir)

        build_dir = 'vbuild'
        build_exe = 'vmain'

        with open(scr, 'w') as f:
            f.write("set -e\n")
            f.write('set -x\n')
            f.write(
                'surelog -nopython -nobuiltin --disable-feature=parametersubstitution -parse -sverilog -nonote -noinfo -nowarning'
            )
            for i in params['incdirs']:
                f.write(f' -I{i}')

            for d in params["defines"]:
                f.write(f" -D{d}")

            for fn in params['files']:
                f.write(f' {fn}')

            f.write("\n")

            f.write(f'{self.executable} $@ || exit $?\n')

            # compile and run the code only for simulation
            if mode == 'simulation':
                f.write(f'make -C {build_dir} -f Vtop.mk\n')
                f.write(f'./vbuild/{build_exe}\n')

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', scr]

        self.cmd += ['--uhdm-ast -cc slpp_all/surelog.uhdm']

        # Flags for compliance testing:
        self.cmd += ['-Wno-fatal', '-Wno-UNOPTFLAT', '-Wno-BLKANDNBLK']

        top = self.get_top_module_or_guess(params)

        # surelog changes the name to work@<top>
        # and then verilator changes work@<top> -> <top>
        if top is not None:
            self.cmd.append(f'--top-module {top}')

        self.cmd += [
            '--Mdir', build_dir, '--prefix', 'Vtop', '--exe', '-o', build_exe
        ]

        self.cmd.append('vmain.cpp')
