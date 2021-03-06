/*
:name: type_op_compare
:description: type comparison tests
:tags: 6.23
*/
module top #( parameter type T = type(logic[11:0]) )
   ();
   initial begin
      case (type(T))
        type(logic[11:0]) : ;
        default           : $stop;
      endcase
      if (type(T) == type(logic[12:0])) $stop;
      if (type(T) != type(logic[11:0])) $stop;
      if (type(T) === type(logic[12:0])) $stop;
      if (type(T) !== type(logic[11:0])) $stop;
      $finish;
   end
endmodule
