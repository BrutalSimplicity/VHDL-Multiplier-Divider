library ieee;
use ieee.std_logic_1164.all;
entity shift_register is
	generic (n : integer := 2);
	port (
		clk			: in std_logic;
		reset			: in std_logic;
		sel			: in std_logic_vector (1 downto 0);		--op select (Hold, load, shift left, shift right)
		shift_in		: in std_logic;
		data_in		: in std_logic_vector((n-1) downto 0);
		data_out		: out std_logic_vector((n-1) downto 0)
	);
end shift_register;


architecture behavior of shift_register is
	signal shift			: std_logic_vector((n-1) downto 0) := (others => '0');
begin
	
	process (reset, clk)
	begin
		if (reset = '1') then
			shift <= (others => '0');
		elsif (rising_edge(clk)) then
			if (sel = "00") then	--Hold
				null;
			elsif (sel = "01") then	--Load
				shift <= data_in;
			-- The statement below seem more efficient for simulation purposes. The concatenation
			-- operator (&) seems to have a higher delta creating a longer propagation delay for
			-- larger n. Why do I know? 3 hours of debugging a non-existent bug.
			elsif (sel = "10") then	--Shift Left 
				shift((n-1) downto 1) <= shift((n-2) downto 0);
				shift(0) <= shift_in;
			elsif (sel = "11") then
				shift((n-2) downto 0) <= shift((n-1) downto 1);
				shift(n-1) <= shift_in;
			end if;
		end if;
	end process;
	
	data_out <= shift;
end behavior;

library ieee;
use ieee.std_logic_1164.all;
entity serial_shifter is
	generic (n : integer := 2);
	port (
		clk			: in std_logic;
		reset			: in std_logic;
		shift_en		: in std_logic;
		sel			: in std_logic;
		shift_in		: in std_logic;
		data_out		: out std_logic_vector((n-1) downto 0)
	);
end serial_shifter;

architecture behavior1 of serial_shifter is
	signal shift			: std_logic_vector((n-1) downto 0);
begin

	process (reset, clk)
	begin
		if (reset = '1') then
			shift <= (others => '0');
		elsif (rising_edge(clk) and shift_en = '1') then
			if (sel = '0') then --shift left
				shift((n-1) downto 1) <= shift((n-2) downto 0);
				shift(0) <= shift_in;
			elsif (sel = '1') then	--shift right
				shift((n-2) downto 0) <= shift((n-1) downto 1);
				shift(n-1) <= shift_in;
			end if;
		end if;
	end process;

	data_out <= shift;
	
end behavior1;
