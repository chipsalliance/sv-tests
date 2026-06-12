#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2026 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
#
# Shared helpers for CIRCT-backed sv-tests runners.
#
# The force_failure_* helpers below only ever demote a status-0 run to a
# failure when its own log contradicts the exit code; they never promote a
# failing run to a pass.

import re

from pathlib import Path

UVM_FATAL_DIAGNOSTIC_PATTERN = re.compile(r"(^|\n)UVM_(ERROR|FATAL)\b")
UVM_TEST_PASSED_PATTERN = re.compile(r"\bUVM TEST PASSED\b", re.IGNORECASE)
UVM_TEST_FAILED_PATTERN = re.compile(r"\bUVM TEST FAILED\b", re.IGNORECASE)

FATAL_DIAGNOSTIC_PATTERNS = [
    re.compile(r"(^|\n)[^\n]*:\d+:\d+:\s+error:", re.IGNORECASE),
    re.compile(r"(^|\n)(error|fatal):", re.IGNORECASE),
    UVM_FATAL_DIAGNOSTIC_PATTERN,
    re.compile(r"\bJIT session error\b", re.IGNORECASE),
    re.compile(r"\bFailed to materialize symbols\b", re.IGNORECASE),
    re.compile(r"\bSymbols not found\b", re.IGNORECASE),
    re.compile(r"\bfailed to run simulation\b", re.IGNORECASE),
    re.compile(r"\bunsupported system call\b", re.IGNORECASE),
]

# A simulation that exits with status 0 while printing one of these markers
# reported its own failure; the row must not be counted as a pass.
SELF_REPORTED_FAILURE_PATTERNS = [
    re.compile(r"\[\*+\s*TEST\s+FAILED\s*\*+\]", re.IGNORECASE),
    re.compile(r"\bUVM\s+TEST\s+FAILED\b", re.IGNORECASE),
    re.compile(r"\bTEST\s+FAILED\b", re.IGNORECASE),
    re.compile(r"\bforce\s+test\s+failed\b", re.IGNORECASE),
    re.compile(r"^\s*Failed:\s", re.IGNORECASE),
    re.compile(r"(^|\n)[^\n]*\bFAILED\b"),
]

# Benign summary lines that merely mention failure counts of zero.
SELF_REPORTED_FAILURE_IGNORE_PATTERNS = [
    re.compile(r"\b0\s+(?:failed|failures?)\b", re.IGNORECASE),
    re.compile(r"\bno\s+(?:failed|failures?)\b", re.IGNORECASE),
    re.compile(r"\bUVM_(?:ERROR|FATAL)\s*:\s*0\b", re.IGNORECASE),
]

# Scoreboard summaries that report that nothing was exercised. A status-0
# run that did no work is not a pass.
VACUOUS_SUCCESS_PATTERNS = [
    re.compile(r"\bNo\s+SPI\s+transfers\s+took\s+place\b", re.IGNORECASE),
]

DIRECT_RUNTIME_MARKERS = (
    ":assert:",
    "$display",
    "$error",
)


def has_hierarchical_printtimescale(params):
    """Return true if a row uses $printtimescale with an explicit scope.

    Slang resolves that scope against the elaborated hierarchy.  For rows
    that intentionally name a top-level module outside the guessed "top"
    module, passing --top=<guess> prunes the referenced hierarchy and turns
    a valid source row into a runner-induced source error.
    """
    pattern = re.compile(r"\$printtimescale\s*\(\s*[^)\s]")
    for path in params.get("files", []):
        try:
            with open(path, encoding="utf-8", errors="ignore") as source:
                if pattern.search(source.read()):
                    return True
        except OSError:
            continue
    return False


def has_passing_uvm_summary(output):
    return (
        UVM_TEST_PASSED_PATTERN.search(output) is not None
        and UVM_TEST_FAILED_PATTERN.search(output) is None)


def has_fatal_diagnostics(output):
    allow_uvm_diagnostics = has_passing_uvm_summary(output)
    for pattern in FATAL_DIAGNOSTIC_PATTERNS:
        if allow_uvm_diagnostics and pattern is UVM_FATAL_DIAGNOSTIC_PATTERN:
            continue
        if pattern.search(output):
            return True
    return False


