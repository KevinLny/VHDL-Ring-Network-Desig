# =================================================================
# Fichier: tb_reseau.do
# Description: Compile, simule, et configure les signaux pour
#              l'entité TB_RESEAU, en ajoutant les trames internes.
# =================================================================

# 1. Préparation de la simulation
quit -sim              
vlib work              
vmap work work         

# 2. Compilation des fichiers VHDL
# IMPORTANT : Compiler dans l'ordre de dépendance
# (Package -> Composant le plus bas -> Composant le plus haut -> Testbench)
vcom Projet_pck.vhd
vcom NODE.vhd
vcom RESEAU.vhd
vcom tb_RESEAU.vhd

# 3. Lancement de la simulation
vsim -c work.tb_reseau -voptargs=+acc

log -r *

# 4. Configuration de la fenêtre des ondes

# Supprime les signaux par défaut
delete wave -all

# Ajoute les signaux d'entrée/sortie du Test Bench (TB_RESEAU)
add wave /tb_reseau/clk_s
add wave /tb_reseau/test_in1_s /tb_reseau/env_mes1_s /tb_reseau/mess_in1_s
add wave /tb_reseau/test_ok1_s /tb_reseau/mess_out1_s
add wave /tb_reseau/test_ok2_s /tb_reseau/mess_out2_s

# 5. Lancement de la simulation
# Simule pour le temps total nécessaire (ici 5 + 15 + 5 + 10 + 5 + 15 = 50 cycles)
run 500ns 

# Ajuste le zoom pour voir tout le tracé
wave zoom full