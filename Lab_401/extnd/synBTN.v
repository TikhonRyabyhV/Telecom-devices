module synBTN
(
    input  wire clk  ,
    input  wire rst  ,
    input  wire ce1ms,

    input  wire BTN_IN,

    output wire BTN_OUT
);

reg  Q1;
reg  Q2;

always @(posedge clk) begin
    if(rst)
        Q1 <= 1'b0;
    else
        Q1 <= ce1ms ? BTN_IN : Q1;
end

always @(posedge clk) begin
    if(rst)
        Q2 <= 1'b0;
    else
        Q2 <= ce1ms ? Q1 : Q2;
end

assign BTN_OUT = (~Q2) & Q1 & ce1ms;

endmodule
