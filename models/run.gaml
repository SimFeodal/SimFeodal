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


global schedules: list(world) + list(Attracteurs) + list(Agregats) + list(Foyers_Paysans) + list(Chateaux) + list(Eglises) + list(Seigneurs){
    
    
	init {
		float t <- machine_time;
		do generer_monde;
		write 'Generation monde : ' + string(machine_time - t);
	}
	
	reflex MaJ_globale {
		do reset_globals;
	}
	
	
	reflex renouvellement_monde when: (time > 0){
		do renouvellement_FP;
	}
		
	reflex MaJ_Agregats{
		float t <- machine_time;
		do update_agregats;
		do creation_nouveaux_seigneurs;
		if (length(Chateaux) > 0){
			ask Agregats {do update_chateau;}
		}
		ask Agregats {do update_attractivite;}
		write 'MaJ_Agregats : ' + string(machine_time - t);
	}
	
	reflex Demenagement_FP {
		float t <- machine_time;
		ask Foyers_Paysans{
			do demenagement;
		}
		write 'Demenagement_FP : ' + string(machine_time - t);
		
	}
	
	reflex MaJ_Chateaux {
		ask Chateaux {do update_attractivite;}
	}
	
	
	reflex MaJ_Eglises {
		ask Eglises {do update_attractivite;}
		//ask Eglises where (!each.eglise_paroissiale) {do update_droits_paroissiaux;}
	}
	
	
	reflex MaJ_Droits_Seigneurs {
		ask Seigneurs where (each.type="Grand Seigneur"){do MaJ_droits_Grands_Seigneurs;}
		ask Seigneurs where (each.type != "Grand Seigneur") { do MaJ_droits_Petits_Seigneurs; do gains_droits_PS; }
	}
	
	
	reflex MaJ_ZP_et_preleveurs {
		float t <- machine_time;
		ask Zones_Prelevement {do update_shape;}
		ask Foyers_Paysans {do reset_preleveurs;}
		ask Seigneurs {do reset_variables;}
		do attribution_loyers_FP;

		float tt1 <- machine_time;
		ask Zones_Prelevement where (each.type_droit = "Haute_Justice"){do update_taxes_FP_HteJustice;}
		write 'taxes ZP Hte Justice : ' + string(machine_time - tt1);
		float tt2 <- machine_time;
		ask Zones_Prelevement where (each.type_droit = "Banaux"){do update_taxes_FP_Banaux;}
		write 'taxes ZP banaux : ' + string(machine_time - tt2);
		float tt3 <- machine_time;
		ask Zones_Prelevement where (each.type_droit = "basseMoyenne_Justice"){do update_taxes_FP_BM_Justice;}
		write 'taxes ZP BM Justice : ' + string(machine_time - tt3);
		
		write 'MaJ_ZP_et_preleveurs : ' + string(machine_time - t);
	}
	
		
	reflex Dons_des_Seigneurs {
		// Don droits
		if (Annee > 880) {
			ask Seigneurs where (each.type = "Grand Seigneur"){ do don_droits_GS; }
			ask Seigneurs where (each.type != "Grand Seigneur"){ do don_droits_PS; }
		}
		// Don châteaux
		if (Annee > 950) {
			ask Seigneurs where (each.type = "Grand Seigneur"){ do update_droits_chateaux_GS; do don_chateaux_GS; }
		}
		ask Seigneurs { do MaJ_puissance; do MaJ_puissance_armee; }
	}
	
	
	reflex Constructions_chateaux {
		ask Seigneurs where (each.type = "Grand Seigneur" and each.puissance > 2000) { do construction_chateau_GS;}
		ask Seigneurs where (each.type != "Grand Seigneur" and each.puissance > 2000){ do construction_chateau_PS;}
	}
	
	
	reflex MaJ_satisfaction_FP {
		float t <- machine_time;
		ask Foyers_Paysans {do update_satisfaction;}
		write 'MaJ_satisfaction_FP : ' + string(machine_time - t);
	}
	
	
	reflex MaJ_paroisses {
		do compute_paroisses ;
		ask Paroisses {
			do update_fideles;
			do update_satisfaction;
		}
		do create_paroisses ;
		do compute_paroisses ;
		do promouvoir_paroisses;
		do compute_paroisses ;
	}
	
	
	reflex update_plot {
		set nb_non_demenagement <- length(Foyers_Paysans) - (nb_demenagement_local + nb_demenagement_lointain) ;
		ask Seigneurs {
			set monNbZP <- Zones_Prelevement count ((each.preleveurs.keys contains self) or (each.proprietaire = self));
		}
	}
	
	reflex save_data when: save_outputs {
		float t <- machine_time;
		do save_Parameters;
		do save_FP;
		do save_Agregats;
		do save_ZP;
		do save_Chateaux;
		do save_Seigneurs;
		do save_Eglises;
		do save_Paroisses;
		write 'Output FP data : ' + string(machine_time - t);
	}
	
	reflex fin_simulation {
		set nb_chateaux <- length(Chateaux);
		if (Annee >= fin_simulation) {do halt;}
	}
}
