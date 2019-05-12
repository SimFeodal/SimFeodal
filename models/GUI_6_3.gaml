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
