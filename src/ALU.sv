`default_nettype none

module ALU (
    input logic [7:0] in_a, in_b,
    input alu_op_e op,
    output logic [7:0] out
);

    always_comb begin
        out = 8'b0;
        case (op)
            ADD: out = in_a + in_b;
            SUB: out = in_a - in_b;
            INC: out = in_b + 8'd1;
            DEC: out = in_b - 8'd1;
            MUL: out = in_a * in_b;
            NEG: out = ~in_b + 8'd1;
            SHL: out = in_a << in_b;
            SHR: out = in_a >> in_b;
            SRA: out = in_a >>> in_b;
            NOT: out = ~in_b;
            AND: out = in_a & in_b;
            LOR: out = in_a | in_b;
            XOR: out = in_a ^ in_b;
        endcase
    end

endmodule: ALU
