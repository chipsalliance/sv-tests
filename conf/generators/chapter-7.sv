// :type: basic
// :tags: 7
// :should_fail: 0
// :desc: struct
// :steps: syntax
// :flags: wrap_module

// ---------- section 7.1 ---------
// :tags: 7.1
// :desc: general

// :description: Test support of structures
// :begin: struct
struct { int i1; int i2; } st;
// :end:


// :description: Test support of unions
// :begin: union
union { int i; real f; } un;
// :end:

// :description: Test support of packed arrays
// :begin: packed-array
bit [7:0] arr;
// :end:

// :description: Test support of unpacked arrays
// :begin: unpacked-array
bit arr [7:0];
// :end:

// :description: Test support of dynamic arrays
// :begin: dynamic-array
bit arr[];
// :end:

// :description: Test support of associative arrays
// :begin: assoc-array
integer arr [ string ];
// :end:

// :description: Test support of queues
// :begin: queue
int q[$];
// :end:

// :description: Test support of array operations
// :begin: array-query-left
int arr [2] = { 2, 1 };
int i;

initial
	i = $left(arr);
// :end:

// :description: Test support of array methods
// :begin: array-manipulation
int arr [2] = { 2, 1 };

initial
	arr.sort;
// :end:

// ---------- section 7.2 ---------
// :tags: 7.2
// :description: Test support of unpacked structures

// :begin: anon
struct { bit[7:0] opcode; bit [23:0] addr; } IR;
// :end:

// :begin: named
typedef struct {
	bit [7:0] opcode;
	bit [23:0] addr;
} instruction;
// :end:

// :begin: named-variable
typedef struct {
	bit [7:0] opcode;
	bit [23:0] addr;
} instruction;

instruction IR;
// :end:

// :tags: 7.2.1
// :description: Test packed structures

// :begin: anon-packed-2-state
struct packed {
	int a;
	shortint b;
	byte c;
	bit [7:0] d;
} pack1; // 2-state
// :end:

// :begin: anon-packed-4-state
struct packed {
	time a;
	integer b;
	logic [31:0] c;
} pack1; // 4-state
// :end:

// :description: Test packed structures signing

// :begin: anon-packed-signed
struct packed signed {
	int a;
	shortint b;
	byte c;
	bit [7:0] d;
} pack1;
// :end:

// :begin: anon-packed-unsigned
struct packed unsigned {
	int a;
	shortint b;
	byte c;
	bit [7:0] d;
} pack1;
// :end:

// :description: Test named and packed structures

// :begin: named-packed
typedef struct packed {
	bit [3:0] GFC;
	bit [7:0] VPI;
	bit [11:0] VCI;
	bit CLP;
	bit [3:0] PT ;
	bit [7:0] HEC;
	bit [47:0] [7:0] Payload;
	bit [2:0] filler;
} s_atmcell;
// :end:

// :description: Test named and packed structures signing

// :begin: named-packed-signed
typedef struct packed signed {
	bit [3:0] GFC;
	bit [7:0] VPI;
	bit [11:0] VCI;
	bit CLP;
	bit [3:0] PT ;
	bit [7:0] HEC;
	bit [47:0] [7:0] Payload;
	bit [2:0] filler;
} s_atmcell;
// :end:

// :begin: named-packed-unsigned
typedef struct packed unsigned {
	bit [3:0] GFC;
	bit [7:0] VPI;
	bit [11:0] VCI;
	bit CLP;
	bit [3:0] PT ;
	bit [7:0] HEC;
	bit [47:0] [7:0] Payload;
	bit [2:0] filler;
} s_atmcell;
// :end:

// -------- section 7.2.2 -------
// :tags: 7.2.2
// :desc: assign
// :description: Test support of structures assignation

// :desc: assign-unpacked

// :begin: initial
parameter constant = 2;

typedef struct {
	int addr = 1 + constant;
	int crc;
	byte data [4] = '{4{1}};
} packet1;
// :end:

// :begin: explicit
typedef struct {
	int addr;
	int crc;
	byte data [4];
} packet1;

packet1 p1 = '{1,2,'{2,3,4,5}};
// :end:

// Do not test constant assignement in packed structures because:
// "Members of unpacked structures containing a union as well"
// "as members of packed structures shall not be assigned"
// "individual default member values."

