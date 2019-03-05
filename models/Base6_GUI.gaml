/**
 *  SimFeodal
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100
 * Version 6.0 (ex 5.1 après renommage)
 * Run with : gama 1.8 git : commit : a6aa46d9c
 * (Gama 1.8 git 2018-12-18)
 */

model t8

import "run.gaml"	
	
experiment Exp_6_base_FullGUI type: gui benchmark: false until: (annee >= fin_simulation){
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'prefix' var: prefix_output init: "6_0";
	
	parameter 'save_outputs' var: save_outputs init: false;

output {
		monitor "Annee" value: annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agregat" value: Foyers_Paysans count (each.monAgregat != nil);
		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.appartenance_communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Chatelains" value: Seigneurs count (each.chatelain);
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		monitor "Sat moyenne" value: mean(Foyers_Paysans collect each.satisfaction);
		
		display "Carte" type: "opengl" {
			species Paroisses transparency: 0.9 ;
			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
	//		text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}		
	    display "Foyers Paysans" {
	        chart "Déménagements" type: series position: {0,0} size: {0.5,0.5}{
	            data "Local" value: nb_demenagement_local color: #blue; 
	            data "Lointain" value: nb_demenagement_lointain color: #red;
	            data "Non" value: length(Foyers_Paysans) - (nb_demenagement_local + nb_demenagement_lointain) color: #black;
	        }
			chart "Concentration" type: series position: {0.0,0.5} size: {0.5,0.5}{
	            data "% FP dans agrégat" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100 color: #blue; 
	        }
    		chart "Satisfaction_FP" type:series position: {0.5,0} size: {0.5,1}{
    			data "Satisfaction Materielle" value: mean(Foyers_Paysans collect each.s_materielle) color: #blue;
    			data "Satisfaction Spirituelle" value: mean(Foyers_Paysans collect each.s_religieuse) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.s_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.satisfaction) color: #black;
    		}
    	}
	}
}

experiment Exp_6_0_Debug type: gui repeat: 1 keep_seed: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_0_Debug";
	// 1 experiment
}

experiment Exp_6_0_Base type: batch repeat: 2 keep_seed: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_0";
	// 1 experiment
}

experiment Exp_6_1_Debug type: gui repeat: 1 keep_seed: false benchmark: true until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter "summarised_outputs" var: summarised_outputs init: false;
	parameter 'prefix' var: prefix_output init: "6_Debug_TestGrowth";
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	parameter 'croissance_demo' var: croissance_demo init: 0.0;
	// 1 experiment

	output {
		monitor "Nombre Chateaux" value: length(Chateaux);
		display "Carte" type: "opengl" {
		species Paroisses transparency: 0.9 ;
	//	species Zones_Prelevement transparency: 0.9;
	//	agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
		species Chateaux aspect: base ;
	//			species Foyers_Paysans transparency: 0.5;
		species Agregats transparency: 0.7;
	//		text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
			}
		}	
}

experiment Exp_6_1_testGrowth type: batch repeat: 4 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter "summarised_outputs" var: summarised_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_1_testGrowth3_chateaux";
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 4000;
	// - croissance population : 1%, 3%, 5%, 12%
	parameter 'croissance_demo' var: croissance_demo among: [0.00, 0.05, 0.09, 0.112, 0.129];
	
	// Nouvelles valeurs : 
	//10E3 => 5%
	//20E3 => 9%
	//30E3 => 11.2%
	//40E3 => 12.9%
	
	// 5 experiments * 4 replications
}

experiment Exp_6_1_testPopInit type: batch repeat: 4 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter "summarised_outputs" var: summarised_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_1_testPopInit2_chateaux";
	parameter 'experimentType' var: experimentType init: "batch";
	// - sans croissance : 10E3, 15E3, 20E3, 25E3
	parameter 'init_nb_total_fp' var: init_nb_total_fp among: [4000, 10000, 15000, 20000, 25000];
	// 5 experiments * 4 replications
}


experiment Exp_6_1_Scenario_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "Exp_6_1_Scenario_Base";
	parameter 'experimentType' var: experimentType init: "batch";
	// 1 experiments * 20 replications
}

experiment Exp_6_1_Scenario_TailleVillage type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "Exp_6_1_Scenario_TailleVillage";
	parameter 'experimentType' var: experimentType init: "batch";
	// 5, 6, 7, 8 and 9
	parameter 'init_nb_fp_village' var: init_nb_fp_village among: [5, 6, 7, 8, 9];
	// 5 experiments * 20 replications
}

experiment Exp_6_1_Scenario_CroissanceDemo type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "Exp_6_1_Scenario_CroissanceDemo";
	parameter 'experimentType' var: experimentType init: "batch";
	//10E3 => 5% ;  20E3 => 9% ; 30E3 => 11.2% ; 40E3 => 12.9%
	parameter 'croissance_demo' var: croissance_demo among: [0.05, 0.09, 0.112, 0.129];
	// 4 experiments * 20 replications
}

experiment Exp_6_1_Scenario_PopInitiale type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "Exp_6_1_Scenario_PopInitiale";
	parameter 'experimentType' var: experimentType init: "batch";
	// 10E3, 20E3, 30E3, 40E3
	parameter 'init_nb_total_fp' var: init_nb_total_fp among: [10000, 20000, 30000, 40000];
	// 4 experiments * 20 replications
}

experiment Exp_6_1_Scenario_ProportionDependants type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "Exp_6_1_Scenario_ProportionDependants";
	parameter 'experimentType' var: experimentType init: "batch";
	// 0%, 40%, 60%
	parameter 'proba_fp_dependant' var: proba_fp_dependant among: [0.0, 0.4, 0.6];
	// 3 experiments * 20 replications
}

experiment Exp_6_1_Scenario_TEST type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "Exp_6_1_Scenario_TEST";
	parameter 'experimentType' var: experimentType init: "batch";
	// 0%, 40%, 60%
	parameter 'proba_fp_dependant' var: proba_fp_dependant among: [0.0, 0.4, 0.6];
	// 3 experiments * 20 replications
}
