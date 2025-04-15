library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_controller is
    Port (
        i_clk            : in  std_logic;
        i_trade_ready    : in  std_logic;
        i_trade_buy_sell : in  std_logic;
        i_trade_price    : in  std_logic_vector(15 downto 0);
        i_timestamp      : in  std_logic_vector(31 downto 0);
        o_uart_tx        : out std_logic
    );
end uart_controller;

architecture Behavioral of uart_controller is

    component uart_tx
        Port (
            i_clk     : in  std_logic;
            i_start   : in  std_logic;
            i_data    : in  std_logic_vector(7 downto 0);
            o_uart_tx : out std_logic;
            o_busy    : out std_logic
        );
    end component;

    signal tx_byte         : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_start        : std_logic := '0';
    signal uart_busy       : std_logic;
    signal byte_index      : integer range 0 to 8 := 0;
    signal state           : integer range 0 to 2 := 0;

    signal packet          : std_logic_vector(8*9 - 1 downto 0); -- 9 bytes = 72 bits

    -- Latched trade data
    signal price_latched     : std_logic_vector(15 downto 0);
    signal timestamp_latched : std_logic_vector(31 downto 0);
    signal dir_latched       : std_logic_vector(7 downto 0); -- LSB is buy/sell

begin

    uart_tx_inst : uart_tx
        port map (
            i_clk     => i_clk,
            i_start   => tx_start,
            i_data    => tx_byte,
            o_uart_tx => o_uart_tx,
            o_busy    => uart_busy
        );

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            tx_start <= '0'; -- default low unless pulsed in state machine

            case state is
                when 0 =>  -- Wait for trade_ready signal
                    if i_trade_ready = '1' then
                        -- Latch data once per trade
                        price_latched     <= i_trade_price;
                        timestamp_latched <= i_timestamp;
                        dir_latched       <= "0000000" & i_trade_buy_sell;

                        -- Build full packet
                        packet(8*0 + 7 downto 8*0) <= x"AA"; -- Start byte
                        packet(8*1 + 7 downto 8*1) <= dir_latched;
                        packet(8*2 + 7 downto 8*2) <= price_latched(15 downto 8);
                        packet(8*3 + 7 downto 8*3) <= price_latched(7 downto 0);
                        packet(8*4 + 7 downto 8*4) <= timestamp_latched(31 downto 24);
                        packet(8*5 + 7 downto 8*5) <= timestamp_latched(23 downto 16);
                        packet(8*6 + 7 downto 8*6) <= timestamp_latched(15 downto 8);
                        packet(8*7 + 7 downto 8*7) <= timestamp_latched(7 downto 0);
                        packet(8*8 + 7 downto 8*8) <= x"55"; -- End byte

                        byte_index <= 0;
                        state <= 1;
                    end if;

                when 1 =>  -- Start TX when UART is free
                    if uart_busy = '0' then
                        tx_byte  <= packet(8*byte_index + 7 downto 8*byte_index);
                        tx_start <= '1'; -- pulse
                        state    <= 2;
                    end if;

                when 2 =>  -- Wait for UART to finish
                    if uart_busy = '0' then
                        if byte_index < 8 then
                            byte_index <= byte_index + 1;
                            state <= 1;
                        else
                            state <= 0; -- done sending
                        end if;
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
