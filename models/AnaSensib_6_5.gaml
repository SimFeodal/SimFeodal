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

experiment AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until:  (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: false;
	parameter 'experimentType' var: experimentType init: "batch";
	parameter 'prefix_output' var: prefix_output init: "base";
	
	parameter 'init_nb_total_fp' var: init_nb_total_fp init: 40000;
	
	parameter 'sensibility_parameter' var: sensibility_parameter init: "nb_tirages_chateaux_gs";

	reflex save_sensibility_outputs {
		ask simulations {
			int nb_chateaux <- length(Chateaux);
			int nb_grands_chateaux <- Chateaux count (each.type = "Grand Chateau");
			int nb_eglises <- length(Eglises);
			int nb_eglises_paroissiales <-  Eglises count (each.eglise_paroissiale);
			int nb_agregats <- length(Agregats);
			int nb_fp <- length(Foyers_Paysans);
			
			list<float> distances_pp_eglise <- [];
			ask Eglises {
				Eglises pp_eglise <- Eglises closest_to self;
				if (pp_eglise != nil){
				float distEglise <- self distance_to pp_eglise;
				distances_pp_eglise <+ distEglise;
				}
			}
			int distance_eglises_sensib <- mean(distances_pp_eglise);
			
			list<float> distances_pp_paroisses <- [];
			list<Eglises> eglises_paroissiales <- Eglises where (each.eglise_paroissiale);
			ask eglises_paroissiales{
				Eglises pp_eglise <- (eglises_paroissiales - self) closest_to self;
				if (pp_eglise != nil){
				float distEglise <- self distance_to pp_eglise;
				distances_pp_paroisses <+ distEglise;
				}
			}
			int distance_eglises_paroissiales_sensib <- mean(distances_pp_paroisses);
			
			float prop_fp_isoles_sensib <- Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans);
			float ratio_charge_fiscale_sensib <- mean(Foyers_Paysans collect float(each.redevances_acquittees)) / max(charge_fiscale_debut, 1);
			
			string seed_sensib <- world.enquote(seed);
			string sim_name <- "6_5_1_SensibAna";
			set sensibility_value <- world.enquote(string(eval_gaml(sensibility_parameter)));
			string annee_sensib <- world.enquote(annee);

			save [
					seed_sensib, sim_name, annee_sensib,
					nb_fp, nb_agregats,
					nb_chateaux, nb_grands_chateaux,
					nb_eglises, nb_eglises_paroissiales,
					distance_eglises_sensib, distance_eglises_paroissiales_sensib,
					prop_fp_isoles_sensib, ratio_charge_fiscale_sensib,
					sensibility_parameter,sensibility_value
				] to: ("/home/robin/analyse_sensibilite_" + prefix_output +".csv") type: "csv" header: true rewrite: false;
			do die;
		}
	}
}
	
// TEST
experiment AnaSensi_TiragesChateaux parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "nb_tirages_chateaux_gs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "nb_tirages_chateaux_gs";
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs among: [1,2,3,4,5];
}


///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//////////////////////     INPUTS     /////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

////
//// 10 paramètres * 5 valeurs * 20 réplications = 1000 simulations
////

experiment AnaSensi_Inputs_taille parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "taille_cote_monde";
	parameter "taille_cote_monde" var: taille_cote_monde among: [50, 75, 100, 125, 150];
}

experiment AnaSensi_Inputs_init_nb_total_fp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_total_fp";
	parameter "init_nb_total_fp" var: init_nb_total_fp among: [10000, 25000, 40000, 55000, 70000];
}

experiment AnaSensi_Inputs_init_nb_agglos parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_agglos";
	parameter "init_nb_agglos" var: init_nb_agglos among: [2, 5, 8, 10, 15];
}

experiment AnaSensi_Inputs_init_nb_fp_agglo parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_fp_agglo";
	parameter "init_nb_fp_agglo" var: init_nb_fp_agglo among: [10, 20, 30, 40, 50];
}

