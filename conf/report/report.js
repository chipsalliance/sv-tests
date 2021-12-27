/// Utils //////////////////////////////////////////////////////////////

function is_string(o) { return (typeof o === "string" || o instanceof String) }
function is_empty(str) { return str.length === 0 }

function deep_eq(a, b) {
  if (Array.isArray(a)) {
    if (!Array.isArray(b) || a.length != b.length)
      return false
    return a.every((v, i) => deep_eq(v, b[i]))
  } else {
    return a === b
  }
}

function parseSimpleFraction(s, for_sorting=false) {
  try {
    let [nom, denom] = s.split("/").map((v) => parseInt(v))
    if (for_sorting) {
      // Add small offsets so that fractions with the same value will be
      // sorted by denominator (e.g. 0/8 < 0/1, 1/1 < 20/20, etc).
      nom   += 0.000001
      denom += 0.000002
    }
    const value = nom / denom
    return isFinite(value) ? value : NaN
  } catch (e) {
    return NaN
  }
}

class Log {
  static dbg(tag, fmt, ...rest) {
    console.debug(`%c[${tag}]%c ${fmt}`, "text-transform:uppercase;font-weight:bold", "", ...rest)
  }

  static err(tag, fmt, ...rest) {
    console.error(`%c[${tag}]%c ${fmt}`, "text-transform:uppercase;font-weight:bold", "", ...rest)
  }
}

/// Custom sorting for DataTable ///////////////////////////////////////

// Sorts using original order of HTML table rows
$.fn.dataTable.ext.order['original-order'] = function (settings, col) {
  return [...Array(this.DataTable().data().length).keys()]
}

$.fn.dataTable.ext.order['simple-fraction'] = function (settings, col) {
  return this.DataTable().data().map(function (row) {
    const value = parseSimpleFraction(row[col], true)
    return isFinite(value) ? value : -Infinity
  })
}

/// ConfigLoader ///////////////////////////////////////////////////////

// Global map where loaded configs put data under their individual keys.
// The key is: "${tool}/${tag}", where both tool and tag are lowercase.
// The variable is considered PRIVATE - do not use it outside of ConfigLoader.
config_loader_data = {}

class ConfigLoader {
  constructor() {
    this._data = null
    this._loaded_key = null
  }

  // Loads config for specified tool and tag.
  // NOTE: do not call this concurrently multiple times.
  async load(tool, tag) {
    console.assert(is_string(tool) && !is_empty(tool), tool)
    console.assert(is_string(tag) && !is_empty(tag), tag)

    tool = tool.toLowerCase()
    tag = tag.toLowerCase()

    const key = `${tool}/${tag}`;

    if (this._loaded_key === key) {
      return this._data
    }

    const path = `results/${tool}/${tag}.config.js`

    config_loader_data[key] = undefined

    let script = document.createElement("script")
    const loading_done = new Promise((resolve, reject) => {
      script.onload = resolve
      script.onerror = reject
    })
    script.src = path
    document.head.appendChild(script)
    try {
      await loading_done
    } catch (e) {
      Log.err("config", "Loading failed.\n"
          + "tool/tag: %o/%o\nkey: %o\npath: %o\nexception: %o", tool, tag, key, path, e)
      return null
    }
    script.remove()

    if (config_loader_data[key] === undefined) {
      Log.err("config", "The loaded config script didn't assign anything to a dedicated global variable. The script probably has been generated incorrectly.\n"
          + "tool/tag: %o/%o\nkey: %o\npath: %o", tool, tag, key, path)
      return null
    }

    Log.dbg("config", "Loaded. key: %o; path: %o", key, path)

    this._loaded_key = key
    this._data = config_loader_data[key]
    delete config_loader_data[key]

    return this._data
  }

  // Releases data. Note that The data still resides in memory if there
  // are other references to it.
  unload() {
    if (this._loaded_key !== null) {
      const key = this._loaded_key
      this._data = null;
      this._loaded_key = null;
      Log.dbg("config", "Unloaded. key: %o", key)
    }
  }

  get data() { return this._data }
}

/// ReportViewerState //////////////////////////////////////////////////

