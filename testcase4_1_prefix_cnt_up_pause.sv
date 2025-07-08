

`timescale 1ns/1ns
`include "define.v"
module testcase4_1_prefix_cnt_up_pause;
  
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
		$display("============== COUNT UP WITH PAUSE  ==============");
		$display("==================================================");
        $display("------------------------------------------------");
        
		testcase;
    #100;
    $stop;
     end
     task testcase;
        reg [7:0]		pause_after_n_cycles, remaining_cycles;
        //STEP1
			//TIMER CONFIGURATION
			$display("\n------------------------------------------------");
			$display("STEP1: TIMER CONFIGRUATION");
			pause_after_n_cycles = $random();
			remaining_cycles = 256 - pause_after_n_cycles;
			$display ("At time %0d, pause_after_n_cycles is %0d", $time, 	pause_after_n_cycles);
			$display ("At time %0d, write TCR to start timer with clk2", $time);
            AHB_WRITE(32'hc010_0001,8'h10,3'b010);
            
			//STEP 2
			$display("------------------------------------");
			$display("STEP 2: Pause timer after %0d cycles", pause_after_n_cycles);
			$display("At time %0d, wait for %0d cycles", $time, pause_after_n_cycles);
			repeat (pause_after_n_cycles * `PER_CLK_2) @(posedge PCLK);
			$display ("At time %0d, write TCR to pause timer", $time);	
			AHB_WRITE(32'hc010_0001,8'h00,3'b010);
			#200;
			$display("At time %0d, write TCR to start timer again", $time);
			AHB_WRITE(32'hc010_0001,8'h10,3'b010);
            //STEP 3
			$display("------------------------------------");
			$display("STEP 3: Wait for timer to finish counting");
			$display("At time %0d, wait for %0d cycles", $time, remaining_cycles);
			repeat (remaining_cycles * `PER_CLK_2) @(posedge PCLK);
            //STEP 4
			$display("------------------------------------");
			$display("STEP 4: Check TSR");
			$display("At time %0d, after %0d clk_int, read TSR", $time, remaining_cycles);
			AHB_READ(32'hc010_0002,3'b010);
            //STEP 5
			$display("\n-------------------------------------------------");
			$display("STEP 5: CLEAR TSR AND DOUBLE CHECK TSR");
			$display("At time %0d, clear TSR", $time);
			AHB_WRITE(32'hc010_0002,8'h00,3'b010);
            $display("At time %0d, read TSR", $time);
			AHB_READ(32'hc010_0002,3'b010);
			
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
