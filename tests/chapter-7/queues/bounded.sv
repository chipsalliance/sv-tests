// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: bounded-queues
:description: Test bounded queues support
:tags: 7.10.5 7.10 7.10.2.7 7.10.2.1
:type: simulation elaboration parsing
*/
module top ();

int q[$:2]; // 3 elements

initial begin
	q.push_back(1);
	q.push_back(2);
	q.push_back(3);
	$display(":assert: ((%d == 1) and (%d == 2) and (%d == 3))",
		q[0], q[1], q[2]);

	$display(":re: BEGIN:QUEUE_FULL"); // expect warning
	q.push_back(4);
	$display(":re: END");
	$display(":assert: (%d==3)", q.size);
end

endmodule
