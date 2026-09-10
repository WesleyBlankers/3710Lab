//```verilog
module top (
    input        CLOCK_50,
    input  [9:0]  SW,
    input  [3:0]  KEY,

    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
);

    //==========================================================
    // INTERNAL REGISTERS
    //==========================================================

    // 16-bit ALU operands
    reg [15:0] A_reg;
    reg [15:0] B_reg;

    // 8-bit ALU opcode
    reg [7:0] Opcode_reg;

    // ALU outputs
    wire [15:0] C;
    wire [4:0]  Flags;


    //==========================================================
    // MODE REGISTER
    //==========================================================
    //
    // KEY0 = A
    // KEY1 = B
    // KEY2 = Opcode
    // KEY3 = Result
    //
    // The mode register remembers which operation the user
    // selected after the button is released.
    //

    localparam MODE_A      = 2'b00;
    localparam MODE_B      = 2'b01;
    localparam MODE_OPCODE = 2'b10;
    localparam MODE_RESULT = 2'b11;

    reg [1:0] mode;

    //==========================================================
    // ALU
    //==========================================================

    alu ALU (
        .A      (A_reg),
        .B      (B_reg),
        .Cin    (1'b0),
        .Opcode (Opcode_reg),
        .C      (C),
        .Flags  (Flags)
    );


    //==========================================================
    // BUTTON / INPUT LOGIC
    //==========================================================
    //
    // DE10-Lite KEY buttons are active LOW.
    //
    // SW[9:8] selects which portion of A or B is being edited.
    //
    //             SW[9:8]
    //
    // 00 = B lower 8 bits
    // 01 = B upper 8 bits
    // 10 = A lower 8 bits
    // 11 = A upper 8 bits
    //
    // SW[7:0] contains the actual 8 bits being entered.
    //
    //==========================================================

    always @(posedge CLOCK_50) begin

        //------------------------------------------------------
        // KEY0 = A
        //------------------------------------------------------
        //
        // Load the selected half of A.
        //

        if (!KEY[0]) begin

            mode <= MODE_A;

            case (SW[9:8])

                2'b10:
                    A_reg[7:0] <= SW[7:0];

                2'b11:
                    A_reg[15:8] <= SW[7:0];

                default:
                    ; // Do nothing

            endcase
        end


        //------------------------------------------------------
        // KEY1 = B
        //------------------------------------------------------
        //
        // Load the selected half of B.
        //

        if (!KEY[1]) begin

            mode <= MODE_B;

            case (SW[9:8])

                2'b00:
                    B_reg[7:0] <= SW[7:0];

                2'b01:
                    B_reg[15:8] <= SW[7:0];

                default:
                    ; // Do nothing

            endcase
        end


        //------------------------------------------------------
        // KEY2 = OPCODE
        //------------------------------------------------------
        //
        // SW[7:0] contains the complete opcode.
        //

        if (!KEY[2]) begin

            mode <= MODE_OPCODE;

            Opcode_reg <= SW[7:0];

        end


        //------------------------------------------------------
        // KEY3 = RESULT
        //------------------------------------------------------
        //
        // No data is changed here.
        //
        // The ALU is combinational, so C is already the current
        // result. This button simply changes what is displayed.
        //

        if (!KEY[3]) begin

            mode <= MODE_RESULT;

        end

    end


    //==========================================================
    // DISPLAY VALUE
    //==========================================================
    //
    // The display can show:
    //
    // MODE_A      -> A in decimal
    // MODE_B      -> B in decimal
    // MODE_OPCODE -> Opcode in hexadecimal
    // MODE_RESULT -> C in decimal
    //
    //==========================================================

    reg [15:0] Display_Value;

    always @(*) begin

        case (mode)

            MODE_A:
                Display_Value = A_reg;

            MODE_B:
                Display_Value = B_reg;

            MODE_RESULT:
                Display_Value = C;

            MODE_OPCODE:
                Display_Value = {8'b0, Opcode_reg};

            default:
                Display_Value = 16'b0;

        endcase

    end


    //==========================================================
    // BINARY TO BCD
    //==========================================================
    //
    // A 16-bit unsigned value can range from:
    //
    // 0 to 65535
    //
    // Therefore we need five decimal digits.
    //
    // The conversion below uses the Double-Dabble algorithm.
    //
    // bcd[19:16] = ten-thousands
    // bcd[15:12] = thousands
    // bcd[11:8]  = hundreds
    // bcd[7:4]   = tens
    // bcd[3:0]   = ones
    //
    //==========================================================

    reg [19:0] bcd;
    integer i;

    always @(*) begin

        bcd = 20'b0;

        for (i = 15; i >= 0; i = i - 1) begin

            // Add 3 before shifting when a BCD digit >= 5

            if (bcd[3:0] >= 5)
                bcd[3:0] = bcd[3:0] + 3;

            if (bcd[7:4] >= 5)
                bcd[7:4] = bcd[7:4] + 3;

            if (bcd[11:8] >= 5)
                bcd[11:8] = bcd[11:8] + 3;

            if (bcd[15:12] >= 5)
                bcd[15:12] = bcd[15:12] + 3;

            bcd = {bcd[18:0], Display_Value[i]};

        end

    end


    //==========================================================
    // 7-SEGMENT DISPLAY
    //==========================================================
    //
    // Decimal modes:
    //
    // HEX4 HEX3 HEX2 HEX1 HEX0
    //
    //  ten-thousands
    //  thousands
    //  hundreds
    //  tens
    //  ones
    //
    // HEX5 is used as a mode indicator.
    //
    // Opcode mode:
    //
    // HEX1 HEX0 = opcode
    //
    //==========================================================


    //----------------------------------------------------------
    // HEX0 = Ones / Opcode low nibble
    //----------------------------------------------------------

    HexTo7Seg H0 (
        .hex_input       (bcd[3:0]),
        .segment_display (HEX0)
    );


    //----------------------------------------------------------
    // HEX1 = Tens / Opcode high nibble
    //----------------------------------------------------------

    HexTo7Seg H1 (
        .hex_input       (bcd[7:4]),
        .segment_display (HEX1)
    );


    //----------------------------------------------------------
    // HEX2 = Hundreds
    //----------------------------------------------------------

    HexTo7Seg H2 (
        .hex_input       (bcd[11:8]),
        .segment_display (HEX2)
    );


    //----------------------------------------------------------
    // HEX3 = Thousands
    //----------------------------------------------------------

    HexTo7Seg H3 (
        .hex_input       (bcd[15:12]),
        .segment_display (HEX3)
    );


    //----------------------------------------------------------
    // HEX4 = Ten-thousands
    //----------------------------------------------------------

    HexTo7Seg H4 (
        .hex_input       (bcd[19:16]),
        .segment_display (HEX4)
    );


    //----------------------------------------------------------
    // HEX5 = Mode indicator
    //----------------------------------------------------------
    //
    // A      = A mode
    // b      = B mode
    // o      = Opcode mode
    // C      = Result mode
    //
    // This uses hexadecimal approximations.
    //

    reg [3:0] Mode_Display;

    always @(*) begin

        case (mode)

            MODE_A:
                Mode_Display = 4'hA;

            MODE_B:
                Mode_Display = 4'hB;

            MODE_OPCODE:
                Mode_Display = 4'h0;

            MODE_RESULT:
                Mode_Display = 4'hC;

            default:
                Mode_Display = 4'h0;

        endcase

    end


    HexTo7Seg H5 (
        .hex_input       (Mode_Display),
        .segment_display (HEX5)
    );


endmodule
//```
