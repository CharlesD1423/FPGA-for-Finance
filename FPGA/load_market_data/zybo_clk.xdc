# Clock input: use 125 MHz system clock
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports clk]; # Sch=sysclk
create_clock -add -name clk -period 8.00 -waveform {0 4} [get_ports clk];

# addr[3:0] → Switches SW0-SW3
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports {addr[0]}]; # SW0
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports {addr[1]}]; # SW1
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {addr[2]}]; # SW2
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports {addr[3]}]; # SW3

# addr[4:9] → Pmod JA (top row)
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports {addr[4]}]; # JA1
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports {addr[5]}]; # JA2
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports {addr[6]}]; # JA3
set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports {addr[7]}]; # JA4
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports {addr[8]}]; # JA1_N
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports {addr[9]}]; # JA2_N

# price_out[3:0] → Onboard LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports {price_out[0]}]; # LED0
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports {price_out[1]}]; # LED1
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports {price_out[2]}]; # LED2
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports {price_out[3]}]; # LED3

# price_out[4:15] → Pmod JB (top row)
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports {price_out[4]}]; # JB1
set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33 } [get_ports {price_out[5]}]; # JB2
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports {price_out[6]}]; # JB3
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports {price_out[7]}]; # JB4
set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33 } [get_ports {price_out[8]}]; # JB5
set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33 } [get_ports {price_out[9]}]; # JB6
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports {price_out[10]}]; # JB7
set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports {price_out[11]}]; # JB8
 
# price_out[12:15] → Pmod JC (top row)
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {price_out[12]}]; # JC1
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {price_out[13]}]; # JC2
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports {price_out[14]}]; # JC3
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports {price_out[15]}]; # JC4