class StateManager {
  constructor(state_spec) {
    this._spec = state_spec
    Object.freeze(state_spec)

    this._state = new Map()
    this._subscribers = new Map()

    for (const [key, spec] of Object.entries(state_spec)) {
      Log.dbg("state/init", "%s: %o", key, spec.initial)
      this._state.set(key, spec.initial)
      this._subscribers.set(key, new Set())
    }

    this._state_proxy = new Proxy(this._state, {
      get: this._get_state_value.bind(this),
      set: this._set_state_value.bind(this),
    })
  }

  _get_state_value(state, key, proxy) {
    console.assert(state.has(key), key)
    return state.get(key)
  }

  _set_state_value(state, key, value, proxy) {
    let previous_value = state.get(key)
    if (deep_eq(value, previous_value))
      return true

    if (this._spec[key].validator) {
      if (!this._spec[key].validator(value)) {
        Log.err("state/set", "%s: invalid value: %o", key, value)
        return false
      }
    }
    if (value instanceof Object)
      Object.freeze(value)
    state.set(key, value)
    Log.dbg("state/change", "%s: %o → %o", key, previous_value, value)
    this._subscribers.get(key).forEach((callable) => callable(this._state_proxy, new Map([[key, previous_value]])))
    return true
  }

  subscribe(keys, callable) {
    if (callable === undefined) {
      callable = keys
      keys = this._subscribers.keys()
    }
    for (const key of keys) {
      console.assert(this._subscribers.has(key), key)
      this._subscribers.get(key).add(callable)
    }
  }

  unsubscribe(keys, callable) {
    if (callable === undefined) {
      callable = keys
      keys = this._subscribers.keys()
    }
    for (const key of keys) {
      console.assert(this._subscribers.has(key), key)
      this._subscribers.get(key).delete(callable)
    }
  }

  get state() {
    return this._state_proxy
  }

  get state_spec() {
    return this._spec
  }

  static debounce(callable, timeout=0) {
    function debounce_wrapper(state, changed_values) {
      if (this.changed_values !== null) {
        changed_values.forEach((v, k) => {
          if (!this.changed_values.has(k)) {
            this.changed_values.set(k, v)
          } else if (this.changed_values.get(k) === state[k]) {
            this.changed_values.delete(k)
          }
        })
        if (this.changed_values.size === 0)
          clearTimeout(this.handle)
        return
      }
      this.changed_values = changed_values
      this.handle = setTimeout(() => {
        this.callable(state, this.changed_values)
        this.changed_values = null
      }, this.timeout)
    }

    return debounce_wrapper.bind({
      callable: callable,
      timeout: timeout,
      handle: null,
      changed_values: null,
    })
  }
}

/// TestDetailsPanel ///////////////////////////////////////////////////

class TestDetailsPanel {
  constructor(state_manager, html_element) {
    this._state = state_manager
    this._panel = html_element

    this._log = this._panel.querySelector(".p_log")
    this._file = this._panel.querySelector(".p_file")
    this._tests_list = this._panel.querySelector(".p_tests-list")
    this._item_template = this._tests_list.querySelector(".p_item-template")
    this._close_button = this._panel.querySelector(".p_close-button")

    this._config = new ConfigLoader()

    this._test_name_to_id = new Map()
    this._items = []
    this._selected_item = null
    this._last_viewed_test = null

    this._state.subscribe(
        ["tool_tag", "test", "group"],
        StateManager.debounce(this._state_changed.bind(this)))

    this._close_button.onclick = () => this.close()
  }

  async _state_changed(state, changed_values) {
    if (changed_values.has("tool_tag") || changed_values.has("group")) {
      const [tool, tag] = state.tool_tag
      if (tool === null || tag === null) {
        this._unload_and_hide()
        return
      }

      let group = state.group
      if (group === null) {
        console.assert(state.test !== null, state.test)
        group = await this._find_group(tool, tag, state.test)
        if (group !== null) {
          state.group = group
        } else {
          state.tool_tag = [null, null]
        }
        return
      }

      await this._load_tests(tool, tag, group)
      this._show_test(state.test)
    } else if (changed_values.has("test")) {
      this._show_test(state.test)
    }
  }

