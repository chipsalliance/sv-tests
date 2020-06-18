/*
:name: delay_control_sim
:description: delay control simulation
:tags: 9.4.1
:type: simulation
*/
module top();

   initial begin
      $display(":assert: (0 == %d)", $time);

      #10;
      $display(":assert: (10 == %d)", $time);

      #10;
      $display(":assert: (20 == %d)", $time);

      #10;
      $display(":assert: (30 == %d)", $time);

      $finish;
   end
endmodule
