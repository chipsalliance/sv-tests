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


class UhdmVerilator(BaseRunner):
    def __init__(self):
        super().__init__(
            "verilator-uhdm", "verilator-uhdm", {
                "preprocessing", "parsing", "elaboration", "simulation",
                "simulation_without_run"
            })

        self.c_extensions = ['.cc', '.c', '.cpp', '.h', '.hpp']
        self.allowed_extensions.extend(['.vlt'] + self.c_extensions)
        self.submodule = "third_party/tools/verilator-uhdm"
        self.url = f"https://github.com/antmicro/verilator/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']
        conf = os.environ['CONF_DIR']
        scr = os.path.join(tmp_dir, 'scr.sh')

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', scr]

        self.cmd += ['--uhdm-ast', '-cc', 'slpp_all/surelog.uhdm']

        # Remove once uhdm-verilator upgrades to Verilator 5:
        self.cmd += ['-CFLAGS', '-DV4']

        # Flags for compliance testing:
        self.cmd += ['-Wno-fatal', '-Wno-UNOPTFLAT', '-Wno-BLKANDNBLK']

        top = self.get_top_module_or_guess(params)
        if top is not None:
            self.cmd += ['--top-module', top]

        # top is None only if the test contains no module
        # if that test would be run with simulation related options
        # Verilator throws error on that test before the build stage
        build_name = f'V{top}'
        build_dir = 'vbuild'

        is_simple_test = False
        if all(os.path.splitext(filename)[1] not in self.c_extensions
               for filename in params['files']):
            # Test doesn't contain any c related file,
            # but one is required for the simulation.
            # We need to provide file with main function
            # and change the build_name to match with include in this file
            is_simple_test = True
            build_name = 'Vtop'

        if mode in ['simulation', 'simulation_without_run']:
            self.cmd += [
                '--Mdir', build_dir, '--prefix', build_name, '--exe', '-o',
                build_name
            ]
            if is_simple_test:
                shutil.copy(
                    os.path.join(conf, 'runners', 'vmain.cpp'), tmp_dir)
                self.cmd.append('vmain.cpp')
            else:
                for filename in params['files']:
                    if os.path.splitext(filename)[1] in self.c_extensions:
                        self.cmd.append(filename)

        if 'runner_verilator_flags' in params:
            self.cmd += shlex.split(params['runner_verilator_flags'])

        with open(scr, 'w') as f:
            f.write("set -e\n")
            f.write('set -x\n')
            f.write(
                'surelog -nopython -nobuiltin -parse -sverilog -nonote -noinfo -nowarning'
            )

            if top is not None:
                f.write(f' --top-module {top}')

            # lowmem option
            if "black-parrot" in params["tags"]:
                f.write(' -lowmem')

            if mode in ["parsing", "preprocessing"]:
                f.write(' -noelab')

            for i in params['incdirs']:
                f.write(f' -I{i}')

            for d in params["defines"]:
                f.write(f" -D{d}")

            for fn in params['files']:
                f.write(f' {fn}')

            f.write("\n")

            # only run verilation if elaboration is needed
            if mode in ['elaboration', 'simulation_without_run', 'simulation']:
                f.write(f'{self.executable} "$@" || exit $?\n')

            # compile the code
            if mode in ['simulation_without_run', 'simulation']:
                f.write(f'make -C {build_dir} -f {build_name}.mk\n')

            # run
            if mode == 'simulation':
                f.write(f'./{build_dir}/{build_name}\n')
