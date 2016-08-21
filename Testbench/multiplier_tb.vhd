library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity multiplier_tb is
end multiplier_tb;

architecture behavior of multiplier_tb is
  signal go, clk, rst     : std_logic;
  signal a, b             : std_logic_vector(3 downto 0);
  signal p                : std_logic_vector(7 downto 0);
  signal done             : std_logic;

  constant period       : time := 25 ns;

begin
  
  uut : entity work.multiplier
  port map (
		go => go,
		clk => clk,
		reset => rst,
		a => a,
		b => b,
		p => p,
		done => done	
		);
	
  clock : process
  begin
    clk <= '0';
    wait for period;
    clk <= '1';
    wait for period;
  end process;
  
  stimulus : process is
  begin
    rst <= '1';
    wait for period;
    rst <= '0';
    wait for period;

    go <= '1';
    wait for period;
    a <= "0000";
    b <= "1000";
    wait until done = '0';
        

    for val1 in 0 to 15 loop
      for val2 in 0 to 15 loop
        go <= '1';
        a <= std_logic_vector(unsigned(a) + 1);
        wait until done = '0';
        go <= '0';
        wait for period;
      end loop;
      b <= std_logic_vector(unsigned(b) + 1);
    end loop;
    wait;
  end process stimulus;
  
end behavior;
