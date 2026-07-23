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

import re


def parseLog(log, success_info):
    res = True
    success_pattern_found = False
    for line in log.split('\n'):
        if success_info is not None:
            pat = re.search(success_info, line.strip())
            if pat:
                success_pattern_found = True
        pat = re.search(r':([a-z]+):(.*)', line.strip())
        if pat:
            if pat.group(1) == 'assert':
                expr = pat.group(2)
                try:
                    if not eval(expr):
                        res = False
                except Exception:
                    res = False
    if success_info is not None:
        return res and success_pattern_found
    return res
