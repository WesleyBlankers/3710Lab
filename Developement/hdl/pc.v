module pc(
input      		PCEnable,
input				PCMultiplexorControl,
input [7:0]		Immediate,
input 			clk,
input       	reset,
output reg [15:0]	PCout
);

wire [15:0] PCupdated;
assign PCupdated = PCMultiplexorControl ? (PCout + $signed(Immediate)) : (PCout + 16'd1); // NOTE: ISA calls for displacement to be 2's Complement.

 always @(posedge clk or posedge reset)
    begin
        if (reset)
            PCout <= 16'd0;
        else if (PCEnable)
            PCout <= PCupdated;
	   end
		
endmodule
	
