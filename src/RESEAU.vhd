library ieee;
use ieee.std_logic_1164.all;
use work.package_noeud.all;

entity RESEAU is
    generic (
        N : integer range 2 to 4 := 3 -- N paramétrable (1<N<5). ICI N=3
    );
    port (
        CLK        : in  std_logic;

        -- Nœud 1 (Haut à Gauche)
        Test_in1   : in  std_logic;
        Env_mes1   : in  std_logic;
        Mess_in1   : in  std_logic_vector(3 downto 0);
        Test_ok1   : out std_logic;
        Mess_out1  : out std_logic_vector(3 downto 0);

        -- Nœud 2 (Bas à Droite)
        Test_in2   : in  std_logic;
        Env_mes2   : in  std_logic;
        Mess_in2   : in  std_logic_vector(3 downto 0);
        Test_ok2   : out std_logic;
        Mess_out2  : out std_logic_vector(3 downto 0)
    );
end entity RESEAU;

architecture Structurel of RESEAU is
    
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
            
            TEST_OK    : out std_logic;
            MESS_OUT   : out std_logic_vector(3 downto 0);
            TR_OUT     : out std_logic_vector(7 downto 0);
            STATE_NODE : out NODE_STATE
        );
    end component;

    -- Nombre total de nœuds
    constant M : integer := N * N;
    
    type TR_ARRAY is array (0 to M-1) of std_logic_vector(7 downto 0);
    signal s_trame : TR_ARRAY;
    
    type STATE_ARRAY is array (0 to M-1) of NODE_STATE;
    type STD_LOGIC_ARRAY is array (0 to M-1) of std_logic;
    type MESS_ARRAY is array (0 to M-1) of std_logic_vector(3 downto 0);

    signal s_test_in   : STD_LOGIC_ARRAY;
    signal s_env_mes   : STD_LOGIC_ARRAY;
    signal s_mess_in   : MESS_ARRAY;
    signal s_test_ok   : STD_LOGIC_ARRAY;
    signal s_mess_out  : MESS_ARRAY;
    signal s_state : STATE_ARRAY;
    
    -- Matrice de constante pour la question 4
    constant MATRICE_ADR_COUR : ADR_MATRIX_4x4 := (
    (0 => "0000", 1 => "0001", 2 => "0011", 3 => "0100"),
    (0 => "1100", 1 => "0010", 2 => "0100", 3 => "0101"),
    (0 => "1011", 1 => "0110", 2 => "0101", 3 => "0110"),
    (0 => "1010", 1 => "1001", 2 => "1000", 3 => "0111")
);
    
begin
    
    -- 1. Connexions des I/O externes aux nœuds correspondants
    
    -- Nœud 0 (Haut à gauche)
    s_test_in(0) <= Test_in1;
    s_env_mes(0) <= Env_mes1;
    s_mess_in(0) <= Mess_in1;
    Test_ok1     <= s_test_ok(0);
    Mess_out1    <= s_mess_out(0);
    
    -- Nœud M-1 (Bas à droite)
    s_test_in(M-1) <= Test_in2;
    s_env_mes(M-1) <= Env_mes2;
    s_mess_in(M-1) <= Mess_in2;
    Test_ok2       <= s_test_ok(M-1);
    Mess_out2      <= s_mess_out(M-1);

    -- 2. Initialisation des ports internes non connectés
    
    GEN_INTERMEDIAIRES: for I in 1 to M-2 generate
    begin
        s_test_in(I) <= '0';
        s_env_mes(I) <= '0';
        s_mess_in(I) <= (others => '0');
    end generate GEN_INTERMEDIAIRES;
    
    -- 3. Instanciation des nœuds et formation de l'anneau

GEN_NOEUDS: for I in 0 to M-1 generate

    constant I_COORD : integer := I / N;
    constant J_COORD : integer := I mod N;
    
    constant I_DEST : integer := N - 1 - I_COORD;
    constant J_DEST : integer := N - 1 - J_COORD;
    
    constant ADR_COUR_NODE : std_logic_vector(3 downto 0) := MATRICE_ADR_COUR(I_COORD, J_COORD);
    constant ADR_DEST_NODE : std_logic_vector(3 downto 0) := MATRICE_ADR_COUR(I_DEST, J_DEST);

    begin
    NOEUD_INST : NOEUD 
    generic map (
        ADR_COURANT      => ADR_COUR_NODE, 
        ADR_DESTINATAIRE => ADR_DEST_NODE 
    )
        port map (
            CLK        => CLK,
            TEST_IN    => s_test_in(I),
            ENV_MES    => s_env_mes(I),
            MESS_IN    => s_mess_in(I),
            TR_IN      => s_trame(I),
            
            TEST_OK    => s_test_ok(I),
            MESS_OUT   => s_mess_out(I),
            TR_OUT     => s_trame((I + 1) mod M),
            STATE_NODE  => s_state(I)
        );
    end generate GEN_NOEUDS;
    
end architecture Structurel;