  async _find_group(tool, tag, test) {
    console.assert(is_string(tool) && !is_empty(tool), tool)
    console.assert(is_string(tag) && !is_empty(tag), tag)
    console.assert(is_string(test) && !is_empty(test), test)

    tool = tool.toLowerCase()
    tag = tag.toLowerCase()

    const config = await this._config.load(tool, tag)
    if (config === null) {
      Log.err("details panel", "Unknown tool/tag: %o/%o", tool, tag)
      return null
    }

    for (const [group, name] of config) {
      if (name === test)
        return group
    }
    return null
  }

  async _load_tests(tool, tag, group) {
    console.assert(is_string(tool) && !is_empty(tool), tool)
    console.assert(is_string(tag) && !is_empty(tag), tag)
    console.assert(is_string(group), group)

    tool = tool.toLowerCase()
    tag = tag.toLowerCase()

    await this._config.load(tool, tag)

    this._set_selected_item(null)
    for (const item of this._items)
      item.remove()
    this._items = []
    this._test_name_to_id.clear()

    let test_id = -1
    for (const [test_group, name, status, log_url, first_input_url] of this._config.data) {
      ++test_id
      if (test_group !== group)
        continue

      this._test_name_to_id.set(name, test_id)

      const item = this._item_template.content.firstElementChild.cloneNode(true)
      if (status)
        item.classList.add("s_passed")
      item.querySelector("slot[name='test-name']").replaceWith(name)
      item._test_id = test_id
      item.onclick = this._item_clicked.bind(this)

      this._tests_list.appendChild(item)
      this._items.push(item)
    }
  }

  _show_test(test) {
    console.assert(this._current_tool !== null)
    console.assert(test === null || is_string(test), test)

    let test_id
    if (!this._test_name_to_id.has(test)) {
      if (this._test_name_to_id.has(this._last_viewed_test)) {
        test = this._last_viewed_test
        test_id = this._test_name_to_id.get(test)
        Log.dbg("details panel", "Using last viewed test: %o", test)
      } else {
        try {
          // Use first available test
          test_id = this._items[0]._test_id
          test = this._config.data[test_id][1]
          Log.dbg("details panel", "Using first available test: %o", test)
        } catch (e) {
          Log.err("details panel", "Loaded tests list is empty.\n"
            + "tool/tag: %o/%o", this._current_tool, this._current_test)
          return
        }
      }
      this._state.state.test = test
    } else {
      test_id = this._test_name_to_id.get(test)
    }
    const log_url = this._config.data[test_id][3]
    const first_input_url = this._config.data[test_id][4]
    const item = this._items.find((e) => e._test_id == test_id)

    this._open_log(log_url)
    this._open_file(first_input_url)
    this._set_selected_item(item)
    this._last_viewed_test = test

    this._panel.classList.remove("s_hidden")
  }

  _open_log(url) {
    console.assert(is_string(url) && !is_empty(url), url)
    this._log.contentWindow.location.replace(url);
  }

  _open_file(url) {
    console.assert(is_string(url) && !is_empty(url), url)
    this._file.contentWindow.location.replace(url);
  }

  _set_selected_item(item) {
    if (this._selected_item === item)
      return;

    if (this._selected_item)
      this._selected_item.classList.remove("s_selected")
    if (item) {
      item.classList.add("s_selected")
      this._selected_item = item
    } else {
      this._selected_item = null
    }
  }

  _item_clicked(event) {
    const test_id = event.target._test_id
    console.assert(test_id >= 0 || test_id < this._config.data.length, test_id)

    const name = this._config.data[test_id][1]
    const log_url = this._config.data[test_id][3]
    const first_input_url = this._config.data[test_id][4]

    this._open_log(log_url)
    this._open_file(first_input_url)
    this._set_selected_item(event.target)
    this._last_viewed_test = name
    this._state.state.test = name
  }

  _unload_and_hide() {
    this._panel.classList.add("s_hidden")

    this._open_log("about:blank")
    this._open_file("about:blank")

    this._set_selected_item(null)
    for (const item of this._items) {
      item.remove()
    }
    this._items = []
    this._test_name_to_id.clear()
    this._config.unload()
  }

  close() {
    this._unload_and_hide()
    this._state.state.tool_tag = [null, null]
    this._state.state.test = null
    this._state.state.group = null
  }
}

