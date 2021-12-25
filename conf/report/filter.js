// NOTE: Code here uses classes and functions from report.js

const HEADER_COLUMNS_COUNT = 2

/// Filter state manager ///////////////////////////////////////////////

const filter_state = new StateManager({
  hidden_column_ids: {
    initial: [],
    validator: (v) => Array.isArray(v),
  },
  row_filter_func: {
    initial: null,
    validator: (v) => (typeof v === "function" || v === null)
  },
  cell_filter_func: {
    initial: null,
    validator: (v) => (typeof v === "function" || v === null)
  },

  tool_filter: {
    initial: TOOL_NAMES.map((v) => v.toLowerCase()).sort(),
    validator: (v) => (Array.isArray(v) && v.every((v) => is_string(v))),
  },
  applied_tool_filter: {
    initial: TOOL_NAMES.map((v) => v.toLowerCase()).sort(),
    validator: (v) => (Array.isArray(v) && v.every((v) => is_string(v))),
  },

  coverage_filter: {
    initial: [">=", 0],
    validator: (v) => Array.isArray(v),
  },
  applied_coverage_filter: {
    initial: [">=", 0],
    validator: (v) => Array.isArray(v),
  },

  type_filter: {
    initial: ["elaboration", "parsing", "simulation"],
    validator: (v) => (Array.isArray(v) && v.every((v) => is_string(v))),
  },
  applied_type_filter: {
    initial: ["elaboration", "parsing", "simulation"],
    validator: (v) => (Array.isArray(v) && v.every((v) => is_string(v))),
  },
})

/// EntriesListController //////////////////////////////////////////////

class CoverageFilterEntriesController {
  constructor(state_manager, element) {
    this._state = state_manager

    this._top = element
    this._first_entry = this._top.querySelector(".p_entry")
    this._first_operator = this._first_entry.querySelector(".p_entry-operator")
    this._first_value = this._first_entry.querySelector(".p_entry-value");

    [this._first_operator, this._first_value].forEach((element) => {
      element.addEventListener("change", this._update_state.bind(this))
    })

    this._entry_template = this._top.querySelector(".p_entry-template")
    this._add_button = this._top.querySelector(".p_add-entry-button")

    this._add_button.onclick = this._add_entry_button_clicked.bind(this)

    this._state.subscribe(
        ["coverage_filter"],
        StateManager.debounce(this._state_changed.bind(this)))

    this._update_state_handle = null
  }

  static _select_option(select_element, option_value) {
    let i = 0
    for (const child of select_element.options) {
      if (child.value === option_value) {
        select_element.selectedIndex = i
        return
      }
      ++i
    }
    select_element.selectedIndex = -1
  }

  _state_changed(state, changed_values) {
    let entries = [...this._top.querySelectorAll(".p_entry.v_removable")]
    const values = state.coverage_filter
    const expected_removable_entries_count = (values.length - 2) / 3

    if (entries.length > expected_removable_entries_count) {
      for (let i = expected_removable_entries_count; i < entries.length; ++i) {
        entries[i].remove()
      }
      entries.splice(expected_removable_entries_count)
    } else if (entries.length < expected_removable_entries_count) {
      let last_entry = entries.length > 0 ? entries[entries.lenght-1] : this._first_entry
      for (let i = entries.length; i < expected_removable_entries_count; ++i) {
        const new_entry = this._create_entry()
        last_entry.after(new_entry)
        entries.push(new_entry)
        last_entry = new_entry
      }
    }

    CoverageFilterEntriesController._select_option(this._first_operator, values[0])
    this._first_value.value = values[1]

    let i = 2
    for (const entry of entries) {
      CoverageFilterEntriesController._select_option(entry.querySelector(".p_entry-relation"), values[i+0])
      CoverageFilterEntriesController._select_option(entry.querySelector(".p_entry-operator"), values[i+1])
      entry.querySelector(".p_entry-value").value = values[i + 2]
      i += 3
    }
  }

