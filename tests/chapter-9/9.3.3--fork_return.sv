/*
:name: fork_return
:description: illegal return from fork
:should_fail_because: illegal return from fork
:tags: 9.3.3
:type: simulation
*/
module block_tb ();
	task fork_test;
		fork
			#20;
			return;
		join_none
	endtask
endmodule