experiment AnaSensi_Inputs_init_nb_villages parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_villages";
	parameter "init_nb_villages" var: init_nb_villages among: [5, 10, 20, 30, 50];
}

experiment AnaSensi_Inputs_init_nb_fp_village parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_fp_village";
	parameter "init_nb_fp_village" var: init_nb_fp_village among: [5, 10, 15, 20, 25];
}

experiment AnaSensi_Inputs_puissance_grand_seigneur1 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "puissance_grand_seigneur1";
	parameter "puissance_grand_seigneur1" var: puissance_grand_seigneur1 among: [0.1, 0.2, 0.3, 0.4, 0.5];
}

experiment AnaSensi_Inputs_init_nb_ps parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_ps";
	parameter "init_nb_ps" var: init_nb_ps among: [5, 10, 15, 20, 25];
}

experiment AnaSensi_Inputs_init_nb_eglises parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_eglises";
	parameter "init_nb_eglises" var: init_nb_eglises among: [50,100,150,200,250];
}

experiment AnaSensi_Inputs_init_nb_eglises_paroissiales parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation) {
	parameter 'prefix_output' var: prefix_output init: "inputs";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "init_nb_eglises_paroissiales";
	parameter "init_nb_eglises_paroissiales" var: init_nb_eglises_paroissiales among: [10, 30, 50, 70, 90];
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//////////////////////     CONTEXTE     ///////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

////
//// 12 paramètres * 5 valeurs * 20 réplications = 1200 simulations
////

experiment AnaSensi_Contexte_taux_renouvellement_fp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "taux_renouvellement_fp";
	parameter "taux_renouvellement_fp" var: taux_renouvellement_fp among: [0, 0.025, 0.05, 0.075, 0.1];
}

experiment AnaSensi_Contexte_proba_fp_dependant parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_fp_dependant";
	parameter "proba_fp_dependant" var: proba_fp_dependant among: [0, 0.1, 0.2, 0.35, 0.5];
}

experiment AnaSensi_Contexte_besoin_protection_fp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "besoin_protection_fp";
	// BASE : [800::0.0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0]
	parameter "besoin_protection_fp" var: besoin_protection_fp among: [
		[800::0.0],
		[800::1.0],
		[800::0.0,1000::1.0],
		[800::0.5,1000::1.0],
		[800::0.0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0]
	];
}

experiment AnaSensi_Contexte_puissance_communaute parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "puissance_communautes";
	// BASE : [800::0.2,1060::0.3,1100::0.4,1160::0.5]
	parameter "puissance_communautes" var: puissance_communautes among: [
		[800::0.0],
		[800::0.5],
		[800::0.0, 1040::0.5],
		[800::0.5, 1040::1.0],
		[800::0.2, 1060::0.3,1100::0.4, 1160::0.5]
	];
}

experiment AnaSensi_Contexte_proba_institution_communaute parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_institution_communaute";
	parameter "proba_institution_communaute" var: proba_institution_communaute among: [0, 0.1, 0.2, 0.35, 0.5];
}

experiment AnaSensi_Contexte_objectif_nombre_seigneurs parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "objectif_nombre_seigneurs";
	parameter "objectif_nombre_seigneurs" var: objectif_nombre_seigneurs among: [100, 150, 200, 250, 300];
}

experiment AnaSensi_Contexte_proba_gain_haute_justice_gs parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_gain_haute_justice_gs";
	// BASE : [800::0.0,900::0.2,1000::1.0]
	parameter "proba_gain_haute_justice_gs" var: proba_gain_haute_justice_gs among: [
		[800::0.0],
		[800::1.0],
		[800::0.0, 900::0.2, 1000::1.0],
		[800::0.0, 900::0.1, 920::0.2, 940::0.3, 960::0.4, 980::0.5, 1000::0.6, 1020::0.7, 1040::0.8, 1060::0.8, 1080::0.9, 1100::1.0],
		[800::0.0, 1000::0.5]
	];
}

