#!/bin/sh
# link with configure'ed systemc
export SYSTEMC_HOME=/opt/systemc-2.3.3
export SYSTEMC_LIBDIR=/opt/systemc-2.3.3/lib-linux64
export SYSTEMC_INCLUDE=/opt/systemc-2.3.3/include
export LD_LIBRARY_PATH=$SYSTEMC_LIBDIR:$LD_LIBRARY_PATH
export SC_CPLUSPLUS=201103L
export CXXFLAGS="-std=c++11 -g3"
//export CXXFLAGS="-g3"
verilator -Wall -trace -sc --clk i_clk test.v --exe sc_main.cpp
make -j -C obj_dir/ -f Vtest.mk Vtest
./obj_dir/Vtest
#gtkwave trace.gtkw