  _add_entry_button_clicked(event) {
    const entries = this._top.querySelectorAll(".p_entry")
    const last_entry = entries[entries.length - 1]
    const new_entry = this._create_entry()
    last_entry.after(new_entry)
    new_entry.querySelector("select, input, button").focus()
    this._update_state()
  }

  _update_state() {
    if (this._update_state_handle !== null)
      clearTimeout(this._update_state_handle)

    this._update_state_handle = setTimeout(() => {
      this._update_state_handle = null

      const entries = this._top.querySelectorAll(".p_entry.v_removable")
      const new_state = new Array(2 + 3 * (entries.length))

      new_state[0] = this._first_operator.value
      if (this._first_value.validity.valid)
        new_state[1] = this._first_value.valueAsNumber|0
      else
        new_state[1] = NaN

      let i = 2
      for (const entry of entries) {
        new_state[i+0] = entry.querySelector(".p_entry-relation").value
        new_state[i+1] = entry.querySelector(".p_entry-operator").value
        const value_field = entry.querySelector(".p_entry-value")
        if (value_field.validity.valid)
          new_state[i + 2] = value_field.valueAsNumber|0
        else
          new_state[i + 2] = NaN
        i += 3
      }

      this._state.state.coverage_filter = new_state
    }, 100)
  }

  _create_entry() {
    const entry = this._entry_template.content.firstElementChild.cloneNode(true)

    entry.querySelectorAll("select, input").forEach((element) => {
      element.addEventListener("change", this._update_state.bind(this))
    })

    const remove_button = entry.querySelector(".p_remove-entry-button")
    remove_button.onclick = (event) => {
      entry.remove()
      this._update_state()
    }

    return entry
  }
}

/// CheckboxGroupController ////////////////////////////////////////////

class CheckboxGroupController {
  constructor(state_manager, state_key, checkbox_list) {
    this._state = state_manager
    this._key = state_key
    this._checkboxes = new Map()
    this._selections = new Set(this._state.state[this._key])

    for (const checkbox of checkbox_list) {
      this._checkboxes.set(checkbox.value, checkbox)
      checkbox.checked = this._selections.has(checkbox.value)
      checkbox.addEventListener("change", this._checkbox_changed.bind(this))
    }

    this._state.subscribe(
        [state_key],
        StateManager.debounce(this._state_changed.bind(this)))

    this._update_state_handle = null
  }

  _state_changed(state, changed_values) {
    this._selections = new Set(state[this._key])
    for (const [value, checkbox] of this._checkboxes) {
      checkbox.checked = this._selections.has(value)
    }
  }

  _checkbox_changed(event) {
    const checkbox = event.target
    if (checkbox.checked == this._selections.has(checkbox.value))
      return

    if (checkbox.checked) {
      this._selections.add(checkbox.value)
    } else {
      this._selections.delete(checkbox.value)
    }

    if (this._update_state_handle === null) {
      this._update_state_handle = setTimeout(() => {
        this._update_state_handle = null
        this._state.state[this._key] = [...this._selections].sort()
      }, 0)
    }
  }
}

/// FilterController ///////////////////////////////////////////////////

class FilterController {
  constructor(state_manager, elements) {
    this._state = state_manager
    this._apply_button = elements.apply_button
    this._reset_button = elements.reset_button
    this._error_label = elements.error_label

    this._apply_button.onclick = this._apply_clicked.bind(this)
    this._reset_button.onclick = this._reset_clicked.bind(this)

    this._state.subscribe(
        ["tool_filter", "coverage_filter", "type_filter", "applied_tool_filter", "applied_coverage_filter", "applied_type_filter"],
        StateManager.debounce(this._state_changed.bind(this)))
  }

