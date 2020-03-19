/*
:name: enum_value_inv
:description: Tests that tools diagnose invalid enum value assignments
:should_fail_because: Tests that tools diagnose invalid enum value assignments
:tags: 6.19
*/
module top();
	// 6.19 says:
	// If the integer value expression is a sized literal constant, it shall
	// be an error if the size is different from the enum base type, even if
	// the value is within the representable range.
	enum logic [2:0] {
	  Global = 4'h2,
	  Local = 4'h3
	} myenum;
endmodule
