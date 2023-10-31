package StackMachine_pkg;

    typedef enum logic [3:0] {
        // Arithmetic
        ADD,
        SUB,
        // Shift
        SHL,
        SHR,
        SRA,
        // Logical
        AND,
        LOR,
        XOR,
        // Null
        NUL
    } alu_op_e;

endpackage