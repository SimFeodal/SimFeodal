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

experiment Exp_6_6_scenario_migration type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios_test";
	parameter 'experimentType' var: experimentType init: "batch";
	
		parameter 'rayon_migration_locale_fp' var: rayon_migration_locale_fp init: [800::1000];
	// 1 experiment
}

experiment Exp_6_6_scenario_droits_fonciers type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios_test";
	parameter 'experimentType' var: experimentType init: "batch";
	// 1 experiment
	
	parameter 'droits_fonciers_zp' var: droits_fonciers_zp init: 0.0;
	
}

experiment Exp_6_6_scenario_dist_minmax_eglise type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_6_Scenarios_test";
	parameter 'experimentType' var: experimentType init: "batch";
	// 1 experiment
	
	parameter 'dist_min_eglise' var: dist_min_eglise init: [800::5000];
	parameter 'dist_max_eglise' var: dist_max_eglise init: [800::25000]; 
}

