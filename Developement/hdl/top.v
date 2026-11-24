module top
(
    // GPIO Connections
    input wire [35:0] GPIO_0,

    // LED Outputs
    output wire [9:0] LEDR
);

	wire Up;
	wire Down;
	wire Right;
	wire Left;
	wire Button;

	wire [15:0] AtariControllerState;

	atari_controller atari
	(
	.Up(Up),
	.Down(Down),
	.Left(Left),
	.Right(Right),
	.Button(Button),

	.AtariControllerState(AtariControllerState)
	);

	// GPIO Signal Mapping
	assign Up     = GPIO_0[34];
	assign Down   = GPIO_0[32];
	assign Left   = GPIO_0[30];
	assign Right  = GPIO_0[28];
	assign Button = GPIO_0[26];

	// Display Controller State on LEDs
	assign LEDR[4:0] = AtariControllerState[4:0];
	assign LEDR[9:5] = 5'b0;

endmodule
