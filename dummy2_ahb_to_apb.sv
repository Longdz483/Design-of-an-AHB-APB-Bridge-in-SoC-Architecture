// Code your design here
module dummy2_ahb_to_apb #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
  )
  (
    input                           HRESETn,
    input                           HCLK,
    input                           HSEL,
    input      [ADDR_WIDTH-1:0]     HADDR,  // 32-bit address
    input      [DATA_WIDTH-1:0]     HWDATA, // 32-bit data
    input                           HWRITE,
    input      [2:0]                HSIZE,
    input      [2:0]                HBURST,
    input      [3:0]                HPROT,
    input      [1:0]                HTRANS,
    input                           HMASTERLOCK,
    input                           HREADYIN,
    output reg                      HREADYOUT,
    output reg [DATA_WIDTH-1:0]     HRDATA,
    output reg                      HRESP,
    input                           PRESETn,
    input                           PCLK,
    output reg                      PSEL,
    output reg                      PENABLE,
    output     [2:0]                PPROT,
    output reg                      PWRITE,
    output reg [(DATA_WIDTH/8)-1:0] PSTRB,
    output reg [ADDR_WIDTH-1:0]     PADDR,
    output reg [DATA_WIDTH-1:0]     PWDATA,
    input      [DATA_WIDTH-1:0]     PRDATA,
    input                           PREADY,
    input                           PSLVERR
  );
  /*
  parameter ST_AHB_IDLE     = 2'b00,
            ST_AHB_TRANSFER = 2'b01,
            ST_AHB_ERROR    = 2'b10;
  */
  enum logic [1:0] {ST_AHB_IDLE,ST_AHB_TRANSFER, ST_AHB_ERROR}  ahb_state ;
  //reg  [1:0]            ahb_state;
  wire                  ahb_transfer;
  reg                   apb_treq;
  reg                   apb_treq_toggle;
  reg  [2:0]            apb_treq_sync;
  wire                  apb_treq_pulse;
  logic [3:0]   pstrb_reg , pstrb_nxt;
  logic [1:0]   pprot_reg , pprot_nxt;
  reg                   apb_tack;
  reg                   apb_tack_toggle;
  reg  [2:0]            apb_tack_sync;
  wire                  apb_tack_pulse;
  reg                   apb_tack_pulse_Q1;
  reg  [ADDR_WIDTH-1:0] ahb_HADDR;
  reg                   ahb_HWRITE;
  reg  [2:0]            ahb_HSIZE;
  reg  [DATA_WIDTH-1:0] ahb_HWDATA;
  reg                   latch_HWDATA;
  reg  [DATA_WIDTH-1:0] apb_PRDATA;
  reg                   apb_PSLVERR;
  reg  [DATA_WIDTH-1:0] apb_PRDATA_HCLK;
  reg                   apb_PSLVERR_HCLK;
  
  //localparam ST_AHB_IDLE = 2'b00, ST_AHB_TRANSFER = 2'b01, ST_AHB_ERROR = 2'b10;

  //localparam ST_APB_IDLE = 2'b00, ST_APB_SETUP = 2'b01, ST_APB_TRANSFER = 2'b10;

  // PPROT
  localparam [2:0] PPROT_NORMAL = 3'b000, PPROT_PRIVILEGED = 3'b001, PPROT_SECURE = 3'b000, PPROT_NONSECURE = 3'b010, PPROT_DATA = 3'b000, PPROT_INSTRUCTION = 3'b100;

  task ahb_no_transfer;
    ahb_state   <= ST_AHB_IDLE;

    HREADYOUT <= 1'b1;
    HRESP     <= 1'b0;
  endtask  // ahb_no_transfer

  task ahb_prep_transfer;
    ahb_state   <= ST_AHB_TRANSFER;

    HREADYOUT <= 1'b0;  // hold off master
    HRESP     <= 1'b0;
    apb_treq  <= 1'b1;  // request data transfer
  endtask  // ahb_prep_transfer
  assign ahb_transfer = (HSEL & HREADYIN & (HTRANS == 2'b10 || HTRANS == 2'b11)) ? 1'b1 : 1'b0;
   assign pstrb_nxt[0] = HWRITE & ((HSIZE[1])|((HSIZE[0])&(~HADDR[1]))|(HADDR[1:0]==2'b00));
    assign pstrb_nxt[1] = HWRITE & ((HSIZE[1])|((HSIZE[0])&(~HADDR[1]))|(HADDR[1:0]==2'b01));
    assign pstrb_nxt[2] = HWRITE & ((HSIZE[1])|((HSIZE[0])&( HADDR[1]))|(HADDR[1:0]==2'b10));
    assign pstrb_nxt[3] = HWRITE & ((HSIZE[1])|((HSIZE[0])&( HADDR[1]))|(HADDR[1:0]==2'b11));
    
    assign pprot_nxt[0] =  HPROT[1];  // (0) Normal, (1) Privileged
    assign pprot_nxt[1] = ~HPROT[0];  // (0) Data, (1) Instruction
  always@(posedge HCLK or negedge HRESETn)begin
    if(!HRESETn)begin     //reseting the Ahb siginals
      HREADYOUT  <= 1'b1;  //output signal to 1;
      HRESP      <= 1'b0;  //--            to 0;
      HRDATA     <=  'd0;  //--            to 0;
      ahb_HADDR  <=  'd0;   // internal reg to 0; 
      ahb_HWRITE <= 1'b0;   // --
      ahb_HSIZE  <=  'd0;   // --
      ahb_state  <= ST_AHB_IDLE;  // making ahb_state ==00;
      apb_treq   <= 1'b0; // --
    end else begin
      apb_treq   <= 1'b0; //internal register of apb to 0;
      case (ahb_state)
        ST_AHB_IDLE : begin    // ahb_state==00
          //HREADYOUT  <= 1'b1;  
          //HRESP      <= 1'b0;
          ahb_HADDR  <= HADDR;  // 32-bit input HADDR is assigning to internal register 32-bit ahb_HADDr
          ahb_HWRITE <= HWRITE;  // 1-bit input to internal register
          ahb_HSIZE  <= HSIZE;   // 3-bit input to internal register
          if (HSEL && HREADYIN) begin
            // This (slave) is selected ... what kind of transfer is this?
            case (HTRANS)
              2'b00:   ahb_no_transfer;
              2'b01:   ahb_no_transfer;
              2'b10:   ahb_prep_transfer;
              2'b11:   ahb_prep_transfer;
            endcase  // HTRANS
          end else ahb_no_transfer;
        end
        /*
          if(ahb_transfer)begin    // ahb_transfer depends up on the HSEL,HREADYIN,HTRANS which all are input signals;
            ahb_state <= ST_AHB_TRANSFER;  // making ahb_state to 01;
            HREADYOUT <= 1'b0;   // output signal to 0;
            apb_treq  <= 1'b1;   // internal reg to 1;
          end
          
        end 
          */
        ST_AHB_TRANSFER : begin   // ahb_state==01;
          HREADYOUT <= 1'b0;      // output signal to 0;
          if(apb_tack_pulse_Q1)begin  // internal apb reg 
            HRDATA <= apb_PRDATA_HCLK;  //32-bit internal apb reg is assigned to 32-bit output signal;
            if(apb_PSLVERR_HCLK)begin  // apb slave error register
              HRESP     <= 1'b1;       // output signal to make 1;
              ahb_state <= ST_AHB_ERROR; // making ahb state to 10;
            end else begin
              HREADYOUT <= 1'b1;  // out-put signal to 1;
              HRESP     <= 1'b0;  // out-put signal to 0;
              ahb_state <= ST_AHB_IDLE; // making ahb state to 00;
            end
          end
        end
        ST_AHB_ERROR : begin  // ahb_state==10
          HREADYOUT <= 1'b1;  // output signal to 1;
          ahb_state <= ST_AHB_IDLE; //making ahb_state to 00;
        end
        default: begin
          ahb_state <= ST_AHB_IDLE; // by default ahb_state==00;
        end
      endcase
    end
  end
  
  always@(posedge HCLK or negedge HRESETn)begin
    if(!HRESETn)begin  
      ahb_HWDATA   <=  'd0;  // internal 32-bit register to 0;
      latch_HWDATA <= 1'b0;  // internal reg to 0;
    end else begin
      if(ahb_transfer && HWRITE) latch_HWDATA <= 1'b1;  //internal ahb_transfer reg and input Hwrite are 1, latch=1;
      else                       latch_HWDATA <= 1'b0;  // else 0;
      if(latch_HWDATA)begin 
        ahb_HWDATA <= HWDATA;// assigning 32-bit input signal to internal register;
      end 
    end
  end
  
  always@(posedge HCLK or negedge HRESETn)begin
    if(!HRESETn)begin
      apb_treq_toggle <= 1'b0;
    end else begin
      if(apb_treq) apb_treq_toggle <= ~apb_treq_toggle; // always toggling the internal apb register when apb_trq==1
    end
  end
  
  always@(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)begin
       apb_treq_sync  <=  'd0; // apb internal 3-bit reg to 1 when active low preset is applied
    end else begin
      apb_treq_sync <= {apb_treq_sync[1:0], apb_treq_toggle}; // shifting and adding lsb of toggle reg to apb sync;
    end
  end
  
    assign apb_treq_pulse = apb_treq_sync[2] ^ apb_treq_sync[1]; // xor operation of treq_sync[2]and[1] to trq_pulse
  
  
  reg                   apb_treq_pulse_Q1;
  reg  [ADDR_WIDTH-1:0] ahb_HADDR_PCLK;
  reg                   ahb_HWRITE_PCLK;
  reg  [2:0]            ahb_HSIZE_PCLK;
  reg  [DATA_WIDTH-1:0] ahb_HWDATA_PCLK;
  
  always@(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)begin
      apb_treq_pulse_Q1 <= 0;
      ahb_HADDR_PCLK    <= 0;
      ahb_HWRITE_PCLK   <= 0;
      ahb_HSIZE_PCLK    <= 0;
      ahb_HWDATA_PCLK   <= 0;
    end else begin
      apb_treq_pulse_Q1 <= apb_treq_pulse;
      if(apb_treq_pulse)begin
        ahb_HADDR_PCLK  <= ahb_HADDR;
        ahb_HWRITE_PCLK <= ahb_HWRITE;
        ahb_HSIZE_PCLK  <= ahb_HSIZE;
        ahb_HWDATA_PCLK <= ahb_HWDATA;
      end
    end
  end
  
  
  reg [(DATA_WIDTH/8)-1:0] lcl_PSTRB;
  
 // reg [1:0] apb_state;
  enum logic [1:0] {ST_APB_IDLE,  ST_APB_SETUP, ST_APB_ACCESS } apb_state;
  /*
  parameter ST_APB_IDLE   = 2'b00,
            ST_APB_SETUP  = 2'b01,
            ST_APB_ACCESS = 2'b10;
  */
  always@(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)begin
      apb_state   <= ST_APB_IDLE;
      PADDR       <=  'd0;
      PSEL        <=  'b0;
      PENABLE     <=  'b0;
      PWRITE      <=  'b0;
      PWDATA      <=  'b0;
      PSTRB       <=  'd0;
      apb_PSLVERR <= 1'b0;
      apb_tack    <= 1'b0;
      apb_PRDATA  <=  'd0;
    end else begin
      apb_tack    <= 1'b0;
      case (apb_state)
        ST_APB_IDLE: begin
          PSEL    <= 'b0;
          PENABLE <= 'b0;
          PWRITE  <= 'b0;
          if(apb_treq_pulse_Q1)begin
            apb_state <= ST_APB_SETUP;
            //PADDR     <= {ahb_HADDR_PCLK[ADDR_WIDTH-1:DATA_WIDTH/8], {{(DATA_WIDTH/8)}{1'b0}}};
            PADDR     <= ahb_HADDR_PCLK;
            PSTRB     <= pstrb_reg[3:0];
            PSEL      <= 'b1;
            PWRITE    <= ahb_HWRITE_PCLK;
            PWDATA    <= ahb_HWDATA_PCLK;
          end
        end
  
        ST_APB_SETUP: begin
          apb_state <= ST_APB_ACCESS;
          PSEL      <= 'b1;
          PENABLE   <= 'b1;
        end
  
        ST_APB_ACCESS: begin
          PENABLE <= PENABLE;
          PWRITE  <= PWRITE;
          if(PREADY)begin
            apb_state   <= ST_APB_IDLE;
            apb_tack    <= 1'b1;
            apb_PRDATA  <= PRDATA;
            PSEL        <= 'b0;
            PENABLE     <= 'b0;
            apb_PSLVERR <= PSLVERR;
          end
        end
      endcase
    end
  end
  
  always@(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)begin
      apb_tack_toggle <= 1'b0;
    end else begin
      if(apb_tack) apb_tack_toggle <= ~apb_tack_toggle;
    end
  end
  
  always@(posedge HCLK or negedge HRESETn)begin
    if(!HRESETn)begin
      apb_tack_sync <= 'd0;
    end else begin
      apb_tack_sync <= {apb_tack_sync[1:0], apb_tack_toggle};
    end
  end
  
  assign apb_tack_pulse = apb_tack_sync[2] ^ apb_tack_sync[1];
  
  
  always@(posedge HCLK or negedge HRESETn)begin
    if(!HRESETn)begin
      apb_tack_pulse_Q1 <= 0;
      apb_PRDATA_HCLK   <= 0;
      apb_PSLVERR_HCLK  <= 0;
    end else begin
      apb_tack_pulse_Q1 <= apb_tack_pulse;
      if(apb_tack_pulse)begin
        apb_PRDATA_HCLK  <= apb_PRDATA;
        apb_PSLVERR_HCLK <= apb_PSLVERR;
      end
    end
  end
  
  reg [127:0] pstrb;
  reg [6:0]   addr_mask;
  always@(*)begin
    case(DATA_WIDTH/8)
      'd0: addr_mask <= 'h00;
      'd1: addr_mask <= 'h01;
      'd2: addr_mask <= 'h03;
      'd3: addr_mask <= 'h07;
      'd4: addr_mask <= 'h0f;
      'd5: addr_mask <= 'h1f;
      'd6: addr_mask <= 'h3f;
      'd7: addr_mask <= 'h7f;
    endcase
  
    case(ahb_HSIZE)
      'd1:     pstrb <= 'h3;
      'd2:     pstrb <= 'hf;
      'd3:     pstrb <= 'hff;
      'd4:     pstrb <= 'hffff;
      'd5:     pstrb <= 'hffff_ffff;
      'd6:     pstrb <= 'hffff_ffff_ffff_ffff;
      'd7:     pstrb <= 'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
      default: pstrb <= 'h1;
    endcase
  end
  
  
  always@(posedge HCLK or negedge HRESETn)begin
    if(!HRESETn)begin
      pstrb_reg <= {4{1'b0}};
    end else begin
       pstrb_reg           <= pstrb_nxt;
    end
  end
  
  endmodule
  
  module apb_decoder_s3
     #(parameter P_NUM         = 6, // how many slaves
                 P_ADDR_START1 = 'hC000, P_ADDR_SIZE1  = 'h0001,
                 P_ADDR_START2 = 'hC010, P_ADDR_SIZE2  = 'h0001,
                 P_ADDR_START3 = 'hC020, P_ADDR_SIZE3  = 'h0001,
                 P_ADDR_START4 = 'hC030, P_ADDR_SIZE4  = 'h0010,
                 P_ADDR_START5 = 'hC030, P_ADDR_SIZE5  = 'h0010,
                 P_ADDR_START6 = 'hC030, P_ADDR_SIZE6  = 'h0010)
(
       input  wire        PSELin
     , input  wire [31:0] PADDR
     , output reg         PSELout1
     , output reg         PSELout2
     , output reg         PSELout3
     , output reg         PSELout4
     , output reg         PSELout5
     , output reg         PSELout6
);
   //-----------------------------------------------------

   // decoder
   localparam P_ADDR_END1 = P_ADDR_START1 + P_ADDR_SIZE1 - 1;
   localparam P_ADDR_END2 = P_ADDR_START2 + P_ADDR_SIZE2 - 1;
   localparam P_ADDR_END3 = P_ADDR_START3 + P_ADDR_SIZE3 - 1;
   localparam P_ADDR_END4 = P_ADDR_START4 + P_ADDR_SIZE4 - 1;
   localparam P_ADDR_END5 = P_ADDR_START5 + P_ADDR_SIZE5 - 1;
   localparam P_ADDR_END6 = P_ADDR_START6 + P_ADDR_SIZE6 - 1;
   
//localparam P_ADDR_END1 = P_ADDR_START1 + (P_ADDR_SIZE1 << 12) - 1;
//localparam P_ADDR_END2 = P_ADDR_START2 + (P_ADDR_SIZE2 << 12) - 1;
//localparam P_ADDR_END3 = P_ADDR_START3 + (P_ADDR_SIZE3 << 12) - 1;
//localparam P_ADDR_END4 = P_ADDR_START4 + (P_ADDR_SIZE4 << 12) - 1;

`ifdef RIGOR

   wire [5:0] _psel = {PSELout6,PSELout6,PSELout4,PSELout3,PSELout2,PSELout1};

`endif
   wire [15:0] tpaddr = PADDR[31:16];
   always @ (tpaddr or PSELin) begin
      if (P_NUM>0&&tpaddr>=P_ADDR_START1&&tpaddr<=P_ADDR_END1) PSELout1 <= 1'b1&PSELin;
      else                                                   PSELout1 <= 1'b0;
      if (P_NUM>1&&tpaddr>=P_ADDR_START2&&tpaddr<=P_ADDR_END2) PSELout2 <= 1'b1&PSELin;
      else                                                   PSELout2 <= 1'b0;
      if (P_NUM>2&&tpaddr>=P_ADDR_START3&&tpaddr<=P_ADDR_END3) PSELout3 <= 1'b1&PSELin;
      else                                                   PSELout3 <= 1'b0;
      if (P_NUM>3&&tpaddr>=P_ADDR_START4&&tpaddr<=P_ADDR_END4) PSELout4 <= 1'b1&PSELin;
      else                                                   PSELout4 <= 1'b0;
      if (P_NUM>4&&tpaddr>=P_ADDR_START5&&tpaddr<=P_ADDR_END5) PSELout5 <= 1'b1&PSELin;
      else                                                   PSELout5 <= 1'b0;
      if (P_NUM>5&&tpaddr>=P_ADDR_START6&&tpaddr<=P_ADDR_END6) PSELout6 <= 1'b1&PSELin;
      else                                                   PSELout6 <= 1'b0;

`ifdef RIGOR

    if ((_psel!=6'b000001)&&(_psel!=6'b000010)&&
        (_psel!=6'b000100)&&(_psel!=6'b001000)&& (_psel!=6'b010000)&&(_psel!=6'b100000)&& 
        (_psel!=6'b0000))
        $display($time,, "ERROR: more than one has been selected! 0x%x", _psel);

`endif
   end 

   initial begin
      if ((P_NUM>0)&&(P_ADDR_START1>=P_ADDR_END1))
          $display("ERROR: address range for PSEL0: from 0x%x to 0x%x", P_ADDR_START1, P_ADDR_END1);
      if ((P_NUM>1)&&(P_ADDR_START2>=P_ADDR_END2))
          $display("ERROR: address range for PSEL1: from 0x%x to 0x%x", P_ADDR_START2, P_ADDR_END2);
      if ((P_NUM>2)&&(P_ADDR_START3>=P_ADDR_END3))
          $display("ERROR: address range for PSEL2: from 0x%x to 0x%x", P_ADDR_START3, P_ADDR_END3);
      if ((P_NUM>3)&&(P_ADDR_START4>=P_ADDR_END4))
          $display("ERROR: address range for PSEL3: from 0x%x to 0x%x", P_ADDR_START4, P_ADDR_END4);
      if ((P_NUM>4)&&(P_ADDR_START5>=P_ADDR_END5))
          $display("ERROR: address range for PSEL4: from 0x%x to 0x%x", P_ADDR_START5, P_ADDR_END5);
      if ((P_NUM>5)&&(P_ADDR_START6>=P_ADDR_END6))
          $display("ERROR: address range for PSEL5: from 0x%x to 0x%x", P_ADDR_START6, P_ADDR_END6);
   end 
   initial begin
          $display("Info: %m PSEL0: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START1, P_ADDR_END1);
          $display("Info: %m PSEL1: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START2, P_ADDR_END2);
          $display("Info: %m PSEL2: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START3, P_ADDR_END3);
          $display("Info: %m PSEL3: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START4, P_ADDR_END4);
          $display("Info: %m PSEL4: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START5, P_ADDR_END5);
          $display("Info: %m PSEL5: from 0x%x_0000 to 0x%04x_FFFF", P_ADDR_START6, P_ADDR_END6);
   end 


endmodule
//---------------------------------------------------
//`timescale 1ns/1ns
module ahb_to_apb_s3
 
     #(parameter ADDR_WIDTH = 32,
                 DATA_WIDTH = 32,
                 P_NUM      = 4,
                 P_PSEL0_START = 16'hC000, P_PSEL0_SIZE  = 16'h0010,
                 P_PSEL1_START = 16'hC010, P_PSEL1_SIZE  = 16'h0010,
                 P_PSEL2_START = 16'hC020, P_PSEL2_SIZE  = 16'h0010,
                 P_PSEL3_START = 16'hC030, P_PSEL3_SIZE  = 16'h0010,
                 P_PSEL4_START = 16'hC040, P_PSEL4_SIZE  = 16'h0010,
                 P_PSEL5_START = 16'hC050, P_PSEL5_SIZE  = 16'h0010)
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
     , output wire        PSEL0
     , input  wire [DATA_WIDTH -1:0] PRDATA0
     
     , input  wire        PREADY0
     , input  wire        PSLVERR0
     
     , output wire        PSEL1
     , input  wire [DATA_WIDTH -1:0] PRDATA1
     
     , input  wire        PREADY1
     , input  wire        PSLVERR1
   
     , output wire        PSEL2
     , input  wire [DATA_WIDTH -1:0] PRDATA2
   
     , input  wire        PREADY2
     , input  wire        PSLVERR2,
      
       output wire        PSEL3
     , input  wire [DATA_WIDTH -1:0] PRDATA3
   
     , input  wire        PREADY3
     , input  wire        PSLVERR3,
       output wire        PSEL4
     , input  wire [DATA_WIDTH -1:0] PRDATA4
   
     , input  wire        PREADY4
     , input  wire        PSLVERR4
     , output wire        PSEL5
     , input  wire [DATA_WIDTH -1:0] PRDATA5
   
     , input  wire        PREADY5
     , input  wire        PSLVERR5
   
  
     , output wire [ 2:0] PPROT
     , output wire [ 3:0] PSTRB
  
     //, input  wire [ 1:0] CLOCK_RATIO // 0=1:1, 3=async
);
   //-----------------------------------------------------
   wire        PSEL   ;
   reg  [31:0] PRDATA ;
  
   reg         PREADY ;
   reg         PSLVERR;

   //-----------------------------------------------------
   wire [5:0] _psel = {PSEL5, PSEL4, PSEL3,PSEL2,PSEL1,PSEL0};
   dummy2_ahb_to_apb #(
               ADDR_WIDTH ,
               DATA_WIDTH
  ) 
  Uahb_to_apb_bridge (
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
  
  
  apb_decoder_s3 #(6, P_PSEL0_START, P_PSEL0_SIZE,
                       P_PSEL1_START, P_PSEL1_SIZE,
                       P_PSEL2_START, P_PSEL2_SIZE,
                       P_PSEL3_START, P_PSEL3_SIZE,
                       P_PSEL4_START, P_PSEL4_SIZE,
                       P_PSEL5_START, P_PSEL5_SIZE)
               Uapb_decoder (
                     // input       // output
                     .PSELin(PSEL),
                     .PADDR( PADDR), .PSELout1(PSEL0),
                                     .PSELout2(PSEL1),
                                     .PSELout3(PSEL2),
                                     .PSELout4(PSEL3),
                                     .PSELout5(PSEL4),
                                     .PSELout6(PSEL5)
   );
   always @ (_psel or
             PRDATA0 or PRDATA1 or PRDATA2 or PRDATA3 or PRDATA4 or PRDATA5) begin
    case(_psel)
      6'b000001: PRDATA = PRDATA0;
      6'b000010: PRDATA = PRDATA1;
      6'b000100: PRDATA = PRDATA2;
      6'b001000: PRDATA = PRDATA3;
      6'b010000: PRDATA = PRDATA4;
      6'b100000: PRDATA = PRDATA5;
      default: PRDATA = 32'b0;
    endcase
   end
   //-----------------------------------------------------

   always @ (_psel or
             PREADY0 or PREADY1 or PREADY2 or PREADY3 or PREADY4 or PREADY5 ) begin
    case(_psel)
      6'b000001: PREADY = PREADY0;
      6'b000010: PREADY = PREADY1;
      6'b000100: PREADY = PREADY2;
      6'b001000: PREADY = PREADY3;
      6'b010000: PREADY = PREADY4;
      6'b100000: PREADY = PREADY5;
      default:  PREADY = 1'b1  ;
    endcase
   end

   always @ (_psel or
             PSLVERR0 or PSLVERR1 or PSLVERR2 or PSLVERR3 or PSLVERR4 or PSLVERR5 ) begin
    case(_psel)
      6'b000001: PSLVERR = PSLVERR0;
      6'b000010: PSLVERR = PSLVERR1;
      6'b000100: PSLVERR = PSLVERR2;
      6'b001000: PSLVERR = PSLVERR3;
      6'b010000: PSLVERR = PSLVERR3;
      6'b100000: PSLVERR = PSLVERR3;
      default: PSLVERR = 1'b0    ;
    endcase
   end
   

   //-----------------------------------------------------
endmodule 
// -----------------------------------------------------------
//`timescale 1ns / 1ps

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

