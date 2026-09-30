module bram_fsm #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 10,
    parameter MEM_FILE   = "../src/bram.mem"
)(
    input  wire [9:0] SW,
    input  wire [3:0] KEYS,
    input  wire       clk,

    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

    // ------------------------------------------------------------
    // BRAM interface
    // ------------------------------------------------------------
    wire [DATA_WIDTH-1:0] data_a0;
    wire [DATA_WIDTH-1:0] data_b0;
    wire [ADDR_WIDTH-1:0] addr_a0;
    wire [ADDR_WIDTH-1:0] addr_b0;
    wire                  we_a0;
    wire                  we_b0;
    wire [DATA_WIDTH-1:0] q_a0;
    wire [DATA_WIDTH-1:0] q_b0;

    reg [DATA_WIDTH-1:0] write_data;
    reg [ADDR_WIDTH-1:0] write_addr;
    reg [2:0] operation;

    assign data_a0 = write_data;
    assign addr_a0 = write_addr;

    // Follow switches while idle.
    // Once an operation starts, keep reading the captured address.
    assign addr_b0 = (state == STATE_IDLE) ? SW : write_addr;

    assign data_b0 = {DATA_WIDTH{1'b0}};

    // BRAM writes whenever FSM is in WRITE state.
    assign we_a0 = (state == STATE_WRITE);

    assign we_b0 = 1'b0;

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

    // ------------------------------------------------------------
    // Synchronize the active-low pushbuttons
    // ------------------------------------------------------------
    reg [3:0] keys_meta;
    reg [3:0] keys_sync;

    always @(posedge clk) begin
        keys_meta <= KEYS;
        keys_sync <= keys_meta;
    end

    // ------------------------------------------------------------
    // FSM
    //
    // KEY0: +1
    // KEY1: +10
    // KEY2: -10
    // KEY3:  0
    //
    // Keys are active-low.
    // ------------------------------------------------------------
    localparam STATE_IDLE       = 3'd0;
    localparam STATE_READ       = 3'd1;
    localparam STATE_MODIFY     = 3'd2;
    localparam STATE_WRITE      = 3'd3;
    localparam STATE_WAIT       = 3'd4;

    localparam OP_ADD1  = 3'd0;
    localparam OP_ADD10 = 3'd1;
    localparam OP_SUB10 = 3'd2;
    localparam OP_RESET = 3'd3;

    reg [2:0] state;

    always @(posedge clk) begin

        case (state)

            STATE_IDLE: begin

                if (!keys_sync[0]) begin
                    write_addr <= SW;
                    operation <= OP_ADD1;
                    state <= STATE_READ;
                end

                else if (!keys_sync[1]) begin
                    write_addr <= SW;
                    operation <= OP_ADD10;
                    state <= STATE_READ;
                end

                else if (!keys_sync[2]) begin
                    write_addr <= SW;
                    operation <= OP_SUB10;
                    state <= STATE_READ;
                end

                else if (!keys_sync[3]) begin
                    write_addr <= SW;
                    operation <= OP_RESET;
                    state <= STATE_READ;
                end

            end


            STATE_READ: begin
                // BRAM performs synchronous read here.
                state <= STATE_MODIFY;
            end


            STATE_MODIFY: begin

                case (operation)

                    OP_ADD1:
                        write_data <= q_b0 + 16'd1;

                    OP_ADD10:
                        write_data <= q_b0 + 16'd10;

                    OP_SUB10:
                        write_data <= q_b0 - 16'd10;

                    OP_RESET:
                        write_data <= 16'd0;

                    default:
                        write_data <= q_b0;

                endcase

                state <= STATE_WRITE;

            end


            STATE_WRITE: begin
                // write_data is already prepared.
                // we_a0 is high because state == STATE_WRITE.
                state <= STATE_WAIT;
            end


            STATE_WAIT: begin

                if (&keys_sync)
                    state <= STATE_IDLE;

            end


            default: begin
                state <= STATE_IDLE;
            end

        endcase

    end

    // ------------------------------------------------------------
    // Convert current BRAM value to six decimal digits.
    // ------------------------------------------------------------
    wire [23:0] bcd_digits;

    double_dabble #(
        .INPUT_WIDTH(DATA_WIDTH)
    ) converter (
        .binary_in(q_b0),
        .bcd_out(bcd_digits)
    );

    // ------------------------------------------------------------
    // Six active-low 7-segment displays.
    //
    // bcd_digits:
    // [23:20] = most significant digit
    // ...
    // [3:0]   = least significant digit
    // ------------------------------------------------------------
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

endmodule
