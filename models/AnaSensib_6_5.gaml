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

}
