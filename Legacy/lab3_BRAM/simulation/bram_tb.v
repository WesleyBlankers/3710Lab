`timescale 1ns/1ps

module bram_tb;

    // Parameters
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 10;
    parameter MEM_FILE = "../../../src/bram.mem";

    // Clock
    reg clk;

    // BRAM signals
    reg [DATA_WIDTH-1:0] data_a0, data_b0;
    reg [ADDR_WIDTH-1:0] addr_a0, addr_b0;
    reg we_a0, we_b0;
    wire [DATA_WIDTH-1:0] q_a0, q_b0;

    // ============================================================
    // BRAM DUT
    // ============================================================
    bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_FILE(MEM_FILE)
    ) bram (
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
    // Clock generation
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // Task: Read a memory location
    // ============================================================
    task read_memory;
        input [ADDR_WIDTH-1:0] address;
        begin
            // Set address on port B
            addr_b0 = address;
            we_b0   = 1'b0;

            // Wait for BRAM read
            @(posedge clk);
            #1;

            $display(
                "READ  Address = %04d   Value = %06d",
                address,
                q_b0
            );
        end
    endtask

    // ============================================================
    // Task: Write a memory location
    // ============================================================
    task write_memory;
        input [ADDR_WIDTH-1:0] address;
        input [DATA_WIDTH-1:0] value;
        begin
            // Set address, data, and write enable on port A
            addr_a0 = address;
            data_a0 = value;
            we_a0   = 1'b1;

            // Write occurs on clock edge
            @(posedge clk);
            #1;

            // Disable writing
            we_a0 = 1'b0;

            $display(
                "WRITE Address = %04d   Value = %06d",
                address,
                value
            );
        end
    endtask

    // ============================================================
    // Test sequence
    // ============================================================
    initial begin

        // Initialize signals
        data_a0 = 16'd0;
        data_b0 = 16'd0;

        addr_a0 = 10'd0;
        addr_b0 = 10'd0;

        we_a0 = 1'd0;
        we_b0 = 1'd0;


        // Give BRAM time to initialize
        #10;

        $display("");
        $display("========================================");
        $display(" INITIAL MEMORY CONTENTS");
        $display("========================================");

        // Read each initialized location from bram.mem
        read_memory(10'd0);
        read_memory(10'd1);
        read_memory(10'd37);
        read_memory(10'd38);
        read_memory(10'd1021);
        read_memory(10'd1022);
        read_memory(10'd1023);


        // ========================================================
        // Modify some memory locations
        // ========================================================

        $display("");
        $display("========================================");
        $display(" MODIFYING MEMORY");
        $display("========================================");

        write_memory(10'd0, 16'd512);
        write_memory(10'd1, 16'd1024);
        write_memory(10'd37, 16'd65000);
        write_memory(10'd38, 16'd9);
		  write_memory(10'd1021, 16'd1021);
        write_memory(10'd1022, 16'd1022);
        write_memory(10'd1023, 16'd1023);


        // ========================================================
        // Read modified memory
        // ========================================================

        $display("");
        $display("========================================");
        $display(" MEMORY CONTENTS AFTER MODIFICATION");
        $display("========================================");

        read_memory(10'd0);
        read_memory(10'd1);
        read_memory(10'd37);
        read_memory(10'd38);
        read_memory(10'd1021);
        read_memory(10'd1022);
        read_memory(10'd1023);

        $display("");
        $display("========================================");
        $display(" TEST COMPLETE");
        $display("========================================");

        $finish;
    end

endmodule