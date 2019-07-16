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
	

experiment Exp_6_5_debug type: gui repeat: 1 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "6_5_debug";
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.5;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs init: 3;
	
	// 1 experiment
}


experiment Exp_6_5_Obj40k_Stable type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.5 ;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs init: 3;
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 40000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	// 1 experiments
}

experiment Exp_6_5_Obj40k_Triple type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.5 ;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs init: 3;
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 13500;
	parameter 'croissance_demo' var: croissance_demo init: 0.0589;
	// 1 experiments
}

experiment Exp_6_5_Obj40k_Decuple type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.5 ;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs init: 3;
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1289;
	// 1 experiments
}

experiment Exp_6_5_Obj50k_Triple type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps init: 0.5 ;
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs init: 3;
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 17000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0585;
	// 1 experiments
}

experiment Exp_6_5_1_Obj50k_Stable type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5_1";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 50000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	// 1 experiments
}

experiment Exp_6_5_1_Obj50k_Decuple type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5_1";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	// 1 experiments
}

experiment Exp_6_5_1_RayonLocal_40k_Stable type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5_1";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 40000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	
	parameter 'rayon_migration_locale_fp' var: rayon_migration_locale_fp init: [800::2500,900::4000,1000::6000];
	// 1 experiments
}

experiment Exp_6_5_1_RayonLocal_40k_Decuple type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5_1";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1289;
	
	parameter 'rayon_migration_locale_fp' var: rayon_migration_locale_fp init: [800::2500,900::4000,1000::6000];
	// 1 experiments
}

experiment Exp_6_5_1_RayonLocal_50k_Stable type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5_1";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 50000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	
	parameter 'rayon_migration_locale_fp' var: rayon_migration_locale_fp init: [800::2500,900::4000,1000::6000];
	// 1 experiments
}

experiment Exp_6_5_1_RayonLocal_50k_Decuple type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_5_1";
	parameter 'experimentType' var: experimentType init: "batch";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.1422;
	
	parameter 'rayon_migration_locale_fp' var: rayon_migration_locale_fp init: [800::2500,900::4000,1000::6000];
	// 1 experiments
}
