// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: event_sequence
:description: sequence event test
:tags: 9.4.2.4
:type: simulation elaboration parsing
:unsynthesizable: 1
*/
module seq_tb ();
	logic a = 0;
	logic b = 0;
	logic c = 0;
	logic y = 0;
	logic clk = 0;

	sequence seq;
		@(posedge clk) a ##1 b ##1 c;
	endsequence

	initial begin
		fork
			begin
				@seq y = 1;
				$display(":assert:(True)");
			end
			begin
				a = 1;
				#10 clk = 1;
				#10 clk = 0;
				b = 1;
				#10 clk = 1;
				#10 clk = 0;
				c = 1;
				#10 clk = 1;
				#10 clk = 0;
			end
		join
	end
endmodule
