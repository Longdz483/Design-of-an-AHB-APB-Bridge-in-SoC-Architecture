module apb_uart_fifo #(
    parameter DATA_WIDTH = 8,
    parameter BUFFER_DEPTH = 8,
    parameter LOG_BUFFER_DEPTH = $clog2(BUFFER_DEPTH)
    )
    (
    input                             clk,
    input                             reset_n,
    input                             clr_i,
    input                             ready_i,
    input                             valid_i,
    input        [DATA_WIDTH-1 : 0]   data_i,
    output logic                      ready_o,
    output logic                      valid_o,
    output logic [LOG_BUFFER_DEPTH:0] elements_o,
    output logic [DATA_WIDTH-1 : 0]   data_o,
    output logic                      empty,
    output logic                      full,
    output logic                      error
    );
  
    // Internal data structures
    /* verilator lint_off WIDTH */
    logic [LOG_BUFFER_DEPTH-1:0]     pointer_in;  // location to which we last wrote
    logic [LOG_BUFFER_DEPTH-1:0]     pointer_out; // location from which we last sent
    /* lint_off */
    logic [LOG_BUFFER_DEPTH:0]       elements;    // number of elements in the buffer
    logic [DATA_WIDTH-1:0]           buffer [BUFFER_DEPTH - 1 : 0];
  
  
    // Update output ports
    assign data_o  = buffer[pointer_out];
    assign valid_o = (elements != 0);
  
    assign ready_o = ~full;
  
    assign empty = (elements == 0);
    assign full = (elements == BUFFER_DEPTH);
    assign error = (full & valid_i);
    assign elements_o = elements;
  
    always_ff @(posedge clk or negedge reset_n) begin : proc_elements_sequential
      if(~reset_n) begin
        elements <= 0;
      end
      else begin
        if (clr_i) begin
          elements <= 0;
        end
        else begin
          // ------------------
          // Are we filling up?
          // ------------------
          // One out, none in
          if (ready_i && valid_o && (!valid_i || full)) begin
            elements <= elements - 1;
            // None out, one in
          end
          else if ((!valid_o || !ready_i) && valid_i && !full) begin
            elements <= elements + 1;
            // Else, either one out and one in, or none out and none in - stays unchanged
          end
        end
      end
    end
  
    always @(posedge clk) begin : proc_buffers_sequential
      // Update the memory
      if (valid_i && !full)
        buffer[pointer_in] <= data_i;
    end
  
    always_ff @(posedge clk or negedge reset_n) begin: proc_sequential
      if (reset_n == 1'b0) begin
        pointer_out <= 0;
        pointer_in  <= 0;
      end
      else begin
        if(clr_i) begin
          pointer_out <= 0;
          pointer_in  <= 0;
        end
        else begin
          // ------------------------------------
          // Check what to do with the input side
          // ------------------------------------
          // We have some input, increase by 1 the input pointer
          if (valid_i && !full) begin
            if (pointer_in == $unsigned(BUFFER_DEPTH - 1)) begin
              pointer_in <= 0;
            end
            else begin
              pointer_in <= pointer_in + 1;
            end
          end
          // Else we don't have any input, the input pointer stays the same
  
          // -------------------------------------
          // Check what to do with the output side
          // -------------------------------------
          // We had pushed one flit out, we can try to go for the next one
          if (ready_i && valid_o) begin
            if (pointer_out == $unsigned(BUFFER_DEPTH - 1)) begin
              pointer_out <= 0;
            end
            else begin
              pointer_out <= pointer_out + 1;
            end
          end
          // Else stay on the same output location
        end
      end
    end
  
  endmodule
