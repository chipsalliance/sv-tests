/*
 * Top level simulation driver for use with verilator
 */

#include <verilated.h>
#include <Vtop.h>

int main(int argc, char *argv[]) {
	const auto contextp = std::make_unique<VerilatedContext>();
	contextp->commandArgs(argc, argv);

	const auto top = std::make_unique<Vtop>(contextp.get());

	while (!contextp->gotFinish() && contextp->time() < 1000) {
		top->eval();
#ifdef V4 // Remove once uhdm-verilator upgrades to Verilator 5
		contextp->timeInc(1);
#else
		if (!top->eventsPending()) {
			// If no scheduled events, fallback to incrementing time
			contextp->timeInc(1);
		} else {
			// Else get the time of the next scheduled event
			contextp->time(top->nextTimeSlot());
		}
#endif
	}

	top->final();

	return 0;
}
