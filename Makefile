# Copyright (C) 2020 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

all: report

OUT_DIR ?= ./out/
CONF_DIR ?= ./conf
TESTS_DIR ?= ./tests
BUILD_DIR ?= ./build
RUNNERS_DIR ?= ./tools/runners
THIRD_PARTY_DIR ?= ./third_party
GENERATORS_DIR ?= ./generators

USE_CGROUP := ${USE_CGROUP}
CGROUP_MAX_MEMORY ?= 3221225472  # 3GiB

export OUT_DIR
export CONF_DIR
export THIRD_PARTY_DIR
export TESTS_DIR
export RUNNERS_DIR
export GENERATORS_DIR

ifneq ($(DISABLE_TEST_TIMEOUTS),)
export DISABLE_TEST_TIMEOUTS
endif

ifneq ($(OVERRIDE_TEST_TIMEOUTS),)
export OVERRIDE_TEST_TIMEOUTS
endif

include tools/runners.mk

.PHONY: clean init info tests generate-tests report

clean:
	rm -rf $(OUT_DIR)
	rm -rf $(BUILD_DIR)
	rm -rf $(TESTS_DIR)/generated/

init:
ifneq (,$(wildcard $(OUT_DIR)/*))
	@echo -e "!!! WARNING !!!\nThe output directory is not empty\n"
endif

runners:

ifneq ($(RUNNER_KEEP_TMP),)
RUNNER_PARAM := --keep-tmp
else
RUNNER_PARAM := --quiet
endif

# $(1) - runner name
# $(2) - test
define runner_test_gen

# Set the runner value for the log target
ifneq ($(USE_CGROUP),)
$(OUT_DIR)/logs/$(1)/$(2).log : RUNNER = cgexec -g memory,cpu:$(USE_CGROUP)/$(1) ./tools/runner
else
$(OUT_DIR)/logs/$(1)/$(2).log : RUNNER = ./tools/runner
endif

$(OUT_DIR)/logs/$(1)/$(2).log: $(TESTS_DIR)/$(2) | $(1)-cg
	RUNNERS_DIR=$(RUNNERS_DIR) $$(RUNNER) --runner $(1) --test $(2) --out $(OUT_DIR)/logs/$(1)/$(2).log $(RUNNER_PARAM)

tests: $(OUT_DIR)/logs/$(1)/$(2).log

endef

# $(1) - runner name
define runner_cg_gen
ifneq ($(USE_CGROUP),)

/sys/fs/cgroup/memory/$(USE_CGROUP)/$(1):
	# Create a sub-cgroup for each runner under the $(USE_CGROUP) group.
	cgcreate -g memory,cpu:$(USE_CGROUP)/$(1)

$(1)-cg: /sys/fs/cgroup/memory/$(USE_CGROUP)/$(1)
	# Limit a single runner memory
	echo $(CGROUP_MAX_MEMORY) > /sys/fs/cgroup/memory/$(USE_CGROUP)/$(1)/memory.limit_in_bytes

else
$(1)-cg:
	@true
endif

endef

define runner_version_gen
$(OUT_DIR)/logs/$(1)/version:
	./tools/runner --runner $(1) --version --out $(OUT_DIR)/logs/$(1)/version

versions: $(OUT_DIR)/logs/$(1)/version
endef

define runner_url_gen
$(OUT_DIR)/logs/$(1)/url:
	./tools/runner --runner $(1) --url --out $(OUT_DIR)/logs/$(1)/url

urls: $(OUT_DIR)/logs/$(1)/url
endef

define generator_gen
generate-$(1):
	$(GENERATORS_DIR)/$(1) $(1)

generate-tests: generate-$(1)
endef

RUNNERS_FOUND := $(wildcard $(RUNNERS_DIR)/*.py)
RUNNERS_FOUND := $(RUNNERS_FOUND:$(RUNNERS_DIR)/%=%)
RUNNERS_FOUND := $(sort $(basename $(RUNNERS_FOUND)))

ifdef RUNNERS_FILTER
FILTER := --filter $(RUNNERS_FILTER)
endif

RUNNERS := $(sort $(shell OUT_DIR=$(OUT_DIR) RUNNERS_DIR=$(RUNNERS_DIR) \
                          TREE_SITTER_SVERILOG_PARSER_DIR=$(TREE_SITTER_SVERILOG_PARSER_DIR) \
                          TREE_SITTER_VERILOG_PARSER_DIR=$(TREE_SITTER_VERILOG_PARSER_DIR) \
			  ./tools/check-runners $(RUNNERS_FOUND) $(FILTER)))
TESTS := $(shell find $(TESTS_DIR) -type f -iname *.sv)
TESTS := $(TESTS:$(TESTS_DIR)/%=%)
GENERATORS := $(wildcard $(GENERATORS_DIR)/*)
GENERATORS := $(GENERATORS:$(GENERATORS_DIR)/%=%)

space := $(subst ,, )

ifneq ($(USE_ALL_RUNNERS),)
ifneq ($(RUNNERS), $(RUNNERS_FOUND))
$(warning Runners found: $(RUNNERS_FOUND))
$(warning Runners defined: $(RUNNERS))
$(error Some runners are missing)
endif
endif

info:
	@echo -e "Found the following runners:$(subst $(space),"\\n \* ", $(RUNNERS))\n"

PY_FILES := $(shell file generators/* tools/* | sed -ne 's/:.*[Pp]ython.*//p')
PY_FILES += $(wildcard tools/*.py)
PY_FILES += $(wildcard tools/runners/*.py)
PY_FILES += $(wildcard conf/report/*.py)

format:
	python3 -m yapf -p -i $(PY_FILES)

tests:

generate-tests:

urls:

versions:

report: init tests versions urls
	./tools/sv-report --revision $(shell git rev-parse --short HEAD)
	cp $(CONF_DIR)/report/*.css $(OUT_DIR)/report/
	cp $(CONF_DIR)/report/*.js $(OUT_DIR)/report/
	cp $(CONF_DIR)/report/*.png $(OUT_DIR)/report/
	cp $(CONF_DIR)/report/*.svg $(OUT_DIR)/report/

list-generators:
	@echo $(GENERATORS)

$(foreach g, $(GENERATORS), $(eval $(call generator_gen,$(g))))
$(foreach r, $(RUNNERS),$(foreach t, $(TESTS),$(eval $(call runner_test_gen,$(r),$(t)))))
$(foreach r, $(RUNNERS),$(eval $(call runner_cg_gen,$(r))))
$(foreach r, $(RUNNERS),$(eval $(call runner_version_gen,$(r))))
$(foreach r, $(RUNNERS),$(eval $(call runner_url_gen,$(r))))
