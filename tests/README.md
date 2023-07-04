# Tests

This directory contains various tests.
The tests are divided into various directories.

## Chapter tests

The purpose of these tests is to verify individual features of each LRM chapter (and subchapters).
They are minimal by design and when possible, test an isolated SystemVerilog construct.

## Generated tests

Some of the tests are not stored directly in the repositories, but dynamically generated using various scripts.
The `make generate` target runs all the generators.
It creates a `generated` directory alongside the directories for each chapter and puts the generated test cases inside it.

The generators are stored in the [generators](https://github.com/SymbiFlow/sv-tests/tree/master/generators) directory.
The configuration for generators is stored in the [conf/generators](https://github.com/SymbiFlow/sv-tests/tree/master/conf/generators) directory.

There are various types of generators.
Some generate fairly simple tests, but does so in a bulk to generate multiple similar tests.
An example of this would be the [template generator](https://github.com/SymbiFlow/sv-tests/blob/master/generators/template_generator).
It has a multitude of various configs, one interesting example would be the [logical operators](https://github.com/SymbiFlow/sv-tests/blob/master/conf/generators/templates/logical.json) tests.

Some generators generate more sophisticated test cases.
These can for example be tests of full blown soft cores.
An example of this would be the [BlackParrot](https://github.com/SymbiFlow/sv-tests/blob/master/generators/black-parrot) generator.
It generates a wrapper which makes it possible to use BlackParrot as a test.

## UVM tests

The repository contains multiple tests dedicated to verifying UVM support of various tools.

The source code of UVM is stored in the [third party](https://github.com/SymbiFlow/sv-tests/tree/master/third_party/tests) directory.
The tests that want to include it need to include the `uvm` tag on the list of their tags.

The tests that use UVM are stored in various places, for example:

* Multiple tests are stored in the [testbenches](https://github.com/SymbiFlow/sv-tests/tree/master/tests/testbenches) directory.
* Some UVM tests are stored in the chapters directories, mostly chapter-16 and chapter-18.
* There is a test generator for [EasyUVM](https://github.com/SymbiFlow/sv-tests/blob/master/generators/easyUVM).
* There are multiple UVM tests that use the template generator (see the ``uvm*`` files in the [conf](https://github.com/SymbiFlow/sv-tests/blob/master/conf/generators/templates/) directory).
