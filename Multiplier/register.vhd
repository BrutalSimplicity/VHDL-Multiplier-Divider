library ieee;
use ieee.std_logic_1164.all;
entity reg is
	generic (n : integer := 2);
	port (
		clk			: in std_logic;
		reset			: in std_logic;
		load			: in std_logic;
		data_in		: in std_logic_vector((n-1) downto 0);
		data_out		: out std_logic_vector((n-1) downto 0)
	);
end reg;

architecture behavior of reg is
	signal data			: std_logic_vector((n-1) downto 0) := (others => '0');
begin
	
	process (reset, clk)
	begin
		if (reset = '1') then
			data <= (others => '0');
		elsif (rising_edge(clk) and load = '1') then
			data <= data_in;
		end if;
	end process;
	
	data_out <= data;
end behavior;
