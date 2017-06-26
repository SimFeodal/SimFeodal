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
		save [
				seed, sim_name, debut_simulation, fin_simulation, duree_step, besoin_protection,
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
				attrac_GC, attrac_PC, attrac_communautes	
			] to: ("../outputs/"+ sim_name +"_parameters.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_global(string sim_name) {
		int nbChateaux <- length(Chateaux);
		int nbGdChateaux <- Chateaux count (each.type = "Grand Chateau");
		int nbEglises <- length(Eglises);
		int nbEglisesParoissiales <-  Eglises count (each.eglise_paroissiale);
		
		save [
				seed, sim_name, Annee,
				nbChateaux, nbGdChateaux,
				nbEglises, nbEglisesParoissiales,
				distance_eglises, distance_eglises_paroissiales,
				prop_FP_isoles, charge_fiscale, dist_ppv_agregat,total_duration
				
			] to: ("../outputs/"+ sim_name +"_results_global.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_seigneurs(string sim_name) {
		ask Seigneurs {
			int nbChateauxProprio <- Chateaux count (each.proprietaire = self);
			int nbChateauxGardien <- Chateaux count (each.gardien = self);
			int nbFPassujettis <- length(FP_assujettis);
			int nbVassaux <- Seigneurs count (each.monSuzerain = self);
			int nbDebiteurs <- length(mesDebiteurs);
			
			save [
				seed, sim_name,Annee,self, 
				type, initial, puissance,
				nbChateauxProprio, nbChateauxGardien,
				nbFPassujettis, nbVassaux, nbDebiteurs
				]
			to:("../outputs/"+ sim_name +"_results_seigneurs.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_agregats(string prefix) {
		ask Agregats {
			int nbFP <- length(fp_agregat);
			float superficie <- shape.area;
			string geom <- "'" + string(shape with_precision 2) + "'";
			
			save [
				seed, prefix_output, Annee, self,
				nbFP, superficie, communaute, monPole, geom
			] to: ("../outputs/"+ prefix +"_results_agregats.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_poles(string sim_name) {
		ask Poles {
			int nbAttracteurs <- length(mesAttracteurs);
			int nbEglises <- length(mesAttracteurs of_species Eglises);
			int nbParoisses <- (mesAttracteurs of_species Eglises) count (each.eglise_paroissiale);
			int nbGC <- (mesAttracteurs of_species Chateaux) count (each.type = "Grand Chateau");
			int nbPC <- (mesAttracteurs of_species Chateaux) count (each.type = "Petit Chateau");
			int nbCA <- length(mesAttracteurs of_species Agregats);
			string geom <- "'" + string(shape with_precision 2) + "'";
				
			save [
				seed, sim_name, Annee, self,
				attractivite, nbAttracteurs, monAgregat,
				nbEglises, nbParoisses, nbGC, nbPC, nbCA, geom
				
			] to: ("../outputs/"+ sim_name +"_results_poles.csv") type: "csv" header: true rewrite: false;
		}
		
	}
	
	action save_FP(string sim_name) {
		ask Foyers_Paysans {
			float sMat <- satisfaction_materielle with_precision 2;
			float sRel <- satisfaction_materielle with_precision 2;
			float sProt <- satisfaction_protection with_precision 2;
			float Satis <- Satisfaction with_precision 2;
			string geom <- "'" + string(location with_precision 2) + "'";
			
			save [
				seed, sim_name, Annee, self,
				communaute, monAgregat,
				sMat, sRel, sProt,
				Satis, mobile, type_deplacement,
				deplacement_from, deplacement_to,
				nb_preleveurs, geom
			] to: ("../outputs/"+ sim_name +"_results_FP.csv") type: "csv" header: true rewrite: false;
		}

	}
	
		action save_paroisses(string sim_name) {
			ask  Paroisses {
				int nbFideles <- length(mesFideles);
				float SatisfactionParoisse <- Satisfaction_Paroisse with_precision 3;
				string geom <- "'" + string(shape with_precision 2) + "'";
				
				save [
					seed, sim_name, Annee, self,
					monEglise, mode_promotion, shape.area,
					nbFideles, SatisfactionParoisse, geom
				] to: ("../outputs/"+ sim_name +"_results_paroisses.csv") type: "csv" header: true rewrite: false;
			}
		}
	
}	