/*
:name: named_event_trigger_blocking
:description: Trigger named event, blocking
:tags: 15.5
:top_module: top
*/


module inner();
	initial 
		-> top.e;
endmodule

module top();

event e;

initial begin
	// Normal trigger
	-> e;
	// Nonblocking trigger
	->> e; 
end

endmodule

class foo;

	event e;
	
	task wait_e();
		->e;
	endtask;

endclass

