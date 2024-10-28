/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_autosel (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[3] = 0;
  assign uo_out[7:5] = 0;
  assign uio_out[7:2] = 0;
  assign uio_oe[7:2] = 0;

  wire [15:0] eeprom_data;

  tt_autosel autosel (
      .clk(clk),
      .rst_n(rst_n),
      .scl_i(uio_in[0]),
      .sda_i(uio_in[1]),
      .scl_o(uio_out[0]),
      .scl_oe(uio_oe[0]),
      .sda_o(uio_out[1]),
      .sda_oe(uio_oe[1]),
      .ctrl_sel_rst_n(uo_out[0]),
      .ctrl_sel_inc(uo_out[1]),
      .ctrl_ena(uo_out[2]),
      .eeprom_data(eeprom_data)
  );

  uart_debug_out debug_out (
      .clk(clk),
      .rst_n(rst_n),
      .eeprom_data(eeprom_data),
      .uart_tx(uo_out[4])
  );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:2], ui_in, 1'b0};

endmodule
