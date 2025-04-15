# Clock input: use 125 MHz system clock
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports clk]; # Sch=sysclk
create_clock -add -name clk -period 8.00 -waveform {0 4} [get_ports clk];

##Pmod Header JC    for uart tx                                                                                                              
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports { jc[0] }]; #IO_L10P_T1_34 Sch=jc_p[1]   			 
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports { jc[1] }]; #IO_L10N_T1_34 Sch=jc_n[1]		     
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { o_uart_tx }];
              
#set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33     } [get_ports { jc[3] }]; #IO_L1N_T0_34 Sch=jc_n[2]              
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports { jc[4] }]; #IO_L8P_T1_34 Sch=jc_p[3]              
#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports { jc[5] }]; #IO_L8N_T1_34 Sch=jc_n[3]              
#set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     } [get_ports { jc[6] }]; #IO_L2P_T0_34 Sch=jc_p[4]              
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33     } [get_ports { jc[7] }]; #IO_L2N_T0_34 Sch=jc_n[4]  

# Button input (BTN0)
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports i_reset_button];

## Status LED output (LED0)
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports o_status_led];

## Status LED output (LED1)
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports  o_reset_led];

## Trading LED Output (LED2)
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports { o_trading_led }];


# addr[3:0] â†’ Switches SW0-SW3
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports {addr[0]}]; # SW0
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports {addr[1]}]; # SW1
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {addr[2]}]; # SW2
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports {addr[3]}]; # SW3

# addr[4:9] â†’ Pmod JA (top row)
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports {addr[4]}]; # JA1
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports {addr[5]}]; # JA2
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports {addr[6]}]; # JA3
set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports {addr[7]}]; # JA4
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports {addr[8]}]; # JA1_N
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports {addr[9]}]; # JA2_N

# price_out[3:0] â†’ Onboard LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports {price_out[0]}]; # LED0
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports {price_out[1]}]; # LED1
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports {price_out[2]}]; # LED2
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports {price_out[3]}]; # LED3

# price_out[4:15] â†’ Pmod JB (top row)
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports {price_out[4]}]; # JB1
set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33 } [get_ports {price_out[5]}]; # JB2
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports {price_out[6]}]; # JB3
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports {price_out[7]}]; # JB4
set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33 } [get_ports {price_out[8]}]; # JB5
set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33 } [get_ports {price_out[9]}]; # JB6
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports {price_out[10]}]; # JB7
set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports {price_out[11]}]; # JB8
 
# price_out[12:15] â†’ Pmod JC (top row)
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {price_out[12]}]; # JC1
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {price_out[13]}]; # JC2
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports {price_out[14]}]; # JC3
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports {price_out[15]}]; # JC4
