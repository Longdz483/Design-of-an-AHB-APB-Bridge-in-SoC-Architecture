module prefix_ahb2apb_s3_uart_i2c_timer
#(parameter ADDR_WIDTH = 32,
            DATA_WIDTH = 32,
            APB_ADDR_WIDTH = 12,
            P_PSEL0_START = 16'hC000, P_PSEL0_SIZE  = 16'h0010,
            P_PSEL1_START = 16'hC010, P_PSEL1_SIZE  = 16'h0010,
            P_PSEL2_START = 16'hC020, P_PSEL2_SIZE  = 16'h0010,
            P_PSEL3_START = 16'hC030, P_PSEL3_SIZE  = 16'h0010)
(
  input  wire        HRESETn
, input  wire        HCLK
, input  wire        HSEL
, input  wire [ADDR_WIDTH - 1:0] HADDR
, input  wire [ 1:0] HTRANS
, input  wire [ 3:0] HPROT
, input  wire        HWRITE
, input  wire [ 2:0] HSIZE
, input  wire [ 2:0] HBURST
, input  wire [31:0] HWDATA
, output wire [31:0] HRDATA
, output wire        HRESP
, input              HMASTERLOCK
, input              HREADYIN
, output wire        HREADYOUT
, input  wire        PCLK
, input  wire        PRESETn
, output wire        PENABLE
, output wire [ADDR_WIDTH-1:0] PADDR
, output wire        PWRITE
, output wire [DATA_WIDTH -1:0] PWDATA
, output wire        uart_PSEL0
, output  wire [DATA_WIDTH -1:0] uart_PRDATA0

, output  wire        uart_PREADY0
, output  wire        uart_PSLVERR0

, output wire        i2c_PSEL1
, output  wire [DATA_WIDTH -1:0] i2c_PRDATA1

, output  wire        i2c_PREADY1
, output  wire        i2c_PSLVERR1

, output wire        timer_PSEL2
, output  wire [DATA_WIDTH -1:0] timer_PRDATA2

, output  wire        timer_PREADY2
, output  wire        timer_PSLVERR2
, output wire        ram_PSEL3
, output  wire [DATA_WIDTH -1:0] ram_PRDATA3

, output  wire        ram_PREADY3
, output  wire        ram_PSLVERR3


, output wire [ 2:0] PPROT
, output wire [ 3:0] PSTRB,
  input                             uart_rx_i,      // Receiver input
  output logic                      uart_tx_o,      // Transmitter output
  
  output logic                      uart_event_o    // interrupt/event output
 
);


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
    .P_PSEL3_SIZE(P_PSEL3_SIZE)
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
    .PSEL0(uart_PSEL0),
    .PRDATA0(uart_PRDATA0),
    .PREADY0(uart_PREADY0),
    .PSLVERR0(uart_PSLVERR0),
    .PSEL1(i2c_PSEL1),
    .PRDATA1(i2c_PRDATA1),
    .PREADY1(i2c_PREADY1),
    .PSLVERR1(i2c_PSLVERR1),
    .PSEL2(timer_PSEL2),
    .PRDATA2(timer_PRDATA2),
    .PREADY2(timer_PREADY2),
    .PSLVERR2(timer_PSLVERR2),
    .PSEL3(ram_PSEL3),
    .PRDATA3(ram_PRDATA3),
    .PREADY3(ram_PREADY3),
    .PSLVERR3(ram_PSLVERR3),
    .PPROT(PPROT),
    .PSTRB(PSTRB)
  );
     
  apb_uart #(
    12
  
  ) Uuart_apb4 (
    .RESETN(HRESETn),
    .CLK (PCLK),

    .PADDR  (PADDR),
    .PWDATA (PWDATA),
    .PWRITE (PWRITE),
    .PSEL   (uart_PSEL0),
    .PENABLE(PENABLE),
    .PRDATA (uart_PRDATA0),
    .PREADY (uart_PREADY0),
    .PSLVERR(uart_PSLVERR0),

    .rx_i(uart_rx_i),
    .tx_o(uart_tx_o),

    .event_o(uart_event_o)
  );
  apb_ram apb3_ram(
     .RAM_PCLK (PCLK),         // Tin hieu xung clock
     .RAM_PRESETn (HRESETn),      // Tin hieu reset
     .RAM_PADDR (PADDR), 
     .RAM_PSEL(ram_PSEL3),         // Tin hieu lua chon slave
     .RAM_PWDATA(PWDATA),// Du lieu dau vao
     .RAM_PENABE(PENABLE),
     .RAM_PWRITE(PWRITE),       // Tin hieu dieu khien ghi/doc
     .RAM_PSLVERR(ram_PSLVERR3),     // Tin hieu bao loi
    //=====output=====
    .RAM_PRDATA(ram_PRDATA3), // Tin hieu phan hoi du lieu cho master
    .RAM_PREADY(ram_PREADY3)         // Tin hieu phan hoi san sang cho master
  );

  
