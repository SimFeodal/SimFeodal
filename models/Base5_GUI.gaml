/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 * Version 5.0 (ex 4.5)
 * Run with : gama 1.7 git : commit : 9484b484f0e07981670fcab6122209292c0c3f5a
 * (Gama 1.7 git 2017-07-12 14h35h09 +0700)
 */

model t8

// L'ordre compte...
import "run.gaml"	
	
experiment Exp_5_0_A_gui type: gui until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "5_0_gui";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "experimentType" var: experimentType init: "gui";
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	/*
	 parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.12;
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 4000, 4000];
	parameter "taille_cote_monde" var: taille_cote_monde init: 80;
	*/
	
	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agregat" value: Foyers_Paysans count (each.monAgregat != nil);
		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Chatelains" value: Seigneurs count (each.type = "Chatelain");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		monitor "Sat moyenne" value: mean(Foyers_Paysans collect each.Satisfaction);
		
		display "Carte" type: "opengl" {
			species Paroisses transparency: 0.9 ;
			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
	//		text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}		
	}
}

experiment Exp_5_0_A type: batch repeat: 20 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_A";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
}

experiment Exp_5_0_A_test type: batch repeat: 20 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_A_win";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
}

experiment Exp_5_0_A_OM type: gui {
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "5_0_OM";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "experimentType" var: experimentType init: "gui";
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "summarised_outputs" var: summarised_outputs init:true;
}

experiment Exp_5_0_Test_01_06 type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_Test_01_06";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "nombre_fp_villages" var: nombre_FP_village among: [10, 9, 8, 7, 6, 5];
	// 6 experiments
}

experiment Exp_5_0_Test_07_08 type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output among: ["5_0_Test_07_08"];
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain init: 0.5 among: [0.5, 0.7];
	// 2 experiments
}

experiment Exp_5_0_Test_09_10 type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_Test_09_10";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "nombre_fp_villages" var: nombre_FP_village among: [5, 10];
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 4000, 4000];
	// 2 experiments
}

experiment Exp_5_0_Test_11_34 type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_Test_11_34";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "nombre_fp_villages" var: nombre_FP_village among: [5, 10];
	parameter "taux_augmentation_FP" var: taux_augmentation_FP among: [0.01, 0.03, 0.05, 0.1];
	parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain among: [0.2, 0.5, 0.7];
	// 2 (nombre_fp_villages) * 4 (taux_augmentation_FP) * 3(proba_ponderee_deplacement_lointain) = 24 experiments
}

experiment Exp_5_0_Base type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_Base";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "nombre_fp_villages" var: nombre_FP_village init: 10;
	// 1 experiment
}

experiment Exp_5_0_Test_35 type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_Test";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.1;
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 4000, 4000];
	// 1 experiment
}

experiment Exp_5_0_Test_36 type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_Test";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.03;
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 4000, 4000];
	parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain init: 0.7;
	// 1 experiment
}

experiment Exp_5_0_Test_MondeReduit type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output among: ["5_0_MondeReduit"];
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.12;
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 4000, 4000];
	parameter "taille_cote_monde" var: taille_cote_monde init: 80;
	// 1 experiment
}

experiment Exp_5_0_Test_MondeReduit_fix type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output among: ["5_0_MondeReduit_fix"];
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.12;
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 4000, 4000];
	parameter "taille_cote_monde" var: taille_cote_monde init: 80;
	// 1 experiment
}

experiment Exp_5_0_Test_MondeReduit_fix2 type: batch repeat: 1 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output among: ["5_0_MondeReduit_fix2"];
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.12;
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 4000, 4000];
	parameter "taille_cote_monde" var: taille_cote_monde init: 80;
	parameter "seuil_creation_paroisse" var: seuil_creation_paroisse init: 600;
	// 1 experiment
}

experiment Exp_5_0_Test_MondeReduit_fix3 type: batch repeat: 1 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output among: ["5_0_MondeReduit_fix3s"];
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.12;
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 2500, 2500];
	parameter "taille_cote_monde" var: taille_cote_monde init: 80;
	parameter "seuil_creation_paroisse" var: seuil_creation_paroisse init: 600;
	// 1 experiment
}

experiment Exp_5_0_Debug type: batch repeat: 1 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_0_Debug";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "nombre_fp_villages" var: nombre_FP_village init: 10;
	// 1 experiment
}

experiment Exp_5_1_Debug type: batch repeat: 1 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_1_Debug";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	// parameter "serfs_mobiles" var: serfs_mobiles init: true; // Serf_mobiles devient true par défaut
	// parameter "nombre_fp_villages" var: nombre_FP_village init: 10; // nombre_FP_village devient 10 par défaut
	// parameter "taille_cote_monde" var: taille_cote_monde init: 80; // taille_cote_monde devient 80 par défaut
	// parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.0; // Vaut 0 en 5.1 base
	// parameter "nombre_foyers_paysans" var: nombre_foyers_paysans init: 4000; // Le défaut ne change pas
	// parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain init: 0.2; // Vaut 0.2 par défaut : ne change pas
	// parameter "seuil_creation_paroisse" var: seuil_creation_paroisse init: 600 ; // Devient 600 par défaut
	// parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 2500, 2500]; // Devient 2,5km constant par défaut
	parameter "min_S_distance_chateau" var: min_S_distance_chateau init: 0.01; // Nouveau paramètre pour modification du calcul de S_protection, via Sdistance_chateau
	// 1 experiment
}

