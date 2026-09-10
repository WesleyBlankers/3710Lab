module top (
    input        CLOCK_50,
    input  [9:0] SW,
    input  [3:0] KEY,

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
    // INPUT / BUTTON LOGIC
    //==========================================================
    //
    // KEY buttons are active LOW.
    //
    // SW[9:8] determines which 8-bit half of the input we
    // are currently editing:
    //
    //      SW[9:8]
    //
    //      00 = Lower 8 bits
    //      11 = Upper 8 bits
    //
    // SW[7:0] contains the 8 bits being entered.
    //
    // KEY3 = Load current 16-bit value into A
    // KEY2 = Load current 16-bit value into B
    // KEY1 = Load SW[7:0] into Opcode
    // KEY0 = Display result C
    //
    //==========================================================


    //----------------------------------------------------------
    // KEY3 / KEY2
    //----------------------------------------------------------
    //
    // The input value is represented by:
    //
    //      SW[7:0] + selected half
    //
    // We update the selected half of A/B while the button
    // is held.
    //
    //----------------------------------------------------------

    always @(posedge CLOCK_50) begin

        //------------------------------------------------------
        // KEY3 = INPUT A
        //------------------------------------------------------

        if (!KEY[3]) begin

            case (SW[9:8])

                // Lower 8 bits
                2'b00:
                    A_reg[7:0] <= SW[7:0];

                // Upper 8 bits
                2'b11:
                    A_reg[15:8] <= SW[7:0];

                default:
                    ; // Do nothing for 01 and 10

            endcase

        end


        //------------------------------------------------------
        // KEY2 = INPUT B
        //------------------------------------------------------

        if (!KEY[2]) begin

            case (SW[9:8])

                // Lower 8 bits
                2'b00:
                    B_reg[7:0] <= SW[7:0];

                // Upper 8 bits
                2'b11:
                    B_reg[15:8] <= SW[7:0];

                default:
                    ; // Do nothing for 01 and 10

            endcase

        end


        //------------------------------------------------------
        // KEY1 = INPUT OPCODE
        //------------------------------------------------------

        if (!KEY[1]) begin

            Opcode_reg <= SW[7:0];

        end

    end


    //==========================================================
    // DISPLAY SELECTION
    //==========================================================
    //
    // KEY0 held:
    //
    //      Display C
    //
    // No key held:
    //
    //      Display ALU flags
    //
    // KEY2 / KEY3:
    //
    //      Display the corresponding 16-bit value while held
    //
    // KEY1:
    //
    //      Display the current 8-bit opcode while held
    //
    //==========================================================

    reg [15:0] Display_Value;
    reg [4:0]  Display_Flags;
    reg        Display_Is_Flags;

    always @(*) begin

        // Default: display flags
        Display_Value     = 16'b0;
        Display_Flags     = Flags;
        Display_Is_Flags  = 1'b1;


        //------------------------------------------------------
        // KEY3 = Display A
        //------------------------------------------------------

        if (!KEY[3]) begin

            Display_Value    = A_reg;
            Display_Is_Flags = 1'b0;

        end


        //------------------------------------------------------
        // KEY2 = Display B
        //------------------------------------------------------

        else if (!KEY[2]) begin

            Display_Value    = B_reg;
            Display_Is_Flags = 1'b0;

        end


        //------------------------------------------------------
        // KEY1 = Display Opcode
        //------------------------------------------------------

        else if (!KEY[1]) begin

            Display_Value    = {8'b0, Opcode_reg};
            Display_Is_Flags = 1'b0;

        end


        //------------------------------------------------------
        // KEY0 = Display Result C
        //------------------------------------------------------

        else if (!KEY[0]) begin

            Display_Value    = C;
            Display_Is_Flags = 1'b0;

        end

    end


    //==========================================================
    // BINARY TO BCD
    //==========================================================
    //
    // Used when displaying A, B, or C.
    //
    // 16-bit unsigned value:
    //
    //      0 - 65535
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
    // FLAG DISPLAY
    //==========================================================
    //
    // When no key is pressed, display the five ALU flags.
    //
    // Flags are:
    //
    //      Flags[4]
    //      Flags[3]
    //      Flags[2]
    //      Flags[1]
    //      Flags[0]
    //
    // Each flag is shown as:
    //
    //      1 = segment displays "1"
    //      0 = segment displays "0"
    //
    // HEX4 = Flag 4
    // HEX3 = Flag 3
    // HEX2 = Flag 2
    // HEX1 = Flag 1
    // HEX0 = Flag 0
    //
    // HEX5 is blank.
    //
    //==========================================================

    reg [3:0] Flag_Display_4;
    reg [3:0] Flag_Display_3;
    reg [3:0] Flag_Display_2;
    reg [3:0] Flag_Display_1;
    reg [3:0] Flag_Display_0;

    always @(*) begin

        if (Display_Is_Flags) begin

            if (Flags[4])
                Flag_Display_4 = 4'h1;
            else
                Flag_Display_4 = 4'h0;

            if (Flags[3])
                Flag_Display_3 = 4'h1;
            else
                Flag_Display_3 = 4'h0;

            if (Flags[2])
                Flag_Display_2 = 4'h1;
            else
                Flag_Display_2 = 4'h0;

            if (Flags[1])
                Flag_Display_1 = 4'h1;
            else
                Flag_Display_1 = 4'h0;

            if (Flags[0])
                Flag_Display_0 = 4'h1;
            else
                Flag_Display_0 = 4'h0;

        end

        else begin

            Flag_Display_4 = 4'h0;
            Flag_Display_3 = 4'h0;
            Flag_Display_2 = 4'h0;
            Flag_Display_1 = 4'h0;
            Flag_Display_0 = 4'h0;

        end

    end


    //==========================================================
    // 7-SEGMENT DISPLAY
    //==========================================================
    //
    // When displaying A, B, or C:
    //
    // HEX4 HEX3 HEX2 HEX1 HEX0
    //
    //  ten-thousands
    //  thousands
    //  hundreds
    //  tens
    //  ones
    //
    // When displaying Opcode:
    //
    // HEX1 HEX0 = opcode
    //
    // When no key is pressed:
    //
    // HEX4 HEX3 HEX2 HEX1 HEX0
    //
    //    F4   F3   F2   F1   F0
    //
    //==========================================================


    //----------------------------------------------------------
    // HEX0
    //----------------------------------------------------------

    HexTo7Seg H0 (
        .hex_input       (Display_Is_Flags ? Flag_Display_0 : bcd[3:0]),
        .segment_display (HEX0)
    );


    //----------------------------------------------------------
    // HEX1
    //----------------------------------------------------------

    HexTo7Seg H1 (
        .hex_input       (Display_Is_Flags ? Flag_Display_1 : bcd[7:4]),
        .segment_display (HEX1)
    );


    //----------------------------------------------------------
    // HEX2
    //----------------------------------------------------------

    HexTo7Seg H2 (
        .hex_input       (Display_Is_Flags ? Flag_Display_2 : bcd[11:8]),
        .segment_display (HEX2)
    );


    //----------------------------------------------------------
    // HEX3
    //----------------------------------------------------------

    HexTo7Seg H3 (
        .hex_input       (Display_Is_Flags ? Flag_Display_3 : bcd[15:12]),
        .segment_display (HEX3)
    );


    //----------------------------------------------------------
    // HEX4
    //----------------------------------------------------------

    HexTo7Seg H4 (
        .hex_input       (Display_Is_Flags ? Flag_Display_4 : bcd[19:16]),
        .segment_display (HEX4)
    );


    //----------------------------------------------------------
    // HEX5
    //----------------------------------------------------------
    //
    // Blank when displaying values.
    //
    // Displays "F" when showing flags.
    //
    //----------------------------------------------------------

    reg [3:0] HEX5_Display;

    always @(*) begin

        if (Display_Is_Flags)
            HEX5_Display = 4'hF;
        else
            HEX5_Display = 4'h0;

    end


    HexTo7Seg H5 (
        .hex_input       (HEX5_Display),
        .segment_display (HEX5)
    );


endmodule