experiment AnaSensi_Contexte_proba_gain_haute_justice_chateau_ps parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_gain_haute_justice_chateau_ps";
	// BASE : [800::0.0, 1000::0.2]
	parameter "proba_gain_haute_justice_chateau_ps" var: proba_gain_haute_justice_chateau_ps among: [
		[800::0.0],
		[800::0.2],
		[800::0.0, 1000::0.5],
		[800::0.5],
		[800::0.0, 1000::0.2]
	];
}

experiment AnaSensi_Contexte_debut_cession_droits_seigneurs parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "debut_cession_droits_seigneurs";
	parameter "debut_cession_droits_seigneurs" var: debut_cession_droits_seigneurs among: [820, 860, 880, 920, 1000];
}

experiment AnaSensi_Contexte_debut_garde_chateaux_seigneurs parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "debut_garde_chateaux_seigneurs";
	parameter "debut_garde_chateaux_seigneurs" var: debut_garde_chateaux_seigneurs among: [940, 1000, 1060, 1120, 1200];
}

experiment AnaSensi_Contexte_debut_construction_chateaux parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "debut_construction_chateaux";
	parameter "debut_construction_chateaux" var: debut_construction_chateaux among: [820, 880, 940, 1000, 1060];
}

experiment AnaSensi_Contexte_periode_promotion_chateaux parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "contexte";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "periode_promotion_chateaux";
	// BASE : [800::false,940::true,1060::false]
	parameter "periode_promotion_chateaux" var: periode_promotion_chateaux among: [
		[800::false,940::true,1060::false],
		[800::false,940::true],
		[800::false,1100::true],
		[800::false,1000::true,1120::false],
		[800::false,940::true,1020::false]
	];
}


///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////////////     MÉCANISMES (FACILE)    //////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

////
//// 17 paramètres * 5 valeurs * 20 réplications = 1700 simulations
////

experiment AnaSensi_Meca_rayon_migration_locale_fp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_migration_locale_fp";
	parameter "rayon_migration_locale_fp" var: rayon_migration_locale_fp among: [
		[800::1000],
		[800::2500, 1000::5000],
		[800::2500],
		[800::5000, 1000::10000],
		[800::1000, 1000::2500]
	];
}

experiment AnaSensi_Meca_prop_migration_lointaine_fp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "prop_migration_lointaine_fp";
	parameter "prop_migration_lointaine_fp" var: prop_migration_lointaine_fp among: [0.0, 0.1, 0.2, 0.35, 0.5];
}

experiment AnaSensi_Meca_nb_min_fp_agregat parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "nb_min_fp_agregat";
	parameter "nb_min_fp_agregat" var: nb_min_fp_agregat among: [3, 5, 7, 10, 15];
}

experiment AnaSensi_Meca_distance_detection_agregat parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "distance_detection_agregat";
	parameter "distance_detection_agregat" var: distance_detection_agregat among: [50, 100, 150, 200, 500];
}

experiment AnaSensi_Meca_distance_detection_agregat_fix parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1_fix";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "distance_detection_agregat";
	parameter "distance_detection_agregat" var: distance_detection_agregat init: 300;
}

experiment AnaSensi_Meca_proba_construction_chateau_ps parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_construction_chateau_ps";
	parameter "proba_construction_chateau_ps" var: proba_construction_chateau_ps among: [0.0, 0.25, 0.5, 0.75, 1.0];
}

experiment AnaSensi_Meca_proba_collecter_foncier_ps parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_collecter_foncier_ps";
	parameter "proba_collecter_foncier_ps" var: proba_collecter_foncier_ps among: [0.0, 0.05, 0.1, 0.25, 0.5];
}

experiment AnaSensi_Meca_proba_creation_zp_autres_droits_ps parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_creation_zp_autres_droits_ps";
	parameter "proba_creation_zp_autres_droits_ps" var: proba_creation_zp_autres_droits_ps among: [0.0, 0.05, 0.15, 0.25, 0.35];
}

experiment AnaSensi_Meca_taux_prelevement_zp_chateau parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "taux_prelevement_zp_chateau";
	parameter "taux_prelevement_zp_chateau" var: taux_prelevement_zp_chateau among: [0.0, 0.25, 0.5, 0.75, 1.0];
}

