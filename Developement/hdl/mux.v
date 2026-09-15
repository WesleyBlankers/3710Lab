module Mux(

input wire[15:0] RegFile 
input[3:0] MUXcontrol //selctor bits
output reg[15:0] MUXoutput //outputs passed to the ALU
);

always @(*) begin
		case (MUXcontrol)
				4'b0000: MUXoutput = RegFile[0];
            4'b0001: MUXoutput = RegFile[1];
            4'b0010: MUXoutput = RegFile[2];
            4'b0011: MUXoutput = RegFile[3];
            4'b0100: MUXoutput = RegFile[4];
            4'b0101: MUXoutput = RegFile[5];
            4'b0110: MUXoutput = RegFile[6];
            4'b0111: MUXoutput = RegFile[7];
            4'b1000: MUXoutput = RegFile[8];
            4'b1001: MUXoutput = RegFile[9];
            4'b1010: MUXoutput = RegFile[10];
            4'b1011: MUXoutput = RegFile[11];
            4'b1100: MUXoutput = RegFile[12];
            4'b1101: MUXoutput = RegFile[13];
            4'b1110: MUXoutput = RegFile[14];
            4'b1111: MUXoutput = RegFile[15];
            default: MUXoutput = 16'b0; // Prevents latches
        endcase
end

endmodule
