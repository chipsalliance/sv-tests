all: report

OUT_DIR=./out/
CONF_DIR=./conf
TESTS_DIR=./tests
RUNNERS_DIR=./tools/runners
THIRD_PARTY_DIR=./third_party
GENERATORS_DIR=./generators

export OUT_DIR
export CONF_DIR
export THIRD_PARTY_DIR
export TESTS_DIR
export RUNNERS_DIR
export GENERATORS_DIR

USE_ALL_RUNNERS?=0

include tools/runners.mk

.PHONY: clean init info tests generate-tests report

clean:
	rm -rf $(OUT_DIR)
	rm -rf $(TESTS_DIR)/generated/

init:
ifneq (,$(wildcard $(OUT_DIR)/*))
	@echo -e "!!! WARNING !!!\nThe output directory is not empty\n"
endif

runners:

# $(1) - runner name
# $(2) - test
define runner_gen
$(OUT_DIR)/logs/$(1)/$(2).log: $(TESTS_DIR)/$(2)
	./tools/runner --runner $(1) --test $(2) --out $(OUT_DIR)/logs/$(1)/$(2).log --quiet

tests: $(OUT_DIR)/logs/$(1)/$(2).log
endef

define generator_gen
generate-$(1):
	@$(GENERATORS_DIR)/$(1) $(1)

generate-tests: generate-$(1)
endef

RUNNERS_FOUND := $(wildcard $(RUNNERS_DIR)/*.py)
RUNNERS_FOUND := $(RUNNERS_FOUND:$(RUNNERS_DIR)/%=%)
RUNNERS_FOUND := $(basename $(RUNNERS_FOUND))
RUNNERS := $(shell OUT_DIR=$(OUT_DIR) ./tools/check-runners $(RUNNERS_FOUND))
TESTS := $(shell find $(TESTS_DIR) -type f -iname *.sv)
TESTS := $(TESTS:$(TESTS_DIR)/%=%)
GENERATORS := $(wildcard $(GENERATORS_DIR)/*)
GENERATORS := $(GENERATORS:$(GENERATORS_DIR)/%=%)

space := $(subst ,, )

info:
ifneq ($(USE_ALL_RUNNERS), 0)
ifneq ($(RUNNERS), $(RUNNERS_FOUND))
	$(error Some runners are missing)
endif
endif
	@echo -e "Found the following runners:$(subst $(space),"\\n \* ", $(RUNNERS))\n"
	@echo -e "Found the following tests:$(subst $(space),"\\n \* ", $(TESTS))\n"

tests:

generate-tests:

report: init info tests
	./tools/sv-report
	cp ./conf/report/report.* ./out/.

$(foreach g, $(GENERATORS), $(eval $(call generator_gen,$(g))))
$(foreach r, $(RUNNERS),$(foreach t, $(TESTS),$(eval $(call runner_gen,$(r),$(t)))))
