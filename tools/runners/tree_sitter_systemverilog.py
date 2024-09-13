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
import sys
import resource

from tree_sitter import Language, Parser
from BaseRunner import BaseRunner


class tree_sitter_systemverilog(BaseRunner):
    libname = 'tree-sitter-systemverilog.so'
    locpath = ['runners', 'lib', libname]
    conpath = ['lib', libname]

    def __init__(self):
        super().__init__("tree-sitter-systemverilog", None, {"parsing"})

        self.submodule = "third_party/tools/tree-sitter-systemverilog"
        self.url = f"https://github.com/gmlarumbe/tree-sitter-systemverilog/tree/{self.get_commit()}"

    def find_lib(self):
        local_lib = ''
        conda_lib = ''
        try:
            out = os.environ['OUT_DIR']
            local_lib = os.path.abspath(os.path.join(out, *self.locpath))
        except KeyError:
            pass

        try:
            prefix = os.environ['CONDA_PREFIX']
            conda_lib = os.path.abspath(os.path.join(prefix, *self.conpath))
        except KeyError:
            pass

        return local_lib if os.path.isfile(local_lib) else conda_lib

    def log_error(self, fname, row, col, err):
        self.log += '{}:{}:{}: error: {}\n'.format(fname, row, col, err)

    def walk(self, node, fname):
        if not node.has_error:
            return False

        last_err = True

        for child in node.children:
            if self.walk(child, fname):
                last_err = False

        if last_err:
            self.log_error(fname, *node.start_point, 'node type: ' + node.type)

        return True

    def run(self, tmp_dir, params):
        self.ret = 0
        self.log = ''

        try:
            lib = self.find_lib()

            lang = Language(lib, 'verilog')

            parser = Parser()
            parser.set_language(lang)
        except Exception as e:
            self.log += f'{e}\n'
            self.ret = 1

        for src in params['files']:
            f = None
            try:
                f = open(src, 'rb')
            except IOError:
                self.ret = 1
                self.log_error(src, '', '', 'failed to open file')
                continue

            try:
                tree = parser.parse(f.read())
                if self.walk(tree.root_node, src):
                    self.ret = 1
            except Exception as e:
                self.log_error(src, '', '', 'unknown error: ' + str(e))
                self.ret = 1
        usage = resource.getrusage(resource.RUSAGE_SELF)
        profiling_data = (usage.ru_utime, usage.ru_stime, usage.ru_maxrss)

        return (self.log, self.ret) + profiling_data

    def can_run(self):
        return os.path.isfile(self.find_lib())
