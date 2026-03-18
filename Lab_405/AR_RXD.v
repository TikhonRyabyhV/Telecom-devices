module AR_RXD
(
    // System
    input   wire    clk,
    input   wire    clr,

    // Channels for '0' and '1'
    input   wire    RXD0,
    input   wire    RXD1,

    // Bit counter
    output  reg [ 4:0]   cb_bit,

    // Enable receiving
    output  wire    en_rx,

    // Parity control trigger
    output  reg     FT_cp,

    // Control bit interval
    output  wire    T_cp,

    // Pause register
    output  reg     res,

    // Shift-registers for address and data
    output  reg [ 7:0]  sr_adr,
    output  reg [22:0]  sr_dat,

    // Successful transmission
    output  wire    ce_wr
);

wire  RXCLK;
reg  tRXCLK;

reg tRXD1;

reg [11:0]  cb_T_bit;
reg [11:0]     T_bit;

wire    ok_rx;

reg [ 7:0]  RX_adr;
reg [22:0]  RX_dat;

// Forming RXCLK
assign
    RXCLK = RXD0 | RXD1;

// Counting T_bit
always @(posedge clk) begin
    if(clr)
        tRXCLK <=  1'b0;
    else
        tRXCLK <= RXCLK;
end

always @(posedge clk) begin
    if(clr) begin
        cb_T_bit <= 12'b1;
           T_bit <= 12'b0;
    end
    else begin
        cb_T_bit <= tRXCLK & (~RXCLK) | (cb_T_bit == T_bit)       ? 12'b1    : cb_T_bit + 1;
           T_bit <= (cb_bit ==  3)    & (cb_T_bit == T_bit) & res ? 12'b0    :
                    tRXCLK & (~RXCLK)                             ? cb_T_bit :    T_bit    ;
    end
end

// Bit counter
always @(posedge clk) begin
    if(clr)
        cb_bit <= 4'b0;
    else
        cb_bit <= res & (cb_bit == 3) & (cb_T_bit == T_bit) ? 4'b0       :
                  ((~RXCLK) & tRXCLK) | (cb_T_bit == T_bit) ? cb_bit + 1 : cb_bit;
end

// Checking correctness of transmission
assign
    T_cp = cb_bit == 31;

always @(posedge clk) begin
    if(clr)
        tRXD1 <= 1'b0;
    else
        tRXD1 <= RXD1;
end

always @(posedge clk) begin
    if(clr | res)
        FT_cp <= 1'b0;
    else
        FT_cp <= (~tRXD1) & RXD1 ? ~FT_cp : FT_cp;
end

assign
    ok_rx = T_cp & RXCLK & (FT_cp == ((~RXD0) | RXD1));

// Forming pause signal
always @(posedge clk) begin
    if(clr)
        res <= 1'b0;
    else
        res <= (cb_bit == 31) & (cb_T_bit == T_bit)       ? 1'b1 :
               (cb_bit ==  3) & (cb_T_bit == T_bit) & res ? 1'b0 : res;
end

// Enable receiving
assign
    en_rx = (~res) & (~T_cp);

// Receiving address and data
always @(posedge clk) begin
    if(clr | res) begin
        sr_adr <=  8'b0;
        sr_dat <= 23'b0;
    end

    else begin
        sr_adr <= RXCLK & (~tRXCLK) & (cb_bit <  8) & en_rx ? (sr_adr << 1) | { 7'b0, {(~RXD0) | (RXD1)}} : sr_adr;
        sr_dat <= RXCLK & (~tRXCLK) & (cb_bit >= 8) & en_rx ? (sr_dat >> 1) | {{(~RXD0) | (RXD1)}, 22'b0} : sr_dat;
    end
end

// Storing received data
always @(posedge clk) begin
    if(clr) begin
        RX_adr <=  8'b0;
        RX_dat <= 23'b0;
    end

    else begin
        RX_adr <= ok_rx ? sr_adr : RX_adr;
        RX_dat <= ok_rx ? sr_dat : RX_dat;
    end
end

endmodule
