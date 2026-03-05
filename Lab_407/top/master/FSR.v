module FSR
(
    input   wire    clk,
    input   wire    cls, // clk set

    input   wire    R, // reset
    input   wire    S, // set

    output  reg     Q
);

always @(posedge clk) begin
    if(cls)
        Q <= 1'b1;
    else
        Q <= S ? 1'b1 :
             R ? 1'b0 : Q;
end

endmodule