// There is no info about defining packed array with size instead of range
// so we use ranges (e.g. bit [3:0] data instead of size bit [4] data)

// Also:
// Only packed data types and the integer data types summarized in
// Table 6-8 (see 6.11) shall be legal in packed structures:
//  shortint, int, longint, byte, bit, logic, reg, integer, time

// :desc: assign-packed

// :begin: explicit
typedef struct packed {
	int addr;
	int crc;
	bit [3:0] data;
} packet1;

packet1 p1 = '{1,2,'{1,0,0,1}};
// :end:

// :desc: assign-packed-signed

// :begin: explicit
typedef struct packed signed {
	int addr;
	int crc;
	bit [3:0] data;
} packet1;

packet1 p1 = '{1,2,'{1,0,0,1}};
// :end:

// :desc: assign-packed-unsigned

// :begin: explicit
typedef struct packed unsigned {
	int addr;
	int crc;
	bit [3:0] data;
} packet1;

packet1 p1 = '{1,2,'{1,1,0,0}};
// :end:

// -------- 7.3 ------------
// :tags: 7.3
// :description: Test support of unions
// :desc: union

// TODO: test union + struct

// :begin: anon
union {
	int i;
	real f;
} n;
// :end:

// :begin: named
typedef union {
	int i;
	real f;
} num;
// :end:

// :begin: named-variable
typedef union {
	int i;
	real f;
} num;

num n;
// :end:

// :tags: 7.3.1
// :description: Test support of packed unions
// :desc: union-packed

// Only packed data types and the integer data types summarized in
// Table 6-8 (see 6.11) shall be legal in packed unions

// :begin: anon
union packed {
	int i;
	byte b;
} n;
// :end:

// :begin: named
typedef union packed {
	int i;
	byte b;
} num;
// :end:

// :begin: named-variable
typedef union packed {
	int i;
	byte b;
} num;

num n;
// :end:

// :should_fail: 1
// :desc: union-packed-real
// :begin: anon
union packed {
	int i;
	real f;
} n;
// :end:

// :begin: named
typedef union packed {
	int i;
	real f;
} num;
// :end:

// :begin: named-variable
typedef union packed {
	int i;
	real f;
} num;

num n;
// :end:
// :should_fail: 0

// :description: Test support of packed unions signing
// :desc: union-packed

// :begin: anon-signed
union packed signed {
	int i;
	byte b;
} n;
// :end:

// :begin: anon-unsigned
union packed unsigned {
	int i;
	byte b;
} n;
// :end:

// :begin: named-signed
typedef union packed signed {
	int i;
	byte b;
} num;
// :end:

// :begin: named-unsigned
typedef union packed unsigned {
	int i;
	byte b;
} num;
// :end:

// :should_fail: 1
// :desc: union-packed-real
// :begin: anon-signed
union packed signed {
	int i;
	real f;
} n;
// :end:

// :begin: anon-unsigned
union packed unsigned {
	int i;
	real f;
} n;
// :end:

// :begin: named-signed
typedef union packed signed {
	int i;
	real f;
} num;
// :end:

// :begin: named-unsigned
typedef union packed unsigned {
	int i;
	real f;
} num;
// :end:
// :should_fail: 0

// :tags: 7.3.2
// :desc: union-tagged
// :description: Test support of tagged unions

// :begin: anon
union tagged {
	void invalid;
	int valid;
} u;
// :end:

// :begin: named
typedef union tagged {
	void invalid;
	int valid;
} VInt;
// :end:

// :tags: 7.4
// :desc: arrays

// :description: Test support of unpacked arrays
// :begin: unpacked
real u [7:0];
// :end:

// :description: Test support of packed arrays
// :begin: packed
bit [7:0] p;
// :end:

// ---------------------------- Packed arrays ---------------------
// :tags: 7.4.1

// Packed arrays can be made of only the single bit data types
// (bit, logic, reg), enumerated types, and
// recursively other packed arrays and packed structures.

// :should_fail: 1
// :desc: arrays-packed
// :description: Test support of packed arrays

// :begin: real
real [7:0] _real;
// :end:

// :begin: byte
byte [7:0] _byte;
// :end:

// :begin: shortint
shortint [7:0] _shortint;
// :end:

// :begin: int
int [7:0] _int;
// :end:

// :begin: longint
longint [7:0] _longint;
// :end:

