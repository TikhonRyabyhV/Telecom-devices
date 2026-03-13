`timescale 10ns/10ps

module I2C_tsb
();

reg clk;
reg clr;

wire    SDA;
wire    SCL;

reg [7:0] ADR_COM;
reg [7:0] adr_REG;
reg [7:0] dat_REG;

reg [11:0] st_cnt;
wire       st    ;

always begin
    clk = 1; #1;
    clk = 0; #1;
end

MASTER_I2C  master
(
    .clk    (clk),
    .clr    (clr),
    .st     (st ),

    // Input data for transmission
    .ADR_COM (ADR_COM),
    .adr_REG (adr_REG),
    .dat_REG (dat_REG),

    // I2C interface
    .SDA    (SDA),
    .SCL    (SCL),

    .SDA_MASTER (),

    // Start/stop transmission signals
    .T_start    (),
    .T_stop     (),

    // Enable transmission
    .en_tx  (),

    // Acknowledge tact
    .T_AC   (),

    // Error trigger (based on acknowledgement from SLAVE)
    .err_AC (),

    // Bit/byte counters
    .cb_bit     (),
    .cb_byte    (),

    // Count-enable signals
    .ce_tact    (),
    .ce_bit     (),
    .ce_byte    (),
    .ce_AC      (),

    // Received data from SLAVE
    .sr_rx_SDA  (),
    .RX_dat     ()
);

SLAVE_I2C   slave
(
    // System
    .clk    (clk),
    .clr    (clr),

    // I2C interface
    .SCL        (SCL),
    .SDA        (SDA),
    .SDA_SLAVE  (),

    // I2C slave address
    .Adr_SLAVE  (7'b0000001),

    // Enable transmission
    .en_tx      (),

    // Enable receiving
    .en_rx      (),
    .ok_rx_byte (),

    // Acknowledge tact
    .T_AC       (),

    // Read-write mode
    .R_W        (),

    // Bit/byte counters
    .cb_bit     (),
    .cb_byte    (),

    // Count-enable signals
    .ce_start   (),
    .ce_stop    (),
    .my_adr     (),
    .my_reg     (),

    // Received data from SLAVE
    .sr_rx      (),
    .sr_tx      (),
    .RX_dat     ()
);

always @(posedge clk) begin
    if(clr)
        st_cnt <= 2000;
    else
        st_cnt <= st_cnt == 1 ? 2000 : st_cnt - 1;
end

assign
    st = st_cnt == 1;

initial begin
    $dumpfile("dump.vcd"); $dumpvars();

    clr = 1; #5 clr = 0;
    ADR_COM = 8'd2; adr_REG = 8'd6; dat_REG = 8'd8;
    #7000;

    ADR_COM = 8'd3; adr_REG = 8'd6; dat_REG = 8'd0;
    #4000;

    ADR_COM = 8'd2; adr_REG = 8'd128; dat_REG = 8'd34;
    #4000;

    ADR_COM = 8'd3; adr_REG = 8'd128; dat_REG = 8'd0;
    #4000;

    $finish;
end

endmodule
