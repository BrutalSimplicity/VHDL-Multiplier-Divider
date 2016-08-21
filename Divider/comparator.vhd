library ieee;
use ieee.std_logic_1164.all;
entity comparator is
	generic (n : integer := 2);
	port (
		a		: in std_logic_vector((n-1) downto 0);
		b		: in std_logic_vector((n-1) downto 0);
		lt		: out std_logic;
		gt		: out std_logic;
		eq		: out std_logic
	);
end comparator;

architecture behavior of comparator is		
begin
	
	lt <= '1' when a < b else '0';
	gt <= '1' when a > b else '0';
	eq <= '1' when a = b else '0';
	
end behavior;