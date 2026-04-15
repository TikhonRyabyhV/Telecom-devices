`include "lab_408_def.vh"

module ADR_COM_DAT_BL
(
    input   wire    clk,
    input   wire    clr,

    input   wire    Inp1,
    input   wire    Inp2,

    output  wire    ok_rx_bl,

    output  reg     [7:0]   adr_COM,
    output  reg     [7:0]   adr_REG,
    output  reg     [7:0]   dat_REG
);

wire    Inp;

wire    ce_tact;
wire    ce_bit ;
wire    dRXD   ;

wire       ok_rx_byte;
wire    start_rx_byte;

wire    T_dat;
wire    T_adr_COM;
wire    T_adr_REG;
wire    T_dat_REG;

reg [11:0]  cb_tact;
reg [ 3:0]  cb_bit ;
reg [ 7:0]  cb_byte;
reg [ 7:0]  cb_res ;

reg [7:0]  rx_dat;
reg        en_rx_byte;
reg        en_rx_bl  ;

reg  RXD;
reg tRXD;

// Input signal
assign
    Inp = Inp1 & Inp2;

always @(posedge clk) begin
    if(clr) begin
         RXD <= 1'b0;
        tRXD <= 1'b0;
    end

    else begin
         RXD <= Inp;
        tRXD <= RXD;
    end
end

// RXD negedge
assign
    dRXD = (~RXD) & tRXD;

// Counters
assign
    ce_tact = (cb_tact ==  `UART_Nt     ),
    ce_bit  = (cb_tact == (`UART_Nt / 2));

always @(posedge clk) begin
    if(clr) begin
        cb_tact <= 12'b0;
        cb_bit  <=  4'b0;
        cb_byte <=  8'b0;
        cb_res  <=  8'b0;
    end

    else begin
        cb_tact <= (dRXD & (~en_rx_byte)) | ce_tact ? 1 : cb_tact + 1;
        cb_bit  <=  start_rx_byte | ((cb_bit == 9) & ce_tact) ? 0 :
                       en_rx_byte                  & ce_tact  ? cb_bit + 1 : cb_bit;
        cb_byte <=  ok_rx_bl   ? 0 :
                    ok_rx_byte ? cb_byte + 1 : cb_byte;
        cb_res  <=  en_rx_byte           ? 0 :
                    en_rx_bl   & ce_tact ? cb_res + 1 : cb_res;
    end
end

// Receiving data
assign
    start_rx_byte =                          (~en_rx_byte) & dRXD,
       ok_rx_byte = ce_bit  & (cb_bit ==  9) & en_rx_byte  & tRXD,
       ok_rx_bl   = ce_tact & (cb_res == 10)                     ;

assign
    T_dat = (cb_bit < 9) & (cb_bit > 0);

always @(posedge clk) begin
    if(clr) begin
        en_rx_byte <= 1'b0;
        en_rx_bl   <= 1'b0;
        rx_dat     <= 8'b0;
    end

    else begin
        en_rx_byte <= ce_bit & (~RXD)        ? 1 :
                      ce_bit & (cb_bit == 9) ? 0 : en_rx_byte;
        en_rx_bl   <= start_rx_byte ? 1 :
                         ok_rx_bl   ? 0 : en_rx_bl;
        rx_dat     <= ce_bit & T_dat ? (rx_dat >> 1) | (RXD << 7) : rx_dat;
    end
end

// Loading data
assign
    T_adr_COM = (cb_byte == 0),
    T_adr_REG = (cb_byte == 1),
    T_dat_REG = (cb_byte == 2);

always @(posedge clk) begin
    if(clr) begin
        adr_COM <= 8'b0;
        adr_REG <= 8'b0;
        dat_REG <= 8'b0;
    end

    else begin
        adr_COM <= T_adr_COM & ok_rx_byte ? rx_dat : adr_COM;
        adr_REG <= T_adr_REG & ok_rx_byte ? rx_dat : adr_REG;;
        dat_REG <= T_dat_REG & ok_rx_byte ? rx_dat : dat_REG;;
    end
end

endmodule
