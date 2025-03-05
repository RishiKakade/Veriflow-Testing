/*
 * scTopModule.h
 *
 *  Created on: 12.10.2017
 *      Author: za
 */
#ifndef SCTOPMODULE_H
#define SCTOPMODULE_H

#include <systemc.h>

SC_MODULE(scTopModule) {
	sc_in<bool> reset;
	sc_out<bool> res_out;
	sc_in<bool> clk;


	SC_CTOR(scTopModule) {
		SC_CTHREAD(myTB, clk.pos());
		reset_signal_is(reset, true);
	}

	void myTB();
};

#endif // SCTOPMODULE_H
