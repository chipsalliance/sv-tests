INSTALL_DIR := $(abspath $(OUT_DIR)/runners/)

RDIR := tools

.PHONY: runners

runners:

# odin
odin: $(INSTALL_DIR)/bin/odin_II

$(INSTALL_DIR)/bin/odin_II: init
	@$(MAKE) -C $(RDIR)/odin_ii/ODIN_II/ build
	@cp $(RDIR)/odin_ii/ODIN_II/odin_II $(INSTALL_DIR)/bin/

# yosys
yosys: $(install_dir)/bin/yosys

$(install_dir)/bin/yosys: init
	@$(MAKE) -C $(RDIR)/yosys ENABLE_TCL=0 ENABLE_ABC=0 ENABLE_GLOB=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0
	@cp $(RDIR)/yosys/yosys $(INSTALL_DIR)/bin/

# icarus
icarus: $(INSTALL_DIR)/bin/iverilog

$(INSTALL_DIR)/bin/iverilog: init
	@cd $(RDIR)/icarus && autoconf
	@cd $(RDIR)/icarus && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	@$(MAKE) -C $(RDIR)/icarus
	@$(MAKE) -C $(RDIR)/icarus installdirs
	@$(MAKE) -C $(RDIR)/icarus install

# verilator
verilator: $(INSTALL_DIR)/bin/verilator

$(INSTALL_DIR)/bin/verilator: init
	@cd $(RDIR)/verilator && autoconf
	@cd $(RDIR)/verilator && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	@$(MAKE) -C $(RDIR)/verilator
	@$(MAKE) -C $(RDIR)/verilator install

# slang
slang: $(INSTALL_DIR)/bin/driver

$(INSTALL_DIR)/bin/driver: init
	@mkdir -p $(RDIR)/slang/build
	@cd $(RDIR)/slang/build && cmake .. -DSLANG_INCLUDE_TESTS=OFF && make -j13
	@cp $(RDIR)/slang/build/bin/* $(INSTALL_DIR)/bin/

# setup the dependencies
runners: $(addprefix $(INSTALL_DIR)/bin/,odin_II yosys iverilog verilator driver)
