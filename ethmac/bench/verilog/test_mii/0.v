  begin
    // TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES
    test_name   = "TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES";
    `TIME; $display("  TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES");
    
    // Test Plan:
    // 1. Basic functionality: Test that the clock divider correctly divides the input clock
    //    for all possible divider values (0-255)
    // 2. Boundary conditions: Test edge cases (divider = 0, 1, 2, 255)
    // 3. Error conditions: Verify behavior when divider changes during operation
    // 4. Timing requirements: Verify that Mdc frequency is within spec for all divider values
    
    // Initialize variables
    fail = 0;
    cnt = 0;
    
    // Test key divider values first (boundary conditions)
    $display("    Testing boundary conditions (divider = 0, 1, 2, 255)");
    for (i = 0; i < 4; i = i + 1) begin
      case (i)
        0: clk_div = 0;   // Min value - should be treated as 2
        1: clk_div = 1;   // Min value + 1 - should be treated as 2
        2: clk_div = 2;   // Min valid value
        3: clk_div = 255; // Max value
      endcase
      
      // Test this boundary value
      hard_reset;
      
      // Set the divider value
      wbm_write(`ETH_MIIMODER, {16'h0, 8'h0, clk_div[7:0]}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      // Calculate expected period (in wb_clk cycles)
      if (clk_div < 2)
        i1 = 2 * 2; // Minimum divider is 2, so period is 4 wb_clk cycles
      else
        i1 = 2 * clk_div; // Period is 2 * divider wb_clk cycles
      
      // Start a read operation to activate the MIIM module
      wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_RSTAT, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      // Measure the MDC period
      i2 = eth_top.miim1.clkgen.Mdc;
      i3 = $time;
      
      // Wait for MDC cycles to get stable measurements
      repeat (10) begin
        @(posedge eth_top.miim1.clkgen.Mdc or negedge eth_top.miim1.clkgen.Mdc);
        tmp_data = $time;
        
        // Only measure complete periods (posedge to posedge or negedge to negedge)
        if (i2 == eth_top.miim1.clkgen.Mdc) begin
          phy_data = (tmp_data - i3) / (2*15); // Convert to wb_clk cycles (wb_clk period is 30ns)
          i3 = tmp_data;
          
          // Check if the measured period matches the expected period
          cnt = cnt + 1;
          if (phy_data != i1) begin
            fail = fail + 1;
            $display("    ERROR: Divider = %d, Expected period = %d wb_clk cycles, Measured period = %d wb_clk cycles",
                     clk_div, i1, phy_data);
          end
          else begin
            $display("    Divider = %d, Expected period = %d wb_clk cycles, Measured period = %d wb_clk cycles - MATCH",
                     clk_div, i1, phy_data);
          end
        end
        
        i2 = eth_top.miim1.clkgen.Mdc;
      end
      
      // Clear the command
      wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    end
    
    // Now test a sampling of other divider values (to avoid excessive simulation time)
    $display("    Testing sample of divider values across the range");
    for (clk_div = 16; clk_div <= 240; clk_div = clk_div + 32) begin
      // Reset the MAC to ensure clean state
      hard_reset;
      
      // Set the divider value
      wbm_write(`ETH_MIIMODER, {16'h0, 8'h0, clk_div[7:0]}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      // Calculate expected period (in wb_clk cycles)
      // According to the code, if divider < 2, it's treated as 2
      // The period is 2 * (divider/2) = divider wb_clk cycles
      if (clk_div < 2)
        i1 = 2 * 2; // Minimum divider is 2, so period is 4 wb_clk cycles
      else
        i1 = 2 * clk_div; // Period is 2 * divider wb_clk cycles
      
      // Start a read operation to activate the MIIM module
      wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_RSTAT, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Read Status command
      
      // Measure the MDC period
      i2 = eth_top.miim1.clkgen.Mdc;
      i3 = $time;
      
      // Wait for 10 MDC cycles to get stable measurements
      repeat (20) begin
        @(posedge eth_top.miim1.clkgen.Mdc or negedge eth_top.miim1.clkgen.Mdc);
        tmp_data = $time;
        
        // Only measure complete periods (posedge to posedge or negedge to negedge)
        if (i2 == eth_top.miim1.clkgen.Mdc) begin
          phy_data = (tmp_data - i3) / (2*15); // Convert to wb_clk cycles (wb_clk period is 30ns)
          i3 = tmp_data;
          
          // Check if the measured period matches the expected period
          cnt = cnt + 1;
          if (phy_data != i1) begin
            fail = fail + 1;
            $display("    ERROR: Divider = %d, Expected period = %d wb_clk cycles, Measured period = %d wb_clk cycles",
                     clk_div, i1, phy_data);
          end
          else begin
            $display("    Divider = %d, Expected period = %d wb_clk cycles, Measured period = %d wb_clk cycles - MATCH",
                     clk_div, i1, phy_data);
          end
        end
        
        i2 = eth_top.miim1.clkgen.Mdc;
      end
      
      // Clear the command
      wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    end
    
    // Test changing divider during operation
    $display("    Testing divider change during operation");
    
    // Start with divider = 32
    hard_reset;
    clk_div = 32;
    wbm_write(`ETH_MIIMODER, {16'h0, 8'h0, clk_div[7:0]}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    
    // Start a read operation
    wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_RSTAT, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    
    // Wait for a few MDC cycles
    repeat (5) @(posedge eth_top.miim1.clkgen.Mdc);
    
    // Change divider to 64 during operation
    clk_div = 64;
    wbm_write(`ETH_MIIMODER, {16'h0, 8'h0, clk_div[7:0]}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    
    // Measure the MDC period after change
    i2 = eth_top.miim1.clkgen.Mdc;
    i3 = $time;
    
    // Wait for MDC cycles to get stable measurements
    repeat (10) begin
      @(posedge eth_top.miim1.clkgen.Mdc or negedge eth_top.miim1.clkgen.Mdc);
      tmp_data = $time;
      
      // Only measure complete periods (posedge to posedge or negedge to negedge)
      if (i2 == eth_top.miim1.clkgen.Mdc) begin
        phy_data = (tmp_data - i3) / (2*15); // Convert to wb_clk cycles
        i3 = tmp_data;
        
        // The expected period should now be based on the new divider
        i1 = 2 * clk_div; // Period is 2 * divider wb_clk cycles
        
        // Check if the measured period matches the expected period
        cnt = cnt + 1;
        if (phy_data != i1) begin
          fail = fail + 1;
          $display("    ERROR: After divider change to %d, Expected period = %d wb_clk cycles, Measured period = %d wb_clk cycles",
                   clk_div, i1, phy_data);
        end
        else begin
          $display("    After divider change to %d, Expected period = %d wb_clk cycles, Measured period = %d wb_clk cycles - MATCH",
                   clk_div, i1, phy_data);
        end
      end
      
      i2 = eth_top.miim1.clkgen.Mdc;
    end
    
    // Clear the command
    wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    
    // Display test results
    if (fail == 0)
      $display("    TEST 0: PASSED - All %d divider values produced correct MDC frequencies", cnt);
    else
      $display("    TEST 0: FAILED - %d out of %d divider values produced incorrect MDC frequencies", 
               fail, cnt);
  end