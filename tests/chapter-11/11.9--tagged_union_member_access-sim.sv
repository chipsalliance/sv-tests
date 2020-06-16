/*
:name: tagged_union_member_access_sim
:description: tagged union member access simulation test
:type: simulation parsing
:tags: 11.9
*/
module top();

typedef union tagged {
	void Invalid;
	int Valid;
} u_int;

u_int a;

int b;

initial begin
	a = tagged Valid(42);
	b = a.Valid;
    $display(":assert: (42 == %d)", b);
end

endmodule