experiment AnaSensi_Meca_proba_cession_droits_zp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_cession_droits_zp";
	parameter "proba_cession_droits_zp" var: proba_cession_droits_zp among: [0.0, 0.15, 0.33, 0.5, 0.75];
}

experiment AnaSensi_Meca_rayon_voisinage_ps parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_voisinage_ps";
	parameter "rayon_voisinage_ps" var: rayon_voisinage_ps among: [1000, 2500, 5000, 7500, 10000];
}

experiment AnaSensi_Meca_proba_cession_locale parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_cession_locale";
	parameter "proba_cession_locale" var: proba_cession_locale among: [0.0, 0.25, 0.5, 0.75, 1.0];
}

experiment AnaSensi_Meca_proba_don_chateau parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_don_chateau";
	parameter "proba_don_chateau" var: proba_don_chateau among: [0.0, 0.25, 0.5, 0.75, 1.0];
}

experiment AnaSensi_Meca_dist_min_entre_chateaux parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_min_entre_chateaux";
	parameter "dist_min_entre_chateaux" var: dist_min_entre_chateaux among: [0, 1500, 3000, 5000, 7500];
}

experiment AnaSensi_Meca_proba_chateau_agregat parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_chateau_agregat";
	parameter "proba_chateau_agregat" var: proba_chateau_agregat among: [0.0, 0.25, 0.5, 0.75, 1.0];
}

experiment AnaSensi_Meca_proba_promotion_chateau_pole parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "proba_promotion_chateau_pole";
	parameter "proba_promotion_chateau_pole" var: proba_promotion_chateau_pole among: [0.0, 0.25, 0.5, 0.75, 1.0];
}

experiment AnaSensi_Meca_ponderation_creation_paroisse_agregat parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "ponderation_creation_paroisse_agregat";
	parameter "ponderation_creation_paroisse_agregat" var: ponderation_creation_paroisse_agregat among: [500, 1000, 2000, 3000, 5000];
}

experiment AnaSensi_Meca_seuil_nb_paroissiens_insatisfaits parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme1";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "seuil_nb_paroissiens_insatisfaits";
	parameter "seuil_nb_paroissiens_insatisfaits" var: seuil_nb_paroissiens_insatisfaits among: [5, 10, 20, 30, 50];
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////     MÉCANISMES (DIFFICILES)    ////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

////
//// 6 paramètres * 5 valeurs * 20 réplications = 600 simulations
////

experiment AnaSensi_Meca_dist_minmax_eglise_1 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_eglise";
	parameter 'dist_minmax_eglise' var: dist_minmax_eglise init: "base"; 
	
	parameter "dist_min_eglise" var: dist_min_eglise init: [800::5000, 960::3000, 1060::1500];
	parameter "dist_max_eglise" var: dist_max_eglise init: [800::25000, 960::10000, 1060::5000];
}
experiment AnaSensi_Meca_dist_minmax_eglise_2 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_eglise";
	parameter 'dist_minmax_eglise' var: dist_minmax_eglise init: "statique_large"; 
	
	parameter "dist_min_eglise" var: dist_min_eglise init: [800::5000];
	parameter "dist_max_eglise" var: dist_max_eglise init: [800::25000];
}
experiment AnaSensi_Meca_dist_minmax_eglise_3 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_eglise";
	parameter 'dist_minmax_eglise' var: dist_minmax_eglise init: "dynamique_reduit"; 
	
	parameter "dist_min_eglise" var: dist_min_eglise init: [800::1500, 960::1000, 1060::500];
	parameter "dist_max_eglise" var: dist_max_eglise init: [800::5000, 960::3000, 1060::1500];
}
experiment AnaSensi_Meca_dist_minmax_eglise_4 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_eglise";
	parameter 'dist_minmax_eglise' var: dist_minmax_eglise init: "dynamique_large"; 
	
	parameter "dist_min_eglise" var: dist_min_eglise init: [800::25000, 960::10000, 1060::5000];
	parameter "dist_max_eglise" var: dist_max_eglise init: [800::50000, 960::25000, 1060::10000];
}
experiment AnaSensi_Meca_dist_minmax_eglise_5 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_eglise";
	parameter 'dist_minmax_eglise' var: dist_minmax_eglise init: "statique_reduit"; 
	
	parameter "dist_min_eglise" var: dist_min_eglise init: [800::1500];
	parameter "dist_max_eglise" var: dist_max_eglise init: [800::5000];
}


