`default_nettype none

module RegFile (
    input logic clock,
    // Read
    input logic [2:0] re_sel_a, re_sel_b,
    output logic [7:0] re_data_a, re_data_b,
    // Write
    input logic [2:0] wr_sel_a, wr_sel_b,
    input logic [7:0] wr_data_a, wr_data_b,
    input logic wr_en_a, wr_en_b
);

    logic [7:0] regs [7:0];

    assign re_data_a = regs[re_sel_a];
    assign re_data_b = regs[re_sel_b];

    always_ff @ (posedge clock) begin
        if (wr_en_a) regs[wr_sel_a] <= wr_data_a;
        if (wr_en_b) regs[wr_sel_b] <= wr_data_b;
    end

endmodule: RegFile