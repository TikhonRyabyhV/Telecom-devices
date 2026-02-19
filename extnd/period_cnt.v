module period_cnt
(
    input wire clk  ,
    input wire rst  ,
    input wire ce1ms,

    input wire CEO,

    output wire [15:0] bcd_dat
);

reg [9:0]    cb10R1;
reg [9:0] bf_cb10R1;

always @(posedge clk) begin
    if(rst) begin
           cb10R1 <= 10'b1;
        bf_cb10R1 <= 10'b0;
    end

    else begin
           cb10R1 <= ce1ms ? (~CEO ? cb10R1 + 1 : 10'b1    ) :    cb10R1;
        bf_cb10R1 <= ce1ms ? ( CEO ? cb10R1     : bf_cb10R1) : bf_cb10R1;
    end

end

double_dabble bin_to_bcd
#(
    .BIN_LEN(10   ),
    .BCD_LEN(4 * 4)
)
(
    .bin(bf_cb10R1),
    .bcd(bcd_dat  )
);

endmodule