experiment AnaSensi_Meca_dist_minmax_chateau_1 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_chateau";
	parameter "dist_minmax_chateau" var: dist_minmax_chateau init: "base";
	
	parameter "dist_min_chateau" var: dist_min_chateau init: 1500;
	parameter "dist_max_chateau" var: dist_max_chateau init: 5000;
}
experiment AnaSensi_Meca_dist_minmax_chateau_2 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_chateau";
	parameter "dist_minmax_chateau" var: dist_minmax_chateau init: "deplacement_negatif";
	
	parameter "dist_min_chateau" var: dist_min_chateau init: 500;
	parameter "dist_max_chateau" var: dist_max_chateau init: 4000;
}
experiment AnaSensi_Meca_dist_minmax_chateau_3 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_chateau";
	parameter "dist_minmax_chateau" var: dist_minmax_chateau init: "deplacement_positif";
	
	parameter "dist_min_chateau" var: dist_min_chateau init: 5000;
	parameter "dist_max_chateau" var: dist_max_chateau init: 8500;
}
experiment AnaSensi_Meca_dist_minmax_chateau_4 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_chateau";
	parameter "dist_minmax_chateau" var: dist_minmax_chateau init: "reduction_max";
	
	parameter "dist_min_chateau" var: dist_min_chateau init: 1500;
	parameter "dist_max_chateau" var: dist_max_chateau init: 3000;
}
experiment AnaSensi_Meca_dist_minmax_chateau_5 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "dist_minmax_chateau";
	parameter "dist_minmax_chateau" var: dist_minmax_chateau init: "augmentation_min";
	
	parameter "dist_min_chateau" var: dist_min_chateau init: 3000;
	parameter "dist_max_chateau" var: dist_max_chateau init: 5000;
}


experiment AnaSensi_Meca_rayon_minmax_zp_ps_1 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_ps";
	parameter "rayon_minmax_zp_ps" var: rayon_minmax_zp_ps init: "base";
	
	parameter "rayon_min_zp_ps" var: rayon_min_zp_ps init: 1000;
	parameter "rayon_max_zp_ps" var: rayon_max_zp_ps init: 5000;
}
experiment AnaSensi_Meca_rayon_minmax_zp_ps_2 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_ps";
	parameter "rayon_minmax_zp_ps" var: rayon_minmax_zp_ps init: "deplacement_negatif";
	
	parameter "rayon_min_zp_ps" var: rayon_min_zp_ps init: 500;
	parameter "rayon_max_zp_ps" var: rayon_max_zp_ps init: 4500;
}
experiment AnaSensi_Meca_rayon_minmax_zp_ps_3 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_ps";
	parameter "rayon_minmax_zp_ps" var: rayon_minmax_zp_ps init: "deplacement_positif";
	
	parameter "rayon_min_zp_ps" var: rayon_min_zp_ps init: 5000;
	parameter "rayon_max_zp_ps" var: rayon_max_zp_ps init: 9000;
}
experiment AnaSensi_Meca_rayon_minmax_zp_ps_4 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_ps";
	parameter "rayon_minmax_zp_ps" var: rayon_minmax_zp_ps init: "reduction_max";
	
	parameter "rayon_min_zp_ps" var: rayon_min_zp_ps init: 1000;
	parameter "rayon_max_zp_ps" var: rayon_max_zp_ps init: 3000;
}
experiment AnaSensi_Meca_rayon_minmax_zp_ps_5 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_ps";
	parameter "rayon_minmax_zp_ps" var: rayon_minmax_zp_ps init: "augmentation_min";
	
	parameter "rayon_min_zp_ps" var: rayon_min_zp_ps init: 3000;
	parameter "rayon_max_zp_ps" var: rayon_max_zp_ps init: 5000;
}