// :begin: integer
integer [7:0] _integer;
// :end:

// :begin: time
time [7:0] _time;
// :end:

// :should_fail: 0

// :begin: bit
bit [7:0] _bit;
// :end:

// :begin: logic
logic [7:0] _logic;
// :end:

// :begin: reg
reg [31:0] _reg;
// :end:

// ---------------------------------- 7.4.2 ------------------------------
// :tags: 7.4.2

// :should_fail: 0
// :desc: arrays-unpacked
// :description: Test support of unpacked arrays

// :begin: real
real _real [7:0];
// :end:

// :begin: byte
byte _byte [7:0];
// :end:

// :begin: shortint
shortint _shortint [7:0];
// :end:

// :begin: int
int _int [7:0];
// :end:

// :begin: longint
longint _longint [7:0];
// :end:

// :begin: integer
integer _integer [7:0];
// :end:

// :begin: time
time _time [7:0];
// :end:

// :begin: bit
bit _bit [7:0];
// :end:

// :begin: logic
logic _logic [7:0];
// :end:

// :begin: reg
reg _reg [31:0];
// :end:

// --------------------------------- 7.4.4 -------------------------------
// :tags: 7.4.4
// :desc: memories
// :description: Test support of memories

// :begin: reg
reg [7:0] _reg [255:0];
// :end:

// :begin: logic
logic [7:0] _logic [255:0];
// :end:

// :begin: bit
bit [7:0] _bit [255:0];
// :end:

// --------------------------------- 7.4.5 -------------------------------
// :tags: 7.4.5
// :desc: multidimensional-arrays
// :description: Test support of multidimensional arrays

// :begin: simple
bit [3:0] [7:0] joe [1:10];
// :end:

// :begin: stages-packed
typedef bit [5:1] bsix;
bsix [10:1] v5;
// :end:

// :begin: stages-unpacked
typedef bit bsix [5:1];
typedef bsix mem_type [3:0];
mem_type ba [7:0];
// :end:

// :begin: stages-mixed
typedef bit [5:1] bsix;
typedef bsix mem_type [3:0];
mem_type ba [7:0];
// :end:

// :begin: little-endian
typedef bit [1:5] bsix;
bsix [1:10] v5;
// :end:

// All arrays in the list shall have the same data
// type and the same packed array dimensions
// :begin: two-arrays
bit [7:0] [31:0] v7 [1:5] [1:10], v8 [0:255];
// :end:



// :tags: 7.4.6
// :desc: indexing-and-slicing
// :description: Test support of indexing and slicing of arrays

// :desc: indexing-and-slicing-packed

// :begin: part-select
logic [63:0] data;
logic [7:0] byte2;

initial
	byte2 = data[23:16];
// :end:

// :begin: single-element
bit [3:0] [7:0] j;
byte k;

initial
	k = j[2];
// :end:

// :begin: slice-name
bit signed [31:0] [7:0] busA;
bit [15:0] busB;

initial
	busB = busA[7:6];
// :end:

// :begin: slice-variable
bit [31:0] bitvec;

parameter k = 8;
int j = 10;
byte i = bitvec[j+:k];
// :end:

// :desc: indexing-and-slicing-unpacked

// :begin: part-select
logic data [63:0];
logic byte2 [7:0];

initial
	byte2 = data[23:16];
// :end:

// :begin: single-element
bit [7:0] j [3:0];
byte k;

initial
	k = j[2];
// :end:

// :begin: slice-name
bit signed [31:0] busA [7:0];
int busB [1:0];

initial
	busB = busA[7:6];
// :end:

// :begin: slice-variable
bit bitvec [31:0];

parameter k = 8;
int j = 10;
bit i [7:0] = bitvec[j+:k];
// :end:

// TODO: Test write out of bound & read out of bound

// :tags: 7.5
// :description: Test support of dynamic arrays
// :desc: dynamic-arrays

// :begin: vector
bit [3:0] nibble [];
// :end:

// :begin: subarray
integer mem[2][];
// :end:

// :tags: 7.5.1
// :desc: dynamic-arrays-new
// :description: Test support of new constructor

// :begin: zero-length
bit [7:0] mem [];

initial
	mem = new[0];
// :end:

// :begin: nonzero-length
bit [7:0] mem [];

initial
	mem = new[32];
