module DISPLAY
(
input wire clk,

input wire [15:0] dat,
input wire [ 1:0] PTR,

 output wire ce1ms,

output wire [3:0] AN,
output wire [7:0] SEG
);

wire [3:0] Dig;
wire [1:0] Adr_dig;

//Anode gen
Gen4an DD1
(
    .clk(clk    ),
    .ce (ce1ms  ),
    .q  (Adr_dig),
    .an (AN     )
);

// Number mux
MUX16_4 DD2
(
    .dat(dat    ),
    .adr(Adr_dig),
    .do (Dig    )
);

// 7seg decoder
D7seg DD3
(
    .dig(Dig     ),
    .seg(SEG[6:0])
);

// Point gen
Gen_P DD4
(
    .ptr   (PTR    ),
    .adr_An(Adr_dig),
    .seg_P (SEG[7] )
);

// ce1ms gen
Gen1ms DD5
(
    .clk  (clk  ),
    .ce1ms(ce1ms)
);

endmodule