experiment AnaSensi_Meca_minmax_taux_prelevement_zp_ps_1 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "minmax_taux_prelevement_zp_ps";
	parameter "minmax_taux_prelevement_zp_ps" var: minmax_taux_prelevement_zp_ps init: "base";
	
	parameter "min_taux_prelevement_zp_ps" var: min_taux_prelevement_zp_ps init: 0.05;
	parameter "max_taux_prelevement_zp_ps" var: max_taux_prelevement_zp_ps init: 0.25;
}
experiment AnaSensi_Meca_minmax_taux_prelevement_zp_ps_2 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "minmax_taux_prelevement_zp_ps";
	parameter "minmax_taux_prelevement_zp_ps" var: minmax_taux_prelevement_zp_ps init: "deplacement_negatif";
	
	parameter "min_taux_prelevement_zp_ps" var: min_taux_prelevement_zp_ps init: 0.0;
	parameter "max_taux_prelevement_zp_ps" var: max_taux_prelevement_zp_ps init: 0.2;
}
experiment AnaSensi_Meca_minmax_taux_prelevement_zp_ps_3 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "minmax_taux_prelevement_zp_ps";
	parameter "minmax_taux_prelevement_zp_ps" var: minmax_taux_prelevement_zp_ps init: "deplacement_positif";
	
	parameter "min_taux_prelevement_zp_ps" var: min_taux_prelevement_zp_ps init: 0.25;
	parameter "max_taux_prelevement_zp_ps" var: max_taux_prelevement_zp_ps init: 0.5;
}
experiment AnaSensi_Meca_minmax_taux_prelevement_zp_ps_4 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "minmax_taux_prelevement_zp_ps";
	parameter "minmax_taux_prelevement_zp_ps" var: minmax_taux_prelevement_zp_ps init: "reduction_max";
	
	parameter "min_taux_prelevement_zp_ps" var: min_taux_prelevement_zp_ps init: 0.05;
	parameter "max_taux_prelevement_zp_ps" var: max_taux_prelevement_zp_ps init: 0.15;
}
experiment AnaSensi_Meca_minmax_taux_prelevement_zp_ps_5 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "minmax_taux_prelevement_zp_ps";
	parameter "minmax_taux_prelevement_zp_ps" var: minmax_taux_prelevement_zp_ps init: "augmentation_min";
	
	parameter "min_taux_prelevement_zp_ps" var: min_taux_prelevement_zp_ps init: 0.15;
	parameter "max_taux_prelevement_zp_ps" var: max_taux_prelevement_zp_ps init: 0.25;
}


experiment AnaSensi_Meca_rayon_minmax_zp_chateau_1 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_chateau";
	parameter "rayon_minmax_zp_chateau" var: rayon_minmax_zp_chateau init: "base";
	
	parameter "rayon_min_zp_chateau" var: rayon_min_zp_chateau init: 2000;
	parameter "rayon_max_zp_chateau" var: rayon_max_zp_chateau init: 15000;
}
experiment AnaSensi_Meca_rayon_minmax_zp_chateau_2 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_chateau";
	parameter "rayon_minmax_zp_chateau" var: rayon_minmax_zp_chateau init: "deplacement_negatif";
	
	parameter "rayon_min_zp_chateau" var: rayon_min_zp_chateau init: 500;
	parameter "rayon_max_zp_chateau" var: rayon_max_zp_chateau init: 10000;
}
experiment AnaSensi_Meca_rayon_minmax_zp_chateau_3 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_chateau";
	parameter "rayon_minmax_zp_chateau" var: rayon_minmax_zp_chateau init: "deplacement_positif";
	
	parameter "rayon_min_zp_chateau" var: rayon_min_zp_chateau init: 5000;
	parameter "rayon_max_zp_chateau" var: rayon_max_zp_chateau init: 20000;
}
experiment AnaSensi_Meca_rayon_minmax_zp_chateau_4 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_chateau";
	parameter "rayon_minmax_zp_chateau" var: rayon_minmax_zp_chateau init: "reduction_max";
	
	parameter "rayon_min_zp_chateau" var: rayon_min_zp_chateau init: 2000;
	parameter "rayon_max_zp_chateau" var: rayon_max_zp_chateau init: 5000;
}
experiment AnaSensi_Meca_rayon_minmax_zp_chateau_5 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "rayon_minmax_zp_chateau";
	parameter "rayon_minmax_zp_chateau" var: rayon_minmax_zp_chateau init: "augmentation_min";
	
	parameter "rayon_min_zp_chateau" var: rayon_min_zp_chateau init: 5000;
	parameter "rayon_max_zp_chateau" var: rayon_max_zp_chateau init: 15000;
}


