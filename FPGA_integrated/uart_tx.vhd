library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        i_clk       : in  std_logic;
        i_start     : in  std_logic;
        i_data      : in  std_logic_vector(7 downto 0);
        o_uart_tx   : out std_logic;
        o_busy      : out std_logic
    );
end uart_tx;

architecture Behavioral of uart_tx is
    constant CLKS_PER_BIT : integer := 1085; -- 125MHz / 115200 baud

    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_type := IDLE;

    signal clk_count : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal tx_data   : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_reg    : std_logic := '1'; -- Idle line is HIGH
begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            case state is
                when IDLE =>
                    o_busy <= '0';
                    tx_reg <= '1';
                    if i_start = '1' then
                        tx_data <= i_data;
                        clk_count <= 0;
                        bit_index <= 0;
                        state <= START_BIT;
                        o_busy <= '1';
                    end if;

                when START_BIT =>
                    tx_reg <= '0';
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end if;

                when DATA_BITS =>
                    tx_reg <= tx_data(bit_index);
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end if;
                    end if;

                when STOP_BIT =>
                    tx_reg <= '1';
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    o_uart_tx <= tx_reg;

end Behavioral;
