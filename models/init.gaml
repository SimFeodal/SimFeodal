/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "global.gaml"
import "T8.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Agglomerations.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"

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
	
	action generer_chateaux {
		create Chateaux number: nombre_chateaux {
			set location <- any_location_in(reduced_worldextent);
			set monSeigneur <- nil;
		}
	}
	
	action generer_seigneurs {
		create Seigneurs number: nombre_chateaux {
			set FP_controlles <- 2 among Foyers_Paysans;
			set chateaux_controlles <- 1 among Chateaux where (each.monSeigneur = nil);
			ask chateaux_controlles {
				set monSeigneur <- myself;
			}
		}
	}

	action generer_eglises {
		create Eglises number: nombre_eglises {
			set location <- any_location_in(reduced_worldextent);
		}
	}
	
	action generer_monde {
		do generer_foyers_paysans;
		do generer_chateaux;
		do generer_seigneurs;
		do generer_eglises;
	}
	
}