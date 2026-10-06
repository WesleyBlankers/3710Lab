module mux(
    input wire [15:0] r0,
    input wire [15:0] r1,
    input wire [15:0] r2,
    input wire [15:0] r3,
    input wire [15:0] r4,
    input wire [15:0] r5,
    input wire [15:0] r6,
    input wire [15:0] r7,
    input wire [15:0] r8,
    input wire [15:0] r9,
    input wire [15:0] r10,
    input wire [15:0] r11,
    input wire [15:0] r12,
    input wire [15:0] r13,
    input wire [15:0] r14,
    input wire [15:0] r15,

    input wire [3:0] MUXcontrol,

    output reg [15:0] MUXoutput
);

    always @(*) begin
        case (MUXcontrol)
            4'd0:  MUXoutput = r0;
            4'd1:  MUXoutput = r1;
            4'd2:  MUXoutput = r2;
            4'd3:  MUXoutput = r3;
            4'd4:  MUXoutput = r4;
            4'd5:  MUXoutput = r5;
            4'd6:  MUXoutput = r6;
            4'd7:  MUXoutput = r7;
            4'd8:  MUXoutput = r8;
            4'd9:  MUXoutput = r9;
            4'd10: MUXoutput = r10;
            4'd11: MUXoutput = r11;
            4'd12: MUXoutput = r12;
            4'd13: MUXoutput = r13;
            4'd14: MUXoutput = r14;
            4'd15: MUXoutput = r15;
            default: MUXoutput = 16'd0;
        endcase
    end

endmodule