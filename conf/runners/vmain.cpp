/*
 * Top level simulation driver for use with verilator
 */

#include <verilated.h>
#include <Vtop.h>

int main(int argc, char *argv[]) {
	Vtop *top = new Vtop;

	for (int i = 0; i < 1000 && !Verilated::gotFinish(); i++)
		top->eval();

	top->final();

	delete top;

	return 0;
}
