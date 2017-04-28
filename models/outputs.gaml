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
		do save_FP_summary(currentPrefix);
		do save_FP_all(currentPrefix);
		do save_paroisses(currentPrefix);
		do save_FP(currentPrefix);
	}
	
	action save_parameters(string prefix) {	
		save [
				myseed, prefix_output, debut_simulation, fin_simulation, duree_step, besoin_protection,
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
			] to: ("../outputs/"+ prefix +"_parameters.csv") type: "csv" rewrite: false;
	}
	
	action save_global(string prefix) {
		save [
				myseed, prefix_output, Annee,
				length(Chateaux), Chateaux count (each.type = "Grand Chateau"),
				length(Eglises), Eglises count (each.eglise_paroissiale),
				distance_eglises, distance_eglises_paroissiales,
				prop_FP_isoles, charge_fiscale,dist_ppv_agregat,total_duration
				
			] to: ("../outputs/"+ prefix +"_results_global.csv") type: "csv" rewrite: false;
	}
	
	action save_seigneurs(string prefix) {
		ask Seigneurs {
			save [
				myseed, prefix_output, Annee,self, 
				type, initial, puissance,
				Chateaux count (each.proprietaire = self),Chateaux count (each.gardien = self),
				length(FP_assujettis), Seigneurs count (each.monSuzerain = self), length(mesDebiteurs)
				]
			to:("../outputs/"+ prefix +"_results_seigneurs.csv") type: "csv" rewrite: false;
		}
	}
	
	action save_agregats(string prefix) {
		ask Agregats {
			save [
				myseed, prefix_output, Annee, self,
				length(fp_agregat), nbfp_avant_dem,
				nb_fp_attires, shape.area, communaute,  "\"" + shape.location + "\""
			] to: ("../outputs/"+ prefix +"_results_agregats.csv") type: "csv" rewrite: false;
		}
	}
	
	action save_poles(string prefix) {
		ask Poles {
				int nbEglises <- length(mesAttracteurs of_species Eglises);
				int nbParoisses <- (mesAttracteurs of_species Eglises) count (each.eglise_paroissiale);
				int nbGC <- (mesAttracteurs of_species Chateaux) count (each.type = "Grand Chateau");
				int nbPC <- (mesAttracteurs of_species Chateaux) count (each.type = "Petit Chateau");
				int nbCA <- length(mesAttracteurs of_species Agregats);
				
			save [
				myseed, prefix_output, Annee, self,
				attractivite, length(mesAttracteurs), monAgregat,
				nbEglises, nbParoisses, nbGC, nbPC, nbCA, "\"" + shape.location + "\""
				
			] to: ("../outputs/"+ prefix +"_results_poles.csv") type: "csv" rewrite: false;
		}
		
	}
	
	action save_FP(string prefix) {
		ask Foyers_Paysans {
			float sMat <- satisfaction_materielle with_precision 2;
			float sRel <- satisfaction_materielle with_precision 2;
			float sProt <- satisfaction_protection with_precision 2;
			float Satis <- Satisfaction with_precision 2;
			string myLoc <- "\"" + round(location) + "\"";
			
			save [
				myseed, prefix_output, Annee, self,
				communaute, monAgregat,
				sMat, sRel, sProt,
				Satis, mobile, nb_preleveurs, myLoc
			] to: ("../outputs/"+ prefix +"_results_FP.csv") type: "csv" rewrite: false;
		}

	}
	
	action save_FP_all(string prefix) {
		save [
			myseed, prefix_output, Annee,
			nbInInIntra, nbInOutIntra, nbOutInIntra, nbOutOutIntra,
			nbInInInter, nbInOutInter, nbOutInInter, nbOutOutInter
		] to: ("../outputs/"+ prefix +"_results_FP_all.csv") type: "csv" rewrite: false;
	}
	
	action save_FP_summary(string prefix) {
			save [
				myseed, prefix_output, Annee,
				nb_demenagement_local, nb_demenagement_lointain,
				nb_FP_sat_024, nb_FP_sat_2549, nb_FP_sat_5075, nb_FP_sat_75100
			] to: ("../outputs/"+ prefix +"_results_summFP.csv") type: "csv" rewrite: false;
		
	}
	
		action save_paroisses(string prefix) {
			ask  Paroisses {
				save [
					myseed, prefix_output, Annee, self,
					monEglise, shape.area,
					length(mesFideles), Satisfaction_Paroisse with_precision 3, "\"" + shape.points + "\""
				] to: ("../outputs/"+ prefix +"_results_paroisses.csv") type: "csv" rewrite: false;
			}
		}
	
}	