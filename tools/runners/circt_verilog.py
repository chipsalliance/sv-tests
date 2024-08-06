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

class circt_verilog(BaseRunner):
    def __init__(
            self,
            name="circt-verilog",
            supported_features={'preprocessing', 'parsing', 'elaboration'}):
        super().__init__(
            name,
            executable="circt-verilog",
            supported_features=supported_features)
        
        self.submodule = "third_party/tools/circt-verilog"
        self.url = f"https://github.com/llvm/circt/tree/{self.get_commit()}"
    
    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]
        mode = params['mode']
        
        # Different ways to process the input: The preprocessor indicates only run and print
        # preprocessed files; parsing means only lint the input, without elaboration and
        # mapping to CIRCT IR; linting only lint the input, without elaboration and mapping
        # CIRCT IR.
        if mode == 'preprocessing':
            self.cmd += ['-E']
        elif mode == 'parsing':
            self.cmd += ('--parse-only')
        
        # Setting for additional include search paths.
        for incdir in params['incdirs']:
            self.cmd.extend(['-I', incdir])
        
        # Setting for macro or value defines in all source files.
        for define in params['defines']:
            self.cmd.extend(['-D', define])
        
        # Borrow from slang config for some modules which get errors without a default timescale.
        self.cmd += ['--timescale=1ns/1ns']

        # Combine all input files for the tests that need a single compilation unit.
        self.cmd += ['--single-unit']

        top = self.get_top_module_or_guess(params)
        if top is not None:
            self.cmd += ['--top=' + top]

        self.cmd += params['files']

    def get_version(self):
        version = super().get_version()

        return " ".join([self.name, version.splitlines()[4].split()[2]])
