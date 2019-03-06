/**
 *  T8
 *  Author: Robin
 */

model t8

import "init.gaml"
import "global.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"

global {
	
	string enquote (unknown text) {
		return '"' + string(text) + '"';
	}
	
	
	action save_outputs_data {
		string currentPrefix <- prefix_output;
		if (annee = 820) {do save_parameters(currentPrefix);}
		do save_global(currentPrefix);
		do save_seigneurs(currentPrefix);
		do save_agregats(currentPrefix);
		do save_poles(currentPrefix);
		do save_paroisses(currentPrefix);
		do save_chateaux(currentPrefix);
		do save_FP(currentPrefix);
	}
	
	action save_summarised_data {
		string currentPrefix <- prefix_output;
		if (annee = 820) {do save_parameters(currentPrefix);}
		do save_global(currentPrefix);
		do save_seigneurs(currentPrefix);
		do save_chateaux(currentPrefix);
	}
	
	action save_parameters(string sim_name) {
		string seed <- string(seed);
		string besoin_protection_fp <- world.enquote(besoin_protection_fp);
		string puissance_communautes <- world.enquote(puissance_communautes);
		string proba_gain_haute_justice_gs <- world.enquote(proba_gain_haute_justice_gs);
		string proba_gain_haute_justice_chateau_ps <- world.enquote(proba_gain_haute_justice_chateau_ps);
		string periode_promotion_chateaux <- world.enquote(periode_promotion_chateaux);
		string dist_min_eglise <- world.enquote(dist_min_eglise);
		string dist_max_eglise <- world.enquote(dist_max_eglise);
		string rayon_migration_locale_fp <- world.enquote(rayon_migration_locale_fp);

		save [			
///////////////
// TECHNIQUE //
///////////////
seed, sim_name,
debut_simulation,
fin_simulation,
duree_step,

////////////
// INPUTS //
////////////
// ESPACE DU MODELE //
taille_cote_monde,
// FOYERS PAYSANS //
init_nb_total_fp,
// AGREGATS //
init_nb_agglos,
init_nb_fp_agglo,
init_nb_villages,
init_nb_fp_village,
// SEIGNEURS //
init_nb_gs,
puissance_grand_seigneur1,
puissance_grand_seigneur2,
init_nb_ps,
// EGLISES //
init_nb_eglises,
init_nb_eglises_paroissiales,

//////////////
// CONTEXTE //
//////////////
// FOYERS PAYSANS //
croissance_demo, 
taux_renouvellement_fp, 
proba_fp_dependant, 
besoin_protection_fp,
// AGREGATS //
puissance_communautes,
proba_institution_communaute,
// SEIGNEURS //
objectif_nombre_seigneurs,
proba_gain_haute_justice_gs,
proba_gain_haute_justice_chateau_ps,
debut_cession_droits_seigneurs,
debut_garde_chateaux_seigneurs,
// CHATEAUX //
debut_construction_chateaux,
periode_promotion_chateaux,

///////////////
// MECANISME //
///////////////
// FOYERS PAYSANS //
dist_min_eglise,
dist_max_eglise,
dist_min_chateau,
dist_max_chateau,
rayon_migration_locale_fp,
prop_migration_lointaine_fp,
// AGREGATS //
nb_min_fp_agregat,
distance_detection_agregat,
// SEIGNEURS //
nb_max_chateaux_par_tour_gs,
nb_max_chateaux_par_tour_ps,
proba_collecter_loyer_ps,
proba_creation_zp_autres_droits_ps,
rayon_min_zp_ps,
rayon_max_zp_ps,
min_taux_prelevement_zp_ps,
max_taux_prelevement_zp_ps,
taux_prelevement_zp_chateau,
proba_cession_droits_zp,
rayon_cession_locale_droits_ps,
proba_cession_locale,
proba_don_chateau,
// CHATEAUX
rayon_min_zp_chateau,
rayon_max_zp_chateau,
dist_min_entre_chateaux,
proba_chateau_gs_agregat,
proba_promotion_chateau_pole,
proba_promotion_chateau_isole,
// EGLISES PAROISSIALES
seuil_creation_paroisse,
nb_requis_paroissiens_insatisfaits,
// POLES
attractivite_petit_chateau,
attractivite_gros_chateau,
attractivite_1_eglise,
attractivite_2_eglise,
attractivite_3_eglise,
attractivite_4_eglise,
attractivite_communaute,

//////////////////////////
// PARAMETRES TECHNIQUE //
//////////////////////////
// Foyers Paysans //
coef_redevances,
min_s_distance_chateau,
// Agrégats //
distance_fusion_agregat,
// Seigneurs //
droits_haute_justice_zp,
droits_haute_justice_zp_cession,
droits_fonciers_zp,
droits_fonciers_zp_cession,
autres_droits_zp,
autres_droits_zp_cession			
			] to: (output_folder_path + sim_name +"_parameters.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_global(string sim_name) {
		int nb_chateaux <- length(Chateaux);
		int nb_grands_chateaux <- Chateaux count (each.type = "Grand Chateau");
		int nb_eglises <- length(Eglises);
		int nb_eglises_paroissiales <-  Eglises count (each.eglise_paroissiale);
		int nb_agregats <- length(Agregats);
		int nb_fp <- length(Foyers_Paysans);
		
		string seed <- world.enquote(seed);
		
		save [
				seed, sim_name, annee,
				nb_fp, nb_agregats,
				nb_chateaux, nb_grands_chateaux,
				nb_eglises, nb_eglises_paroissiales,
				distance_eglises, distance_eglises_paroissiales,
				prop_fp_isoles, charge_fiscale, dist_ppv_agregat,
				total_duration
				
			] to: (output_folder_path + sim_name +"_results_global.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_seigneurs(string sim_name) {
		string seed <- world.enquote(seed);
		
		ask Seigneurs {
			int id_seigneur <- int(replace(self.name, 'Seigneurs', ''));
			int nb_chateaux_proprio <- Chateaux count (each.proprietaire = self);
			int nb_chateaux_gardien <- Chateaux count (each.gardien = self);
			int nb_fp_assujettis <- length(FP_assujettis);
			int nb_vassaux <- Seigneurs count (each.monSuzerain = self);
			int nb_debiteurs <- length(mesDebiteurs);
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
			string geom <- world.enquote(location with_precision 2);

			save [
				seed, sim_name,annee,id_seigneur, 
				type, initial, puissance,
				nb_chateaux_proprio, nb_chateaux_gardien,
				nb_fp_assujettis, nb_vassaux, nb_debiteurs, monagregat, geom
				]
			to: (output_folder_path + sim_name +"_results_seigneurs.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_agregats(string sim_name) {
		string seed <- enquote(seed);
		
		ask Agregats {
			int nombre_fp_agregat <- length(fp_agregat);
			float superficie <- shape.area;
			string geom <- world.enquote(shape with_precision 2);
			int id_agregat <- int(replace(self.name, 'Agregats', ''));
			int monpole <- (monPole != nil) ? int(replace(monPole.name, 'Poles', '')) : -1;
			
			save [
				seed, sim_name, annee, id_agregat,
				nombre_fp_agregat, superficie, communaute, monpole, geom
			] to: (output_folder_path + sim_name +"_results_agregats.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_poles(string sim_name) {
		string seed <- world.enquote(seed);
		
		ask Poles {
			int nb_attracteurs <- length(mesAttracteurs);
			int nb_eglises <- length(mesAttracteurs of_species Eglises);
			int nb_paroisses <- (mesAttracteurs of_species Eglises) count (each.eglise_paroissiale);
			int nb_gc <- (mesAttracteurs of_species Chateaux) count (each.type = "Grand Chateau");
			int nb_pc <- (mesAttracteurs of_species Chateaux) count (each.type = "Petit Chateau");
			int nb_ca <- length(mesAttracteurs of_species Agregats);
			string geom <- world.enquote(shape with_precision 2);
			int id_pole <- int(replace(self.name, 'Poles', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
				
			save [
				seed, sim_name, annee, id_pole,
				attractivite, nb_attracteurs, monagregat,
				nb_eglises, nb_paroisses, nb_gc, nb_pc, nb_ca, geom
				
			] to: (output_folder_path + sim_name +"_results_poles.csv") type: "csv" header: true rewrite: false;
		}
		
	}
	
	action save_FP(string sim_name) {
		string seed <- enquote(seed);
		
		ask Foyers_Paysans {
			float satisfaction <- satisfaction with_precision 2;
			string geom <- world.enquote(shape with_precision 2);
			int id_fp <- int(replace(self.name, 'Foyers_Paysans', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
			
			save [
				seed, sim_name, annee, id_fp,
				appartenance_communaute, monagregat,
				s_materielle, s_religieuse, s_protection,
				satisfaction, mobile, type_deplacement,
				deplacement_from, deplacement_to,
				redevances_acquittees, geom
			] to: (output_folder_path + sim_name +"_results_FP.csv") type: "csv" header: true rewrite: false;
		}

	}
	
		action save_paroisses(string sim_name) {
			string seed <- world.enquote(seed);
			
			ask  Paroisses {
				int nb_fideles <- length(mesFideles);
				float satisfaction_paroisse <- Satisfaction_Paroisse with_precision 3;
				string geom <- world.enquote(shape with_precision 2);
				int id_paroisse <- int(replace(self.name, 'Paroisses', ''));
				int moneglise <- (monEglise != nil) ? int(replace(monEglise.name, 'Eglises', '')) : -1;
				float superficie <- shape.area with_precision 2;
				save [
					seed, sim_name, annee, id_paroisse,
					moneglise, mode_promotion, superficie,
					nb_fideles, nb_paroissiens_insatisfaits, satisfaction_paroisse, geom
				] to: (output_folder_path + sim_name +"_results_paroisses.csv") type: "csv" header: true rewrite: false;
			}
		}
		
			action save_chateaux(string sim_name) {
			string seed <- world.enquote(seed);
			
			ask  Chateaux {
				string geom <- world.enquote(shape with_precision 2);
				int id_chateau <- int(replace(self.name, 'Chateaux', ''));
				int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
				int monproprietaire <- (proprietaire != nil) ? int(replace(proprietaire.name, 'Seigneurs', '')) : -1;
				string monproprietaire_type <- proprietaire.type;
				int mongardien <- (gardien != nil) ? int(replace(gardien.name, 'Seigneurs', '')) : -1;

				save [
					seed, sim_name, annee, id_chateau,
					type, rayon_zp_chateau, attractivite, droits_haute_justice,
					monagregat, monproprietaire, monproprietaire_type, mongardien,
					geom
				] to: (output_folder_path + sim_name +"_results_chateaux.csv") type: "csv" header: true rewrite: false;
				}
			}
}	