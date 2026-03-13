`include "lab_408_def.vh"

module SLAVE_I2C
(
    // System
    input   wire    clk,
    input   wire    clr,

    // I2C interface
    input   wire    SCL,
    inout   wire    SDA,

    output  wire    SDA_SLAVE,

    // I2C slave address
    input   wire    [6:0]   Adr_SLAVE,

    // Enable transmission
    output  reg     en_tx,

    // Enable receiving
    output  reg     en_rx,

    output  wire    ok_rx_byte,

    // Acknowledge tact
    output  wire    T_AC,

    // Read-write mode
    output  reg     R_W,

    // Bit/byte counters
    output  reg     [3:0]  cb_bit ,
    output  reg     [2:0]  cb_byte,

    // Count-enable signals
    output  wire    ce_start,
    output  wire    ce_stop ,

    output  reg     my_adr,
    output  reg     my_reg,

    // Received data from SLAVE
    output  reg     [7:0]   sr_rx,
    output  reg     [7:0]   sr_tx,

    output  reg     [7:0]   RX_dat
);

BUFT    T_buffer
(
    .O(SDA      ),
    .I(1'b0     ),
    .T(SDA_SLAVE)
);


reg      tSDA;
reg     ttSDA;
reg      tSCL;
reg     ttSCL;

wire    posedge_SDA;
wire    negedge_SDA;
wire    posedge_SCL;
wire    negedge_SCL;

reg     Q_start;

wire    ce_ADR_COM;
wire    ce_adr_REG;
wire    ce_dat_REG;

reg     tce_adr_REG;
reg     tce_dat_REG;

reg             we     ;
reg     [7:0]   Adr_wr ;
reg     [7:0]   DI     ;
reg     [7:0]   Adr_rd ;
wire    [7:0]   dat_REG;

REG_BL  SLAVE_MEMORY
(
    .clk        (clk    ),
    .clr        (clr    ),
    .we         (we     ),
    .Adr_wr     (Adr_wr ),
    .DI         (DI     ),
    .Adr_rd     (Adr_rd ),
    .dat_REG    (dat_REG)
);

// Forming SDA_SLAVE, posedge_SCL, negedge_SCL, ce_start, ce_stop
always @(posedge clk) begin
    if(clr) begin
        tSDA  <= 1'b0;
        tSCL  <= 1'b0;
        ttSDA <= 1'b0;
        ttSCL <= 1'b0;
    end

    else begin
        tSDA <= SDA;
        tSCL <= SCL;

        ttSDA <= tSDA;
        ttSCL <= tSCL;
    end
end

assign
    posedge_SDA =    tSDA  & (~ ttSDA),
    negedge_SDA = (~ tSDA) &    ttSDA ,
    posedge_SCL =    tSCL  & (~ ttSCL),
    negedge_SCL = (~ tSCL) &    ttSCL ;

assign
    ce_start = negedge_SDA & SCL,
    ce_stop  = posedge_SDA & SCL;

assign
    SDA_SLAVE = ~(T_AC & my_adr & (cb_byte == 1)) &
                ~(T_AC & my_adr &  my_reg       ) &
                ~(R_W  & my_reg & (cb_byte >= 2)  & (~sr_tx[7]));

// Change-enable signals
assign
    ok_rx_byte = (cb_bit == 7) & negedge_SCL;

assign
    ce_ADR_COM = ok_rx_byte & (cb_byte == 0),
    ce_adr_REG = ok_rx_byte & (cb_byte == 1),
    ce_dat_REG = ok_rx_byte & (cb_byte >= 2);

always @(posedge clk) begin
    tce_adr_REG <= clr ? 1'b0 : ce_adr_REG;
end

always @(posedge clk) begin
   tce_dat_REG <= clr ? 1'b0 : ce_dat_REG;
end

// Reading/writing
always @(posedge clk) begin
    if(clr)
        R_W <= 1'b1;
    else
        R_W <= (ce_ADR_COM & (sr_rx[7:1] == Adr_SLAVE)) ? sr_rx[0] : R_W;
end

// Checking slave and register addresses correctness
always @(posedge clk) begin
    if(clr)
        my_adr <= 1'b0;
    else
        my_adr <= ce_ADR_COM ? (sr_rx[7:1] == Adr_SLAVE ? 1'b1 : 1'b0) : my_adr;
end

always @(posedge clk) begin
    if(clr)
        my_reg <= 1'b0;
    else
        my_reg <= tce_adr_REG ?
                ((sr_rx >= `BASE_ADDR) & (sr_rx <  `BASE_ADDR + `N_REG) ? 1'b1 : 1'b0) : my_reg;
end

// Getting addresses for writing/reading from MASTER
always @(posedge clk) begin
    if(clr) begin
        Adr_wr <= 8'b0;
        Adr_rd <= 8'b0;
    end

    else begin
        Adr_wr <= ce_adr_REG & (~R_W) ? sr_rx : Adr_wr;
        Adr_rd <= ce_adr_REG & ( R_W) ? sr_rx : Adr_rd;
    end
end

// Getting data for writing from MASTER
always @(posedge clk) begin
    we <= tce_dat_REG & (~R_W);
end

always @(posedge clk) begin
    if(clr)
        DI <= 8'b0;
    else
        DI <= tce_dat_REG & (~R_W) ? sr_rx : DI;
end

// Enable receiving/transmission
always @(posedge clk) begin
    if(clr) begin
        en_tx <= 1'b0;
        en_rx <= 1'b0;
    end

    else begin
        en_tx <= (cb_byte >= 2) & (cb_bit == 0) & posedge_SCL & R_W ? 1'b1 :
                                                            ce_stop ? 1'b0 : en_tx;
        en_rx <= ce_start ? 1'b1 :
                 ce_stop  ? 1'b0 : en_rx;
    end
end

// Bit/byte counters
always @(posedge clk) begin
    if(clr)
        Q_start <= 1'b0;
    else
        Q_start <= ce_start    ? 1'b1 :
                   posedge_SCL ? 1'b0 : Q_start;
end

always @(posedge clk) begin
    if(clr) begin
        cb_bit  <= 4'b0;
        cb_byte <= 3'b0;
    end

    else begin
        cb_bit  <= negedge_SCL ? (Q_start | (cb_bit  ==       8)? 4'b0    : cb_bit  + 1) : cb_bit ;
        cb_byte <= negedge_SCL ? (Q_start | (cb_byte == `N_BYTE)? 3'b0    :
                                ~(cb_bit == 7)                  ? cb_byte : cb_byte + 1) : cb_byte;
    end
end

// Transmitting data to MASTER
always @(posedge clk) begin
    if(clr | ce_start)
        sr_tx <= 8'b0;
    else
        sr_tx <= (tce_adr_REG    & R_W ) ?  dat_REG :
                 ((cb_byte == 2) & R_W &
                  (~T_AC) & negedge_SCL) ? (sr_tx << 1) | 1'b1 : sr_tx;
end

assign
    T_AC = cb_bit == 8;

// Shift register for receiving data from MASTER
always @(posedge clk) begin
    if(clr | ce_start)
        sr_rx <= 8'b0;
    else
        sr_rx <= (posedge_SCL & (~T_AC)) ? (sr_rx << 1) | SDA : sr_rx;
end

// Buffer for received data from MASTER
always @(posedge clk) begin
    if(clr)
        RX_dat <= 8'b0;
    else
        RX_dat <= ok_rx_byte ? sr_rx : RX_dat;
end

endmodule
