`default_nettype none

module Top (
    input logic clock, reset,
    input logic [7:0] data_in,
    output logic [7:0] data_out, mem_addr
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
    localparam [7:0] OP_FIN = 8'd14;
    // Null
    localparam [7:0] OP_NUL = 8'd15;
    // NEW
    localparam [7:0] OP_CAL = 8'd16;  // Call
    localparam [7:0] OP_RET = 8'd17;  // Return
    localparam [7:0] OP_CAR = 8'd18;  // Call and return (tail recurse)

    // Registers
    logic [7:0] pc, ir;

    logic [7:0] stack_in, stack_out_a, stack_out_b;  // Stack data
    logic wr_en, re_en_a, re_en_b;  // Stack control bits

    alu_op_e alu_op;
    logic [7:0] alu_out;

    // Return stack
    logic [7:0] return_stack_in, return_stack_out;
    logic return_stack_wr_en, return_stack_re_en;

    Stack stack (
        .clock(clock),
        .reset(reset),
        .wr_data(stack_in),
        .re_data_a(stack_out_a),  
        .re_data_b(stack_out_b),  // b = top of stack
        .wr_en(wr_en), 
        .re_en_a(re_en_a), 
        .re_en_b(re_en_b)
    );

    Stack return_stack (
        .clock(clock),
        .reset(reset),
        .wr_data(return_stack_in),
        // .re_data_a(),  
        .re_data_b(return_stack_out),
        .wr_en(return_stack_wr_en), 
        .re_en_a(1'b0), 
        .re_en_b(return_stack_re_en)
    );

    ALU alu (
        .in_a(stack_out_a), 
        .in_b(stack_out_b),
        .op(alu_op),
        .out(alu_out)
    );

    ////////////////////////////////////////
    // FSM                                //
    ////////////////////////////////////////

    typedef enum logic [4:0] {
        FETCH,
        DECODE,
        EX_PSI_0, EX_PSI_1,
        EX_PSH_0, EX_PSH_1, EX_PSH_2,
        EX_STR_0, EX_STR_1,
        EX_JPZ_0, EX_JPZ_1,
        EX_JPN_0, EX_JPN_1,
        EX_FIN,
        EX_CAL_0, EX_CAL_1,
        EX_CAR_0, EX_CAR_1
    } state_e;

    state_e state, next_state;

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            FETCH: next_state = DECODE;
            DECODE: begin
                case (ir)
                    OP_ADD: next_state = FETCH;
                    OP_SUB: next_state = FETCH;
                    OP_SHL: next_state = FETCH;
                    OP_SHR: next_state = FETCH;
                    OP_SRA: next_state = FETCH;
                    OP_AND: next_state = FETCH;
                    OP_LOR: next_state = FETCH;
                    OP_XOR: next_state = FETCH;
                    OP_DUP: next_state = FETCH;
                    OP_NUL: next_state = FETCH;
                    OP_PSI: next_state = EX_PSI_0;
                    OP_PSH: next_state = EX_PSH_0;
                    OP_STR: next_state = EX_STR_0;
                    OP_JPZ: next_state = (stack_out_b == 8'd0) ? EX_JPZ_0 : FETCH;
                    OP_JPN: next_state = (stack_out_b[7] == 1'b1) ? EX_JPN_0 : FETCH;
                    OP_FIN: next_state = EX_FIN;
                    OP_CAL: next_state = EX_CAL_0;
                    OP_CAR: next_state = EX_CAR_0;
                    OP_RET: next_state = FETCH;
                endcase
            end

            EX_PSI_0: next_state = EX_PSI_1;
            EX_PSI_1: next_state = FETCH;

            EX_PSH_0: next_state = EX_PSH_1;
            EX_PSH_1: next_state = EX_PSH_2;
            EX_PSH_2: next_state = FETCH;

            EX_STR_0: next_state = EX_STR_1;
            EX_STR_1: next_state = FETCH;

            EX_JPZ_0: next_state = EX_JPZ_1;
            EX_JPZ_1: next_state = FETCH;

            EX_JPN_0: next_state = EX_JPN_1;
            EX_JPN_1: next_state = FETCH;

            EX_CAL_0: next_state = EX_CAL_1;
            EX_CAL_1: next_state = FETCH;

            EX_CAR_0: next_state = EX_CAR_1;
            EX_CAR_1: next_state = FETCH;
        endcase
    end

    // Output logic
    always_comb begin
        // Defaults
        mem_addr = 8'b0;
        data_out = 8'b0;
        stack_in = 8'b0;
        wr_en = 1'b0;
        re_en_a = 1'b0;
        re_en_b = 1'b0;
        alu_op = NUL;
        return_stack_in = 8'b0;
        return_stack_re_en = 1'b0;
        return_stack_wr_en = 1'b0;

        case (state)
            FETCH: begin
                mem_addr = pc;
            end
            DECODE: begin
                if (
                    ir == OP_ADD ||
                    ir == OP_SUB ||
                    ir == OP_SHL ||
                    ir == OP_SHR ||
                    ir == OP_SRA ||
                    ir == OP_AND ||
                    ir == OP_LOR ||
                    ir == OP_XOR
                ) begin
                    // 2 values -> 1 value
                    re_en_a = 1'b1;
                    re_en_b = 1'b1;
                    wr_en = 1'b1;
                    stack_in = alu_out;
                    case (ir)
                        OP_ADD: alu_op = ADD;
                        OP_SUB: alu_op = SUB;
                        OP_SHL: alu_op = SHL;
                        OP_SHR: alu_op = SHR;
                        OP_SRA: alu_op = SRA;
                        OP_AND: alu_op = AND;
                        OP_LOR: alu_op = LOR;
                        OP_XOR: alu_op = XOR;
                    endcase
                end
                else if (ir == OP_DUP) begin
                    wr_en = 1'b1;
                    stack_in = stack_out_b;
                end
                else if (ir == OP_FIN) begin
                    data_out = stack_out_b;
                end
                else if (ir == OP_RET) begin
                    return_stack_re_en = 1'b1;
                end
            end
            
            EX_PSI_0: mem_addr = pc;
            EX_PSI_1: begin
                wr_en = 1'b1;
                stack_in = ir;
            end

            EX_PSH_0: mem_addr = pc;
            EX_PSH_1: mem_addr = ir;
            EX_PSH_2: begin
                wr_en = 1'b1;
                stack_in = ir;
            end

            EX_STR_0: begin
                mem_addr = pc;
                data_out = 8'b1111_1111;
            end
            EX_STR_1: begin
                data_out = stack_out_b;
                mem_addr = ir;
                re_en_b = 1'b1;
            end

            EX_JPZ_0: mem_addr = pc;
            // EX_JPZ_1: begin end

            EX_JPN_0: mem_addr = pc;
            // EX_JPN_1: begin end

            EX_FIN: data_out = stack_out_b;

            EX_CAL_0: mem_addr = pc;
            EX_CAL_1: begin
                return_stack_in = pc;
                return_stack_wr_en = 1'b1;
            end

            EX_CAR_0: mem_addr = pc;
            // EX_CAR_1: begin end
        endcase
    end

    // Registers
    always_ff @ (posedge clock) begin
        if (reset) begin
            pc <= 8'b0;
            ir <= 8'd0;
        end
        else begin
            case (state)
                FETCH: begin
                    ir <= data_in;
                end
                DECODE: begin
                    case (ir)
                        OP_ADD: pc <= pc + 8'd1; 
                        OP_SUB: pc <= pc + 8'd1; 
                        OP_SHL: pc <= pc + 8'd1; 
                        OP_SHR: pc <= pc + 8'd1; 
                        OP_SRA: pc <= pc + 8'd1; 
                        OP_AND: pc <= pc + 8'd1; 
                        OP_LOR: pc <= pc + 8'd1; 
                        OP_XOR: pc <= pc + 8'd1; 
                        OP_DUP: pc <= pc + 8'd1; 
                        OP_NUL: pc <= pc + 8'd1;
                        OP_PSI: pc <= pc + 8'd1;
                        OP_PSH: pc <= pc + 8'd1;
                        OP_STR: pc <= pc + 8'd1;
                        OP_JPZ: begin
                            if (stack_out_b == 8'd0) pc <= pc + 8'd1;
                            else pc <= pc + 8'd2;  // Skip imm
                        end
                        OP_JPN: begin
                            if (stack_out_b[7] == 1'b1) pc <= pc + 8'd1;
                            else pc <= pc + 8'd2;  // Skip imm
                        end
                        OP_FIN: pc <= pc + 8'd1;
                        OP_CAL: pc <= pc + 8'd1;
                        OP_CAR: pc <= pc + 8'd1;
                        OP_RET: pc <= return_stack_out;
                    endcase
                end
                
                EX_PSI_0: ir <= data_in;
                EX_PSI_1: pc <= pc + 8'd1;
                
                EX_PSH_0: ir <= data_in;
                EX_PSH_1: ir <= data_in;
                EX_PSH_2: pc <= pc + 8'd1;

                EX_STR_0: ir <= data_in;
                EX_STR_1: pc <= pc + 8'd1;

                EX_JPZ_0: ir <= data_in;
                EX_JPZ_1: pc <= ir;

                EX_JPN_0: ir <= data_in;
                EX_JPN_1: pc <= ir;

                EX_CAL_0: begin
                    ir <= data_in;
                    pc <= pc + 8'd1;
                end
                EX_CAL_1: pc <= ir;

                EX_CAR_0: ir <= data_in;
                EX_CAR_1: pc <= ir;
            endcase
        end
    end

    // FSM
    always_ff @ (posedge clock) begin
        if (reset) state <= FETCH;
        else state <= next_state;
    end

endmodule: Top