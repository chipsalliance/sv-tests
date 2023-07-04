// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: parameter_type_conflict_unresolved
:description: superclass type declaration conflicts must be resolved in subclass
:should_fail_because: superclass type declaration conflicts must be resolved in subclass
:tags: 8.26.6.2
:type: simulation elaboration
*/
module class_tb ();
	interface class ic1#(type T = logic);
		pure virtual function void fn1(T a);
	endclass

	interface class ic2#(type T = logic);
		pure virtual function void fn2(T a);
	endclass
	
	interface class ic3#(type TYPE = logic) extends ic1#(TYPE), ic2#(TYPE);
	endclass
endmodule
