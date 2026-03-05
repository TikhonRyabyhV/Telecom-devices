`include "lab_407_def.vh"

module sr_MRX
(
    input   wire    clk,
    input   wire    clr,

    input   wire    SLI,

    output  reg     [`m - 1:0]  sr_MRX
);

always @(posedge clk) begin
    if(clr)
        sr_MRX <= {`m {1'b0}};
    else
        sr_MRX <= {sr_MRX[`m - 2:0], SLI};
end

endmodule
