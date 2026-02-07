library ieee;
use ieee.std_logic_1164.all;
use work.package_noeud.all;

entity TB_NOEUD is
end entity TB_NOEUD;

architecture TEST of TB_NOEUD is

    component NOEUD
        generic (
            ADR_COURANT      : std_logic_vector(3 downto 0);
            ADR_DESTINATAIRE : std_logic_vector(3 downto 0)
        );
        port (
            CLK        : in  std_logic;                                 
            TEST_IN    : in  std_logic;                                 
            ENV_MES    : in  std_logic;                                  
            MESS_IN    : in  std_logic_vector(3 downto 0);              
            
            TR_IN      : in  std_logic_vector(7 downto 0);               
            TR_OUT     : out std_logic_vector(7 downto 0);              
            
            TEST_OK    : out std_logic;                                
            MESS_OUT   : out std_logic_vector(3 downto 0);             

            STATE_NODE : out NODE_STATE
        );
    end component;

    -- Constantes et signaux pour la simulation
    constant CLK_PERIOD : time := 20 ns; -- Période
    
    signal msg_trame_in  : std_logic_vector(3 downto 0);
    signal msg_trame_out : std_logic_vector(3 downto 0);
    
    signal MESS_IN_s   : std_logic_vector(3 downto 0) := (others => '0');
    signal MESS_OUT_s  : std_logic_vector(3 downto 0);

    signal adr_trame_in  : std_logic_vector(3 downto 0);
    signal adr_trame_out : std_logic_vector(3 downto 0);

    signal TR_IN_s     : std_logic_vector(7 downto 0) := (others => '0');
    signal TR_OUT_s    : std_logic_vector(7 downto 0);

    signal CLK_s       : std_logic := '0';
    signal TEST_IN_s   : std_logic := '0';
    signal ENV_MES_s   : std_logic := '0';
    signal TEST_OK_s   : std_logic;
    signal STATE_NODE_s : NODE_STATE;

    
begin
    
    -- Décoder TR_IN et TR_OUT en leurs composants Adresse/Message pour l'affichage
    msg_trame_in  <= TR_IN_s(3 downto 0);
    msg_trame_out <= TR_OUT_s(3 downto 0);
    adr_trame_in  <= TR_IN_s(7 downto 4);
    adr_trame_out <= TR_OUT_s(7 downto 4);

    -- Instanciation du Nœud (DUT)
    UUT: NOEUD 
    generic map (       
        ADR_COURANT      => "0101", --  = 5 (0101)
        ADR_DESTINATAIRE => "1000"  --  = 8 (1000)
    )
    port map (
        CLK        => CLK_s,
        TEST_IN    => TEST_IN_s,
        ENV_MES    => ENV_MES_s,
        MESS_IN    => MESS_IN_s,
        TR_IN      => TR_IN_s,
        
        TEST_OK    => TEST_OK_s,
        MESS_OUT   => MESS_OUT_s,
        TR_OUT     => TR_OUT_s,
        STATE_NODE => STATE_NODE_s
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

        TEST_IN_s <= '0';
        ENV_MES_s <= '0';
        MESS_IN_s <= (others => '0');
        TR_IN_s   <= "11110000"; -- x"F0"

        wait for CLK_PERIOD * 5;

        -- 1: Auto-Test (TEST_IN) 

        -- Début du test: CLK ~5
        TEST_IN_s <= '1';
        -- Trame sortante attendue: "01011100" / (x"5C")

        wait for CLK_PERIOD * 3; 

        -- On simule le test retour dans le noeud
        TR_IN_s <= "01011100"; -- x"5C"
        
        wait for CLK_PERIOD * 2;

        TEST_IN_s <= '0';
        TR_IN_s   <= "11110000"; -- Retour par défaut

        wait for CLK_PERIOD * 5; 

        -- 2: Envoi de Message

        ENV_MES_s <= '1';
        MESS_IN_s <= "1110"; -- Message x"E" 
        -- Trame sortante attendue: "10001110" / (x"8E")

        wait for CLK_PERIOD * 5; 

        ENV_MES_s <= '0';
        MESS_IN_s <= (others => '0');

        wait for CLK_PERIOD * 3; 

        -- 3: Recopie
        TR_IN_s <= "00110001"; -- x"31" / (Adr 3, Msg 1)
        -- Trame sortante attendue: x"31" 

        wait for CLK_PERIOD * 2; 

        -- 4: Reception/Consumption (Trame pour Adr 5)

        TR_IN_s <= "01011001"; -- x"59" / (Adr 5, Msg 9)
        -- MESS_OUT attendu: x"9" (1001)
        -- TR_OUT attendu: x"F0"

        wait for CLK_PERIOD * 5; 

        TR_IN_s <= "11110000"; -- "F0"
        wait; 
    end process stimulus_gen;
    
end architecture TEST;