
//`timescale 1ns/1ps
`timescale 1ns/1ns
module case_2_test_more_single_rw;
  
  // Parameters
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  parameter APB_ADDR_WIDTH = 12;
  parameter P_PSEL0_START = 16'hC000, P_PSEL0_SIZE = 16'h0010;
  parameter P_PSEL1_START = 16'hC010, P_PSEL1_SIZE = 16'h0010;
  parameter P_PSEL2_START = 16'hC020, P_PSEL2_SIZE = 16'h0010;
 // parameter P_PSEL3_START = 16'hC030, P_PSEL3_SIZE  = 16'h0010;
 // parameter P_PSEL4_START = 16'hC040, P_PSEL4_SIZE  = 16'h0010;
 // parameter P_PSEL5_START = 16'hC050, P_PSEL5_SIZE  = 16'h0010;
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
  wire [31:0] HRDATA;
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
  wire       ram0_PSEL0;
  wire [DATA_WIDTH-1:0]  ram0_PRDATA0;
  wire       ram0_PREADY0;
  wire       ram0_PSLVERR0;
  
  wire       ram1_PSEL1; //ram1
  wire [DATA_WIDTH-1:0] ram1_PRDATA1;//ram1
  wire       ram1_PREADY1;//ram1
  wire       ram1_PSLVERR1;//ram1
  ///
  wire        ram2_PSEL2;
  wire [DATA_WIDTH -1:0] ram2_PRDATA2;

  wire        ram2_PREADY2;
  wire        ram2_PSLVERR2;

  
  wire [2:0] PPROT;
  wire [3:0] PSTRB;
  
  
  
  // Instantiate the DUT
ahb_to_apb_s3 #(
  .ADDR_WIDTH(ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH),
  .P_PSEL0_START(P_PSEL0_START),
  .P_PSEL0_SIZE(P_PSEL0_SIZE),
  .P_PSEL1_START(P_PSEL1_START),
  .P_PSEL1_SIZE(P_PSEL1_SIZE),
  .P_PSEL2_START(P_PSEL2_START),
  .P_PSEL2_SIZE(P_PSEL2_SIZE)
  //.P_PSEL3_START(P_PSEL3_START),
  //.P_PSEL3_SIZE(P_PSEL3_SIZE),
  //.P_PSEL4_START(P_PSEL4_START),
  //.P_PSEL4_SIZE(P_PSEL4_SIZE),
 // .P_PSEL5_START(P_PSEL5_START),
 // .P_PSEL5_SIZE(P_PSEL5_SIZE)
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
  .PSEL0(ram0_PSEL0),
  .PRDATA0(ram0_PRDATA0),
  .PREADY0(ram0_PREADY0),
  .PSLVERR0(ram0_PSLVERR0),
  .PSEL1(ram1_PSEL1),
  .PRDATA1(ram1_PRDATA1),
  .PREADY1(ram1_PREADY1),
  .PSLVERR1(ram1_PSLVERR1),
  .PSEL2(ram2_PSEL2),
  .PRDATA2(ram2_PRDATA2),
  .PREADY2(ram2_PREADY2),
  .PSLVERR2(ram2_PSLVERR2),
  .PPROT(PPROT),
  .PSTRB(PSTRB)
);

mem_apb #(.SIZE_IN_BYTES(SIZE_IN_BYTES)) dut_0 (
  .PRESETn(HRESETn),
  .PCLK(PCLK),
  .PSEL(ram0_PSEL0),
  .PENABLE(PENABLE),
  .PADDR(PADDR),
  .PWRITE(PWRITE),
  .PRDATA(ram0_PRDATA0),
  .PWDATA(PWDATA),
  .PREADY(ram0_PREADY0),
  .PSLVERR(ram0_PSLVERR0),
  .PSTRB(PSTRB),
  .PPROT(PPROT)
); 
mem_apb #(.SIZE_IN_BYTES(SIZE_IN_BYTES)) dut_1 (
  .PRESETn(HRESETn),
  .PCLK(PCLK),
  .PSEL(ram1_PSEL1),
  .PENABLE(PENABLE),
  .PADDR(PADDR),
  .PWRITE(PWRITE),
  .PRDATA(ram1_PRDATA1),
  .PWDATA(PWDATA),
  .PREADY(ram1_PREADY1),
  .PSLVERR(ram1_PSLVERR1),
  .PSTRB(PSTRB),
  .PPROT(PPROT)
); 


mem_apb #(.SIZE_IN_BYTES(SIZE_IN_BYTES)) dut_2 (
  .PRESETn(HRESETn),
  .PCLK(PCLK),
  .PSEL(ram2_PSEL2),
  .PENABLE(PENABLE),
  .PADDR(PADDR),
  .PWRITE(PWRITE),
  .PRDATA(ram2_PRDATA2),
  .PWDATA(PWDATA),
  .PREADY(ram2_PREADY2),
  .PSLVERR(ram2_PSLVERR2),
  .PSTRB(PSTRB),
  .PPROT(PPROT)
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
    PCLK = 01;
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
$display("Starting TESTCASE 3.2: Burst INCR Transaction... USING PORT 0:");

// Generate random data for burst with increment pattern
data_burst[0] = $urandom_range(32'h0000_0100, 32'h0010_0000); // Giá trị đầu tiên random trong khoảng

for (i = 1; i < 16; i = i + 1) begin
    data_burst[i] = data_burst[i - 1] + 4; // Tăng mỗi lần thêm 4 byte
    // Đảm bảo dữ liệu không vượt quá giới hạn
    if (data_burst[i] > 32'h0010_0000) 
        data_burst[i] = 32'h0000_0100; // Reset về min nếu vượt max
end
/*
// Generate random data for burst
for (i = 0; i < 16; i = i + 1) begin
    data_burst[i] = $random; // Generate random data
end
*/
        //port0
        ahb_write_single(32'hc000_0022, 32'b0000_0011, 3'b010);
        ahb_write_single(32'hc000_0032, 32'b0000_0111, 3'b010);
        ahb_write_single(32'hc000_0042, 32'b0000_1001, 3'b010);
        //ahb_write_single(32'hc000_0052, 32'h0001_1111, 3'b010);
        ////////
        ahb_read_single(32'hc000_0022,3'b010);
        ahb_read_single(32'hc000_0032,3'b010);
        ahb_read_single(32'hc000_0042,3'b010);
        //ahb_read_single(32'hc000_0052,3'b010);
        //////
       
      #40;
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

  task ahb_write_burst_wrap;
    input  [31:0] addr;   // Địa chỉ bắt đầu của burst
    input  [31:0] leng;   // Độ dài burst (4, 8, 16)
    integer i;
    reg [31:0] wrap_mask;

    begin
        wrap_mask = leng - 1;  // Xác định mask để tính wrap address

        $display($time, " Starting AHB WRAP BURST WRITE to base address 0x%h with length %d", addr, leng);
         // Wait until granted and ready
        @ (posedge HCLK);
       while ((HREADYOUT !== 1'b1)) @ (posedge HCLK);
        
        HADDR  <= #1 addr;
        HTRANS <= #1 2'b10; // HTRANS_NONSEQ
        HBURST <= #1 (leng == 4) ? 3'b010 : (leng == 8) ? 3'b100 : (leng == 16) ? 3'b110 : 3'b001; // Chế độ wrap
        HWRITE <= #1 1'b1; // HWRITE_WRITE
        HSIZE  <= #1 3'b010; // 32-bit word
        HSEL   <= #1 1'b1;

        // Vòng lặp ghi dữ liệu trong wrap burst
        for (i = 0; i < leng - 1; i = i + 1) begin
            @ (posedge HCLK);
            while (HREADYOUT == 1'b0) @ (posedge HCLK);

            HWDATA <= #1 data_burst[i % 1024];  // Dữ liệu ghi

            // Tính toán địa chỉ wrap
            HADDR <= #1 (addr & ~(wrap_mask << HSIZE)) | ((HADDR + (1 << HSIZE)) & (wrap_mask << HSIZE));

            $display($time, " Write burst data[%0d] = 0x%0h and address 0x%0h", i, HWDATA, HADDR);           
            HTRANS <= #1 2'b11; // HTRANS_SEQ
            while (HREADYOUT == 1'b0) @ (posedge HCLK); 
        end
        
        // Chuyển bus về trạng thái IDLE
        @ (posedge HCLK);
        while (HREADYOUT == 0) @ (posedge HCLK);
        //HADDR  <= #1 0;
        HTRANS <= #1 0;
        //HBURST <= #1 0;
        //HWRITE <= #1 0;
        //HSIZE  <= #1 0;
        HWDATA <= #1 data_burst[i % 1024];
        @ (posedge HCLK);
        while (HREADYOUT == 0) @ (posedge HCLK);
  
        // Check response for error
        if (HRESP != 1'b0) begin // HRESP_OKAY
            $display($time, " ERROR: Non-OK response on write (HRESP = %b)", HRESP);
        end
        $display("Completed AHB WRAP BURST WRITE to base address 0x%h.\n", addr);
        @ (posedge HCLK);
    end
endtask

  
task ahb_read_burst_wrap;
  input  [31:0] addr;   // Địa chỉ bắt đầu của burst
  input  [31:0] leng;   // Độ dài burst (4, 8, 16)
  integer i;
  reg [31:0] wrap_mask;

  begin
      wrap_mask = leng - 1;  // Xác định phạm vi wrap

      $display("Starting AHB WRAP BURST READ from base address 0x%h with length %d", addr, leng);
      @ (posedge HCLK);
      while ( (HREADYOUT !== 1'b1)) @ (posedge HCLK);

      HADDR  <= #1 addr;
      HTRANS <= #1 2'b10; // HTRANS_NONSEQ
      HBURST <= #1 (leng == 4) ? 3'b010 : (leng == 8) ? 3'b100 : (leng == 16) ? 3'b110 : 3'b001; // Chế độ wrap
      HWRITE <= #1 1'b0; // HWRITE_READ
      HSIZE  <= #1 3'b010; // 32-bit word
      HSEL   <= #1 1'b1;
      @ (posedge HCLK);
          while (HREADYOUT == 1'b0) @ (posedge HCLK);

      // Vòng lặp đọc dữ liệu trong wrap burst
      for (i = 0; i < leng - 1; i = i + 1) begin
         // @ (posedge HCLK);
         // while (HREADYOUT == 1'b0) @ (posedge HCLK);

          // Tính toán địa chỉ wrap
          HADDR <= #1 (addr & ~(wrap_mask << HSIZE)) | ((HADDR + (1 << HSIZE)) & (wrap_mask << HSIZE));

          //if (i < leng -1 ) begin
              HTRANS <= #1 2'b11; // HTRANS_SEQ
         // end
        
          $display($time, " Read burst data[%0d] = 0x%0h from address 0x%0h", i, HRDATA, HADDR);
          CHECK_READ_DATA(HADDR, data_burst[i]); // Kiểm tra dữ liệu đọc
          @ (posedge HCLK);
        while (HREADYOUT == 0) @ (posedge HCLK);
      end

        // Chuyển bus về trạng thái IDLE
        @ (posedge HCLK);
        while (HREADYOUT == 0) @ (posedge HCLK);
      HADDR  <= #1 0;
      HTRANS <= #1 0;
      HBURST <= #1 0;
      HWRITE <= #1 0;
      HSIZE  <= #1 0;
      @ (posedge HCLK);
        while (HREADYOUT == 0) @ (posedge HCLK);
  
        // Check response for error
        if (HRESP != 1'b0) begin // HRESP_OKAY
            $display($time, " ERROR: Non-OK response on read (HRESP = %b)", HRESP);
        end
  
        @ (posedge HCLK);
  end
endtask

task ahb_write_burst_incr;
  input  [31:0] addr;   // Starting address for the burst
  input  [31:0] leng;   // Length of burst (4, 8, 16, etc.)
  integer       i;

  begin
     // @ (posedge HCLK);
    //  HBUSREQ <= #1 1'b1;

      // Wait until granted and ready
      @ (posedge HCLK);
     while ((HREADYOUT !== 1'b1)) @ (posedge HCLK);

      HADDR  <= #1 addr;
      HTRANS <= #1 2'b10; // HTRANS_NONSEQ

      // Set burst type based on length
      if (leng == 4)       HBURST <= #1 3'b011; // HBURST_INCR4
      else if (leng == 8)  HBURST <= #1 3'b101; // HBURST_INCR8
      else if (leng == 16) HBURST <= #1 3'b111; // HBURST_INCR16
      else                 HBURST <= #1 3'b001; // HBURST_INCR
      
      HWRITE <= #1 1'b1; // HWRITE_WRITE
      HSIZE  <= #1 3'b010; // HSIZE_WORD (32-bit word)
      HSEL   <= #1 1'b1;
      // Writing burst
      for (i = 0; i < leng - 1  ; i = i + 1) begin
          @ (posedge HCLK);
          while (HREADYOUT == 1'b0) @ (posedge HCLK);
       
          HWDATA <= #1 data_burst[i % 1024]; 
          HADDR  <= #1 addr + (i + 1) * (1 << HSIZE);
          HTRANS <= #1 2'b11; // HTRANS_SEQ
          while (HREADYOUT == 1'b0) @ (posedge HCLK);
      end
      
      // Set bus to IDLE after burst is complete
      @ (posedge HCLK);
      while (HREADYOUT == 0) @ (posedge HCLK);
      HWDATA <= #1 data_burst[i % 1024];
      //HADDR  <= #1 0;
       HTRANS <= #1 0;
     // HBURST <= #1 0;
      //HWRITE <= #1 0;
      //HSIZE  <= #1 0;
    //  HBUSREQ <= #1 1'b0;

      @ (posedge HCLK);
      while (HREADYOUT == 0) @ (posedge HCLK);

      // Check response for error
      if (HRESP != 1'b0) begin // HRESP_OKAY
          $display($time, " ERROR: Non-OK response on write (HRESP = %b)", HRESP);
      end

      `ifdef DEBUG
      $display($time, " INFO: write(%x, %d, %x)", addr, leng, HWDATA);
      `endif

      //HWDATA <= #1 0;
      @ (posedge HCLK);
  end
endtask


task ahb_read_burst_incr;
  input  [31:0] addr;   // Starting address for the burst
  input  [31:0] leng;   // Length of burst (4, 8, 16, etc.)
  integer       i;

  begin
    //  @ (posedge HCLK);
    //  HBUSREQ <= #1 1'b1;

      // Wait until granted and ready
      @ (posedge HCLK);
      while ( (HREADYOUT !== 1'b1)) @ (posedge HCLK);

      HADDR  <= #1 addr;
      HTRANS <= #1 2'b10; // HTRANS_NONSEQ

      // Set burst type based on length
      if (leng == 4)       HBURST <= #1 3'b011; // HBURST_INCR4
      else if (leng == 8)  HBURST <= #1 3'b101; // HBURST_INCR8
      else if (leng == 16) HBURST <= #1 3'b111; // HBURST_INCR16
      else                 HBURST <= #1 3'b001; // HBURST_INCR
      
      HWRITE <= #1 1'b0; // HWRITE_READ
      HSIZE  <= #1 3'b010; // HSIZE_WORD (32-bit word)
      HSEL   <= #1 1'b1;
      // Reading burst
       @ (posedge HCLK);
          while (HREADYOUT == 1'b0) @ (posedge HCLK); 
      for (i = 0; i < leng -1  ; i = i + 1) begin
              HADDR  <= #1 addr + (i + 1) * (1 << HSIZE);
              HTRANS <= #1 2'b11; // HTRANS_SEQ
          
        @ (posedge HCLK);
      while (HREADYOUT == 0) @ (posedge HCLK);
          // Capture data read
          $display($time, " INFO: read from address 0x%0h: 0x%0h", HADDR, HRDATA);
      end

      // Set bus to IDLE after burst is complete
      HADDR  <= #1 0;
      HTRANS <= #1 0;
      HBURST <= #1 0;
      HWRITE <= #1 0;
      HSIZE  <= #1 0;
      //HBUSREQ <= #1 1'b0;

      @ (posedge HCLK);
      while (HREADYOUT == 0) @ (posedge HCLK);

      // Check response for error
      if (HRESP != 1'b0) begin // HRESP_OKAY
          $display($time, " ERROR: Non-OK response on read (HRESP = %b)", HRESP);
      end

      @ (posedge HCLK);
  end
endtask
  
       // Task to perform AHB Write (Address Phase + Data Phase)
  task ahb_write_single;
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
        //HWDATA = 'b0;
        //HADDR = 'b0;
       // @(posedge HCLK);
    end
endtask

// Task to perform AHB Read (Address Phase + Data Phase)
task ahb_read_single;
input [ADDR_WIDTH-1:0] address;
//output [31:0] data;
// input [31:0] expected_data;
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
   //HRDATA  = expected_data;  // Example APB data response  
   //PRDATA1  = expected_data;  // Example APB data response
   //PRDATA2  = expected_data;  // Example APB data response    
  @(posedge HCLK);
      while (!HREADYOUT) begin
        @(posedge HCLK);
    end   
     $display("AHB_READ completed from address 0x%h with data 0x%h\n", address, HRDATA);     
        @(posedge HCLK);
   
end
endtask
  task CHECK_READ_DATA;
    input [ADDR_WIDTH-1:0] address;
    input [31:0] expected_data;
  
    integer j;  // Loop variable for checking individual bits
    reg bit_match; // To check if all bits match
  
    begin
       // @(posedge HCLK);
        //while (!HREADYOUT) @(posedge HCLK);  // Wait until DUT is ready to provide data
  
        // Initialize bit_match as true
        bit_match = 0;
  
        // Compare each bit
        for (j = 0; j < 32; j = j + 1) begin
            if (HRDATA[j] == expected_data[j]) begin
                bit_match = 1; // Set flag to false if a bit does not match
            end
        end
  
        // Final reporting
        if (bit_match) begin
            $display($time, " [PASS]: Data at address 0x%h matches expected value 0x%h", address, expected_data);
        end else begin
            $display($time, " [FAIL]: Data at address 0x%h does not match expected value 0x%h. Read data was 0x%h", 
                      address, expected_data, HRDATA);
            test_passed = 0; // Mark test as failed
        end
    end
  endtask
  
  task ahb_write_burst_incr_hsize;
    input [31:0] addr;   // Starting address for the burst
    input [31:0] leng;   // Length of burst (4, 8, 16, etc.)
    input [2:0]  size;   // HSIZE: 000=byte, 001=halfword, 010=word, etc.
    integer i;

    begin
        @ (posedge HCLK);
        while ((HREADYOUT !== 1'b1)) @ (posedge HCLK);

        HADDR  <= #1 addr;
        HTRANS <= #1 2'b10; // HTRANS_NONSEQ

        // Set burst type based on length
        if (leng == 4)       HBURST <= #1 3'b011; // HBURST_INCR4
        else if (leng == 8)  HBURST <= #1 3'b101; // HBURST_INCR8
        else if (leng == 16) HBURST <= #1 3'b111; // HBURST_INCR16
        else                 HBURST <= #1 3'b001; // HBURST_INCR

        HWRITE <= #1 1'b1;         // Write operation
        HSIZE  <= #1 size;         // Use provided HSIZE
        HSEL   <= #1 1'b1;

        // Writing burst
        for (i = 0; i < leng - 1; i = i + 1) begin
            @ (posedge HCLK);
            while (HREADYOUT == 1'b0) @ (posedge HCLK);

            HWDATA <= #1 data_burst[i % 1024];
            HADDR  <= #1 addr + (i + 1) * (1 << size);
            HTRANS <= #1 2'b11; // HTRANS_SEQ
        end

        // Final data phase
        @ (posedge HCLK);
        while (HREADYOUT == 0) @ (posedge HCLK);
        HWDATA <= #1 data_burst[i % 1024];
        HTRANS <= #1 2'b00; // HTRANS_IDLE

        @ (posedge HCLK);
        while (HREADYOUT == 0) @ (posedge HCLK);

        // Check for error response
        if (HRESP != 1'b0) begin
            $display($time, " ERROR: Non-OK response on write (HRESP = %b)", HRESP);
        end

        `ifdef DEBUG
        $display($time, " INFO: write(%x, %d, %x) with HSIZE = %d", addr, leng, HWDATA, size);
        `endif

        @ (posedge HCLK);
    end
endtask

task ahb_read_burst_incr_hsize;
  input  [31:0] addr;   // Starting address for the burst
  input  [31:0] leng;   // Length of burst (4, 8, 16, etc.)
  input  [2:0]  size;   // HSIZE: 000=byte, 001=halfword, 010=word, etc.
  integer i;

  begin
      @ (posedge HCLK);
      while (HREADYOUT !== 1'b1) @ (posedge HCLK);

      HADDR  <= #1 addr;
      HTRANS <= #1 2'b10; // HTRANS_NONSEQ

      // Set burst type based on length
      if (leng == 4)       HBURST <= #1 3'b011; // HBURST_INCR4
      else if (leng == 8)  HBURST <= #1 3'b101; // HBURST_INCR8
      else if (leng == 16) HBURST <= #1 3'b111; // HBURST_INCR16
      else                 HBURST <= #1 3'b001; // HBURST_INCR

      HWRITE <= #1 1'b0;       // Read operation
      HSIZE  <= #1 size;       // Use provided HSIZE
      HSEL   <= #1 1'b1;

      // First access
      @ (posedge HCLK);
      while (HREADYOUT == 1'b0) @ (posedge HCLK); 

      for (i = 0; i < leng - 1; i = i + 1) begin
          HADDR  <= #1 addr + (i + 1) * (1 << size);
          HTRANS <= #1 2'b11; // HTRANS_SEQ
          
          @ (posedge HCLK);
          while (HREADYOUT == 1'b0) @ (posedge HCLK);
          
          $display($time, " INFO: read from address 0x%0h: 0x%0h", HADDR, HRDATA);
      end

      // End of burst - go idle
      HADDR  <= #1 0;
      HTRANS <= #1 2'b00;
      HBURST <= #1 3'b000;
      HWRITE <= #1 1'b0;
      HSIZE  <= #1 3'b000;

      @ (posedge HCLK);
      while (HREADYOUT == 1'b0) @ (posedge HCLK);

      // Final response check
      if (HRESP != 1'b0) begin
          $display($time, " ERROR: Non-OK response on read (HRESP = %b)", HRESP);
      end

      @ (posedge HCLK);
  end
endtask

endmodule









