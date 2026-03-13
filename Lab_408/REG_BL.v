module REG_BL
(
    input    wire    clk,
    input    wire    clr,

    input    wire    we ,

    input    wire    [7:0]   Adr_wr,
    input    wire    [7:0]   DI    ,

    input    wire    [7:0]   Adr_rd ,
    output   wire    [7:0]   dat_REG
);

reg [7:0]   MEM [255:0];

// genvar Gi;
//
// generate
// for(Gi = 0; Gi < 256; Gi = Gi + 1) begin
//     always @(posedge clk) begin
//         if(clr)
//             MEM[Gi] <= 8'b0;
//         else
//             MEM[Gi] <= (Adr_wr == Gi[7:0]) & we ? DI : MEM[Gi];
//     end
// end
// endgenerate

always @(posedge clk) begin
    MEM[Adr_wr] <= we ? DI : MEM[Adr_wr];
end

assign
    dat_REG = MEM[Adr_rd];

endmodule
