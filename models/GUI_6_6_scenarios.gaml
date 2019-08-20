/**
 *  SimFeodal
 *  Author: R. Cura, C. Tannier, S. Leturcq, E. Zadora-Rio
 *  Description: https://simfeodal.github.io/
 *  Repository : https://github.com/SimFeodal/SimFeodal
 *  Version : 6.5
 *  Run with : Gama 1.8 (git) (1.7.0.201906131338)
 */

model simfeodal

import "run.gaml"	
	

experiment Exp_6_6_debug type: gui repeat: 1 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "6_6_debug";
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.5;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs init: 3;
	
	// 1 experiment
}


experiment Exp_6_6_base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios_base";
	parameter 'experimentType' var: experimentType init: "batch";
	// 1 experiment
}

experiment Exp_6_6_A type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp among: [30000, 50000];
	// 2 experiments
}

experiment Exp_6_6_B type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_fp_village' var: init_nb_fp_village among: [5, 15];
	// 2 experiments
}

experiment Exp_6_6_C type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_fp_agglo' var: init_nb_fp_agglo among: [20, 40, 100];
	// 3 experiments
}

experiment Exp_6_6_D type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo among: [0.1289, 0.1422];
	// 2 experiments
}

experiment Exp_6_6_E type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'proba_fp_dependant' var: proba_fp_dependant among: [0.0, 0.4];
	// 2 experiments
}

experiment Exp_6_6_F type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'puissance_communautes' var: puissance_communautes init: [800::0.25];
	// 1 experiment
}

experiment Exp_6_6_G type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'rayon_migration_locale_fp' var: rayon_migration_locale_fp init: [800::2500, 900::4000, 1000::6000];
	// 1 experiment
}
