module Gen_st
#(
    parameter Fclk = 50000000,
    parameter F_st = 10000
)
(
    input  wire clk,
    input  wire clr,

    output wire st
);

reg [15:0] cb_st;

assign
    st = (cb_st == 1);

always @(posedge clk) begin
    if(clr)
        cb_st <= (Fclk/F_st);
    else
        cb_st <= st ? (Fclk/F_st) : cb_st - 1;
end

endmodule
