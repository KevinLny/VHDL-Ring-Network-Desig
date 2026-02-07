library ieee;
use ieee.std_logic_1164.all;

package package_noeud is
    -- Définition du type énuméré pour l'état du nœud
    type NODE_STATE is (default, test, tr_trame, tr_msg);
    -- Type pour un vecteur d'adresse 4 bits
    subtype ADR_4BIT is std_logic_vector(3 downto 0); 
    -- Type pour la matrice 4x4 des adresses (Indices 0 à 3)
    type ADR_MATRIX_4x4 is array (0 to 3, 0 to 3) of ADR_4BIT;
end package package_noeud;