library ieee;
use ieee.std_logic_1164.all;
entity partial_full_adder is
	port (
		Cin, X, Y			: in std_logic;
		S, Cout				: out std_logic
	);
end partial_full_adder;

architecture behavior of partial_full_adder is
begin
	S <= X xor Y xor Cin;
	Cout <= (Cin and Y) or (Cin and X) or (X and Y);
end behavior;

library ieee;
use ieee.std_logic_1164.all;
entity lookahead_adder is
	generic (n : integer := 2);
	port (
		C0 		: in std_logic;
		X, Y		: in std_logic_vector((n - 1) downto 0);
		S			: out std_logic_vector((n - 1) downto 0);
		Cn, V		: out std_logic
	);
end lookahead_adder;

architecture structure of lookahead_adder is
	component partial_full_adder
		port (
			Cin, X, Y			: in std_logic;
			S, Cout				: out std_logic
		);
	end component;
	
	signal C : std_logic_vector(n downto 0);
begin

	C(0) <= C0;
	Cn <= C(n);
	
	S_n : for i in 0 to (n - 1) generate
		S_i : partial_full_adder
		port map (C(i), X(i), Y(i), S(i), C(i+1));
	end generate;
	
	V <= C(n) xor C(n-1);
end structure;

library ieee;
use ieee.std_logic_1164.all;
entity add_sub is
	generic (n : integer := 2);
	port (
		op_sel			: in std_logic;	--0 -> Add, 1 -> Subtract
		a					: in std_logic_vector((n-1) downto 0);
		b					: in std_logic_vector((n-1) downto 0);
		result			: out std_logic_vector((n-1) downto 0);
		cout				: out std_logic;
		ov					: out std_logic
	);
end add_sub;

architecture behavior of add_sub is
	component lookahead_adder
		generic (n : integer := 2);
		port (
			C0 		: in std_logic;
			X, Y		: in std_logic_vector((n - 1) downto 0);
			S			: out std_logic_vector((n - 1) downto 0);
			Cn, V		: out std_logic
		);
	end component;
	
	signal op1		: std_logic_vector((n - 1) downto 0);
	signal op2		: std_logic_vector((n - 1) downto 0);
	signal c0		: std_logic;
	
begin
	c0 <= op_sel;	--0 -> Add, 1 -> Subtract
	op1 <= a;
	two_comp_i : for i in 0 to (n - 1) generate
		op2(i) <= b(i) xor op_sel;
	end generate;
	
	adder_n : lookahead_adder generic map (n)
	port map (
		 C0 => c0,
		 X => op1,
		 Y => op2,
		 S => result,
		 Cn => cout,
		 V => ov
	);
	
end behavior;
		