/**
 *  SimFeodal
 *  Author: R. Cura, C. Tannier, S. Leturcq, E. Zadora-Rio
 *  Description: https://simfeodal.github.io/
 *  Repository : https://github.com/SimFeodal/SimFeodal
 *  Version : 6.3
 *  Run with : Gama 1.8 (git) (1.7.0.201903051304)
 */

model simfeodal

import "run.gaml"	
	
experiment Exp_6_3_Debug type: gui repeat: 1 keep_seed: false benchmark: true until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_3_Debug";
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	// 1 experiment
}

experiment Exp_6_3_Obj50k_1 type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_3_Obj50k";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
}
experiment Exp_6_3_Obj50k_2 type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_3_Obj50k";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 10000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0885;
}
experiment Exp_6_3_Obj50k_3 type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_3_Obj50k";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 17000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0585;
}
experiment Exp_6_3_Obj50k_4 type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_3_Obj50k";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 25000;
	parameter 'croissance_demo' var: croissance_demo init: 0.037;
}
experiment Exp_6_3_Obj50k_5 type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_3_Obj50k";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 50000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
}

experiment Exp_6_4_Debug type: gui repeat: 1 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "6_4_Debug";
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	
	parameter 'construction_chateau_alternate' var: construction_chateau_alternate init: true;
	parameter 'nb_tirages_chateaux_ps' var: nb_tirages_chateaux_ps init: 5;
	parameter 'nb_tirages_chateaux_gs' var: nb_tirages_chateaux_gs init: 2;
	// 1 experiment
}

experiment Exp_6_4_PopGrowth type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_4_chateaux";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	
	parameter 'construction_chateau_alternate' var: construction_chateau_alternate init: true;
	parameter 'nb_tirages_chateaux_ps' var: nb_tirages_chateaux_ps among: [1,3,5,7,10];
	parameter 'nb_tirages_chateaux_gs' var: nb_tirages_chateaux_gs among: [1,2,5];
	// 1 experiment
}

experiment Exp_6_4_PopInit type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_4_chateaux";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 50000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	
	parameter 'construction_chateau_alternate' var: construction_chateau_alternate init: true;
	parameter 'nb_tirages_chateaux_ps' var: nb_tirages_chateaux_ps among: [1,3,5,7,10];
	parameter 'nb_tirages_chateaux_gs' var: nb_tirages_chateaux_gs among: [1,2,5];
	// 1 experiment
}

experiment Exp_6_4_1_debug type: gui repeat: 1 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "6_4_1_debug";
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 50000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	parameter "nb_max_chateaux_par_tour_gs" var: nb_max_chateaux_par_tour_gs init: 2;
	
	// 1 experiment
}


experiment Exp_6_4_1_PopGrowth type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_4_1";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	
	parameter "nb_max_chateaux_par_tour_gs" var: nb_max_chateaux_par_tour_gs among: [2, 3];
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps among: [0.6, 0.7, 0.8];
	// 6 experiment
}

experiment Exp_6_4_1_PopInit type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_4_1";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 50000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	
	parameter "nb_max_chateaux_par_tour_gs" var: nb_max_chateaux_par_tour_gs among: [2, 3];
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps among: [0.6, 0.7, 0.8];
	// 6 experiment
}


experiment Exp_6_4_2_debug type: gui repeat: 1 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "6_4_2_debug";
	parameter 'experimentType' var: experimentType init: "gui";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.8;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs among: [1,2,3,4,5];
	
	// 1 experiment
}


experiment Exp_6_4_2_PopGrowth type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_4_2";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.8;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs init: 2;
	// 5 experiments
}

experiment Exp_6_4_2_PopGrowth_fix type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_4_2";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.8;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs among: [1,3,4,5];
	// 5 experiments
}


experiment Exp_6_4_2_PopInit type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_4_2";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 50000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.8;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs among: [1,2,3,4,5];
	// 5 experiments
}

