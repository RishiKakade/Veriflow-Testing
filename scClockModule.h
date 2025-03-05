/* scClockModule.h
 *
 * Clock Generator Module - simulates a busclock
 *
 * 17-10-13/Za
 *
 *
 */

#ifndef SCCLOCKMODULE_H
#define SCCLOCKMODULE_H

#include <systemc.h>
#include <stdlib.h>

#define CLOCK_PERIOD_PS	62500000.0	// Periodtime for 16kHz in ps
#define INCLOCK_PERIOD_PS   40000.0	// Periodtime for 25 MHz input clock
#define DIVIDER (CLOCK_PERIOD_PS / INCLOCK_PERIOD_PS)
//#define DIVIDER 8

SC_MODULE(scClockModule) {
	sc_out<bool> clk_out;
	sc_in<bool> clk;

	sc_signal<bool> clkState;


	void run() {
		static long jitter;
		clk_out.write(false);
		clkState.write(false);
		while (true) {
			clkState.write(!clkState.read());		// toggle
			clk_out.write(clkState.read());
			if (clkState.read()) {
				jitter = rand() %5  -2;		// jitter of +/- 2 clock cycles
				wait(DIVIDER/2 + jitter);
			} else wait (DIVIDER/2);
		}
	}

	SC_CTOR(scClockModule) {
		SC_CTHREAD(run, clk.pos());
	}
};

#endif // SCCLOCKMODULE_H
