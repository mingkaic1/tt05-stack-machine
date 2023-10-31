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

    Memory mem (
        .mem_addr(uio_out),
        .data_in(uo_out),
        .data_out(ui_in)
    );

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        $monitor(
            "%d, mem_addr=%d, data_in=%d, data_out=%d",
            $time, uio_out, ui_in, uo_out
        );
        rst_n <= 1'b0;
        @ (posedge clk)
        rst_n <= 1'b1;
        @ (posedge clk)
        #1000
        $finish;
    end

endmodule: tb