def force_failure_on_fatal_diagnostics(output, rc):
    if rc == 0 and has_fatal_diagnostics(output):
        output += (
            "\n[sv-tests strict] CIRCT-backed runner produced fatal "
            "diagnostics while returning status 0; treating execution as "
            "failed for dashboard accounting.\n")
        return output, 1
    return output, rc


def has_runtime_assertion_output_mismatch(output):
    for line in output.splitlines():
        if not re.match(r"^UVM_(INFO|WARNING|ERROR|FATAL)\b", line):
            continue
        match = re.search(r":assert:\s*(.*)$", line)
        if not match:
            continue
        try:
            if not eval(match.group(1), {"__builtins__": {}}, {}):
                return True
        except Exception:
            return True
    return False


def force_failure_on_assertion_output_mismatch(output, rc):
    if rc == 0 and has_runtime_assertion_output_mismatch(output):
        output += (
            "\n[sv-tests strict] Arcilator produced an assertion-output "
            "mismatch while returning status 0; treating execution as failed "
            "for dashboard accounting.\n")
        return output, 1
    return output, rc


def _iter_param_files(params):
    files = params.get("files", [])
    if isinstance(files, str):
        files = files.split()
    return files


def _is_uvm_library_source_path(file_name):
    parts = Path(str(file_name)).parts
    return any(
        parts[i:i + 2] == ("uvm", "src")
        for i in range(max(len(parts) - 1, 0)))


def _iter_user_source_texts(params):
    for file_name in _iter_param_files(params):
        if not str(file_name).endswith(".sv"):
            continue
        if _is_uvm_library_source_path(file_name):
            continue
        try:
            yield Path(file_name).read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue


def _top_level_uvm_runtime_call(text):
    return re.search(
        r"\binitial\b(?:(?!\bend\b).)*(`uvm_info|`uvm_error|`uvm_fatal|"
        r"uvm_info\s*\(|uvm_error\s*\(|uvm_fatal\s*\()",
        text,
        re.DOTALL,
    ) is not None


def _source_has_runtime_observable(params):
    for text in _iter_user_source_texts(params):
        if any(marker in text for marker in DIRECT_RUNTIME_MARKERS):
            return True
        if "run_test" in text:
            return True
        if _top_level_uvm_runtime_call(text):
            return True
    return False


def _arcilator_run_payload(output):
    lines = output.splitlines()
    run_index = None
    for index, line in enumerate(lines):
        if line.startswith("+ ") and "arcilator" in line and "--run" in line:
            run_index = index
    if run_index is None:
        return None
    return [
        line for line in lines[run_index + 1:]
        if line.strip() and not line.startswith("+ ")
    ]


def force_failure_on_missing_runtime_output(output, rc, params):
    if rc != 0 or params.get("mode") != "simulation":
        return output, rc
    payload = _arcilator_run_payload(output)
    if payload == [] and _source_has_runtime_observable(params):
        output += (
            "\n[sv-tests strict] Arcilator returned status 0 without runtime "
            "output for a simulation test that has user-visible runtime "
            "observability; treating execution as failed for dashboard "
            "accounting.\n")
        return output, 1
    return output, rc


def self_reported_failure_line(output):
    for line in output.splitlines():
        if line.startswith("[sv-tests strict] "):
            continue
        if any(pattern.search(line)
               for pattern in SELF_REPORTED_FAILURE_IGNORE_PATTERNS):
            continue
        if any(pattern.search(line)
               for pattern in SELF_REPORTED_FAILURE_PATTERNS):
            return line
    return None


def strict_demotion_line(output):
    line = self_reported_failure_line(output)
    if line is not None:
        return "self-reported failure", line
    for line in output.splitlines():
        if line.startswith("[sv-tests strict] "):
            continue
        if any(pattern.search(line) for pattern in VACUOUS_SUCCESS_PATTERNS):
            return "vacuous success", line
    return None


def force_failure_on_self_reported_failure(output, rc, params):
    demotion = strict_demotion_line(output)
    if rc == 0 and params.get("mode") == "simulation" and demotion is not None:
        kind, _ = demotion
        output += (
            "\n[sv-tests strict] Arcilator produced a "
            f"{kind} line while returning status 0; treating execution "
            "as failed for dashboard accounting.\n")
        return output, 1
    return output, rc
