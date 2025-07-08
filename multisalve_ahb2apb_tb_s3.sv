//------------------------------------------------------------------------------
// Design and create by Stublid_20th01 ----> ducanhdinh---> ducanhld15@gmail.com
//------------------------------------------------------------------------------
`timescale 1ns / 1ns

module tb_ahb_to_apb_s3;

  // Parameters
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  parameter P_NUM = 4;
  parameter P_PSEL0_START = 16'hC000, P_PSEL0_SIZE = 16'h0010;
  parameter P_PSEL1_START = 16'hC010, P_PSEL1_SIZE = 16'h0010;
  parameter P_PSEL2_START = 16'hC020, P_PSEL2_SIZE = 16'h0010;
  parameter P_PSEL3_START = 16'hC030, P_PSEL3_SIZE = 16'h0010;

  // Clock and Reset
  reg HCLK;
  reg HRESETn;
  reg PCLK;
  reg PRESETn;

  // AHB signals
  reg HSEL;
  reg [ADDR_WIDTH-1:0] HADDR;
  reg [1:0] HTRANS;
  reg [3:0] HPROT;
  reg HWRITE;
  reg [2:0] HSIZE;
  reg [2:0] HBURST;
  reg [31:0] HWDATA;
  wire [31:0] HRDATA;
  wire        HRESP;
  reg HMASTERLOCK;
  reg HREADYIN;
  wire HREADYOUT;

  // APB signals
  wire PENABLE;
  wire [ADDR_WIDTH-1:0] PADDR;
  wire PWRITE;
  wire [DATA_WIDTH-1:0] PWDATA;
  wire PSEL0, PSEL1, PSEL2,PSEL3;
  reg [DATA_WIDTH-1:0] PRDATA0, PRDATA1, PRDATA2,PRDATA3;
  reg PREADY0, PREADY1, PREADY2,PREADY3;
  reg PSLVERR0, PSLVERR1, PSLVERR2,PSLVERR3;
  wire [2:0] PPROT;
  wire [3:0] PSTRB;

  // Instantiate the DUT
  ahb_to_apb_s3 #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .P_NUM (P_NUM),
    .P_PSEL0_START(P_PSEL0_START),
    .P_PSEL0_SIZE(P_PSEL0_SIZE),
    .P_PSEL1_START(P_PSEL1_START),
    .P_PSEL1_SIZE(P_PSEL1_SIZE),
    .P_PSEL2_START(P_PSEL2_START),
    .P_PSEL2_SIZE(P_PSEL2_SIZE),
    .P_PSEL3_START(P_PSEL2_START),
    .P_PSEL3_SIZE(P_PSEL2_SIZE)
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
    .PSEL0(PSEL0),
    .PRDATA0(PRDATA0),
    .PREADY0(PREADY0),
    .PSLVERR0(PSLVERR0),
    .PSEL1(PSEL1),
    .PRDATA1(PRDATA1),
    .PREADY1(PREADY1),
    .PSLVERR1(PSLVERR1),
    .PSEL2(PSEL2),
    .PRDATA2(PRDATA2),
    .PREADY2(PREADY2),
    .PSLVERR2(PSLVERR2),
    .PSEL3(PSEL3),
    .PRDATA3(PRDATA3),
    .PREADY3(PREADY3),
    .PSLVERR3(PSLVERR3),
    .PPROT(PPROT),
    .PSTRB(PSTRB)
  );

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
    
    PRDATA0 = 32'h12345678;
    PRDATA1 = 32'h87654321;
    PRDATA2 = 32'hABCDEF00;
    PRDATA3 = 0;
    PREADY0 = 1;
    PREADY1 = 1;
    PREADY2 = 1;
    PREADY3 = 1;
    PSLVERR0 = 0;
    PSLVERR1 = 0;
    PSLVERR2 = 0;
    PSLVERR3 = 0;
    $display("Design and create by Stublid_20th01 ----> ducanhdinh---> ducanhld15@gmail.com");
    $display("Design and create by Stublid_20th01 ----> ducanhdinh---> ducanhld15@gmail.com");
    // Reset DUT
    reset_dut;

    // AHB write operation
    AHB_WRITE(32'hc000_0004, 32'hDEAD_BEEF, 3'b010);
    AHB_WRITE(32'hc010_0100, 32'h1000_1001, 3'b010);
    AHB_WRITE(32'hc002_0400, 32'h1234_B0E1, 3'b010); 
    AHB_WRITE(32'hc020_1000, 32'h000f_11f0, 3'b010);
    AHB_WRITE(32'hc000_1000, 32'hffff_aa1a, 3'b010);
    AHB_WRITE(32'hc020_0005, 32'h1111_0011, 3'b010);
    AHB_WRITE(32'hc030_0005, 32'h0011_0011, 3'b010);
    AHB_WRITE(32'hc030_0015, 32'h0011_0011, 3'b010);
    
    // AHB read operation
    AHB_READ(32'hc000_0004, 32'hDEAD_BEEF, 3'b010);
    AHB_READ(32'hc010_0100, 32'h1000_1001, 3'b010);
    AHB_READ(32'hc002_0400, 32'h1234_B0E1, 3'b010); 
    AHB_READ(32'hc020_1000, 32'h000f_11f0, 3'b010);
    AHB_READ(32'hc000_1000, 32'hffff_aa1a, 3'b010);
    AHB_READ(32'hc020_0005, 32'h1111_0011, 3'b010);
    AHB_READ(32'hc030_0005, 32'h1011_0000, 3'b010);
    AHB_READ(32'hc030_0015, 32'h2211_0011, 3'b010);
    
    // AHB read operation
   // ahb_read(32'h0000_0001, 3'b010);
  //  $display("AHB Read Data: %h", read_data);

    // Finish simulation
    #100;
    $stop;
  end
 


  // Task to reset the DUT
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
            //HREADY = 1;
            // Wait for write completion
             @(posedge HCLK);
            while (~HREADYOUT) begin
                @(posedge HCLK);
            end
            // De-assert signals after the transaction
              $display("AHB_WRITE completed to address 0x%h with data 0x%h\n", address, data);
            @(posedge HCLK);
            //HWDATA = 'bx;
           // @(posedge HCLK);
        end
    endtask
 
 // Task to perform AHB Read (Address Phase + Data Phase)
task AHB_READ;
    input [ADDR_WIDTH-1:0] address;
    //output [31:0] data;
    input [31:0] expected_data;
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

       // @(posedge HCLK);           // Chuy?n ??n giai ?o?n d? li?u (Data Phase)

        // K?t th?c qu? tr?nh ??c, ??a bus v? tr?ng th?i Idle
        
        //HSEL    = 0;               // Ng?t k?t n?i v?i slave
        
        @(posedge HCLK);
          while (!HREADYOUT) begin
           @(posedge HCLK);
        end
       // data = HRDATA;
       HTRANS  = 2'b00; 
      // PRDATA0  = expected_data;  // Example APB data response  
       //PRDATA1  = expected_data;  // Example APB data response
       //PRDATA2  = expected_data;  // Example APB data response 
       PRDATA3  = expected_data;  // Example APB data response    
      @(posedge HCLK);
          while (!HREADYOUT) begin
            @(posedge HCLK);
        end   
         $display("AHB_READ completed from address 0x%h with data 0x%h\n", address, HRDATA);     
            @(posedge HCLK);
       
    end
endtask
endmodule
