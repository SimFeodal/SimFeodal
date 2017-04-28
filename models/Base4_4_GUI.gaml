/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 */

model t8

// L'ordre compte...
import "run.gaml"	
	
experiment Exp_4_4_gui type: gui {
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "4_4_gui";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	
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
		
		display "Carte" {
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

experiment Exp_4_4_A type: batch repeat: 20 keep_seed: true until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "4_4_A";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
}

experiment Exp_4_4_B type: batch repeat: 20 keep_seed: true until: (Annee >= fin_simulation){
	//   - Modification du paramètre nombre\_FP\_village entre 5 et 9. Autres paramètres inchangés. : 5 * 20 rep
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "4_4_B";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	
	parameter "nombre_FP_village" var: nombre_FP_village among: [5, 6, 7, 8, 9];
}

experiment Exp_4_4_C type: batch repeat: 20 keep_seed: true until: (Annee >= fin_simulation){
	// rayon de la distance de déplacement local au cours du temps :
	// 		2,5km entre 800 et 880 ; puis 4km entre 900 et 980 ; puis 4km à partir de 1000
	// + nombre\_FP\_village égale à 5 et à 10.
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "4_4_C";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	
	parameter "nombre_FP_village" var: nombre_FP_village among: [5, 10];
	parameter "seuils_distance_max_dem_local" var: seuils_distance_max_dem_local among: [[2500, 4000, 4000]];
}

experiment Exp_4_4_D type: batch repeat: 20 keep_seed: true until: (Annee >= fin_simulation){
	// 0,06% croissance nb FP
	// p_depl_lointain avec paramètre à 0,2 (valeur par défaut), 0,5 et 0,7
	// nombre\_FP\_village égale à 5 et à 10. :
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "4_4_D";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	
	parameter "nombre_FP_village" var: nombre_FP_village among: [5, 10];
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.06;
	parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain among: [0.2, 0.5, 0.7];
}

experiment Exp_4_4_E type: batch repeat: 20 keep_seed: true until: (Annee >= fin_simulation){
	// 0,22% croissance nb FP
	// p_depl_lointain avec paramètre à 0,2 (valeur par défaut), 0,5 et 0,7
	// nombre\_FP\_village égale à 5 et à 10. :
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "4_4_E";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	
	parameter "nombre_FP_village" var: nombre_FP_village among: [5, 10];
	parameter "taux_augmentation_FP" var: taux_augmentation_FP init: 0.22;
	parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain among: [0.2, 0.5, 0.7];
}