// :end:

// :begin: fixed-size
int arr1 [][2][3];

initial
	arr1 = new [4];
// :end:

// :begin: subarrays
int arr2 [][];

initial
	arr2 = new[4];
// :end:

// :should_fail: 1
// :begin: static-array
int arr3 [1][2][];

initial
	arr3 = new [4];
// :end:
// :should_fail: 0

// :begin: subarray-fixed-size-1
int arr[2][][];

initial
	arr[0] = new[4];
// :end:

// :begin: subarray-fixed-size-2
int arr[2][][];

initial
	arr[0][0] = new [2];
// :end:

// :should_fail: 1

// illegal, arr[1] not initialized so arr[1][0] does not exist
// :begin: subarray-uninit
int arr[2][][];

initial
	arr[1][0] = new [2];
// :end:

// illegal, syntax error - dimension without subscript on left hand side
// :begin: subarray-dimension
int arr[2][][];

initial
	arr[0][] = new [2];
// :end:

// illegal, arr[0][1][1] is an int, not a dynamic array
// :begin: subarray-wrong-type
int arr[2][][];

initial
	arr[0][1][1] = new [2];
// :end:

// :should_fail: 0

// :begin: init
int idest[], isrc[3] = '{5, 6, 7};

initial
	idest = new [3] (isrc);
// :end:

// :begin: init-different-size
int src[3], dest1[], dest2[];

initial begin
	src = '{2, 3, 4};
	dest1 = new [2] (src);
	dest2 = new [4] (src);
end
// :end:

// :begin: resize
integer addr[];

initial begin
	addr = new [100];
	addr = new [200] (addr);
end
// :end:

// :tags: 7.5.2
// :desc: dynamic-arrays

// :description: Test support of size method
// :begin: size
int addr[];
int addr_size;

initial
	addr_size = addr.size();
// :end:

// :tags: 7.5.3

// :description: Test support of delete method
// :begin: delete
int ab[];

initial begin
	ab = new [4];
	ab.delete;
end
// :end:

// :tags: 7.6
// :desc: dynamic-arrays-assignments
// :description: Test dynamic arrays assignments

// :begin: static
int A[100:1];
int B[];

initial
	B = A;
// :end:

// :begin: dynamic
int B[];
int C[] = new [8];

initial
	B = C;
// :end:

// :begin: complex
string d[1:5] = '{ "a", "b", "c", "d", "e" };
string p[];

initial
	p = { d[1:3], "hello", d[4:5] };
// :end:

// :tags: 7.7
// :desc: arrays-as-arugments-to-subroutines
// :description: Test support of arrays passing as arguments to subroutines

// :begin: static
int b[3:1][3:1];

task fun (int a[3:1][3:1]);
	a[1][1] = 1;
endtask

initial
	fun(b);
// :end:

// :begin: dynamic
string b[];

task t (string arr []);
	arr[1] = "x";
endtask

initial begin
	b = new [4];
	t(b);
end
// :end:

// :tags: 7.8
// :desc: associative-arrays
// :description: Test support of associative arrays

// :begin: integer
integer i_array[*];
// :end:

// :begin: bit
bit [20:0] array_b [string];
// :end:

// :tags: 7.8.1
// :begin: wildcard-index-type
integer array_name [*];
// :end:

// :tags: 7.8.2
// :begin: string-index
int array_name [ string ];
// :end:

// :tags: 7.8.3
// :begin: class-index
class C;
	int x;
endclass

int array_name [ C ];
// :end:

// :tags: 7.8.4
// :begin: integral-index
int array_name1 [ integer ];
// :end:

// :tags: 7.8.5
// :begin: other-user-defined
typedef struct { byte B; int I [*]; } Unpkt;
int array_name [Unpkt];
// :end:

// should issue a warning and return default value
// :tags: 7.8.6
// :begin: access-invalid-indices
int arr [4] = { 5, 6, 7, 8 };
int i;

initial
	i = arr[5];
// :end:

// :tags: 7.8.7
// :begin: allocating-associative-array-elements-simple
int a [int] = '{default:1};

initial
	a[1]++;
// :end:

// :begin: allocating-associative-array-elements-typedef
typedef struct { int x=1, y=2; } xy_t;
xy_t b [int];

initial
	b[2].x = 5;
// :end:

// :tags: 7.9
// :desc: associative-array-methods