module apb_ram(
  //=====input=====
  input wire RAM_PCLK,         // Tin hieu xung clock
  input wire RAM_PRESETn,      // Tin hieu reset
  input wire [11:0] RAM_PADDR, // Ghi dia chi vao slave (12-bit address space)
  input wire RAM_PSEL,         // Tin hieu lua chon slave
  input wire [31:0] RAM_PWDATA,// Du lieu dau vao
  input wire RAM_PENABLE,      // Tin hieu cho phep
  input wire RAM_PWRITE,       // Tin hieu dieu khien ghi/doc
  output wire RAM_PSLVERR,     // Tin hieu bao loi
  //=====output=====
  output reg [31:0] RAM_PRDATA, // Tin hieu phan hoi du lieu cho master
  output reg RAM_PREADY         // Tin hieu phan hoi san sang cho master
);
`define WAIT_CYCLES 2

  // 4KB SRAM Memory (4096 words, each 32 bits)
  reg [31:0] mem [0:4095]; // 4KB memory
  integer i;
  reg [1:0] count;
  reg error_flag;          // C? b?o l?i
  wire  read_enable;
  // PREADY RESPONSE
  always @(posedge RAM_PCLK or negedge RAM_PRESETn) begin
      if (~RAM_PRESETn) begin
          RAM_PREADY <= 1'b0;
          count  <= 2'b0;
          error_flag <= 1'b0; // Reset l?i
      end else if (RAM_PSEL && RAM_PENABLE && count == 2'b00) begin
          RAM_PREADY <= 1'b0;
      end else if (RAM_PSEL) begin
          if (count == `WAIT_CYCLES) begin
              count <= 2'b00;
              RAM_PREADY <= 1'b1;
          end else begin
              count <= count + 1;
          end
      end else begin
          RAM_PREADY <= 1'b0;
      end
  end
//posedge RAM_PCLK or negedge RAM_PRESETn
  // Reset v? kh?i t?o b? nh?
  always @(posedge RAM_PCLK or negedge RAM_PRESETn) begin
      if (!RAM_PRESETn) begin
          for (i = 0; i < 4096; i = i + 1) begin
              mem[i] <= 32'b0;
          end
      end else if (RAM_PSEL && RAM_PENABLE && RAM_PWRITE ) begin
          if (RAM_PADDR < 4096) begin
              mem[RAM_PADDR] <= RAM_PWDATA;
              error_flag <= 1'b0;  // Kh?ng c? l?i
          end else begin
              error_flag <= 1'b1;  // ??a ch? kh?ng h?p l?, b?t c? b?o l?i
          end
      end
  end

  // ??c d? li?u t? SRAM
 always @(*) begin
      if (!RAM_PRESETn) begin
          RAM_PRDATA = 32'd0;
          error_flag = 1'b0;
      end else if (RAM_PSEL && RAM_PENABLE && !RAM_PWRITE && RAM_PREADY ) begin
          if (RAM_PADDR < 4096) begin
              RAM_PRDATA = mem[RAM_PADDR];
              error_flag = 1'b0;  // Kh?ng c? l?i
          end else begin
              RAM_PRDATA = 32'd0;
              error_flag = 1'b1;  // ??a ch? kh?ng h?p l?, b?t c? b?o l?i
          end
      end else begin
          RAM_PRDATA = 32'd0;
      end
  end

  // X? l? PSLVERR d?a tr?n c? b?o l?i
  assign RAM_PSLVERR = error_flag;

//assign read_enable = RAM_PENABLE & RAM_PSEL & (~RAM_PWRITE)& RAM_PREADY;
//assign RAM_PRDATA = (read_enable) ? mem[RAM_PADDR] : 32'dx;
endmodule

endmodule