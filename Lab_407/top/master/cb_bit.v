module cb_bit
(
    input   wire    clk,
    input   wire    clr, // clk reset
    input   wire    R  , // reset
    input   wire    ce , // count enable

    output  reg     [7:0]   cb_bit
);

always @(posedge clk) begin
    if(clr)
        cb_bit <= 8'h0;
    else
        cb_bit <= R  ?          8'b0 :
                  ce ? cb_bit + 1'b1 : cb_bit;
end

endmodule
