`timescale 10ns/1ns

module top_testbench ();

reg     clock;
initial clock = 1'b1;

always
    #1 clock = ~ clock;

reg       reset ;
reg [7:0] switch;

wire [3:0] num;
wire [7:0] seg;
wire [3:0] dig;

Lab_401_top dut
(
    .F50MHz(clock ),
    .BTN0  (reset ),
    .BTN3  (      ),
    .SW    (switch),
    .AN    (num   ),
    .seg   (seg   ),
    .LED   (      )
);

assign dig = (seg == 7'b1000000)?  0 : //0
             (seg == 7'b1111001)?  1 : //1
             (seg == 7'b0100100)?  2 : //2
             (seg == 7'b0110000)?  3 : //3
             (seg == 7'b0011001)?  4 : //4
             (seg == 7'b0010010)?  5 : //5
             (seg == 7'b0000010)?  6 : //6
             (seg == 7'b1111000)?  7 : //7
             (seg == 7'b0000000)?  8 : //8
             (seg == 7'b0010000)?  9 : //9
             (seg == 7'b0001000)? 10 : //A
             (seg == 7'b0000011)? 11 : //b
             (seg == 7'b1000110)? 12 : //C
             (seg == 7'b0100001)? 13 : //d
             (seg == 7'b0000110)? 14 : //E
             (seg == 7'b0001110)? 15 : //F
                                  'hx;

initial begin
    $dumpfile("dump.vcd"); $dumpvars();

    reset = 1'b1; switch = 8'b0;
    #1  switch[7] = 1'b1;
    #10 reset     = 1'b0;

    #20000000;

    $finish;
end

endmodule
