`include "lab_407_def.vh"

module SPI_SLAVE
(
    // System
    input   wire    clr,
    input   wire    st ,

    // SPI sync. signals
    input   wire    SCLK,
    input   wire    LOAD,

    // Data in
    input   wire            MOSI,
    input   wire    [15:0]  DI  ,

    // Data out
    output  wire            MISO,
    output  wire    [15:0]  DO  ,

    // Trans. and rec. data for DISPLAY
    output  reg     [15:0]  sr_STX,
    output  reg     [15:0]  sr_SRX
);

reg [`m - 1:0] SRX_DAT;

// Slave receives data from master
always @(posedge SCLK) begin
    if(clr)
        sr_SRX <= {`m {1'b0}};
    else
        sr_SRX <= {sr_SRX[`m - 2:0], MOSI};
end

always @(posedge LOAD) begin
    SRX_DAT <= clr ? {`m {1'b0}} : sr_SRX;
end

assign
    DO[`m-1:0] = SRX_DAT;

// Slave transmits data to master
assign
    start = st & LOAD;

always @(posedge start or negedge SCLK) begin
    sr_STX <= LOAD ? DI[`m-1:0] : sr_STX << 1;
end

assign
    MISO = sr_STX[`m - 1];

endmodule
