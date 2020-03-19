/*
:name: 22.5.1--define_expansion_18
:description: Test
:should_fail_because: For a macro with arguments, the parentheses are always required in the macro call, even if all the arguments have defaults. 
:tags: 22.5.1
:type: preprocessing
*/
`define MACRO3(a=5, b=0, c="C") initial $display(a,,b,,c);
module top ();
`MACRO3
endmodule
