all: report

OUT_DIR=./out/
TESTS_DIR=./tests
RUNNERS_DIR=./runners

clean:
	@echo -e "Removing $(OUT_DIR)"
	@rm -rf $(OUT_DIR)

init:
ifneq (,$(wildcard $(OUT_DIR)/*))
	@echo -e "!!! WARNING !!!\nThe output directory is not empty\n"
endif
	@mkdir -p $(addprefix $(OUT_DIR), $(RUNNERS))

define parse_param
	$(eval $(1):=$(shell grep -m 1 :$1: $2 | cut -d' ' -f2-))
endef

# $(1) - runner name
# $(2) - test
define runner_gen

$(1)_$(2): info init
	$(call parse_param,name,$(TESTS_DIR)/$(2))
	$(call parse_param,should_fail,$(TESTS_DIR)/$(2))
	$(call parse_param,tags,$(TESTS_DIR)/$(2))
	@echo "NAME: $(name)" > $(OUT_DIR)/$(1)/$(2).log
	@echo "TAGS: $(tags)" >> $(OUT_DIR)/$(1)/$(2).log
	@echo "SHOULD_FAIL: $(should_fail)" >> $(OUT_DIR)/$(1)/$(2).log
	$(eval TMPDIR:=$(shell mktemp -d))
	$(eval RUNNER_PATH:=$(abspath $(RUNNERS_DIR)/$(1)))
	$(eval TEST_PATH:=$(abspath $(TESTS_DIR)/$(2)))
	$(eval RC:=$(shell cd $(TMPDIR) && $(RUNNER_PATH) $(TEST_PATH) >> $(1).log 2>&1; echo $$?))
	@echo "RC: $(RC)" >> $(OUT_DIR)/$(1)/$(2).log
	@cat $(TMPDIR)/$(1).log >> $(OUT_DIR)/$(1)/$(2).log
	@if [[ $(should_fail) == "0" && $(RC) == "0" ]] || [[ $(should_fail) == "1" && $(RC) != "0" ]]; then \
		echo -e "Testing $(2) with $(1):\tPASS"; \
	else \
		echo -e "Testing $(2) with $(1):\tFAIL"; \
	fi
	@rm -r $(TMPDIR)

tests: $(1)_$(2)
endef

RUNNERS := $(wildcard $(RUNNERS_DIR)/*)
RUNNERS := $(RUNNERS:$(RUNNERS_DIR)/%=%)
TESTS := $(wildcard $(TESTS_DIR)/*.sv)
TESTS := $(TESTS:$(TESTS_DIR)/%=%)

space := $(subst ,, )

info:
	@echo -e "Found the following runners:$(subst $(space),"\\n \* ", $(RUNNERS))\n"
	@echo -e "Found the following tests:$(subst $(space),"\\n \* ", $(TESTS))\n"

tests:

report: init tests
	@echo -e "\nGenerating report"
	@./tools/sv-report --quiet
	@echo -e "\nDONE!"

$(foreach r, $(RUNNERS),$(foreach t, $(TESTS),$(eval $(call runner_gen,$(r),$(t)))))
