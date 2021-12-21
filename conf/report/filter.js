var tables = [];
var toolnames = TOOL_NAMES;
var tool_array = [];
var col_array = [];

$(document).ready(function () {
  $('table.dataTable').DataTable({
    paging: false,
    autoWidth: false,

    order: [ [1, "asc"], ],
    columns: [
      { orderable: false },
      { orderDataType: "original-order", type: "num" },
      ...TOOL_NAMES.map(() => { return { orderDataType: "simple-fraction", type: "num" } })
    ],
  })

  $('table.dataTable').each(function () {
    tables.push($(this).dataTable().api())
  })
  col_array = [...Array(TOOL_NAMES.length+2).keys()]
  tool_array = [...col_array.slice(2)]
});

var iter;
var selected_tools = [];
var tools_relation;

const operator_from_string = {
  '<': (a, b) => a < b,
  '>': (a, b) => a > b,
  '>=': (a, b) => a >= b,
  '<=': (a, b) => a <= b,
  '=': (a, b) => a === b
};

const relation_from_string = {
  'and': (a, b) => a && b,
  'or': (a, b) => a || b
}

function toggleFilters() {
  let x = document.getElementById("filter");
  if (x.style.display === "none") {
    x.style.display = "block";
  } else {
    x.style.display = "none";
  }
}

