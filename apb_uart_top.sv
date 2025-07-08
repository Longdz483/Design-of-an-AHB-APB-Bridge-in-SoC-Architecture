module apb_uart #(
    parameter APB_ADDR_WIDTH = 12  //APB slaves are 4KB by default
  )
  (
    input                             CLK,
    input                             RESETN,
    input        [APB_ADDR_WIDTH-1:0] PADDR,
    input                      [31:0] PWDATA,
    input                             PWRITE,
    input                             PSEL,
    input                             PENABLE,
    output logic               [31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,
  
    input                             rx_i,      // Receiver input
    output logic                      tx_o,      // Transmitter output
  
    output logic                      event_o    // interrupt/event output
  );
  
    parameter TX_FIFO_DEPTH = 8; // in bytes
    parameter RX_FIFO_DEPTH = 8; // in bytes
  
    // receive buffer register, read only
    logic [7:0]       rx_data;
    // parity error
    logic [3:0]       clr_int;
  
    /* verilator lint_off UNOPTFLAT */
    // tx flow control
    logic             tx_ready;
    /* lint_on */
  
    // rx flow control
    logic             rx_valid;
  
    logic             tx_fifo_clr_n, tx_fifo_clr_q;
    logic             rx_fifo_clr_n, rx_fifo_clr_q;
  
    logic             fifo_tx_valid;
    logic             tx_valid;
    logic             fifo_rx_valid;
    logic             fifo_rx_ready;
    logic             rx_ready;
  
    logic             [7:0] fifo_tx_data;
    logic             [8:0] fifo_rx_data;
  
    logic             [7:0] tx_data;
    logic             [$clog2(TX_FIFO_DEPTH):0] tx_elements;
    logic             [$clog2(RX_FIFO_DEPTH):0] rx_elements;
  
    logic             fifo_tx_error;
    logic             fifo_rx_error;
    logic             reg_error;
    logic             parity_error;
  
    logic [7:0]       reg_thr_data;
    logic [7:0]       reg_dll_dll;
    logic             reg_ier_erbi;
    logic             reg_ier_etbei;
    logic             reg_ier_elsi;
    logic             reg_ier_edssi;
    logic [7:0]       reg_dlh_dlh;
    logic             reg_fcr_fifoen;
    logic             reg_fcr_rxclr;
    logic             reg_fcr_txclr;
    logic             reg_fcr_dmamode1;
    logic [1:0]       reg_fcr_rxfiftl;
    logic [1:0]       reg_lcr_wls;
    logic             reg_lcr_stb;
    logic             reg_lcr_pen;
    logic             reg_lcr_eps;
    logic             reg_lcr_sp;
    logic             reg_lcr_bc;
    logic             reg_lcr_dlab;
    logic             reg_mcr_rts;
    logic             reg_mcr_out1;
    logic             reg_mcr_out2;
    logic             reg_mcr_loop;
    logic             reg_mcr_afe;
    logic [7:0]       reg_scr_scr;
    logic             reg_mdr_osmsel;
    logic [7:0]       reg_rbr_data;
    logic             reg_iir_ipend;
    logic [2:0]       reg_iir_intid;
    logic [1:0]       reg_iir_fifoen;
    logic             reg_lsr_dr;
    logic             reg_lsr_oe;
    logic             reg_lsr_pe;
    logic             reg_lsr_fe;
    logic             reg_lsr_bi;
    logic             reg_lsr_thre;
    logic             reg_lsr_temt;
    logic             reg_lsr_rxfifoe;
    logic             reg_msr_dcts;
    logic             reg_msr_ddsr;
    logic             reg_msr_teri;
    logic             reg_msr_dcd;
    logic             reg_msr_cts;
    logic             reg_msr_dsr;
    logic             reg_msr_ri;
    logic             reg_msr_cd;
    logic             reg_stt_int_txff_full;
    logic             reg_stt_int_txff_empty;
    logic             reg_stt_int_rxff_full;
    logic             reg_stt_int_rxff_empty;
  
    // TODO: check that stop bits are really not necessary here
    apb_uart_rx uart_rx (
      .clk                ( CLK                           ),
      .reset_n            ( RESETN                        ),
      .rx_i               ( rx_i                          ),
      .cfg_en_i           ( 1'b1                          ),
      .cfg_div_i          ( {reg_dlh_dlh, reg_dll_dll}    ),
      .cfg_parity_en_i    ( reg_lcr_pen                   ),
      .cfg_bits_i         ( reg_lcr_wls                   ),
      // .cfg_stop_bits_i    ( regs_q[LCR][2]                ),
     // .select_event_parity(reg_lcr_eps),
      .busy_o             (                               ),
      /* lint_on */
      .err_o              ( parity_error                  ),
      .err_clr_i          ( 1'b1                          ),
      .rx_data_o          ( rx_data                       ),
      .rx_valid_o         ( rx_valid                      ),
      .rx_ready_i         ( rx_ready                      )
    );
  
    apb_uart_tx uart_tx (
      .clk                ( CLK                           ),
      .reset_n            ( RESETN                        ),
      .tx_o               ( tx_o                          ),
      /* verilator lint_off PINCONNECTEMPTY */
      .busy_o             (                               ),
      /* lint_on */
      .cfg_en_i           ( 1'b1                          ),
      .cfg_div_i          ( {reg_dlh_dlh, reg_dll_dll}    ),
      .cfg_parity_en_i    ( reg_lcr_pen                   ),
      .cfg_bits_i         ( reg_lcr_wls                   ),
      .cfg_stop_bits_i    ( reg_lcr_stb                   ),
  
      .tx_data_i          ( tx_data                       ),
      .tx_valid_i         ( tx_valid                      ),
     // .select_event_parity(reg_lcr_eps),
      .tx_ready_o         ( tx_ready                      )
    );
  
    apb_uart_fifo #(
      .DATA_WIDTH         ( 9                             ),
      .BUFFER_DEPTH       ( RX_FIFO_DEPTH                 )
    ) uart_rx_fifo (
      .clk                ( CLK                           ),
      .reset_n            ( RESETN                        ),
  
      .clr_i              ( reg_fcr_rxclr                 ),
  
      .elements_o         ( rx_elements                   ),
  
      .data_o             ( fifo_rx_data                  ),
      .valid_o            ( fifo_rx_valid                 ),
      .ready_i            ( fifo_rx_ready                 ),
  
      .valid_i            ( rx_valid                      ),
      .data_i             ( { parity_error, rx_data }     ),
      .ready_o            ( rx_ready                      ),
      .empty              ( reg_stt_int_rxff_empty        ),
      .full               ( reg_stt_int_rxff_full         ),
      .error              ( fifo_rx_error                 )
    );
  
    apb_uart_fifo #(
      .DATA_WIDTH         ( 8                             ),
      .BUFFER_DEPTH       ( TX_FIFO_DEPTH                 )
    ) uart_tx_fifo (
      .clk                ( CLK                           ),
      .reset_n            ( RESETN                        ),
  
      .clr_i              ( reg_fcr_txclr                 ),
  
      .elements_o         ( tx_elements                   ),
  
      .data_o             ( tx_data                       ),
      .valid_o            ( tx_valid                      ),
      .ready_i            ( tx_ready                      ),
  
      .valid_i            ( fifo_tx_valid                 ),
      .data_i             ( reg_thr_data                  ),
      // not needed since we are getting the status via the fifo population
      .ready_o            (                               ),
      .empty              ( reg_stt_int_txff_empty        ),
      .full               ( reg_stt_int_txff_full         ),
      .error              ( fifo_tx_error                 )
    );
  
    apb_uart_interrupt #(
      .TX_FIFO_DEPTH (TX_FIFO_DEPTH),
      .RX_FIFO_DEPTH (RX_FIFO_DEPTH)
    ) uart_interrupt (
      .clk                ( CLK                           ),
      .reset_n            ( RESETN                        ),
  
      .IER_i              ( {reg_ier_elsi, reg_ier_etbei, reg_ier_erbi} ), // interrupt enable register
      .RDA_i              ( reg_lsr_dr                    ), // receiver data available
      .CTI_i              ( 1'b0                          ), // character timeout indication
  
      .error_i            ( reg_lsr_pe                    ),
      .rx_elements_i      ( rx_elements                   ),
      .tx_elements_i      ( tx_elements                   ),
      .trigger_level_i    ( reg_fcr_rxfiftl               ),
  
      .clr_int_i          ( clr_int                       ), // one hot
  
      .interrupt_o        ( event_o                       ),
      .IIR_o              ( {reg_iir_intid, reg_iir_ipend})
    );
  
    // UART Registers
    apb_uart_reg_blk uart_reg_blk (
      .apb_presetn        (RESETN                         ),
      .apb_pclk           (CLK                            ),
      .apb_paddr          (PADDR                          ),
      .apb_psel           (PSEL                           ),
      .apb_penable        (PENABLE                        ),
      .apb_pwrite         (PWRITE                         ),
      .apb_pwdata         (PWDATA                         ),
      .apb_pready         (PREADY                         ),
      .apb_prdata         (PRDATA                         ),
      .apb_pslverr        (reg_error                      ),
  
      .reg_thr_data       (reg_thr_data),
      .reg_dll_dll        (reg_dll_dll),
      .reg_ier_erbi       (reg_ier_erbi),
      .reg_ier_etbei      (reg_ier_etbei),
      .reg_ier_elsi       (reg_ier_elsi),
      .reg_ier_edssi      (reg_ier_edssi),
      .reg_dlh_dlh        (reg_dlh_dlh),
      .reg_fcr_fifoen     (reg_fcr_fifoen),
      .reg_fcr_rxclr      (reg_fcr_rxclr),
      .reg_fcr_txclr      (reg_fcr_txclr),
      .reg_fcr_dmamode1   (reg_fcr_dmamode1),
      .reg_fcr_rxfiftl    (reg_fcr_rxfiftl),
      .reg_lcr_wls        (reg_lcr_wls),
      .reg_lcr_stb        (reg_lcr_stb),
      .reg_lcr_pen        (reg_lcr_pen),
      .reg_lcr_eps        (reg_lcr_eps),
      .reg_lcr_sp         (reg_lcr_sp),
      .reg_lcr_bc         (reg_lcr_bc),
      .reg_lcr_dlab       (reg_lcr_dlab),
      .reg_mcr_rts        (reg_mcr_rts),
      .reg_mcr_out1       (reg_mcr_out1),
      .reg_mcr_out2       (reg_mcr_out2),
      .reg_mcr_loop       (reg_mcr_loop),
      .reg_mcr_afe        (reg_mcr_afe),
      .reg_scr_scr        (reg_scr_scr),
      .reg_mdr_osmsel     (reg_mdr_osmsel),
      .reg_rbr_data       (reg_rbr_data),
      .reg_iir_ipend      (reg_iir_ipend),
      .reg_iir_intid      (reg_iir_intid),
      .reg_iir_fifoen     (reg_iir_fifoen),
      .reg_lsr_dr         (reg_lsr_dr),
      .reg_lsr_oe         (reg_lsr_oe),
      .reg_lsr_pe         (reg_lsr_pe),
      .reg_lsr_fe         (reg_lsr_fe),
      .reg_lsr_bi         (reg_lsr_bi),
      .reg_lsr_thre       (reg_lsr_thre),
      .reg_lsr_temt       (reg_lsr_temt),
      .reg_lsr_rxfifoe    (reg_lsr_rxfifoe),
      .reg_msr_dcts       (reg_msr_dcts),
      .reg_msr_ddsr       (reg_msr_ddsr),
      .reg_msr_teri       (reg_msr_teri),
      .reg_msr_dcd        (reg_msr_dcd),
      .reg_msr_cts        (reg_msr_cts),
      .reg_msr_dsr        (reg_msr_dsr),
      .reg_msr_ri         (reg_msr_ri),
      .reg_msr_cd         (reg_msr_cd),
      .reg_stt_int_txff_full  (reg_stt_int_txff_full),
      .reg_stt_int_txff_empty (reg_stt_int_txff_empty),
      .reg_stt_int_rxff_full  (reg_stt_int_rxff_full),
      .reg_stt_int_rxff_empty (reg_stt_int_rxff_empty)
      );
  
    assign PSLVERR = fifo_tx_error | fifo_rx_error | reg_error;
    assign reg_rbr_data = fifo_rx_data[7:0];
  
    // register write and update logic
    always_comb begin
      tx_fifo_clr_n   = 1'b0; // self clearing
      rx_fifo_clr_n   = 1'b0; // self clearing
  
      // rx status
      reg_lsr_dr = fifo_rx_valid; // fifo is empty
  
      // parity error on receiving part has occured
      reg_lsr_pe = fifo_rx_data[8]; // parity error is detected when element is retrieved
  
      // tx status register
      reg_lsr_thre = ~ (|tx_elements); // fifo is empty
      reg_lsr_temt = tx_ready & ~ (|tx_elements); // shift register and fifo are empty
  
  
    end
  
    always_ff @(posedge CLK or negedge RESETN) begin : proc_fifo_tx_valid
      if(~RESETN) begin
        fifo_tx_valid <= 0;
      end else begin
        if (PSEL && PENABLE && PWRITE) begin
          case (PADDR)
            12'h000: begin // either THR or DLL
              fifo_tx_valid <= 1'b1;
            end
            default: fifo_tx_valid <= 1'b0;
          endcase
        end
        else begin
          fifo_tx_valid <= 1'b0;
        end
      end
    end
  
    // register read logic
    always_ff @(posedge CLK or negedge RESETN) begin : proc_
      if(~RESETN) begin
        fifo_rx_ready <= 0;
        clr_int <= 4'b0;
      end else begin
        if (PSEL && PENABLE && !PWRITE) begin
          case (PADDR)
            12'h000: begin // either RBR or DLL
              fifo_rx_ready <= 1'b1;
              clr_int <= 4'b1000; // clear Received Data Available interrupt
            end
            12'h008: begin // interrupt identification register read only
              clr_int <= 4'b0100; // clear Transmitter Holding Register Empty
            end
            12'h014: begin // Line Status Register
              clr_int <= 4'b1100; // clear parrity interrupt error
            end
            default: begin
              fifo_rx_ready <= 0;
              clr_int <= 4'b0;
            end
          endcase
        end
        else begin
          fifo_rx_ready <= 0;
          clr_int <= 4'b0;
        end
      end
    end
  
    // synchronouse part
    always_ff @(posedge CLK or negedge RESETN) begin
      if(~RESETN) begin
        tx_fifo_clr_q   <= 1'b0;
        rx_fifo_clr_q   <= 1'b0;
      end
      else begin
        tx_fifo_clr_q   <= tx_fifo_clr_n;
        rx_fifo_clr_q   <= rx_fifo_clr_n;
      end
    end
  
    // APB logic: we are always ready to capture the data into our regs
    // not supporting transfare failure
  endmodule
  
