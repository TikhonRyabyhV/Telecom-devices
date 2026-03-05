`include "lab_407_def.vh"

module cb_tact
(
    input   wire    clk,
    input   wire    clr, // clk reset
    input   wire    R  , // reset

    output  reg   [7:0]    cb_tact
);

always @(posedge clk) begin
    if(clr)
        cb_tact <= 8'h0;
    else
        cb_tact <= R | (cb_tact == (`Nt - 1)) ? 8'b0 : cb_tact + 1'b1;
end

endmodule
