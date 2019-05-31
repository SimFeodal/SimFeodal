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
import "outputs.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"


global schedules: shuffle(Attracteurs) + shuffle(Poles) + shuffle(Agregats) + shuffle(Foyers_Paysans) + shuffle(Chateaux) + shuffle(Eglises) + shuffle(Seigneurs)
{
    
	init {
		gama.pref_errors_warnings_errors <- false; // Les warnings ne doivent pas stopper le modèle
		//gama.pref_errors_warnings_errors <- true; // Pour debug
		do generer_monde;
		set espace_dispo_chateaux <- worldextent - 3 #km;
	}
	
	reflex MaJ_globals {
		set annee <- annee + duree_step;
		do update_variables_temporelles;
		write string(annee);
	}
		
	reflex renouvellement_monde when: (time > 0){
		do renouvellement_FP;
	}
		
	reflex MaJ_paroisses {
		do compute_paroisses ; // On redécoupe
		do create_paroisses ; // On crée les paroisses des agrégats
		do compute_paroisses ; // On redessine
		do promouvoir_paroisses; // On nomme/crée de  nouvelles paroisses là où la population est mal desservie
		do compute_paroisses ; // On redessine
	}

	reflex MaJ_poles {
		do update_poles;
	}
	
//	reflex MaJ_satisfaction_FP_bis {		
//		// Tous les FP d'un agrégat auront les mêmes satis religieuses et protection
//		ask Agregats {
//			do update_satisfaction_religieuse_fp;
//			do update_satisfaction_protection_fp;
//		}
//		
//		ask Foyers_Paysans {
//			do update_satisfaction_materielle;
//			if (self.monAgregat = nil){
//				do update_satisfaction_religieuse;
//				do update_satisfaction_protection;
//				set Satisfaction <- 0.75 * min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
//			} else {
//				set Satisfaction <- 0.75 * min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
//				set Satisfaction <- (self.monAgregat.communaute) ? Satisfaction + 0.25 : Satisfaction;
//			}
//		}
//	}
	
	reflex MaJ_satisfaction_FP {
		ask  Foyers_Paysans {
			do update_satisfaction_materielle;
			do update_satisfaction_religieuse;
			do update_satisfaction_protection;
			set satisfaction <- 0.75 * min([s_religieuse, s_protection,  s_materielle]);
			if (self.monAgregat != nil){
				set satisfaction <- (self.monAgregat.communaute) ? satisfaction + 0.25 : satisfaction;
			}
		}
	}
	
	reflex Deplacement_FP {
		ask Foyers_Paysans where (each.mobile) {
			do deplacement;
		}
		ask Foyers_Paysans where (!each.mobile){
				do deplacement_serfs;
			}
	}
	
	reflex MaJ_Droits_Seigneurs {
		ask Seigneurs where (each.type != "Grand Seigneur") {
			do gains_droits_ps;
		}
	}
	
	reflex MaJ_Droits_Haute_Justice_GS when: (proba_gain_haute_justice_gs_actuel > 0.0){
		ask Seigneurs where (each.type = 'Grand Seigneur' and !each.droits_haute_justice){
			do maj_droits_haute_justice_gs;
		}
	}
	
	reflex MaJ_ZP_et_preleveurs {
		ask Foyers_Paysans {do reset_preleveurs;}
		ask Seigneurs {do reset_variables;}
		ask Zones_Prelevement {
			do update_prelevements;
		}
		do prelevements_fonciers_gs;
		do prelevements_haute_justice_gs;
	}
	
	reflex Dons_PS when: (annee >= debut_cession_droits_seigneurs) {
		ask Seigneurs where (each.type != "Grand Seigneur"){
			do don_droits_ps;
		}
	}
	
	reflex Dons_Chateaux when: (annee >= debut_garde_chateaux_seigneurs){
		list<Chateaux> chateaux_sans_gardiens <- Chateaux where (each.gardien = nil);
		loop ceChateau over: chateaux_sans_gardiens {
			if (flip(proba_don_chateau)) { // On donne
				ask ceChateau.proprietaire {
					do don_chateau(chateau_donne: ceChateau);
				}
			} // On ne donne pas
		}
	}
	
	reflex MaJ_Puissance_Seigneurs {
		ask Seigneurs {
			do MaJ_puissance;
		}
	}
	
	reflex Promotion_Chateaux when: chateaux_promouvables{
		ask Chateaux where (each.type = "Petit Chateau"){
			do promotion_chateau;
		}	
	}
	
	reflex Constructions_chateaux when: annee >= debut_construction_chateaux{
		set agregats_loins_chateaux <- Agregats inside espace_dispo_chateaux;
		// Pour les GS
		ask Seigneurs where (each.type = "Grand Seigneur"){
			if (espace_dispo_chateaux != nil){do construction_chateaux;}
		}
		// Pour les PS
		bool construction_chateau_ps <- flip(proba_construction_chateau_ps);
		if (espace_dispo_chateaux != nil and construction_chateau_ps){
			list<Seigneurs> tousPS <- (Seigneurs where (each.type != "Grand Seigneur" and each.puissance > 0)) sort_by (each);
			Seigneurs seigneurConstructeur <- tousPS at rnd_choice(tousPS collect (each.puissance));
			ask seigneurConstructeur {do construction_chateaux;}
		}			
	}
	
	reflex MaJ_Agregats{
		do update_agregats;
		do creation_nouveaux_seigneurs;
		ask Seigneurs where (each.type != "Grand Seigneur"){do update_agregats_seigneurs;}
		if (length(Chateaux) > 0){
			ask Agregats {do update_chateau;}
		}
		ask Agregats {do update_attractivite;}
	}
	
	reflex MaJ_poles_bis {
		do update_poles;
	}
	
	reflex update_outputs when: (annee > debut_simulation){
		do update_summarised_outputs;
		write "Seed : " + seed + " / Annee : " + annee + " / Nb Agregats : " + length(Agregats) + " / TxIsoles : " + prop_fp_isoles;
	}
	
	reflex save_data when: save_outputs {
		do save_outputs_data;
	}
	
	reflex save_summarised_outputs when: summarised_outputs{
		do save_summarised_data;
	}
	
//	reflex print_zp {
//write "Foncier : " + Zones_Prelevement count (each.type_droit = "foncier");
//write "Haute-Justice : "+ Zones_Prelevement count (each.type_droit = "haute_justice"); 
//write "Autres : " + Zones_Prelevement count (each.type_droit = "autres_droits"); 
//	}
	
	reflex fin_simulation {
		set nb_chateaux <- length(Chateaux);
		if (annee >= fin_simulation) {
			write 'Durée simulation : ' + total_duration;
			 write "Nb châteaux :  GS :" + string(length(Chateaux where (each.proprietaire.type = "Grand Seigneur"))) + " / PS : " + string(length(Chateaux where (each.proprietaire.type != "Grand Seigneur")));
			if (experimentType = "batch"){
				do halt;
			} else {
				do pause;
			}	
		}
	}
}
