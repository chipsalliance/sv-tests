/*
:name: class_member_test_5
:description: Test
:should_fail_because: pure virtual methods can only be declared in virtual classes
:tags: 8.3
*/
class myclass;
pure virtual task pure_task1;
pure virtual task pure_task2(int arg);
endclass
