module ir(
input      		IRen,
input [15:0]	IRin,
input 			clk,
input       	reset,
output reg [15:0]	IRout
);

 always @(posedge clk or posedge reset)
    begin
        if (reset)
            IRout <= 16'd0;
        else if (IRen)
            IRout <= IRin;
	   end
		
endmodule
	