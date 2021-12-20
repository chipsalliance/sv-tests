/// Custom sorting for DataTable ///////////////////////////////////////

(function () {

  function isChapterNumber(a) {
    var parts = a.split(".")

    for (var i = 0; i < parts.length; i++) {

      if (isNaN(Number(parts[i]))) {
        return false
      }
    }

    return true
  };

  function chapterNumberCompare(a, b) {
    if (!isChapterNumber(a)) {
      if (!isChapterNumber(b)) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0))
      } else {
        return -1
      }
    } else if (!isChapterNumber(b)) {
      return 1
    }

    var a_parts = a.split(".")
    var b_parts = b.split(".")

    /* One or none of these loops will be executed */
    while (a_parts.length < b_parts.length) {
      a_parts.push("0")
    }

    while (a_parts.length > b_parts.length) {
      b_parts.push("0")
    }

    for (var i = 0; i < a_parts.length; i++) {
      if (Number(a_parts[i]) == Number(b_parts[i])) {
        continue
      } else if (Number(a_parts[i]) < Number(b_parts[i])) {
        return -1
      } else if (Number(a_parts[i]) > Number(b_parts[i])) {
        return 1
      }
    }

    return 0
  }

  $.fn.dataTable.ext.type.order['sv-id-asc'] = function (a, b) {
    return chapterNumberCompare(a, b)
  }

  $.fn.dataTable.ext.type.order['sv-id-desc'] = function (a, b) {
    return chapterNumberCompare(b, a)
  }

  $.fn.dataTable.ext.order['test-status'] = function (settings, col) {
    return this.api().column(col, { order: 'index' }).nodes().map(function (td, i) {
      p = eval(td.textContent)
      if (typeof p !== 'undefined') {
        return 1 - p
      }
      return 2
    })
  }

}())

/// Utils //////////////////////////////////////////////////////////////

function is_string(o) { return (typeof o === "string" || o instanceof String) }
function is_empty(str) { return str.length === 0 }

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
      console.error("Config script loading failed.\n"
          + "tool: %s\ntag: %s\nkey: %s\npath: %s\nexception: %o", tool, tag, key, path, e)
      return null
    }
    script.remove()

    if (config_loader_data[key] === undefined) {
      console.error("The loaded config script didn't assign anything to a dedicated global variable. The script probably has been generated incorrectly.\n"
          + "tool: %s\ntag: %s\nkey: %s\npath: %s", tool, tag, key, path)
      return null
    }

    console.debug("Config loaded. key: %s; path: %s", key, path)

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
      console.debug("Config unloaded. key: %s", key)
    }
  }

  get data() { return this._data }
}

/// ReportViewerState //////////////////////////////////////////////////

class ReportViewerState {
  constructor() {
    this._state = {
      current_tool_tag: [null, null],
      current_test: null,
    }

    this._subscribers = {}
    for (const state_key of Object.keys((this._state))) {
      this._subscribers[state_key] = new Set()
    }
  }

  set(new_values, sender=undefined) {
    const interested_subscribers = new Set()
    const modified_values = {}

    console.debug("Set state:", new_values)
    for (const [key, value] of Object.entries(new_values)) {
      console.assert(key in this._state, key)
      console.debug(`state change: ${key}: "${this._state[key]}" → "${value}"`)
      this._state[key] = value
      modified_values[key] = value
      this._subscribers[key].forEach(v => interested_subscribers.add(v))
    }
    interested_subscribers.forEach(cb => cb(modified_values, sender))
    console.groupEnd()
  }

  get(key) {
    console.assert(key in this._state, key)
    return this._state[key]
  }

  subscribe(state_keys, callback) {
    for (const key of state_keys) {
      console.assert(key in this._subscribers, key)
      this._subscribers[key].add(callback)
    }
  }

