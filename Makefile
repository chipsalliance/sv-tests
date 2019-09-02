all: report

OUT_DIR=./out/
CONF_DIR=./conf
TESTS_DIR=./tests
RUNNERS_DIR=./runners
GENERATORS_DIR=./generators

export OUT_DIR
export CONF_DIR
export TESTS_DIR
export RUNNERS_DIR
export GENERATORS_DIR

include tools/runners.mk

clean:
	@echo -e "Removing $(OUT_DIR)"
	@rm -rf $(OUT_DIR)
	@echo -e "Removing $(TESTS_DIR)/generated/"
	@rm -rf $(TESTS_DIR)/generated/

init:
ifneq (,$(wildcard $(OUT_DIR)/*))
	@echo -e "!!! WARNING !!!\nThe output directory is not empty\n"
endif

runners:

# $(1) - runner name
# $(2) - test
define runner_gen
run-$(1)-$(2): info init
	@mkdir -p $(OUT_DIR)/logs/$(1)/$(dir $(2))
	@./tools/runner --runner $(1) --test $(2)

tests: run-$(1)-$(2)
endef

define generator_gen
generate-$(1):
	@mkdir -p $(TESTS_DIR)/generated/$(1)/
	@$(GENERATORS_DIR)/$(1) $(1)

generate-tests: generate-$(1)
endef

RUNNERS := $(wildcard $(RUNNERS_DIR)/*)
RUNNERS := $(RUNNERS:$(RUNNERS_DIR)/%=%)
TESTS := $(shell find $(TESTS_DIR)/ -type f -iname *.sv)
TESTS := $(TESTS:$(TESTS_DIR)/%=%)
GENERATORS := $(wildcard $(GENERATORS_DIR)/*)
GENERATORS := $(GENERATORS:$(GENERATORS_DIR)/%=%)

space := $(subst ,, )

info:
	@echo -e "Found the following runners:$(subst $(space),"\\n \* ", $(RUNNERS))\n"
	@echo -e "Found the following tests:$(subst $(space),"\\n \* ", $(TESTS))\n"

tests:

generate-tests:

report: init tests
	@echo -e "\nGenerating report"
	@./tools/sv-report
	@echo -e "\nDONE!"

$(foreach g, $(GENERATORS), $(eval $(call generator_gen,$(g))))
$(foreach r, $(RUNNERS),$(foreach t, $(TESTS),$(eval $(call runner_gen,$(r),$(t)))))
