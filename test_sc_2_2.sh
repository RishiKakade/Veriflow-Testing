#!/bin/sh
export SYSTEMC_HOME=/opt/systemc-2.2
export SYSTEMC_LIBDIR=/opt/systemc-2.2/lib-linux64
export SYSTEMC_INCLUDE=/opt/systemc-2.2/include
export LD_LIBRARY_PATH=$SYSTEMC_LIBDIR:$LD_LIBRARY_PATH
export CXXFLAGS="-std=gnu++11"
verilator -Wall -trace -sc --clk i_clk test.v --exe sc_main.cpp
make -j -C obj_dir/ -f Vtest.mk Vtest
./obj_dir/Vtest
#gtkwave trace.gtkw