/// TestResultCellsSelectionController /////////////////////////////////

class TestResultCellsSelectionController {
  constructor(state_manager, tables) {
    this._state = state_manager
    this._tables = tables

    this._selected_cell = null;

    this._state.subscribe(
        ["tool_tag", "group"],
        StateManager.debounce(this._state_changed.bind(this)))

    for (const table of this._tables) {
      const cells = table.querySelectorAll("tbody > tr > td:not(:empty)")
      for (const cell of cells) {
        cell.onclick = this._cell_clicked.bind(this)
      }
    }
  }

  _state_changed(state, changed_values) {
    if (changed_values.has("tool_tag") || changed_values.has("group")) {
      const [tool, tag] = state.tool_tag
      const group = state.group
      if (this._set_selected_cell(tool, tag, group))
        this._scroll_selected_cell_into_view()
    }
  }

  _scroll_selected_cell_into_view() {
    if (this._selected_cell === null)
      return
    const cell_to_scroll_to = this._selected_cell
    setTimeout(() => {
      if (cell_to_scroll_to === this._selected_cell) {
        cell_to_scroll_to.scrollIntoView({block: "center", inline: "end"})
      }
    }, 250)
  }

  _set_selected_cell(tool, tag, group) {
    if (tool === null || tag === null || group === null) {
      this._set_selected_cell_element(null)
      return false
    }

    tool = tool.toLowerCase()
    tag = tag.toLowerCase()

    let cell = null
    for (const table of this._tables) {
      if (table.dataset.group != group)
        continue
      cell = table.querySelector(`tbody > tr[data-tag="${tag}"] > td[data-tool="${tool}"]`);
      if (cell)
        break;
    }
    cell = cell ? cell : null
    if (cell === this._selected_cell)
      return false
    this._set_selected_cell_element(cell)
    return true
  }

  _set_selected_cell_element(element) {
    if (element === this._selected_cell)
      return;

    if (this._selected_cell)
      this._selected_cell.classList.remove("s_selected")
    if (element) {
      Log.dbg("cell select", "%o", element)
      element.classList.add("s_selected")
      this._selected_cell = element
    } else {
      Log.dbg("cell select", "%o", null)
      this._selected_cell = null
    }
  }

  _cell_clicked(event) {
    const row_element = event.target.parentElement
    const tbody_element = row_element.parentElement
    const table_element = tbody_element.parentElement

    const tool = event.target.dataset.tool
    const tag = row_element.dataset.tag
    const group = table_element.dataset.group

    const [current_tool, current_tag] = this._state.state.tool_tag
    const current_group = this._state.state.group

    if (tool === current_tool && tag === current_tag && group == current_group) {
      this._set_selected_cell_element(null)

      this._state.state.tool_tag = [null, null]
      this._state.state.test = null
      this._state.state.group = null
    } else {
      this._set_selected_cell_element(event.target)

      this._state.state.tool_tag = [tool, tag]
      this._state.state.test = null
      this._state.state.group = group
    }
  }
}

/// KeyboardControl ////////////////////////////////////////////////////

class KeyboardControl {
  constructor(state_manager) {
    this._state = state_manager

    document.addEventListener("keydown", this._key_pressed.bind(this))
  }

  _key_pressed(event) {
    switch (event.key) {
      case "Escape":
      case "Esc":
        this._state.state.tool_tag = [null, null]
        this._state.state.test = null
        this._state.state.group = null
        break
    }
  }
}

/// UrlParametersController ////////////////////////////////////////////

class UrlParametersController {
  constructor(state_manager) {
    this._state = state_manager
    this._update_state_from_parameters()
    this._state.subscribe(
        ["tool_tag", "test", "group"],
        StateManager.debounce(this._state_changed.bind(this), 125))
    window.addEventListener("popstate", (event) => this._update_state_from_parameters())
  }

  _state_changed(state, changed_values) {
    if (changed_values.has("tool_tag") || changed_values.has("test")) {
      const [tool, tag] = state.tool_tag
      const test = state.test

      const url = UrlParametersController._make_url(tool, tag, test)
      if (url.href === window.location.href)
        return

      history.pushState(null, "", url.href)
      document.title = UrlParametersController._make_title(tool, tag, test)
    }
  }

