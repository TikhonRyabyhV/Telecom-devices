module lab_407_top
(
    input   wire    F50MHz,
    input   wire    BTN0  ,

    input   wire    [4:0]   SW,

    input   wire    JC1,

    output  wire    JC2,
    output  wire    JC3,
    output  wire    JC4,

    output  wire    JB1,
    output  wire    JB2,
    output  wire    JB3,
    output  wire    JB4,

    output  wire    LED0,

    output  wire    [3:0]   AN   ,
    output  wire    [6:0]   seg  ,
    output  wire            seg_P
);

wire    load;
wire    clk ;
wire    clr ;
wire    st  ;

wire    [15:0]  STX_DAT;
wire    [15:0]  MTX_DAT;

wire    [15:0]  SRX_DAT;
wire    [15:0]  MRX_DAT;

wire    [15:0]  DISPL_dat;

// System
assign
    clk = F50MHz,
    clr = BTN0;

Gen_st  st_generator
(
    .clk(clk),
    .clr(clr),
    .st (st )
);

SPI_MASTER  MASTER
(

    .clk         (clk),
    .clr         (clr),
    .st          (st ),
    .MISO        (JB4),
    .DI          (MTX_DAT),
    .MOSI        (JB3),
    .DO          (MRX_DAT),
    .ce          (   ),
    .ce_tact     (JC3),
    .LOAD        (JB1),
    .SCLK        (JB2),
    .cb_bit      (   ),
    .sr_MTX      (   ),
    .sr_MRX      (   )
);

SPI_SLAVE   SLAVE
(
   .clr          (clr ),
   .st           (st  ),
   .SCLK         (JB2 ),
   .LOAD         (load),
   .MOSI         (JB3 ),
   .DI           (STX_DAT),
   .MISO         (JB4 ),
   .DO           (SRX_DAT),
   .sr_STX       (    ),
   .sr_SRX       (    )
);

DISPLAY DISPLAY
(
    .clk        (clk         ),
    .dat        (DISPL_dat   ),
    .PTR        (SW[4:3]     ),
    .ce1ms      (JC4         ),
    .AN         (AN          ),
    .SEG        ({seg_P, seg})
);

// SOURCE DATA
assign
    MTX_DAT = 15'b011_0010_0100,
    STX_DAT = 15'b101_1000_1101;

// MUX64_16
assign DISPL_dat = SW[1:0] == 2'b00 ? MTX_DAT :
                   SW[1:0] == 2'b01 ? MRX_DAT :
                   SW[1:0] == 2'b10 ? STX_DAT :
                                      SRX_DAT ;

// M2_1
assign
    load = SW[2] ? JC1 : JB1;

assign
    LED0 = ~ load;

endmodule
