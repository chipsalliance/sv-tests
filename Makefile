all: tests

OUT_DIR=./out/
TESTS_DIR=./tests
RUNNERS_DIR=./runners

clean:
	@echo removing $(OUT_DIR)
	@rm -rf $(OUT_DIR)

init:
	@mkdir -p $(addprefix $(OUT_DIR), $(RUNNERS))

# $(1) - runner name
# $(2) - test
define runner_gen

$(1)_$(2): info init
	@echo Testing $(2) with $(1)

	@echo "TESTS: [TODO: MAKE THIS A LIST OF VERIFIED TAGS]" > $(OUT_DIR)/$(1)/$(2).log
	@$(RUNNERS_DIR)/$(1) $(2) >> $(OUT_DIR)/$(1)/$(2).log 2>&1

tests: $(1)_$(2)
endef

RUNNERS := $(wildcard $(RUNNERS_DIR)/*)
RUNNERS := $(RUNNERS:$(RUNNERS_DIR)/%=%)
TESTS := $(wildcard $(TESTS_DIR)/*.sv)
TESTS := $(TESTS:$(TESTS_DIR)/%=%)

info:
	@echo "Found the following runners: $(RUNNERS)"
	@echo "Found the following tests: $(TESTS)"

tests:

$(foreach r, $(RUNNERS),$(foreach t, $(TESTS),$(eval $(call runner_gen,$(r),$(t)))))
