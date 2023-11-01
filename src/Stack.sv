`default_nettype none

module Stack (
    input logic clock, reset,
    input logic [7:0] wr_data,
    output logic [7:0] re_data_a, re_data_b,  // b = top of stack
    input logic wr_en, re_en_a, re_en_b
);

    logic [3:0] count, count_next;  // Num of values on stack
    logic [2:0] wr_sel;

    always_ff @ (posedge clock) begin
        if (reset) count <= 4'd0;
        else count <= count_next;
    end

    always_comb begin
        wr_sel = 3'd0;
        count_next = count;
        if (re_en_a && re_en_b) begin
            wr_sel = count[2:0] - 3'd2;
            count_next = count_next - 3'd2;
        end
        else if (re_en_a || re_en_b) begin
            wr_sel = count[2:0] - 3'd1;
            count_next = count_next - 3'd1;
        end
        else begin
            wr_sel = count[2:0];
        end

        if (wr_en) count_next = count_next + 3'd1;
    end

    RegFile reg_file (
        .clock(clock),
        // Read
        .re_sel_a(count[2:0] - 3'd2), 
        .re_sel_b(count[2:0] - 3'd1),
        .re_data_a(re_data_a), 
        .re_data_b(re_data_b),
        // Write
        .wr_sel(wr_sel),
        .wr_data(wr_data),
        .wr_en(wr_en)
    );

endmodule: Stack
