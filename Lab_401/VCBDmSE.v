`define m 4

module VCBDmSE
(
    input  wire ce ,
    input  wire clk,
    input  wire s  ,

    output reg  [`m - 1:0] Q,

    output wire TC,
    output wire CEO
);

always @(posedge clk) begin
    if(s) begin
        Q <= (1 << `m) - 1;
    end

    else begin
        Q <= ce ? Q - 1 : Q;
    end
end

assign
    TC  = (Q == 4'b0000),
    CEO = ce & TC;

endmodule
