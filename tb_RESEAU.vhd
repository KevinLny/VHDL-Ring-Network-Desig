library ieee;
use ieee.std_logic_1164.all;

entity TB_RESEAU is
end entity TB_RESEAU;

architecture TEST of TB_RESEAU is

    component RESEAU
        generic (
            N : integer range 2 to 4 := 3 -- Si test a 4 alors augmenter le nombre de coup de clock entre chaque situation par exemple *2
        );
        port (
            CLK        : in  std_logic;

            Test_in1   : in  std_logic;
            Env_mes1   : in  std_logic;
            Mess_in1   : in  std_logic_vector(3 downto 0);
            Test_ok1   : out std_logic;
            Mess_out1  : out std_logic_vector(3 downto 0);

            Test_in2   : in  std_logic;
            Env_mes2   : in  std_logic;
            Mess_in2   : in  std_logic_vector(3 downto 0);
            Test_ok2   : out std_logic;
            Mess_out2  : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Constantes et signaux
    constant N_VAL : integer := 3;
    constant CLK_PERIOD : time := 10 ns; 
    
    signal CLK_s       : std_logic := '0';
    signal Test_in1_s  : std_logic := '0';
    signal Env_mes1_s  : std_logic := '0';
    signal Mess_in1_s  : std_logic_vector(3 downto 0) := (others => '0');
    signal Test_in2_s  : std_logic := '0';
    signal Env_mes2_s  : std_logic := '0';
    signal Mess_in2_s  : std_logic_vector(3 downto 0) := (others => '0');
    
    signal Test_ok1_s  : std_logic;
    signal Mess_out1_s : std_logic_vector(3 downto 0);
    signal Test_ok2_s  : std_logic;
    signal Mess_out2_s : std_logic_vector(3 downto 0);
    
begin
    
    -- Instanciation du Réseau (DUT) N=3 
    UUT: RESEAU 
    generic map (
        N => N_VAL 
    )
    port map (
        CLK        => CLK_s,
        Test_in1   => Test_in1_s,
        Env_mes1   => Env_mes1_s,
        Mess_in1   => Mess_in1_s,
        Test_ok1   => Test_ok1_s,
        Mess_out1  => Mess_out1_s,
        Test_in2   => Test_in2_s,
        Env_mes2   => Env_mes2_s,
        Mess_in2   => Mess_in2_s,
        Test_ok2   => Test_ok2_s,
        Mess_out2  => Mess_out2_s
    );

    -- Horloge
    CLK_gen: process
    begin
        loop
            CLK_s <= '0';
            wait for CLK_PERIOD / 2;
            CLK_s <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process CLK_gen;

    stimulus_gen: process
    begin
                
        Test_in1_s <= '0'; Env_mes1_s <= '0'; Mess_in1_s <= (others => '0');
        Test_in2_s <= '0'; Env_mes2_s <= '0'; Mess_in2_s <= (others => '0');

        wait for CLK_PERIOD * 5; 

        -- 1: Auto-Test du Nœud 0 (Haut à Gauche)
        -- Nœud 0 (Adr 0) envoie la trame de test (Adr=0, Msg=C) -> Trame x"0C"

        Test_in1_s <= '1';
        
        wait for CLK_PERIOD * 10; 
        
        -- Test_ok1 doit être à '1'
        Test_in1_s <= '0';
        
        wait for CLK_PERIOD * 5; 

        -- 2: Auto-Test du Nœud 8 (Bas à Droite)

        -- Nœud 8 (Adr 5) envoie la trame de test (Adr=5, Msg=C) -> Trame x"5C"
        
        Test_in2_s <= '1';
        
        wait for CLK_PERIOD * 10; 
        
        Test_in2_s <= '0';

        wait for CLK_PERIOD * 5; 

        -- TEST 3: Envoi de Message depuis le premier nœud (Nœud 0)
        -- Nœud 0 envoie un message x"A" destiné à son symétrique : Nœud 8 (Adr 5) dans le cas N = 3.
        
        Env_mes1_s <= '1';
        Mess_in1_s <= "1010"; -- Message x"A"
        
        -- Note: Le Nœud 0 doit envoyer la trame x"5A" (Adr 5, Msg A)
        
        wait for CLK_PERIOD * 10; 
        
        -- Vérification: Mess_out2_s doit valoir "1010" (x"A")
        
        Env_mes1_s <= '0';
        
        wait;
    end process stimulus_gen;
    
end architecture TEST;