  static _is_filter_valid(key, value) {
    const VALID_OPERATORS = new Set([">=", "<=", ">", "<", "=="])
    const VALID_RELATIONS = new Set(["&&", "||"])

    switch (key) {
      case "tool_filter":
      case "type_filter":
        return value.length > 0

      case "coverage_filter": {
        if (value.length < 2 || ((value.length - 2) % 3) !== 0)
          return false
        if (!VALID_OPERATORS.has(value[0]) || !isFinite(value[1]) || value[1] < 0 || value[1] > 100)
          return false
        for (let i = 2; i < value.length; i += 3) {
          if (!VALID_RELATIONS.has(value[i+0])) return false
          if (!VALID_OPERATORS.has(value[i+1])) return false
          if (!isFinite(value[i+2]) || value[i+2] < 0 || value[i+2] > 100) return false
        }
        return true
      }
    }
  }

  _state_changed(state, changed_values) {
    let apply_possible = false;
    let reset_possible = false;
    const ERROR_MSGS = {
      tool_filter: "No tool selected.",
      coverage_filter: "Invalid coverage value(s).",
      type_filter: "No type selected.",
    }
    const ERROR_MSG_PREFIX = "<strong>Error(s):</strong> "
    const errors = []

    for (const key of ["tool_filter", "coverage_filter", "type_filter"]) {
      if (!deep_eq(state[key], this._state.state_spec[key].initial))
        reset_possible = true
      if (!deep_eq(state[key], state[`applied_${key}`]))
        apply_possible = true
      if (!FilterController._is_filter_valid(key, state[key]))
        errors.push(ERROR_MSGS[key])
    }

    if (errors.length > 0)
      this._error_label.innerHTML = ERROR_MSG_PREFIX + errors.join(" ")
    else
      this._error_label.innerText = ""

    this._apply_button.disabled = (errors.length != 0) || !apply_possible;
    this._reset_button.disabled = !reset_possible;
  }

  _apply_clicked(event) {
    const tool_filter = this._state.state.tool_filter
    const coverage_filter = this._state.state.coverage_filter
    const type_filter = this._state.state.type_filter

    this._state.state.applied_tool_filter = tool_filter
    this._state.state.applied_coverage_filter = coverage_filter
    this._state.state.applied_type_filter = type_filter

    if (!(coverage_filter.length === 2 && (
          (coverage_filter[0] === ">=" && coverage_filter[1] === 0) ||
          (coverage_filter[0] === "<=" && coverage_filter[1] === 100)
        ))) {
      const operator = coverage_filter[0]
      const value = coverage_filter[1]
      let coverage_filter_code = `(coverage ${operator} ${value})`
      for (let i = 2; i < coverage_filter.length; i += 3) {
        const relation = coverage_filter[i + 0]
        const operator = coverage_filter[i + 1]
        const value = coverage_filter[i + 2]
        coverage_filter_code += ` ${relation} (coverage ${operator} ${value})`
      }

      const cell_filter_func_code = `(coverage) => { return (${coverage_filter_code}) }`
      Log.dbg("filter", "Cell filter function: %o", cell_filter_func_code)
      const cell_filter_func = eval(cell_filter_func_code)
      this._state.state.cell_filter_func = cell_filter_func
    } else {
      this._state.state.cell_filter_func = null
    }

    if (!deep_eq(type_filter, this._state.state_spec.type_filter.initial)) {
      const type_filter_codes = []
      for (const type of type_filter)
        type_filter_codes.push(`(types.includes("${type}"))`)
      const type_filter_code = type_filter_codes.join(" || ")

      const row_filter_func_code = `(types) => { return (${type_filter_code}) }`
      Log.dbg("filter", "Row filter function: %o", row_filter_func_code)
      const row_filter_func = eval(row_filter_func_code)
      this._state.state.row_filter_func = row_filter_func
    } else {
      this._state.state.row_filter_func = null
    }

    const hidden_column_ids = []
    let i = HEADER_COLUMNS_COUNT
    for (const tool of TOOL_NAMES) {
      if (!tool_filter.includes(tool.toLowerCase()))
        hidden_column_ids.push(i)
      ++i
    }
    this._state.state.hidden_column_ids = hidden_column_ids
  }

