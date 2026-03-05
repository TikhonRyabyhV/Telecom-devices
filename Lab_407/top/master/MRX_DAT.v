`include "lab_407_def.vh"

module MRX_DAT
(
    input   wire    clk,
    input   wire    clr,

    input   wire    [`m - 1:0]  sr_MRX ,
    output  reg     [`m - 1:0]  MRX_DAT
);

always @(posedge clk) begin
    MRX_DAT <= clr ? {`m {1'b0}} : sr_MRX;
end

endmodule
