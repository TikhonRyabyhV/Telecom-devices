module REG_BL
(
    input    wire    clk,
    input    wire    clr,

    input    wire    we ,

    input    wire    [2:0]   Adr_wr,
    input    wire    [7:0]   DI    ,

    input    wire    [2:0]   Adr_rd ,
    output   wire    [7:0]   dat_REG
);

reg [7:0]   MEM [7:0];

genvar Gi;

generate
for(Gi = 0; Gi < 8; Gi = Gi + 1) begin
    always @(posedge clk) begin
        if(clr)
            MEM[Gi] <= 8'b0;
        else
            MEM[Gi] <= (Adr_wr == Gi[2:0]) & we ? DI : MEM[Gi];
    end
end
endgenerate

assign
    dat_REG = MEM[Adr_rd];

endmodule
