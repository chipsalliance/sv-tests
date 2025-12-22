// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: unpack_stream_pad_sim
:description: padded stream unpack simulation test
:type: simulation elaboration parsing
:tags: 11.4.14.3
*/
module top();

int a = 1;
int b = 2;
int c = 3;

bit ok;

initial begin
    bit [127:0] d = {<< 32 {a, b, c}};
    ok = d == 128'h00000003_00000002_00000001_00000000;
    $display(":assert: (%0d == %0d)", ok, 1);
end

endmodule