  unsubscribe(state_keys, callback) {
    for (const key of state_keys) {
      console.assert(key in this._subscribers, key)
      this._subscribers[key].remove(callback)
    }
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
    this._last_viewed_test = null,

    this._state.subscribe(["current_tool_tag", "current_test"], this._state_changed.bind(this))

    this._close_button.onclick = () => this.close()
  }

  async _state_changed(values, sender) {
    if (sender === this)
      return

    if ("current_tool_tag" in values) {
      const [tool, tag] = values.current_tool_tag

      if (tool !== null && tag !== null) {
        await this._load_tests(tool, tag)
        this._show_test(this._state.get("current_test"))
      } else {
        this._unload_and_hide()
      }
    } else if ("current_test" in values) {
      this._show_test(values.current_test)
    }
  }

  async _load_tests(tool, tag) {
    console.assert(is_string(tool) && !is_empty(tool), tool)
    console.assert(is_string(tag) && !is_empty(tag), tag)

    tool = tool.toLowerCase()
    tag = tag.toLowerCase()

    await this._config.load(tool, tag)

    this._set_selected_item(null)
    for (const item of this._items)
      item.remove()
    this._items = []
    this._test_name_to_id.clear()

    let test_id = 0
    for (const [name, status, log_url, first_input_url] of this._config.data) {
      this._test_name_to_id.set(name, test_id)

      const item = this._item_template.content.firstElementChild.cloneNode(true)
      if (status)
        item.classList.add("s_passed")
      item.querySelector("slot[name='test-name']").replaceWith(name)
      item._test_id = test_id
      item.onclick = this._item_clicked.bind(this)

      this._tests_list.appendChild(item)
      this._items.push(item)

      ++test_id
    }
  }

  _show_test(test) {
    console.assert(this._current_tool !== null)
    console.assert(test === null || is_string(test), test)

    if (!this._test_name_to_id.has(test)) {
      if (this._test_name_to_id.has(this._last_viewed_test)) {
        test = this._last_viewed_test
        console.debug(`Using last viewed test: "${test}"`)
      } else {
        try {
          // Use first available test name
          test = this._config.data[0][0]
          console.debug(`Using first available test: "${test}"`)
        } catch (e) {
          console.error("Loaded tests list is empty.\n"
              + "tool: %s\ntag: %s", this._current_tool, this._current_test)
          return
        }
      }
      this._state.set({ current_test: test }, this)
    }
    const test_id = this._test_name_to_id.get(test)
    const log_url = this._config.data[test_id][2]
    const first_input_url = this._config.data[test_id][3]
    const item = this._items[test_id]

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

    const name = this._config.data[test_id][0]
    const log_url = this._config.data[test_id][2]
    const first_input_url = this._config.data[test_id][3]

    this._open_log(log_url)
    this._open_file(first_input_url)
    this._set_selected_item(event.target)
    this._last_viewed_test = name
    this._state.set({current_test: name})
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
    this._state.set({ current_tool_tag: [null, null], current_test: null }, this)
  }
}

/// TestResultCellsSelectionController /////////////////////////////////

class TestResultCellsSelectionController {
  constructor(state_manager, tables) {
    this._state = state_manager
    this._tables = tables

    this._selected_cell = null;

    this._state.subscribe(["current_tool_tag"], this._state_changed.bind(this))

    for (const table of this._tables) {
      const cells = table.querySelectorAll("tbody > tr > td:not(:empty)")
      for (const cell of cells) {
        cell.onclick = this._cell_clicked.bind(this)
      }
    }
  }

  _state_changed(values, sender) {
    if (sender === this)
      return

    if ("current_tool_tag" in values) {
      const [tool, tag] = values.current_tool_tag
      this._set_selected_cell(tool, tag)
    }
  }

  _set_selected_cell(tool, tag) {
    if (tool === null || tag === null) {
      this._set_selected_cell_element(null)
      return
    }

    tool = tool.toLowerCase()
    tag = tag.toLowerCase()

    let cell = null
    for (const table of this._tables) {
      cell = table.querySelector(`tbody > tr[data-tag="${tag}"] > td[data-tool="${tool}"]`);
      if (cell)
        break;
    }
    this._set_selected_cell_element(cell ? cell : null)
  }

