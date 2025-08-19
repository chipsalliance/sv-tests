# Copyright (C) 2020 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

INSTALL_DIR := $(abspath $(OUT_DIR)/runners/)

RDIR := $(abspath third_party/tools)
TDIR := $(abspath tools)
CDIR := $(abspath conf)

TREE_SITTER_SVERILOG_PARSER_DIR := $(abspath $(OUT_DIR)/tmp/tree-sitter-systemverilog/parser)
TREE_SITTER_VERILOG_PARSER_DIR := $(abspath $(OUT_DIR)/tmp/tree-sitter-verilog/parser)

export TREE_SITTER_SVERILOG_PARSER_DIR
export TREE_SITTER_VERILOG_PARSER_DIR

.PHONY: runners

runners:

# odin
odin: $(INSTALL_DIR)/bin/odin_II

$(INSTALL_DIR)/bin/odin_II:
	$(MAKE) -C $(RDIR)/odin_ii/ODIN_II/ build
	install -D $(RDIR)/odin_ii/ODIN_II/odin_II $@

# yosys
yosys: $(INSTALL_DIR)/bin/yosys

$(INSTALL_DIR)/bin/yosys:
	$(MAKE) -C $(RDIR)/yosys CONFIG=gcc PREFIX=$(INSTALL_DIR) install

# icarus
icarus: $(INSTALL_DIR)/bin/iverilog

$(INSTALL_DIR)/bin/iverilog:
	cd $(RDIR)/icarus && autoconf
	cd $(RDIR)/icarus && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	$(MAKE) -C $(RDIR)/icarus
	$(MAKE) -C $(RDIR)/icarus installdirs
	$(MAKE) -C $(RDIR)/icarus install

# verilator
verilator: $(INSTALL_DIR)/bin/verilator

$(INSTALL_DIR)/bin/verilator:
	cd $(RDIR)/verilator && autoconf
	cd $(RDIR)/verilator && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	$(MAKE) -C $(RDIR)/verilator
	$(MAKE) -C $(RDIR)/verilator install

# slang
slang: $(INSTALL_DIR)/bin/slang-driver

$(INSTALL_DIR)/bin/slang-driver:
	mkdir -p $(RDIR)/slang/build
	cd $(RDIR)/slang/build && cmake .. -DSLANG_INCLUDE_TESTS=OFF -DCMAKE_BUILD_TYPE=Release
	$(MAKE) -C $(RDIR)/slang/build
	install -D $(RDIR)/slang/build/bin/slang $@

# Surelog
surelog: $(INSTALL_DIR)/bin/surelog

$(INSTALL_DIR)/bin/surelog:
	cd $(RDIR)/Surelog ; mkdir -p build/tests dist
	cd $(RDIR)/Surelog/build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) ../
	$(MAKE) -C $(RDIR)/Surelog/build install

# zachjs-sv2v
zachjs-sv2v: $(INSTALL_DIR)/bin/zachjs-sv2v

$(INSTALL_DIR)/bin/zachjs-sv2v:
	$(MAKE) -C $(RDIR)/zachjs-sv2v
	install -D $(RDIR)/zachjs-sv2v/bin/sv2v $@

# tree-sitter-verilog & tree-sitter-systemverilog
tree-sitter-systemverilog: $(INSTALL_DIR)/bin/tree-sitter
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(RDIR)/tree-sitter-systemverilog && tree-sitter generate)
	mkdir -p $(abspath $(OUT_DIR)/tmp/tree-sitter-systemverilog)
	mv $(RDIR)/tree-sitter-systemverilog/src $(TREE_SITTER_SVERILOG_PARSER_DIR)

tree-sitter-verilog: $(INSTALL_DIR)/bin/tree-sitter
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(RDIR)/tree-sitter-verilog && tree-sitter generate)
	mkdir -p $(abspath $(OUT_DIR)/tmp/tree-sitter-verilog)
	mv $(RDIR)/tree-sitter-verilog/src $(TREE_SITTER_VERILOG_PARSER_DIR)

$(INSTALL_DIR)/bin/tree-sitter:
	wget https://github.com/tree-sitter/tree-sitter/releases/download/v0.25.3/tree-sitter-linux-x64.gz
	gunzip tree-sitter-linux-x64.gz
	install -D tree-sitter-linux-x64 $@
	rm tree-sitter-linux-x64

