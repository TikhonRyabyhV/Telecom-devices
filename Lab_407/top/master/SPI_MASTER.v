`include "lab_407_def.vh"

module SPI_MASTER
(
    // System
    input   wire    clk,
    input   wire    clr,
    input   wire    st ,

    // Data in
    input   wire           MISO,
    input   wire    [15:0] DI  ,

    // Data out
    output  wire           MOSI,
    output  wire    [15:0] DO  ,

    // Signals for forming SCLK
    output  wire    ce     ,
    output  wire    ce_tact,

    // SPI sync. signals
    output  wire    LOAD,
    output  wire    SCLK,

    // Bit counter
    output  wire    [7:0] cb_bit,

    // Trans. and rec. data for DISPLAY
    output  wire    [15:0]  sr_MTX,
    output  wire    [15:0]  sr_MRX
);

wire    [`m - 1:0]  sr_MRX_intr;

wire    start;

wire    ce_tact_intr;
wire       SCLK_intr;
wire       LOAD_intr;

assign
    ce_tact = ce_tact_intr,
    SCLK    =    SCLK_intr,
    LOAD    =    LOAD_intr;

syn_gen syn_gen
(
    .clk      (clk         ),
    .clr      (clr         ),
    .st       (st          ),
    .cb_bit   (cb_bit      ),
    .ce       (ce          ),
    .ce_tact  (ce_tact_intr),
    .SCLK     (SCLK_intr   ),
    .LOAD     (LOAD_intr   ),
    .start_out(start       )
);

sr_MTX  sr_MTX_module
(
    .clk      (clk         ),
    .clr      (clr         ),
    .ce       (ce_tact_intr),
    .start    (start       ),
    .L        (LOAD_intr   ),
    .DI       (DI[`m-1:0]  ),
    .MOSI     (MOSI        )
);

sr_MRX  sr_MRX_module
(
    .clk      (SCLK_intr   ),
    .clr      (clr         ),
    .SLI      (MISO        ),
    .sr_MRX   (sr_MRX_intr )
);

MRX_DAT MRX_DAT_module
(
    .clk      (LOAD_intr   ),
    .clr      (clr         ),
    .sr_MRX   (sr_MRX_intr ),
    .MRX_DAT  (DO[`m-1:0]  )
);

endmodule