  _reset_clicked(event) {
    for (const key of ["tool_filter", "coverage_filter", "type_filter"]) {
      this._state.state[key] = this._state.state_spec[key].initial
    }
  }
}

/// DataTable filter function that does actual filtering ///////////////

$.fn.dataTable.ext.search.push(function (settings, searchData, index, rowData, counter) {
  if (filter_state.state.row_filter_func) {
    const dt = settings.oInstance.DataTable();
    const types = dt.row(index).node().dataset.types.split(" ")
    if (!filter_state.state.row_filter_func(types))
      return false
  }
  if (filter_state.state.cell_filter_func) {
    const hidden_column_ids = filter_state.state.hidden_column_ids
    const cell_filter_func = filter_state.state.cell_filter_func
    let i = 0
    let has_matching_cell = false;
    for (let col = HEADER_COLUMNS_COUNT; col < rowData.length; ++col) {
      if (col === hidden_column_ids[i]) {
        ++i
        continue
      }
      const coverage = Math.round(parseSimpleFraction(rowData[col]) * 100)|0
      if (cell_filter_func(coverage)) {
        has_matching_cell = true
        break
      }
    }
    if (!has_matching_cell)
      return false
  }
  return true
})

/// Main ///////////////////////////////////////////////////////////////

window.addEventListener('DOMContentLoaded', function(event) {

  // DataTable

  $('table.dataTable').DataTable({
    paging: false,
    autoWidth: false,

    order: [ [1, "asc"], ],
    columns: [
      { orderable: false },
      { orderDataType: "original-order", type: "num" },
      ...TOOL_NAMES.map(() => {
        return {
          orderDataType: "simple-fraction",
          type: "num",
        }
      })
    ],
  })

  // Update tables when a filter is applied

  const tables = []
  $('table.dataTable').each(function () {
    const table = $(this).dataTable().api()
    tables.push(table)

    filter_state.subscribe(
      ["hidden_column_ids", "row_filter_func", "cell_filter_func"],
      StateManager.debounce((state, changed_values) => tables.forEach((table) => {
        if (changed_values.has("hidden_column_ids")) {
          table.columns().visible(true)
          table.columns(state.hidden_column_ids).visible(false)
        }

        setTimeout(()=>table.draw(), 0)
    }), 0))
  })

  // Filter

  const filter_section = document.querySelector("#filter-section")

  const filter_controller = new FilterController(filter_state, {
    apply_button: document.getElementById("filter-apply-button"),
    reset_button: document.getElementById("filter-reset-button"),
    error_label: document.getElementById("filter-error-msg"),
  })

  // Tool filter

  const tool_filter = filter_section.querySelector(".p_tool-filter")
  const tool_filter_checkboxes = tool_filter.querySelectorAll("input[type='checkbox']")

  tool_filter.querySelector(".p_select-all-button").onclick = (event) => {
    tool_filter_checkboxes.forEach((element) => {
      if (!element.checked) {
        element.checked = true
        element.dispatchEvent(new Event("change"))
      }
    })
  }
  tool_filter.querySelector(".p_invert-selection-button").onclick = (event) => {
    tool_filter_checkboxes.forEach((element) => {
      element.checked = !(element.checked)
      element.dispatchEvent(new Event("change"))
    })
  }

  const tool_filter_controls = new CheckboxGroupController(filter_state, "tool_filter", tool_filter_checkboxes)

  // Coverage filter

  const coverage_filter_controls = new CoverageFilterEntriesController(filter_state, filter_section.querySelector(".p_coverage-filter"));

  // Type filter

  const type_filter_checkboxes = document.querySelectorAll("#filter-section .p_type-filter input[type='checkbox']")
  const type_filter_controls = new CheckboxGroupController(filter_state, "type_filter", type_filter_checkboxes)
})
