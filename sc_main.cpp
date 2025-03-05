// -*- SystemC -*-
// DESCRIPTION: Verilator Example: Top level main for invoking SystemC model
//
// Derived from an example by Wilson Snyder.
//======================================================================

// SystemC global header
#include <systemc.h>

// Include common routines
#include <verilated.h>
#include <verilated_vcd_sc.h>

#include <sys/stat.h>  // mkdir

// Include model header, generated from Verilating "top.v"
#include "Vtest.h"
#include "scTopModule.h"
#include "scClockModule.h"

// Construct the Verilated model, from inside Vtest.h
 Vtest top("top");

void scTopModule::myTB() {
	// initial stuff...
	res_out=true;
	wait();	// apply 1 cycles res_out active
	res_out=false;
	while(true) {  // do the logic...
		wait();
	}
}


int sc_main(int argc, char* argv[]) {
    // This is a more complicated example, please also see the simpler examples/hello_world_c.

    // Prevent unused variable warnings
    if (0 && argc && argv) {}
    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    Verilated::commandArgs(argc, argv);

    // Set debug level, 0 is off, 9 is highest presently used
    Verilated::debug(0);

    // Randomization reset policy
    Verilated::randReset(2);

    // General logfile
    ios::sync_with_stdio();

    // Define clocks
    sc_clock clk     ("i_clk",    40,SC_NS, 0.5, 3,SC_NS, true);   // 40 ns clock cycle (25 MHz)

    // Define interconnect
    sc_signal<bool> reset;
    sc_signal<bool> res_out;
    sc_signal<bool> clk16kHz;

    // Construct the SystemC scTopModule
    scTopModule *sctop = new scTopModule("scTop");

    // Construct the SystemC clock generator scClockModule
    scClockModule *scClk = new scClockModule("scClk");

    // Attach signals to the model
    scClk->clk		(clk);
    scClk->clk_out	(clk16kHz);

    top.i_clk       (clk);
    top.ref_clk		(clk16kHz);
    top.i_reset     (res_out);

    sctop->clk		(clk16kHz);
    sctop->reset	(reset);
    sctop->res_out	(res_out);

    // Before any evaluation, need to know to calculate those signals only used for tracing
    Verilated::traceEverOn(true);

    // You must do one evaluation before enabling waves, in order to allow
    // SystemC to interconnect everything for testing.
    sc_start(1,SC_NS);

    // Turn on waves
    cout << "Enabling waves into trace.vcd...\n";
    VerilatedVcdSc* tfp = new VerilatedVcdSc;
    top.trace(tfp, 99);
    tfp->open ("trace.vcd");

    // Simulate until $finish
    while (!Verilated::gotFinish() && VL_TIME_Q() < 500000) {  // not longer than 8 clk16kHz cycles

	// Apply inputs
	if (VL_TIME_Q() > 1 && VL_TIME_Q() < 10) {
	    reset = 1;	// Assert reset
	} else if (VL_TIME_Q() > 1) {
	    reset = 0;	// Deassert reset
	}

	// Simulate 1ns
	sc_start(1,SC_NS);
    }

    //  Close Waves
    if (tfp) tfp->close();

    // Final model cleanup
    top.final();

    // Fin
    cout << "SYSTEMC_VERSION: " << SYSTEMC_VERSION << "\n";
    return 0;
}
