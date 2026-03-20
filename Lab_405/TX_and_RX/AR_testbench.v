`timescale 10ns/10ps

module AR_testbench
();

reg clk;
reg clr;

reg [11:0] st_cnt;
wire       st    ;

wire TXD0;
wire TXD1;

reg [ 1:0] Nvel;

reg [ 7:0] ADR;
reg [22:0] DAT;

AR_TXD  TX
(
    // System
    .clk        (clk),
    .clr        (clr),
    .st         (st ),

    // Speed mode
    .Nvel       (Nvel),
    .ce_tact    (),

    // Address and data for transmission
    .ADR        (ADR),
    .DAT        (DAT),

    // Channels for '0' and '1'
    .TXD0       (TXD0),
    .TXD1       (TXD1),

    // Modulator
    .QM         (),

    // Front steepness
    .SLP        (),

    // Control bit tact
    .T_cp       (),

    // Parity control trigger
    .FT_cp      (),

    // Seq. data
    .SDAT       (),

    // Enable data transmission
    .en_tx      (),

    // Enable word transmission
    .en_tx_word (),

    // Bit counter
    .cb_bit     ()
);

AR_RXD  RX
(
    // System
    .clk        (clk),
    .clr        (clr),

    // Channels for '0' and '1'
    .RXD0       (TXD0),
    .RXD1       (TXD1),

    // Bit counter
    .cb_bit     (),

    // Enable receiving
    .en_rx      (),

    // Parity control trigger
    .FT_cp      (),

    // Control bit interval
    .T_cp       (),

    // Internal reset
    .res        (),

    // Shift-registers for address and data
    .sr_adr     (),
    .sr_dat     (),

    // Successful transmission
    .ce_wr      ()
);

always begin
    clk = 1; #1;
    clk = 0; #1;
end

always @(posedge clk) begin
    if(clr)
        st_cnt <= 3000;
    else
        st_cnt <= st_cnt == 1 ? 3000 : st_cnt - 1;
end

assign
    st = st_cnt == 1;

initial begin
    $dumpfile("dump.vcd"); $dumpvars();

    clr = 1; #5 clr = 0;
    Nvel = 2'b11; ADR = 8'b10000001; DAT = 23'b011001001;
    #10000;
    Nvel = 2'b10; ADR = 8'b10000010; DAT = 23'b110010101;
    #100000;

    $finish;
end


endmodule
