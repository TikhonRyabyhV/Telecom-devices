module VCB4RE
(
    input  wire ce ,
    input  wire clk,
    input  wire R  ,

    output reg  [3:0] Q ,
    output wire       TC,
    output wire       CEO
);

always @(posedge clk) begin
    if(R) begin
        Q <= 4'b0000;
    end

    else begin
        Q <= ce ? Q + 1 : Q;
    end
end

assign
    TC  = (Q == 4'b1111),
    CEO = ce & TC;

endmodule
