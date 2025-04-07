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
            probe1 : in std_logic_vector(15 downto 0)   -- price
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
        end if;
    end process;

    -- Instantiate ILA
    ila_inst : ila_0
        port map (
            clk    => clk,
            probe0 => addr,
            probe1 => price
        );

end Behavioral;
