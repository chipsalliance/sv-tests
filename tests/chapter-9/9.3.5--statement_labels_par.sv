/*
:name: statement_labels_par
:description: parallel block labels check
:tags: 9.3.5
*/
module block_tb ();
	reg a = 0;
	initial
		name: fork
			a = 1;
		join: name
endmodule
