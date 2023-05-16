set_property PACKAGE_PIN T18 [get_ports {BTNU}]; # "BTNU"
set_property PACKAGE_PIN R16 [get_ports {BTND}]; # "BTND"
set_property PACKAGE_PIN N15 [get_ports {BTNL}]; # "BTNL"
set_property PACKAGE_PIN R18 [get_ports {BTNR}]; # "BTNR"
set_property PACKAGE_PIN Y21 [get_ports {blue[0]}];
set_property PACKAGE_PIN Y20 [get_ports {blue[1]}];
set_property PACKAGE_PIN AB20 [get_ports {blue[2]}];
set_property PACKAGE_PIN AB19 [get_ports {blue[3]}];
set_property PACKAGE_PIN AB22 [get_ports {green[0]}];
set_property PACKAGE_PIN AA22 [get_ports {green[1]}];
set_property PACKAGE_PIN AB21 [get_ports {green[2]}];                                                      
set_property PACKAGE_PIN AA21 [get_ports {green[3]}];
set_property PACKAGE_PIN V20 [get_ports {red[0]}];
set_property PACKAGE_PIN U20 [get_ports {red[1]}];
set_property PACKAGE_PIN V19 [get_ports {red[2]}];
set_property PACKAGE_PIN V18 [get_ports {red[3]}];
set_property PACKAGE_PIN AA19 [get_ports {hsync}];
set_property PACKAGE_PIN Y19 [get_ports {vsync}];
set_property PACKAGE_PIN Y9 [get_ports clk];
set_property PACKAGE_PIN Y11 [get_ports {ssd[6]}];
set_property PACKAGE_PIN AA11 [get_ports {ssd[5]}];
set_property PACKAGE_PIN Y10 [get_ports {ssd[4]}];
set_property PACKAGE_PIN AA9 [get_ports {ssd[3]}];
set_property PACKAGE_PIN W12 [get_ports {ssd[2]}];
set_property PACKAGE_PIN W11 [get_ports {ssd[1]}];
set_property PACKAGE_PIN V10 [get_ports {ssd[0]}];
set_property PACKAGE_PIN W8 [get_ports {sel}];
set_property PACKAGE_PIN P16 [get_ports {reset}]; # "BTNC"
set_property PACKAGE_PIN AB6 [get_ports {mosi}];
set_property PACKAGE_PIN AB7 [get_ports {cs}];
set_property PACKAGE_PIN AA4 [get_ports {sclk}];
set_property PACKAGE_PIN Y4 [get_ports {miso}];


set_property IOSTANDARD LVCMOS25 [get_ports BTNU]; # "BTNU"
set_property IOSTANDARD LVCMOS25 [get_ports BTND]; # "BTND"
set_property IOSTANDARD LVCMOS25 [get_ports BTNL]; # "BTNL"
set_property IOSTANDARD LVCMOS25 [get_ports BTNR]; # "BTNR"
set_property IOSTANDARD LVCMOS25 [get_ports reset]; # "BTNC"
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];
set_property IOSTANDARD LVCMOS33 [get_ports clk];
set_property IOSTANDARD LVCMOS33 [get_ports ssd];
set_property IOSTANDARD LVCMOS33 [get_ports sel];
set_property IOSTANDARD LVCMOS33 [get_ports mosi ];
set_property IOSTANDARD LVCMOS33 [get_ports cs];
set_property IOSTANDARD LVCMOS33 [get_ports sclk];
set_property IOSTANDARD LVCMOS33 [get_ports miso];

create_clock -period 10 [get_ports clk];