  _set_selected_cell_element(element) {
    if (element === this._selected_cell)
      return;

    if (this._selected_cell)
      this._selected_cell.classList.remove("s_selected")
    if (element) {
      console.debug(`Selecting cell: %o`, element)
      element.classList.add("s_selected")
      this._selected_cell = element
    } else {
      console.debug(`Selecting cell: null`)
      this._selected_cell = null
    }
  }

  _cell_clicked(event) {
    const tool = event.target.dataset.tool
    const tag = event.target.parentElement.dataset.tag

    const [current_tool, current_tag] = this._state.get("current_tool_tag")

    if (tool === current_tool && tag === current_tag) {
      this._set_selected_cell_element(null)
      this._state.set({ current_tool_tag: [null, null], current_test: null }, this)
    } else {
      this._set_selected_cell_element(event.target)
      this._state.set({ current_tool_tag: [tool, tag], current_test: null }, this)
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
        const current_test = this._state.get("current_test")
        this._state.set({ current_tool_tag: [null, null], current_test: null })
        break
    }
  }
}

/// UrlParametersController ////////////////////////////////////////////

class UrlParametersController {
  constructor(state_manager) {
    this._state = state_manager
    this._state.subscribe(["current_tool_tag", "current_test"], this._state_changed.bind(this))
    this._state_handling_suspended = false
    this._update_state_from_parameters()
    window.addEventListener("popstate", this._restore_state.bind(this))
  }

  _state_changed(values, sender) {
    if (this._state_handling_suspended)
      return

    const url = new URL(window.location)
    url.hash = ""

    if ("current_test" in values || "current_tool_tag" in values) {
      const [tool, tag] = this._state.get("current_tool_tag")
      const test = this._state.get("current_test")
      if (tool === null || tag === null) {
        url.searchParams.delete("v")
        document.title = `SystemVerilog Report`
      } else if (test !== null) { // Do not show "temporary" URLs without a test
        url.searchParams.set("v", `${tool} ${tag} ${test}`)
        document.title = `${tool}/${tag}/${test} - SystemVerilog Report`
      } else {
        return
      }
      if (url.href == window.location.href)
        return
      if (sender === this)
        history.replaceState(null, "", url.href)
      else
        history.pushState(null, "", url.href)
    }
  }

  _restore_state(event) {
    this._state_handling_suspended = true
    this._update_state_from_parameters()
    this._state_handling_suspended = false
  }

  _update_state_from_parameters() {
    let url = new URL(window.location)

    const set_state_if_valid = (tool, tag, test) => {
      if (tool !== undefined && tool !== ""
          && tag !== undefined && tag !== ""
          && test !== undefined && tag !== "") {
        this._state.set({ "current_tool_tag": [tool, tag], "current_test": test })
        return true
      }
      return false
    }

    // Try URL parameter "v" containing "${TOOL} ${TAG} ${TEST}"
    const v = url.searchParams.get("v")
    if (is_string(v) && !is_empty(v)) {
      const [tool, tag, test] = v.split(" ")
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
    this._state.set({ "current_tool_tag": [null, null], "current_test": null })
  }
}

/// Main ///////////////////////////////////////////////////////////////

const state_manager = new ReportViewerState()

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
  state_manager.subscribe(["current_tool_tag"], (values) => {
    if (values.current_tool_tag[0] !== null) {
      panel_resize_observer.observe(test_details_panel_element, { box: "border-box" })
    } else {
      panel_resize_observer.unobserve(test_details_panel_element)
      document.body.style.removeProperty("--panel-height")
    }
  })
  if (state_manager.get("current_tool_tag")[0] !== null)
    panel_resize_observer.observe(test_details_panel_element, { box: "border-box" })

  // Install tooltip component
  $(function() {
    $(document).tooltip({ track: true, show: 0, hide: 0 });
  });
})
