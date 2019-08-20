all: report

OUT_DIR=./out/
TESTS_DIR=./tests
RUNNERS_DIR=./runners

export OUT_DIR
export TESTS_DIR
export RUNNERS_DIR

clean:
	@echo -e "Removing $(OUT_DIR)"
	@rm -rf $(OUT_DIR)

init:
ifneq (,$(wildcard $(OUT_DIR)/*))
	@echo -e "!!! WARNING !!!\nThe output directory is not empty\n"
endif
	@mkdir -p $(addprefix $(OUT_DIR), $(RUNNERS))

# $(1) - runner name
# $(2) - test
define runner_gen
$(1)_$(2): info init
	@./tools/runner --runner $(1) --test $(2)

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
