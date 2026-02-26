`timescale 10ns/1ns

module testbench ();

reg     clock;
initial clock = 1'b1;

always
    #1 clock = ~ clock;

reg  reset;

wire [3:0] TC ;
wire [3:0] CEO;

wire [3:0] Q_out [3:0];

reg ce;

VCB4RE dut1
(
    .ce (ce   ),
    .clk(clock),
    .R  (reset),
    .Q  (Q_out[0]),
    .TC (TC[0]),
    .CEO(CEO[0])
);

VCBDmSE dut2
(
    .ce (ce   ),
    .clk(clock),
    .s  (reset),
    .Q  (Q_out[1]),
    .TC (TC[1]),
    .CEO(CEO[1])
);

VCGrey4Re dut3
(
    .clk(clock),
    .ce (ce   ),
    .r  (reset),
    .Y  (Q_out[2]),
    .CEO(CEO[2]),
    .TC (TC[2])
);

VCJmRE dut4
(
    .ce (ce   ),
    .clk(clock),
    .R  (reset),
    .TC (TC[3]),
    .CEO(CEO[3]),
    .Q  (Q_out[3])
);

initial begin
    $dumpfile("dump.vcd"); $dumpvars();

    ce = 0;

    reset = 1'b1;
    #10 reset = 1'b0;

    ce = 1'b1;
    #100;

    $finish;
end

endmodule
