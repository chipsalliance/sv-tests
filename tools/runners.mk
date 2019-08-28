INSTALL_DIR := $(abspath $(OUT_DIR)/runners/)

RDIR := third_party/tools
TDIR := tools

.PHONY: runners

runners:

# odin
odin: $(INSTALL_DIR)/bin/odin_II

$(INSTALL_DIR)/bin/odin_II:
	@mkdir -p $(OUT_DIR)/runners/bin
	@$(MAKE) -C $(RDIR)/odin_ii/ODIN_II/ build
	@cp $(RDIR)/odin_ii/ODIN_II/odin_II $(INSTALL_DIR)/bin/

# yosys
yosys: $(INSTALL_DIR)/bin/yosys

$(INSTALL_DIR)/bin/yosys:
	@mkdir -p $(OUT_DIR)/runners/bin
	@$(MAKE) -C $(RDIR)/yosys ENABLE_TCL=0 ENABLE_ABC=0 ENABLE_GLOB=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0
	@cp $(RDIR)/yosys/yosys $(INSTALL_DIR)/bin/

# icarus
icarus: $(INSTALL_DIR)/bin/iverilog

$(INSTALL_DIR)/bin/iverilog:
	@mkdir -p $(OUT_DIR)/runners/bin
	@cd $(RDIR)/icarus && autoconf
	@cd $(RDIR)/icarus && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	@$(MAKE) -C $(RDIR)/icarus
	@$(MAKE) -C $(RDIR)/icarus installdirs
	@$(MAKE) -C $(RDIR)/icarus install

# verilator
verilator: $(INSTALL_DIR)/bin/verilator

$(INSTALL_DIR)/bin/verilator:
	@mkdir -p $(OUT_DIR)/runners/bin
	@cd $(RDIR)/verilator && autoconf
	@cd $(RDIR)/verilator && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	@$(MAKE) -C $(RDIR)/verilator
	@$(MAKE) -C $(RDIR)/verilator install

# slang
slang: $(INSTALL_DIR)/bin/driver

$(INSTALL_DIR)/bin/driver:
	@mkdir -p $(OUT_DIR)/runners/bin
	@mkdir -p $(RDIR)/slang/build
	@cd $(RDIR)/slang/build && cmake .. -DSLANG_INCLUDE_TESTS=OFF && make -j13
	@cp $(RDIR)/slang/build/bin/* $(INSTALL_DIR)/bin/

# zachjs-sv2v
zachjs-sv2v: $(INSTALL_DIR)/bin/zachjs-sv2v

$(INSTALL_DIR)/bin/zachjs-sv2v:
	@mkdir -p $(OUT_DIR)/runners/bin
	@cd $(RDIR)/zachjs-sv2v && make
	@cp $(RDIR)/zachjs-sv2v/bin/sv2v $@

# tree-sitter-verilog
tree-sitter-verilog: $(INSTALL_DIR)/lib/verilog.so

$(INSTALL_DIR)/lib/verilog.so:
	@cd $(RDIR)/tree-sitter-verilog && npm install
	@/usr/bin/env python3 -c "from tree_sitter import Language; Language.build_library(\"$@\", [\"$(abspath $(RDIR)/tree-sitter-verilog)\"])"

# setup the dependencies
RUNNERS_TARGETS := odin yosys icarus verilator slang zachjs-sv2v tree-sitter-verilog
.PHONY: $(RUNNERS_TARGETS)
runners: $(RUNNERS_TARGETS)
