library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk : in std_logic
    );
end top;

architecture Behavioral of top is

    -- ROM interface signals
    signal addr     : std_logic_vector(9 downto 0) := (others => '0');
    signal rom_data : std_logic_vector(15 downto 0);
    signal price    : std_logic_vector(15 downto 0);

    -- Trade Core interface signals
    signal trade_price    : unsigned(15 downto 0);
    signal trade_mvg_avg  : unsigned(32 downto 0);
    signal trade_buy_sell : std_logic;
    signal trade_ready    : std_logic;
    signal trade_N        : unsigned(15 downto 0);

    -- Component declaration for ROM
    component prices_rom
        port (
            clka   : in std_logic;
            ena    : in std_logic;
            addra  : in std_logic_vector(9 downto 0);
            douta  : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Component declaration for ILA
    component ila_0
        port (
            clk    : in std_logic;
        probe0 : in std_logic_vector(9 downto 0);   -- addr
        probe1 : in std_logic_vector(15 downto 0);  -- price
        probe2 : in std_logic_vector(15 downto 0);  -- trade_price
        probe3 : in std_logic_vector(32 downto 0);  -- moving average
        probe4 : in std_logic;                      -- buy/sell
        probe5 : in std_logic;                      -- ready
        probe6 : in std_logic_vector(15 downto 0)   -- N (samples collected)
        );
    end component;

    -- Component declaration for Trade Core
    component trade_core
        port (
            i_clk       : in std_logic;
            i_rst       : in std_logic;
            i_price     : in unsigned(15 downto 0);
            o_mvg_avg   : out unsigned(32 downto 0);
            o_buy_sell  : out std_logic;
            o_N         : out unsigned(15 downto 0);
            o_ready     : out std_logic
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

    -- Step through ROM on each clock cycle
    process(clk)
    begin
        if rising_edge(clk) then
            addr  <= std_logic_vector(unsigned(addr) + 1);
            price <= rom_data;
            trade_price <= unsigned(rom_data); -- cast to unsigned for trade_core
        end if;
    end process;

    -- Instantiate ILA
    ila_inst : ila_0
        port map (
            clk    => clk,
            probe0 => addr,
            probe1 => price,
            probe2 => std_logic_vector(trade_price),
            probe3 => std_logic_vector(trade_mvg_avg),
            probe4 => trade_buy_sell,
            probe5 => trade_ready,
            probe6 => std_logic_vector(trade_N)
        );

    -- Instantiate Trade Core
    trade_core_inst : trade_core
        port map (
            i_clk      => clk,
            i_rst      => '0', -- no reset for now
            i_price    => trade_price,
            o_mvg_avg  => trade_mvg_avg,
            o_buy_sell => trade_buy_sell,
            o_N        => trade_N,
            o_ready    => trade_ready
        );

end Behavioral;
