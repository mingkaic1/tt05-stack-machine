`default_nettype none

module tb ();

    logic [7:0] ui_in; 
    logic [7:0] uo_out;
    logic [7:0] uio_in;
    logic [7:0] uio_out;
    logic [7:0] uio_oe;
    logic       ena;
    logic       clk;
    logic       rst_n;

    tt_um_mingkaic1_stack_machine dut (.*);

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        $finish;
    end

endmodule: tb