// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC


`ifndef _CUSTOM_REPORT_SERVER_SVH_
`define _CUSTOM_REPORT_SERVER_SVH_

`ifdef UVM_POST_VERSION_1_1


class custom_report_server extends
`ifndef UVM_1p1d
  uvm_default_report_server;
`else
   uvm_report_server;
`endif

  `uvm_object_utils(custom_report_server)

  string filename_cache[string];
  string hier_cache[string];

  int unsigned file_name_width = 22;
  int unsigned hier_width = 22;

  uvm_severity_type sev_type;
  string prefix, time_str, code_str, fill_char, file_str, hier_str;
  int last_slash, flen, hier_len;

  function new(string name="custom_report_server");
    super.new(name);
  endfunction : new


`ifndef UVM_1p1d
      virtual function string compose_report_message (uvm_report_message report_message,
                                                      string report_object_name = "");
         uvm_severity severity;
         uvm_verbosity l_verbosity;
         uvm_report_message_element_container el_container;
         uvm_report_handler l_report_handler;
         string                                              message = "";
         string                                              filename = "";
         int                                             line;
         string                                              id = "";
         string                                              sev_string = "";
  if (report_object_name == "") begin
                  l_report_handler = report_message.get_report_handler();
                  report_object_name = l_report_handler.get_full_name();
  end
   severity = report_message.get_severity();
   sev_string = severity.name();       
   id = report_message.get_id();
    el_container = report_message.get_element_container();
               if (el_container.size() == 0)
                 message = report_message.get_message();
               else begin
                  prefix = uvm_default_printer.knobs.prefix;
                  uvm_default_printer.knobs.prefix = " +";
                  message = {report_message.get_message(), "\n", el_container.sprint()};
                  uvm_default_printer.knobs.prefix = prefix;
               end
   filename = report_message.get_filename();
   line = report_message.get_line();

