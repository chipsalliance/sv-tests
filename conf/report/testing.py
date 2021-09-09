from selenium import webdriver
from selenium.webdriver.support.ui import Select
import sys

def setDriver(driver_location, driver=None):
    if driver == None:
        return webdriver.Chrome(driver_location)
    elif driver == 'chrome':
        return webdriver.Chrome(driver_location)
    elif driver == 'edge':
        return webdriver.Edge(driver_location)
    elif driver == 'firefox':
        return webdriver.Firefox(driver_location)
    elif driver == 'ie':
        return webdriver.Ie(driver_location)
    elif driver == 'opera':
        return webdriver.Opera(driver_location)
    elif driver == 'phantomjs':
        return webdriver.PhantomJS(driver_location)
    elif driver == 'safari':
        return webdriver.Safari(driver_location)

def openPage(URL):
    driver.get(URL)

def addEntries(iter):
    for _ in range(iter):
        driver.find_element_by_class_name('filter-add').click()

def fillEntry(num, type, operator, value):
    entry_type = "//*[@class='filter-entry-type']"
    select = Select(driver.find_elements_by_xpath(entry_type)[num])
    select.select_by_value(type)
    entry_operator = "//*[@class='filter-entry-operator']"
    select = Select(driver.find_elements_by_xpath(entry_operator)[num])
    select.select_by_value(operator)
    entry_value = "//*[@class='filter-entry-value']"
    select = Select(driver.find_elements_by_xpath(entry_value)[num])
    select.select_by_value(value)

def addGlobalOp(operator):
    operator_type = "//*[@class='global-relation']"
    select = Select(driver.find_element_by_xpath(operator_type))
    select.select_by_value(operator)

def applyFilters():
    driver.find_element_by_class_name('filter-apply').click()

def removeIcon(num):
    driver.find_elements_by_class_name('filter-clear')[num].click()

def removeAll():
    driver.find_element_by_class_name('filter-remove').click()


if __name__ == "__main__":
    try:
        URL = sys.argv[1]
    except:
        URL = "D:/Outreachy/local-cp/sv-tests/out/report/index.html"

    driver = setDriver("D:/Downloads/chromedriver_latest/chromedriver.exe")
    openPage(URL)

    driver.implicitly_wait(10)
    driver.find_element_by_tag_name('details').click()
    addEntries(3)
    fillEntry(0, "coverage", "=", "50")
    fillEntry(1, "type", "is", "preprocessing")
    fillEntry(2, "tool", "is not", "icarus")
    addGlobalOp("and")
    applyFilters()
    removeIcon(2)
    removeAll()