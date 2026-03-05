`include "lab_407_def.vh"

module sr_MTX
(
    input   wire    clk  ,
    input   wire    clr  ,
    input   wire    ce   , // count enable
    input   wire    start,
    input   wire    L    , // LOAD

    input   wire    [`m - 1:0]  DI  ,
    output  wire                MOSI
);

reg [`m - 1:0] sr_MTX;

always @(posedge clk) begin
    if(clr)
        sr_MTX <= {`m {1'b0}};
    else
        sr_MTX <= ~L     ? (ce ? sr_MTX << 1 : sr_MTX) :
                   start ?       DI                    : sr_MTX;
end

assign
    MOSI = sr_MTX[`m - 1];

endmodule