`else
  virtual function string compose_message(uvm_severity severity, string name, string id, string message, string filename, int line);

`endif // !`ifndef UVM_1p1d

    // format filename & line-number
    last_slash = filename.len() - 1;
    //$display("AT %t,ORIGINAL filename =%s : Length =%0d ",$time,filename,last_slash);
    if(file_name_width > 0) begin
       if(filename_cache.exists(filename)) begin
         file_str = filename_cache[filename];
       end else begin
          while(filename[last_slash] != "/" && last_slash >= 0) begin
            last_slash--;
          end
          file_str = (filename[last_slash] == "/") ? filename.substr(last_slash+1, filename.len()-1) : filename;
          flen = file_str.len();
          file_str = (flen > file_name_width) ? file_str.substr(0, file_name_width-1) : {{(file_name_width-flen){" "}}, file_str};
          filename_cache[filename] = file_str;
       end
       //$display("AT %t,NEW file_str=%s  ",$time,file_str);
       $swrite(file_str, "(%s:%6d) ", file_str, line);
    end else begin
      file_str = "";
    end
    // format hier
    hier_len = id.len();
    if(hier_len > 13 && id.substr(0,12) == "uvm_test_top.") begin
       id = id.substr(13, hier_len-1);
       hier_len -= 13;
    end
    if (hier_len < hier_width) begin
       hier_str = {id, {(hier_width - hier_len){" "}}};
    end else if(hier_len > hier_width) begin
      hier_str = id.substr(hier_len - hier_width, hier_len - 1);
    end else begin
      hier_str = id;
    end
    hier_str = {"[", hier_str, "]"};
    hier_cache[id] = hier_str;

    // format time
    $swrite(time_str, "{%9t}", $time);

    // determine fill character
    sev_type = uvm_severity_type'(severity);
    // Customize the strings for the different severity of messages (ARSENAL parses transcript for these)
    case(sev_type)
      UVM_INFO:    begin code_str = "**    NOTE:"; fill_char = " "; end
      UVM_ERROR:   begin code_str = "**   ERROR:"; fill_char = " "; end
      UVM_WARNING: begin code_str = "** WARNING:"; fill_char = " "; end
      UVM_FATAL:   begin code_str = "**   FATAL:"; fill_char = " "; end
      default:     begin code_str = "%?"; fill_char = "?"; end
    endcase

    // create line's prefix (everything up to time)
    $swrite(prefix, "%s-%s%s%s", code_str, file_str, hier_str, time_str);
    
    if(fill_char != " ") begin
       for(int x = 0; x < prefix.len(); x++)
         if(prefix[x] == " ")
           prefix.putc(x, byte'(fill_char));
    end

    // append message
    return {prefix, " ", message};
  endfunction// : compose_message

endclass //: testbench_report_server_c

`else
class custom_report_server extends uvm_report_server;
  `uvm_object_utils(custom_report_server)

  string filename_cache[string];
  string hier_cache[string];

  int unsigned file_name_width = 22;
  int unsigned hier_width = 22;

  uvm_severity_type sev_type;
  string prefix, time_str, code_str, fill_char, file_str, hier_str;
  int last_slash, flen, hier_len;

  function new(string name="custom_report_server");
    super.new();
  endfunction : new

  virtual function string compose_message(uvm_severity severity, string name, string id, string message, string filename, int line);
    // format filename & line-number
    last_slash = filename.len() - 1;
    //$display("AT %t,ORIGINAL filename =%s : Length =%0d ",$time,filename,last_slash);
    if(file_name_width > 0) begin
       if(filename_cache.exists(filename)) begin
         file_str = filename_cache[filename];
       end else begin
          while(filename[last_slash] != "/" && last_slash >= 0) begin
            last_slash--;
          end
          file_str = (filename[last_slash] == "/") ? filename.substr(last_slash+1, filename.len()-1) : filename;
          flen = file_str.len();
          file_str = (flen > file_name_width) ? file_str.substr(0, file_name_width-1) : {{(file_name_width-flen){" "}}, file_str};
          filename_cache[filename] = file_str;
       end
       //$display("AT %t,NEW file_str=%s  ",$time,file_str);
       $swrite(file_str, "(%s:%6d) ", file_str, line);
    end else begin
      file_str = "";
    end
    // format hier
    hier_len = id.len();
    if(hier_len > 13 && id.substr(0,12) == "uvm_test_top.") begin
       id = id.substr(13, hier_len-1);
       hier_len -= 13;
    end
    if (hier_len < hier_width) begin
       hier_str = {id, {(hier_width - hier_len){" "}}};
    end else if(hier_len > hier_width) begin
      hier_str = id.substr(hier_len - hier_width, hier_len - 1);
    end else begin
      hier_str = id;
    end
    hier_str = {"[", hier_str, "]"};
    hier_cache[id] = hier_str;

    // format time
    $swrite(time_str, "{%9t}", $time);

    // determine fill character
    sev_type = uvm_severity_type'(severity);
    // Customize the strings for the different severity of messages (ARSENAL parses transcript for these)
    case(sev_type)
      UVM_INFO:    begin code_str = "** NOTE:"; fill_char = " "; end
      UVM_ERROR:   begin code_str = "** ERROR:"; fill_char = " "; end
      UVM_WARNING: begin code_str = "** WARNING:"; fill_char = " "; end
      UVM_FATAL:   begin code_str = "** FATAL:"; fill_char = " "; end
      default:     begin code_str = "%?"; fill_char = "?"; end
    endcase

    // create line's prefix (everything up to time)
    $swrite(prefix, "%s-%s%s%s", code_str, file_str, hier_str, time_str);
    
    if(fill_char != " ") begin
       for(int x = 0; x < prefix.len(); x++)
         if(prefix[x] == " ")
           prefix.putc(x, byte'(fill_char));
    end

    // append message
    return {prefix, " ", message};
  endfunction// : compose_message

  // Function: summarize
  //
  // See <uvm_report_object::report_summarize> method.

  virtual function void summarize(UVM_FILE file=0);
    string id;
    string name;
    string output_str;
    uvm_report_catcher::summarize_report_catcher(file);
    f_display(file, "");
    f_display(file, "--- UVM Report Summary ---");
    f_display(file, "");

    if (enable_report_id_count_summary) begin

      f_display(file, "** Report counts by id");
      for(int found = id_count.first(id);
           found;
           found = id_count.next(id)) begin
        int cnt;
        cnt = id_count[id];
        $sformat(output_str, "[%s] %5d", id, cnt);
        f_display(file, output_str);
      end

    end

    if(get_max_quit_count() != 0) begin
      if ( get_quit_count() >= get_max_quit_count() ) f_display(file, "Quit count reached!");
      if (get_quit_count() == 0 ) f_display(file, $sformatf("\nSIMULATION PASS : QUIT COUNT == 0!"));
      $sformat(output_str, "\nQuit count : %5d of %5d", get_quit_count(), get_max_quit_count());
      f_display(file, output_str);
    end

    f_display(file, "** Report counts by severity");
    for(uvm_severity_type s = s.first(); 1; s = s.next()) begin
      int cnt;
      cnt = get_severity_count(s);
      name = s.name();
      $sformat(output_str, "%s :%5d", name, cnt);
      f_display(file, output_str);
      if(s == s.last()) break;
    end

  endfunction
endclass //: testbench_report_server_c



        
class small_report_server extends uvm_report_server;
     `uvm_object_utils(small_report_server)

  function new(string name="small_report_server");
      super.new();
   endfunction// : new
   
   virtual function string compose_message( uvm_severity severity,
                                            string name,
                                            string id,
                                            string message,
                                            string filename,
                                            int line );
      uvm_severity_type severity_type = uvm_severity_type'( severity );
      return $psprintf( "%-8s | %16s | %2d | %0t | %-21s | %-7s | %s",
             severity_type.name(), filename, line, $time, name, id, message );
   endfunction: compose_message
endclass//: small_report_server


`endif // !`ifdef UVM_POST_VERSION_1_1


`endif // _CUSTOM_REPORT_SERVER_SVH_
