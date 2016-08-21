library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity adder_tb is
end adder_tb;

architecture testbench of adder_tb is
  signal op1, op2   : std_logic_vector(3 downto 0) := (others => '0');
  signal Cin        : std_logic;
  signal sum        : std_logic_vector(3 downto 0);
  signal Cout       : std_logic;
  signal OV         : std_logic;
  library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity adder_tb is
end adder_tb;

architecture testbench of adder_tb is
  signal op1, op2   : std_logic_vector(3 downto 0) := (others => '0');
  signal Cin        : std_logic;
  signal sum        : std_logic_vector(3 downto 0);
  signal Cout       : std_logic;
  signal OV         : std_logic;
  
begin
  uut : entity work.lookahead_adder
  port map (
    C0 => Cin,
    X => op1,
    Y => op2,
    S => sum,
    C4 => Cout,
    V => OV
  );
  Cin <= '0';

  stimulus : process is
  begin
    for val1 in 0 to 15 loop
      for val2 in 0 to 15 loop
        op1 <= std_logic_vector(unsigned(op1) + 1);
        wait for 25 ns;
      end loop;
      op2 <= std_logic_vector(unsigned(op2) + 1);
      wait for 25 ns;
    end loop;
  end process stimulus;
end testbench;
begin
  uut : entity work.lookahead_adder
  port map (
    C0 => Cin,
    X => op1,
    Y => op2,
    S => sum,
    C4 => Cout,
    V => OV
  );
  Cin <= '0';

  stimulus : process is
  begin
    for val1 in 0 to 15 loop
      for val2 in 0 to 15 loop
        op1 <= std_logic_vector(unsigned(op1) + 1);
        wait for 25 ns;
      end loop;
      op2 <= std_logic_vector(unsigned(op2) + 1);
      wait for 25 ns;
    end loop;
  end process stimulus;
end testbench;
  