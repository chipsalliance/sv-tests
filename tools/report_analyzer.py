#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2021 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

import argparse
import csv
import json
import sys
import pytablewriter

relevant_headers = ["Tool", "TestName", "Pass"]


def get_data(csv_path):
    with open(csv_path, newline="") as csv_file:
        report = list(csv.DictReader(csv_file))
        header = report[0].keys()

        assert set(relevant_headers).issubset(
            header), "Lack of crucial headers in CSV report " + csv_path

        tools = set(row["Tool"] for row in report)

        sorted_report = {}
        for tool in tools:
            sorted_report[tool] = {}

        for row in report:
            sorted_report[row["Tool"]][row["TestName"]] = row["Pass"]

    return sorted_report


def check_tool(tool_reportA, tool_reportB, tool_name):
    results = {
        "new_passes": [],
        "new_failures": [],
        "added": [],
        "removed": [],
        "summary": {},
    }

    testsA = set(tool_reportA.keys())
    testsB = set(tool_reportB.keys())

    tests_added = testsA.difference(testsB)
    tests_removed = testsB.difference(testsA)

    tests_comparable = testsA.intersection(testsB)

    added_cnt = len(tests_added)
    removed_cnt = len(tests_removed)
    no_change_cnt = 0

    for test in tests_comparable:
        res = check_test(tool_reportA[test], tool_reportB[test])
        if (res == -1):
            results["new_failures"].append(test)
        elif (res == 1):
            results["new_passes"].append(test)
        else:
            no_change_cnt += 1

    fail_cnt = len(results["new_failures"])
    pass_cnt = len(results["new_passes"])

    for added_test in tests_added:
        results["added"].append(added_test)

    for removed_test in tests_removed:
        results["removed"].append(removed_test)

    results["summary"]["new_failures"] = fail_cnt
    results["summary"]["new_passes"] = pass_cnt
    results["summary"]["added"] = added_cnt
    results["summary"]["removed"] = removed_cnt
    results["summary"]["not_affected"] = no_change_cnt

    return results


def check_test(test_reportA, test_reportB):
    if (test_reportA == test_reportB):
        return 0
    elif (test_reportA == "True" and test_reportB == "False"):
        return 1
    elif (test_reportA == "False" and test_reportB == "True"):
        return -1
    else:
        raise ValueError(
            "unknown test result occured: A -> " + test_reportA + " B -> " +
            test_reportB)


def check_reports(reportA, reportB):
    summary = {
        "comparable_tools": {},
        "added_tools": [],
        "removed_tools": [],
    }

    toolsA = set(reportA.keys())
    toolsB = set(reportB.keys())
    tools = toolsA.intersection(toolsB)

    if (toolsA != toolsB):
        tools_added = toolsA.difference(toolsB)
        tools_removed = toolsB.difference(toolsA)
        summary["added_tools"] = list(tools_added)
        summary["removed_tools"] = list(tools_removed)

    for tool in tools:
        tool_results = check_tool(reportA[tool], reportB[tool], tool)
        summary["comparable_tools"][tool] = tool_results

    return summary


def prepare_comment(summary, table_path):
    tools = list(summary["comparable_tools"].keys())
    cols = list(summary["comparable_tools"][tools[0]]["summary"].keys())
    cols.insert(0, "tool")

    matrix = []
    for tool in tools:
        vals = list(summary["comparable_tools"][tool]["summary"].values())
        vals.insert(0, tool)
        matrix.append(vals)

    writer = pytablewriter.MarkdownTableWriter()
    writer.table_name = "Changes In Tests"
    pretty_cols = [c.replace("_", " ").title() for c in cols]
    writer.headers = pretty_cols
    writer.value_matrix = matrix
    writer.write_table()
    with open(table_path, "w") as f:
        writer.stream = f
        writer.write_table()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "report_compare",
        help="csv report that will be compared with base report")
    parser.add_argument(
        "report_base", help="csv report that will be a base of comparison")
    parser.add_argument(
        "-o",
        "--output",
        dest="output_path",
        default="report_summary.json",
        help="path to output json file, defaults to \"report_summary.json\"")
    parser.add_argument(
        "-t",
        "--table",
        dest="table_path",
        default="report_summary.md",
        help=
        "path to output md file with summary, defaults to \"report_summary.md\""
    )
    parser.add_argument(
        "-c",
        "--changes",
        dest="changes_path",
        default="./out/report",
        help=
        "path to output csv file with names of test that changed status, defaults to \"./out/report\""
    )
    args = parser.parse_args()

    reportA = get_data(args.report_compare)
    reportB = get_data(args.report_base)

    summary = check_reports(reportA, reportB)

    with open(args.changes_path + "/new_failures.csv", "w") as csv_file:
        writer = csv.writer(csv_file)
        for tool in summary["comparable_tools"]:
            for test in summary["comparable_tools"][tool]["new_failures"]:
                writer.writerow([tool, test])
    with open(args.changes_path + "/new_passes.csv", "w") as csv_file:
        writer = csv.writer(csv_file)
        for tool in summary["comparable_tools"]:
            for test in summary["comparable_tools"][tool]["new_passes"]:
                writer.writerow([tool, test])

    prepare_comment(summary, args.table_path)

    with open(args.output_path, "w") as json_file:
        json.dump(summary, json_file, indent=4)


if __name__ == "__main__":
    main()
