// Use of this source code is governed by an ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC

/*
:name: always_comb_static_function_local_fail
:description: multiple always_comb processes write a static function local (13.4.2 Static and automatic functions)
:should_fail_because: a variable written by an always_comb procedure, including in a called function, cannot be written by another process
:tags: 9.2.2.2
:type: elaboration
:top_module: always_tb
*/
module always_tb (
	input logic a, b,
	output logic y, z
);
	// Module functions default to static lifetime, sharing tmp across calls.
	function logic helper(input logic x);
		logic tmp;
		tmp = x;
		return tmp;
	endfunction

	always_comb y = helper(a);
	always_comb z = helper(b);
endmodule
