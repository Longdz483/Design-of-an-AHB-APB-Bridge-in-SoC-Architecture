module external_block(

input         clk_ext,  //extin
input              pclk,
input             presetn,
input  [2:0]  ps,       
input         edge_mode,


output        clk_pulse

);

reg [7:0] clk_ext_past;
wire        pos_edge;
wire        neg_edge;

reg   [7:0] ps_counter;
wire        in_pulse;
wire        clk_ps;
reg         clk_ps_past;


//Input edge detector
always @(posedge pclk)
if (presetn == 0)
  clk_ext_past <= 8'b0;
else
  clk_ext_past <= clk_ext_past << 1|clk_ext;
  
assign pos_edge = ( (&(~clk_ext_past[3:2])) & (&clk_ext_past[1:0]) );
assign neg_edge = ( (&(~clk_ext_past[1:0])) & (&clk_ext_past[3:2]) );

assign in_pulse = edge_mode?neg_edge:pos_edge;


//prescaler
always @(posedge pclk or negedge presetn)
begin
  if (presetn == 0)
    ps_counter <= 0;
  else
    if (in_pulse)
      ps_counter <= ps_counter + 1; 
    else 
    ps_counter   <= ps_counter;
end

assign clk_ps    =  (ps == 3'd0)? in_pulse
                   :(ps == 3'd1)? ps_counter[0]
                   :(ps == 3'd2)? ps_counter[1]
                   :(ps == 3'd3)? ps_counter[2]
                   :(ps == 3'd4)? ps_counter[3]
                   :(ps == 3'd5)? ps_counter[4]
                   :(ps == 3'd6)? ps_counter[5]
                   :(ps == 3'd7)? ps_counter[6]:0;

//counter edge detector
always @(posedge pclk)
if (presetn == 0)
  clk_ps_past <= 8'b0;
else
  clk_ps_past <= clk_ps;
  
assign  clk_pulse = ~clk_ps_past & clk_ps;
                   
endmodule

