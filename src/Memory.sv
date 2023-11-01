`default_nettype none

module Memory (
    input logic [7:0] mem_addr, data_in,
    output logic [7:0] data_out
);

    // Opcode definition
    // Arithmetic
    localparam [7:0] OP_ADD = 8'd0;
    localparam [7:0] OP_SUB = 8'd1;
    localparam [7:0] OP_INC = 8'd2;
    localparam [7:0] OP_DEC = 8'd3;
    localparam [7:0] OP_NEG = 8'd4;
    localparam [7:0] OP_MUL = 8'd5;
    // Shifting
    localparam [7:0] OP_SHL = 8'd6;
    localparam [7:0] OP_SHR = 8'd7;
    localparam [7:0] OP_SRA = 8'd8;
    // Logical
    localparam [7:0] OP_NOT = 8'd9;
    localparam [7:0] OP_AND = 8'd10;
    localparam [7:0] OP_LOR = 8'd11;
    localparam [7:0] OP_XOR = 8'd12;
    // Stack operations
    localparam [7:0] OP_PSI = 8'd13;  // Push immediate
    localparam [7:0] OP_PSH = 8'd14;  // Push memory
    localparam [7:0] OP_STR = 8'd15;  // Store
    localparam [7:0] OP_DUP = 8'd16;  // Duplicate
    localparam [7:0] OP_DRP = 8'd17;  // Drop top value
    localparam [7:0] OP_SWP = 8'd18;  // Swap top two values
    localparam [7:0] OP_OVR = 8'd19;  // Over (copy second value to top)
    // Control flow
    localparam [7:0] OP_JMP = 8'd20;  // Jump
    localparam [7:0] OP_JPZ = 8'd21;  // Jump if zero
    localparam [7:0] OP_JPN = 8'd22;  // Jump if negative
    localparam [7:0] OP_CAL = 8'd23;  // Call
    localparam [7:0] OP_RET = 8'd24;  // Return
    localparam [7:0] OP_CAR = 8'd25;  // Call and return (tail recurse)
    localparam [7:0] OP_FIN = 8'd26;
    // Null
    localparam [7:0] OP_NUL = 8'd27;
    
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
        OP_FIN
    };

    assign data_out = mem[mem_addr];

endmodule: Memory