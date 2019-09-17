/*
:name: push_front
:description: Test queues push_front function support
:should_fail: 0
:tags: 7.10.2.6 7.10.2
*/
module top ();

int q[$];

initial begin
	q.push_front(2);
	q.push_front(3);
	q.push_front(4);
	$display(":assert: (%d == 3)", q.size);
	$display(":assert: (%d == 4)", q[0]);
end

endmodule
