INSTALL_DIR := $(abspath $(OUT_DIR)/runners/)

RDIR := tools

.PHONY: runners

runners:

# odin
$(INSTALL_DIR)/bin/odin_II:
	@$(MAKE) -C $(RDIR)/odin_ii/ODIN_II/ build
	@cp $(RDIR)/odin_ii/ODIN_II/odin_II $(INSTALL_DIR)/bin/

# yosys
$(INSTALL_DIR)/bin/yosys:
	@$(MAKE) -C $(RDIR)/yosys ENABLE_TCL=0 ENABLE_ABC=0 ENABLE_GLOB=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0
	@cp $(RDIR)/yosys/yosys $(INSTALL_DIR)/bin/

# icarus
$(INSTALL_DIR)/bin/iverilog:
	@cd $(RDIR)/icarus && autoconf
	@cd $(RDIR)/icarus && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	@$(MAKE) -C $(RDIR)/icarus
	@$(MAKE) -C $(RDIR)/icarus installdirs
	@$(MAKE) -C $(RDIR)/icarus install

# verilator
$(INSTALL_DIR)/bin/verilator:
	@cd $(RDIR)/verilator && autoconf
	@cd $(RDIR)/verilator && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	@$(MAKE) -C $(RDIR)/verilator
	@$(MAKE) -C $(RDIR)/verilator install

# slang
$(INSTALL_DIR)/bin/driver:
	@mkdir -p $(RDIR)/slang/build
	@cd $(RDIR)/slang/build && cmake .. && make -j13
	@cp $(RDIR)/slang/build/bin/* $(INSTALL_DIR)/bin/

# setup the dependencies
runners: $(addprefix $(INSTALL_DIR)/bin/,odin_II yosys iverilog verilator driver)
