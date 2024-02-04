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

.PHONY: runners

runners:

# odin
odin: $(INSTALL_DIR)/bin/odin_II

$(INSTALL_DIR)/bin/odin_II:
	$(MAKE) -C $(RDIR)/odin_ii/ODIN_II/ build
	install -D $(RDIR)/odin_ii/ODIN_II/odin_II $@

# yosys
yosys: $(INSTALL_DIR)/bin/yosys

$(INSTALL_DIR)/bin/yosys $(INSTALL_DIR)/bin/yosys-config:
	$(MAKE) -C $(RDIR)/yosys CONFIG=gcc PREFIX=$(INSTALL_DIR) install

# yosys-slang
yosys-slang: $(INSTALL_DIR)/bin/yosys-slang

$(INSTALL_DIR)/bin/yosys-slang: $(INSTALL_DIR)/bin/yosys-config
	mkdir -p $(INSTALL_DIR)
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(RDIR)/yosys-slang && \
		cmake -S slang -B build/slang -DCMAKE_INSTALL_PREFIX=build/slang_install -DSLANG_USE_MIMALLOC=OFF && \
		make -C build/slang -j$(nproc) && \
		make -C build/slang install && \
		mkdir -p $(INSTALL_DIR)/share/yosys/plugins && \
		yosys-config --build $(INSTALL_DIR)/share/yosys/plugins/slang.so \
				slang_frontend.cc -Ibuild/slang_install/include -std=c++20 \
				-DSLANG_BOOST_SINGLE_HEADER -Lbuild/slang_install/lib \
				-lsvlang -lfmt)
	cp $(INSTALL_DIR)/bin/yosys $(INSTALL_DIR)/bin/yosys-slang

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

# tree-sitter-verilog
tree-sitter-verilog: $(INSTALL_DIR)/lib/tree-sitter-verilog.so

$(INSTALL_DIR)/lib/tree-sitter-verilog.so:
	mkdir -p $(INSTALL_DIR)/lib
	cd $(RDIR)/tree-sitter-verilog && npm install
	/usr/bin/env python3 -c "from tree_sitter import Language; Language.build_library(\"$@\", [\"$(abspath $(RDIR)/tree-sitter-verilog)\"])"

# surelog-uhdm-verilator
verilator-uhdm: $(INSTALL_DIR)/bin/verilator-uhdm

# cannot use 'make -C uhdm-integration <target> as uhdm relies on $PWD
$(INSTALL_DIR)/bin/verilator-uhdm:
	mkdir -p $(INSTALL_DIR)
	cd $(RDIR)/verilator-uhdm && ./build_binaries.sh
	cp -r $(RDIR)/verilator-uhdm/image/* $(INSTALL_DIR)
	mv $(INSTALL_DIR)/bin/verilator $(INSTALL_DIR)/bin/verilator-uhdm

# yosys-synlig
yosys-synlig: $(INSTALL_DIR)/bin/yosys-synlig

$(INSTALL_DIR)/bin/yosys-synlig:
	mkdir -p $(INSTALL_DIR)
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(RDIR)/synlig && \
		$(MAKE) -rR -Oline -f build_binaries.mk install-yosys install-plugin INSTALL_DIR=$(INSTALL_DIR))
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
	cd $(RDIR)/verible/ && bazel run :install --noshow_progress --//bazel:use_local_flex_bison -c opt -- $(INSTALL_DIR)/bin && bazel shutdown

$(INSTALL_DIR)/bin/verible-verilog-kythe-extractor: verible

$(INSTALL_DIR)/bin/verilog_syntax: verible

# setup the dependencies
RUNNERS_TARGETS := yosys-slang
.PHONY: $(RUNNERS_TARGETS)
runners: $(RUNNERS_TARGETS)
