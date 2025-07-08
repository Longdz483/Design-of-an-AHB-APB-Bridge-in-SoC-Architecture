`timescale 1ns/1ns
module testcase3_prefix_ahb2apb_i2c;
    
      
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
      wire       i2c_PSEL2; //ram1
      wire [DATA_WIDTH-1:0] i2c_PRDATA2;//ram1
      wire       i2c_PREADY2;//ram1
      wire       i2c_PSLVERR2;//ram1
      ///
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
      .P_PSEL2_SIZE(P_PSEL2_SIZE),
      .P_PSEL3_START(P_PSEL3_START),
      .P_PSEL3_SIZE(P_PSEL3_SIZE),
      .P_PSEL4_START(P_PSEL4_START),
      .P_PSEL4_SIZE(P_PSEL4_SIZE),
      .P_PSEL5_START(P_PSEL5_START),
      .P_PSEL5_SIZE(P_PSEL5_SIZE)
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
      .PSEL2(i2c_PSEL2),
      .PRDATA2(i2c_PRDATA2),
      .PREADY2(i2c_PREADY2),
      .PSLVERR2(i2c_PSLVERR2),
      .PPROT(PPROT),
      .PSTRB(PSTRB)
    );
    
  // Instantiate the DUT (Device Under Test)
  apb_i2c_top dut (
    .pclk      (PCLK),
    .prst_n    (PRESETn),
    .psel      (i2c_PSEL2),
    .penable   (PENABLE),
    .pwrite    (PWRITE),
    .paddr     (PADDR),
    .pwdata    (PWDATA),
    .prdata    (i2c_PRDATA2),
    .pready    (i2c_PREADY2),
    .pslverr   (i2c_PSLVERR2),
    .i2c_if    (i2c_if)
  );

    
    reg [31:0] expected_data [0:3]; // Array to store expected data for burst transactions
        reg test_passed;
        reg [31:0] data_burst [0:1023];
        integer   i; 
      // Clock Generation
      always #5 HCLK = ~HCLK;
      task clock_gen;
        begin
           forever  #10 PCLK = !PCLK;
        end
     
      endtask
    
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
       
        
        
    // Hiển thị thông báo bắt đầu testcase
$display("--------------'Testcase with I2C'-------------------"); 

     main;
          #100;
          $stop;
      end
       
      task main;
        fork
            clock_gen;
            operation;
        join
      endtask
      task operation;
        AHB_WRITE(32'hc020_003c, 2'b00, 3'b010);  // Chọn tốc độ 100kbps
        #4000;

        // Cấu hình Slave
        AHB_WRITE(32'hc020_001c, 3'b011, 3'b010); 
        // Cấu hình thanh ghi STATUS/ENABLE để Slave có thể nhận dữ liệu
        AHB_WRITE(32'hc020_0020, 8'b0000_0001, 3'b010);  // Cho phép Slave nhận dữ liệu
        // Cấu hình thanh ghi ADDRESS REGISTER cho địa chỉ Slave
        AHB_WRITE(32'hc020_0024, 7'b1010101, 3'b010);  // Địa chỉ Slave (1010101)
        
        // Cấu hình thanh ghi INTERRUPT ENABLE cho phép ngắt truyền, nhận, quá tải
        AHB_WRITE(32'hc020_0030, 8'b111, 3'b010);  // Cho phép ngắt truyền, nhận, quá tải

        begin
            AHB_WRITE(32'hc020_002c, 8'h7f, 3'b010);  // Truyền giá trị 0x00
            #860;
            AHB_WRITE(32'hc020_002c, 8'h80, 3'b010);  // Truyền giá trị 0x01
            #860;
            AHB_WRITE(32'hc020_002c, 8'h81, 3'b010);  // Truyền giá trị 0x02
            #860;
            AHB_WRITE(32'hc020_002c, 8'h82, 3'b010);  // Truyền giá trị 0x03
            #860;
            AHB_WRITE(32'hc020_002c, 8'h83, 3'b010);
            #860;
        end

        AHB_WRITE(32'hc020_0000, 8'b0, 3'b010);  
        //AHB_WRITE(32'hc020_0004, 8'b1, 3'b010);  
       // AHB_WRITE(32'hc020_0008, 8'b10, 3'b010);  
       // AHB_WRITE(32'hc020_000c, 8'b111, 3'b010);
        // Cấu hình Master
        // Cấu hình thanh ghi STATUS/ENABLE để kích hoạt giao tiếp I2C
        AHB_WRITE(32'hc020_0020, 8'b0000_0001, 3'b010);  // Cho phép giao tiếp I2C hoạt động
        // Cấu hình thanh ghi CONTROL cho Master
        AHB_WRITE(32'hc020_001c, 8'b111, 3'b010);  // Kích hoạt Master, xóa FIFO truyền, nhận
        // Cấu hình thanh ghi TRANSMIT ADDRESS cho địa chỉ Slave
        AHB_WRITE(32'hc020_0040, 7'b1010101, 3'b010);  // Địa chỉ Slave cần giao tiếp (1010101)
        // Cấu hình thanh ghi INTERRUPT ENABLE cho phép ngắt truyền, nhận, quá tải
        AHB_WRITE(32'hc020_0030, 8'b111, 3'b010);  // Cho phép ngắt truyền, nhận, quá tải
        // Cấu hình thanh ghi CLOCK SELECT cho tốc độ 100kbps
       
        // Cấu hình thanh ghi COMMAND 
        AHB_WRITE(32'hc020_0028, 8'b011, 3'b010);  


        



        /*// Truyền dữ liệu từ Master đến Slave qua thanh ghi DATA
        begin
            AHB_WRITE(32'hc020_002c, 8'h01, 3'b010);  // Truyền giá trị 0x00
            AHB_WRITE(32'hc020_002c, 8'h02, 3'b010);  // Truyền giá trị 0x01
            AHB_WRITE(32'hc020_002c, 8'h03, 3'b010);  // Truyền giá trị 0x02
            AHB_WRITE(32'hc020_002c, 8'h05, 3'b010);  // Truyền giá trị 0x03
        end*/
        #540000;
        AHB_WRITE(32'hc020_0028, 8'b110, 3'b010);  
        #400000;
        AHB_WRITE(32'hc020_0028, 8'b001, 3'b010);  
        #10000;
        AHB_READ(32'hc020_002c, 3'b010);
        AHB_READ(32'hc020_002c, 3'b010);
        AHB_READ(32'hc020_002c, 3'b010);
        endtask
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

/*
`timescale 1ns/1ns
module testcase3_prefix_ahb2apb_timer;
      
      // Parameters
      parameter ADDR_WIDTH = 32;
      parameter DATA_WIDTH = 32;
      parameter APB_ADDR_WIDTH = 12;
      parameter P_PSEL2_START = 16'hC020, P_PSEL2_SIZE = 16'h0010;
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
      wire       i2c_PSEL2; //ram1
      wire [DATA_WIDTH-1:0] i2c_PRDATA2;//ram1
      wire       i2c_PREADY2;//ram1
      wire       i2c_PSLVERR2;//ram1
      ///
      wire [2:0] PPROT;
      wire [3:0] PSTRB;
      // Instantiate the DUT
    ahb_to_apb_s3 #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH),
      
      .P_PSEL2_START(P_PSEL2_START),
      .P_PSEL2_SIZE(P_PSEL2_SIZE)
      
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
      .PSEL2(timer_PSEL2),
      .PRDATA2(timer_PRDATA2),
      .PREADY2(timer_PREADY2),
      .PSLVERR2(timer_PSLVERR2),
      .PPROT(PPROT),
      .PSTRB(PSTRB)
    );
    
  // Instantiate the DUT (Device Under Test)
  apb_timer_top dut (
    .pclk      (PCLK),
    .prst_n    (PRESETn),
    .psel      (timer_PSEL2),
    .penable   (PENABLE),
    .pwrite    (PWRITE),
    .paddr     (PADDR),
    .pwdata    (PWDATA),
    .prdata    (timer_PRDATA2),
    .pready    (timer_PREADY2),
    .pslverr   (timer_PSLVERR2),
    .timer_ovf    (timer_ovf),
    .timer_udf    (timer_udf)
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
        
     end
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
  */