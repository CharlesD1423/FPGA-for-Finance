library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk             : in  std_logic;
        i_reset_button  : in  std_logic; -- Reset button input
        o_status_led    : out std_logic; -- Status LED (waiting/blinking)
        o_reset_led     : out std_logic; -- Reset status LED
        o_trading_led   : out std_logic; -- ✅ NEW: Active trading LED
        o_uart_tx       : out std_logic  -- UART TX output
    );
end top;

architecture Behavioral of top is

    -- ROM interface signals
    signal addr        : std_logic_vector(9 downto 0) := (others => '0');
    signal rom_data    : std_logic_vector(15 downto 0);
    signal price       : std_logic_vector(15 downto 0);

    -- Trade Core signals
    signal trade_ready    : std_logic;
    signal trade_buy_sell : std_logic;
    signal trade_mvg_avg  : unsigned(31 downto 0);
    signal trade_N        : unsigned(15 downto 0);
    signal trade_price    : unsigned(15 downto 0);
    signal timestamp      : unsigned(31 downto 0) := (others => '0');

    -- Control signals
    signal start_trading  : std_logic := '0';

    -- Reset synchronization
    signal reset_sync_0   : std_logic := '1';
    signal reset_sync_1   : std_logic := '1';
    signal rst_internal   : std_logic := '0';

    -- Blinking LED control
    signal blink_counter  : unsigned(23 downto 0) := (others => '0');
    signal blink_led      : std_logic := '0';

    -- ROM Component
    component prices_rom
        port (
            clka   : in  std_logic;
            ena    : in  std_logic;
            addra  : in  std_logic_vector(9 downto 0);
            douta  : out std_logic_vector(15 downto 0)
        );
    end component;

    -- ILA Component
    component ila_0
        port (
            clk    : in  std_logic;
            probe0 : in  std_logic_vector(9 downto 0);
            probe1 : in  std_logic_vector(15 downto 0);
            probe2 : in  std_logic_vector(31 downto 0);
            probe3 : in  std_logic_vector(15 downto 0);
            probe4 : in  std_logic;
            probe5 : in  std_logic;
            probe6 : in  std_logic_vector(15 downto 0)
        );
    end component;

    -- Trade Core Component
    component trade_core
        port (
            i_clk       : in  std_logic;
            i_rst       : in  std_logic;
            i_price     : in  unsigned(15 downto 0);
            o_mvg_avg   : out unsigned(31 downto 0);
            o_buy_sell  : out std_logic;
            o_N         : out unsigned(15 downto 0);
            o_ready     : out std_logic
        );
    end component;

    -- UART Controller Component
    component uart_controller
        port (
            i_clk            : in  std_logic;
            i_trade_ready    : in  std_logic;
            i_trade_buy_sell : in  std_logic;
            i_trade_price    : in  std_logic_vector(15 downto 0);
            i_timestamp      : in  std_logic_vector(31 downto 0);
            o_uart_tx        : out std_logic
        );
    end component;

begin

    -- Instantiate ROM
    rom_inst : prices_rom
        port map (
            clka  => clk,
            ena   => '1',
            addra => addr,
            douta => rom_data
        );

    -- Instantiate Trade Core
    trade_inst : trade_core
        port map (
            i_clk       => clk,
            i_rst       => rst_internal,
            i_price     => unsigned(price),
            o_mvg_avg   => trade_mvg_avg,
            o_buy_sell  => trade_buy_sell,
            o_N         => trade_N,
            o_ready     => trade_ready
        );

    -- Instantiate UART Controller
    uart_inst : uart_controller
        port map (
            i_clk            => clk,
            i_trade_ready    => trade_ready,
            i_trade_buy_sell => trade_buy_sell,
            i_trade_price    => std_logic_vector(trade_price),
            i_timestamp      => std_logic_vector(timestamp),
            o_uart_tx        => o_uart_tx
        );

    -- Instantiate ILA
    ila_inst : ila_0
        port map (
            clk    => clk,
            probe0 => addr,
            probe1 => price,
            probe2 => std_logic_vector(trade_mvg_avg),
            probe3 => std_logic_vector(trade_N),
            probe4 => trade_ready,
            probe5 => trade_buy_sell,
            probe6 => std_logic_vector(trade_price)
        );

    -- Main process
    process(clk)
    begin
        if rising_edge(clk) then
            -- Synchronize reset button
            reset_sync_0 <= i_reset_button;
            reset_sync_1 <= reset_sync_0;
            rst_internal <= reset_sync_1;

            if rst_internal = '1' then
                -- Reset behavior
                start_trading  <= '0';
                addr           <= (others => '0');
                timestamp      <= (others => '0');
                blink_counter  <= (others => '0');
                blink_led      <= '0';
                o_status_led   <= '0';
                o_reset_led    <= '1'; -- LED ON during reset
                o_trading_led  <= '0'; -- ✅ Turn off during reset
                trade_price    <= (others => '0');
                price          <= (others => '0');
            else
                -- Normal operation
                o_reset_led <= '0'; -- LED OFF when running

                -- ✅ Automatically start trading after reset
                start_trading <= '1';

                -- Status LED logic
                if start_trading = '1' then
                    o_status_led  <= '1';      -- Solid when trading
                    o_trading_led <= '1';      -- ✅ Additional LED ON
                else
                    blink_counter <= blink_counter + 1;
                    if blink_counter(23) = '1' then
                        blink_led <= not blink_led;
                    end if;
                    o_status_led  <= blink_led;
                    o_trading_led <= '0';
                end if;

                -- ROM stepping
                if start_trading = '1' then
                    addr      <= std_logic_vector(unsigned(addr) + 1);
                    price     <= rom_data;
                    timestamp <= timestamp + 1;
                end if;

                -- Update trade price
                trade_price <= unsigned(price);
            end if;
        end if;
    end process;

end Behavioral;
