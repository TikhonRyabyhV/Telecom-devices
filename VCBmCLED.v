`define m 4

module VCBmCLED
(
    input  wire ce ,
    input  wire up ,

    input  wire [`m - 1:0] di,

    input  wire L  ,
    input  wire clk,
    input  wire clr,

    output reg  [`m - 1:0] Q,

    output wire TC,
    output wire CEO
);

always @(posedge clk or posedge clr) begin
    if(clr) begin
        Q <= {`m {1'b0}};
    end

    else begin
        Q <=  L ? di :
             ( up & ce) ? Q + 1 :
             (!up & ce) ? Q - 1 : Q;
    end
end

assign
    TC  = up ? (Q == {`m {1'b1}}) : (Q == {`m {1'b0}}),
    CEO = ce & TC;

endmodule
