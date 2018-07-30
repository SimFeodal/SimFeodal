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
	
	action enquote (unknown text) {
		return '"' + string(text) + '"';
	}
	
	
	action save_outputs_data {
		string currentPrefix <- prefix_output;
		if (Annee = 820) {do save_parameters(currentPrefix);}
		do save_global(currentPrefix);
		do save_seigneurs(currentPrefix);
		do save_agregats(currentPrefix);
		do save_poles(currentPrefix);
		do save_paroisses(currentPrefix);
		do save_FP(currentPrefix);
	}
	
	action save_parameters(string sim_name) {
		string seuils_distance_max_dem_localSt <-  enquote(seuils_distance_max_dem_local);
		string myseed <- enquote(seed);
		
		save [
				myseed, sim_name, debut_simulation, fin_simulation, duree_step, besoin_protection,
				distance_detection_agregats, nombre_FP_agregat, nombre_agglos_antiques,
				nombre_villages, puissance_communautes,
				apparition_communautes, proba_apparition_communaute, nombre_foyers_paysans,
				taux_renouvellement, taux_mobilite, distance_max_dem_local, seuil_puissance_armee,
				nombre_seigneurs_objectif, nombre_grands_seigneurs,
				nombre_petits_seigneurs, puissance_grand_seigneur1, puissance_grand_seigneur2,
				proba_collecter_loyer, proba_creation_ZP_banaux, proba_creation_ZP_basseMoyenneJustice,
				rayon_min_PS, rayon_max_PS, min_fourchette_loyers_PS, max_fourchette_loyers_PS,
				proba_don_partie_ZP, apparition_chateaux, nb_chateaux_potentiels_GS,
				seuil_attractivite_chateau, proba_creer_chateau_GS, proba_chateau_agregat,
				proba_don_chateau_GS, proba_creer_chateau_PS, proba_gain_droits_hauteJustice_chateau,
				proba_gain_droits_banaux_chateau, proba_gain_droits_basseMoyenneJustice_chateau,
				proba_promotion_groschateau_multipole, proba_promotion_groschateau_autre,
				puissance_necessaire_creation_chateau_GS, puissance_necessaire_creation_chateau_PS,
				nombre_eglises, nb_eglises_paroissiales, nb_max_paroissiens,
				nb_min_paroissiens, seuil_creation_paroisse, nb_paroissiens_mecontents_necessaires,
				attrac_0_eglises, attrac_1_eglises, attrac_2_eglises, attrac_3_eglises, attrac_4_eglises,
				attrac_GC, attrac_PC, attrac_communautes,nombre_FP_village, seuils_distance_max_dem_localSt,
				taux_augmentation_FP, proba_ponderee_deplacement_lointain, coef_redevances, serfs_mobiles,
				taille_cote_monde
			] to: ("../outputs/"+ sim_name +"_parameters.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_global(string sim_name) {
		int nbChateaux <- length(Chateaux);
		int nbGdChateaux <- Chateaux count (each.type = "Grand Chateau");
		int nbEglises <- length(Eglises);
		int nbEglisesParoissiales <-  Eglises count (each.eglise_paroissiale);
		string myseed <- enquote(seed);
		save [
				myseed, sim_name, Annee,
				nbChateaux, nbGdChateaux,
				nbEglises, nbEglisesParoissiales,
				distance_eglises, distance_eglises_paroissiales,
				prop_FP_isoles, charge_fiscale, dist_ppv_agregat,total_duration
				
			] to: ("../outputs/"+ sim_name +"_results_global.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_seigneurs(string sim_name) {
		string myseed <- enquote(seed);
		ask Seigneurs {
			int id_seigneur <- int(replace(self.name, 'Seigneurs', ''));
			int nbChateauxProprio <- Chateaux count (each.proprietaire = self);
			int nbChateauxGardien <- Chateaux count (each.gardien = self);
			int nbFPassujettis <- length(FP_assujettis);
			int nbVassaux <- Seigneurs count (each.monSuzerain = self);
			int nbDebiteurs <- length(mesDebiteurs);
			string geom <- enquote(location with_precision 2);

			save [
				myseed, sim_name,Annee,id_seigneur, 
				type, initial, puissance,
				nbChateauxProprio, nbChateauxGardien,
				nbFPassujettis, nbVassaux, nbDebiteurs, monAgregat, geom
				]
			to:("../outputs/"+ sim_name +"_results_seigneurs.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_agregats(string sim_name) {
		string myseed <- enquote(seed);
		ask Agregats {
			int nbFP <- length(fp_agregat);
			float superficie <- shape.area;
			string geom <- enquote(shape with_precision 2);
			int id_agregat <- int(replace(self.name, 'Agregats', ''));
			int monpole <- (monPole != nil) ? int(replace(monPole.name, 'Poles', '')) : nil;
			
			save [
				myseed, sim_name, Annee, id_agregat,
				nbFP, superficie, communaute, monpole, geom
			] to: ("../outputs/"+ sim_name +"_results_agregats.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_poles(string sim_name) {
		string myseed <- enquote(seed);
		ask Poles {
			int nbAttracteurs <- length(mesAttracteurs);
			int nbEglises <- length(mesAttracteurs of_species Eglises);
			int nbParoisses <- (mesAttracteurs of_species Eglises) count (each.eglise_paroissiale);
			int nbGC <- (mesAttracteurs of_species Chateaux) count (each.type = "Grand Chateau");
			int nbPC <- (mesAttracteurs of_species Chateaux) count (each.type = "Petit Chateau");
			int nbCA <- length(mesAttracteurs of_species Agregats);
			string geom <- enquote(shape with_precision 2);
			int id_pole <- int(replace(self.name, 'Poles', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : nil;
				
			save [
				myseed, sim_name, Annee, id_pole,
				attractivite, nbAttracteurs, monagregat,
				nbEglises, nbParoisses, nbGC, nbPC, nbCA, geom
				
			] to: ("../outputs/"+ sim_name +"_results_poles.csv") type: "csv" header: true rewrite: false;
		}
		
	}
	
	action save_FP(string sim_name) {
		string myseed <- enquote(seed);
		ask Foyers_Paysans {
			float sMat <- satisfaction_materielle with_precision 2;
			float sRel <- satisfaction_materielle with_precision 2;
			float sProt <- satisfaction_protection with_precision 2;
			float Satis <- Satisfaction with_precision 2;
			string geom <- enquote(location with_precision 2);
			int id_fp <- int(replace(self.name, 'Foyers_Paysans', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : nil;
			
			save [
				myseed, sim_name, Annee, id_fp,
				communaute, monagregat,
				sMat, sRel, sProt,
				Satis, mobile, type_deplacement,
				deplacement_from, deplacement_to,
				nb_preleveurs, geom
			] to: ("../outputs/"+ sim_name +"_results_FP.csv") type: "csv" header: true rewrite: false;
		}

	}
	
		action save_paroisses(string sim_name) {
			string myseed <- enquote(seed);
			ask  Paroisses {
				int nbFideles <- length(mesFideles);
				float SatisfactionParoisse <- Satisfaction_Paroisse with_precision 3;
				string geom <- enquote(shape with_precision 2);
				int id_paroisse <- int(replace(self.name, 'Paroisses', ''));
				int moneglise <- (monEglise != nil) ? int(replace(monEglise.name, 'Agregats', '')) : nil;

				save [
					myseed, sim_name, Annee, id_paroisse,
					moneglise, mode_promotion, shape.area,
					nbFideles, SatisfactionParoisse, geom
				] to: ("../outputs/"+ sim_name +"_results_paroisses.csv") type: "csv" header: true rewrite: false;
			}
		}
	
}	