`default_nettype none

module RegFile (
    input logic clock,
    // Read
    input logic [3:0] re_sel_a, re_sel_b,
    output logic [7:0] re_data_a, re_data_b,
    // Write
    input logic [3:0] wr_sel,
    input logic [7:0] wr_data,
    input logic wr_en
);

    logic [7:0] regs [15:0];

    assign re_data_a = regs[re_sel_a];
    assign re_data_b = regs[re_sel_b];

    always_ff @ (posedge clock) begin
        if (wr_en) regs[wr_sel] <= wr_data;
    end

endmodule: RegFile
