/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 */

model t8

// L'ordre compte...
import "run.gaml"	
	
experiment Exp_4_5_gui type: gui until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "4_5_gui";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "experimentType" var: experimentType init: "gui";
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	
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

experiment Exp_4_5_A type: batch repeat: 10 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "4_5_A";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
}

experiment Exp_4_5_A_immobiles type: batch repeat: 10 keep_seed: false until: (Annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "4_5_A_immobiles";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "serfs_mobiles" var: serfs_mobiles init: false;
}

experiment Exp_4_5_OM type: gui {
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix' var: prefix_output init: "4_5_OM";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "experimentType" var: experimentType init: "gui";
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "summarised_outputs" var: summarised_outputs init:true;
}

experiment Exp_4_5_sensibility type: gui {
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'prefix_output' var: prefix_output init: "4_5_OM";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	parameter "experimentType" var: experimentType init: "gui";
	parameter "serfs_mobiles" var: serfs_mobiles init: true;
	parameter "summarised_outputs" var: summarised_outputs init:true;
	
	parameter "sensibility_parameter" var: sensibility_parameter;
	parameter "sensibility_value" var: sensibility_value ;
	
	parameter "apparition_chateaux" var: apparition_chateaux ;
	parameter "apparition_communautes" var: apparition_communautes ;
	parameter "coef_redevances" var: coef_redevances ;
	parameter "distance_detection_agregats" var: distance_detection_agregats ;
	parameter "distance_max_dem_local" var: distance_max_dem_local ;
	parameter "max_fourchette_loyers_PS" var: max_fourchette_loyers_PS ;
	parameter "min_fourchette_loyers_PS" var: min_fourchette_loyers_PS ;
	parameter "nb_chateaux_potentiels_GS" var: nb_chateaux_potentiels_GS ;
	parameter "nb_eglises_paroissiales" var: nb_eglises_paroissiales ;
	parameter "nb_max_paroissiens" var: nb_max_paroissiens ;
	parameter "nb_min_paroissiens" var: nb_min_paroissiens ;
	parameter "nb_paroissiens_mecontents_necessaires" var: nb_paroissiens_mecontents_necessaires ;
	parameter "nombre_agglos_antiques" var: nombre_agglos_antiques ;
	parameter "nombre_eglises" var: nombre_eglises ;
	parameter "nombre_foyers_paysans" var: nombre_foyers_paysans ;
	parameter "nombre_FP_agregat" var: nombre_FP_agregat ;
	parameter "nombre_FP_village" var: nombre_FP_village ;
	parameter "nombre_grands_seigneurs" var: nombre_grands_seigneurs ;
	parameter "nombre_petits_seigneurs" var: nombre_petits_seigneurs ;
	parameter "nombre_seigneurs_objectif" var: nombre_seigneurs_objectif ;
	parameter "nombre_villages" var: nombre_villages ;
	parameter "proba_apparition_communaute" var: proba_apparition_communaute ;
	parameter "proba_chateau_agregat" var: proba_chateau_agregat ;
	parameter "proba_collecter_loyer" var: proba_collecter_loyer ;
	parameter "proba_creation_ZP_banaux" var: proba_creation_ZP_banaux ;
	parameter "proba_creation_ZP_basseMoyenneJustice" var: proba_creation_ZP_basseMoyenneJustice ;
	parameter "proba_creer_chateau_GS" var: proba_creer_chateau_GS ;
	parameter "proba_creer_chateau_PS" var: proba_creer_chateau_PS ;
	parameter "proba_don_chateau_GS" var: proba_don_chateau_GS ;
	parameter "proba_don_partie_ZP" var: proba_don_partie_ZP ;
	parameter "proba_gain_droits_banaux_chateau" var: proba_gain_droits_banaux_chateau ;
	parameter "proba_gain_droits_basseMoyenneJustice_chateau" var: proba_gain_droits_basseMoyenneJustice_chateau ;
	parameter "proba_gain_droits_hauteJustice_chateau" var: proba_gain_droits_hauteJustice_chateau ;
	parameter "proba_ponderee_deplacement_lointain" var: proba_ponderee_deplacement_lointain ;
	parameter "proba_promotion_groschateau_autre" var: proba_promotion_groschateau_autre ;
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole ;
	parameter "puissance_communautes" var: puissance_communautes ;
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS ;
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS ;
	parameter "rayon_max_PS" var: rayon_max_PS ;
	parameter "rayon_min_PS" var: rayon_min_PS ;
	parameter "seuil_attractivite_chateau" var: seuil_attractivite_chateau ;
	parameter "seuil_creation_paroisse" var: seuil_creation_paroisse ;
	parameter "seuil_puissance_armee" var: seuil_puissance_armee ;
	parameter "taux_augmentation_FP" var: taux_augmentation_FP ;
	parameter "taux_mobilite" var: taux_mobilite ;
	parameter "taux_renouvellement" var: taux_renouvellement ;
	
}
