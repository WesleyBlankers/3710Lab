/*
 * Atari Controller Interface
 *
 * Interprets the digital input signals from an Atari controller
 * connected through a DB9 connector.
 *
 * The controller inputs represent directional controls and the
 * primary action button. These inputs are encoded into a 9-bit
 * rotation state, which is intended to be passed to the
 * BRAM_Peripheral module for storage in memory.
 *
 * DB9 Pinout:
 *   Pin 1: 	Up					- Brown	/	GIPO_0[34]	/ PIN_AG18
 *   Pin 2: 	Down				- Gray	/	GIPO_0[32]	/ PIN_AF18
 *   Pin 3: 	Left				- White	/	GIPO_0[30]	/ PIN_AF19
 *   Pin 4: 	Right				- Black	/	GIPO_0[28]	/ PIN_AF20
 *   Pin 5: 	Not Connected
 *   Pin 6: 	Button			- Green	/	GIPO_0[26]	/ PIN_AE18 
 *   Pin 7: 	+5V				- Orange	/	VCC 3.3V
 *   Pin 8: 	Ground 			- Red		/	Ground
 *   Pin 9: 	Not Connected
 *
 * Encoded Controller State:
 *   [0]: 		Button
 *   [1]: 		Right
 *   [2]: 		Left
 *   [3]: 		Down
 *   [4]: 		Up
 *   [15:5]: 	0
 */

module atari_controller
(
    // Controller Inputs
    input wire Up,
    input wire Down,
    input wire Left,
    input wire Right,
    input wire Button,

    // Encoded Controller State
    output wire [15:0] AtariControllerState
);

assign AtariControllerState = {11'b0, ~Up, ~Down, ~Left, ~Right, ~Button};

endmodule
