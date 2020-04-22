# Copyright (C) 2020 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

from BaseRunner import BaseRunner


class Slang(BaseRunner):
    def __init__(self):
        super().__init__("slang", "slang-driver")

        self.url = "https://github.com/MikePopoloski/slang"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']

        self.cmd = [self.executable]
        if mode == 'preprocessing':
            self.cmd += ['-E']

        # Some tests expect that all input files will be concatenated into
        # a single compilation unit, so ask slang to do that.
        self.cmd += ['--single-unit']

        if params['top_module'] != '':
            self.cmd.append('--top=' + params['top_module'])

        for incdir in params['incdirs']:
            self.cmd.extend(['-I', incdir])

        for define in params['defines']:
            self.cmd.extend(['-D', define])

        self.cmd += params['files']

    def get_version(self):
        version = super().get_version()

        return " ".join([self.name, version.split()[2]])
