library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trade_core is
  Port (
    i_clk       : in std_logic;
    i_rst       : in std_logic;
    i_price     : in unsigned(15 downto 0);
    o_mvg_avg   : out unsigned(32 downto 0);
    o_buy_sell  : out std_logic;
    o_N         : out unsigned(15 downto 0);
    o_ready     : out std_logic
  );
end trade_core;

architecture Behavioral of trade_core is

    type state_t is (IDLE, CALC, BUY, SELL);
    signal state : state_t := IDLE;
    
    constant N : integer := 8;
    constant SHIFT : integer := 3; -- divide by 8 = shift right by 3

    type price_array is array(0 to N-1) of unsigned(15 downto 0);
    signal price_mem : price_array; -- use a clean name, not "buffer"
    signal price_idx : integer range 0 to N-1 := 0; -- points to where to write

    signal sum : unsigned(32 downto 0) := (others => '0');
    signal m_avg : unsigned(32 downto 0) := (others => '0');

    signal num_calc : unsigned(15 downto 0) := (others => '0');
    signal last_price : unsigned(15 downto 0) := (others => '0');

begin

    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            state <= IDLE;
            sum <= (others => '0');
            m_avg <= (others => '0');
            num_calc <= (others => '0');
            price_idx <= 0;
            last_price <= (others => '0');
            price_mem <= (others => (others => '0')); -- Clear memory manually if Vivado allows
            o_ready <= '0';
        elsif rising_edge(i_clk) then
            case state is
                when IDLE =>
                    sum <= (others => '0');
                    m_avg <= (others => '0');
                    num_calc <= (others => '0');
                    price_idx <= 0;
                    last_price <= (others => '0');
                    price_mem <= (others => (others => '0'));
                    o_ready <= '0';
                    state <= CALC;

                when CALC =>
                    o_ready <= '0';

                    if last_price /= i_price then
                        last_price <= i_price;

                        -- Store new price into array
                        price_mem(price_idx) <= i_price;

                        -- Increment index with wraparound
                        if price_idx = N-1 then
                            price_idx <= 0;
                        else
                            price_idx <= price_idx + 1;
                        end if;

                        -- Increment number of samples collected
                        num_calc <= num_calc + 1;

                        -- Only calculate average once at least 8 samples collected
                        if num_calc >= to_unsigned(N, num_calc'length) then
                            -- Sum all prices
                            sum <= resize(price_mem(0), 33) +
                                   resize(price_mem(1), 33) +
                                   resize(price_mem(2), 33) +
                                   resize(price_mem(3), 33) +
                                   resize(price_mem(4), 33) +
                                   resize(price_mem(5), 33) +
                                   resize(price_mem(6), 33) +
                                   resize(price_mem(7), 33);

                            -- Moving average is sum / 8
                            m_avg <= shift_right(sum, SHIFT);

                            -- Compare latest price to moving average
                            if i_price >= shift_right(sum, SHIFT) then
                                state <= BUY;
                            else
                                state <= SELL;
                            end if;
                        end if;
                    end if;

                when BUY =>
                    o_buy_sell <= '1';
                    o_ready <= '1';
                    state <= CALC;

                when SELL =>
                    o_buy_sell <= '0';
                    o_ready <= '1';
                    state <= CALC;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    o_mvg_avg <= m_avg;
    o_N <= num_calc;

end Behavioral;
