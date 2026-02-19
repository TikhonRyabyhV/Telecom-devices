`define m 4

module VCJmRE
(
    input  wire ce ,
    input  wire clk,
    input  wire R  ,

    output wire TC,
    output wire CEO,

    output reg  [`m - 1:0] Q
);

always @(posedge clk) begin
    if(R) begin
        Q <= {`m {1'b0}};
    end

    else begin
        Q <=  ce ? Q << 1 | {{`m {1'b0}}, {~Q[`m - 1]}} : Q;
    end
end

assign
    TC  = (Q == {`m {1'b1}}),
    CEO = ce & TC;

endmodule
