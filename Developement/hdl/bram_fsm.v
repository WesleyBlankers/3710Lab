module bram_fsm #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 10,
    parameter MEM_FILE   = "../src/bram.mem"
)(
    input  wire        clk,
    input  wire [3:0]  KEYS,
	 input  wire [9:0]  SW,

    output wire [2:0]  LED,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5
);


    // ============================================================
    // BRAM
    // ============================================================

    reg  [DATA_WIDTH-1:0] data_a0;
    reg  [DATA_WIDTH-1:0] data_b0;

    wire  [ADDR_WIDTH-1:0] addr_a0;
    reg  [ADDR_WIDTH-1:0] addr_b0;

    reg                   we_a0;
    reg                   we_b0;

    wire [DATA_WIDTH-1:0] q_a0;
    wire [DATA_WIDTH-1:0] q_b0;

    bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_FILE(MEM_FILE)
    ) bram_inst (
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

    localparam [2:0] S_READ    = 3'd0;
    localparam [2:0] S_MODIFY  = 3'd1;
    localparam [2:0] S_WRITE   = 3'd2;

    reg [2:0] state;

    reg [DATA_WIDTH-1:0] read_value;
    reg [DATA_WIDTH-1:0] write_value;
	 
	 assign addr_a0 = SW[9:0];
	 
    // ============================================================
    // FSM SEQUENTIAL LOGIC
    // ============================================================

    always @(negedge KEYS[0]) begin

            case (state)

                // ------------------------------------------------
                // STATE 0
                //
                // q_a0 now contains the value read from BRAM.
                // Capture it.
                // ------------------------------------------------
                S_READ: begin
                    read_value <= q_a0;
                    state <= S_MODIFY;
                end


                // ------------------------------------------------
                // STATE 1
                //
                // Increment the value by 1.
                // ------------------------------------------------
                S_MODIFY: begin
                    write_value <= read_value + 1'b1;
                    state <= S_WRITE;
                end


                // ------------------------------------------------
                // STATE 2
                //
                // The BRAM write happens while this state is
                // active.
                // ------------------------------------------------
                S_WRITE: begin
                    state <= S_READ;
                end

                default: begin
                    state <= S_READ;
                end

            endcase
    end


    // ============================================================
    // BRAM CONTROL
    // ============================================================

    always @(*) begin

        // Defaults
        data_a0 = 16'd0;
        data_b0 = 16'd0;

        we_a0 = 1'b0;
        we_b0 = 1'b0;

        case (state)

            // ----------------------------------------------------
            // READ
            //
            // Address on switches is presented to the BRAM.
            // ----------------------------------------------------
            S_READ: begin
            end

            // ----------------------------------------------------
            // MODIFY
            // ----------------------------------------------------
            S_MODIFY: begin
            end

            // ----------------------------------------------------
            // WRITE
            //
            // Write the modified value back to address on switches.
            // ----------------------------------------------------
            S_WRITE: begin
                data_a0 = write_value;
                we_a0   = 1'b1;
            end

            default: begin
            end

        endcase

    end


    // ============================================================
    // DOUBLE DABBLE
    //
    // Always display the current BRAM value.
    // ============================================================

    wire [23:0] bcd_digits;

    double_dabble #(
        .INPUT_WIDTH(DATA_WIDTH)
    ) converter (
        .binary_in(q_a0),
        .bcd_out(bcd_digits)
    );


    // ============================================================
    // SEVEN SEGMENT DISPLAYS
    // ============================================================

    HexTo7Seg hex0 (
        .hex_input(bcd_digits[3:0]),
        .segment_display(HEX0)
    );

    HexTo7Seg hex1 (
        .hex_input(bcd_digits[7:4]),
        .segment_display(HEX1)
    );

    HexTo7Seg hex2 (
        .hex_input(bcd_digits[11:8]),
        .segment_display(HEX2)
    );

    HexTo7Seg hex3 (
        .hex_input(bcd_digits[15:12]),
        .segment_display(HEX3)
    );

    HexTo7Seg hex4 (
        .hex_input(bcd_digits[19:16]),
        .segment_display(HEX4)
    );

    HexTo7Seg hex5 (
        .hex_input(bcd_digits[23:20]),
        .segment_display(HEX5)
    );


    // ============================================================
    // DEBUG LED
    // ============================================================

	 assign LED[2] = (state == S_READ);
	 assign LED[1] = (state == S_MODIFY);
	 assign LED[0] = (state == S_WRITE);

endmodule