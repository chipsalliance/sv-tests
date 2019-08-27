all: report

OUT_DIR=./out/
TESTS_DIR=./tests
RUNNERS_DIR=./runners

export OUT_DIR
export TESTS_DIR
export RUNNERS_DIR

include tools/runners.mk

clean:
	@echo -e "Removing $(OUT_DIR)"
	@rm -rf $(OUT_DIR)

init:
ifneq (,$(wildcard $(OUT_DIR)/*))
	@echo -e "!!! WARNING !!!\nThe output directory is not empty\n"
endif
	@mkdir -p $(OUT_DIR)/runners/bin

runners: init

# $(1) - runner name
# $(2) - test
define runner_gen
$(1)_$(2): info init runners
	@mkdir -p $(OUT_DIR)/logs/$(1)/$(dir $(2))
	@./tools/runner --runner $(1) --test $(2)

tests: $(1)_$(2)
endef

RUNNERS := $(wildcard $(RUNNERS_DIR)/*)
RUNNERS := $(RUNNERS:$(RUNNERS_DIR)/%=%)
TESTS := $(shell find $(TESTS_DIR)/ -type f -iname *.sv)
TESTS := $(TESTS:$(TESTS_DIR)/%=%)

space := $(subst ,, )

info:
	@echo -e "Found the following runners:$(subst $(space),"\\n \* ", $(RUNNERS))\n"
	@echo -e "Found the following tests:$(subst $(space),"\\n \* ", $(TESTS))\n"

tests:

report: init tests
	@echo -e "\nGenerating report"
	@./tools/sv-report
	@echo -e "\nDONE!"

$(foreach r, $(RUNNERS),$(foreach t, $(TESTS),$(eval $(call runner_gen,$(r),$(t)))))
