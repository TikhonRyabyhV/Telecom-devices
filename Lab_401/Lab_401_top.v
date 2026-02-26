module Lab_401_top
(
    input wire F50MHz,

    input wire BTN0,
    input wire BTN3,

    input wire [7:0] SW,

    output wire [3:0] AN,
    output wire [7:0] seg,
    output wire [7:0] LED
);

wire clock;
wire reset;

wire ce1ms   ;
wire ce1s_Nms;

wire [1:0] ce1s_Nms_ext;

wire [15:0] dat     ;
wire [15:0] dat_disp;
wire [15:0] bcd_dat ;
wire [ 3:0] CEO     ;

// 4-bit counters //
VCJmRE cnt_ones
(
    .ce (ce1s_Nms_ext[0]),
    .clk(clock          ),
    .R  (reset          ),
    .TC (               ),
    .CEO(CEO[0]         ),
    .Q  (dat[3:0]       )
);

VCB4RE cnt_tens
(
    .ce (CEO[0]  ),
    .clk(clock   ),
    .R  (reset   ),
    .Q  (dat[7:4]),
    .TC (        ),
    .CEO(CEO[1]  )
);

VCGrey4Re cnt_hunds
(
    .clk(clock    ),
    .ce (CEO[1]   ),
    .r  (reset    ),
    .Y  (dat[11:8]),
    .CEO(CEO[2]   ),
    .TC (         )
);

VCBDmSE cnt_thousands
(
    .ce (CEO[2]    ),
    .clk(clock     ),
    .s  (reset     ),
    .Q  (dat[15:12]),
    .TC (          ),
    .CEO(CEO[3]    )
);
// -------------- //

Gen_Nms_1s gen_nms_1s
(
    .clk (clock   ),
    .ce  (ce1ms   ),
    .Tmod(SW[7]   ),
    .CEO (ce1s_Nms)
);

DISPLAY DISP
(
    .clk  (clock   ),
    .dat  (dat_disp),
    .PTR  (SW[5:4] ),
    .ce1ms(ce1ms   ),
    .AN   (AN      ),
    .SEG  (seg     )
);

period_cnt period_cnt
(
    .clk    (clock          ),
    .rst    (reset          ),
    .ce1ms  (ce1ms          ),
    .CEO    (ce1s_Nms_ext[1]),
    .bcd_dat(bcd_dat        )
);

assign
    ce1s_Nms_ext = {2 {ce1s_Nms}};

assign
    clock = F50MHz,
    reset = BTN0  ;

assign
    dat_disp = SW[6] ? bcd_dat : dat;

endmodule
