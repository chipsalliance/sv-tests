#!/usr/bin/env python3
#
# Copyright (C) 2020 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

import re


def parseLog(log):
    res = True
    for line in log.split('\n'):
        pat = re.search(r':([a-z]+):(.*)', line.strip())
        if pat:
            if pat.group(1) == 'assert':
                expr = pat.group(2)
                try:
                    if not eval(expr):
                        res = False
                except Exception:
                    res = False
    return res