const filter_types = {
  coverage: {
    name: "Coverage",
    operators: ["<", "<=", ">", ">=", "="],
    value_field_factory: function(id, span_id=0) {
      span_id = parseInt(span_id)
      if ($(`li[data-uid=${id}] span[data-uid=${span_id+1}]`).length > 0)
        $(`li[data-uid=${id}] span[data-uid=${span_id+1}]`).remove()
      const iter = $(`li[data-uid=${id}] span`).length
      if (iter === 0)
        $(`<span data-uid=${iter}></span>`).insertAfter(`li[data-uid=${id}] .filter-entry-type`)
      else
        $(`<span data-uid=${iter}></span>`).insertAfter(`li[data-uid=${id}] span[data-uid=${iter-1}]`)
      $('<select class="filter-entry-operator"><option value=""></option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      $('<select class="filter-entry-value"><option value=""></option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      $('<select onchange="filter_types.coverage.value_field_factory(this.parentElement.parentElement.dataset.uid, this.parentElement.dataset.uid)" class="filter-condition"><option value=""></option><option value="and">AND</option><option value="or">OR</option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      for (let i=0; i<this.operators.length; i++)
        $(`<option value="${this.operators[i]}">${this.operators[i]}</option>`).appendTo(`li[data-uid=${id}] span[data-uid=${iter}] .filter-entry-operator`);
      for (let i=0; i<=100; i++)
        $(`<option value="${i}">${i}</option>`).appendTo(`li[data-uid=${id}] span[data-uid=${iter}] .filter-entry-value`);
    },
    apply: function(operator1, percentage1, operator2, percentage2, relation) {
      let values = new Set()
      for (const table of tables) {
        if (typeof relation == 'undefined') {
          table.columns().every(function () {
            let column = this
            if (column.index() !== 0 && column.index() !== 1) {
              percentage = parseInt(percentage1)
              column.data().each(function (d, j) {
                output = d.split('/')
                tests_passed = output[0]
                total_tests = output[1]
                coverage = parseInt((tests_passed / total_tests) * 100)
                if ((operator1 in operator_from_string) && operator_from_string[operator1](coverage, percentage))
                  values.add(d)
              })
            }
          })
        }
        else {
          table.columns().every(function () {
            let column = this
            if (column.index() !== 0 && column.index() !== 1) {
              percentage1 = parseInt(percentage1)
              percentage2 = parseInt(percentage2)
              column.data().each(function (d, j) {
                output = d.split('/')
                tests_passed = output[0]
                total_tests = output[1]
                coverage = parseInt((tests_passed / total_tests) * 100)
                const result_left = operator_from_string[operator1](coverage, percentage1)
                const result_right = operator_from_string[operator2](coverage, percentage2)
                const result = relation_from_string[relation](result_left, result_right)
                if (result)
                  values.add(d)
              })
            }
          })
        }
      }

      values = [...values]
      if (selected_tools.length === 0) {
        $.fn.dataTable.ext.search.push(
          function (settings, searchData, index, rowData, counter) {
            for (let i = 0; i < col_array.length; i++) {
              if (values.includes(searchData[col_array[i]]))
                return true
            }
          })
      }
      else {
        if (tool_relation !== 'and') {
          $.fn.dataTable.ext.search.push(
            function (settings, searchData, index, rowData, counter) {
              for (let i = 0; i < selected_tools.length; i++) {
                if (values.includes(searchData[selected_tools[i]]))
                  return true
              }
            })
        }
        else if (tool_relation === 'and') {
          regex = []
          for (let i = 0; i < values.length; i++) {
            value = "^" + values[i] + "$"
            regex.push(value)
          }
          regex = regex.join("|")

          for (const table of tables) {
            table.columns(selected_tools).search(regex, true, false, true).draw()
          }
        }
      }
      for (const table of tables) {
        table.draw()
      }
    } // .apply()
  }, // .coverage
  type: {
    name: "Type",
    operators: ["is", "is not"],
    types: ["parsing", "preprocessing", "simulation"],
    value_field_factory: function(id, span_id=0) {
      span_id = parseInt(span_id)
      if ($(`li[data-uid=${id}] span[data-uid=${span_id+1}]`).length > 0)
        $(`li[data-uid=${id}] span[data-uid=${span_id+1}]`).remove()
      const iter = $(`li[data-uid=${id}] span`).length
      if (iter === 0)
        $(`<span data-uid=${iter}></span>`).insertAfter(`li[data-uid=${id}] .filter-entry-type`)
      else
        $(`<span data-uid=${iter}></span>`).insertAfter(`li[data-uid=${id}] span[data-uid=${iter-1}]`)
      $('<select class="filter-entry-operator"><option value=""></option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      $('<select class="filter-entry-value"><option value=""></option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      $('<select onchange="filter_types.type.value_field_factory(this.parentElement.parentElement.dataset.uid, this.parentElement.dataset.uid)" class="filter-condition"><option value=""></option><option value="and">AND</option><option value="or">OR</option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      for (let i=0; i<this.operators.length; i++)
        $(`<option value="${this.operators[i]}">${this.operators[i]}</option>`).appendTo(`li[data-uid=${id}] span[data-uid=${iter}] .filter-entry-operator`);
      for (let i=0; i<this.types.length; i++)
        $(`<option value="${this.types[i]}">${this.types[i]}</option>`).appendTo(`li[data-uid=${id}] span[data-uid=${iter}] .filter-entry-value`);
    },
    apply: function(operator1, type1, operator2, type2, relation) {
      if (typeof relation == 'undefined'){
        $.fn.dataTable.ext.search.push(
          function(settings, data, dataIndex){
            if (operator1 === 'is')
              return $(settings.row(dataIndex).node()).hasClass(type1);
            else if (operator1 === 'is not')
              return !$(settings.row(dataIndex).node()).hasClass(type1);
          });
      }
      else {
        $.fn.dataTable.ext.search.push(
          function(settings, data, dataIndex){
            if (relation === 'and'){
              if (operator1 === 'is' && operator2 === 'is')
                return (($(settings.row(dataIndex).node()).hasClass(type1)) && ($(settings.row(dataIndex).node()).hasClass(type2)));
              else if (operator1 === 'is' && operator2 === 'is not')
              return (($(settings.row(dataIndex).node()).hasClass(type1)) && (!$(settings.row(dataIndex).node()).hasClass(type2)));
              else if (operator1 === 'is not' && operator2 === 'is')
              return ((!$(settings.row(dataIndex).node()).hasClass(type1)) && ($(settings.row(dataIndex).node()).hasClass(type2)));
              else if (operator1 === 'is not' && operator2 === 'is not')
              return ((!$(settings.row(dataIndex).node()).hasClass(type1)) && (!$(settings.row(dataIndex).node()).hasClass(type2)));
            }
            else if (relation === 'or'){
              if (operator1 === 'is' && operator2 === 'is')
                return (($(settings.row(dataIndex).node()).hasClass(type1)) || ($(settings.row(dataIndex).node()).hasClass(type2)));
              else if (operator1 === 'is' && operator2 === 'is not')
              return (($(settings.row(dataIndex).node()).hasClass(type1)) || (!$(settings.row(dataIndex).node()).hasClass(type2)));
              else if (operator1 === 'is not' && operator2 === 'is')
              return ((!$(settings.row(dataIndex).node()).hasClass(type1)) || ($(settings.row(dataIndex).node()).hasClass(type2)));
              else if (operator1 === 'is not' && operator2 === 'is not')
              return ((!$(settings.row(dataIndex).node()).hasClass(type1)) || (!$(settings.row(dataIndex).node()).hasClass(type2)));
            }
          }
        );
      }
      tables.forEach((table) => table.draw())
    } // .apply()
  }, // .type
  tool: {
    name: "Tool",
    operators: ["is", "is not"],
    tools: toolnames,
    value_field_factory: function(id, span_id=0) {
      span_id = parseInt(span_id)
      if ($(`li[data-uid=${id}] span[data-uid=${span_id+1}]`).length > 0)
        $(`li[data-uid=${id}] span[data-uid=${span_id+1}]`).remove()
      const iter = $(`li[data-uid=${id}] span`).length
      if (iter === 0)
        $(`<span data-uid=${iter}></span>`).insertAfter(`li[data-uid=${id}] .filter-entry-type`)
      else
        $(`<span data-uid=${iter}></span>`).insertAfter(`li[data-uid=${id}] span[data-uid=${iter-1}]`)
      $('<select class="filter-entry-operator"><option value=""></option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      $('<select class="filter-entry-value"><option value=""></option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      $('<select onchange="filter_types.tool.value_field_factory(this.parentElement.parentElement.dataset.uid, this.parentElement.dataset.uid)" class="filter-condition"><option value=""></option><option value="and">AND</option><option value="or">OR</option></select>').appendTo(`li[data-uid=${id}] span[data-uid=${iter}]`)
      for (let i=0; i<this.operators.length; i++)
        $(`<option value="${this.operators[i]}">${this.operators[i]}</option>`).appendTo(`li[data-uid=${id}] span[data-uid=${iter}] .filter-entry-operator`);
      for (let i=0; i<this.tools.length; i++)
        $(`<option value="${this.tools[i]}">${this.tools[i]}</option>`).appendTo(`li[data-uid=${id}] span[data-uid=${iter}] .filter-entry-value`);
    },
    apply: function(operator, tool) {
      for (const table of tables) {
        table.columns(col_array).visible(true)
        table.columns(tool_array).every(function () {
          let column = this
          if (column.index() !== 0 && column.index() !== 1) {
            let theadname = column.header().textContent.trim()
            if (operator === 'is') {
              if (theadname === tool) {
                let index = tool_array.indexOf(column.index())
                tool_array.splice(index, 1)
                selected_tools.push(column.index())
              }
            }
            else if (operator === 'is not') {
              if (theadname !== tool) {
                let index = tool_array.indexOf(column.index())
                tool_array.splice(index, 1)
                selected_tools.push(column.index())
              }
            }
          }
        })
        table.columns(tool_array).visible(false)
      }
    } // .apply()
  } // .tool
} // filter_types

function entryChanged(mode, id) {
  $(`li[data-uid=${id}] span`).remove();
  filter_types[mode].value_field_factory(id);
}

function applyFilter() {
  for (const table of tables) {
    tool_array = table.columns()[0]
    tool_array = tool_array.splice(2)
    table.columns(col_array).every(function () {
      $.fn.dataTable.ext.search.pop()
    })
    table.columns(col_array).search("").draw()
    table.columns(col_array).visible(true)
    $.fn.dataTable.ext.search.pop()
    table.draw()
    $('.filter-remove').show()
    let applied_filters = []
    $('.filter-entries').find('li').each(function () {
      let object = {}
      object['filter'] = $(this).find('.filter-entry-type').val()
      if (object['filter'] === 'tool')
        object['priority'] = 1
      else
        object['priority'] = 0
      $(this).find('span').each(function (index) {
        let span = {}
        span['relation'] = $(this).find('.filter-condition').val()
        span['operator'] = $(this).find('.filter-entry-operator').val()
        span['value'] = $(this).find('.filter-entry-value').val()
        object[index] = span
      })
      applied_filters.push(object)
    })
    applied_filters.sort((a, b) => (a.priority < b.priority) ? 1 : -1)
    for (const key in applied_filters) {
      if (applied_filters[key]['filter'] === 'tool')
        tool_relation = applied_filters[key][0]['relation']
      if (applied_filters[key]['filter'] !== 'tool' && (Object.keys(applied_filters[key]).length - 2 === 2))
        filter_types[applied_filters[key]['filter']].apply(applied_filters[key][0]['operator'], applied_filters[key][0]['value'], applied_filters[key][1]['operator'], applied_filters[key][1]['value'], applied_filters[key][0]['relation'])
      else {
        for (let i = 0; i < Object.keys(applied_filters[key]).length - 2; i++)
          filter_types[applied_filters[key]['filter']].apply(applied_filters[key][i]['operator'], applied_filters[key][i]['value'])
      }
    }
  }
}

function removeAll() {
  $.fn.dataTable.ext.search.pop()
  for (const table of tables) {
    table.columns(col_array).search("").draw()
    table.columns(col_array).visible(true)
    table.draw()
  }
  $('li').remove();
  $('.filter-apply').hide();
  $('.filter-remove').hide();
}

function removeEntry(parent, col_array) {
  parent.remove();
  iter = $('.filter-entries').children('li').length;
  applyFilter();
  if (iter === 0){
    $('.filter-apply').hide();
    $('.filter-remove').hide();
    $.fn.dataTable.ext.search.pop()
    for (const table of tables) {
      table.columns(col_array).search("").draw()
      table.columns(col_array).visible(true)
      table.draw()
    }
  }
}

function addOptions() {
  iter = $('.filter-entries').children('li').length;
  if(iter === 0)
    $('.filter-apply').show();
  const filter_entries = $(`<li data-uid=${iter}></li>`).appendTo('.filter-entries');
  const filter_entry_type =  $('<select class="filter-entry-type" onchange="entryChanged(this.value, this.parentElement.dataset.uid)"><option value=""></option></select>').appendTo(filter_entries)
  $('<i class="fas fa-minus-circle filter-clear" onclick="removeEntry(this.parentElement, col_array)"></i>').insertAfter(filter_entry_type);

  for (const key in filter_types){
    filter_entry_type.append(`<option value=${key}>${filter_types[key].name}</option>`);
  }
  iter = iter + 1;
}
