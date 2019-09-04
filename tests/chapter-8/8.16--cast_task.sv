/*
:name: cast_task
:description: $cast task test
:should_fail: 0
:tags: 8.16
*/
module class_tb ();
	typedef enum { aaa, bbb, ccc, ddd, eee } values;
	initial begin
		values val;
		$cast(val, 3);
		$display(val);
	end
endmodule
