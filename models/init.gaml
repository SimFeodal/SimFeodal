/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "global.gaml"
import "T8.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"

import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Amenites.gaml"

global {
	action generer_foyers_paysans {
		// Création agglos antiques
		list centres_agglos <- [];
		loop times: nombre_agglos_antiques {
			add any_location_in(reduced_worldextent) to: centres_agglos;
		}
		loop centre_actuel over: centres_agglos {
			create Foyers_Paysans number: 30 {
				set location <- any_location_in(300 around centre_actuel);
			}
		}
		// Création villages
		list centres_villages <- [];
		loop times: nombre_villages {
			add any_location_in(reduced_worldextent) to: centres_villages;
		}
		loop centre_actuel over: centres_villages {
			create Foyers_Paysans number: nombre_foyers_villages {
				set location <- any_location_in((10 * nombre_foyers_villages) around centre_actuel);
			}
		}
		// Création FP
		create Foyers_Paysans number: (nombre_foyers_paysans - ((nombre_agglos_antiques * 30) + (nombre_villages * nombre_foyers_villages))) {
			set location <- any_location_in(worldextent);
		}
	}
	
	action generer_foyers_paysans_grappe {
		// Agglos antiques
		create Foyers_Paysans number: nombre_agglos_antiques {
			set location <- any_location_in(reduced_worldextent);
			set mobile <- flip (taux_mobilite);
			set mesSeigneurs <- (rnd(3) + 1) among Seigneurs;
			ask mesSeigneurs {
				FP_controlles <+ myself;
			}
			//FP_controlles
			list<Foyers_Paysans> pool_FP <- [self];
			create Foyers_Paysans number: (30 - 1) {
				pool_FP <+ self ;
				// On choisit un des FP de la même agglo
				agent myFP <- one_of(pool_FP);
				set location <- any_location_in(199 around myFP.location);
				set mobile <- flip (taux_mobilite);
				set mesSeigneurs <- (rnd(3) + 1) among Seigneurs;
				ask mesSeigneurs {
					FP_controlles <+ myself;
				}
			}
		}
		// Villages
		create Foyers_Paysans number: nombre_villages {
			set location <- any_location_in(reduced_worldextent);
			set mobile <- flip (taux_mobilite);
			set mesSeigneurs <- (rnd(3) + 1) among Seigneurs;
			ask mesSeigneurs {
				FP_controlles <+ myself;
			}
			list<Foyers_Paysans> pool_FP <- [self];
			create Foyers_Paysans number: (nombre_foyers_villages - 1) {
				pool_FP <+ self ;
				// On choisit un des FP de la même agglo
				agent myFP <- one_of(pool_FP);
				set location <- any_location_in(199 around myFP.location);
				set mobile <- flip (taux_mobilite);
				set mesSeigneurs <- (rnd(3) + 1) among Seigneurs;
				ask mesSeigneurs {
					FP_controlles <+ myself;
				}
			}
		}
		// FP isolés
		int nb_FP_isoles <- nombre_foyers_paysans - (nombre_agglos_antiques * 30) - (nombre_villages * nombre_foyers_villages);
		create Foyers_Paysans number: nb_FP_isoles {
			set location <- any_location_in(worldextent);
			set mobile <- flip (taux_mobilite);
			set mesSeigneurs <- (rnd(3) + 1) among Seigneurs;
			ask mesSeigneurs {
					FP_controlles <+ myself;
			}
		}
	}
	
	action generer_chateaux {
		create Chateaux number: nombre_chateaux {
			set location <- any_location_in(reduced_worldextent);
			set monSeigneur <- nil;
		}
	}
	
	action generer_seigneurs {
		create Seigneurs number: nombre_seigneurs {
			set taux_prelevement <- rnd(100) / 100;
			set type <- "Grand Seigneur";
		}
		
		
	}

	action generer_eglises {
		create Eglises number: nombre_eglises {
			set droits_paroissiaux <- flip(1/3) ? ["Baptême"] : [];
			set location <- any_location_in(reduced_worldextent);
		}
	}
	
	action generer_monde {
		//do generer_foyers_paysans;
		do generer_seigneurs;
		do generer_foyers_paysans_grappe;
		do generer_chateaux;
		do generer_eglises;
	}
	
}