# SystemVerilog Tester

[![License](https://img.shields.io/github/license/chipsalliance/sv-tests.svg)](https://github.com/chipsalliance/sv-tests/blob/master/LICENSE)
[![Build Status](https://github.com/chipsalliance/sv-tests/workflows/sv-tests-ci/badge.svg)](https://github.com/chipsalliance/sv-tests/actions)

The purpose of this project is to find all the supported and missing SystemVerilog features in various Verilog tools.

The report generated from the last passing master build can be viewed [on a dedicated dashboard:](https://chipsalliance.github.io/sv-tests-results/)
[![Grid](./img/sv-test-grid.png)](https://chipsalliance.github.io/sv-tests-results/)

# Running

Initialize the submodules:

```bash
git submodule update --init --recursive
```

Install all the python dependencies and make sure the installed binaries can be called.

```bash
pip3 install --user -r conf/requirements.txt
export PATH=~/.local/bin:$PATH
```

Build tools (optional, tools from `PATH` can be used):

```bash
make -k runners
```

And then just run:

```bash
make generate-tests -j$(nproc)
make -j$(nproc)
```

This should generate many log files for all the tools/tests combinations and an `out/report.html` file with a summary of the tested features and tools.

If you don't want to generate the report file, but are interested in just running all the tests, you can run:

```bash
make tests
```

## Adding new test cases

Adding a new test case is a two step process.
First you create the test case itself which should use only a minimal required subset of SystemVerilog to test a particular feature.
Additionally each test should cover only a single feature.
If the test must use several features, each of those must be also covered in separate test cases.

After creating a new test case it must be correctly tagged:

* `name` - must be unique and should be directly related to what the test case covers.
* `description` - should provide a short description that will be visible in the report page.
* `should_fail_because` - must be used if the test is expected to fail and should contain the reason of failure.
* `files` - is a list of files used by this test case, can be omitted to use only the main file with metadata.
* `incdirs` - can be used to provide a list of include directories, can be omitted to use only the default ones.
* `top_module` - optional, allows to specify which module is the top one.
* `tags` - tag must be used to specify which part of SystemVerilog specification this test case covers.
* `defines` - provides a list of macros for preprocessor.
  If the test case uses several SystemVerilog features, only the feature directly tested should be included in tags.
  List of existing tags is located in `conf/lrm.conf`.

Finally the file containing the test case and metadata should be placed in `tests/chapter-([0-9]+)/` subdirectory based on the `tags` fields specified earlier.

## Importing existing tests from a test suite/core/tool

1. Add the tests as a submodule to this repository via `git submodule add <git_url> third_party/<category>/<name>`.
   If you want to add tests from a tool that is already in `third_party/tools` you can skip this step.
2. Add a new tag named `<name>` to `conf/lrm.conf` together with a short description.
3. Generate wrapper `.sv` files by either:
   * Adding a new config to `conf/generators/meta-path/` that will be used by `generators/path_generator`.
   * Adding a new generator script to `generators/` that will create required wrappers.

   First method works well with test suites in which each test case is contained in a separate Verilog file.
   If the test suite provides metadata that must be processed or you are importing an IP core then you should create custom generator script.

   Use tag that you added in the previous step.

## Adding a new tool

1. Make the tool available from [Anaconda](https://anaconda.org/) by either:
   * Adding the tool to the [SymbiFlow/conda-packages](https://github.com/SymbiFlow/conda-packages) repository.
   * Adding the tool to any other `conda` channel.

   If the tool is already available as a `conda` package you can skip this step.
2. Add the conda package as a dependency in `conf/environment.yml`.
3. Add the tool as a submodule to this repository via `git submodule add <git_url> third_party/tools/<name>`.
4. Add a target for building and installing the tool manually in `tools/runners.mk`
5. Create a new runner script in `tools/runners/<name>.py` that will contain a subclass of `BaseRunner` named `<name>`.
   This subclass will need to at least implement the following methods:
   * `__init__` to provide general information about the tool.
   * `prepare_run_cb` to prepare correct tool invocation that will be used during tests.

   If the new tool is a Python library, reimplement `run` and other supporting methods instead of implementing `prepare_run_cb`.

## Supported tools

* [Yosys](http://www.clifford.at/yosys)
* [Odin II](https://verilogtorouting.org)
* [Verilator](https://verilator.org)
* [Icarus](http://iverilog.icarus.com)
* [slang](https://github.com/MikePopoloski/slang)
* [sv2v(zachjs)](https://github.com/zachjs/sv2v)
* [tree-sitter-verilog](https://github.com/tree-sitter/tree-sitter-verilog)
* [sv-parser](https://github.com/dalance/sv-parser)
* [moore](http://llhd.io)
* [verible](https://github.com/google/verible)
