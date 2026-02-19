module VCGrey4Re
(
    input wire clk,
    input wire ce ,
    input wire r  ,

    output wire [3:0] Y,

    output wire CEO,
    output wire TC
);

reg [4:0] q;

assign
    TC = (q[4:0] == 5'b10001),
    CEO = ce & TC,
    Y = q[4:1];

always @(posedge clk) begin
    q[0] <= (r | CEO) ? 1'b0 :                               ce ? ~q[0] : q[0];
    q[1] <= (r | CEO) ? 1'b0 : ({3'b0, q[0]  } == 4'b0000) & ce ? ~q[1] : q[1];
    q[2] <= (r | CEO) ? 1'b0 : ({2'b0, q[1:0]} == 4'b0011) & ce ? ~q[2] : q[2];
    q[3] <= (r | CEO) ? 1'b0 : ({1'b0, q[2:0]} == 4'b0101) & ce ? ~q[3] : q[3];
    q[4] <= (r | CEO) ? 1'b0 : (       q[3:0]  == 4'b1001) & ce ? ~q[4] : q[4];
end

endmodule
