

module apb_i2c_top (
   
    output			i2c_if,		// From icore of i2c_core.v
    input           pclk,
    input           prst_n,
    input wire [31:0]		paddr,			// From apbmaster of apb_master.v
    input wire			penable,		// From apbmaster of apb_master.v
    output [31:0]		prdata,		// From icore of i2c_core.v
    input wire			psel,			// From apbmaster of apb_master.v
    input wire [31:0]		pwdata,			// From apbmaster of apb_master.v
    input wire			pwrite,			// From apbmaster of apb_master.v
	output              pready,
	output              pslverr
);
// End of automatics
wire sda, scl;
i2c_core 	i2c_s(/*AUTOINST*/
		      // Outputs
		      .i2c_if		(i2c_if),
		      .prdata		(prdata[31:0]),
		      // Inouts
		      .sda		    (sda),
		      .scl		(   scl),
		      // Inputs
		      .paddr		(paddr[7:0]),
		      .pclk		    (pclk),
		      .penable		(penable),
		      .prst_n		(prst_n),
		      .psel		    (psel),
		      .pwdata		(pwdata[31:0]),
		      .pwrite		(pwrite)
              );

assign   pready   = 1'b1;
assign   pslverr  = 1'b0;
endmodule  
