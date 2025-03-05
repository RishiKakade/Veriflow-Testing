# SystemC Example
Simple SystemC sample simulated with verilator.

This example demonstrates a simple clock divider realized in verilog. The divider is fed by a clock source which simulates some random jitter.
This clock generator is realized in SystemC as well as the testbench. The top level SystemC (sc_main.cpp) runs the testbench and
also is setting up a trace to dump a VCD-file.

## Special Notes
* Verilator version used: 4.014  (stable branch from git.veripool.org)
* SystemC built on Linux from original reference sources by accelera.org
* There are two bash scripts, one for SystemC Version 2.2 and one for System C Version 2.3, which generate a trace dump in "trace.vcd".
If you want them to run, don't forget to ajust the environment variables according your systemc installation.
* Problem: 
<pre>test_sc_2_2.sh  # using SystemC 2.2.0 </pre>
properly producing a trace. You may view it with
<pre>gtkwave test.gtkw</pre>
but (don't forget to delete obj_dir)
<pre>test_sc_2_3.sh  # using SystemC 2.3.3</pre>
also is running seamlessly, but the produced trace.vcd doesn't contain trace data!

### Workaround

Inside the systemc cmake build directory with <pre>
make edit_cache
</pre>
set
<pre>ENABLE_PHASE_CALLBACKS_TRACING = OFF</pre>
