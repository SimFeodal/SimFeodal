/**
 *  SimFeodal
 *  Author: R. Cura, C. Tannier, S. Leturcq, E. Zadora-Rio
 *  Description: https://simfeodal.github.io/
 *  Repository : https://github.com/SimFeodal/SimFeodal
 *  Version : 6.3
 *  Run with : Gama 1.8 (git) (1.7.0.201903051304)
 */

model simfeodal

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
		//do save_FP(currentPrefix); : Changement en 6.3
		do save_FP_summary(currentPrefix);
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
proba_collecter_foncier_ps,
proba_creation_zp_autres_droits_ps,
rayon_min_zp_ps,
rayon_max_zp_ps,
min_taux_prelevement_zp_ps,
max_taux_prelevement_zp_ps,
taux_prelevement_zp_chateau,
proba_cession_droits_zp,
rayon_voisinage_ps,
proba_cession_locale,
proba_don_chateau,
// CHATEAUX
rayon_min_zp_chateau,
rayon_max_zp_chateau,
dist_min_entre_chateaux,
proba_chateau_agregat, // TODO : A renommer dans SimEDB (proba_chateau_gs_agregat)
proba_promotion_chateau_pole,
// EGLISES PAROISSIALES
ponderation_creation_paroisse_agregat,
seuil_nb_paroissiens_insatisfaits,
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
autres_droits_zp_cession,
ponderation_proba_chateau_gs, // TODO : A ajouter dans SimEDB
ponderation_proba_chateau_ps // TODO : A ajouter dans SimEDB		
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
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
			string geom <- world.enquote(location with_precision 2);

			save [
				seed, sim_name,annee,id_seigneur, 
				type, date_apparition, puissance,
				nb_chateaux_proprio, nb_chateaux_gardien,
				nb_fp_assujettis, monagregat, geom
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
	
	action save_FP_summary(string sim_name) {
		string seed <- enquote(seed);
		int nb_fp <- length(Foyers_Paysans);
		
		float deplacement_fixe <- (Foyers_Paysans count (each.type_deplacement = "fixe")) / nb_fp;
		float deplacement_lointain <- (Foyers_Paysans count (each.type_deplacement = "lointain")) / nb_fp;
		float deplacement_local <- (Foyers_Paysans count (each.type_deplacement = "local")) / nb_fp;
				
		//	"pole local avec agregat" / "pole local avec agregat plus attractif"
		float from_isole_to_agregat_local <- (Foyers_Paysans count (each.deplacement_from = "isole" and
			(each.deplacement_to = "pole local avec agregat" or  each.deplacement_to = "pole local avec agregat plus attractif")
		)) / nb_fp;
		// "agregat lointain unique" / "agregat lointain attractif"
		float from_isole_to_agregat_lointain <- (Foyers_Paysans count (each.deplacement_from = "isole" and 
			(each.deplacement_to = "agregat lointain unique" or  each.deplacement_to = "agregat lointain attractif")
		)) / nb_fp;
		// "pole local sans agregat" / "pole local sans agregat plus attractif"
		float from_isole_to_pole_local_hors_agregat <- (Foyers_Paysans count (each.deplacement_from = "isole" and
			(each.deplacement_to = "pole local sans agregat" or  each.deplacement_to = "pole local sans agregat plus attractif")
		)) / nb_fp;

		//	"pole local avec agregat" / "pole local avec agregat plus attractif"
		float from_agregat_to_agregat_local <- (Foyers_Paysans count (each.deplacement_from = "agregat" and
			(each.deplacement_to = "pole local avec agregat" or  each.deplacement_to = "pole local avec agregat plus attractif")
		)) / nb_fp;
		// "agregat lointain unique" / "agregat lointain attractif"
		float from_agregat_to_agregat_lointain <- (Foyers_Paysans count (each.deplacement_from = "agregat" and 
			(each.deplacement_to = "agregat lointain unique" or  each.deplacement_to = "agregat lointain attractif")
		)) / nb_fp;
		// "pole local sans agregat" / "pole local sans agregat plus attractif"
		float from_agregat_to_pole_local_hors_agregat <- (Foyers_Paysans count (each.deplacement_from = "agregat" and
			(each.deplacement_to = "pole local sans agregat" or  each.deplacement_to = "pole local sans agregat plus attractif")
		)) / nb_fp;
		
		float taux_fp_isoles <- (Foyers_Paysans count (each.monAgregat = nil)) / nb_fp;
		
		float deci_0_satis <- (Foyers_Paysans count (each.satisfaction >= 0.0 and each.satisfaction < 0.1)) / nb_fp;
		float deci_1_satis <- (Foyers_Paysans count (each.satisfaction >= 0.1 and each.satisfaction < 0.2)) / nb_fp;
		float deci_2_satis <- (Foyers_Paysans count (each.satisfaction >= 0.2 and each.satisfaction < 0.3)) / nb_fp;
		float deci_3_satis <- (Foyers_Paysans count (each.satisfaction >= 0.3 and each.satisfaction < 0.4)) / nb_fp;
		float deci_4_satis <- (Foyers_Paysans count (each.satisfaction >= 0.4 and each.satisfaction < 0.5)) / nb_fp;
		float deci_5_satis <- (Foyers_Paysans count (each.satisfaction >= 0.5 and each.satisfaction < 0.6)) / nb_fp;
		float deci_6_satis <- (Foyers_Paysans count (each.satisfaction >= 0.6 and each.satisfaction < 0.7)) / nb_fp;
		float deci_7_satis <- (Foyers_Paysans count (each.satisfaction >= 0.7 and each.satisfaction < 0.8)) / nb_fp;
		float deci_8_satis <- (Foyers_Paysans count (each.satisfaction >= 0.8 and each.satisfaction < 0.9)) / nb_fp;
		float deci_9_satis <- (Foyers_Paysans count (each.satisfaction >= 0.9 and each.satisfaction <= 1.0)) / nb_fp;
		
		float deci_0_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.0 and each.s_religieuse < 0.1)) / nb_fp;
		float deci_1_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.1 and each.s_religieuse < 0.2)) / nb_fp;
		float deci_2_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.2 and each.s_religieuse < 0.3)) / nb_fp;
		float deci_3_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.3 and each.s_religieuse < 0.4)) / nb_fp;
		float deci_4_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.4 and each.s_religieuse < 0.5)) / nb_fp;
		float deci_5_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.5 and each.s_religieuse < 0.6)) / nb_fp;
		float deci_6_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.6 and each.s_religieuse < 0.7)) / nb_fp;
		float deci_7_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.7 and each.s_religieuse < 0.8)) / nb_fp;
		float deci_8_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.8 and each.s_religieuse < 0.9)) / nb_fp;
		float deci_9_srel <- (Foyers_Paysans count (each.s_religieuse >= 0.9 and each.s_religieuse <= 1.0)) / nb_fp;
		
		float deci_0_smat <- (Foyers_Paysans count (each.s_materielle >= 0.0 and each.s_materielle < 0.1)) / nb_fp;
		float deci_1_smat <- (Foyers_Paysans count (each.s_materielle >= 0.1 and each.s_materielle < 0.2)) / nb_fp;
		float deci_2_smat <- (Foyers_Paysans count (each.s_materielle >= 0.2 and each.s_materielle < 0.3)) / nb_fp;
		float deci_3_smat <- (Foyers_Paysans count (each.s_materielle >= 0.3 and each.s_materielle < 0.4)) / nb_fp;
		float deci_4_smat <- (Foyers_Paysans count (each.s_materielle >= 0.4 and each.s_materielle < 0.5)) / nb_fp;
		float deci_5_smat <- (Foyers_Paysans count (each.s_materielle >= 0.5 and each.s_materielle < 0.6)) / nb_fp;
		float deci_6_smat <- (Foyers_Paysans count (each.s_materielle >= 0.6 and each.s_materielle < 0.7)) / nb_fp;
		float deci_7_smat <- (Foyers_Paysans count (each.s_materielle >= 0.7 and each.s_materielle < 0.8)) / nb_fp;
		float deci_8_smat <- (Foyers_Paysans count (each.s_materielle >= 0.8 and each.s_materielle < 0.9)) / nb_fp;
		float deci_9_smat <- (Foyers_Paysans count (each.s_materielle >= 0.9 and each.s_materielle <= 1.0)) / nb_fp;
		
		float deci_0_sprot <- (Foyers_Paysans count (each.s_protection >= 0.0 and each.s_protection < 0.1)) / nb_fp;
		float deci_1_sprot <- (Foyers_Paysans count (each.s_protection >= 0.1 and each.s_protection < 0.2)) / nb_fp;
		float deci_2_sprot <- (Foyers_Paysans count (each.s_protection >= 0.2 and each.s_protection < 0.3)) / nb_fp;
		float deci_3_sprot <- (Foyers_Paysans count (each.s_protection >= 0.3 and each.s_protection < 0.4)) / nb_fp;
		float deci_4_sprot <- (Foyers_Paysans count (each.s_protection >= 0.4 and each.s_protection < 0.5)) / nb_fp;
		float deci_5_sprot <- (Foyers_Paysans count (each.s_protection >= 0.5 and each.s_protection < 0.6)) / nb_fp;
		float deci_6_sprot <- (Foyers_Paysans count (each.s_protection >= 0.6 and each.s_protection < 0.7)) / nb_fp;
		float deci_7_sprot <- (Foyers_Paysans count (each.s_protection >= 0.7 and each.s_protection < 0.8)) / nb_fp;
		float deci_8_sprot <- (Foyers_Paysans count (each.s_protection >= 0.8 and each.s_protection < 0.9)) / nb_fp;
		float deci_9_sprot <- (Foyers_Paysans count (each.s_protection >= 0.9 and each.s_protection <= 1.0)) / nb_fp;
		
		
		list<int> list_redevances_acquittees <- Foyers_Paysans collect each.redevances_acquittees;
		float q1_redevances_acquittees <- list_redevances_acquittees quantile 0.25;
		float med_redevances_acquittees <- list_redevances_acquittees quantile 0.5;
		float q3_redevances_acquittees <- list_redevances_acquittees quantile 0.75;
		
		
		ask Foyers_Paysans {
			
			save [
				seed, sim_name, annee, nb_fp,taux_fp_isoles,
				deplacement_fixe, deplacement_lointain, deplacement_local,
				from_isole_to_agregat_local, from_isole_to_agregat_lointain, from_isole_to_pole_local_hors_agregat,
				from_agregat_to_agregat_local, from_agregat_to_agregat_lointain, from_agregat_to_pole_local_hors_agregat,
				q1_redevances_acquittees, med_redevances_acquittees, q3_redevances_acquittees,
				
				deci_0_satis,deci_1_satis,deci_2_satis,deci_3_satis,deci_4_satis,
				deci_5_satis,deci_6_satis,deci_7_satis,deci_8_satis,deci_9_satis,
				
				deci_0_srel,deci_1_srel,deci_2_srel,deci_3_srel,deci_4_srel,
				deci_5_srel,deci_6_srel,deci_7_srel,deci_8_srel,deci_9_srel,
				
				deci_0_smat,deci_1_smat,deci_2_smat,deci_3_smat,deci_4_smat,
				deci_5_smat,deci_6_smat,deci_7_smat,deci_8_smat,deci_9_smat,

				deci_0_sprot,deci_1_sprot,deci_2_sprot,deci_3_sprot,deci_4_sprot,
				deci_5_sprot,deci_6_sprot,deci_7_sprot,deci_8_sprot,deci_9_sprot
				
				
			] to: (output_folder_path + sim_name +"_results_FP_summarised.csv") type: "csv" header: true rewrite: false;
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