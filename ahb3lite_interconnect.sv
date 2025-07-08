`include "ahb3lite_pkg.sv"
module ahb3lite_interconnect
    import ahb3lite_pkg::*;
    #(
      parameter                  HADDR_SIZE                   = 32,
      parameter                  HDATA_SIZE                   = 32,
      parameter                  MASTERS                      = 3, //number of AHB Masters
      parameter                  SLAVES                       = 8, //number of AHB slaves
    
      parameter bit [SLAVES-1:0] SLAVE_MASK         [MASTERS] = '{MASTERS{ {SLAVES{1'b1}} }},
      parameter bit [SLAVES-1:0] ERROR_ON_SLAVE_MASK[MASTERS] = invert_slave_mask(),
      parameter bit              ERROR_ON_NO_SLAVE  [MASTERS] = '{MASTERS {1'b0 }},
    
      //actually localparam
      parameter                  MASTER_BITS = MASTERS==1 ? 1 : $clog2(MASTERS)
    )
    (
      //Common signals
      input                   HRESETn,
                              HCLK,
    
      //Master Ports; AHB masters connect to these
      // thus these are actually AHB Slave Interfaces
      input  [MASTER_BITS-1:0] mst_priority  [MASTERS],
    
      input                    mst_HSEL      [MASTERS],
      input  [HADDR_SIZE -1:0] mst_HADDR     [MASTERS],
      input  [HDATA_SIZE -1:0] mst_HWDATA    [MASTERS],
      output [HDATA_SIZE -1:0] mst_HRDATA    [MASTERS],
      input                    mst_HWRITE    [MASTERS],
      input  [            2:0] mst_HSIZE     [MASTERS],
      input  [            2:0] mst_HBURST    [MASTERS],
      input  [            3:0] mst_HPROT     [MASTERS],
      input  [            1:0] mst_HTRANS    [MASTERS],
      input                    mst_HMASTLOCK [MASTERS],
      output                   mst_HREADYOUT [MASTERS],
      input                    mst_HREADY    [MASTERS],
      output                   mst_HRESP     [MASTERS],
    
      //Slave Ports; AHB Slaves connect to these
      //  thus these are actually AHB Master Interfaces
      input  [HADDR_SIZE -1:0] slv_addr_mask [SLAVES],
      input  [HADDR_SIZE -1:0] slv_addr_base [SLAVES],
    
      output                   slv_HSEL      [SLAVES],
      output [HADDR_SIZE -1:0] slv_HADDR     [SLAVES],
      output [HDATA_SIZE -1:0] slv_HWDATA    [SLAVES],
      input  [HDATA_SIZE -1:0] slv_HRDATA    [SLAVES],
      output                   slv_HWRITE    [SLAVES],
      output [            2:0] slv_HSIZE     [SLAVES],
      output [            2:0] slv_HBURST    [SLAVES],
      output [            3:0] slv_HPROT     [SLAVES],
      output [            1:0] slv_HTRANS    [SLAVES],
      output                   slv_HMASTLOCK [SLAVES],
      output                   slv_HREADYOUT [SLAVES], //HREADYOUT to slave-decoder; generates HREADY to all connected slaves
      input                    slv_HREADY    [SLAVES], //combinatorial HREADY from all connected slaves
      input                    slv_HRESP     [SLAVES]
    );
      //////////////////////////////////////////////////////////////////
      //
      // Constants
      //
      typedef bit [SLAVES-1:0] slave_mask_t [MASTERS];
    
      //////////////////////////////////////////////////////////////////
      //
      // Functions
      //
      function slave_mask_t invert_slave_mask;
        for (int i=0; i < MASTERS; i++)
          invert_slave_mask[i] = ~SLAVE_MASK[i];
      endfunction : invert_slave_mask
    
    
      //////////////////////////////////////////////////////////////////
      //
      // Variables
      //
      logic [MASTERS-1:0]             [MASTER_BITS-1:0] frommstpriority;
      logic [MASTERS-1:0][SLAVES -1:0]                  frommstHSEL;
      logic [MASTERS-1:0]             [HADDR_SIZE -1:0] frommstHADDR;
      logic [MASTERS-1:0]             [HDATA_SIZE -1:0] frommstHWDATA;
      logic [MASTERS-1:0][SLAVES -1:0][HDATA_SIZE -1:0] tomstHRDATA;
      logic [MASTERS-1:0]                               frommstHWRITE;
      logic [MASTERS-1:0]             [            2:0] frommstHSIZE;
      logic [MASTERS-1:0]             [            2:0] frommstHBURST;
      logic [MASTERS-1:0]             [            3:0] frommstHPROT;
      logic [MASTERS-1:0]             [            1:0] frommstHTRANS;
      logic [MASTERS-1:0]                               frommstHMASTLOCK;
      logic [MASTERS-1:0]                               frommstHREADYOUT,
                                                        frommst_canswitch;
      logic [MASTERS-1:0][SLAVES -1:0]                  tomstHREADY;
      logic [MASTERS-1:0][SLAVES -1:0]                  tomstHRESP;
      logic [MASTERS-1:0][SLAVES -1:0]                  tomstgrant;
    
    
      logic [SLAVES -1:0][MASTERS-1:0][MASTER_BITS-1:0] toslvpriority;
      logic [SLAVES -1:0][MASTERS-1:0]                  toslvHSEL;
      logic [SLAVES -1:0][MASTERS-1:0][HADDR_SIZE -1:0] toslvHADDR;
      logic [SLAVES -1:0][MASTERS-1:0][HDATA_SIZE -1:0] toslvHWDATA;
      logic [SLAVES -1:0]             [HDATA_SIZE -1:0] fromslvHRDATA;
      logic [SLAVES -1:0][MASTERS-1:0]                  toslvHWRITE;
      logic [SLAVES -1:0][MASTERS-1:0][            2:0] toslvHSIZE;
      logic [SLAVES -1:0][MASTERS-1:0][            2:0] toslvHBURST;
      logic [SLAVES -1:0][MASTERS-1:0][            3:0] toslvHPROT;
      logic [SLAVES -1:0][MASTERS-1:0][            1:0] toslvHTRANS;
      logic [SLAVES -1:0][MASTERS-1:0]                  toslvHMASTLOCK;
      logic [SLAVES -1:0][MASTERS-1:0]                  toslvHREADY,
                                                        toslv_canswitch;
      logic [SLAVES -1:0]                               fromslvHREADYOUT;
      logic [SLAVES -1:0]                               fromslvHRESP;
      logic [SLAVES -1:0][MASTERS-1:0]                  fromslvgrant;
    
    
      genvar m,s;
    
    
      //////////////////////////////////////////////////////////////////
      //
      // Module Body
      //
    
    //synopsys translate_off
    initial
    begin
        //wait for potential always_comb signals to settle
        #1;
        $display("\n\n");
        $display ("------------------------------------------------------------");
        $display (" ,------.                    ,--.                ,--.       ");
        $display (" |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---. ");
        $display (" |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--' ");
        $display (" |  |\\  \\ ' '-' '\\ '-'  |    |  '--.' '-' ' '-' ||  |\\ `--. ");
        $display (" `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---' ");
        $display ("- AHB3-Lite Interconnect Configuration---  `---'  ----------");
        $display ("- Module: %m");
        $display ("- Masters: %0d, Slaves: %0d", MASTERS, SLAVES);
        for (int n=0; n < MASTERS; n++)
          $display ("master[%2d] priority=%0d", n, mst_priority[n]);
        for (int n=0; n < SLAVES; n++)
          $display ("slv_addr_base[%3d]=%32b (0x%8h), slv_addr_mask[%3d]=%32b (0x%8h)", n, slv_addr_base[n], slv_addr_base[n], n, slv_addr_mask[n], slv_addr_mask[n]);
    end
    //synopsys translate_on
    
    
      /*
       * Hookup Master Interfaces
       */
    generate
      for (m=0;m < MASTERS; m++)
      begin: gen_master_ports
      ahb3lite_interconnect_master_port #(
        .HADDR_SIZE          ( HADDR_SIZE             ),
        .HDATA_SIZE          ( HDATA_SIZE             ),
        .MASTERS             ( MASTERS                ),
        .SLAVES              ( SLAVES                 ),
        .SLAVE_MASK          ( SLAVE_MASK         [m] ),
        .ERROR_ON_SLAVE_MASK ( ERROR_ON_SLAVE_MASK[m] ),
        .ERROR_ON_NO_SLAVE   ( ERROR_ON_NO_SLAVE  [m] ) )
      master_port (
        .HRESETn             ( HRESETn                ),
        .HCLK                ( HCLK                   ),
         
        //AHB Slave Interfaces (receive data from AHB Masters)
        //AHB Masters conect to these ports
        .mst_priority        ( mst_priority       [m] ),
        .mst_HSEL            ( mst_HSEL           [m] ),
        .mst_HADDR           ( mst_HADDR          [m] ),
        .mst_HWDATA          ( mst_HWDATA         [m] ),
        .mst_HRDATA          ( mst_HRDATA         [m] ),
        .mst_HWRITE          ( mst_HWRITE         [m] ),
        .mst_HSIZE           ( mst_HSIZE          [m] ),
        .mst_HBURST          ( mst_HBURST         [m] ),
        .mst_HPROT           ( mst_HPROT          [m] ),
        .mst_HTRANS          ( mst_HTRANS         [m] ),
        .mst_HMASTLOCK       ( mst_HMASTLOCK      [m] ),
        .mst_HREADYOUT       ( mst_HREADYOUT      [m] ),
        .mst_HREADY          ( mst_HREADY         [m] ),
        .mst_HRESP           ( mst_HRESP          [m] ),
        
        //AHB Master Interfaces (send data to AHB slaves)
        //AHB Slaves connect to these ports
        .slvHADDRmask        ( slv_addr_mask          ),
        .slvHADDRbase        ( slv_addr_base          ),
        .slvpriority         ( frommstpriority    [m] ),
        .slvHSEL             ( frommstHSEL        [m] ),
        .slvHADDR            ( frommstHADDR       [m] ),
        .slvHWDATA           ( frommstHWDATA      [m] ),
        .slvHRDATA           ( tomstHRDATA        [m] ),
        .slvHWRITE           ( frommstHWRITE      [m] ),
        .slvHSIZE            ( frommstHSIZE       [m] ),
        .slvHBURST           ( frommstHBURST      [m] ),
        .slvHPROT            ( frommstHPROT       [m] ),
        .slvHTRANS           ( frommstHTRANS      [m] ),
        .slvHMASTLOCK        ( frommstHMASTLOCK   [m] ),
        .slvHREADY           ( tomstHREADY        [m] ),
        .slvHREADYOUT        ( frommstHREADYOUT   [m] ),
        .slvHRESP            ( tomstHRESP         [m] ),
    
        .can_switch          ( frommst_canswitch  [m] ),
        .master_granted      ( tomstgrant         [m] ) );
        end
    endgenerate
    
    
      /*
       * wire mangling
       */
      //Master-->Slave
      generate
        for (s=0; s<SLAVES; s++)
        begin: slave
          for (m=0; m<MASTERS; m++)
          begin: master
              assign toslvpriority    [s][m] = frommstpriority    [m];
              assign toslvHSEL        [s][m] = frommstHSEL        [m][s];
              assign toslvHADDR       [s][m] = frommstHADDR       [m];
              assign toslvHWDATA      [s][m] = frommstHWDATA      [m];
              assign toslvHWRITE      [s][m] = frommstHWRITE      [m];
              assign toslvHSIZE       [s][m] = frommstHSIZE       [m];
              assign toslvHBURST      [s][m] = frommstHBURST      [m];
              assign toslvHPROT       [s][m] = frommstHPROT       [m];
              assign toslvHTRANS      [s][m] = frommstHTRANS      [m];
              assign toslvHMASTLOCK   [s][m] = frommstHMASTLOCK   [m];
              assign toslvHREADY      [s][m] = frommstHREADYOUT   [m]; //feed Masters's HREADY signal to slave port
              assign toslv_canswitch  [s][m] = frommst_canswitch  [m];
          end //next m
        end //next s
      endgenerate
    
    
      /*
       * wire mangling
       */
      //Slave-->Master
      generate
        for (m=0; m<MASTERS; m++)
        begin: master
          for (s=0; s<SLAVES; s++)
          begin: slave
              assign tomstgrant [m][s] = fromslvgrant    [s][m];   
              assign tomstHRDATA[m][s] = fromslvHRDATA   [s];
              assign tomstHREADY[m][s] = fromslvHREADYOUT[s];
              assign tomstHRESP [m][s] = fromslvHRESP    [s];
          end //next s
        end //next m
      endgenerate
    
    
      /*
       * Hookup Slave Interfaces
       */
    generate
      for (s=0;s < SLAVES; s++)
      begin: gen_slave_ports
      ahb3lite_interconnect_slave_port #(
        .HADDR_SIZE      ( HADDR_SIZE           ),
        .HDATA_SIZE      ( HDATA_SIZE           ),
        .MASTERS         ( MASTERS              ) )
      slave_port (
        .HRESETn         ( HRESETn              ),
        .HCLK            ( HCLK                 ),
         
        //AHB Slave Interfaces (receive data from AHB Masters)
        //AHB Masters connect to these ports
        .mstpriority     ( toslvpriority    [s] ),
        .mstHSEL         ( toslvHSEL        [s] ),
        .mstHADDR        ( toslvHADDR       [s] ),
        .mstHWDATA       ( toslvHWDATA      [s] ),
        .mstHRDATA       ( fromslvHRDATA    [s] ),
        .mstHWRITE       ( toslvHWRITE      [s] ),
        .mstHSIZE        ( toslvHSIZE       [s] ),
        .mstHBURST       ( toslvHBURST      [s] ),
        .mstHPROT        ( toslvHPROT       [s] ),
        .mstHTRANS       ( toslvHTRANS      [s] ),
        .mstHMASTLOCK    ( toslvHMASTLOCK   [s] ),
        .mstHREADY       ( toslvHREADY      [s] ),
        .mstHREADYOUT    ( fromslvHREADYOUT [s] ),
        .mstHRESP        ( fromslvHRESP     [s] ),
    
    
        //AHB Master Interfaces (send data to AHB slaves)
        //AHB Slaves connect to these ports
        .slv_HSEL        ( slv_HSEL        [s] ),
        .slv_HADDR       ( slv_HADDR       [s] ),
        .slv_HWDATA      ( slv_HWDATA      [s] ),
        .slv_HRDATA      ( slv_HRDATA      [s] ),
        .slv_HWRITE      ( slv_HWRITE      [s] ),
        .slv_HSIZE       ( slv_HSIZE       [s] ),
        .slv_HBURST      ( slv_HBURST      [s] ),
        .slv_HPROT       ( slv_HPROT       [s] ),
        .slv_HTRANS      ( slv_HTRANS      [s] ),
        .slv_HMASTLOCK   ( slv_HMASTLOCK   [s] ),
        .slv_HREADYOUT   ( slv_HREADYOUT   [s] ),
        .slv_HREADY      ( slv_HREADY      [s] ),
        .slv_HRESP       ( slv_HRESP       [s] ),
    
        //Internal signals
        .can_switch      ( toslv_canswitch [s] ),
        .granted_master  ( fromslvgrant    [s] ) );
      end
    endgenerate
    
    
    endmodule
    
