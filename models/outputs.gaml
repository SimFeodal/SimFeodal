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
//		do fake_save(currentPrefix);
		if (Annee = 820) {do save_parameters(currentPrefix);}
		do save_global(currentPrefix);
		do save_seigneurs(currentPrefix);
		do save_agregats(currentPrefix);
		do save_poles(currentPrefix);
		do save_paroisses(currentPrefix);
		do save_FP(currentPrefix);
	}
	
//	action fake_save(string sim_name) {
//		string blob <- "Blob";
//		write (output_folder_path + sim_name +"_results_global.csv");
//		save [blob] to: (output_folder_path + sim_name +"_results_global.csv") type: "csv" header: true rewrite: false;
//	}
	
	action save_parameters(string sim_name) {
		string seuils_distance_max_dem_local <-  world.enquote(seuils_distance_max_dem_local);
		string seed <- string(seed);
		string besoin_protection_fp <- world.enquote(besoin_protection_fp);
		
		
		save [
				seed, sim_name, debut_simulation, fin_simulation, duree_step,
				besoin_protection, // XXX : N'est plus un param mais une variable en v6
				distance_detection_agregats, nombre_FP_agregat,
				init_nb_fp_agglo, // avant v6 : anciennement nombre_agglos_antiques
				init_nb_villages, // avant v6 : anciennement nombre_villages
				puissance_communautes,
				apparition_communautes, proba_apparition_communaute,
				init_nb_total_fp, // avant v6 : nombre_foyers_paysans
				taux_renouvellement_fp, // avant v6 : taux_renouvellement
				proba_fp_dependant, // avant v6 : proba_FP_dependants
				distance_max_dem_local, seuil_puissance_armee,
				objectif_nombre_seigneurs, // avant v6 :  nombre_seigneurs_objectif
				init_nb_gs, // avant v6 : nombre_grands_seigneurs
				init_nb_ps, // avant v6 : nombre_petits_seigneurs
				puissance_grand_seigneur1, puissance_grand_seigneur2,
				proba_collecter_loyer, proba_creation_ZP_banaux, proba_creation_ZP_basseMoyenneJustice,
				rayon_min_PS, rayon_max_PS, min_fourchette_loyers_PS, max_fourchette_loyers_PS,
				proba_don_partie_ZP, apparition_chateaux, nb_chateaux_potentiels_GS,
				seuil_attractivite_chateau,
				// proba_creer_chateau_GS, // FIXME : Supprimer ce paramètre des sorties + SimEDB
				proba_chateau_agregat,
				proba_don_chateau_GS, 
				// proba_creer_chateau_PS, // FIXME : Supprimer ce paramètre des sorties + SimEDB
				proba_gain_droits_hauteJustice_chateau,
				proba_gain_droits_banaux_chateau, proba_gain_droits_basseMoyenneJustice_chateau,
				proba_promotion_groschateau_multipole, proba_promotion_groschateau_autre,
				// puissance_necessaire_creation_chateau_GS, puissance_necessaire_creation_chateau_PS, // FIXME : Supprimer ces 2 paramètres des sorties + SimEDB
				init_nb_eglises, // avant v6 nombre_eglises
				init_nb_eglises_paroissiales, // avant v6 : nb_eglises_paroissiales
				nb_max_paroissiens,
				nb_min_paroissiens, seuil_creation_paroisse, nb_paroissiens_mecontents_necessaires,
				attrac_0_eglises, attrac_1_eglises, attrac_2_eglises, attrac_3_eglises, attrac_4_eglises,
				attrac_GC, attrac_PC, attrac_communautes,
				init_nb_fp_village, // avant v6 : nombre_FP_village
				seuils_distance_max_dem_local,
				croissance_demo, // avant v6 : taux_augmentation_FP
				proba_ponderee_deplacement_lointain, coef_redevances, serfs_mobiles,
				taille_cote_monde, min_S_distance_chateau,
				init_nb_fp_agglo, // nouveau paramètre en v6 : vallait 30 avant
				besoin_protection_fp // nouveau paramètre en v6 : vallait [800::0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0] avant
			] to: (output_folder_path + sim_name +"_parameters.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_global(string sim_name) {
		int annee <- Annee;
		int nbChateaux <- length(Chateaux);
		int nbGdChateaux <- Chateaux count (each.type = "Grand Chateau");
		int nbEglises <- length(Eglises);
		int nbEglisesParoissiales <-  Eglises count (each.eglise_paroissiale);
		string seed <- world.enquote(seed);
		
		save [
				seed, sim_name, annee,
				nbChateaux, nbGdChateaux,
				nbEglises, nbEglisesParoissiales,
				distance_eglises, distance_eglises_paroissiales,
				prop_FP_isoles, charge_fiscale, dist_ppv_agregat,total_duration
				
			] to: (output_folder_path + sim_name +"_results_global.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_seigneurs(string sim_name) {
		string seed <- world.enquote(seed);
		int annee <- Annee;
		
		ask Seigneurs {
			int id_seigneur <- int(replace(self.name, 'Seigneurs', ''));
			int nbChateauxProprio <- Chateaux count (each.proprietaire = self);
			int nbChateauxGardien <- Chateaux count (each.gardien = self);
			int nbFPassujettis <- length(FP_assujettis);
			int nbVassaux <- Seigneurs count (each.monSuzerain = self);
			int nbDebiteurs <- length(mesDebiteurs);
			string geom <- world.enquote(location with_precision 2);

			save [
				seed, sim_name,annee,id_seigneur, 
				type, initial, puissance,
				nbChateauxProprio, nbChateauxGardien,
				nbFPassujettis, nbVassaux, nbDebiteurs, monAgregat, geom
				]
			to: (output_folder_path + sim_name +"_results_seigneurs.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_agregats(string sim_name) {
		string seed <- enquote(seed);
		int annee <- Annee;
		
		ask Agregats {
			int nbFP <- length(fp_agregat);
			float superficie <- shape.area;
			string geom <- world.enquote(shape with_precision 2);
			int id_agregat <- int(replace(self.name, 'Agregats', ''));
			int monpole <- (monPole != nil) ? int(replace(monPole.name, 'Poles', '')) : -1;
			
			save [
				seed, sim_name, annee, id_agregat,
				nbFP, superficie, communaute, monpole, geom
			] to: (output_folder_path + sim_name +"_results_agregats.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_poles(string sim_name) {
		string seed <- world.enquote(seed);
		int annee <- Annee;
		
		ask Poles {
			int nbAttracteurs <- length(mesAttracteurs);
			int nbEglises <- length(mesAttracteurs of_species Eglises);
			int nbParoisses <- (mesAttracteurs of_species Eglises) count (each.eglise_paroissiale);
			int nbGC <- (mesAttracteurs of_species Chateaux) count (each.type = "Grand Chateau");
			int nbPC <- (mesAttracteurs of_species Chateaux) count (each.type = "Petit Chateau");
			int nbCA <- length(mesAttracteurs of_species Agregats);
			string geom <- world.enquote(shape with_precision 2);
			int id_pole <- int(replace(self.name, 'Poles', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
				
			save [
				seed, sim_name, annee, id_pole,
				attractivite, nbAttracteurs, monagregat,
				nbEglises, nbParoisses, nbGC, nbPC, nbCA, geom
				
			] to: (output_folder_path + sim_name +"_results_poles.csv") type: "csv" header: true rewrite: false;
		}
		
	}
	
	action save_FP(string sim_name) {
		string seed <- enquote(seed);
		int annee <- Annee;
		
		ask Foyers_Paysans {
			float sMat <- satisfaction_materielle with_precision 2;
			float sRel <- satisfaction_materielle with_precision 2;
			float sProt <- satisfaction_protection with_precision 2;
			float Satis <- Satisfaction with_precision 2;
			string geom <- world.enquote(point(location with_precision 2));
			int id_fp <- int(replace(self.name, 'Foyers_Paysans', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
			
			save [
				seed, sim_name, annee, id_fp,
				communaute, monagregat,
				sMat, sRel, sProt,
				Satis, mobile, type_deplacement,
				deplacement_from, deplacement_to,
				nb_preleveurs, geom
			] to: (output_folder_path + sim_name +"_results_FP.csv") type: "csv" header: true rewrite: false;
		}

	}
	
		action save_paroisses(string sim_name) {
			string seed <- world.enquote(seed);
			int annee <- Annee;
			
			ask  Paroisses {
				int nbFideles <- length(mesFideles);
				float SatisfactionParoisse <- Satisfaction_Paroisse with_precision 3;
				string geom <- world.enquote(shape with_precision 2);
				int id_paroisse <- int(replace(self.name, 'Paroisses', ''));
				int moneglise <- (monEglise != nil) ? int(replace(monEglise.name, 'Agregats', '')) : -1;

				save [
					seed, sim_name, annee, id_paroisse,
					moneglise, mode_promotion, shape.area,
					nbFideles, SatisfactionParoisse, geom
				] to: (output_folder_path + sim_name +"_results_paroisses.csv") type: "csv" header: true rewrite: false;
			}
		}
	
}	