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

import os
import shlex


class VeribleExtractor(BaseRunner):
    def __init__(self):
        super().__init__(
            "verible_extractor", "verible-verilog-kythe-extractor",
            {"parsing"})

        self.url = "https://github.com/google/verible"

    def prepare_run_cb(self, tmp_dir, params):
        src_list_path = os.path.join(tmp_dir, "src_list")
        script_path = os.path.join(tmp_dir, "run.sh")

        with open(src_list_path, "w") as src_list:
            files = [os.path.abspath(f) for f in params.get("files", [])]
            print("\n".join(files), file=src_list)

        inc_dirs = ",".join(params.get("incdirs", []))

        with open(script_path, "w") as script:
            command = (
                '{executable}'
                ' --file_list_root "/"'
                ' --include_dir_paths {inc_dirs}'
                ' --file_list_path {src_list_path}').format(
                    executable=self.executable,
                    inc_dirs=shlex.quote(inc_dirs),
                    src_list_path=shlex.quote(src_list_path))
            s = (
                'echo "#" {command_str}\n'
                'log="$( {command} 2>&1 1>/dev/null )"\n'
                'rc=$?\n'
                'echo "stderr:"\n'
                'echo "$log"\n'
                'if [ $rc -eq 0 ]; then\n'
                # Use the log output as an information that something failed.
                # Ignore warnings about re-defining macros, and empty lines.
                '    ! echo "$log" | grep -v -e "^I .*] Re-defining macro.*" -e "^$" -q\n'
                '    rc=$?\n'
                'fi\n'
                'exit $rc\n').format(
                    command_str=shlex.quote(command), command=command)
            script.write(s)

        self.cmd = ['sh', script_path]
