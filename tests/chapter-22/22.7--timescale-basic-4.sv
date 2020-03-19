/*
:name: 22.7--timescale-basic-4
:description: Test
:should_fail_because: The time_precision argument shall be at least as precise as the time_unit argument; it cannot specify a longerunit of time than time_unit.
:tags: 22.7
:type: simulation
*/
`timescale 1 ns / 10 ns
