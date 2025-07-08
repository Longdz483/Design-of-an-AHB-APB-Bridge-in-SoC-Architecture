

`timescale 1ns/1ns
`include "define.v"
module testcase4_3_prefix_cnt_up_load;
  
      // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter APB_ADDR_WIDTH = 12;
    parameter P_PSEL0_START = 16'hC000, P_PSEL0_SIZE = 16'h0010;
    parameter P_PSEL1_START = 16'hC010, P_PSEL1_SIZE = 16'h0010;
    parameter P_PSEL2_START = 16'hC020, P_PSEL2_SIZE = 16'h0010;
    parameter P_PSEL3_START = 16'hC030, P_PSEL3_SIZE  = 16'h0010;
    parameter P_PSEL4_START = 16'hC040, P_PSEL4_SIZE  = 16'h0010;
    parameter P_PSEL5_START = 16'hC050, P_PSEL5_SIZE  = 16'h0010;
    parameter SIZE_IN_BYTES = 1024;
    
    // Signals
    reg        HRESETn;
    reg        HCLK;
    reg        HSEL;
    reg [ADDR_WIDTH-1:0] HADDR;
    reg [1:0]  HTRANS;
    reg [3:0]  HPROT;
    reg        HWRITE;
    reg [2:0]  HSIZE;
    reg [2:0]  HBURST;
    reg [31:0] HWDATA;
    wire [7:0] HRDATA;
    wire       HRESP;
    reg        HMASTERLOCK;
    reg        HREADYIN;
    wire       HREADYOUT;
    reg        PCLK;
    reg        PRESETn;
    wire       PENABLE;
    wire [APB_ADDR_WIDTH-1:0] PADDR;
    wire       PWRITE;
    wire [DATA_WIDTH-1:0] PWDATA;
    wire       timer_PSEL1; //ram1
    wire [7:0] timer_PRDATA1;//ram1
    wire       timer_PREADY1;//ram1
    wire       timer_PSLVERR1;//ram1
    ///
    wire [2:0] PPROT;
    wire [3:0] PSTRB;
    //wire [DATA_WIDTH -1 :0] i_WRDATA;
    //wire [APB_ADDR_WIDTH -1 :0] i_PADDR;
    // Instantiate the DUT
  ahb_to_apb_s3 #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
   // .P_PSEL0_START(P_PSEL0_START),
   // .P_PSEL0_SIZE(P_PSEL0_SIZE),
    .P_PSEL1_START(P_PSEL1_START),
    .P_PSEL1_SIZE(P_PSEL1_SIZE)
   // .P_PSEL2_START(P_PSEL2_START),
  //  .P_PSEL2_SIZE(P_PSEL2_SIZE),
  //  .P_PSEL3_START(P_PSEL3_START),
  // .P_PSEL3_SIZE(P_PSEL3_SIZE),
   // .P_PSEL4_START(P_PSEL4_START),
  //  .P_PSEL4_SIZE(P_PSEL4_SIZE),
  //  .P_PSEL5_START(P_PSEL5_START),
  //  .P_PSEL5_SIZE(P_PSEL5_SIZE)
    ) uut (
      .HRESETn(HRESETn),
      .HCLK(HCLK),
      .HSEL(HSEL),
      .HADDR(HADDR),
      .HTRANS(HTRANS),
      .HPROT(HPROT),
      .HWRITE(HWRITE),
      .HSIZE(HSIZE),
      .HBURST(HBURST),
      .HWDATA(HWDATA),
      .HRDATA(HRDATA),
      .HRESP(HRESP),
      .HMASTERLOCK(HMASTERLOCK),
      .HREADYIN(HREADYIN),
      .HREADYOUT(HREADYOUT),
      .PCLK(PCLK),
      .PRESETn(PRESETn),
      .PENABLE(PENABLE),
      .PADDR(PADDR),
      .PWRITE(PWRITE),
      .PWDATA(PWDATA),
      .PSEL1(timer_PSEL1),
      .PRDATA1(timer_PRDATA1),
      .PREADY1(timer_PREADY1),
      .PSLVERR1(timer_PSLVERR1),
      .PPROT(PPROT),
      .PSTRB(PSTRB)
    );
    
  // Instantiate the DUT (Device Under Test)
  timer_8bit dut (
    .pclk      (PCLK),
    .presetn  (PRESETn),
    .psel      (timer_PSEL1),
    .penable   (PENABLE),
    .pwrite    (PWRITE),
    .paddr     (PADDR),
    .pwdata    (PWDATA),
    .prdata    (timer_PRDATA1),
    .pready    (timer_PREADY1),
    .pslverr   (timer_PSLVERR1)
  );

    
    reg [31:0] expected_data [0:3]; // Array to store expected data for burst transactions
        reg test_passed;
        reg [31:0] data_burst [0:1023];
        integer   i; 
      // Clock Generation
      always #5 HCLK = ~HCLK;
      always #10 PCLK = ~PCLK;
    
      // Test Sequence
      initial begin
        // Initialize signals
        HCLK = 0;
        PCLK = 0;
        HRESETn = 0;
        PRESETn = 0;
        HSEL = 0;
        HADDR = 0;
        HTRANS = 0;
        HPROT = 0;
        HWRITE = 0;
        HSIZE = 0;
        HBURST = 0;
        HWDATA = 0;
        HMASTERLOCK = 0;
        HREADYIN = 1;
        test_passed = 1;
        reset_dut;
        #200;
        //Test info
        $display("==================================================");
        $display("=============== COUNT UP WITH LOAD ==============");
        $display("==================================================");
        
		testcase;
    #100;
    $stop;
     end
     task testcase;
      reg[7:0]  init_value;
      reg[7:0]  wait_cycles_1; 
      reg[7:0]  wait_cycles_2;
      begin
        //step 1 configuration 
        //STEP1
        //TIMER CONFIGURATION
         $display("------------------------------------------------");
         $display("STEP1: TIMER CONFIGRUATION");
     $display("At time %0d, Generated init value for Timer Counter",$time);
     init_value = $random;
     if(init_value < 8'd50) begin 
      init_value = init_value + 50;
      $display(" At time %0d, init_value is smaller than 50 --> add 50", $time);
     end 
     else if(init_value > 8'd150) begin
      init_value = init_value - 100;
      $display(" At time %0d, init_value is greated than 150 --> sub 100 ", $time);
     end
     else begin 
       $display(" At time %0d, init_value is in range 50 --> 150 ", $time);
     end
        //wait cycles 1: not overflow
    //wait cycles 2: overflow
     
     wait_cycles_2 = 256 - init_value;
     wait_cycles_1 = wait_cycles_2 - 20;
     $display(" At time %0d, wait_cycles_1 = %0d ", $time, wait_cycles_1);
     $display(" At time %0d, wait_cycles_2 = %0d ", $time, wait_cycles_2);
     // generated initial value of TDR and TCR 
     $display("\nAt %0d Starting counting to TDR at %0d ",$time, init_value);
     AHB_WRITE(32'hc010_0000, init_value,3'b010);
     $display("\nAt %0d Start load count to TCR at %0d ",$time, init_value);
     AHB_WRITE(32'hc010_0001, 8'h80,3'b010);
     $display ("At time %0d, write TCR to start timer", $time);
     AHB_WRITE(32'hc010_0001, 8'h10,3'b010);
//STEP2
     $display("\n------------------------------------------------");
     $display("STEP2: CHECK OVERFLOW FLAG");
     fork
      //STEP 2.1
      $display("\nAt time %0d, waiting for ovf", $time);
      begin
              repeat (`PER_CLK_2 * wait_cycles_1) @(posedge PCLK);

              $display("At time %0d, after 220 clk_cnt, read TSR", $time);
              AHB_READ(32'hc010_0002, 3'b010);
      end
      begin
              repeat (`PER_CLK_2 * wait_cycles_2) @(posedge PCLK);
                              
              $display("\nAt time %0d, after 256 clk_cnt, read TSR (STEP 2.2)", $time);
              AHB_READ(32'hc010_0002, 3'b010);
      end
      join
      //STEP 3
      $display("\n-------------------------------------------------");
      $display("STEP 3: CLEAR TSR");
      $display("At time %0d, clear TSR", $time);
      //top.CPU.write_data(`TSR, 8'h00);
      AHB_WRITE(32'hc010_0002,8'h00, 3'b010);
      //STEP 4
      $display("\n-------------------------------------------------");
      $display("STEP 4: READ TSR");
      $display("At time %0d, read TSR", $time);
      AHB_READ(32'hc010_0002, 3'b010);
    end
     endtask

      task reset_dut;
        begin
          HRESETn = 1'b0;
          PRESETn = 1'b0;
          #20;
          HRESETn = 1'b1;
          PRESETn = 1'b1;
          $display("Reset completed at time %t", $time);
        end
      endtask
 
           // Task to perform AHB Write (Address Phase + Data Phase)
        task AHB_WRITE;
            input [ADDR_WIDTH-1:0] address;
            input [31:0] data;
            input [2:0] size;
            
            begin
             $display( " Starting AHB_WRITE to address 0x%h with data 0x%h", address, data);
                @(posedge HCLK);  // Wait for rising edge of clock
                HSEL    = 1;
                HADDR   = address;
                HWRITE  = 1;
                HSIZE   = size;
                HTRANS  = 2'b10;   // Non-sequential transfer
                HREADYIN  = 1;
    
                // Address phase
                @(posedge HCLK);
               while (!HREADYOUT) begin
                 @(posedge HCLK);
               end
                HWDATA  = data;
                HTRANS  = 2'b00;   // Idle
                // Wait for write completion
                 @(posedge HCLK);
                while (~HREADYOUT) begin
                    @(posedge HCLK);
                end
                // De-assert signals after the transaction
                  $display("AHB_WRITE completed to address 0x%h with data 0x%h\n", address, data);
                @(posedge HCLK);
               
            end
        endtask
     
     // Task to perform AHB Read (Address Phase + Data Phase)
    task AHB_READ;
        input [ADDR_WIDTH-1:0] address;
    
        input [2:0] size;
         
        begin
          $display("Starting AHB_READ from address 0x%h", address);
            @(posedge HCLK);  // Ch? ??n c?nh l?n c?a clock
    
            // Giai ?o?n ??a ch? (Address Phase)
            HSEL    = 1;               // Ch?n slave AHB
            HADDR   = address;         // ??t ??a ch?
            HWRITE  = 0;               // ??c d? li?u
            HSIZE   = 3'b010;          // K?ch th??c d? li?u 32-bit
            HTRANS  = 2'b10;           // Non-sequential transfer
            HREADYIN  = 1;               // S?n s?ng cho giao ti?p
            @(posedge HCLK);
              while (!HREADYOUT) begin
               @(posedge HCLK);
            end
          
           HTRANS  = 2'b00; 
          @(posedge HCLK);
              while (!HREADYOUT) begin
                @(posedge HCLK);
            end   
             $display("AHB_READ completed from address 0x%h with data 0x%h\n", address, HRDATA);     
                @(posedge HCLK);
           
        end
    endtask
    
endmodule


