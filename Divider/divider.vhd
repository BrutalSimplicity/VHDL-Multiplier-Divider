library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity divider is
	port (
		clk			: in std_logic;
		reset			: in std_logic;
		en				: in std_logic;
		a				: in std_logic_vector(3 downto 0);
		b				: in std_logic_vector(3 downto 0);
		q				: out std_logic_vector(3 downto 0);
		r				: out std_logic_vector(3 downto 0);
		calc_done	: out std_logic	--active low
	);
end divider;

architecture behavior of divider is
	
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
	
	component serial_shifter
		generic (n : integer := 2);
		port (
			clk			: in std_logic;
			reset			: in std_logic;
			shift_en		: in std_logic;
			sel			: in std_logic;
			shift_in		: in std_logic;
			data_out		: out std_logic_vector((n-1) downto 0)
		);
	end component;
	
	component add_sub
		generic (n : integer := 2);
		port (
			op_sel			: in std_logic;	--0 -> Add, 1 -> Subtract
			a					: in std_logic_vector((n-1) downto 0);
			b					: in std_logic_vector((n-1) downto 0);
			result			: out std_logic_vector((n-1) downto 0);
			cout				: out std_logic;
			ov					: out std_logic
		);
	end component;
	
	component comparator
		generic (n : integer := 2);
		port (
			a		: in std_logic_vector((n-1) downto 0);
			b		: in std_logic_vector((n-1) downto 0);
			lt		: out std_logic;
			gt		: out std_logic;
			eq		: out std_logic
		);
	end component;
	
	type state is (IDLE, DIV0, DIV1, DONE);
	signal curr_state, next_state	: state;
	
	signal divisor		: std_logic_vector(7 downto 0) := "00000000";
	signal q_0			: std_logic := '0';
	signal rem_out		: std_logic_vector(3 downto 0) := "0000";
	signal rem_out2	: std_logic_vector(3 downto 0) := "0000";
	signal rem_in		: std_logic_vector(3 downto 0) := "0000";
	signal diff			: std_logic_vector(3 downto 0) := "0000";
	signal pad_a   : std_logic_vector(7 downto 0);
	signal pad_rem : std_logic_vector(7 downto 0);
	

	signal op_sel	: std_logic_vector(1 downto 0) := "00";
	signal d_shift : std_logic := '0';
	signal q_shift	: std_logic := '0';
	signal q_rst	: std_logic;
	signal r_sel	: std_logic;
	signal r_rst	: std_logic;
	signal r_load	: std_logic;
	signal less_than : std_logic;
	signal gte		: std_logic;
	signal count	: std_logic_vector(1 downto 0) := "00";
		
begin

	div_8 : shift_register generic map(8)
	port map (clk, reset, op_sel, '0', pad_a, divisor);
	pad_a <= a&"0000";
	
	quot_4 : serial_shifter generic map(4)
	port map (clk, q_rst, q_shift, '0', q_0, q);
	q_0 <= (not less_than);
	
	rem_4	: reg generic map (4)
	port map (clk, reset, r_load, rem_in, rem_out);
	rem_in <= rem_out2 when r_sel = '1' else b;
	
	subtractor : add_sub generic map (4)
	port map ('1', rem_out, divisor(3 downto 0), diff);
	rem_out2 <= rem_out when less_than = '1' else diff;
	r <= rem_out;
	
	comp_8 : comparator generic map(8)--compare needs to be 8 bits!
	port map (pad_rem, divisor, lt => less_than);
	pad_rem <= "0000"&rem_out;
	
	state_register : process (clk, reset)
	begin
		if (reset = '1') then
			curr_state <= IDLE;
		elsif (rising_edge(clk)) then
			curr_state <= next_state;
		end if;		
	end process;
	
	state_function	: process (curr_state, en)
	begin
		case curr_state is
			when IDLE =>
				if en = '1' then
					next_state <= DIV0;
				else
					next_state <= IDLE;
				end if;
				
			when DIV0 =>
				if count = "10" then
					next_state <= DONE;
				else
					next_state <= DIV1;
				end if;
					
			when DIV1 =>
				next_state <= DIV0;
				
			when DONE =>
				next_state <= IDLE;
		end case;
	end process;
	
	datapath_function : process (clk)
	begin
		if (rising_edge(clk)) then
			case curr_state is
				when IDLE => 
					if (en = '1') then
						calc_done <= '1';
						q_rst <= '1';	--reset quotient
						r_load <= '1';	--load remainder with dividend
						op_sel <= "01";	--load shift_reg with divisor			
						r_sel <= '0';
						count <= "00";
					else
						calc_done <= '0';
					end if;
				when DIV0 =>
					q_rst <= '0';
					r_sel <= '1';
					op_sel <= "11";	--shift divisor right
					d_shift <= '1';
					q_shift <= '1';	-- shift quotient left					
				when DIV1 =>
					count <= count + "01";
				when DONE =>
					--hold phase
					op_sel <= "00";
					d_shift <= '0';
					q_shift <= '0';
					r_load <= '0';
					calc_done <= '0';
			end case;		
		end if;	
	end process;

end behavior;
