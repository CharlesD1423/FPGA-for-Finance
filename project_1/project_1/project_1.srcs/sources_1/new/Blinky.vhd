----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2025 05:37:33 PM
-- Design Name: 
-- Module Name: Blinky - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Blinky is
  Port (
    i_clock : in std_logic;
    o_led   : out std_logic
   );
end Blinky;

architecture Behavioral of Blinky is
    signal pulse : std_logic := '0';
    signal count : integer range 0 to 49999999 := 0;
begin
    counter : process(i_clock)
    begin
        if i_clock'event and i_clock = '1' then
            if count =  49999999 then
                count <= 0;
                pulse <= not pulse;
             else
                count <= count + 1;
             end if;
         end if;       
    end process;
    
    o_led <= pulse;
end Behavioral;
