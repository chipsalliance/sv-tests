// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: illegal_implements_parameter
:description: implementing parameter that resolves to an interface class is not allowed
:should_fail_because: implementing parameter that resolves to an interface class is not allowed
:tags: 8.26.4
:type: simulation elaboration
*/
module class_tb ();
	interface class ihello;
		typedef int int_t;
		pure virtual function void hello(int_t val);
	endclass

	class Hello #(type T = ihello) implements T;
		virtual function void hello(ihello::int_t val);
			$display("hello world %d", val);
		endfunction
	endclass

	Hello obj;

	initial begin
		obj = new;
		obj.hello();
	end
endmodule
