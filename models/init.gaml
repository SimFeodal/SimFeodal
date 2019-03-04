/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "global.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"

import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"


global {
	
	action generer_foyers_paysans {
		// Agglos antiques
		create Foyers_Paysans number: init_nb_agglos {
			set location <- any_location_in(reduced_worldextent);
			set mobile <- flip (1 - proba_fp_dependant);
			
			list<Foyers_Paysans> pool_FP <- [self]; 
			create Foyers_Paysans number: (init_nb_fp_agglo - 1) {
				agent myFP <- one_of(pool_FP);
				set location <- any_location_in(((distance_detection_agregat -  1) around myFP.location) inter reduced_worldextent);
				set mobile <- flip (1 - proba_fp_dependant);
				pool_FP <+ self ;
			}
		}
		// Villages
		create Foyers_Paysans number: init_nb_villages {
			set location <- any_location_in(reduced_worldextent);
			set mobile <- flip (1 - proba_fp_dependant);
			
			list<Foyers_Paysans> pool_FP <- [self];
			create Foyers_Paysans number: (init_nb_fp_village - 1){
				agent myFP <- one_of(pool_FP);
				set location <- any_location_in(((distance_detection_agregat -  1) around myFP.location) inter reduced_worldextent);
				set mobile <- flip (1 - proba_fp_dependant);
				pool_FP <+ self ;
			}
		}
		// FP isolés
		int nb_FP_isoles <- init_nb_total_fp - length(Foyers_Paysans);
		create Foyers_Paysans number: nb_FP_isoles {
			set location <- any_location_in(reduced_worldextent);
			set mobile <- flip (1 - proba_fp_dependant);
		}
	}
	
	
	action generer_seigneurs {
		create Seigneurs number: init_nb_gs {
			set type <- "Grand Seigneur";
			set initial <- true;
		}
		
		create Seigneurs number: init_nb_ps {
			set type <- "Petit Seigneur";
			set location <- any_location_in(one_of(Agregats collect each.shape) inter reduced_worldextent);
			set initial <- true;
			
			int rayon_zone <- rayon_min_zp_ps + rnd(rayon_max_zp_ps - rayon_min_zp_ps);
			float txPrelev <- min_taux_prelevement_zp_ps + rnd(max_taux_prelevement_zp_ps - min_taux_prelevement_zp_ps);
			Seigneurs ceSeigneur <- self;
			ask world {
				do creer_zone_prelevement (centre_zone: ceSeigneur.location, rayon: rayon_zone, proprio: ceSeigneur, typeDroit: "foncier", txPrelev: txPrelev, chateau_zp: nil);
			}
		}
	}
	
	action attribuer_puissance_seigneurs {
		list<Seigneurs> Grands_Seigneurs <- Seigneurs where (each.type = "Grand Seigneur");
		if (length(Grands_Seigneurs) = 1){
			ask Grands_Seigneurs {
				set puissance_init <- 1.0;
			}
		} else {
			ask Grands_Seigneurs at 0 {
				set puissance_init <- puissance_grand_seigneur1 / (puissance_grand_seigneur1 + puissance_grand_seigneur2);
			}
			ask Grands_Seigneurs at 1 {
				set puissance_init <- puissance_grand_seigneur2 / (puissance_grand_seigneur1 + puissance_grand_seigneur2);
			}
		}
	}

	action generer_eglises {
		create Eglises number: init_nb_eglises {
			set location <- any_location_in(reduced_worldextent);
		}
		ask (init_nb_eglises_paroissiales among Eglises) {
			set eglise_paroissiale <- true;
			set mode_promotion <- "initialisation";
		}
	}
	
	action generer_monde {
		do update_variables_temporelles;
		do generer_foyers_paysans;
		do generer_eglises;
		do update_agregats;
		do generer_seigneurs;
		do attribuer_puissance_seigneurs;
	}
	
}