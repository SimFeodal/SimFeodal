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


global schedules: list(world) + list(Attracteurs) + list(Poles)+ list(Agregats) + list(Foyers_Paysans) + list(Chateaux) + list(Eglises) + list(Seigneurs){
    
	init {
		float t <- machine_time;
		do generer_monde;
		if (benchmark){write 'init : ' + string(machine_time - t);}
	}
		
	reflex renouvellement_monde when: (time > 0){
		float t <- machine_time;
		do renouvellement_FP;
		if (benchmark){write 'renouvellement_monde : ' + string(machine_time - t);}
	}
		
	reflex MaJ_globals {
		float t <- machine_time;
		do update_besoin_protection;
		if (benchmark){write 'MaJ_globals : ' + string(machine_time - t);}
	}	

	reflex MaJ_Agregats{
		float t <- machine_time;
		do update_agregats;
		do creation_nouveaux_seigneurs;
		if (length(Chateaux) > 0){
			ask Agregats {do update_chateau;}
		}
		ask Agregats {do update_attractivite;}
		if (benchmark){write 'MaJ_Agregats : ' + string(machine_time - t);}
	}
	
	reflex Deplacement_FP {
		float t <- machine_time;
		ask Foyers_Paysans where (each.mobile) {
			do deplacement;
		}
		if (benchmark){write 'Deplacement_FP : ' + string(machine_time - t);}
	}
	
	reflex MaJ_Chateaux {
		float t <- machine_time;
		ask Chateaux {do update_attractivite;}
		if (benchmark){write 'MaJ_Chateaux : ' + string(machine_time - t);}
	}
	
	reflex MaJ_Eglises {
		float t <- machine_time;
		ask Eglises {do update_attractivite;}
		//ask Eglises where (!each.eglise_paroissiale) {do update_droits_paroissiaux;}
		if (benchmark){write 'MaJ_Eglises : ' + string(machine_time - t);}
	}
	
	reflex MaJ_Droits_Seigneurs {
		float t <- machine_time;
		ask Seigneurs where (each.type="Grand Seigneur"){do MaJ_droits_Grands_Seigneurs;}
		ask Seigneurs where (each.type != "Grand Seigneur") {
			do MaJ_droits_Petits_Seigneurs;
			do gains_droits_PS;
		}
		if (benchmark){write 'MaJ_Droits_Seigneurs : ' + string(machine_time - t);}
	}
	
	reflex MaJ_ZP_et_preleveurs {
		float t <- machine_time;
		ask Zones_Prelevement {do update_shape;}
		ask Foyers_Paysans {do reset_preleveurs;}
		ask Seigneurs {do reset_variables;}
		do attribution_loyers_FP;

		//float tt1 <- machine_time;
		ask Zones_Prelevement where (each.type_droit = "Haute_Justice"){do update_taxes_FP_HteJustice;}
		//write 'taxes ZP Hte Justice : ' + string(machine_time - tt1);
		//float tt2 <- machine_time;
		ask Zones_Prelevement where (each.type_droit = "Banaux"){do update_taxes_FP_Banaux;}
		//write 'taxes ZP banaux : ' + string(machine_time - tt2);
		//float tt3 <- machine_time;
		ask Zones_Prelevement where (each.type_droit = "basseMoyenne_Justice"){do update_taxes_FP_BM_Justice;}
		//write 'taxes ZP BM Justice : ' + string(machine_time - tt3);
		
		//write 'MaJ_ZP_et_preleveurs : ' + string(machine_time - t);
		if (benchmark){write 'MaJ_ZP_et_preleveurs : ' + string(machine_time - t);}
	}
	
	reflex Dons_des_Seigneurs {
		float t <- machine_time;
		// Don droits
		if (Annee >= 900) {
			ask Seigneurs where (each.type = "Grand Seigneur"){ do don_droits_GS; }
			ask Seigneurs where (each.type != "Grand Seigneur"){ do don_droits_PS; }
		}
		// Don châteaux
		if (Annee >= 950) {
			ask Seigneurs where (each.type = "Grand Seigneur"){ do update_droits_chateaux_GS; do don_chateaux_GS; }
		}
		ask Seigneurs { do MaJ_puissance; do MaJ_puissance_armee; }
		if (benchmark){write 'Dons_des_Seigneurs : ' + string(machine_time - t);}
	}
	
	reflex Constructions_chateaux when: Annee >= apparition_chateaux{
		float t <- machine_time;
		ask Seigneurs where (each.type = "Grand Seigneur" and each.puissance > 2000) { do construction_chateau_GS;}
		if (benchmark){write 'Constructions_chateaux 1/2 : ' + string(machine_time - t);}
		
		float t2 <- machine_time;
		ask Seigneurs where (each.type != "Grand Seigneur" and each.puissance > 2000){ do construction_chateau_PS;}
		if (benchmark){write 'Constructions_chateaux 2/2 : ' + string(machine_time - t2);}
	}
	
	reflex MaJ_satisfaction_FP {
		float t <- machine_time;
		ask  Foyers_Paysans {
			do update_satisfaction_materielle;
			do update_satisfaction_religieuse;
			do update_satisfaction_protection;
			set Satisfaction <- min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
		}
		if (benchmark){write 'update_satis : ' + string(machine_time - t);}	
	}
	
	reflex MaJ_paroisses {
		float t <- machine_time;
		do compute_paroisses ; // On redécoupe
		do create_paroisses ; // On crée les paroisses des agrégats
		do compute_paroisses ; // On redessine
		do promouvoir_paroisses; // On nomme/crée de  nouvelles paroisses là où la population est mal desse
		do compute_paroisses ; // On redessine
		if (benchmark){write 'MaJ_paroisses : ' + string(machine_time - t);}
	}
	
	reflex MaJ_poles {
		float t <- machine_time;
		do update_poles;
		if ( Annee >= 940 and Annee <= 1040 ){
		ask Chateaux where (each.type = "Petit Chateau"){
				do promotion_chateau;
			}	
		}
		if (benchmark){write 'MaJ_poles : ' + string(machine_time - t);}
	}
	
	reflex update_plot {
		float t <- machine_time;
		ask Seigneurs {
			set monNbZP <- Zones_Prelevement count ((each.preleveurs.keys contains self) or (each.proprietaire = self));
		}
		if (benchmark){write 'update_plot : ' + string(machine_time - t);}
	}
	
	reflex update_outputs when: (Annee > debut_simulation){
		if (Annee = (debut_simulation + duree_step)){
			set charge_fiscale_debut <- mean(Foyers_Paysans collect float(each.nb_preleveurs));
		}
		do update_agregats_fp ;
		do update_output_indexes;
		do update_outputs_fp;

	}
	
	reflex save_data when: save_outputs {
		float t <- machine_time;
		//float t <- machine_time;
		do save_Parameters;
		do save_FP;
		do save_Agregats;
		do save_ZP;
		do save_Chateaux;
		do save_Seigneurs;
		do save_Eglises;
		do save_Paroisses;
		//write 'Output FP data : ' + string(machine_time - t);
		if (benchmark){write 'save_data : ' + string(machine_time - t);}
	}
	
	reflex save_TMD_data when: save_TMD {
		do save_TMD;
	}
	
	reflex fin_simulation {
		float t <- machine_time;
		set nb_chateaux <- length(Chateaux);
		if (Annee >= fin_simulation) {
			write 'Durée simulation : ' + total_duration;
			do halt; // Si version  batch
			//do pause; // Si version GUI
		}
		if (benchmark){write 'fin_simulation : ' + string(machine_time - t);}
	}
}
