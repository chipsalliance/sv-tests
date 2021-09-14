#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2021 The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

from selenium import webdriver
from selenium.webdriver.support.ui import Select
import sys

def setDriver(driver=None):
    if driver == None:
        return webdriver.Chrome()
    else:
        return driver

def openPage(URL):
    driver.get(URL)
    driver.implicitly_wait(10)
    driver.find_element_by_tag_name('button').click()

def addEntries(iter):
    for _ in range(iter):
        driver.find_element_by_class_name('filter-add').click()

def fillEntryType(num, type):
    entry_type = "//*[@class='filter-entry-type']"
    select = Select(driver.find_elements_by_xpath(entry_type)[num])
    select.select_by_value(type)

def fillSpan(num, operator, value, relation=None):
    entry_operator = "//*[@class='filter-entry-operator']"
    select = Select(driver.find_elements_by_xpath(entry_operator)[num])
    select.select_by_value(operator)
    entry_value = "//*[@class='filter-entry-value']"
    select = Select(driver.find_elements_by_xpath(entry_value)[num])
    select.select_by_value(value)
    if relation != None:
        entry_relation = "//*[@class='filter-condition']"
        select = Select(driver.find_elements_by_xpath(entry_relation)[num])
        select.select_by_value(relation)

def applyFilters():
    driver.find_element_by_class_name('filter-apply').click()

def removeIcon(num):
    driver.find_elements_by_class_name('filter-clear')[num].click()

def removeAll():
    driver.find_element_by_class_name('filter-remove').click()


if __name__ == "__main__":
    URL = sys.argv[1]
    driver = setDriver(webdriver.Chrome())
    openPage(URL)

    addEntries(3)
    fillEntryType(0, "coverage")
    fillEntryType(1, "type")
    fillEntryType(2, "tool")
    fillSpan(0, ">", "50", "or")
    fillSpan(1, "<", "80")
    fillSpan(2, "is", "preprocessing")
    fillSpan(3, "is", "yosyssv", "and")
    fillSpan(4, "is", "surelog")
    applyFilters()
    removeIcon(2)
    removeAll()
