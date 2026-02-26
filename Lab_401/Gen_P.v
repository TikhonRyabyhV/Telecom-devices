module Gen_P
(
    input wire [1:0] ptr   ,
    input wire [1:0] adr_An,

    output wire seg_P
);

assign seg_P = ~(ptr == adr_An);

endmodule
