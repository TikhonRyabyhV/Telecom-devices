module lab_405_top
(
    // System
    input   wire    F50MHz,
    input   wire    BTN0  ,

    // Control signals
    input   wire    [6:0]   SW,

    // TX channels (0 and 1)
    input   wire    JA7,
    input   wire    JA1,

    // Display outputs
    output  wire    [3:0]   AN   ,
    output  wire    [6:0]   seg  ,
    output  wire            seg_P,

    // RX channels (0 and 1)
    output  wire    JB7,
    output  wire    JB1
);

wire    clk;
wire    clr;

wire    ce1ms   ;
wire    ce1s_Nms;

wire    ce_wr;

wire    [15:0]   dat_disp;

wire    [ 7:0]   RX_adr;
wire    [22:0]   RX_dat;
wire    [ 7:0]   TX_adr;
wire    [22:0]   TX_dat;
wire    [ 7:0]   dat_REG;

`ifndef SIMUL_MODE
    // Clock buffer
    BUFGDLL DD1 (.I(F50MHz), .O(clk));
`else  // SIMUL_MODE
    assign
        clk = F50MHz;
`endif // SIMUL_MODE

// Forming reset
assign
    clr = BTN0;

// ARINC transmitter
AR_TXD  TX
(
    // System
    .clk        (clk    ),
    .clr        (clr    ),
    .st         (ce1ms  ),

    // Speed mode
    .Nvel       (SW[6:5]),
    .ce_tact    (       ),

    // Address and data for transmission
    .ADR        (TX_adr ),
    .DAT        (TX_dat ),

    // Channels for '0' and '1'
    .TXD0       (JB7    ),
    .TXD1       (JB1    ),

    // Modulator
    .QM         (       ),

    // Front steepness
    .SLP        (       ),

    // Control bit tact
    .T_cp       (       ),

    // Parity control trigger
    .FT_cp      (       ),

    // Seq. data
    .SDAT       (       ),

    // Enable data transmission
    .en_tx      (       ),

    // Enable word transmission
    .en_tx_word (       ),

    // Bit counter
    .cb_bit     (       )
);

// ARINC receiver
AR_RXD  RX
(
    // System
    .clk        (clk    ),
    .clr        (clr    ),

    // Channels for '0' and '1'
    .RXD0       (TXD0   ),
    .RXD1       (TXD1   ),

    // Bit counter
    .cb_bit     (       ),

    // Enable receiving
    .en_rx      (       ),

    // Parity control trigger
    .FT_cp      (       ),

    // Control bit interval
    .T_cp       (       ),

    // Internal reset
    .res        (       ),

    // Shift-registers for address and data
    .sr_adr     (       ),
    .sr_dat     (       ),

    // Buffers for received address and data
    .RX_adr     (RX_adr ),
    .RX_dat     (RX_dat ),

    // Successful transmission
    .ce_wr      (ce_wr  )
);

// Memory for received data
REG_BL  MEMORY
(
    .clk        (clk        ),
    .clr        (clr        ),
    .we         (ce_wr      ),
    .Adr_wr     (RX_adr[2:0]),
    .DI         (RX_dat[7:0]),
    .Adr_rd     (SW[2:0]    ), // selecting cell for display output
    .dat_REG    (dat_REG    )
);

// Display for showing data
DISPLAY DISP
(
    .clk        (clk         ),
    .dat        (dat_disp    ),
    .PTR        (2'b0        ),
    .ce1ms      (ce1ms       ),
    .AN         (AN          ),
    .SEG        ({seg_P, seg})
);

// 1s-signals generator
Gen_Nms_1s gen_nms_1s
(
    .clk        (clk         ),
    .ce         (ce1ms       ),
    .Tmod       (1'b0        ),
    .CEO        (ce1s_Nms    )
);

// Counter that generates data for transmission
reg [2:0]   Q_M;

always @(posedge clk) begin
    if(clr)
        Q_M <= 3'b0;
    else
        Q_M <= ce1ms ? Q_M + 1'b1 : Q_M;
end

// M2_1 - selecting internal (SW[3] = 0) or external (SW[3] = 1) connection between TX and RX
assign
    TXD0 = SW[3] ? JA7 : JB7,
    TXD1 = SW[3] ? JA1 : JB1;

// Selecting data for transmission (SW[4] = 0 -> static, SW[4] = 1 -> dynamic)
assign
    TX_adr = SW[4] ? { 5'b0, Q_M} : 8'b10000010,
    TX_dat = SW[4] ? {20'b0, Q_M} : 23'h5678   ;

// Selecting data for display output
assign
    dat_disp = SW[4] ? dat_REG :
               SW[1:0] == 2'b00 ? {8'b0, TX_adr} :
               SW[1:0] == 2'b01 ? TX_dat[15:0] :
               SW[1:0] == 2'b10 ? {8'b0, RX_adr} :
                                  RX_dat[15:0] ;


endmodule
