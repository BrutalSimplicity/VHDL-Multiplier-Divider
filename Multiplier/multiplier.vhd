library ieee;
use ieee.std_logic_1164.all;
entity multiplier is
	port (
		go		: in std_logic;
		clk	: in std_logic;
		reset	: in std_logic;
		a		: in std_logic_vector(3 downto 0);
		b		: in std_logic_vector(3 downto 0);
		p		: out std_logic_vector(7 downto 0);
		done	: out std_logic	--active low
	);
end multiplier;

architecture structure of multiplier is
	
	component reg
	generic (n : integer := 2);
	port (
		clk			: in std_logic;
		reset			: in std_logic;
		load			: in std_logic;
		data_in		: in std_logic_vector((n-1) downto 0);
		data_out		: out std_logic_vector((n-1) downto 0)
	);
	end component;

	component add_sub
		generic (n : integer := 8);
		port (
			op_sel			: in std_logic;	--0 -> Add, 1 -> Subtract
			a					: in std_logic_vector((n-1) downto 0);
			b					: in std_logic_vector((n-1) downto 0);
			result			: out std_logic_vector((n-1) downto 0);
			cout				: out std_logic;
			ov					: out std_logic
		);
	end component;	
	
	component shift_register
	generic (n : integer := 2);
	port (
		clk			: in std_logic;
		reset			: in std_logic;
		sel			: in std_logic_vector (1 downto 0);		--op select (Hold, load, shift left, shift right)
		shift_in		: in std_logic;
		data_in		: in std_logic_vector((n-1) downto 0);
		data_out		: out std_logic_vector((n-1) downto 0)
	);
	end component;
	
	component mult_datapath
		port (
			en			: in std_logic;
			clk		: in std_logic;
			reset		: in std_logic;
			loada		: out std_logic; --multiplicand
			loadb		: out std_logic; --mulitplier
			loadp		: out std_logic;
			resetp	: out std_logic;
			shifta	: out std_logic;	--left shift for multiplicand
			shiftb	: out std_logic;	--right shift for multiplier
			done		: out std_logic	--active low
		);
	end component;
	
	signal padded_a : std_logic_vector(7 downto 0);
	signal op_sel_a	: std_logic_vector(1 downto 0);
	signal op_sel_b	: std_logic_vector(1 downto 0);
	signal mcand		: std_logic_vector(7 downto 0);
	signal mult			: std_logic_vector(3 downto 0);
	signal prod_in		: std_logic_vector(7 downto 0);
	signal prod_out	: std_logic_vector(7 downto 0);
	signal mcand_in	: std_logic_vector(7 downto 0);
	signal loada		: std_logic;
	signal loadb		: std_logic;
	signal loadp		: std_logic;
	signal resetp		: std_logic;
	signal shifta		: std_logic;
	signal shiftb		: std_logic;
	
begin

	p <= prod_out;
	padded_a <= "0000" & a;
  
	multiplicand : shift_register generic map (8)
	port map (clk, reset, op_sel_a, '0', padded_a, mcand);
	op_sel_a <= "01" when loada = '1' else
					"10" when shifta = '1' else 
					"00";
	
	multiplier : shift_register generic map (4)
	port map (clk, reset, op_sel_b, '0', b, mult);
	op_sel_b <=	"01" when loadb = '1' else
					"11" when shiftb = '1' else 
					"00";
	
	product : reg generic map (8)
	port map (clk, resetp, loadp, prod_in, prod_out);

	adder : add_sub generic map (8)
	port map ('0', prod_out, mcand_in, prod_in);
	mcand_in <=	"00000000" when mult(0) = '0' else 
					mcand;
					
	datapath : mult_datapath
	port map (go, clk, reset, loada, loadb, loadp, resetp, shifta, shiftb, done);
	

	
end structure;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity mult_datapath is
	port (
		en			: in std_logic;
		clk		: in std_logic;
		reset		: in std_logic;
		loada		: out std_logic; --multiplicand
		loadb		: out std_logic; --mulitplier
		loadp		: out std_logic;
		resetp	: out std_logic;
		shifta	: out std_logic;	--left shift for multiplicand
		shiftb	: out std_logic;	--left shift for multiplier
		done		: out std_logic	--active low
	);
end mult_datapath;

architecture behavior of mult_datapath is
	type state is (IDLE, MULT, FINISH);

	signal curr_state			: state;
	signal next_state			: state;
	
	signal count				: std_logic_vector(1 downto 0) := "00";
	
begin
	
	state_register : process (clk, reset)
	begin
		if (reset = '1') then
			curr_state <= IDLE;
		elsif (rising_edge(clk)) then
			curr_state <= next_state;
		end if;
	end process;
	
	state_function : process (curr_state, en, count)
	begin
		case curr_state is
			when IDLE =>
				if (en = '1') then
					next_state <= MULT;
				else
					next_state <= IDLE;
				end if;
				
			when MULT =>
				if (count = "11") then
					next_state <= FINISH;
				else
					next_state <= MULT;
				end if;
			
			when FINISH =>
				next_state <= IDLE;
		end case;
		
	end process;
	
	datapath : process(clk)
	begin
		if (rising_edge(clk)) then
			case curr_state is
				when IDLE =>
					if (en = '1') then
						count <= "00";
						loada <= '1';
						loadb <= '1';
						resetp <= '1';
						done <= '1';
					else
						done <= '0';
					end if;
				
				when MULT =>
					loada <= '0';
					loadb <= '0';
					resetp <= '0';
					shifta <= '1';
					shiftb <= '1';
					loadp <= '1';
					count <= count + "01";
				
				when FINISH =>
					done <= '0';
					shifta <= '0';
					shiftb <= '0';
					loadp <= '0';
			end case;
		end if;
	end process;
	
end behavior;