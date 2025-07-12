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
tree-sitter-systemverilog: tree-sitter-init
	cp -r $(RDIR)/tree-sitter-systemverilog $(HOME)/dev/
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(HOME)/dev/tree-sitter-systemverilog && tree-sitter generate)


tree-sitter-verilog: tree-sitter-init
	cp -r $(RDIR)/tree-sitter-verilog $(HOME)/dev/
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		cd $(RDIR)/tree-sitter-verilog && tree-sitter generate --abi 14)

tree-sitter-init: $(HOME)/.config/tree-sitter/config.json

$(HOME)/.config/tree-sitter/config.json: $(INSTALL_DIR)/bin/tree-sitter
	(export PATH=$(INSTALL_DIR)/bin/:${PATH} && \
		tree-sitter init-config)

$(INSTALL_DIR)/bin/tree-sitter:
	wget https://github.com/tree-sitter/tree-sitter/releases/download/v0.25.3/tree-sitter-linux-x64.gz
	gunzip tree-sitter-linux-x64.gz
	install -D tree-sitter-linux-x64 $@
	rm tree-sitter-linux-x64
	mkdir -p $(HOME)/dev/

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
	mkdir -p $(RDIR)/circt-verilog/build && \
	mkdir -p $(RDIR)/circt-verilog/llvm/build && \
	cd $(RDIR)/circt-verilog/llvm/build && \
	cmake ../llvm \
	    -G Ninja \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DLLVM_USE_LINKER=lld \
	    -DLLVM_CCACHE_BUILD=ON \
	    -DCMAKE_C_COMPILER=clang \
	    -DCMAKE_CXX_COMPILER=clang++ \
	    -DLLVM_ENABLE_PROJECTS="mlir" \
	    -DLLVM_INSTALL_UTILS=ON \
	    -DLLVM_OPTIMIZED_TABLEGEN=ON \
	    -DLLVM_TARGETS_TO_BUILD="host" && \
	ninja && cd $(RDIR)/circt-verilog/build && \
	cmake .. \
	    -G Ninja \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DLLVM_USE_LINKER=lld \
	    -DCMAKE_C_COMPILER=clang \
	    -DCMAKE_CXX_COMPILER=clang++ \
	    -DMLIR_DIR=$(RDIR)/circt-verilog/llvm/build/lib/cmake/mlir \
	    -DLLVM_DIR=$(RDIR)/circt-verilog/llvm/build/lib/cmake/llvm \
	    -DCIRCT_SLANG_FRONTEND_ENABLED=ON \
	    -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) && \
	ninja && ninja install

# setup the dependencies
RUNNERS_TARGETS := odin yosys icarus verilator slang zachjs-sv2v tree-sitter-systemverilog tree-sitter-verilog sv-parser moore verible surelog yosys-synlig circt-verilog
.PHONY: $(RUNNERS_TARGETS)
runners: $(RUNNERS_TARGETS)
