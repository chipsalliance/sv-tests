/*
:name: 22.5.1--define_expansion_7
:description: Test
:should_fail_because: To use a macro defined with arguments, the name of the text macro shall be followed by a list of actual arguments in parentheses, separated by commas.
:tags: 22.5.1
:type: preprocessing
*/
`define D(x,y) initial $display("start", x , y, "end");
`D()
