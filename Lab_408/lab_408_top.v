`include "lab_408_def.vh"

module lab_408_top
(
    inout   wire  JB2, //SDA MASTER
    inout   wire  JC2, //SDA_SLAVE

    input   wire  JC1,
    output  wire  JB1, //SCL MASTER/SLAVE

    input   wire  F50MHz,
    input   wire  BTN0  ,

//------USB COM port
    input   wire    JD4,
    output  wire    JD3,

//-----RS232 COM port
    input   wire    RXD,
    output  wire    TXD,

    input   wire    [7:1]   SW, // addr/command

    output  wire    LED0, //R_W
    output  wire    LED1, //my_reg
    output  wire    LED7, //my_adr

//-------DISPLAY--------
    output  wire    [3:0]   AN   , // anods
    output  wire    [6:0]   seg  , // segments
    output  wire            seg_P, // point
//----------------------

    output  wire    JA1, //T_start
    output  wire    JA2, //T_AC
    output  wire    JA3, //en_tx
    output  wire    JA4, //T_stop
    output  wire    JA7, //en_tx_bl
    output  wire    JB3, //SDA_SLAVE
    output  wire    JB4, //SDA_MASTER
    output  wire    JC7, //en_rx
    output  wire    JC8, //ce_start
    output  wire    JC9, //ce_stop
    output  wire    JC10
);

wire clk, clr, st;

wire    [7:0]   ADR_COM;
wire    [7:0]   adr_REG;
wire    [7:0]   dat_REG;

wire    [7:0]   dat_SLAVE;
wire    [2:0]   N_byte   ;

assign
    JD3 = TXD; //USB-COM_port

`ifndef SIMUL_MODE
    //--- clk buffer
    BUFGDLL DD1 (.I(F50MHz), .O(clk));
`else  // SIMUL_MODE
    assign
        clk = F50MHz;
`endif // SIMUL_MODE

assign
    clr = BTN0;

MASTER_I2C  master
(
    .clk    (clk),
    .clr    (clr),
    .st     (st ),

    // Input data for transmission
    .ADR_COM (ADR_COM),
    .adr_REG (adr_REG),
    .dat_REG (dat_REG),

    // I2C interface
    .SDA    (JB2),
    .SCL    (JB1),

    .SDA_MASTER (JB4),

    // Start/stop transmission signals
    .T_start    (JA1),
    .T_stop     (JA4),

    // Enable transmission
    .en_tx  (JA3),

    // Acknowledge tact
    .T_AC   (JA2),

    // Error trigger (based on acknowledgement from SLAVE)
    .err_AC (),

    // Bit/byte counters
    .cb_bit     (),
    .cb_byte    (),

    // Count-enable signals
    .ce_tact    (),
    .ce_bit     (),
    .ce_byte    (),
    .ce_AC      (),

    // Received data from SLAVE
    .sr_rx_SDA  (),
    .RX_dat     (dat_SLAVE)
);

SLAVE_I2C   slave
(
    // System
    .clk    (clk),
    .clr    (clr),

    // I2C interface
    .SCL        (JC1),
    .SDA        (JC2),
    .SDA_SLAVE  (JB3),

    // I2C slave address
    .Adr_SLAVE  (SW),

    // Enable transmission
    .en_tx      (),

    // Enable receiving
    .en_rx      (JC7),
    .ok_rx_byte (),

    // Acknowledge tact
    .T_AC       (JC10),

    // Read-write mode
    .R_W        (LED0),

    // Bit/byte counters
    .cb_bit     (),
    .cb_byte    (),

    // Count-enable signals
    .ce_start   (JC8 ),
    .ce_stop    (JC9 ),
    .my_adr     (LED7),
    .my_reg     (LED1),

    // Received data from SLAVE
    .sr_rx      (),
    .sr_tx      (),
    .RX_dat     ()
);

ADR_COM_DAT_BL COM_DATA_IN
(
    .clk        (clk    ),
    .clr        (clr    ),
    .Inp1       (RXD    ),
    .Inp2       (JD4    ),
    .ok_rx_bl   (st     ),
    .adr_COM    (ADR_COM),
    .adr_REG    (adr_REG),
    .dat_REG    (dat_REG)
);

TXD_RET_BL  COM_DATA_OUT
(
    .clk        (clk      ),
    .st         (JC9      ),
    .ADR_COM    (ADR_COM  ),
    .adr_REG    (adr_REG  ),
    .dat_MASTER (dat_REG  ),
    .dat_SLAVE  (dat_SLAVE),
    .tx_dat     (         ),
    .TXD        (TXD      ),
    .en_tx      (JA7      )
);

Display DISPLAY
(
    .clk        (clk       ),
    .adr_REG    (adr_REG   ),
    .dat_MASTER (dat_REG   ),
    .dat_SLAVE  (dat_SLAVE ),
    .R_W        (ADR_COM[0]),
    .AN         (AN        ),
    .seg        (seg       ),
    .seg_P      (seg_P     )
);

endmodule
