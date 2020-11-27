/*
:name: associative-arrays-other-types
:description: Test associative arrays support
:tags: 7.8.1
*/
module top ();

typedef struct {
    byte B;
    int I[*];
} Unpkt;

int arr [ Unpkt ];

endmodule
