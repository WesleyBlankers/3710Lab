module double_dabble #(
    parameter INPUT_WIDTH = 16
)(
    input  wire [INPUT_WIDTH-1:0] binary_in,
    output reg  [23:0] bcd_out
);

    // 16-bit binary input -> six BCD digits.
    // 6 digits require 24 BCD bits.
    reg [39:0] shift_reg;
    integer i;

    always @* begin
        shift_reg = 40'd0;
        shift_reg[INPUT_WIDTH-1:0] = binary_in;

        // Double-dabble / shift-add-3.
        for (i = 0; i < INPUT_WIDTH; i = i + 1) begin

            if (shift_reg[19:16] >= 5)
                shift_reg[19:16] = shift_reg[19:16] + 4'd3;

            if (shift_reg[23:20] >= 5)
                shift_reg[23:20] = shift_reg[23:20] + 4'd3;

            if (shift_reg[27:24] >= 5)
                shift_reg[27:24] = shift_reg[27:24] + 4'd3;

            if (shift_reg[31:28] >= 5)
                shift_reg[31:28] = shift_reg[31:28] + 4'd3;

            if (shift_reg[35:32] >= 5)
                shift_reg[35:32] = shift_reg[35:32] + 4'd3;

            if (shift_reg[39:36] >= 5)
                shift_reg[39:36] = shift_reg[39:36] + 4'd3;

            shift_reg = shift_reg << 1;
        end

        bcd_out = shift_reg[39:16];
    end

endmodule
