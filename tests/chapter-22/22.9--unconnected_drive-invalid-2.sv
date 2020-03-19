/*
:name: 22.9--unconnected_drive-invalid-2
:description: Test unconnected drive macro with argument other than pull0 and pull1
:should_fail_because: The directive `unconnected_drive takes one of two arguments—pull1 or pull0 
:tags: 22.9
:type: preprocessing
*/
`unconnected_drive pull2
`nounconnected_drive
