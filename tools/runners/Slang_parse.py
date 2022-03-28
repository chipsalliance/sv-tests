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

from runners.Slang import Slang


class Slang_parse(Slang):
    def __init__(self):
        super().__init__(
            "slang-parse", supported_features={'preprocessing', 'parsing'})
