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


class Verible(BaseRunner):
    def __init__(self):
        super().__init__("verible", "verible-verilog-syntax", {"parsing"})

        self.submodule = "third_party/tools/verible"
        self.url = f"https://github.com/chipsalliance/verible/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        self.cmd += params['files']
