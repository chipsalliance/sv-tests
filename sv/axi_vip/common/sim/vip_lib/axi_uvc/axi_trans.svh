// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_TRANS_SVH_
`define _AXI_TRANS_SVH_

class axi_trans extends uvm_sequence_item;
   `uvm_object_utils(axi_trans)

   string tID;

   rand axi_trans_type   ttype;

   rand int unsigned     id, addr, len;
   rand wr_data_type     wr_data = RAND;
   bit [2:0]             size;
   bit [1:0]             burst;
   bit [3:0]             cache;
   bit [2:0]             prot;
   bit [3:0]             qos;
   bit [3:0]             region;

   int unsigned          awuser, wuser[$], buser, aruser, ruser[$];

   rand bit[7:0]         data[$];
   rand bit              wstrb[$];
   bit [1:0]             bresp, rresp[$];

   bit [7:0]             data_val;

   constraint data_c {
      solve len before data;
      solve wr_data before data;
      data.size == (len+1)*get_width(size);
      wstrb.size == (len+1)*get_width(size);
      if (wr_data == RAND)
         foreach(data[i]) {
            data[i] inside { [0 : 255] };
            wstrb[i] == 1'b1;
         }
      else if (wr_data == CONST)
         foreach(data[i]) {
            data[i] == data_val;
            wstrb[i] == 1'b1;
         }
      else //(wr_data = INCR)
         foreach(data[i]) {
            if (i == 0)
               data[i] == data_val;
            else
               data[i] == data[i-1] + 1;
            wstrb[i] == 1'b1;
         }
   }

   function new(string name = "axi_trans");
      super.new(name);

      tID = get_full_name();
      tID = tID.toupper();
   endfunction

   function void set_size(int unsigned width);
      case (width)
         1   : size = 3'b000;
         2   : size = 3'b001;
         4   : size = 3'b010;
         8   : size = 3'b011;
         16  : size = 3'b100;
         32  : size = 3'b101;
         64  : size = 3'b110;
         128 : size = 3'b111;
         default : `uvm_info(tID, $sformatf("set_size: Invalid width (%0d)", width), UVM_MEDIUM)
      endcase
   endfunction

   function int unsigned get_width(int unsigned size);
      int unsigned   width;

      case (size)
         0   : width = 1;
         1   : width = 2;
         2   : width = 4;
         3   : width = 8;
         4   : width = 16;
         5   : width = 32;
         6   : width = 64;
         7   : width = 128;
         default : `uvm_info(tID, $sformatf("get_width: Invalid size (%0d)", size), UVM_MEDIUM)
      endcase

     return(width);
   endfunction

   //--------------------------------------------------------------------
   // do_copy
   //--------------------------------------------------------------------
   virtual function void do_copy(uvm_object rhs);
      axi_trans   rhs_;
      $cast(rhs_, rhs);
      super.do_copy(rhs);

      this.ttype      = rhs_.ttype;
      this.id         = rhs_.id;
      this.addr       = rhs_.addr;
      this.len        = rhs_.len;
      this.size       = rhs_.size;
      this.burst      = rhs_.burst;
      this.cache      = rhs_.cache;
      this.prot       = rhs_.prot;
      this.qos        = rhs_.qos;
      this.region     = rhs_.region;

      this.awuser     = rhs_.awuser;
      this.wuser      = rhs_.wuser;
      this.buser      = rhs_.buser;
      this.aruser     = rhs_.aruser;
      this.ruser      = rhs_.ruser;

      this.data       = rhs_.data;
      this.wstrb      = rhs_.wstrb;
      this.bresp      = rhs_.bresp;
      this.rresp      = rhs_.rresp;
   endfunction

   //--------------------------------------------------------------------
   // do_compare
   //--------------------------------------------------------------------
   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      axi_trans   rhs_;
      $cast(rhs_, rhs);

      do_compare = 1;

      if (id != rhs_.id) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: id = %0h, rhs_.id = %0h", id, rhs_.id), UVM_NONE)
      end
      if (addr != rhs_.addr) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: addr = %0h, rhs_.addr = %0h", addr, rhs_.addr), UVM_NONE)
      end
      if (len != rhs_.len) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: len = %0d, rhs_.len = %0d", len, rhs_.len), UVM_NONE)
      end
      if (size != rhs_.size) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: size = %0d, rhs_.size = %0d", size, rhs_.size), UVM_NONE)
      end
      if (burst != rhs_.burst) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: burst = %0d, rhs_.burst = %0d", burst, rhs_.burst), UVM_NONE)
      end
      if (cache != rhs_.cache) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: cache = %h, rhs_.cache = %h", cache, rhs_.cache), UVM_NONE)
      end
      if (prot != rhs_.prot) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: prot = %h, rhs_.prot = %h", prot, rhs_.prot), UVM_NONE)
      end
      if (qos != rhs_.qos) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: qos = %h, rhs_.qos = %h", qos, rhs_.qos), UVM_NONE)
      end
      if (region != rhs_.region) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: region = %h, rhs_.region = %h", region, rhs_.region), UVM_NONE)
      end
      if (awuser != rhs_.awuser) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: awuser = %0h, rhs_.awuser = %0h", awuser, rhs_.awuser), UVM_NONE)
      end
      if (wuser != rhs_.wuser) begin
         do_compare = 0;
         if (wuser.size() != rhs_.wuser.size()) begin
            `uvm_info(tID,$sformatf("MISCMP: wuser.size = %0d, rhs_.wuser.size = %0d", wuser.size(), rhs_.wuser.size()), UVM_NONE)
            `uvm_info(tID,$sformatf("        wuser      = %p", wuser), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.wuser = %p", rhs_.wuser), UVM_NONE)
         end
         else begin
            `uvm_info(tID,$sformatf("        wuser      = %p", wuser), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.wuser = %p", rhs_.wuser), UVM_NONE)
         end
      end
      if (buser != rhs_.buser) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: buser = %0h, rhs_.buser = %0h", buser, rhs_.buser), UVM_NONE)
      end
      if (aruser != rhs_.aruser) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: aruser = %0h, rhs_.aruser = %0h", aruser, rhs_.aruser), UVM_NONE)
      end
      if (ruser != rhs_.ruser) begin
         do_compare = 0;
         if (ruser.size() != rhs_.ruser.size()) begin
            `uvm_info(tID,$sformatf("MISCMP: ruser.size = %0d, rhs_.ruser.size = %0d", ruser.size(), rhs_.ruser.size()), UVM_NONE)
            `uvm_info(tID,$sformatf("        ruser      = %p", ruser), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.ruser = %p", rhs_.ruser), UVM_NONE)
         end
         else begin
            `uvm_info(tID,$sformatf("        ruser      = %p", ruser), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.ruser = %p", rhs_.ruser), UVM_NONE)
         end
      end
      if (data != rhs_.data) begin
         do_compare = 0;
         if (data.size() != rhs_.data.size()) begin
            `uvm_info(tID,$sformatf("MISCMP: data.size = %0d, rhs_.data.size = %0d", data.size(), rhs_.data.size()), UVM_NONE)
            `uvm_info(tID,$sformatf("        data      = %p", data), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.data = %p", rhs_.data), UVM_NONE)
         end
         else begin
            `uvm_info(tID,$sformatf("        data      = %p", data), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.data = %p", rhs_.data), UVM_NONE)
         end
      end
      if (wstrb != rhs_.wstrb) begin
         do_compare = 0;
         if (wstrb.size() != rhs_.wstrb.size()) begin
            `uvm_info(tID,$sformatf("MISCMP: wstrb.size = %0d, rhs_.wstrb.size = %0d", wstrb.size(), rhs_.wstrb.size()), UVM_NONE)
            `uvm_info(tID,$sformatf("        wstrb      = %p", wstrb), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.wstrb = %p", rhs_.wstrb), UVM_NONE)
         end
         else begin
            `uvm_info(tID,$sformatf("        wstrb      = %p", wstrb), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.wstrb = %p", rhs_.wstrb), UVM_NONE)
         end
      end
      if (bresp != rhs_.bresp) begin
         do_compare = 0;
         `uvm_info(tID,$sformatf("MISCMP: bresp = %0h, rhs_.bresp = %0h", bresp, rhs_.bresp), UVM_NONE)
      end
      if (rresp != rhs_.rresp) begin
         do_compare = 0;
         if (rresp.size() != rhs_.rresp.size()) begin
            `uvm_info(tID,$sformatf("MISCMP: rresp.size = %0d, rhs_.rresp.size = %0d", rresp.size(), rhs_.rresp.size()), UVM_NONE)
            `uvm_info(tID,$sformatf("        rresp      = %p", rresp), UVM_NONE)
          `uvm_info(tID,$sformatf("        rhs_.rresp = %p", rhs_.rresp), UVM_NONE)
         end
         else begin
            `uvm_info(tID,$sformatf("        rresp      = %p", rresp), UVM_NONE)
            `uvm_info(tID,$sformatf("        rhs_.rresp = %p", rhs_.rresp), UVM_NONE)
         end
      end
   endfunction

   function string convert2string();
      string   str1;

      str1 = {str1,"\n\n******************** AXI transaction ********************\n"
              ,$sformatf("ttype      : %s  \n", ttype.name())
              ,$sformatf("id         : %h  \n", id)
              ,$sformatf("addr       : %0h \n", addr)
              ,$sformatf("len        : %0d \n", len)
              ,$sformatf("size       : %h  \n", size)
              ,$sformatf("burst      : %0d \n", burst)
              ,$sformatf("cache      : %h  \n", cache)
              ,$sformatf("prot       : %h  \n", prot)
              ,$sformatf("qos        : %h  \n", qos)
              ,$sformatf("region     : %h  \n", region)
              ,$sformatf("awuser     : %0h \n", awuser)
              ,$sformatf("buser      : %0h \n", buser)
              ,$sformatf("aruser     : %0h \n", aruser)
              ,$sformatf("bresp      : %b  \n", bresp)};

      for (int i=0; i<data.size()/get_width(size); i++) begin
         for (int j=0; j<get_width(size); j++) begin
            if (j == 0)
               str1 = {str1, $sformatf("\nbeat[%2d] : data : %h", i, data[(i*get_width(size))+j])};
            else if (j == get_width(size)-1)
               str1 = {str1, $sformatf(" %h\n", data[(i*get_width(size))+j])};
            else
               str1 = {str1, $sformatf(" %h", data[(i*get_width(size))+j])};
         end

         if (wstrb.size())
            for (int j=0; j<=get_width(size)-1; j++) begin
               if (j == 0)
                  str1 = {str1, $sformatf("           wstrb:  %b", wstrb[(i*get_width(size))+j])};
               else if (j == get_width(size)-1)
                  str1 = {str1, $sformatf("  %b\n", wstrb[(i*get_width(size))+j])};
               else
                  str1 = {str1, $sformatf("  %b", wstrb[(i*get_width(size))+j])};
            end

         if (rresp.size())
            str1 = {str1, $sformatf("           rresp: %b\n", rresp[i])};
      end

      str1 = {str1, "*********************************************************\n"};
      return(str1);
   endfunction

endclass
`endif