experiment Exp_5_1_Debug_GUI benchmark: false type: gui until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "5_1_Debug_GUI";
	//parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "experimentType" var: experimentType init: "gui";

	// parameter "serfs_mobiles" var: serfs_mobiles init: true; // Serf_mobiles devient true par défaut
	// parameter "nombre_fp_villages" var: nombre_FP_village init: 10; // nombre_FP_village devient 10 par défaut
	parameter "taille_cote_monde" var: taille_cote_monde init: 80; // taille_cote_monde devient 80 par défaut
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.0; // Vaut 0 en 5.1 base
	// parameter "nombre_foyers_paysans" var: nombre_foyers_paysans init: 4000; // Le défaut ne change pas
	parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain init: 0.2; // Vaut 0.2 par défaut : ne change pas
	// parameter "seuil_creation_paroisse" var: seuil_creation_paroisse init: 600 ; // Devient 600 par défaut
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 2500, 2500]; // Devient 2,5km constant par défaut
	parameter "min_S_distance_chateau" var: min_S_distance_chateau init: 0.01; // Nouveau paramètre pour modification du calcul de S_protection, via Sdistance_chateau
	
	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agregat" value: Foyers_Paysans count (each.monAgregat != nil);
		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Chatelains" value: Seigneurs count (each.type = "Chatelain");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		monitor "Sat moyenne" value: mean(Foyers_Paysans collect each.Satisfaction);
		
		display "Carte" type: "opengl" {
			species Paroisses transparency: 0.9 ;
			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
		}		
	}
}


experiment Exp_5_1_beta type: batch repeat: 1 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_1_beta";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	// parameter "serfs_mobiles" var: serfs_mobiles init: true; // Serf_mobiles devient true par défaut
	// parameter "nombre_fp_villages" var: nombre_FP_village init: 10; // nombre_FP_village devient 10 par défaut
	// parameter "taille_cote_monde" var: taille_cote_monde init: 80; // taille_cote_monde devient 80 par défaut
	// parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.0; // Vaut 0 en 5.1 base
	// parameter "nombre_foyers_paysans" var: nombre_foyers_paysans init: 4000; // Le défaut ne change pas
	// parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain init: 0.2; // Vaut 0.2 par défaut : ne change pas
	// parameter "seuil_creation_paroisse" var: seuil_creation_paroisse init: 600 ; // Devient 600 par défaut
	// parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 2500, 2500]; // Devient 2,5km constant par défaut
	parameter "min_S_distance_chateau" var: min_S_distance_chateau init: 0.01; // Nouveau paramètre pour modification du calcul de S_protection, via Sdistance_chateau
	// 1 experiment
}

experiment Exp_5_1_tests type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_1_Tests";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "taille_cote_monde" var: taille_cote_monde among: [80, 100]; // taille_cote_monde devient 80 par défaut
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local among: [[2500, 2500, 2500], [2500,4000,6000]]; // Devient 2,5km constant par défaut
	parameter "min_S_distance_chateau" var: min_S_distance_chateau among: [0.0, 0.01, 0.001]; // Nouveau paramètre pour modification du calcul de S_protection, via Sdistance_chateau
	// 2*2*3= 12 experiments
}

experiment Exp_5_1_PopInit type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_1_PopInit";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	//parameter "taille_cote_monde" var: taille_cote_monde init: 80; // taille_cote_monde devient 80 par défaut
	//parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 2500, 2500]; // Devient 2,5km constant par défaut
	parameter "min_S_distance_chateau" var: min_S_distance_chateau init: 0.01; // Nouveau paramètre pour modification du calcul de S_protection, via Sdistance_chateau
	parameter "nombre_foyers_paysans" var: nombre_foyers_paysans among: [10000, 15000, 20000, 25000];
}

experiment Exp_5_1_PopCroissance type: batch repeat: 2 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "5_1_PopCroissance";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	//parameter "taille_cote_monde" var: taille_cote_monde init: 80; // taille_cote_monde devient 80 par défaut
	//parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local init: [2500, 2500, 2500]; // Devient 2,5km constant par défaut
	parameter "min_S_distance_chateau" var: min_S_distance_chateau init: 0.01; // Nouveau paramètre pour modification du calcul de S_protection, via Sdistance_chateau
	parameter "taux_augmentation_FP" var: taux_augmentation_FP among: [0.01, 0.03, 0.05, 0.12];
}