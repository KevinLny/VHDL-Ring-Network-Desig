library ieee;
use ieee.std_logic_1164.all;
use work.package_noeud.all;

-- Question 1 : Entité noeud

entity NOEUD is
    generic (
        ADR_COURANT      : std_logic_vector(3 downto 0);
        ADR_DESTINATAIRE : std_logic_vector(3 downto 0)
    );
    port (
        -- Entrées/Sorties de la logique interne
        CLK        : in  std_logic;                                
        TEST_IN    : in  std_logic;                                
        ENV_MES    : in  std_logic;                                
        MESS_IN    : in  std_logic_vector(3 downto 0);             
        
        -- Entrées/Sorties pour la communication réseau
        TR_IN      : in  std_logic_vector(7 downto 0);             
        TR_OUT     : out std_logic_vector(7 downto 0);             
        
        -- Sorties (synchrones à CLK)
        TEST_OK    : out std_logic;                                
        MESS_OUT   : out std_logic_vector(3 downto 0);             

        -- Sortie State 
        STATE_NODE : out NODE_STATE 
    );
end entity NOEUD;

-- Question 2 : Architecture

architecture bhv_noeud of NOEUD is
    -- Constantes
    constant ADR_NON_AFFECTEE : std_logic_vector(3 downto 0) := "1111"; -- x"F" 
    constant MSG_VIDE         : std_logic_vector(3 downto 0) := "0000"; -- x"0"
    constant MSG_TEST         : std_logic_vector(3 downto 0) := "1100"; -- x"C" 
    
    -- Trame par défaut"
    constant TRAME_DEFAUT     : std_logic_vector(7 downto 0) := ADR_NON_AFFECTEE & MSG_VIDE;
    
    -- Signaux internes pour stocker l'état
    signal s_test_ok : std_logic := '0';
    signal s_mess_out : std_logic_vector(3 downto 0) := (others => '0');
    signal s_state : NODE_STATE := default;

    -- Signaux pour décoder la trame entrante
    signal adr_in : std_logic_vector(3 downto 0);
    signal msg_in : std_logic_vector(3 downto 0);
begin
    
    -- Décodage combinatoire de la trame entrante 
    adr_in <= TR_IN(7 downto 4);
    msg_in <= TR_IN(3 downto 0);
    
    TEST_OK <= s_test_ok;
    MESS_OUT <= s_mess_out;
    STATE_NODE <= s_state;

    -- Processus synchrone gérant toutes les sorties et les priorités
    process(CLK)
    begin
        if rising_edge(CLK) then

            -- 1: Gestion de s_test_ok

            if TEST_IN = '0' then
                s_test_ok <= '0';
            else
                if (s_test_ok = '1') or ((adr_in = ADR_COURANT) and (msg_in = MSG_TEST)) then
                    s_test_ok <= '1';
                else
                    s_test_ok <= '0'; 
                end if;
            end if;
            
            s_mess_out <= s_mess_out; 

            -- 2: Logique de Trame TR_OUT (Par Priorité)

            if TEST_IN = '1' then
                
                TR_OUT <= ADR_COURANT & MSG_TEST;
                s_state <= test;

            else 
                
                TR_OUT <= TRAME_DEFAUT;
                s_state <= default;
    
                if adr_in /= ADR_NON_AFFECTEE then 
                    
                    if adr_in /= ADR_COURANT then
                        TR_OUT <= TR_IN;
                        s_state <= tr_trame;

                    else 
                        if msg_in /= MSG_TEST then
                            s_mess_out <= msg_in; 
                            TR_OUT <= TRAME_DEFAUT; 
                            s_state <= tr_msg;     
                        end if;
                        
                    end if;
                    
                -- 3. Envoi de Message (ENV_MES)

                elsif ENV_MES = '1' then
                    TR_OUT <= ADR_DESTINATAIRE & MESS_IN;
                    s_state <= tr_msg;
                    
                -- 4. Déjà géré par l'assignation initiale dans le bloc 'else'

                end if;
                
            end if;
            
        end if;
    end process;
    
end architecture bhv_noeud;