  static _make_url(tool, tag, test) {
    const url = new URL(window.location)
    if (tool === null || tag === null) {
      url.hash = ""
      url.searchParams.delete("v")
    } else if (test !== null) {
      url.hash = ""
      url.searchParams.set("v", `${tool} ${tag} ${test}`)
    }
    return url
  }

  static _make_title(tool, tag, test) {
    if (tool === null || tag === null) {
      return `SystemVerilog Report`
    } else if (test !== null) {
      return `${tool}/${tag}/${test} - SystemVerilog Report`
    }
  }

  _update_state_from_parameters() {
    let url = new URL(window.location)

    const set_state_if_valid = (tool, tag, test) => {
      if (tool !== undefined && tool !== ""
          && tag !== undefined && tag !== ""
          && test !== undefined && test !== "") {
        const url = UrlParametersController._make_url(tool, tag, test)
        if (url.href !== window.location.href)
          history.replaceState(null, "", url.href)

        document.title = UrlParametersController._make_title(tool, tag, test)

        this._state.state.tool_tag = [tool, tag]
        this._state.state.test = test
        this._state.state.group = null

        return true
      }
      return false
    }

    // Try URL parameter "v" containing "${TOOL} ${TAG} ${TEST}"
    const v = url.searchParams.get("v")
    if (is_string(v) && !is_empty(v)) {
      const values = v.split(" ")
      let [tool, tag, test] = values
      if (set_state_if_valid(tool, tag, test))
        return
    }

    // Try URL hash containing "#${TOOL}|${TAG}|${TEST}" (legacy format)
    if (is_string(url.hash) && !is_empty(url.hash)) {
      const hash = decodeURIComponent(url.hash).substr(1)
      const [tool, tag, test] = hash.split("|")
      if (set_state_if_valid(tool, tag, test))
        return
    }

    // Set initial state (no selected test). Required for correct state
    // restoration from history.
    set_state_if_valid(null, null, null)
  }
}

/// Main ///////////////////////////////////////////////////////////////

const state_manager = new StateManager({
  tool_tag: {
    initial: [null, null],
    validator: (v) => (Array.isArray(v) && ((is_string(v[0]) && is_string(v[1])) || (v[0] === null && v[1] === null)))
  },
  test: {
    initial: null,
    validator: (v) => (is_string(v) || v === null)
  },
  group: {
    initial: null,
    validator: (v) => (is_string(v) || v === null)
  },
})

var test_details_panel = null;
var cells_selection_controller = null;
var keyboard_control = null;
var url_parameters_controller = null;

window.addEventListener('DOMContentLoaded', function(event) {
  const test_details_panel_element = document.querySelector(
      ".c_test-details-panel")
  test_details_panel = new TestDetailsPanel(state_manager, test_details_panel_element)

  const tables = document.querySelectorAll(".dataTable")
  cells_selection_controller = new TestResultCellsSelectionController(state_manager, tables)

  keyboard_control = new KeyboardControl(state_manager)
  url_parameters_controller = new UrlParametersController(state_manager)

  // Track panel height and store it in body's "--panel-height" CSS property
  // TODO: move to a class, probably to TestDetailsPanel.
  const panel_resize_observer = new ResizeObserver(entries => {
    console.assert(entries.length === 1, entries)
    const panel_entry = entries[0]
    document.body.style.setProperty("--panel-height", `${panel_entry.borderBoxSize[0].blockSize}px`)
  })
  state_manager.subscribe(["tool_tag"], StateManager.debounce((state, changed_values) => {
    if (state.tool_tag[0] !== null) {
      panel_resize_observer.observe(test_details_panel_element, { box: "border-box" })
    } else {
      panel_resize_observer.unobserve(test_details_panel_element)
      document.body.style.removeProperty("--panel-height")
    }
  }))
  if (state_manager.state.tool_tag[0] !== null)
    panel_resize_observer.observe(test_details_panel_element, { box: "border-box" })

  // Install tooltip component
  $(function() {
    $(document).tooltip({ track: true, show: 0, hide: 0 });
  });
})