// :description: Test support of associative arrays methods

// :tags: 7.9.1

// :begin: num
int imem [int];
int n;

initial begin
	imem[3] = 1;
	n = imem.num;
end
// :end:

// :begin: size
int imem [int];
int n;

initial begin
	imem[3] = 1;
	n = imem.size;
end
// :end:

// :tags: 7.9.2

// :begin: delete-one-entry
int map [string];

initial begin
	map[ "hello" ] = 1;
	map[ "sad" ] = 2;
	map[ "world" ] = 3;
	map.delete( "sad" );
end
// :end:

// :begin: delete-all-entries
int map [string];

initial begin
	map[ "hello" ] = 1;
	map[ "sad" ] = 2;
	map[ "world" ] = 3;
	map.delete;
end
// :end:

// :tags: 7.9.3

// :begin: exists
int map [string];

initial begin
	map[ "hello" ] = 1;
	map[ "sad" ] = 2;
	map[ "world" ] = 3;

	if ( map.exists( "hello" ) )
		map[ "hello" ] += 1;
	else
		map[ "hello" ] = 0;
end
// :end:

// :tags: 7.9.4

// :begin: first
int map [string];
string s;

initial begin
	map[ "hello" ] = 1;
	map[ "sad" ] = 2;
	map[ "world" ] = 3;

	map.first( s );
end
// :end:

// :tags: 7.9.5

// :begin: last
int map [string];
string s;

initial begin
	map[ "hello" ] = 1;
	map[ "sad" ] = 2;
	map[ "world" ] = 3;

	map.last( s );
end
// :end:

// :tags: 7.9.6

// :begin: next
int map [string];
string s;

initial begin
	map[ "hello" ] = 1;
	map[ "sad" ] = 2;
	map[ "world" ] = 3;

	if ( map.first( s ) )
		map.next( s );
end
// :end:

// :tags: 7.9.7

// :begin: next
int map [string];
string s;

initial begin
	map[ "hello" ] = 1;
	map[ "sad" ] = 2;
	map[ "world" ] = 3;

	if ( map.last( s ) )
		map.prev( s );
end
// :end:

// :tags: 7.9.8
// :description: Test support of traversal methods

// TODO: Status should be -1 and ix should be 232
// :begin: arguments-to-traversal-methods
string aa[int];
byte ix;
int status;

initial begin
	aa[ 1000 ] = "a";
	status = aa.first( ix );
end
// :end:

// :tags: 7.9.9
// :description: Test support of Associative arrays assignment
// TODO: Add tests which should_fail e.g. different type
// :begin: associative-array-assignment
string arraya[int];
string arrayb[int];

initial begin
	arraya[ 0 ] = "a";
	arraya[ 1 ] = "b";
	arraya[ 2 ] = "c";

	arrayb = arraya;
end
// :end:

// :tags: 7.9.10
// :description: Test support of associative array arugments
// TODO: Add tests which should_fail e.g. different type
// :begin: associative-array-arguments
string arraya[int];

task fun (string arrayb[int]);
	arrayb[ 2 ] = "d";
endtask

initial begin
	arraya[ 0 ] = "a";
	arraya[ 1 ] = "b";
	arraya[ 2 ] = "c";

	fun(arraya);
end
// :end:

// :tags: 7.9.11
// :description: Test support of associative array literals

// :begin: associative-array-literals-default
string words [int] = '{default: "hello"};
// :end:

// :begin: associative-array-literals-init
integer tab [string] = '{"Peter":20, "Paul":22, "Mary":23, default:-1};
// :end:

// ------------------------------ 7.10 -----------------------------------
// :tags: 7.10
// :desc: queues

// :description: Test support of queues

// :begin: byte
byte q1[$];
// :end:

// :begin: string
string names[$];
// :end:

// :begin: integer
integer Q[$];
// :end:

// :begin: max-size
integer q2[$:255];
// :end:

// :begin: initial
string names[$] = { "Bob" };
// :end:

// TODO: 7.10.3 persitence-of-references-to-elements-of-a-queue



// :tags: 7.10.4
// :desc: updating-a-queue-using-assignment-and-unpacked-array-concatenation
// :description: Test support of queue assignments

// :begin: push-back
int q[$] = { 2, 4, 6 };

initial
	q = { q, 8 }; // q.push_back(8);
