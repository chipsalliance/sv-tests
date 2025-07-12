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


class tree_sitter_systemverilog(BaseRunner):
    def __init__(self):
        super().__init__(
            "tree-sitter-systemverilog", "tree-sitter", {"parsing"})

        self.submodule = "third_party/tools/tree-sitter-systemverilog"
        self.url = f"https://github.com/gmlarumbe/tree-sitter-systemverilog/tree/{self.get_commit()}"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [
            self.executable, 'parse', '--scope', 'source.systemverilog'
        ]
        self.cmd += params['files']
