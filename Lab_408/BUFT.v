module BUFT
(
    output  wire    O,
    input   wire    I,
    input   wire    T
);

assign
    O = T ? 1'bz : I;

endmodule
