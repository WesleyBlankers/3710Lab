`timescale 1ns/1ps

module bram_tb;

    // Parameters
    parameter DATA_WIDTH = 48;
    parameter ADDR_WIDTH = 10;

    // Clock
    reg clk;

    // BRAM 0 signals
    reg [DATA_WIDTH-1:0] data_a0, data_b0;
    reg [ADDR_WIDTH-1:0] addr_a0, addr_b0;
    reg we_a0, we_b0;
    wire [DATA_WIDTH-1:0] q_a0, q_b0;

    // BRAM 1 signals
    reg [DATA_WIDTH-1:0] data_a1, data_b1;
    reg [ADDR_WIDTH-1:0] addr_a1, addr_b1;
    reg we_a1, we_b1;
    wire [DATA_WIDTH-1:0] q_a1, q_b1;


    // ============================================================
    // BRAM 0
    // ============================================================
    bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) bram0 (
        .data_a(data_a0),
        .data_b(data_b0),
        .addr_a(addr_a0),
        .addr_b(addr_b0),
        .we_a(we_a0),
        .we_b(we_b0),
        .clk(clk),
        .q_a(q_a0),
        .q_b(q_b0)
    );


    // ============================================================
    // BRAM 1
    // ============================================================
    bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) bram1 (
        .data_a(data_a1),
        .data_b(data_b1),
        .addr_a(addr_a1),
        .addr_b(addr_b1),
        .we_a(we_a1),
        .we_b(we_b1),
        .clk(clk),
        .q_a(q_a1),
        .q_b(q_b1)
    );


    // ============================================================
    // Clock generation
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // Test sequence
    // ============================================================
    initial begin

        // Initialize signals
        data_a0 = 0;
        data_b0 = 0;
        addr_a0 = 0;
        addr_b0 = 0;
        we_a0   = 0;
        we_b0   = 0;

        data_a1 = 0;
        data_b1 = 0;
        addr_a1 = 0;
        addr_b1 = 0;
        we_a1   = 0;
        we_b1   = 0;

        // --------------------------------------------------------
        // Write to BRAM 0
        // --------------------------------------------------------
        @(negedge clk);

        addr_a0 = 10;
        data_a0 = 48'h1234_5678_9ABC;
        we_a0   = 1;

        @(negedge clk);

        we_a0 = 0;

        // --------------------------------------------------------
        // Read from BRAM 0
        // --------------------------------------------------------
        addr_a0 = 10;

        @(posedge clk);

        #1;
        $display("BRAM 0: addr=%0d, q_a=%h", addr_a0, q_a0);


        // --------------------------------------------------------
        // Write to BRAM 1
        // --------------------------------------------------------
        @(negedge clk);

        addr_a1 = 20;
        data_a1 = 48'hFEDC_BA98_7654;
        we_a1   = 1;

        @(negedge clk);

        we_a1 = 0;

        // --------------------------------------------------------
        // Read from BRAM 1
        // --------------------------------------------------------
        addr_a1 = 20;

        @(posedge clk);

        #1;
        $display("BRAM 1: addr=%0d, q_a=%h", addr_a1, q_a1);


        // --------------------------------------------------------
        // Test both BRAMs simultaneously
        // --------------------------------------------------------
        @(negedge clk);

        addr_a0 = 10;
        addr_a1 = 20;

        @(posedge clk);

        #1;
        $display("BRAM 0 read: %h", q_a0);
        $display("BRAM 1 read: %h", q_a1);

        #10;

        $finish;
    end

endmodule