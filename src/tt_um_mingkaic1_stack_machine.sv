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

    Top top (
        .clock(clk),
        .reset(~rst_n),
        .data_in(ui_in),
        .data_out(uo_out),
        .mem_addr(uio_out)
    );

    assign uio_oe = 8'b1111_1111;  // All outputs

endmodule: tt_um_mingkaic1_stack_machine
