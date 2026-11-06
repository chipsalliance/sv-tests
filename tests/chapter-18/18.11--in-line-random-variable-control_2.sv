// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: in-line_random_variable-control_2
:description: randomize(variable_identifier_list) should hold other rand variables as state
:tags: 18.11
:unsynthesizable: 1
*/

class a;
    rand int x;
    rand int y;
endclass

module top;

    a obj = new;
    int y_before;
    int ok;

    initial begin
        obj.x = 5;
        obj.y = 100;
        y_before = obj.y;
        ok = obj.randomize(x);

        if (ok == 1 && obj.y == y_before) begin
            $display("x=%0d y_before=%0d y_after=%0d SUCCESS", obj.x, y_before, obj.y);
        end else begin
            $display("x=%0d y_before=%0d y_after=%0d FAILED -- randomize(x) changed y",
                obj.x, y_before, obj.y);
        end
    end

endmodule
