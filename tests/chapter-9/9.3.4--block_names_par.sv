/*
:name: block_names_par
:description: parallel block names check
:tags: 9.3.4
*/
module block_tb ();
	reg a = 0;
	initial
		fork: name
			a = 1;
		join: name
endmodule
