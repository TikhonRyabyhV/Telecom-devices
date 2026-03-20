`timescale 10ns/10ps

module l405_tsb
();

integer i;

reg clk;
reg clr;

reg [6:0] SW;

lab_405_top dut
(
    .F50MHz (clk),
    .BTN0   (clr),
    .SW     (SW ),
    .JA7    (   ),
    .JA1    (   ),
    .AN     (   ),
    .seg    (   ),
    .seg_P  (   ),
    .JB7    (   ),
    .JB1    (   )
);

always begin
    clk = 1; #1;
    clk = 0; #1;
end

initial begin
    $dumpfile("dump.vcd"); $dumpvars();

    for (i = 0; i < 8; i = i + 1) begin
        $dumpvars(0, dut.MEMORY.MEM[i]);
    end

    clr = 1; #5 clr = 0;
    SW[3:0] = 4'b00;
    SW[  4] = 1'b1 ;
    SW[6:5] = 2'b00;
    #1000000;

    $finish;
end

endmodule
