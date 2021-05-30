// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: sanity
:description: A simple module that should fail during parsing
:should_fail_because: syntax error, fails during parsing
:tags: sanity
*/
module sanity_tb (
	clk,
	out
);
	input clk;
	output out;
syntaxerror
	wire clk;
	reg out;

	reg [31:0] sum = 0;

	always @(posedge clk) begin
		if(sum >= 21) begin
			out <= 1;
			sum <= 0;
		end else begin
			out <= 0;
			sum <= sum + 1;
		end
	end
endmodule
