module apb_uart_interrupt #(
    parameter TX_FIFO_DEPTH = 4,
    parameter RX_FIFO_DEPTH = 4
    )
    (
    input                                   clk,
    input                                   reset_n,
  
    // registers
    input        [2:0]                      IER_i, // interrupt enable register
    input                                   RDA_i, // receiver data available
    input                                   CTI_i, // character timeout indication
  
    // control logic
    input                                   error_i,
    input        [$clog2(RX_FIFO_DEPTH):0]  rx_elements_i,
    input        [$clog2(TX_FIFO_DEPTH):0]  tx_elements_i,
    input        [1:0]                      trigger_level_i,
  
    input        [3:0]                      clr_int_i, // one hot
  
    output logic                            interrupt_o,
    output logic [3:0]                      IIR_o
  );
  
    logic [3:0] iir_n, iir_q;
    logic trigger_level_reached;
  
    always_comb begin
      trigger_level_reached = 1'b0;
      case (trigger_level_i)
        2'b00: begin
          if ($unsigned(rx_elements_i) == 1) begin
            trigger_level_reached = 1'b1;
          end
        end
        2'b01: begin
          if ($unsigned(rx_elements_i) == 4) begin
            trigger_level_reached = 1'b1;
          end
        end
        2'b10: begin
          if ($unsigned(rx_elements_i) == 8) begin
            trigger_level_reached = 1'b1;
          end
        end
        2'b11: begin
          if ($unsigned(rx_elements_i) == 14) begin
            trigger_level_reached = 1'b1;
          end
        end
        default : trigger_level_reached = 1'b1;
      endcase
    end
  
    always_comb begin
      if (clr_int_i == 4'b0) begin
        iir_n = iir_q;
      end
      else begin
        iir_n = iir_q & ~(clr_int_i);
      end
  
      // Receiver line status interrupt on: Overrun error, parity error, framing error or break interrupt
      if (IER_i[2] & error_i) begin
        iir_n = 4'b1100;
      end
      // Received data available or trigger level reached in FIFO mode
      else if (IER_i[0] & (trigger_level_reached | RDA_i)) begin
        iir_n = 4'b1000;
      end
      // Character timeout indication
      else if (IER_i[0] & CTI_i) begin
        iir_n = 4'b1000;
      end
      // Transmitter holding register empty
      else if (IER_i[1] & tx_elements_i == 0) begin
        iir_n = 4'b0100;
      end
    end
  
    always_ff @(posedge clk or negedge reset_n) begin : proc_iir_q
      if(~reset_n) begin
        iir_q <= 4'b0001;
      end else begin
        iir_q <= iir_n;
      end
    end
  
    assign IIR_o = iir_q;
    assign interrupt_o = ~iir_q[0];
  
  endmodule
  
