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
		float t <- machine_time;
		do generer_monde;
		set espace_dispo_chateaux <- worldextent - 3 #km;
	}
	
	reflex MaJ_globals {
		float t <- machine_time;
		do update_variables_temporelles;
		write string(annee);
		if (benchmark){write 'MaJ_globals : ' + string(machine_time - t);}
	}
		
	reflex renouvellement_monde when: (time > 0){
		float t <- machine_time;
		do renouvellement_FP;
		if (benchmark){write 'renouvellement_monde : ' + string(machine_time - t);}
	}
		

	reflex MaJ_paroisses {
		float t <- machine_time;
		do compute_paroisses ; // On redécoupe
		do create_paroisses ; // On crée les paroisses des agrégats
		do compute_paroisses ; // On redessine
		do promouvoir_paroisses; // On nomme/crée de  nouvelles paroisses là où la population est mal desservie
		do compute_paroisses ; // On redessine
		if (benchmark){write 'MaJ_paroisses : ' + string(machine_time - t);}
	}

	reflex MaJ_poles {
		float t <- machine_time;
		do update_poles;
		if (benchmark){write 'MaJ_poles : ' + string(machine_time - t);}
	}
	
	reflex MaJ_satisfaction_FP {
		float t0 <- machine_time;
		ask  Foyers_Paysans {
			do update_satisfaction_materielle;
		}
		if (benchmark){write 'update_satisfaction_materielle : ' + string(machine_time - t0);}
		float t <- machine_time;
		ask  Foyers_Paysans {
			do update_satisfaction_religieuse;
		}
		if (benchmark){write 'update_satisfaction_religieuse : ' + string(machine_time - t);}
		set t <- machine_time;
		ask  Foyers_Paysans {
			do update_satisfaction_protection;
		}
		if (benchmark){write 'update_satisfaction_protection : ' + string(machine_time - t);}
		set t <- machine_time;
		ask Foyers_Paysans {
			set Satisfaction <- 0.75 * min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
			if (self.monAgregat != nil){
				set Satisfaction <- (self.monAgregat.communaute) ? Satisfaction + 0.25 : Satisfaction;
			}
		}
	if (benchmark){write 'Maj_Satis_globale : ' + string(machine_time - t);}		
	if (benchmark){write 'MaJ_satisfaction_FP : ' + string(machine_time - t0);}
	}
	
	reflex Deplacement_FP {
		float t <- machine_time;
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

		if (benchmark){write 'Deplacement_FP : ' + string(machine_time - t);}
	}
	
	reflex MaJ_Droits_Seigneurs {
		float t <- machine_time;
		ask Seigneurs where (each.type != "Grand Seigneur") {
			do gains_droits_ps;
		}
		if (benchmark){write 'MaJ_Droits_Seigneurs : ' + string(machine_time - t);}
	}
	
	reflex MaJ_Droits_Haute_Justice_GS when: (proba_gain_haute_justice_gs_actuel > 0.0){
		ask Seigneurs where (each.type = 'Grand Seigneur' and !each.droits_haute_justice){
			do maj_droits_haute_justice_gs;
		}
	}
	
	reflex MaJ_ZP_et_preleveurs {
				float t <- machine_time;
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
				if (benchmark){write 'MaJ_ZP_et_preleveurs : ' + string(machine_time - t);}
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
	if (benchmark){write 'Dons_des_Seigneurs : ' + string(machine_time - t);}
	}
	
	reflex Promotion_Chateaux when: chateaux_promouvables{
		float t <- machine_time;
			ask Chateaux where (each.type = "Petit Chateau"){
				do promotion_chateau;
			}	
			if (benchmark){write 'Promotion_Chateaux : ' + string(machine_time - t);}
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
		float t <- machine_time;
		do update_agregats;
//		
		do creation_nouveaux_seigneurs;
		ask Seigneurs where (each.type != "Grand Seigneur"){do update_agregats_seigneurs;}
		if (length(Chateaux) > 0){
			ask Agregats {do update_chateau;}
		}
		ask Agregats {do update_attractivite;}
					if (benchmark){write 'MaJ_Agregats : ' + string(machine_time - t);}
	}
	
	reflex MaJ_poles_bis {
		float t <- machine_time;
		do update_poles;
		if (benchmark){write 'MaJ_poles_bis : ' + string(machine_time - t);}
	}
	
	reflex update_outputs when: (annee > debut_simulation){
		float t <- machine_time;
		do update_summarised_outputs;
		//write "espace_dispo_chateaux : " + string(espace_dispo_chateaux.area / 1E6) + "km²";
		write "Seed : " + seed + " / Annee : " + annee + " / Nb Agregats : " + length(Agregats) + " / TxIsoles : " + prop_FP_isoles;
	}
	
	reflex save_data when: save_outputs {
		float t <- machine_time;
		do save_outputs_data;
		if (benchmark){write 'save_data : ' + string(machine_time - t);}
	}
	
	
	reflex fin_simulation {
		float t <- machine_time;
		set nb_chateaux <- length(Chateaux);
		if (annee >= fin_simulation) {
			write 'Durée simulation : ' + total_duration;
			if (experimentType = "batch"){
				do halt;
			} else {
				do pause;
			}	
		}
		if (benchmark){write 'fin_simulation : ' + string(machine_time - t);}
	}
}
