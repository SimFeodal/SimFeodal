/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "global.gaml"
//import "GUI.gaml"
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
		create Foyers_Paysans number: nombre_agglos_antiques {
			set location <- any_location_in(reduced_worldextent);
			set mobile <- flip (taux_mobilite);
			
			//FP_controlles
			list<Foyers_Paysans> pool_FP <- [self];
			create Foyers_Paysans number: (30 - 1) {
				pool_FP <+ self ;
				// On choisit un des FP de la même agglo
				agent myFP <- one_of(pool_FP);
				set location <- any_location_in(99 around myFP.location);
				set mobile <- flip (taux_mobilite);
			}
		}
		// Villages
		create Foyers_Paysans number: nombre_villages {
			set location <- any_location_in(reduced_worldextent);
			set mobile <- flip (taux_mobilite);
			
			list<Foyers_Paysans> pool_FP <- [self];
			create Foyers_Paysans number: (nombre_foyers_villages - 1) {
				pool_FP <+ self ;
				// On choisit un des FP de la même agglo
				agent myFP <- one_of(pool_FP);
				set location <- any_location_in(99 around myFP.location);
				set mobile <- flip (taux_mobilite);
			}
		}
		// FP isolés
		int nb_FP_isoles <- nombre_foyers_paysans - (nombre_agglos_antiques * 30) - (nombre_villages * nombre_foyers_villages);
		create Foyers_Paysans number: nb_FP_isoles {
			set location <- any_location_in(worldextent);
			set mobile <- flip (taux_mobilite);
		}
	}
	
	
	action generer_seigneurs {
		create Seigneurs number: nombre_grands_seigneurs{
			set type <- "Grand Seigneur";
			set taux_prelevement <- 1.0;
			set initialement_present <- true;
			
			set droits_loyer <-true;
			set droits_hauteJustice <- false;
			set droits_banaux <- false;
			set droits_moyenneBasseJustice <- false;
		}
		
		create Seigneurs number: nombre_petits_seigneurs {
			set type <- "Petit Seigneur";
			set initialement_present <- true;
			set taux_prelevement <- 1.0;
			set location <- any_location_in(one_of(Agregats collect each.shape));
			
			
			set droits_loyer <- true;
			set droits_hauteJustice <- false;
			set droits_banaux <- false;
			set droits_moyenneBasseJustice <- false;
			
			int rayon_zone <- rayon_min_PS_init + rnd(rayon_max_PS_init - rayon_min_PS_init);
			float txPrelev <- min_fourchette_loyers_PS_init + rnd(max_fourchette_loyers_PS_init - min_fourchette_loyers_PS_init);
			do creer_zone_prelevement(self.location, rayon_zone, self, "Loyer", txPrelev);
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
		create Eglises number: nombre_eglises {
			//set droits_paroissiaux <- flip(1/3) ? ["Baptême"] : [];
			set eglise_paroissiale <- flip(1/3);
			set location <- any_location_in(20000 around one_of(Agregats));
		}
	}
	
	action generer_monde {
		do generer_foyers_paysans;
		do update_agregats;
		do generer_seigneurs;
		do attribuer_puissance_seigneurs;
		do generer_eglises;
	}
	
}