module pc(
input      		PCen,
input [15:0]	PCin,
input 			clk,
input       	reset,
output reg [15:0]	PCout
);

 always @(posedge clk or posedge reset)
    begin
        if (reset)
            PCout <= 16'd0;
        else if (PCen)
            PCout <= PCin;
	   end
		
endmodule
	
