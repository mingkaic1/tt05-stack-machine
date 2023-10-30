`default_nettype none

module tt_um_mingkaic1_stack_machine (
    input  logic [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output logic [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  logic [7:0] uio_in,   // IOs: Bidirectional Input path
    output logic [7:0] uio_out,  // IOs: Bidirectional Output path
    output logic [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  logic       ena,      // will go high when the design is enabled
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);

    RegFile reg_file (
        .clock(clk),
        .re_sel_a(uio_in[2:0]), 
        .re_sel_b(3'd7),
        .re_data_a(ui_in), 
        .re_data_b(),
        .wr_sel_a(uio_in[5:3]), 
        .wr_sel_b(3'd6),
        .wr_data_a(uo_out),
        .wr_data_b(),
        .wr_en_a(uio_in[6]), 
        .wr_en_b(uio_in[7])
    );

    // Configure bidirectional pins
    assign uio_oe = 8'b0000_0000;  // All inputs

endmodule: tt_um_mingkaic1_stack_machine
