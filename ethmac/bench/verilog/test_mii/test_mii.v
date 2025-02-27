task test_mii;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        cnt;
  integer        fail;
  integer        test_num;
  reg     [8:0]  clk_div; // only 8 bits are valid!
  reg     [4:0]  phy_addr;
  reg     [4:0]  reg_addr;
  reg     [15:0] phy_data;
  reg     [15:0] tmp_data;
begin
// MIIM MODULE TEST
test_heading("MIIM MODULE TEST");
$display(" ");
$display("MIIM MODULE TEST");
fail = 0;

// reset MAC registers
hard_reset;


//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_mii:                                                   ////
////                                                              ////
////  0:  Test clock divider of mii management module with all    ////
////      possible frequences.                                    ////
////  1:  Test various readings from 'real' phy registers.        ////
////  2:  Test various writings to 'real' phy registers (control  ////
////      and non writable registers)                             ////
////  3:  Test reset phy through mii management module            ////
////  4:  Test 'walking one' across phy address (with and without ////
////      preamble)                                               ////
////  5:  Test 'walking one' across phy's register address (with  ////
////      and without preamble)                                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test clock divider of mii management module with all      ////
  ////  possible frequences.                                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  `include "./test_mii/0.v"
  
  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test various readings from 'real' phy registers.          ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) //
  `include "./test_mii/1.v"

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test various writings to 'real' phy registers (control    ////
  ////  and non writable registers)                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) // 
  `include "./test_mii/2.v"

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test reset phy through mii management module              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 3) // 
  `include "./test_mii/3.v"

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy address (with and without   ////
  ////  preamble)                                                 ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) // 
  `include "./test_mii/4.v"

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy's register address (with    ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) // 
  `include "./test_mii/5.v"

end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mii