experiment AnaSensi_Meca_attractivite_amenites_1 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "attractivite_amenites";
	parameter "attractivite_amenites" var: attractivite_amenites init: "base";
	
	parameter "attractivite_petit_chateau" var: attractivite_petit_chateau init: 0.15;
	parameter "attractivite_gros_chateau" var: attractivite_gros_chateau init: 0.25;
	parameter "attractivite_1_eglise" var: attractivite_1_eglise init: 0.15;
	parameter "attractivite_2_eglise" var: attractivite_2_eglise init: 0.25;
	parameter "attractivite_3_eglise" var: attractivite_3_eglise init: 0.5;
	parameter "attractivite_4_eglise" var: attractivite_4_eglise init: 0.6;
	parameter "attractivite_communaute" var: attractivite_communaute init: 0.15;
}
experiment AnaSensi_Meca_attractivite_amenites_2 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "attractivite_amenites";
	parameter "attractivite_amenites" var: attractivite_amenites init: "renforce_chateaux";
	
	parameter "attractivite_petit_chateau" var: attractivite_petit_chateau init: 0.25;
	parameter "attractivite_gros_chateau" var: attractivite_gros_chateau init: 0.5;
	parameter "attractivite_1_eglise" var: attractivite_1_eglise init: 0.05;
	parameter "attractivite_2_eglise" var: attractivite_2_eglise init: 0.1;
	parameter "attractivite_3_eglise" var: attractivite_3_eglise init: 0.25;
	parameter "attractivite_4_eglise" var: attractivite_4_eglise init: 0.35;
	parameter "attractivite_communaute" var: attractivite_communaute init: 0.15;
}
experiment AnaSensi_Meca_attractivite_amenites_3 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "attractivite_amenites";
	parameter "attractivite_amenites" var: attractivite_amenites init: "renforce_eglises";
	
	parameter "attractivite_petit_chateau" var: attractivite_petit_chateau init: 0.05;
	parameter "attractivite_gros_chateau" var: attractivite_gros_chateau init: 0.15;
	parameter "attractivite_1_eglise" var: attractivite_1_eglise init: 0.2;
	parameter "attractivite_2_eglise" var: attractivite_2_eglise init: 0.4;
	parameter "attractivite_3_eglise" var: attractivite_3_eglise init: 0.6;
	parameter "attractivite_4_eglise" var: attractivite_4_eglise init: 0.7;
	parameter "attractivite_communaute" var: attractivite_communaute init: 0.15;
}
experiment AnaSensi_Meca_attractivite_amenites_4 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "attractivite_amenites";
	parameter "attractivite_amenites" var: attractivite_amenites init: "renforce_communaute";
	
	parameter "attractivite_petit_chateau" var: attractivite_petit_chateau init: 0.1;
	parameter "attractivite_gros_chateau" var: attractivite_gros_chateau init: 0.2;
	parameter "attractivite_1_eglise" var: attractivite_1_eglise init: 0.1;
	parameter "attractivite_2_eglise" var: attractivite_2_eglise init: 0.2;
	parameter "attractivite_3_eglise" var: attractivite_3_eglise init: 0.35;
	parameter "attractivite_4_eglise" var: attractivite_4_eglise init: 0.5;
	parameter "attractivite_communaute" var: attractivite_communaute init: 0.3;
}
experiment AnaSensi_Meca_attractivite_amenites_5 parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "mecanisme2";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "attractivite_amenites";
	parameter "attractivite_amenites" var: attractivite_amenites init: "renforce_hierarchie";
	
	parameter "attractivite_petit_chateau" var: attractivite_petit_chateau init: 0.1;
	parameter "attractivite_gros_chateau" var: attractivite_gros_chateau init: 0.3;
	parameter "attractivite_1_eglise" var: attractivite_1_eglise init: 0.05;
	parameter "attractivite_2_eglise" var: attractivite_2_eglise init: 0.15;
	parameter "attractivite_3_eglise" var: attractivite_3_eglise init: 0.35;
	parameter "attractivite_4_eglise" var: attractivite_4_eglise init: 0.6;
	parameter "attractivite_communaute" var: attractivite_communaute init: 0.1;
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////////////////     TECHNIQUES     //////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

