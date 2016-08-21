library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity divider_tb is
end divider_tb;

architecture testbench of divider_tb is
  signal clk, rst   : std_logic := '0';
  signal op1, op2   : std_logic_vector(3 downto 0) := "0000";
  signal en         : std_logic := '0';
  signal quot       : std_logic_vector(3 downto 0) := "0000";
  signal rema       : std_logic_vector(3 downto 0) := "0000";
  signal done       : std_logic;
  
  constant period       : time := 25 ns;
  
begin
  uut : entity work.divider
  port map (
    clk => clk,
    reset => rst,
    en => en,
    a => op1,
    b => op2,
    q => quot,
    r => rema,
    calc_done => done
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

    en <= '1';
    wait for period;
    op1 <= "0010";
    op2 <= "1010";
    wait until done = '0';
        

    for val1 in 0 to 15 loop
      for val2 in 0 to 15 loop
        en <= '1';
        op1 <= std_logic_vector(unsigned(op1) + 1);
        wait until done = '0';
        en <= '0';
        wait for period;
      end loop;
      op2 <= std_logic_vector(unsigned(op2) + 1);
    end loop;
    wait;
  end process stimulus;
end testbench;
  
