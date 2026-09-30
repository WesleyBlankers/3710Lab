module bram_fsm #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 10,
    parameter MEM_FILE   = "../src/bram.mem"
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [3:0]  KEYS,

    output wire        LED,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5
);

    // ============================================================
    // KEY0 synchronizer / edge detector
    //
    // KEY0 is active-low.
    //
    // CLOCK_50 remains the actual FPGA clock. A KEY0 press
    // generates a one-clock pulse called key0_press.
    // ============================================================

    reg key0_meta;
    reg key0_sync;
    reg key0_prev;

    wire key0_press;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            key0_meta <= 1'b1;
            key0_sync <= 1'b1;
            key0_prev <= 1'b1;
        end
        else begin
            key0_meta <= KEYS[0];
            key0_sync <= key0_meta;
            key0_prev <= key0_sync;
        end
    end

    // KEY0 goes from 1 -> 0 when pressed.
    // Generate a one-clock pulse on that transition.
    assign key0_press = key0_prev & ~key0_sync;


    // ============================================================
    // BRAM
    // ============================================================

    reg  [DATA_WIDTH-1:0] data_a0;
    reg  [DATA_WIDTH-1:0] data_b0;

    reg  [ADDR_WIDTH-1:0] addr_a0;
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


    // ============================================================
    // FSM STATES
    //
    // Each state requires ONE KEY0 press to advance.
    //
    //        KEY0       KEY0        KEY0        KEY0        KEY0
    //
    // IDLE ------> READ ------> CAPTURE ------> MODIFY ------> WRITE
    //                                                           |
    //                                                           |
    //                                                        KEY0
    //                                                           |
    //                                                           v
    //                                                         DONE
    //                                                           |
    //                                                        KEY0
    //                                                           |
    //                                                           v
    //                                                         IDLE
    //
    // ============================================================

    localparam [2:0] S_IDLE    = 3'd0;
    localparam [2:0] S_READ    = 3'd1;
    localparam [2:0] S_CAPTURE = 3'd2;
    localparam [2:0] S_MODIFY  = 3'd3;
    localparam [2:0] S_WRITE   = 3'd4;
    localparam [2:0] S_DONE    = 3'd5;

    reg [2:0] state;

    reg [DATA_WIDTH-1:0] read_value;
    reg [DATA_WIDTH-1:0] write_value;


    // ============================================================
    // FSM SEQUENTIAL LOGIC
    //
    // The FSM ONLY changes state when key0_press is asserted.
    // ============================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            state       <= S_IDLE;
            read_value  <= {DATA_WIDTH{1'b0}};
            write_value <= {DATA_WIDTH{1'b0}};

        end

        else if (key0_press) begin

            case (state)

                // ------------------------------------------------
                // STATE 0
                // ------------------------------------------------
                S_IDLE: begin
                    state <= S_READ;
                end


                // ------------------------------------------------
                // STATE 1
                //
                // BRAM address is presented in this state.
                // The BRAM gets one CLOCK_50 cycle to perform
                // its synchronous read.
                // ------------------------------------------------
                S_READ: begin
                    state <= S_CAPTURE;
                end


                // ------------------------------------------------
                // STATE 2
                //
                // q_a0 now contains the value read from BRAM.
                // Capture it.
                // ------------------------------------------------
                S_CAPTURE: begin
                    read_value <= q_a0;
                    state <= S_MODIFY;
                end


                // ------------------------------------------------
                // STATE 3
                //
                // Increment the value by 1.
                // ------------------------------------------------
                S_MODIFY: begin
                    write_value <= read_value + 1'b1;
                    state <= S_WRITE;
                end


                // ------------------------------------------------
                // STATE 4
                //
                // The BRAM write happens while this state is
                // active.
                // ------------------------------------------------
                S_WRITE: begin
                    state <= S_DONE;
                end


                // ------------------------------------------------
                // STATE 5
                //
                // Operation is complete.
                // ------------------------------------------------
                S_DONE: begin
                    state <= S_IDLE;
                end


                default: begin
                    state <= S_IDLE;
                end

            endcase

        end
    end


    // ============================================================
    // BRAM CONTROL
    //
    // Currently operates on address 0, matching your original
    // bram_fsm.v.
    // ============================================================

    always @(*) begin

        // Defaults
        data_a0 = {DATA_WIDTH{1'b0}};
        data_b0 = {DATA_WIDTH{1'b0}};

        addr_a0 = {ADDR_WIDTH{1'b0}};
        addr_b0 = {ADDR_WIDTH{1'b0}};

        we_a0 = 1'b0;
        we_b0 = 1'b0;


        case (state)

            // ----------------------------------------------------
            // IDLE
            // ----------------------------------------------------
            S_IDLE: begin
                addr_a0 = {ADDR_WIDTH{1'b0}};
            end


            // ----------------------------------------------------
            // READ
            //
            // Address 0 is presented to the BRAM.
            // ----------------------------------------------------
            S_READ: begin
                addr_a0 = {ADDR_WIDTH{1'b0}};
            end


            // ----------------------------------------------------
            // CAPTURE
            // ----------------------------------------------------
            S_CAPTURE: begin
                addr_a0 = {ADDR_WIDTH{1'b0}};
            end


            // ----------------------------------------------------
            // MODIFY
            // ----------------------------------------------------
            S_MODIFY: begin
                addr_a0 = {ADDR_WIDTH{1'b0}};
            end


            // ----------------------------------------------------
            // WRITE
            //
            // Write the modified value back to address 0.
            // ----------------------------------------------------
            S_WRITE: begin
                addr_a0 = {ADDR_WIDTH{1'b0}};
                data_a0 = write_value;
                we_a0   = 1'b1;
            end


            // ----------------------------------------------------
            // DONE
            // ----------------------------------------------------
            S_DONE: begin
                addr_a0 = {ADDR_WIDTH{1'b0}};
            end


            default: begin
                addr_a0 = {ADDR_WIDTH{1'b0}};
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
    //
    // LED is ON while the FSM is in the WRITE state.
    // ============================================================

    assign LED = (state == S_WRITE);

endmodule