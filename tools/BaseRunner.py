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

import psutil
import resource
import shutil
import signal
import subprocess
import os
import re


def set_process_limits():
    """Make sure processes behave. Limit memory to 4GiB"""
    resource.setrlimit(resource.RLIMIT_DATA, (4 << 30, 4 << 30))


def kill_child_processes(parent_pid, sig=signal.SIGKILL):
    try:
        parent = psutil.Process(parent_pid)
    except psutil.NoSuchProcess:
        return
    children = parent.children(recursive=True)
    for process in children:
        process.send_signal(sig)


class BaseRunner:
    """Common base class shared by all runners
    Each runner must either implement prepare_run_cb
    or override the run method.

    prepare_run_cb is responsible for generating command to run
    and preparing the command working directory if required by the tool.

    Runners must be located in tools/runners subdirectory
    to be detected and launched by the Makefile.
    """
    def __init__(
            self,
            name,
            executable=None,
            supported_features={'preprocessing', 'parsing', 'simulation'}):
        """Base runner class constructor
        Arguments:
        name -- runner name.
        executable -- name of an executable used by the particular runner
        can be omitted if default can_run method isn't used.
        supported_features -- list of supported test types
        """
        self.name = name
        self.executable = executable
        self.supported_features = supported_features

        self.url = "https://github.com/symbiflow/sv-tests"

    def get_mode(self, test_features, compatible_runners):
        """Determine correct run mode or return None when incompatible
        """
        if "all" not in compatible_runners:
            if self.name not in compatible_runners:
                return None
        basic_features = ['parsing', 'preprocessing']
        previous_required = False
        for feature in basic_features:
            if feature in test_features and feature not in self.supported_features and previous_required:
                return None
            if feature in test_features and feature in self.supported_features:
                previous_required = True

        features = ['simulation', *basic_features]

        for feature in features:
            if feature in test_features and feature in self.supported_features:
                return feature

    def run(self, tmp_dir, params):
        """Run the provided test case
        This method is called by the main runner script (tools/runner).

        Arguments:
        tmp_dir -- temporary directory created for this test run.
        params -- dictionary with all metadata from the test file.
                  All keys are used without colons, ie. :tags: becomes tags.

        Returns a tuple containing command execution log, return code,
        user time, system time and ram usage
        """
        result = self.run_subprocess(tmp_dir, params)

        usage = resource.getrusage(resource.RUSAGE_CHILDREN)
        profiling_data = (usage.ru_utime, usage.ru_stime, usage.ru_maxrss)

        return result + profiling_data

    def run_subprocess(self, tmp_dir, params):
        """ Run the test case's subprocess

        This method is called by the run method and is expected to execute the
        command prepared in `self.cmd`. Subclasses may choose to override this
        in order to intercept the execution of the subprocess or inject custom
        return codes.

        Arguments are the same as for the run method.

        Returns a tuple containing command execution log and return code.
        """
        self.prepare_run_cb(tmp_dir, params)

        proc = subprocess.Popen(
            self.cmd,
            cwd=tmp_dir,
            preexec_fn=set_process_limits,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)

        timeout = int(params['timeout'])
        if 'DISABLE_TEST_TIMEOUTS' in os.environ:
            timeout = None
        else:
            try:
                timeout = int(os.environ['OVERRIDE_TEST_TIMEOUTS'])
            except KeyError:
                # continue with timeout from params
                pass
            except ValueError:
                return ("Invalid OVERRIDE_TEST_TIMEOUTS value", 1)

        try:
            log, _ = proc.communicate(timeout=timeout)
            returncode = proc.returncode
        except subprocess.TimeoutExpired:
            kill_child_processes(proc.pid)
            proc.kill()
            proc.communicate()
            log = ("Timeout: > " + str(timeout) + "s").encode('utf-8')
            returncode = 71  # 71meout :) - something easy to grep for

        invocation_log = " ".join(self.cmd) + "\n"

        return (
            invocation_log + self.transform_log(log.decode('utf-8', 'ignore')),
            returncode)

    def is_success_returncode(self, rc, params):
        """ Returns a boolean if the given returncode is considered a success.

        This function determines if the tool was running successfully. Tools
        might return more rich return codes, so not all non-zero codes might
        mean failure.
        """
        return rc == 0

    def transform_log(self, output):
        """ Post-process the output log

        Subclasses may choose to override this in order to transform the output
        of the command.
        """
        return output

    def can_run(self):
        """Check if runner can be used
        This method is called by the main runner script (tools/runner) as
        a sanity check to verify that tool used by the runner is properly
        installed.

        Returns True when tool is installed and can be used, False otherwise.
        """
        return shutil.which(self.executable) is not None

    def get_version_cmd(self):
        """ Get version command

        Returns a list containing the command and arguments needed to get the
                version.
        """

        # assume sane defaults
        return [self.executable, "--version"]

    def get_version(self):
        """Attempt to get the version of the tool

        Returns a version string
        """

        try:
            cmd = self.get_version_cmd()

            proc = subprocess.Popen(
                cmd,
                preexec_fn=set_process_limits,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT)

            log, _ = proc.communicate()

            if proc.returncode != 0:
                return self.name

            return log.decode('utf-8')
        except (TypeError, NameError, OSError):
            return self.name

    def get_url(self):
        """Get the URL to the homepage of the runner

        Returns a string with the URL
        """

        return self.url

    def get_top_module_or_guess(self, params):
        """ Get the top-level module from the params, or guess it
        """
        return params['top_module'] or self.guess_top_module(params)

    def guess_top_module(self, params):
        """ Guess the top-level module

        If the params do not contain a top-level module, guess it by grepping
        for the first module in the first file. This works for single-module
        tests, but is likely to give false results in more complex tests.
        """
        regex = re.compile(r'module\s+(\w+)\s*[#(;]')
        for fn in params['files']:
            with open(fn) as f:
                try:
                    m = regex.search(f.read())
                except UnicodeDecodeError:
                    continue
                if m:
                    return m.group(1)
        return None
