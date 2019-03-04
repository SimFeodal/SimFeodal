/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

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
		do update_variables_temporelles;
		set annee <- annee + duree_step;
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
	
	reflex MaJ_satisfaction_FP {
		ask  Foyers_Paysans {
			do update_satisfaction_materielle;
			do update_satisfaction_religieuse;
			do update_satisfaction_protection;
			set Satisfaction <- 0.75 * min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
			if (self.monAgregat != nil){
				set Satisfaction <- (self.monAgregat.communaute) ? Satisfaction + 0.25 : Satisfaction;
			}
		}
	}
	

	reflex Deplacement_FP {
		ask Foyers_Paysans where (each.mobile) {
			do deplacement;
		}
		if (serfs_mobiles){ // Vaut toujours true maintenant (depuis la v5)
			ask Foyers_Paysans where (!each.mobile){
				do deplacement_serfs;
			}
		} else {
			ask Foyers_Paysans where (!each.mobile){
				set type_deplacement <- "Non mobile";
			}
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
		//set espace_dispo_chateaux <- reduced_worldextent - (dist_min_entre_chateaux around Chateaux);
		
		set agregats_loins_chateaux <- Agregats inside espace_dispo_chateaux;
		if (espace_dispo_chateaux != nil){
			ask Seigneurs{
				if (espace_dispo_chateaux != nil){do construction_chateaux;}
		}
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
		//write "espace_dispo_chateaux : " + string(espace_dispo_chateaux.area / 1E6) + "km²";
		write "Seed : " + seed + " / Annee : " + annee + " / Nb Agregats : " + length(Agregats) + " / TxIsoles : " + prop_FP_isoles;
	}
	
	reflex save_data when: save_outputs {
		do save_outputs_data;
	}
	}
	
	
	reflex fin_simulation {
		set nb_chateaux <- length(Chateaux);
		if (annee >= fin_simulation) {
			write 'Durée simulation : ' + total_duration;
			if (experimentType = "batch"){
				do halt;
			} else {
				do pause;
			}	
		}
	}
}
