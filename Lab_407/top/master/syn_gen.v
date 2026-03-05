`include "lab_407_def.vh"

module syn_gen
(
    input   wire    clk,
    input   wire    clr,
    input   wire    st ,

    output  wire    [7:0]   cb_bit,

    output  wire    ce     ,
    output  wire    ce_tact,

    output  wire    SCLK   ,
    output  wire    LOAD   ,
    output  wire    start_out
);

wire    cb_tact_rst;
wire    FSR_set;
wire    START;

wire    [7:0]   cb_tact;

cb_tact     cb_tact_module
(
    .clk    (clk        ),
    .clr    (clr        ),
    .R      (cb_tact_rst),
    .cb_tact(cb_tact    )
);

cb_bit      cb_bit_module
(
    .clk    (clk        ),
    .clr    (clr        ),
    .R      (START      ),
    .ce     (ce_tact    ),
    .cb_bit (cb_bit     )
);

FSR         FSR
(
    .clk    (clk        ),
    .cls    (clr        ),
    .R      (st         ),
    .S      (FSR_set    ),
    .Q      (LOAD       )
);

FTR         FTR
(
    .clk    (clk        ),
    .clr    (clr        ),
    .R      (LOAD       ),
    .T      (ce         ),
    .Q      (SCLK       )
);

assign
    ce = cb_tact == (`Nt - 1);

assign
    START       = st    & LOAD,
    ce_tact     = SCLK  & ce  ,
    cb_tact_rst = START & ce  ;

assign
    FSR_set     = ce_tact & (cb_bit == (`m - 1));

assign
    start_out = START;

endmodule
