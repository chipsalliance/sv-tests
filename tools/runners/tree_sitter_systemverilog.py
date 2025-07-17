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
        self.parser_dir = os.path.abspath(
            os.environ['TREE_SITTER_SVERILOG_PARSER_DIR'])

    def prepare_run_cb(self, tmp_dir, params):
        # Tree‑sitter expects the grammar.json in $CWD/src/grammar.json,
        # so we symlink the parser directory.
        symlink_path = os.path.join(tmp_dir, 'src')
        if os.path.exists(symlink_path) is False:
            os.symlink(self.parser_dir, symlink_path, True)

        self.cmd = [self.executable, 'parse']
        self.cmd += params['files']

    def can_run(self):
        parser_c_path = os.path.join(self.parser_dir, 'parser.c')
        return os.path.exists(parser_c_path) and super().can_run()
