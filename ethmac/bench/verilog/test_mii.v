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
////  6:  Test 'walking one' across phy's data (with and without  ////
////      preamble)                                               ////
////  7:  Test reading from phy with wrong phy address (host      ////
////      reading high 'z' data)                                  ////
////  8:  Test writing to phy with wrong phy address and reading  ////
////      from correct one                                        ////
////  9:  Test sliding stop scan command immediately after read   ////
////      request (with and without preamble)                     ////
//// 10:  Test sliding stop scan command immediately after write  ////
////      request (with and without preamble)                     ////
//// 11:  Test busy and nvalid status durations during write      ////
////      (with and without preamble)                             ////
//// 12:  Test busy and nvalid status durations during write      ////
////      (with and without preamble)                             ////
//// 13:  Test busy and nvalid status durations during scan (with ////
////      and without preamble)                                   ////
//// 14:  Test scan status from phy with detecting link-fail bit  ////
////      (with and without preamble)                             ////
//// 15:  Test scan status from phy with sliding link-fail bit    ////
////      (with and without preamble)                             ////
//// 16:  Test sliding stop scan command immediately after scan   ////
////      request (with and without preamble)                     ////
//// 17:  Test sliding stop scan command after 2. scan (with and  ////
////      without preamble)                                       ////
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
  begin
    // TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES
    test_name   = "TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES";
    `TIME; $display("  TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES");
  
    wait(Mdc_O); // wait for MII clock to be 1
    for(clk_div = 0; clk_div <= 255; clk_div = clk_div + 1) // Loop through all possible clock divider values
    begin // Begin block
      i1 = 0; // Initialize i1 to 0
      i2 = 0; // Initialize i2 to 0
      #Tp mii_set_clk_div(clk_div[7:0]); // Set the MII clock divider
      @(posedge Mdc_O); // Wait for a positive edge of the Mdc_O signal
      #Tp; // Add a small delay
      fork // Create concurrent processes
        begin // Begin process
          @(posedge Mdc_O); // Wait for a positive edge of the Mdc_O signal
          #Tp; // Add a small delay
          disable count_i1; // Disable the count_i1 process
          disable count_i2; // Disable the count_i2 process
        end // End process
        begin: count_i1 // Begin a named process called count_i1
          forever // Loop forever
          begin // Begin block
            @(posedge wb_clk); // Wait for a positive edge of the wb_clk signal
            i1 = i1 + 1; // Increment i1
            #Tp; // Add a small delay
          end // End block
        end // End process
        begin: count_i2 // Begin a named process called count_i2
          forever // Loop forever
          begin // Begin block
            @(negedge wb_clk); // Wait for a negative edge of the wb_clk signal
            i2 = i2 + 1; // Increment i2
            #Tp; // Add a small delay
          end // End block
        end // End process
      join // Wait for all forked processes to complete
      if((clk_div[7:0] == 0) || (clk_div[7:0] == 1) || (clk_div[7:0] == 2) || (clk_div[7:0] == 3)) // Check if the clock divider is 0, 1, 2, or 3
      begin // Begin block
        if((i1 == i2) && (i1 == 2)) // Check if i1 and i2 are equal to 2
        begin // Begin block
        end // End block
        else // Otherwise
        begin // Begin block
          fail = fail + 1; // Increment the fail counter
          test_fail("Clock divider of MII module did'nt divide frequency corectly (it should divide by 2)"); // Call the test_fail task
        end // End block
      end // End block
      else // Otherwise
      begin // Begin block
        if((i1 == i2) && (i1 == {clk_div[7:1], 1'b0})) // Check if i1 and i2 are equal to half the clock divider value
        begin // Begin block
        end // End block
        else // Otherwise
        begin // Begin block
          fail = fail + 1; // Increment the fail counter
          test_fail("Clock divider of MII module did'nt divide frequency corectly"); // Call the test_fail task
        end // End block
      end // End block
    end // End block
    if(fail == 0) // Check if the fail counter is 0
      test_ok; // Call the test_ok task
    else // Otherwise
      fail = 0; // Reset the fail counter

  end
  
  
  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test various readings from 'real' phy registers.          ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) //
  begin
    // TEST 1: VARIOUS READINGS FROM 'REAL' PHY REGISTERS
    test_name   = "TEST 1: VARIOUS READINGS FROM 'REAL' PHY REGISTERS";
    `TIME; $display("  TEST 1: VARIOUS READINGS FROM 'REAL' PHY REGISTERS");
  
    // set the fastest possible MII
    clk_div = 0;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1F;
    phy_addr = 5'h1;
    while(reg_addr >= 5'h4)
    begin
      // read request
      #Tp mii_read_req(phy_addr, reg_addr);
      check_mii_busy; // wait for read to finish
      // read data
      wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data !== 16'hDEAD)
      begin
        test_fail("Wrong data was read from PHY from 'not used' address space");
        fail = fail + 1;
      end
      if (reg_addr == 5'h4) // go out of for loop
        reg_addr = 5'h3;
      else
        reg_addr = reg_addr - 5'h9;
    end
  
    // set address
    reg_addr = 5'h3;
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== {`PHY_ID2, `MAN_MODEL_NUM, `MAN_REVISION_NUM})
    begin
      test_fail("Wrong data was read from PHY from ID register 2");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test various writings to 'real' phy registers (control    ////
  ////  and non writable registers)                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) // 
  begin
    // TEST 2: VARIOUS WRITINGS TO 'REAL' PHY REGISTERS ( CONTROL AND NON WRITABLE REGISTERS )
    test_name   = "TEST 2: VARIOUS WRITINGS TO 'REAL' PHY REGISTERS ( CONTROL AND NON WRITABLE REGISTERS )";
    `TIME; $display("  TEST 2: VARIOUS WRITINGS TO 'REAL' PHY REGISTERS ( CONTROL AND NON WRITABLE REGISTERS )");
  
    // negate data and try to write into unwritable register
    tmp_data = ~phy_data;
    // write request
    #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (tmp_data !== phy_data)
    begin
      test_fail("Data was written into unwritable PHY register - ID register 2");
      fail = fail + 1;
    end
  
    // set address
    reg_addr = 5'h0; // control register
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // write request
    phy_data = 16'h7DFF; // bit 15 (RESET bit) and bit 9 are self clearing bits
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== 16'h7DFF)
    begin
      test_fail("Data was not correctly written into OR read from writable PHY register - control register");
      fail = fail + 1;
    end
    // write request
    #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== tmp_data)
    begin
      test_fail("Data was not correctly written into OR read from writable PHY register - control register");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test reset phy through mii management module              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 3) // 
  begin
    // TEST 3: RESET PHY THROUGH MII MANAGEMENT MODULE
    test_name   = "TEST 3: RESET PHY THROUGH MII MANAGEMENT MODULE";
    `TIME; $display("  TEST 3: RESET PHY THROUGH MII MANAGEMENT MODULE");
  
    // set address
    reg_addr = 5'h0; // control register
    // write request
    phy_data = 16'h7DFF; // bit 15 (RESET bit) and bit 9 are self clearing bits
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== tmp_data)
    begin
      test_fail("Data was not correctly written into OR read from writable PHY register - control register");
      fail = fail + 1;
    end
    // set reset bit - selfclearing bit in PHY
    phy_data = phy_data | 16'h8000;
    // write request
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check self clearing of reset bit
    if (tmp_data[15] !== 1'b0)
    begin
      test_fail("Reset bit should be self cleared - control register");
      fail = fail + 1;
    end
    // check reset value of control register
    if (tmp_data !== {2'h0, (`LED_CFG1 || `LED_CFG2), `LED_CFG1, 3'h0, `LED_CFG3, 8'h0})
    begin
      test_fail("PHY was not reset correctly AND/OR reset bit not self cleared");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy address (with and without   ////
  ////  preamble)                                                 ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) // 
  begin
    // TEST 4: 'WALKING ONE' ACROSS PHY ADDRESS ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 4: 'WALKING ONE' ACROSS PHY ADDRESS ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 4: 'WALKING ONE' ACROSS PHY ADDRESS ( WITH AND WITHOUT PREAMBLE )");
  
    // set PHY to test mode
    #Tp eth_phy.test_regs(1); // set test registers (wholy writable registers) and respond to all PHY addresses
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i); 
      #Tp eth_phy.clear_test_regs;
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      // walk one across phy address
      for (phy_addr = 5'h1; phy_addr > 5'h0; phy_addr = phy_addr << 1)
      begin
        reg_addr = $random;
        tmp_data = $random;
        // write request
        #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
        check_mii_busy; // wait for write to finish
        // read request
        #Tp mii_read_req(phy_addr, reg_addr);
        check_mii_busy; // wait for read to finish
        // read data
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        #Tp;
        if (phy_data !== tmp_data)
        begin
          if (i)
            test_fail("Data was not correctly written into OR read from test registers (without preamble)");
          else
            test_fail("Data was not correctly written into OR read from test registers (with preamble)");
          fail = fail + 1;
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.test_regs(0);
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy's register address (with    ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) // 
  begin
    // TEST 5: 'WALKING ONE' ACROSS PHY'S REGISTER ADDRESS ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 5: 'WALKING ONE' ACROSS PHY'S REGISTER ADDRESS ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 5: 'WALKING ONE' ACROSS PHY'S REGISTER ADDRESS ( WITH AND WITHOUT PREAMBLE )");
  
    // set PHY to test mode
    #Tp eth_phy.test_regs(1); // set test registers (wholy writable registers) and respond to all PHY addresses
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      #Tp eth_phy.clear_test_regs;
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      // walk one across reg address
      for (reg_addr = 5'h1; reg_addr > 5'h0; reg_addr = reg_addr << 1)
      begin
        phy_addr = $random;
        tmp_data = $random;
        // write request
        #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
        check_mii_busy; // wait for write to finish
        // read request
        #Tp mii_read_req(phy_addr, reg_addr);
        check_mii_busy; // wait for read to finish
        // read data
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        #Tp;
        if (phy_data !== tmp_data)
        begin
          if (i)
            test_fail("Data was not correctly written into OR read from test registers (without preamble)");
          else
            test_fail("Data was not correctly written into OR read from test registers (with preamble)");
          fail = fail + 1;
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.test_regs(0);
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy's data (with and without    ////
  ////  preamble)                                                 ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 6) // 
  begin
    // TEST 6: 'WALKING ONE' ACROSS PHY'S DATA ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 6: 'WALKING ONE' ACROSS PHY'S DATA ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 6: 'WALKING ONE' ACROSS PHY'S DATA ( WITH AND WITHOUT PREAMBLE )");
  
    // set PHY to test mode
    #Tp eth_phy.test_regs(1); // set test registers (wholy writable registers) and respond to all PHY addresses
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      #Tp eth_phy.clear_test_regs;
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}), 4'hF, 1, wbm_init_waits,
                wbm_subseq_waits);
      // walk one across data
      for (tmp_data = 16'h1; tmp_data > 16'h0; tmp_data = tmp_data << 1)
      begin
        phy_addr = $random;
        reg_addr = $random;
        // write request
        #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
        check_mii_busy; // wait for write to finish
        // read request
        #Tp mii_read_req(phy_addr, reg_addr);
        check_mii_busy; // wait for read to finish
        // read data
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        #Tp;
        if (phy_data !== tmp_data)
        begin
          if (i)
            test_fail("Data was not correctly written into OR read from test registers (without preamble)");
          else
            test_fail("Data was not correctly written into OR read from test registers (with preamble)");
          fail = fail + 1;
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.test_regs(0);
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test reading from phy with wrong phy address (host        ////
  ////  reading high 'z' data)                                    ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 7) // 
  begin
    // TEST 7: READING FROM PHY WITH WRONG PHY ADDRESS ( HOST READING HIGH 'Z' DATA )
    test_name   = "TEST 7: READING FROM PHY WITH WRONG PHY ADDRESS ( HOST READING HIGH 'Z' DATA )";
    `TIME; $display("  TEST 7: READING FROM PHY WITH WRONG PHY ADDRESS ( HOST READING HIGH 'Z' DATA )");
  
    phy_addr = 5'h2; // wrong PHY address
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    $display("  => Two error lines will be displayed from WB Bus Monitor, because correct HIGH Z data was read");
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (tmp_data !== 16'hzzzz)
    begin
      test_fail("Data was read from PHY register with wrong PHY address - control register");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test writing to phy with wrong phy address and reading    ////
  ////  from correct one                                          ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 8) // 
  begin
    // TEST 8: WRITING TO PHY WITH WRONG PHY ADDRESS AND READING FROM CORRECT ONE
    test_name   = "TEST 8: WRITING TO PHY WITH WRONG PHY ADDRESS AND READING FROM CORRECT ONE";
    `TIME; $display("  TEST 8: WRITING TO PHY WITH WRONG PHY ADDRESS AND READING FROM CORRECT ONE");
  
    // set address
    reg_addr = 5'h0; // control register
    phy_addr = 5'h2; // wrong PHY address
    // write request
    phy_data = 16'h7DFF; // bit 15 (RESET bit) and bit 9 are self clearing bits
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
  
    phy_addr = 5'h1; // correct PHY address
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data === tmp_data)
    begin
      test_fail("Data was written into PHY register with wrong PHY address - control register");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command immediately after read     ////
  ////  request (with and without preamble)                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 9) // 
  begin
    // TEST 9: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER READ REQUEST ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 9: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER READ REQUEST ( WITH AND WITHOUT PREAMBLE )";
    `TIME; 
    $display("  TEST 9: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER READ REQUEST ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
               wbm_subseq_waits);
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after read will be finished
        begin
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // read request
          #Tp mii_read_req(phy_addr, reg_addr);
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while read in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for read to finish
            end
            begin
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
            end
          join
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Read request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Read request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after read was finished
          #Tp phy_data = {8'h7D, (i[7:0] + 1'b1)};
          #Tp cnt = 0;
          if (i3 == 0) // write after read
          begin
            // write request
            #Tp mii_write_req(phy_addr, reg_addr, phy_data);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after read
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after read request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after read request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command immediately after write    ////
  ////  request (with and without preamble)                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 10) // 
  begin
    // TEST 10: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER WRITE REQUEST ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 10: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER WRITE REQUEST ( WITH AND WITHOUT PREAMBLE )";
    `TIME; 
    $display("  TEST 10: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER WRITE REQUEST ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after write will be finished
        begin
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // write request
          phy_data = {8'h75, (i[7:0] + 1'b1)};
          #Tp mii_write_req(phy_addr, reg_addr, phy_data);
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while read in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for write to finish
            end
            begin
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while(Mdio_IO !== 1'bz)
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
            end
          join
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Write request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Write request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after write was finished
          #Tp cnt = 0;
          if (i3 == 0) // write after write
          begin
            phy_data = {8'h78, (i[7:0] + 1'b1)};
            // write request, bit 9 in phy_data is self-clearing
            #Tp mii_write_req(phy_addr, reg_addr, (phy_data|16'h0200));
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data , 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after write
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data , 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after write request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after write request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test busy and nvalid status durations during write (with  ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 11) // 
  begin
    // TEST 11: BUSY AND NVALID STATUS DURATIONS DURING WRITE ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 11: BUSY AND NVALID STATUS DURATIONS DURING WRITE ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 11: BUSY AND NVALID STATUS DURATIONS DURING WRITE ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1);
    // set the MII
    clk_div = 64;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div), 
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      @(posedge Mdc_O);
      // write request
      #Tp mii_write_req(phy_addr, reg_addr, 16'h5A5A);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
      else // Busy bit should already be set to '1', due to reads from MII status register
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after write, due to reads from MII status register");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
  
      // wait for serial bus to become active
      wait(Mdio_IO !== 1'bz);
      // count transfer bits
      if (i)
      begin
        repeat(32) @(posedge Mdc_O);
      end
      else
      begin
        repeat(64) @(posedge Mdc_O);
      end
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
  
      // wait for next negative clock edge
      @(negedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after MII IO signal become HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
  
      // wait for Busy to become inactive
      i1 = 0;
      while (i1 <= 2)
      begin
        // wait for next positive clock edge
        @(posedge Mdc_O);
        // read data from MII status register - Busy and Nvalid bits
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
        // check MII IO signal and Busy and Nvalid bits
        if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
        begin
          test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
            fail = fail + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set during write");
            fail = fail + 1;
          end
        end
        else // wait for Busy bit to be set to '0'
        begin
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            i1 = 3; // end of Busy checking
          end
          else
          begin
            if (i1 == 2)
            begin
              test_fail("Busy signal should be cleared after 2 periods after MII IO signal become HIGH Z");
              fail = fail + 1;
            end
            #Tp i1 = i1 + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set after write");
            fail = fail + 1;
          end
        end
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test busy and nvalid status durations during write (with  ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 12) // 
  begin
    // TEST 12: BUSY AND NVALID STATUS DURATIONS DURING READ ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 12: BUSY AND NVALID STATUS DURATIONS DURING READ ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 12: BUSY AND NVALID STATUS DURATIONS DURING READ ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1); 
    // set the MII
    clk_div = 64;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div),
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      @(posedge Mdc_O);
      // read request
      #Tp mii_read_req(phy_addr, reg_addr);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
      else // Busy bit should already be set to '1', due to reads from MII status register
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after read, due to reads from MII status register");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
  
      // wait for serial bus to become active
      wait(Mdio_IO !== 1'bz);
      // count transfer bits
      if (i)
      begin
        repeat(31) @(posedge Mdc_O);
      end
      else
      begin
        repeat(63) @(posedge Mdc_O);
      end
      // wait for next negative clock edge
      @(negedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
  
      // wait for next positive clock edge
      @(posedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after MII IO signal become HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
  
      // wait for Busy to become inactive
      i1 = 0;
      while (i1 <= 2)
      begin
        // wait for next positive clock edge
        @(posedge Mdc_O);
        // read data from MII status register - Busy and Nvalid bits
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
        // check MII IO signal and Busy and Nvalid bits
        if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
        begin
          test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
            fail = fail + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set during read");
            fail = fail + 1;
          end
        end
        else // wait for Busy bit to be set to '0'
        begin
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            i1 = 3; // end of Busy checking
          end
          else
          begin
            if (i1 == 2)
            begin
              test_fail("Busy signal should be cleared after 2 periods after MII IO signal become HIGH Z");
              fail = fail + 1;
            end
            #Tp i1 = i1 + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set after read");
            fail = fail + 1;
          end
        end
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test busy and nvalid status durations during scan (with   ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 13) // 
  begin
    // TEST 13: BUSY AND NVALID STATUS DURATIONS DURING SCAN ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 13: BUSY AND NVALID STATUS DURATIONS DURING SCAN ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 13: BUSY AND NVALID STATUS DURATIONS DURING SCAN ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1); 
    // set the MII
    clk_div = 64;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div),
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      @(posedge Mdc_O);
      // scan request
      #Tp mii_scan_req(phy_addr, reg_addr);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
      end
      else // Busy bit should already be set to '1', due to reads from MII status register
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after scan, due to reads from MII status register");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal should be set after scan, due to reads from MII status register");
          fail = fail + 1;
        end
      end
  
      // wait for serial bus to become active
      wait(Mdio_IO !== 1'bz);
      // count transfer bits
      if (i)
      begin
        repeat(21) @(posedge Mdc_O);
      end
      else
      begin
        repeat(53) @(posedge Mdc_O);
      end
      // stop scan
      #Tp mii_scan_finish; // finish scan operation
  
      // wait for next positive clock edge
      repeat(10) @(posedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        // Nvalid signal can be cleared here - it is still Testbench error
      end
      else // Busy bit should still be set to '1', Nvalid bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
      end
  
      // wait for next negative clock edge
      @(negedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        // Nvalid signal can be cleared here - it is still Testbench error
      end
      else // Busy bit should still be set to '1', Nvalid bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
      end
  
      // wait for next negative clock edge
      @(posedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1', Nvalid bit can be set to '0'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after MII IO signal become HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          i2 = 1; // check finished
        end
        else
        begin
          i2 = 0; // check must continue
        end
      end
  
      // wait for Busy to become inactive
      i1 = 0;
      while ((i1 <= 2) || (i2 == 0))
      begin
        // wait for next positive clock edge
        @(posedge Mdc_O);
        // read data from MII status register - Busy and Nvalid bits
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
        // check MII IO signal and Busy and Nvalid bits
        if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
        begin
          test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
          if (i1 <= 2)
          begin
            if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
            begin
              test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
              fail = fail + 1;
            end
          end
          if (i2 == 0)
          begin
            if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
            begin
              test_fail("Nvalid signal was not set while MII IO signal is not HIGH Z");
              fail = fail + 1;
            end
          end
        end
        else // wait for Busy bit to be set to '0'
        begin
          if (i1 <= 2)
          begin
            if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
            begin
              i1 = 3; // end of Busy checking
            end
            else
            begin
              if (i1 == 2)
              begin
                test_fail("Busy signal should be cleared after 2 periods after MII IO signal become HIGH Z");
                fail = fail + 1;
              end
              #Tp i1 = i1 + 1;
            end
          end
          if (i2 == 0)
          begin
            if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
            begin
              i2 = 1;
            end
            else
            begin
              test_fail("Nvalid signal should be cleared after MII IO signal become HIGH Z");
              fail = fail + 1;
            end
          end
        end
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test scan status from phy with detecting link-fail bit    ////
  ////  (with and without preamble)                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 14) // 
  begin
    // TEST 14: SCAN STATUS FROM PHY WITH DETECTING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 14: SCAN STATUS FROM PHY WITH DETECTING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 14: SCAN STATUS FROM PHY WITH DETECTING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1); 
    // set MII speed
    clk_div = 6;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data from PHY status register - remember LINK-UP status
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div),
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // scan request
      #Tp mii_scan_req(phy_addr, reg_addr);
      check_mii_scan_valid; // wait for scan to make first data valid
     
      fork
      begin 
        repeat(2) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("Data was not correctly scaned from status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] !== 1'b0)
        begin
          test_fail("Link FAIL bit was set in the MII status register");
          fail = fail + 1;
        end
      end
      begin
      // Completely check second scan
        #Tp cnt = 0;
        // wait for serial bus to become active - second scan
        wait(Mdio_IO !== 1'bz);
        // count transfer length
        while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i == 0)) || ((cnt == 15) && (i == 1)) )
        begin
          @(posedge Mdc_O);
          #Tp cnt = cnt + 1;
        end
        // check transfer length
        if (i) // without preamble
        begin
          if (cnt != 33) // at this value Mdio_IO is HIGH Z
          begin
            test_fail("Second scan request did not proceed correctly");
            fail = fail + 1;
          end
        end
        else // with preamble
        begin
          if (cnt != 65) // at this value Mdio_IO is HIGH Z
          begin
            test_fail("Second scan request did not proceed correctly");
            fail = fail + 1;
          end
        end
      end
      join
      // check third to fifth scans
      for (i3 = 0; i3 <= 2; i3 = i3 + 1)
      begin
        fork
        begin
          repeat(2) @(posedge Mdc_O);
          // read data from PHY status register
          wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data !== tmp_data)
          begin
            test_fail("Data was not correctly scaned from status register");
            fail = fail + 1;
          end
          // read data from MII status register
          wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data[0] !== 1'b0)
          begin
            test_fail("Link FAIL bit was set in the MII status register");
            fail = fail + 1;
          end
          if (i3 == 2) // after fourth scan read
          begin
            @(posedge Mdc_O);
            // change saved data
            #Tp tmp_data = tmp_data & 16'hFFFB; // put bit 3 to ZERO
            // set link down
            #Tp eth_phy.link_up_down(0);
          end
        end
        begin
        // Completely check scans
          #Tp cnt = 0;
          // wait for serial bus to become active - second scan
          wait(Mdio_IO !== 1'bz);
          // count transfer length
          while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i == 0)) || ((cnt == 15) && (i == 1)) )
          begin
            @(posedge Mdc_O);
            #Tp cnt = cnt + 1;
          end
          // check transfer length
          if (i) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
        end
        join
      end
  
      fork
      begin
        repeat(2) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("Data was not correctly scaned from status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] === 1'b0)
        begin
          test_fail("Link FAIL bit was not set in the MII status register");
          fail = fail + 1;
        end
        // wait to see if data stayed latched
        repeat(4) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("Data was not latched correctly in status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] === 1'b0)
        begin
          test_fail("Link FAIL bit was not set in the MII status register");
          fail = fail + 1;
        end
        // change saved data
        #Tp tmp_data = tmp_data | 16'h0004; // put bit 2 to ONE
        // set link up
        #Tp eth_phy.link_up_down(1);
      end
      begin
      // Wait for sixth scan
        // wait for serial bus to become active - sixth scan
        wait(Mdio_IO !== 1'bz);
        // wait for serial bus to become inactive - turn-around cycle in sixth scan
        wait(Mdio_IO === 1'bz);
        // wait for serial bus to become active - end of turn-around cycle in sixth scan
        wait(Mdio_IO !== 1'bz);
        // wait for serial bus to become inactive - end of sixth scan
        wait(Mdio_IO === 1'bz);
      end
      join
  
      @(posedge Mdc_O);
      // read data from PHY status register
      wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data !== tmp_data)
      begin
        test_fail("Data was not correctly scaned from status register");
        fail = fail + 1;
      end
      // read data from MII status register
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data[0] !== 1'b0)
      begin
        test_fail("Link FAIL bit was set in the MII status register");
        fail = fail + 1;
      end
      // wait to see if data stayed latched
      repeat(4) @(posedge Mdc_O);
      // read data from PHY status register
      wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data !== tmp_data)
      begin
        test_fail("Data was not correctly scaned from status register");
        fail = fail + 1;
      end
      // read data from MII status register
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data[0] !== 1'b0)
      begin
        test_fail("Link FAIL bit was set in the MII status register");
        fail = fail + 1;
      end
  
      // STOP SCAN
      #Tp mii_scan_finish; // finish scan operation
      #Tp check_mii_busy; // wait for scan to finish
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test scan status from phy with sliding link-fail bit      ////
  ////  (with and without preamble)                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 15) // 
  begin
    // TEST 15: SCAN STATUS FROM PHY WITH SLIDING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 15: SCAN STATUS FROM PHY WITH SLIDING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 15: SCAN STATUS FROM PHY WITH SLIDING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )");
  
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data from PHY status register - remember LINK-UP status
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      #Tp wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                    wbm_subseq_waits);
      i = 0;
      while (i < 80) // delay for sliding of LinkFail bit
      begin
        // first there are two scans
        #Tp cnt = 0;
        // scan request
        #Tp mii_scan_req(phy_addr, reg_addr);
        #Tp check_mii_scan_valid; // wait for scan to make first data valid
  
        // check second scan
        fork
        begin
          repeat(4) @(posedge Mdc_O);
          // read data from PHY status register
          wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data !== tmp_data)
          begin
            test_fail("Second data was not correctly scaned from status register");
            fail = fail + 1;
          end
          // read data from MII status register
          wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data[0] !== 1'b0)
          begin
            test_fail("Link FAIL bit was set in the MII status register");
            fail = fail + 1;
          end
        end
        begin
        // Completely check scan
          #Tp cnt = 0;
          // wait for serial bus to become active - second scan
          wait(Mdio_IO !== 1'bz);
          // count transfer length
          while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
          begin
            @(posedge Mdc_O);
            #Tp cnt = cnt + 1;
          end
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Second scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Second scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
        end
        join
        // reset counter 
        #Tp cnt = 0;
        // SLIDING LINK DOWN and CHECK
        fork
          begin
          // set link down
            repeat(i) @(posedge Mdc_O);
            // set link down
            #Tp eth_phy.link_up_down(0);
          end
          begin
          // check data in MII registers after each scan in this fork statement
            if (i2) // without preamble
              wait (cnt == 32);
            else // with preamble
              wait (cnt == 64);
            repeat(3) @(posedge Mdc_O);
            // read data from PHY status register
            wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data !== (tmp_data & 16'hFFFB)) // bit 3 is ZERO
              begin
                test_fail("Third data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data !== tmp_data)
              begin
                test_fail("Third data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            // read data from MII status register
            wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data[0] === 1'b0)
              begin
                test_fail("Link FAIL bit was not set in the MII status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data[0] !== 1'b0)
              begin
                test_fail("Link FAIL bit was set in the MII status register");
                fail = fail + 1;
              end
            end
          end
          begin
          // check length
            for (i3 = 0; i3 <= 1; i3 = i3 + 1) // two scans
            begin
              #Tp cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("3. or 4. scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("3. or 4. scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          end
        join
        // reset counter
        #Tp cnt = 0;
        // check fifth scan and data from fourth scan
        fork
        begin
          repeat(2) @(posedge Mdc_O);
          // read data from PHY status register
          wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data !== (tmp_data & 16'hFFFB)) // bit 3 is ZERO
          begin
            test_fail("4. data was not correctly scaned from status register");
            fail = fail + 1;
          end
          // read data from MII status register
          wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data[0] === 1'b0)
          begin
            test_fail("Link FAIL bit was not set in the MII status register");
            fail = fail + 1;
          end
        end
        begin
        // Completely check intermediate scan
          #Tp cnt = 0;
          // wait for serial bus to become active - second scan
          wait(Mdio_IO !== 1'bz);
          // count transfer length
          while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
          begin
            @(posedge Mdc_O);
            #Tp cnt = cnt + 1;
          end
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
        end
        join
        // reset counter 
        #Tp cnt = 0;
        // SLIDING LINK UP and CHECK
        fork
          begin
          // set link up
            repeat(i) @(posedge Mdc_O);
            // set link up
            #Tp eth_phy.link_up_down(1);
          end
          begin
          // check data in MII registers after each scan in this fork statement
            repeat(2) @(posedge Mdc_O);
            if (i2) // without preamble
              wait (cnt == 32);
            else // with preamble
              wait (cnt == 64);
            repeat(3) @(posedge Mdc_O);
            // read data from PHY status register
            wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data !== tmp_data) 
              begin
                test_fail("6. data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data !== (tmp_data & 16'hFFFB)) // bit 3 is ZERO
              begin
                test_fail("6. data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            // read data from MII status register
            wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data[0] !== 1'b0)
              begin
                test_fail("Link FAIL bit was set in the MII status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data[0] === 1'b0)
              begin
                test_fail("Link FAIL bit was not set in the MII status register");
                fail = fail + 1;
              end
            end
          end
          begin
          // check length
            for (i3 = 0; i3 <= 1; i3 = i3 + 1) // two scans
            begin
              #Tp cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("Scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("Scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          end
        join
        // check last scan 
        repeat(4) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("7. data was not correctly scaned from status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] !== 1'b0)
        begin
          test_fail("Link FAIL bit was set in the MII status register");
          fail = fail + 1;
        end
  
        #Tp mii_scan_finish; // finish scan operation
        #Tp check_mii_busy; // wait for scan to finish
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0,  1,  2,  3,  4:  i = i + 1;
            13, 14, 15, 16, 17,
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 13;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0,  1,  2,  3,  4:  i = i + 1;
            45, 46, 47, 48, 49,
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 45;
          endcase
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command immediately after scan     ////
  ////  request (with and without preamble)                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 16) // 
  begin
    // TEST 16: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER SCAN REQUEST ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 16: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER SCAN REQUEST ( WITH AND WITHOUT PREAMBLE )";
    `TIME; 
    $display("  TEST 16: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER SCAN REQUEST ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after scan will be finished
        begin
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // scan request
          #Tp mii_scan_req(phy_addr, reg_addr);
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while scan in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for scan to finish
              @(posedge wb_clk);
              disable check;
            end
            begin: check
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          join
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after scan was finished
          phy_data = {8'h7D, (i[7:0] + 1'b1)};
          cnt = 0;
          if (i3 == 0) // write after scan
          begin
            // write request
            #Tp mii_write_req(phy_addr, reg_addr, phy_data);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after scan
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command after 2. scan (with and    ////
  ////  without preamble)                                         ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 17) // 
  begin
    // TEST 17: SLIDING STOP SCAN COMMAND AFTER 2. SCAN ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 17: SLIDING STOP SCAN COMMAND AFTER 2. SCAN ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 17: SLIDING STOP SCAN COMMAND AFTER 2. SCAN ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
  
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after scan will be finished
        begin
          // first there are two scans
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // scan request
          #Tp mii_scan_req(phy_addr, reg_addr);
          // wait and check first 2 scans
          begin
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            // check transfer length
            if (i2) // without preamble
            begin
              if (cnt != 33) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
            else // with preamble
            begin
              if (cnt != 65) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
            cnt = 0;
            // wait for serial bus to become active if there is more than one scan
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            // check transfer length
            if (i2) // without preamble
            begin
              if (cnt != 33) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
            else // with preamble
            begin
              if (cnt != 65) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
          end
  
          // reset counter 
          cnt = 0;
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while scan in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for scan to finish
              @(posedge wb_clk);
              disable check_3;
            end
            begin: check_3
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          join
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after scan was finished
          phy_data = {8'h7D, (i[7:0] + 1'b1)};
          cnt = 0;
          if (i3 == 0) // write after scan
          begin
            // write request
            #Tp mii_write_req(phy_addr, reg_addr, phy_data);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after scan
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end

end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mii

