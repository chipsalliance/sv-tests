// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: abstract_class_inst
:description: instantiating abstract class
:should_fail_because: instantiating abstract class
:tags: 8.21
:type: simulation elaboration
*/
module class_tb ();
	virtual class base_cls;
		pure virtual function void print();
	endclass

	class test_cls extends base_cls;
		int a = 2;
		virtual function void print();
			$display(a);
		endfunction
	endclass

	base_cls test_obj;

	initial begin
		test_obj = new;

		test_obj.print();
	end
endmodule