// :end:

// :begin: push-front
int q[$] = { 2, 4, 6 };

initial
	q = { 0, q }; // q.push_front(0);
// :end:

// :begin: pop-front
int q[$] = { 2, 4, 6 };

initial
	q = q[1:$]; // void'(q.pop_front()) or q.delete(0)
// :end:

// :begin: pop-back
int q[$] = { 2, 4, 6 };

initial
	q = q[0:$-1]; // void'(q.pop_back()) or q.delete(q.size-1)
// :end:

// :begin: insert
int q[$] = { 2, 4, 6 };

initial
	q = { q[0:1], 5, q[2:$] }; // q.insert(2, 5);
// :end:

// :begin: delete-all
int q[$] = { 2, 4, 6 };

initial
	q = {}; // q.delete
// :end:



// TODO: 7.10.5 Bounded queues

// :tags: 7.11
// :desc: array-querying-functions
// :description: Test support of array querying functions

// TODO: Test packed arrays

// :begin: left
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $left(q);
// :end:

// :begin: right
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $right(q);
// :end:

// :begin: low
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $low(q);
// :end:

// :begin: high
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $high(q);
// :end:

// :begin: increment
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $increment(q);
// :end:

// :begin: size
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $size(q);
// :end:

// :begin: dimensions
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $dimensions(q);
// :end:

// :begin: unpacked-dimensions
int q[3] = { 2, 4, 6 };
int i;

initial
	i = $unpacked_dimensions(q);
// :end:

// :tags: 7.12.1
// :desc: array-locator-methods
// :description: Test support of array locator methods

// :begin: find
string s[] = { "hello", "sad", "world" };
string qs[$];

initial
	qs = s.find with ( item == "sad" );
// :end:

// :begin: find-index
string s[] = { "hello", "sad", "world" };
int qi[$];

initial
	qi = s.find_index with ( item == "sad" );
// :end:

// :begin: find-first
string s[] = { "hello", "sad", "world" };
string qs[$];

initial
	qs = s.find_first with ( item == "sad" );
// :end:

// :begin: find-first-index
string s[] = { "hello", "sad", "world" };
int qi[$];

initial
	qi = s.find_first_index with ( item == "sad" );
// :end:

// :begin: find-last
string s[] = { "hello", "sad", "world" };
string qs[$];

initial
	qs = s.find_last with ( item == "sad" );
// :end:

// :begin: find-last-index
string s[] = { "hello", "sad", "world" };
int qi[$];

initial
	qi = s.find_last_index with ( item == "sad" );
// :end:

// :tags: 7.12.2
// :desc: array-ordering-methods
// :description: Test support of array ordering methods

// :begin: reverse
string s[] = { "hello", "sad", "world" };

initial
	s.reverse;
// :end:

// :begin: sort
int q[$] = { 4, 5, 3, 1 };

initial
	q.sort;
// :end:

// :begin: rsort
int q[$] = { 4, 5, 3, 1 };

initial
	q.rsort;
// :end:

// :begin: shuffle
int q[$] = { 1, 2, 3, 4, 5 };

initial
	q.shuffle;
// :end:

// TODO: test 'with' keyword

// :tags: 7.12.3
// :desc: array-reduction-methods
// :description: Test support of array reduction methods

// TODO: test packed arrays

// :begin: sum
byte b[] = { 1, 2, 3, 4 };
int y;

initial
	y = b.sum;
// :end:

// :begin: product
byte b[] = { 1, 2, 3, 4 };
int y;

initial
	y = b.product;
// :end:

// :begin: xor
byte b[] = { 1, 2, 3, 4 };
int y;

initial
	y = b.xor;
// :end:

// :begin: and
byte b[] = { 1, 2, 3, 4 };
int y;

initial
	y = b.and;
// :end:

// :begin: or
byte b[] = { 1, 2, 3, 4 };
int y;

initial
	y = b.or;
// :end:

// :begin: with
byte b[] = { 1, 2, 3, 4 };
int y;

initial
	y = b.product with (item + 1);
// :end:

// :tags: 7.12.4
// :desc: iterator-index-querying
// :description: Test support of array iterator index querying

// :begin: basic
int arr[];
int q[$];

// Find all items equal to their position (index)
initial
	q = arr.find with ( item == item.index );
// :end:
