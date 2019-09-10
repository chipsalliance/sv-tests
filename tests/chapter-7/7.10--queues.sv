/*
:name: queues
:description: Test queues support
:should_fail: 0
:tags: 7.10
*/
module top ();

int q[$]; // 7.10
int ql[$:5]; // 7.10
int qc[$]; // 7.10.

initial begin
	$display(":assert:7.10.2.1: (%d==0)", q.size);
	q.insert(0, 3);
	$display(":assert:7.10.2.1: (%d==1)", q.size);
	q.insert(1, 6);
	$display(":assert:7.10.2.1: (%d==2)", q.size);
	$display(":assert:7.10.2.2: (%d==6)", q[1]);
	$display(":assert:7.10.2.2: (%d==3)", q[0]);

	q.push_back(10);
	$display(":assert:7.10.2.7: (%d==3)", q.size);
	$display(":assert:7.10.2.7: (%d==10)", q[2]);

	q.push_front(20);
	$display(":assert:7.10.2.6: (%d==4)", q.size);
	$display(":assert:7.10.2.6: (%d==20)", q[0]);

	q.push_front(30);
	q.push_front(31);
	$display(":assert:7.10.2.4: (%d==31)", q.pop_front());
	$display(":assert:7.10.2.4: (%d==30)", q.pop_front());

	q.push_back(40);
	q.push_back(41);
	$display(":assert:7.10.2.5: (%d==41)", q.pop_back());
	$display(":assert:7.10.2.5: (%d==40)", q.pop_back());

	// delete one element
	q.delete(0);
	$display(":assert:7.10.2.3: (%d==3)", q.size);

	// delete all
	q.delete;
	$display(":assert:7.10.2.3: (%d==0)", q.size);

	// test queue with max size
	ql.push_back(1);
	ql.push_back(2);
	ql.push_back(3);
	ql.push_back(4);
	ql.push_back(5);
	ql.push_back(6);
	$display(":re:7.10.5: BEGIN:QUEUE_FULL"); // expect warning
	ql.push_back(7);
	$display(":re:7.10.5: END");
	$display(":assert:7.10.5: (%d==6)", ql.size);

	// 7.10.4
	qc = { qc, 1 }; // q.push_back(1)
	$display(":assert:7.10.4: (%d==1)", qc[0]);
	qc = { 16, qc }; // q.push_front(16)
	$display(":assert:7.10.4: (%d==16)", qc[0]);

	qc = { qc[0], 7, qc[1] }; // q.insert(1, 7)
	$display(":assert:7.10.4: ((%d==3) and (%d==7))", qc.size, qc[1]);

	qc = {}; // q.delete
	$display(":assert:7.10.4: (%d==0)", qc.size);
end

endmodule
