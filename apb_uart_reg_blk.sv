module apb_uart_reg_blk ( 
    output logic [7:0]    reg_thr_data,
    output logic [7:0]    reg_dll_dll,
    output logic          reg_ier_erbi,
    output logic          reg_ier_etbei,
    output logic          reg_ier_elsi,
    output logic          reg_ier_edssi,
    output logic [7:0]    reg_dlh_dlh,
    output logic          reg_fcr_fifoen,
    output logic          reg_fcr_rxclr,
    output logic          reg_fcr_txclr,
    output logic          reg_fcr_dmamode1,
    output logic [1:0]    reg_fcr_rxfiftl,
    output logic [1:0]    reg_lcr_wls,
    output logic          reg_lcr_stb,
    output logic          reg_lcr_pen,
    output logic          reg_lcr_eps,
    output logic          reg_lcr_sp,
    output logic          reg_lcr_bc,
    output logic          reg_lcr_dlab,
    output logic          reg_mcr_rts,
    output logic          reg_mcr_out1,
    output logic          reg_mcr_out2,
    output logic          reg_mcr_loop,
    output logic          reg_mcr_afe,
    output logic [7:0]    reg_scr_scr,
    output logic          reg_mdr_osmsel,
    input        [7:0]    reg_rbr_data,
    input                 reg_iir_ipend,
    input        [2:0]    reg_iir_intid,
    input        [1:0]    reg_iir_fifoen,
    input                 reg_lsr_dr,
    input                 reg_lsr_oe,
    input                 reg_lsr_pe,
    input                 reg_lsr_fe,
    input                 reg_lsr_bi,
    input                 reg_lsr_thre,
    input                 reg_lsr_temt,
    input                 reg_lsr_rxfifoe,
    input                 reg_msr_dcts,
    input                 reg_msr_ddsr,
    input                 reg_msr_teri,
    input                 reg_msr_dcd,
    input                 reg_msr_cts,
    input                 reg_msr_dsr,
    input                 reg_msr_ri,
    input                 reg_msr_cd,
    input                 reg_stt_int_txff_full,
    input                 reg_stt_int_txff_empty,
    input                 reg_stt_int_rxff_full,
    input                 reg_stt_int_rxff_empty,
  // APB Bridge
    //AMBA APB SIGNALS,
    input                 apb_presetn,
    input                 apb_pclk,
    input        [11:0]   apb_paddr,
    input                 apb_psel,
    input                 apb_penable,
    input                 apb_pwrite,
    input        [31:0]   apb_pwdata,
    output logic          apb_pready,
    output logic [31:0]   apb_prdata,
    output logic          apb_pslverr
  // Global Signals
  );
  
  //-------------------------------------------------------------------------
  // Internal Signals
  //-------------------------------------------------------------------------
    logic                 clk;
    logic                 reset_n;
  // APB Bridge
    logic                 apb_rstrobe;
    logic        [11:0]   apb_raddr;
    logic        [31:0]   apb_rdata;
    logic                 apb_rack;
    logic                 apb_raddrerr;
    logic                 apb_wstrobe;
    logic        [11:0]   apb_waddr;
    logic        [31:0]   apb_wdata;
    logic                 apb_wack;
    logic                 apb_waddrerr   ;
  // End of signals APB Bridge
  //Internal Signals for Derivate reg Block
  // End of Derivative Signals
  
  //-------------------------------------------------------------------------
  // Module Instances
  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  // Module apb_uart_rb_regs Instance
  //-------------------------------------------------------------------------
    apb_uart_rb_regs
    apb_uart_rb_regs ( 
      .thr_data                               (reg_thr_data                            ),
      .dll_dll                                (reg_dll_dll                             ),
      .ier_erbi                               (reg_ier_erbi                            ),
      .ier_etbei                              (reg_ier_etbei                           ),
      .ier_elsi                               (reg_ier_elsi                            ),
      .ier_edssi                              (reg_ier_edssi                           ),
      .dlh_dlh                                (reg_dlh_dlh                             ),
      .fcr_fifoen                             (reg_fcr_fifoen                          ),
      .fcr_rxclr                              (reg_fcr_rxclr                           ),
      .fcr_txclr                              (reg_fcr_txclr                           ),
      .fcr_dmamode1                           (reg_fcr_dmamode1                        ),
      .fcr_rxfiftl                            (reg_fcr_rxfiftl                         ),
      .lcr_wls                                (reg_lcr_wls                             ),
      .lcr_stb                                (reg_lcr_stb                             ),
      .lcr_pen                                (reg_lcr_pen                             ),
      .lcr_eps                                (reg_lcr_eps                             ),
      .lcr_sp                                 (reg_lcr_sp                              ),
      .lcr_bc                                 (reg_lcr_bc                              ),
      .lcr_dlab                               (reg_lcr_dlab                            ),
      .mcr_rts                                (reg_mcr_rts                             ),
      .mcr_out1                               (reg_mcr_out1                            ),
      .mcr_out2                               (reg_mcr_out2                            ),
      .mcr_loop                               (reg_mcr_loop                            ),
      .mcr_afe                                (reg_mcr_afe                             ),
      .scr_scr                                (reg_scr_scr                             ),
      .mdr_osmsel                             (reg_mdr_osmsel                          ),
      .rbr_data                               (reg_rbr_data                            ),
      .iir_ipend                              (reg_iir_ipend                           ),
      .iir_intid                              (reg_iir_intid                           ),
      .iir_fifoen                             (reg_iir_fifoen                          ),
      .lsr_dr                                 (reg_lsr_dr                              ),
      .lsr_oe                                 (reg_lsr_oe                              ),
      .lsr_pe                                 (reg_lsr_pe                              ),
      .lsr_fe                                 (reg_lsr_fe                              ),
      .lsr_bi                                 (reg_lsr_bi                              ),
      .lsr_thre                               (reg_lsr_thre                            ),
      .lsr_temt                               (reg_lsr_temt                            ),
      .lsr_rxfifoe                            (reg_lsr_rxfifoe                         ),
      .msr_dcts                               (reg_msr_dcts                            ),
      .msr_ddsr                               (reg_msr_ddsr                            ),
      .msr_teri                               (reg_msr_teri                            ),
      .msr_dcd                                (reg_msr_dcd                             ),
      .msr_cts                                (reg_msr_cts                             ),
      .msr_dsr                                (reg_msr_dsr                             ),
      .msr_ri                                 (reg_msr_ri                              ),
      .msr_cd                                 (reg_msr_cd                              ),
      .stt_int_txff_full                      (reg_stt_int_txff_full                   ),
      .stt_int_txff_empty                     (reg_stt_int_txff_empty                  ),
      .stt_int_rxff_full                      (reg_stt_int_rxff_full                   ),
      .stt_int_rxff_empty                     (reg_stt_int_rxff_empty                  ),
      //Derivative Signals
      //Global Signals
      .clk                                    (clk                                     ),
      .reset_n                                (reset_n                                 ),
      //GENERIC BUS PORTS Signals
      .apb_waddr                              (apb_waddr                               ),
      .apb_raddr                              (apb_raddr                               ),
      .apb_wdata                              (apb_wdata                               ),
      .apb_rdata                              (apb_rdata                               ),
      .apb_rstrobe                            (apb_rstrobe                             ),
      .apb_wstrobe                            (apb_wstrobe                             ),
      .apb_raddrerr                           (apb_raddrerr                            ),
      .apb_waddrerr                           (apb_waddrerr                            ),
      .apb_wack                               (apb_wack                                ),
      .apb_rack                               (apb_rack                                )
     ); 
  //-------------------------------------------------------------------------
  // Module apb_uart_rb_apb_bridge Instance
  //-------------------------------------------------------------------------
    apb_uart_rb_apb_bridge
    apb_uart_rb_apb_bridge ( 
      .clk                                    (clk                                     ),
      .reset_n                                (reset_n                                 ),
      .apb_presetn                            (apb_presetn                             ),
      .apb_pclk                               (apb_pclk                                ),
      .apb_paddr                              (apb_paddr                               ),
      .apb_psel                               (apb_psel                                ),
      .apb_penable                            (apb_penable                             ),
      .apb_pwrite                             (apb_pwrite                              ),
      .apb_pwdata                             (apb_pwdata                              ),
      .apb_pready                             (apb_pready                              ),
      .apb_prdata                             (apb_prdata                              ),
      .apb_pslverr                            (apb_pslverr                             ),
      .apb_rstrobe                            (apb_rstrobe                             ),
      .apb_raddr                              (apb_raddr                               ),
      .apb_rdata                              (apb_rdata                               ),
      .apb_rack                               (apb_rack                                ),
      .apb_raddrerr                           (apb_raddrerr                            ),
      .apb_wstrobe                            (apb_wstrobe                             ),
      .apb_waddr                              (apb_waddr                               ),
      .apb_wdata                              (apb_wdata                               ),
      .apb_wack                               (apb_wack                                ),
      .apb_waddrerr                           (apb_waddrerr                            )
     ); 
  
  endmodule
  
