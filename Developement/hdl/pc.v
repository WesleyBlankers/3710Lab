module pc(
input      		PCEnable,
input				PCImmediateMultiplexorControl,
input				PCTargetMultiplexorControl,
input	[15:0]   PCTarget,
input [7:0]		Immediate,
input 			clk,
input       	reset,
output reg [15:0]	PCOut
);

wire [15:0] PCDisplaced;
wire [15:0] PCUpdated;
assign PCDisplaced = PCImmediateMultiplexorControl ? (PCOut + $signed(Immediate)) : (PCOut + 16'd1); // NOTE: ISA calls for displacement to be 2's Complement.
assign PCUpdated = PCTargetMultiplexorControl ? PCTarget : PCDisplaced;

 always @(posedge clk or posedge reset)
    begin
        if (reset)
            PCOut <= 16'd0;
        else if (PCEnable)
            PCOut <= PCUpdated;
	   end
		
endmodule
	
