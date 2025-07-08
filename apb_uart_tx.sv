module apb_uart_tx (
    input                   clk,
    input                   reset_n,
    input                   cfg_en_i,
    input        [15:0]     cfg_div_i,
    input                   cfg_parity_en_i,
    input        [1:0]      cfg_bits_i,
    input                   cfg_stop_bits_i,
   // input  logic            select_event_parity,
    input        [7:0]      tx_data_i,
    input                   tx_valid_i,
    output logic            tx_ready_o,
    output logic            tx_o,
    output logic            busy_o
    );
  
    enum logic [2:0] {
      ST_IDLE,
      ST_START_BIT,
      ST_DATA,
      ST_PARITY,
      ST_STOP_BIT_FIRST,
      ST_STOP_BIT_LAST} current_state, next_state;
  
    logic [7:0]  reg_data;
    logic [7:0]  reg_data_next;
  
    logic [2:0]  reg_bit_count;
    logic [2:0]  reg_bit_count_next;
  
    logic [2:0]  s_target_bits;
  
    logic        parity_bit;
    logic        parity_bit_next;
  
    logic        sampleData;
  
    logic [15:0] baud_cnt;
    logic        baudgen_en;
    logic        bit_done;
  
    assign busy_o = (current_state != ST_IDLE);
  
    always_comb begin
      case(cfg_bits_i)
        2'b00: s_target_bits = 3'h4;
        2'b01: s_target_bits = 3'h5;
        2'b10: s_target_bits = 3'h6;
        2'b11: s_target_bits = 3'h7;
      endcase
    end
  
    always_comb begin
      tx_o = 1'b1;
      sampleData = 1'b0;
      reg_bit_count_next  = reg_bit_count;
      reg_data_next = {1'b1,reg_data[7:1]};
      tx_ready_o = 1'b0;
      baudgen_en = 1'b0;
      parity_bit_next = parity_bit;
      case(current_state)
        ST_IDLE: begin
          if (cfg_en_i) begin
            tx_ready_o = 1'b1;
          end
          if (tx_valid_i) begin
            next_state = ST_START_BIT;
            baudgen_en = 1'b1;
            sampleData = 1'b1;
            reg_data_next = tx_data_i;
          end
          else begin
            next_state = ST_IDLE;
          end
        end
        ST_START_BIT: begin
          tx_o = 1'b0;
          parity_bit_next = 1'b0;
          baudgen_en = 1'b1;
          if (bit_done) begin
            next_state = ST_DATA;
          end
          else begin
            next_state = ST_START_BIT;
          end
        end
        ST_DATA: begin
          tx_o = reg_data[0];
          baudgen_en = 1'b1;
          parity_bit_next = parity_bit ^ reg_data[0];  // eps = 0 0^1 = 1, 1^1 = 0
          if (bit_done) begin
            if (reg_bit_count == s_target_bits) begin
              reg_bit_count_next = 'h0;
              if (cfg_parity_en_i) begin
                next_state = ST_PARITY;
              end
              else begin
                next_state = ST_STOP_BIT_FIRST;
              end
            end
            else begin
              next_state = ST_DATA;
              reg_bit_count_next = reg_bit_count + 1;
              sampleData = 1'b1;
            end
          end
          else begin
            next_state = ST_DATA;
          end
        end
        ST_PARITY: begin
          tx_o = parity_bit;
          baudgen_en = 1'b1;
          if (bit_done) begin
            next_state = ST_STOP_BIT_FIRST;
          end
          else begin
            next_state = ST_PARITY;
          end
        end
        ST_STOP_BIT_FIRST: begin
          tx_o = 1'b1;
          baudgen_en = 1'b1;
          if (bit_done) begin
            if (cfg_stop_bits_i) begin
              next_state = ST_STOP_BIT_LAST;
            end
            else begin
              next_state = ST_IDLE;
            end
          end
          else begin
            next_state = ST_STOP_BIT_FIRST;
          end
        end
        ST_STOP_BIT_LAST: begin
          tx_o = 1'b1;
          if (bit_done) begin
            next_state = ST_IDLE;
            baudgen_en = 1'b0;
          end
          else begin
            next_state = ST_STOP_BIT_LAST;
            baudgen_en = 1'b1;
          end
        end
        default:
          next_state = ST_IDLE;
      endcase
    end
  
    always_ff @(posedge clk or negedge reset_n) begin
      if (~reset_n) begin
        current_state  <= ST_IDLE;
        reg_data       <= 8'hFF;
        reg_bit_count  <=  'h0;
        parity_bit     <= 1'b0;
      end
      else begin
        if(bit_done) begin
          parity_bit <= parity_bit_next;
        end
  
        if(sampleData) begin
          reg_data <= reg_data_next;
        end
  
        reg_bit_count  <= reg_bit_count_next;
        if(cfg_en_i)
          current_state <= next_state;
        else
          current_state <= ST_IDLE;
      end
    end
  
    always_ff @(posedge clk or negedge reset_n) begin
      if (~reset_n) begin
        baud_cnt <= 'h0;
        bit_done <= 1'b0;
      end
      else begin
        if(baudgen_en) begin
          if(baud_cnt == cfg_div_i) begin
            baud_cnt <= 'h0;
            bit_done <= 1'b1;
          end
          else begin
            baud_cnt <= baud_cnt + 1;
            bit_done <= 1'b0;
          end
        end
        else begin
          baud_cnt <= 'h0;
          bit_done <= 1'b0;
        end
      end
    end
  
  endmodule
