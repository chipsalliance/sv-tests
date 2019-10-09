url_tool = ''
url_tag = ''
url_test = ''

function updateUrl() {
  window.history.pushState(null, null,
	  location.protocol + '//' + location.host + location.pathname + '#' +
	  [url_tool, url_tag, url_test].join('|'))
};

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

function toggleLog(tool, tag, test) {
  all_logs = document.getElementsByClassName("logfile-shown");

  url_tool = tool;
  if(url_tag === tag){
    test = url_test;
  } else {
    url_tag = tag;
    url_test = test;
  };
  updateUrl();

  var div_id = [tool, tag, "logfile"].join("-");
  var cell_id = [tool, tag, "cell"].join("-");

  for (var i=0; i < all_logs.length; ++i) {
    if (all_logs[i].id != div_id) {
      hideLog(all_logs[i].id);
    }
  }

  log_div = document.getElementById(div_id);
  outer_div = document.getElementById('logfile-outer');

  if (test === null) {
    window.open('about:blank', 'log-frame')
  } else {
    test_btn = document.getElementById(
      ['logtab', 'btn', tool, tag, test].join('-'));
    test_btn.onclick();
  }

  if (log_div.classList.toggle("logfile-shown")) {
    outer_div.classList.add("logfile-outer-shown");
  } else {
    outer_div.classList.remove("logfile-outer-shown");
  }

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

function selectTab(path, btn_id, file, test_name) {
  url_test = test_name;
  updateUrl();
  all_btns = document.getElementsByClassName("logtab-btn-selected");
  for (var i=0; i < all_btns.length; i++) {
    all_btns[i].classList.remove("logtab-btn-selected");
  }

  btn = document.getElementById(btn_id);
  btn.classList.add("logtab-btn-selected");

  window.open(path, "log-frame");

  if (file === null) {
    window.open("about:blank", 'file-frame')
  } else {
    window.open(file, 'file-frame')
  }
}

$(function() {
  $(document).tooltip({
    track: true,
    show: 0,
    hide: 0
  });
});

$(document).ready(function() {
  var hash = location.hash.substr(1).split('|');

  console.log(hash);

  tool = hash[0];
  tag = hash[1];
  test = hash[2];

  chap_btn = document.getElementById(
    [tool, tag, 'cell'].join('-'));
  chap_btn.onclick();

  test_btn = document.getElementById(
    ['logtab', 'btn', tool, tag, test].join('-'));
  test_btn.onclick();
});
