`timescale 10ns/1ns

module testbench ();

reg     clock;
initial clock = 1'b1;

always
    #1 clock = ~ clock;

reg     reset;

wire    st;
wire    [4:0]   zero;

lab_407_top dut
(
    .F50MHz (clock),
    .BTN0   (reset),
    .SW     (zero ),
    .JC1    (),
    .JC2    (),
    .JC3    (),
    .JC4    (),
    .JB1    (),
    .JB2    (),
    .JB3    (),
    .JB4    (),
    .LED0   (),
    .AN     (),
    .seg    (),
    .seg_P  ()
);

assign
    zero = 5'b0;

initial begin
    $dumpfile("dump.vcd"); $dumpvars();

    reset = 1'b1; #2 reset = 1'b0;

    #100000;

    $finish;
end

endmodule
