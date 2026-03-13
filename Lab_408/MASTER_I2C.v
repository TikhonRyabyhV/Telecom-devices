`include "lab_408_def.vh"

module MASTER_I2C
#(
    parameter   Fclk = 50000000, // 50   MHz
    parameter   Fvel =  1250000, // 1.25 bit/sec

    parameter   N4vel  = Fclk / (4 * Fvel), // 10
    parameter   N_byte = 3
)
(
    // System
    input   wire    clk,
    input   wire    clr,
    input   wire    st ,

    // Input data for transmission
    input   wire    [7:0]   ADR_COM,
    input   wire    [7:0]   adr_REG,
    input   wire    [7:0]   dat_REG,

    // I2C interface
    inout   wire    SDA,
    output  reg     SCL,

    output  reg     SDA_MASTER,

    // Start/stop transmission signals
    output  reg     T_start,
    output  reg     T_stop ,

    // Enable transmission
    output  reg     en_tx,

    // Acknowledge tact
    output  wire    T_AC,

    // Error trigger (based on acknowledgement from SLAVE)
    output  reg     err_AC,

    // Bit/byte counters
    output  reg     [3:0]  cb_bit ,
    output  reg     [2:0]  cb_byte,

    // Count-enable signals
    output  wire    ce_tact,
    output  wire    ce_bit ,
    output  wire    ce_byte,
    output  wire    ce_AC  ,

    // Received data from SLAVE
    output  reg     [7:0]   sr_rx_SDA,
    output  reg     [7:0]   RX_dat
);

`ifndef SIMUL_MODE
    PULLUP DA1  (SDA);
`else  // SIMUL_MODE
    pullup DA1 (SDA);
`endif // SIMUL_MODE

BUFT    T_buffer
(
    .O(SDA       ),
    .I(1'b0      ),
    .T(SDA_MASTER)
);

reg [10:0]  cb_ce;
reg         rep_st;

reg [ 7:0]  TX_dat   ;
reg [ 7:0]  sr_tx_SDA;

// Repeat st
always @(posedge clk) begin
    if(clr)
        rep_st <= 1'b0;
    else
        rep_st <= (st | (ce_byte & en_tx));
end

// I2C control and data signals
always @(posedge clk) begin
    if(clr) begin
        SCL        <= 1'b1;
        SDA_MASTER <= 1'b1;
    end

    else begin
        SCL        <= (cb_ce > 2 * N4vel) | (~ en_tx);
        SDA_MASTER <= (T_start | T_stop) ?  1'b0                 :
                       en_tx             ? (sr_tx_SDA[7] | T_AC) : 1'b1;
    end
end

// Start/stop/enable transmission
always @(posedge clk) begin
    if(clr) begin
        T_start <= 1'b0;
        T_stop  <= 1'b0;

        en_tx <= 1'b0;
    end

    else begin
        T_start <= st      ? 1'b1 :
                   ce_tact ? 1'b0 : T_start;
        T_stop  <= ce_byte & ((cb_byte == N_byte - 1) | err_AC) ? 1'b1 :
                   ce_bit                                       ? 1'b0 : T_stop;

        en_tx <=  st               ? 1'b1 :
                 (ce_bit & T_stop) ? 1'b0 : en_tx;
    end
end

// Error trigger (based on ACK from SLAVE)
always @(posedge clk) begin
    if(clr)
        err_AC <= 1'b0;
    else
        err_AC <=  st           ? 1'b0 :
                  (ce_AC & SDA) ? 1'b1 : err_AC;
end

// Counters
always @(posedge clk) begin
    if(clr) begin
        cb_ce  <= 4 * N4vel;

        cb_bit  <= 4'b0;
        cb_byte <= 3'b0;
    end

    else begin
        cb_ce <=  st          ? 3 * N4vel :
                 (cb_ce == 1) ? 4 * N4vel : cb_ce - 1;

        cb_bit  <= (st | ce_byte                 ) ? 4'b0       :
                   (ce_tact & en_tx & (~ T_start)) ? cb_bit + 1 : cb_bit;

        cb_byte <= (st | (cb_byte == `N_BYTE)) ? 3'b0        :
                   (ce_byte & en_tx)           ? cb_byte + 1 : cb_byte;
    end
end

// Updating data for transmission
always @(posedge clk) begin
    if(clr)
        TX_dat <= 8'b0;
    else
        TX_dat <= st ? ADR_COM :
                 (ce_bit & en_tx & (cb_bit == 8)) ? (cb_byte == 0           ? adr_REG :
                                                    (cb_byte == 1) & (~R_W) ? dat_REG : 8'b11111111) : TX_dat;
end

// Shift register for transmission from MASTER
always @(posedge clk) begin
    if(clr)
        sr_tx_SDA <= 8'b0;
    else
        sr_tx_SDA <=  rep_st           ?  TX_dat                 :
                     (ce_tact & T_dat) ? (sr_tx_SDA << 1) | 1'b1 : sr_tx_SDA;
end

// Shift register for receiving data from SLAVE
always @(posedge clk) begin
    if(clr)
        sr_rx_SDA <= 8'b0;
    else
        sr_rx_SDA <= ((cb_byte == N_byte - 1) &
                       ce_bit & T_dat       ) ?  (sr_rx_SDA << 1) | SDA : sr_rx_SDA;
end

// Buffer for received data from SLAVE
always @(posedge clk) begin
    if(clr)
        RX_dat <= 8'b0;
    else
        RX_dat <= ((cb_byte === N_byte - 1) & ce_byte & R_W) ? sr_rx_SDA : RX_dat;
end

// Control tact
assign
    T_AC = (cb_bit == 8);

// Signal shows that transmission with data
assign
    T_dat = en_tx & (~(T_start | T_stop | T_AC));

// Read (1) - write (0) signal
assign
    R_W = ADR_COM[0];

// Count enable signals
assign
    ce_tact = (cb_ce == 1 * N4vel),
    ce_bit  = (cb_ce == 3 * N4vel) & en_tx,
    ce_byte =  ce_tact & T_AC,
    ce_AC   =  ce_bit  & T_AC;

endmodule
