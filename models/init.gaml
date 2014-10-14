/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "global.gaml"
import "GUI.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"

import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"

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
				set location <- any_location_in(199 around myFP.location);
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
				set location <- any_location_in(199 around myFP.location);
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
			set taux_prelevement <- rnd(100) / 100;
		}
		
		create Seigneurs number: nombre_petits_seigneurs {
			set type <- "Petit Seigneur";
			set initialement_present <- true;
			set taux_prelevement <- rnd(100) / 100;
			set location <- any_location_in(one_of(Agregats collect each.shape));
			set rayon_captation <- min_rayon_captation_petits_seigneurs + rnd(max_rayon_captation_petits_seigneurs - min_rayon_captation_petits_seigneurs);
		}
	}

	action generer_eglises {
		create Eglises number: nombre_eglises {
			set droits_paroissiaux <- flip(1/3) ? ["Baptême"] : [];
			set location <- any_location_in(reduced_worldextent);
		}
	}
	
	action generer_monde {
		do generer_foyers_paysans;
		do update_agregats;
		do generer_seigneurs;
		do generer_eglises;
	}
	
}