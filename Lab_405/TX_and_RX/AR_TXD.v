module AR_TXD
(
    // System
    input   wire    clk,
    input   wire    clr,
    input   wire    st ,

    // Speed mode
    input   wire    [1:0]   Nvel   ,
    output  wire            ce_tact,

    // Address and data for transmission
    input   wire    [ 7:0]   ADR,
    input   wire    [22:0]   DAT,

    // Channels for '0' and '1'
    output  wire    TXD0,
    output  wire    TXD1,

    // Modulator
    output  reg     QM,

    // Front steepness
    output  wire    SLP,

    // Control bit tact
    output  wire    T_cp,

    // Parity control trigger
    output  reg     FT_cp,

    // Seq. data
    output  wire    SDAT,

    // Enable data transmission
    output  reg     en_tx,

    // Enable word transmission
    output  reg     en_tx_word,

    // Bit counter
    output  reg     [5:0]   cb_bit
);

// Parameters (clock freq. and speed of transmission)
parameter Fclk=50000000 ; //50 MHz

parameter V1Mb    = 1000000 ; // 1000 kb/s
parameter V100kb  = 100000  ; //  100 kb/s
parameter V50kb   = 50000   ; //   50 kb/s
parameter V12_5kb = 12500   ; // 12.5 kb/s

wire    [10:0]  AR_Nt;
reg     [10:0]  cb_ce; // half-tact counter
wire            ce   ;

wire    T_adr_dat  ;
wire    start      ;
wire    ce_end_word;

reg     [ 7:0]  sr_adr;
reg     [22:0]  sr_dat;

// Forming tact-signal
assign
    AR_Nt = Nvel[1:0] == 2'b11 ? (Fclk / (2 * V1Mb    )) :
            Nvel[1:0] == 2'b10 ? (Fclk / (2 * V100kb  )) :
            Nvel[1:0] == 2'b01 ? (Fclk / (2 * V50kb   )) :
                                 (Fclk / (2 * V12_5kb )) ;

assign
    ce      = (cb_ce == AR_Nt),
    ce_tact =     ce & QM     ;

always @(posedge clk) begin
    if(clr)
        cb_ce <= 11'b0;
    else
        cb_ce <= (start | ce) ? 1 : cb_ce + 1;
end

// Bit counter
always @(posedge clk) begin
    if(clr)
        cb_bit <= 6'b0;
    else
        cb_bit <= start                ? 6'b0       :
                  en_tx_word & ce_tact ? cb_bit + 1 : cb_bit;
end

// Forming control signals
assign
    start       = st      & (~en_tx_word ),
    ce_end_word = ce_tact & (cb_bit == 35);

assign
    T_adr_dat = en_tx & (~T_cp),
    T_cp      =  (cb_bit == 31);

always @(posedge clk) begin
    if(clr) begin
        en_tx      <= 1'b0;
        en_tx_word <= 1'b0;
    end

    else begin
        en_tx      <= start          ? 1'b1 :
                      T_cp & ce_tact ? 1'b0 : en_tx;
        en_tx_word <= start          ? 1'b1 :
                      ce_end_word    ? 1'b0 : en_tx_word;
    end
end

// Counting parity
always @(posedge clk) begin
    if(clr)
        FT_cp <= 1'b0;
    else
        FT_cp <= cb_bit > 31                     ?   1'b0 :
                 start                           ?   1'b1 :
                 sr_adr[7] & ce_tact & T_adr_dat ? ~FT_cp : FT_cp;
end

assign
    SLP = (Nvel == 2'b00);

// Modulator
always @(posedge clk) begin
    if(clr)
        QM <= 1'b0;
    else
        QM <= start           ? 1'b0 :
              en_tx_word & ce ? ~QM  : QM;
end

// Transmitting address and data
assign
    SDAT = sr_adr[7] | (T_cp & FT_cp),
    TXD0 = en_tx & QM & (~SDAT)      ,
    TXD1 = en_tx & QM & ( SDAT)      ;

always @(posedge clk) begin
    if(clr) begin
        sr_adr <=  8'b0;
        sr_dat <= 23'b0;
    end

    else begin
        sr_adr <= start           ?                               ADR :
                  ce_tact & en_tx ? (sr_adr << 1) | {7'b0, sr_dat[0]} : sr_adr;
        sr_dat <= start ?                                         DAT :
                  ce_tact & en_tx ? (sr_dat >> 1)                     : sr_dat;
    end
end

endmodule
