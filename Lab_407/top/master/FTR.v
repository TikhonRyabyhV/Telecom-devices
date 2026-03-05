module FTR
(
    input   wire    clk,
    input   wire    clr, // clk reset
    input   wire    R, // reset

    input   wire    T,
    output  reg     Q
);

always @(posedge clk) begin
    if(clr)
        Q <= 1'b0;
    else
        Q <= R ? 1'b0 :
             T ? ~Q   : Q;
end

endmodule
