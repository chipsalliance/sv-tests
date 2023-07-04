// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: fwrite_task
:description: $fwrite test
:tags: 21.3
:type: simulation elaboration parsing
*/
module top();

int fd;
string str = "abc";

initial begin
	fd = $fopen("tmp.txt", "w");
	$fwrite(fd, str);
end

final
	$fclose(fd);

endmodule