////
//// 11 paramètres * 5 valeurs * 20 réplications = 1100 simulations
////

experiment AnaSensi_Technique_coef_redevances parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "coef_redevances";
	parameter "coef_redevances" var: coef_redevances among: [5, 10, 15, 20, 25];
}

experiment AnaSensi_Technique_min_s_distance_chateau parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "min_s_distance_chateau";
	parameter "min_s_distance_chateau" var: min_s_distance_chateau among: [0.0, 0.001, 0.01, 0.05, 0.1];

}

experiment AnaSensi_Technique_distance_fusion_agregat parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "distance_fusion_agregat";
	parameter "distance_fusion_agregat" var: distance_fusion_agregat among: [50, 100, 150, 200, 500];
}

experiment AnaSensi_Technique_droits_haute_justice_zp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "droits_haute_justice_zp";
	parameter "droits_haute_justice_zp" var: droits_haute_justice_zp among: [0.0, 1.0, 2.0, 3.0, 4.0];
}

experiment AnaSensi_Technique_droits_haute_justice_zp_cession parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "droits_haute_justice_zp_cession";
	parameter "droits_haute_justice_zp_cession" var: droits_haute_justice_zp_cession among: [0.0, 1.0, 2.5, 3.5, 5.0];
}

experiment AnaSensi_Technique_droits_fonciers_zp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "droits_fonciers_zp";
	parameter "droits_fonciers_zp" var: droits_fonciers_zp among: [0, 0.5, 1.0, 1.5, 2.0];
}

experiment AnaSensi_Technique_droits_fonciers_zp_cession parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "droits_fonciers_zp_cession";
	parameter "droits_fonciers_zp_cession" var: droits_fonciers_zp_cession among: [0.0, 0.5, 1.25, 2.0, 2.5];
}

experiment AnaSensi_Technique_autres_droits_zp parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "autres_droits_zp";
	parameter "autres_droits_zp" var: autres_droits_zp among: [0.0, 0.15, 0.25, 0.5, 1.0];
}

experiment AnaSensi_Technique_autres_droits_zp_cession parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "autres_droits_zp_cession";
	parameter "autres_droits_zp_cession" var: autres_droits_zp_cession among: [0.0, 0.2, 0.35, 0.5, 1.0];
}

experiment AnaSensi_Technique_nb_tirages_chateaux_gs parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "nb_tirages_chateaux_gs";
	parameter "nb_tirages_chateaux_gs" var: nb_tirages_chateaux_gs among: [1, 2, 3, 4, 5];
}

experiment AnaSensi_Technique_nb_tirages_chateaux_ps parent: AnaSensi_Base type: batch repeat: 2 keep_seed: false benchmark: false until: (annee >= fin_simulation){
	parameter 'prefix_output' var: prefix_output init: "technique";
	parameter 'sensibility_parameter' var: sensibility_parameter init: "nb_tirages_chateaux_ps";
	parameter "nb_tirages_chateaux_ps" var: nb_tirages_chateaux_ps among: [0, 1, 2, 3, 4];
}
