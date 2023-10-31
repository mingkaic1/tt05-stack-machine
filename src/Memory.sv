`default_nettype none

module Memory (
    input logic [7:0] mem_addr, data_in,
    output logic [7:0] data_out
);

    // Opcode definition
    // Arithmetic
    localparam [7:0] OP_ADD = 8'd0;
    localparam [7:0] OP_SUB = 8'd1;
    // Shifting
    localparam [7:0] OP_SHL = 8'd2;
    localparam [7:0] OP_SHR = 8'd3;
    localparam [7:0] OP_SRA = 8'd4;
    // Logical
    localparam [7:0] OP_AND = 8'd5;
    localparam [7:0] OP_LOR = 8'd6;
    localparam [7:0] OP_XOR = 8'd7;
    // Stack operations
    localparam [7:0] OP_PSI = 8'd8;  // Push immediate
    localparam [7:0] OP_PSH = 8'd9;  // Push memory
    localparam [7:0] OP_STR = 8'd10;  // Store
    localparam [7:0] OP_DUP = 8'd11;  // Duplicate
    // Control flow
    localparam [7:0] OP_JPZ = 8'd12;  // Jump if zero
    localparam [7:0] OP_JPN = 8'd13;  // Jump if negative
    localparam [7:0] OP_RET = 8'd14;
    // Null
    localparam [7:0] OP_NUL = 8'd15;

    localparam [7:0] mem [] = '{
        OP_PSI,
        8'd10,
        OP_PSI,
        8'd20,
        OP_ADD,
        OP_PSI,
        8'd5,
        OP_SUB,  // 25 on stack
        OP_JPZ,
        8'd0,  // No jump
        OP_JPN,
        8'd0,  // No jump
        OP_PSI,
        8'd30,
        OP_SUB,  // -5 on stack
        OP_JPN,
        8'd21,
        8'b0,
        8'd12,  // address 18
        8'b0,
        8'b0,
        OP_PSI,
        8'd10,
        OP_ADD,  // 5 on stack
        OP_DUP,
        OP_AND,  // 5 on stack
        OP_PSH,
        8'd18,  // 5, 12 on stack
        OP_ADD,  // 17 on stack
        OP_RET
    };

    assign data_out = mem[mem_addr];

endmodule: Memory