/*
:name: class_member_test_33
:description: Test
:should_fail: 0
:tags: 8.3
*/
class myclass;
function void shifter;
  for (int shft_idx=0; shft_idx < n_bits;
       shft_idx++, data.width--) begin
    dout = {dout} << 1;
  end
endfunction
endclass