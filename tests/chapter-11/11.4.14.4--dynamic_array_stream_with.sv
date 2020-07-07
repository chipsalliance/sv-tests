/*
:name: dynamic_array_unpack_stream_with
:description: stream unpack test with dynamic array using with
:tags: 11.4.14.4
*/
module top();

int i_header;
int i_len;
byte i_data[];
int i_crc;

int o_header;
int o_len;
byte o_data[];
int o_crc;

initial begin
	byte pkt[$];

	i_header = 12;
	i_len = 5;
	i_data = new[5];
	i_crc = 42;

	pkt = {<< 8 {i_header, i_len, i_data, i_crc}};

	{<< 8 {o_header, o_len, o_data with [0 +: o_len], o_crc}} = pkt;
end

endmodule
