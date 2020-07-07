/*
:name: global_constraints_0
:description: global constraints test
:tags: 18.5.9
*/

class a;
    rand int v;
endclass

class b;
    rand a aObj;
    rand int v;

    constraint c { aObj.v < v; }
endclass
