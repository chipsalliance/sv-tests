function isChapterNumber(a) {
  var parts = a.split(".");

  for (var i = 0; i < parts.length; i++) {

  if (isNaN(Number(parts[i]))) {
     return false;
   }
 }

  return true;
};

function chapterNumberCompare(a, b) {
  if (!isChapterNumber(a)) {
    if (!isChapterNumber(b)) {
      return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    } else {
      return -1;
    }
  } else if (!isChapterNumber(b)) {
    return 1;
  }

  var a_parts = a.split(".");
  var b_parts = b.split(".");

  /* One or none of these loops will be executed */
  while (a_parts.length < b_parts.length) {
    a_parts.push("0");
  }

  while (a_parts.length > b_parts.length) {
    b_parts.push("0");
  }

  for (var i = 0; i < a_parts.length; i++) {
    if (Number(a_parts[i]) == Number(b_parts[i])) {
      continue;
    } else if (Number(a_parts[i]) < Number(b_parts[i])) {
      return -1;
    } else if (Number(a_parts[i]) > Number(b_parts[i])) {
      return 1;
    }
  }

  return 0;
}

$.fn.dataTable.ext.type.order['sv-id-asc'] = function (a, b) {
  return chapterNumberCompare(a, b);
};

$.fn.dataTable.ext.type.order['sv-id-desc'] = function (a, b) {
  return chapterNumberCompare(b, a);
};

$.fn.dataTable.ext.order['test-status'] = function ( settings, col ) {
  return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {

    if (td.className.includes("test-passed")) {
      return 1;
    }

    if (td.className.includes("test-failed")) {
      return 2;
    }

    if (td.className.includes("test-varied")) {
      return 3;
    }

    return 4;
  });
};

function toggleLog(div_id, cell_id) {
  all_logs = document.getElementsByClassName("logfile-shown");

  for (var i=0; i < all_logs.length; ++i) {
    if (all_logs[i].id != div_id) {
      hideLog(all_logs[i].id);
    }
  }

  log_div = document.getElementById(div_id);
  log_div.classList.toggle("logfile-shown");

  cell = document.getElementById(cell_id);
  cell.classList.toggle("test-cell-selected");
}

function hideLog(div_id) {
  log_div = document.getElementById(div_id);
  log_div.classList.remove("logfile-shown");

  cells = document.getElementsByClassName("test-cell-selected");
  for (var i=0; i < cells.length; ++i) {
    cells[i].classList.remove("test-cell-selected");
  }
}

function selectTab(group, test, btn_id) {
  all_tabs = document.getElementsByClassName(group);
  tab_id = group + "-" + test;

  all_btns = document.getElementsByClassName("logtab-btn-selected");

  for (var i=0; i < all_btns.length; ++i) {
    if (all_btns[i].parentElement.id == group + "-bar") {
      if (all_btns[i].id != btn_id) {
        all_btns[i].classList.remove("logtab-btn-selected");
      }
    }
  }

  for (var i=0; i < all_tabs.length; ++i) {
    if (all_tabs[i].id != tab_id) {
      all_tabs[i].classList.remove("logtab-shown");
    }
  }

  chosen_tab = document.getElementById(tab_id);
  chosen_tab.classList.toggle("logtab-shown");

  btn = document.getElementById(btn_id);

  btn.classList.toggle("logtab-btn-selected");
}

$(function() {
  $(document).tooltip({
    track: true,
    show: 0,
    hide: 0
  });
});
