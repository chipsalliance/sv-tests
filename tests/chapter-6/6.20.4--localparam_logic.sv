/*
:name: localparam_logic
:description: localparam with logic type
:tags: 6.20.4
*/
module top();
	localparam [10:0] p = 1 << 5;
	localparam logic [10:0] q = 1 << 5;
endmodule
