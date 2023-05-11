// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module lab05(clk, hsync, vsync, red, green, blue, BTNU, BTND, BTNR, 
  BTNL, ssd, sel);
  input clk;
  output hsync;
  output vsync;
  output [3:0]red;
  output [3:0]green;
  output [3:0]blue;
  input BTNU;
  input BTND;
  input BTNR;
  input BTNL;
  output [6:0]ssd;
  output sel;
endmodule
