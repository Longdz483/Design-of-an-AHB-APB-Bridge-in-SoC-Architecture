module apb_uart_rb_regs ( 
    output logic [7:0]    thr_data,                            // Data to transmit.
    output logic [7:0]    dll_dll,                             // The 8 least-significant bits (LSBs) of the 16-bit divisor for generation of the baud clock in the baud rate generator.
    output logic          ier_erbi,                            // Receiver data available interrupt and character timeout indication interrupt enable.&#10;0 = Receiver data available interrupt and character timeout indication interrupt is disabled.&#10;1 = Receiver data available interrupt and character timeout indication interrupt is enabled.
    output logic          ier_etbei,                           // Transmitter holding register empty interrupt enable.&#10;0 = Transmitter holding register empty interrupt is disabled.&#10;1 = Transmitter holding register empty interrupt is enabled.
    output logic          ier_elsi,                            // Receiver status interrupt enable(dr, oe, pe, fe, bi).&#10;0 = Receiver line status interrupt is disabled.&#10;1 = Receiver line status interrupt is enabled.
    output logic          ier_edssi,                           // Enable modem status interrupt.
    output logic [7:0]    dlh_dlh,                             // The 8 most-significant bits (MSBs) of the 16-bit divisor for generation of the baud clock in the baud rate generator. Maximum baud rate is 128 kbps
    output logic          fcr_fifoen,                          // Transmitter and receiver FIFOs mode enable. FIFOEN must be set before other FCR bits are written to or the FCR bits are not programmed. Clearing this bit clears the FIFO counters.
    output logic          fcr_rxclr,                           // Receiver FIFO clear. Write a 1 to RXCLR to clear the bit.
    output logic          fcr_txclr,                           // Transmitter FIFO clear. Write a 1 to TXCLR to clear the bit.
    output logic          fcr_dmamode1,                        // DMA MODE1 enable if FIFOs are enabled. Always write 1 to DMAMODE1. After a hardware reset, change DMAMODE1 from 0 to 1. DMAMOD1 = 1 is a requirement for proper communication between the UART and the EDMA controller.
    output logic [1:0]    fcr_rxfiftl,                         // Receiver FIFO trigger level. RXFIFTL sets the trigger level for the receiver FIFO. When the trigger level is reached, a receiver data-ready interrupt is generated (if the interrupt request is enabled). When the FIFO drops below the trigger level, the interrupt is cleared.
    output logic [1:0]    lcr_wls,                             // Word length select. Number of bits in each transmitted or received serial character. When STB = 1, the WLS bit&#10;determines the number of STOP bits.&#10;0 = Reserved&#10;1 = Reserved&#10;2 = Reserved&#10;3 = 8 bits
    output logic          lcr_stb,                             // Number of STOP bits generated. STB specifies 1, 2 STOP bits in each transmitted character. When STB =&#10;1, the WLS bit determines the number of STOP bits. The receiver clocks only the first STOP bit, regardless of the&#10;number of STOP bits selected. The number of STOP bits generated is summarized in Table 3-10.&#10;0 = One STOP bit is generated.&#10;1 = WLS bit determines the number of STOP bits:&#10;�� When WLS = 0, STOP bits are generated.&#10;�� When WLS = 1h, 2h, or 3h, 2 STOP bits are generated.
    output logic          lcr_pen,                             // Parity enable. The PEN bit works in conjunction with the SP and EPS bits. The relationship between the SP, EPS,&#10;and PEN bits is summarized in Table 3-9.&#10;0 = No PARITY bit is transmitted or checked.&#10;1 = Parity bit is generated in transmitted data and is checked in received data between the last data word bit&#10;and the first STOP bit.
    output logic          lcr_eps,                             // Even parity select. Selects the parity when parity is enabled (PEN = 1). The EPS bit works in conjunction with&#10;the SP and PEN bits. The relationship between the SP, EPS, and PEN bits is summarized in Table 3-9.&#10;0 = Odd parity is selected (an odd number of logic 1s is transmitted or checked in the data and PARITY bits).&#10;1 = Even parity is selected (an even number of logic 1s is transmitted or checked in the data and PARITY bits).
    output logic          lcr_sp,                              // Stick parity. The SP bit works in conjunction with the EPS and PEN bits. The relationship between the SP, EPS,&#10;and PEN bits is summarized in Table 3-9.&#10;0 = Stick parity is disabled.&#10;1 = Stick parity is enabled.&#10;���When odd parity is selected (EPS = 0), the PARITY bit is transmitted and checked as set.&#10;���When even parity is selected (EPS = 1), the PARITY bit is transmitted and checked as cleared.
    output logic          lcr_bc,                              // Break control.&#10;0 = Break condition is disabled.&#10;1 = Break condition is transmitted to the receiving UART. A break condition is a condition in which the&#10;UARTn_TXD signal is forced to the spacing (cleared) state.
    output logic          lcr_dlab,                            // Divisor latch access bit.
    output logic          mcr_rts,                             // RTS control.
    output logic          mcr_out1,                            // OUT1 Control Bit.
    output logic          mcr_out2,                            // OUT2 Control Bit.
    output logic          mcr_loop,                            // Loopback mode enable. LOOP is used for the diagnostic testing using the loopback feature.
    output logic          mcr_afe,                             // Autoflow control enable.
    output logic [7:0]    scr_scr,                             // These bits are intended for the programmer's use as a scratch pad in the sense that it temporarily holds the programmer's data without affecting any other UART operation.
    output logic          mdr_osmsel,                          // Over-Sampling Mode Select. 0 = 16x; 1 = 8x;
    input        [7:0]    rbr_data,                            // Received data
    input                 iir_ipend,                           // Interrupt pending.&#10;When any UART interrupt is generated and is enabled in IER, IPEND is forced to 0. IPEND remains 0 until all&#10;pending interrupts are cleared or until a hardware reset occurs. If no interrupts are enabled, IPEND is never&#10;forced to 0.&#10;0 = Interrupts pending.&#10;1 = No interrupts pending.
    input        [2:0]    iir_intid,                           // Interrupt type. See Table 3-6.&#10;0 = Reserved.&#10;1 = Transmitter holding register empty (priority 3).&#10;2 = Receiver data available (priority 2).&#10;3 = Receiver line status (priority 1, highest).&#10;4 = Reserved.&#10;5 = Reserved.&#10;6 = Character timeout indication (priority 2).&#10;7 = Reserved.
    input        [1:0]    iir_fifoen,                          // FIFOs enabled.&#10;0 = Non-FIFO mode.&#10;1 = Reserved.&#10;2 = Reserved.&#10;3 = FIFOs are enabled. FIFOEN bit in the FIFO control register (FCR) is set to 1.
    input                 lsr_dr,                              // Data-ready (DR) indicator for the receiver. If the DR bit is set and the corresponding interrupt enable bit is set (ERBI = 1 in IER), an interrupt request is generated.
    input                 lsr_oe,                              // Overrun error (OE) indicator. An overrun error in the non-FIFO mode is different from an overrun error in the FIFO mode. If the OE bit is set and the corresponding interrupt enable bit is set (ELSI = 1 in IER), an interrupt request is generated.
    input                 lsr_pe,                              // Parity error (PE) indicator. A parity error occurs when the parity of the received character does not match the parity selected with the EPS bit in the line control register (LCR). If the PE bit is set and the corresponding interrupt enable bit is set (ELSI = 1 in IER), an interrupt request is generated.
    input                 lsr_fe,                              // Framing error (FE) indicator. A framing error occurs when the received character does not have a valid STOP bit. In response to a framing error, the UART sets the FE bit and waits until the signal on the RX pin goes high. When the RX signal goes high, the receiver is ready to detect a new START bit and receive new data. If the FE bit is set and the corresponding interrupt enable bit is set (ELSI = 1 in IER), an interrupt request is generated.
    input                 lsr_bi,                              // Break indicator. The BI bit is set whenever the receive data input (UARTn_RXD) was held low for longer than a full-word transmission time. A full-word transmission time is defined as the total time to transmit the START, data, PARITY, and STOP bits. If the BI bit is set and the corresponding interrupt enable bit is set (ELSI = 1 in IER), an interrupt request is generated.
    input                 lsr_thre,                            // Transmitter holding register empty (THRE) indicator. If the THRE bit is set and the corresponding interrupt enable bit is set (ETBEI = 1 in IER), an interrupt request is generated.
    input                 lsr_temt,                            // Transmitter empty (TEMT) indicator.
    input                 lsr_rxfifoe,                         // Receiver FIFO error
    input                 msr_dcts,                            // Change in CTS indicator bit. DCTS indicates that the CTS input has changed state since the last time it was read by the CPU. When DCTS is set (autoflow control is not enabled and the modem status interrupt is enabled), a modem status interrupt is generated. When autoflow control is enabled, no interrupt is generated.
    input                 msr_ddsr,                            // Change in DSR indicator bit. DDSR indicates that the DSR input has changed state since the last time it was read by the CPU. When DDSR is set and the modem status interrupt is enabled, a modem status interrupt is generated.
    input                 msr_teri,                            // Trailing edge of RI (TERI) indicator bit. TERI indicates that the RI input has changed from a low to a high. When TERI is set and the modem status interrupt is enabled, a modem status interrupt is generated.
    input                 msr_dcd,                             // Change in DCD indicator bit. DCD indicates that the DCD input has changed state since the last time it was read by the CPU. When DCD is set and the modem status interrupt is enabled, a modem status interrupt is generated.
    input                 msr_cts,                             // Complement of the Clear To Send input. When the UART is in the diagnostic test mode (loopback mode MCR[4] = 1), this bit is equal to the MCR bit 1 (RTS).
    input                 msr_dsr,                             // Complement of the Data Set Ready input. When the UART is in the diagnostic test mode (loopback mode MCR[4] = 1), this bit is equal to the MCR bit 0 (DTR).
    input                 msr_ri,                              // Complement of the Ring Indicator input. When the UART is in the diagnostic test mode (loopback mode MCR[4] = 1), this bit is equal to the MCR bit 2 (OUT1).
    input                 msr_cd,                              // Complement of the Carrier Detect input. When the UART is in the diagnostic test mode (loopback mode MCR[4] = 1), this bit is equal to the MCR bit 3 (OUT2).
    input                 stt_int_txff_full,                   // Transmit Fifo Full
    input                 stt_int_txff_empty,                  // Transmit Fifo Empty
    input                 stt_int_rxff_full,                   // Receive Fifo Full
    input                 stt_int_rxff_empty,                  // Receive Fifo Empty
  //Derivative Signals
  //Global Signals
    input                 clk,                                 // System Clock
    input                 reset_n,                             // Asynchronous Reset, Active LOW
  //GENERIC BUS PORTS Signals
    input        [11:0]   apb_waddr,                           // Write Address
    input        [11:0]   apb_raddr,                           // Read Address
    input        [31:0]   apb_wdata,                           // Write Data
    output logic [31:0]   apb_rdata,                           // Read Data
    input                 apb_rstrobe,                         // Read-Strobe
    input                 apb_wstrobe,                         // Write-Strobe
    output logic          apb_raddrerr,                        // Read-Address-Error
    output logic          apb_waddrerr,                        // Write-Address-Error
    output logic          apb_wack,                            // Write Acknowledge
    output logic          apb_rack                            // Read Acknowledge
  );
  //-----------------------------------------------------------------------------
  // Internal Signals
   //-----------------------------------------------------------------------------
  // Enable Signals
  // ---------------------------
  // READ/WRITE ENABLE SIGNALS
    logic                 wen_rbr;
    logic                 wen_thr;
    logic                 wen_ier;
    logic                 wen_iir;
    logic                 wen_fcr;
    logic                 wen_lcr;
    logic                 wen_mcr;
    logic                 wen_lsr;
    logic                 wen_msr;
    logic                 wen_scr;
    logic                 wen_dll;
    logic                 wen_dlh;
    logic                 wen_mdr;
    logic                 wen_stt;
  // Internal Registers
    logic        [7:0]    rbr_data_reg;
    logic                 iir_ipend_reg;
    logic        [2:0]    iir_intid_reg;
    logic        [1:0]    iir_fifoen_reg;
    logic                 lsr_dr_reg;
    logic                 lsr_oe_reg;
    logic                 lsr_pe_reg;
    logic                 lsr_fe_reg;
    logic                 lsr_bi_reg;
    logic                 lsr_thre_reg;
    logic                 lsr_temt_reg;
    logic                 lsr_rxfifoe_reg;
    logic                 msr_dcts_reg;
    logic                 msr_ddsr_reg;
    logic                 msr_teri_reg;
    logic                 msr_dcd_reg;
    logic                 msr_cts_reg;
    logic                 msr_dsr_reg;
    logic                 msr_ri_reg;
    logic                 msr_cd_reg;
    logic                 stt_int_txff_full_reg;
    logic                 stt_int_txff_empty_reg;
    logic                 stt_int_rxff_full_reg;
    logic                 stt_int_rxff_empty_reg;
  // Read Data Mux
    logic        [31:0]   mux_rbr;
    logic        [31:0]   mux_thr;
    logic        [31:0]   mux_ier;
    logic        [31:0]   mux_iir;
    logic        [31:0]   mux_fcr;
    logic        [31:0]   mux_lcr;
    logic        [31:0]   mux_mcr;
    logic        [31:0]   mux_lsr;
    logic        [31:0]   mux_msr;
    logic        [31:0]   mux_scr;
    logic        [31:0]   mux_dll;
    logic        [31:0]   mux_dlh;
    logic        [31:0]   mux_mdr;
    logic        [31:0]   mux_stt;
  
  //-----------------------------------------------------------------------------
  // Read - Write Enable
  //-----------------------------------------------------------------------------
    always_comb begin: WRITE_ENABLE_PROC
      wen_rbr             = 0;
      wen_thr             = 0;
      wen_ier             = 0;
      wen_iir             = 0;
      wen_fcr             = 0;
      wen_lcr             = 0;
      wen_mcr             = 0;
      wen_lsr             = 0;
      wen_msr             = 0;
      wen_scr             = 0;
      wen_dll             = 0;
      wen_dlh             = 0;
      wen_mdr             = 0;
      wen_stt             = 0;
      apb_waddrerr        = 1'b0;
      apb_wack            = 1'b0;
      if (apb_wstrobe)
      begin
        case (apb_waddr)
          12'h000:        begin
            wen_rbr       = 1'b1;
            wen_thr       = 1'b1;
          end
          12'h004:        begin
            wen_ier       = 1'b1;
          end
          12'h008:        begin
            wen_iir       = 1'b1;
            wen_fcr       = 1'b1;
          end
          12'h00C:        begin
            wen_lcr       = 1'b1;
          end
          12'h010:        begin
            wen_mcr       = 1'b1;
          end
          12'h014:        begin
            wen_lsr       = 1'b1;
          end
          12'h018:        begin
            wen_msr       = 1'b1;
          end
          12'h01C:        begin
            wen_scr       = 1'b1;
          end
          12'h020:        begin
            wen_dll       = 1'b1;
          end
          12'h024:        begin
            wen_dlh       = 1'b1;
          end
          12'h028:        begin
            wen_mdr       = 1'b1;
          end
          12'h02C:        begin
            wen_stt      = 1'b1;
          end
          default:
          begin
            apb_waddrerr  = 1'b1;
          end
        endcase
        apb_wack = 1'b1;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : THR_DATA_PROC
      if (!reset_n) begin
        thr_data <= 0;
      end
      else if (wen_thr) begin
        thr_data <= apb_wdata[7:0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : IER_ERBI_PROC
      if (!reset_n) begin
        ier_erbi <= 0;
      end
      else if (wen_ier) begin
        ier_erbi <= apb_wdata[0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : IER_ETBEI_PROC
      if (!reset_n) begin
        ier_etbei <= 0;
      end
      else if (wen_ier) begin
        ier_etbei <= apb_wdata[1];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : IER_ELSI_PROC
      if (!reset_n) begin
        ier_elsi <= 0;
      end
      else if (wen_ier) begin
        ier_elsi <= apb_wdata[2];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : IER_EDSSI_PROC
      if (!reset_n) begin
        ier_edssi <= 0;
      end
      else if (wen_ier) begin
        ier_edssi <= apb_wdata[3];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : FCR_FIFOEN_PROC
      if (!reset_n) begin
        fcr_fifoen <= 0;
      end
      else if (wen_fcr) begin
        fcr_fifoen <= apb_wdata[0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : FCR_RXCLR_PROC
      if (!reset_n) begin
        fcr_rxclr <= 0;
      end
      else if (wen_fcr) begin
        fcr_rxclr <= apb_wdata[1];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : FCR_TXCLR_PROC
      if (!reset_n) begin
        fcr_txclr <= 0;
      end
      else if (wen_fcr) begin
        fcr_txclr <= apb_wdata[2];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : FCR_DMAMODE1_PROC
      if (!reset_n) begin
        fcr_dmamode1 <= 0;
      end
      else if (wen_fcr) begin
        fcr_dmamode1 <= apb_wdata[3];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : FCR_RXFIFTL_PROC
      if (!reset_n) begin
        fcr_rxfiftl <= 0;
      end
      else if (wen_fcr) begin
        fcr_rxfiftl <= apb_wdata[7:6];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LCR_WLS_PROC
      if (!reset_n) begin
        lcr_wls <= 0;
      end
      else if (wen_lcr) begin
        lcr_wls <= apb_wdata[1:0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LCR_STB_PROC
      if (!reset_n) begin
        lcr_stb <= 0;
      end
      else if (wen_lcr) begin
        lcr_stb <= apb_wdata[2];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LCR_PEN_PROC
      if (!reset_n) begin
        lcr_pen <= 0;
      end
      else if (wen_lcr) begin
        lcr_pen <= apb_wdata[3];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LCR_EPS_PROC
      if (!reset_n) begin
        lcr_eps <= 0;
      end
      else if (wen_lcr) begin
        lcr_eps <= apb_wdata[4];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LCR_SP_PROC
      if (!reset_n) begin
        lcr_sp <= 0;
      end
      else if (wen_lcr) begin
        lcr_sp <= apb_wdata[5];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LCR_BC_PROC
      if (!reset_n) begin
        lcr_bc <= 0;
      end
      else if (wen_lcr) begin
        lcr_bc <= apb_wdata[6];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LCR_DLAB_PROC
      if (!reset_n) begin
        lcr_dlab <= 0;
      end
      else if (wen_lcr) begin
        lcr_dlab <= apb_wdata[7];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MCR_RTS_PROC
      if (!reset_n) begin
        mcr_rts <= 0;
      end
      else if (wen_mcr) begin
        mcr_rts <= apb_wdata[1];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MCR_OUT1_PROC
      if (!reset_n) begin
        mcr_out1 <= 0;
      end
      else if (wen_mcr) begin
        mcr_out1 <= apb_wdata[2];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MCR_OUT2_PROC
      if (!reset_n) begin
        mcr_out2 <= 0;
      end
      else if (wen_mcr) begin
        mcr_out2 <= apb_wdata[3];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MCR_LOOP_PROC
      if (!reset_n) begin
        mcr_loop <= 0;
      end
      else if (wen_mcr) begin
        mcr_loop <= apb_wdata[4];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MCR_AFE_PROC
      if (!reset_n) begin
        mcr_afe <= 0;
      end
      else if (wen_mcr) begin
        mcr_afe <= apb_wdata[5];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : SCR_SCR_PROC
      if (!reset_n) begin
        scr_scr <= 0;
      end
      else if (wen_scr) begin
        scr_scr <= apb_wdata[7:0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : DLL_DLL_PROC
      if (!reset_n) begin
        dll_dll <= 0;
      end
      else if (wen_dll) begin
        dll_dll <= apb_wdata[7:0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : DLH_DLH_PROC
      if (!reset_n) begin
        dlh_dlh <= 0;
      end
      else if (wen_dlh) begin
        dlh_dlh <= apb_wdata[7:0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MDR_OSMSEL_PROC
      if (!reset_n) begin
        mdr_osmsel <= 0;
      end
      else if (wen_mdr) begin
        mdr_osmsel <= apb_wdata[0];
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : RBR_DATA_PROC
      if (!reset_n) begin
        rbr_data_reg <= 0;
      end
      else begin
        rbr_data_reg <= rbr_data;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : IIR_IPEND_PROC
      if (!reset_n) begin
        iir_ipend_reg <= 0;
      end
      else begin
        iir_ipend_reg <= iir_ipend;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : IIR_INTID_PROC
      if (!reset_n) begin
        iir_intid_reg <= 0;
      end
      else begin
        iir_intid_reg <= iir_intid;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : IIR_FIFOEN_PROC
      if (!reset_n) begin
        iir_fifoen_reg <= 0;
      end
      else begin
        iir_fifoen_reg <= iir_fifoen;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_DR_PROC
      if (!reset_n) begin
        lsr_dr_reg <= 0;
      end
      else begin
        lsr_dr_reg <= lsr_dr;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_OE_PROC
      if (!reset_n) begin
        lsr_oe_reg <= 0;
      end
      else begin
        lsr_oe_reg <= lsr_oe;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_PE_PROC
      if (!reset_n) begin
        lsr_pe_reg <= 0;
      end
      else begin
        lsr_pe_reg <= lsr_pe;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_FE_PROC
      if (!reset_n) begin
        lsr_fe_reg <= 0;
      end
      else begin
        lsr_fe_reg <= lsr_fe;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_BI_PROC
      if (!reset_n) begin
        lsr_bi_reg <= 0;
      end
      else begin
        lsr_bi_reg <= lsr_bi;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_THRE_PROC
      if (!reset_n) begin
        lsr_thre_reg <= 0;
      end
      else begin
        lsr_thre_reg <= lsr_thre;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_TEMT_PROC
      if (!reset_n) begin
        lsr_temt_reg <= 0;
      end
      else begin
        lsr_temt_reg <= lsr_temt;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : LSR_RXFIFOE_PROC
      if (!reset_n) begin
        lsr_rxfifoe_reg <= 0;
      end
      else begin
        lsr_rxfifoe_reg <= lsr_rxfifoe;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_DCTS_PROC
      if (!reset_n) begin
        msr_dcts_reg <= 0;
      end
      else begin
        msr_dcts_reg <= msr_dcts;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_DDSR_PROC
      if (!reset_n) begin
        msr_ddsr_reg <= 0;
      end
      else begin
        msr_ddsr_reg <= msr_ddsr;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_TERI_PROC
      if (!reset_n) begin
        msr_teri_reg <= 0;
      end
      else begin
        msr_teri_reg <= msr_teri;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_DCD_PROC
      if (!reset_n) begin
        msr_dcd_reg <= 0;
      end
      else begin
        msr_dcd_reg <= msr_dcd;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_CTS_PROC
      if (!reset_n) begin
        msr_cts_reg <= 0;
      end
      else begin
        msr_cts_reg <= msr_cts;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_DSR_PROC
      if (!reset_n) begin
        msr_dsr_reg <= 0;
      end
      else begin
        msr_dsr_reg <= msr_dsr;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_RI_PROC
      if (!reset_n) begin
        msr_ri_reg <= 0;
      end
      else begin
        msr_ri_reg <= msr_ri;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : MSR_CD_PROC
      if (!reset_n) begin
        msr_cd_reg <= 0;
      end
      else begin
        msr_cd_reg <= msr_cd;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : STT_INT_TXFF_FULL_PROC
      if (!reset_n) begin
        stt_int_txff_full_reg <= 0;
      end
      else begin
        stt_int_txff_full_reg <= stt_int_txff_full;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : STT_INT_TXFF_EMPTY_PROC
      if (!reset_n) begin
        stt_int_txff_empty_reg <= 0;
      end
      else begin
        stt_int_txff_empty_reg <= stt_int_txff_empty;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : STT_INT_RXFF_FULL_PROC
      if (!reset_n) begin
        stt_int_rxff_full_reg <= 0;
      end
      else begin
        stt_int_rxff_full_reg <= stt_int_rxff_full;
      end
    end
  
    always_ff @(posedge clk, negedge reset_n) begin : STT_INT_RXFF_EMPTY_PROC
      if (!reset_n) begin
        stt_int_rxff_empty_reg <= 0;
      end
      else begin
        stt_int_rxff_empty_reg <= stt_int_rxff_empty;
      end
    end
  
  //-----------------------------------------------------------------------------
  // Read Data Mux
  //-----------------------------------------------------------------------------
  // mux_thr
    assign mux_thr[7:0]              = thr_data;
    assign mux_thr[31:8]             = '0;
  // mux_ier
    assign mux_ier[0]                = ier_erbi;
    assign mux_ier[1]                = ier_etbei;
    assign mux_ier[2]                = ier_elsi;
    assign mux_ier[3]                = ier_edssi;
    assign mux_ier[31:4]             = '0;
  // mux_fcr
    assign mux_fcr[0]                = fcr_fifoen;
    assign mux_fcr[1]                = fcr_rxclr;
    assign mux_fcr[2]                = fcr_txclr;
    assign mux_fcr[3]                = fcr_dmamode1;
    assign mux_fcr[5:4]              = '0;
    assign mux_fcr[7:6]              = fcr_rxfiftl;
    assign mux_fcr[31:8]             = '0;
  // mux_lcr
    assign mux_lcr[1:0]              = lcr_wls;
    assign mux_lcr[2]                = lcr_stb;
    assign mux_lcr[3]                = lcr_pen;
    assign mux_lcr[4]                = lcr_eps;
    assign mux_lcr[5]                = lcr_sp;
    assign mux_lcr[6]                = lcr_bc;
    assign mux_lcr[7]                = lcr_dlab;
    assign mux_lcr[31:8]             = '0;
  // mux_mcr
    assign mux_mcr[0]                = 1'b0;
    assign mux_mcr[1]                = mcr_rts;
    assign mux_mcr[2]                = mcr_out1;
    assign mux_mcr[3]                = mcr_out2;
    assign mux_mcr[4]                = mcr_loop;
    assign mux_mcr[5]                = mcr_afe;
    assign mux_mcr[31:6]             = '0;
  // mux_scr
    assign mux_scr[7:0]              = scr_scr;
    assign mux_scr[31:8]             = '0;
  // mux_dll
    assign mux_dll[7:0]              = dll_dll;
    assign mux_dll[31:8]             = '0;
  // mux_dlh
    assign mux_dlh[7:0]              = dlh_dlh;
    assign mux_dlh[31:8]             = '0;
  // mux_mdr
    assign mux_mdr[0]                = mdr_osmsel;
    assign mux_mdr[31:1]             = '0;
  
  // mux_rbr
    assign mux_rbr[7:0]              = rbr_data_reg;
    assign mux_rbr[31:8]             = '0;
  // mux_iir
    assign mux_iir[0]                = iir_ipend_reg;
    assign mux_iir[3:1]              = iir_intid_reg;
    assign mux_iir[5:4]              = '0;
    assign mux_iir[7:6]              = iir_fifoen_reg;
    assign mux_iir[31:8]             = '0;
  // mux_lsr
    assign mux_lsr[0]                = lsr_dr_reg;
    assign mux_lsr[1]                = lsr_oe_reg;
    assign mux_lsr[2]                = lsr_pe_reg;
    assign mux_lsr[3]                = lsr_fe_reg;
    assign mux_lsr[4]                = lsr_bi_reg;
    assign mux_lsr[5]                = lsr_thre_reg;
    assign mux_lsr[6]                = lsr_temt_reg;
    assign mux_lsr[7]                = lsr_rxfifoe_reg;
    assign mux_lsr[31:8]             = '0;
  // mux_msr
    assign mux_msr[0]                = msr_dcts_reg;
    assign mux_msr[1]                = msr_ddsr_reg;
    assign mux_msr[2]                = msr_teri_reg;
    assign mux_msr[3]                = msr_dcd_reg;
    assign mux_msr[4]                = msr_cts_reg;
    assign mux_msr[5]                = msr_dsr_reg;
    assign mux_msr[6]                = msr_ri_reg;
    assign mux_msr[7]                = msr_cd_reg;
    assign mux_msr[31:8]             = '0;
  // mux_stt
    assign mux_stt[0]                = stt_int_txff_full_reg;
    assign mux_stt[1]                = stt_int_txff_empty_reg;
    assign mux_stt[2]                = stt_int_rxff_full_reg;
    assign mux_stt[3]                = stt_int_rxff_empty_reg;
    assign mux_stt[31:4]             = '0;
  
    always_comb begin : READ_DATA_PROC
      apb_rack = 1'b0;
      apb_raddrerr = 1'b0;
      if (apb_rstrobe) begin
        case (apb_raddr )
          12'h000: begin
            apb_rdata = mux_rbr;
          end
          12'h004: begin
            apb_rdata = mux_ier;
          end
          12'h008: begin
            apb_rdata = mux_iir;
          end
          12'h00C: begin
            apb_rdata = mux_lcr;
          end
          12'h010: begin
            apb_rdata = mux_mcr;
          end
          12'h014: begin
            apb_rdata = mux_lsr;
          end
          12'h018: begin
            apb_rdata = mux_msr;
          end
          12'h01C: begin
            apb_rdata = mux_scr;
          end
          12'h020: begin
            apb_rdata = mux_dll;
          end
          12'h024: begin
            apb_rdata = mux_dlh;
          end
          12'h028: begin
            apb_rdata = mux_mdr;
          end
          12'h02C: begin
            apb_rdata = mux_stt;
          end
          default : begin
            apb_rdata = '0;
            apb_raddrerr =  1'b1;
          end
        endcase
        apb_rack = 1'b1;
      end
      else begin
        apb_rdata = '0;
      end
    end
  
  //-----------------------------------------------------------------------------
  // Interrupt Signals
  //-----------------------------------------------------------------------------
  
  endmodule
