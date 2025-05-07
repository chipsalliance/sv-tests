#!/usr/bin/env python3

import os
import csv
import json
import argparse
import subprocess

parser = argparse.ArgumentParser()

parser.add_argument("count")

args = parser.parse_args()

tools = [
    'odin_ii', 'tree-sitter-verilog', 'zachjs-sv2v', 'verilator', 'iverilog',
    'yosys', 'slang'
]

packages = {}

versions = {}

for tool in tools:
    cmd = 'conda search {} -c symbiflow --json'.format(tool)
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    log, _ = proc.communicate()
    packages[tool] = json.loads(log)

for p in packages:
    versions[p] = []
    for r in packages[p][p]:
        if r['version'] not in versions[p]:
            versions[p].append(r['version'])

os.system('rm -rf ./tests/generated')
os.system('make generate-tests')

last_ver = {}

used_versions = []

for i in range(1, int(args.count) + 1):
    os.system('rm -rf ./out')

    for tool in tools:
        try:
            ver = versions[tool][-i]
        except IndexError:
            ver = last_ver[tool]

        last_ver[tool] = ver

        os.system('conda install -y -c symbiflow {}={}'.format(tool, ver))

        print('{}={} installed'.format(tool, ver))

    used_versions.append(last_ver.copy())

    os.system('make -j12')
    os.system('cp ./out/report/report.csv report-{}.csv'.format(i))

with open('out.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(tools)
    for ver in used_versions:
        row = []
        for v in ver:
            row.append(ver[v])

        writer.writerow(row)
