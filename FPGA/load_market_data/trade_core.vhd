----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2025 10:57:32 PM
-- Design Name: 
-- Module Name: trade_core - Behavioral
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
-- this is the trading core that takes in the market data
--computes a moving average and makes trading decisions based on the information
--the moving average is calculated every x time frame
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trade_core is
  Port (
    i_clk       : in std_logic;
    i_rst       : in std_logic; -- 1 is reset
    i_price     : in std_logic_vector(31 downto 0);
    o_mvg_avg   : out unsigned(31 downto 0);
    o_buy_sell  : out std_logic; -- 1 is buy 0 is sell
    
    o_N         : out unsigned(31 downto 0); -- debug output
    
    o_ready     : out std_logic
   );
end trade_core;

architecture Behavioral of trade_core is
    type state_t is (IDLE, CONV, CALC, BUY, SELL);
    signal state            : state_t;
    
    constant N              : integer := 8; --8 + 2
    constant SHIFT          : integer := 3;
    signal sum              : integer;
    signal m_avg            :unsigned(31 downto 0);
    signal ma_calculated    : std_logic;
    signal num_calc         : integer;
    signal s_buy_sell       :std_logic;
    signal last_price       : std_logic_vector(31 downto 0);
    
    --convert signals
    
    signal sign :std_logic;
    signal exp : integer;
    signal mant : unsigned(22 downto 0);
    signal float_val : real;
    signal fixed_out: integer;
    
    
begin
   process(i_clk, i_rst)
   begin
    if i_rst = '1' then
        state <= IDLE;
        sum             <= 0;
        m_avg           <= (others => '0');
        ma_calculated   <= '0';
        num_calc        <=0; 
        s_buy_sell      <='0';
         o_ready <= '0';
        
    elsif rising_edge(i_clk) then
        case state is
            when IDLE =>
                
                o_ready <= '0';
                sum             <= 0;
                m_avg           <= (others => '0');
                ma_calculated   <= '0';
                num_calc        <=0; 
                s_buy_sell      <='0';
                last_price      <= (others => '0');
                state <= CONV;
                fixed_out <= 0;
                --o_N <= TO_UNSIGNED(0, 32);
            when CONV =>
                 -- Step 1: Extract sign, exponent, and mantissa from hex input
                sign <= i_price(31); -- Sign bit
                exp <= to_integer(unsigned(i_price(30 downto 23))) - 127; -- Adjust exponent bias
                mant <= unsigned(i_price(22 downto 0)); -- Mantissa
    
                -- Step 2: Convert IEEE 754 to floating-point
                -- Formula: value = (-1)^sign * (1 + mantissa) * 2^exponent
                float_val <= real((-1)**to_integer(unsigned'('0' & sign))) *
                             (1.0 + real(to_integer(mant)) / 2.0**23) *
                             2.0**exp;
    
                -- Step 3: Scale to fixed-point
                fixed_out <= INTEGER(float_val * real(100));  
                --o_N <= to_unsigned(fixed_out, 32);  
                state <= CALC;         
            when CALC =>
                --o_N <= TO_UNSIGNED(2, 32);
                if num_calc = N then
                    
                    --m_avg <= sum / N;
                    --sum <= sum + i_price;
                    m_avg <= shift_right(TO_UNSIGNED (sum, 32), SHIFT);
                    if m_avg <= to_unsigned(fixed_out, 32) then
                        state <= BUY;
                    else
                        state <= SELL;
                    end if;
                else
                    o_ready <= '0';
                   if last_price /= i_price AND ((fixed_out - 2147483648) /= 0 OR TO_UNSIGNED(fixed_out, 32) /= 0)then
                        
                        last_price <= i_price;
                        sum <= sum + fixed_out;
                        if num_calc = 1 then
                            sum <= sum - 2147483648;
                        end if;
                        num_calc  <= num_calc + 1;
                        m_avg <= shift_right(TO_UNSIGNED (sum, 32), SHIFT);
                        --o_mvg_avg <= TO_UNSIGNED (sum,32);
                       -- o_N <= TO_UNSIGNED(fixed_out, 32);
                        o_N <= TO_UNSIGNED(num_calc, 32);
                   end if;
                   state <= CONV;
                end if;
            when BUY =>
              -- o_N <= TO_UNSIGNED(3, 32);
                o_ready <= '1';
               
                o_buy_sell <= '1';
                state <= IDLE;
            when SELL =>
                --o_N <= TO_UNSIGNED(4, 32);
                o_buy_sell <= '0';
                
                o_ready <= '1';
                state <= IDLE;
            when others =>
                state <= IDLE;
        end case;
    end if;
   end process;
    o_mvg_avg <= m_avg;
     
end Behavioral;
