`timescale 1ns/1ns
module tb_dummy2_ahb_to_apb;

  // Testbench parameters
  parameter ADDR_WIDTH = 32;
  parameter PDATA_SIZE =  8;
  parameter DATA_WIDTH = 32;

  // Testbench signals
  reg                           HRESETn;
  reg                           HCLK;
  reg                           HSEL;
  reg  [ADDR_WIDTH-1:0]         HADDR;
  reg  [DATA_WIDTH-1:0]         HWDATA;
  reg                           HWRITE;
  reg  [2:0]                    HSIZE;
  reg  [2:0]                    HBURST;
  reg  [3:0]                    HPROT;
  reg  [1:0]                    HTRANS;
  reg                           HMASTERLOCK;
  reg                           HREADYIN;
  wire                          HREADYOUT;
  wire [DATA_WIDTH-1:0]         HRDATA;
  wire                          HRESP;

  reg                           PRESETn;
  reg                           PCLK;
  wire                          PSEL;
  wire                          PENABLE;
  wire [2:0]                    PPROT;
  wire                          PWRITE;
  wire [(DATA_WIDTH/8)-1:0]     PSTRB;
  wire [ADDR_WIDTH-1:0]         PADDR;
  wire [DATA_WIDTH-1:0]         PWDATA;
  reg  [DATA_WIDTH-1:0]         PRDATA;
  reg                           PREADY;
  reg                           PSLVERR;

  // Instantiate the DUT (Device Under Test)
  dummy2_ahb_to_apb #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .HRESETn(HRESETn),
    .HCLK(HCLK),
    .HSEL(HSEL),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HBURST(HBURST),
    .HPROT(HPROT),
    .HTRANS(HTRANS),
    .HMASTERLOCK(HMASTERLOCK),
    .HREADYIN(HREADYIN),
    .HREADYOUT(HREADYOUT),
    .HRDATA(HRDATA),
    .HRESP(HRESP),
    .PRESETn(PRESETn),
    .PCLK(PCLK),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PPROT(PPROT),
    .PWRITE(PWRITE),
    .PSTRB(PSTRB),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
  );
 //reg [DATA_WIDTH-1:0] read_data;
  // Clock generation
  always #5 HCLK = ~HCLK;
  always #10 PCLK = ~PCLK;

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
            @(posedge PCLK); 
        while(PSEL == 0) begin
            @(posedge PCLK);
        end   
        PREADY  = 1;
        @(posedge PCLK); 
        PREADY  = 0;
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
    input [31:0] data;
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
         HTRANS  = 2'b00;   
        @(posedge PCLK); 
        while(PSEL == 0) begin
            @(posedge PCLK);
        end   
            PRDATA  = data;
            PREADY  = 1;
            @(posedge PCLK); 
            PREADY  = 0;
       
      @(posedge HCLK);
         while (!HREADYOUT) begin
           @(posedge HCLK);
        end
          
         $display("AHB_READ completed from address 0x%h with data 0x%h\n", address, HRDATA);     
            @(posedge HCLK);
       
    end
endtask


  // Test sequence
  initial begin
    // Initialize signals
    HRESETn = 1'b1;
    HCLK = 1'b0;
    HSEL = 1'b0;
    HADDR = 'd0;
    HWDATA = 'd0;
    HWRITE = 1'b0;
    HSIZE = 'd0;
    HBURST = 'd0;
    HPROT = 'd0;
    HTRANS = 'd0;
    HMASTERLOCK = 1'b0;
    HREADYIN = 1'b1;

    PRESETn = 1'b1;
    PCLK = 1'b0;
    PRDATA = 'd0;
    PREADY = 1'b0;
    PSLVERR = 1'b0;

    // Reset DUT
    reset_dut;

    // AHB write operation
     //AHB_WRITE(32'b0000_1111, 32'hDEAD_BEEF, 3'b010);
    // AHB_WRITE(32'b0000_0110, 32'h1000_1001, 3'b010);
    // AHB_READ(32'b1000_1000, 8'b0000_1001, 3'b010);
     //AHB_READ(32'b1000_1100, 32'h0000_00ff, 3'b010);
    //AHB_READ(32'b1000_1110, 32'h0000_0fff, 3'b010);
    //AHB_READ(32'b1000_1111, 32'h0000_ffff, 3'b010);
    AHB_WRITE(32'b0000_1000, 32'h0000_0001, 3'b010);
    
    // AHB read operation
   // ahb_read(32'h0000_0001, 3'b010);
  //  $display("AHB Read Data: %h", read_data);

    // Finish simulation
    #100;
    $stop;
  end

endmodule 