# yosys-synlig
yosys-synlig: $(INSTALL_DIR)/bin/yosys-synlig

$(INSTALL_DIR)/bin/yosys-synlig:
	mkdir -p $(INSTALL_DIR)
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(RDIR)/synlig && \
		$(MAKE) -rR -Oline install CFG_OUT_DIR=$(INSTALL_DIR)/)
	mv $(INSTALL_DIR)/bin/yosys $(INSTALL_DIR)/bin/yosys-synlig

# sv-parser
sv-parser: $(INSTALL_DIR)/bin/parse_sv

$(INSTALL_DIR)/bin/parse_sv:
	cd $(RDIR)/sv-parser && cargo build --release --example parse_sv
	install -D $(RDIR)/sv-parser/target/release/examples/parse_sv $@

# moore
moore: $(INSTALL_DIR)/bin/moore

$(INSTALL_DIR)/bin/moore: $(RDIR)/moore/Cargo.lock
	(export CARGO_NET_GIT_FETCH_WITH_CLI=true && \
        cargo install --locked --path $(RDIR)/moore --root $(INSTALL_DIR) --bin moore)

$(RDIR)/moore/Cargo.lock: $(CDIR)/runners/Cargo.lock
	cp -f $(CDIR)/runners/Cargo.lock $(RDIR)/moore/Cargo.lock

# verible
verible:
	cd $(RDIR)/verible/ && bazel build :install-binaries --noshow_progress --//bazel:use_local_flex_bison -c opt
	cd $(RDIR)/verible/ && .github/bin/simple-install.sh $(INSTALL_DIR)/bin
	cd $(RDIR)/verible/ && bazel shutdown

$(INSTALL_DIR)/bin/verible-verilog-kythe-extractor: verible

$(INSTALL_DIR)/bin/verilog_syntax: verible

# yosys-slang
yosys-slang: $(INSTALL_DIR)/bin/yosys-slang

$(INSTALL_DIR)/bin/slang-yosys $(INSTALL_DIR)/bin/slang-yosys-config:
	$(MAKE) -C $(RDIR)/yosys CONFIG=gcc CXXSTD=c++20 ENABLE_ABC=0 \
				PROGRAM_PREFIX=slang- PREFIX=$(INSTALL_DIR) install

$(INSTALL_DIR)/bin/yosys-slang: $(INSTALL_DIR)/bin/slang-yosys-config
	mkdir -p $(INSTALL_DIR)
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(RDIR)/yosys-slang && \
		TARGET=$(INSTALL_DIR)/share/slang-yosys/plugins/slang.so YOSYS_PREFIX=slang- ./build.sh)
	# copy slang-yosys, which was the result of compiling yosys with PROGRAM_PREFIX=slang-,
	# to yosys-slang, which is the executable registered in tools/runners/yosys_slang.py
	cp $(INSTALL_DIR)/bin/slang-yosys $(INSTALL_DIR)/bin/yosys-slang

# circt-verilog
circt-verilog: $(INSTALL_DIR)/bin/circt-verilog

$(INSTALL_DIR)/bin/circt-verilog:
	cd $(RDIR)/circt-verilog && cmake llvm/llvm -B build \
		-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) \
		-DCMAKE_BUILD_TYPE=Release \
		-DLLVM_TARGETS_TO_BUILD=host \
		-DLLVM_ENABLE_PROJECTS=mlir \
		-DLLVM_EXTERNAL_PROJECTS=circt \
		-DLLVM_EXTERNAL_CIRCT_SOURCE_DIR=$(RDIR)/circt-verilog \
		-DCIRCT_SLANG_FRONTEND_ENABLED=ON
	$(MAKE) -C $(RDIR)/circt-verilog/build install-circt-verilog

# setup the dependencies
RUNNERS_TARGETS := odin yosys icarus verilator slang zachjs-sv2v tree-sitter-systemverilog tree-sitter-verilog sv-parser moore verible surelog yosys-synlig circt-verilog
.PHONY: $(RUNNERS_TARGETS)
runners: $(RUNNERS_TARGETS)
