// SPDX-License-Identifier: Apache-2.0
/*
:name: unpacked_multidim_array
:description: Verifies that tools correctly parse and manipulate multi-dimensional unpacked arrays.
:tags: 7.4
*/
module top;
    int grid [2][3]; // 2 rows, 3 columns unpacked array

    initial begin
        grid[0][0] = 32'hA5A5A5A5;
        grid[1][2] = 32'h5A5A5A5A;
    end
endmodule