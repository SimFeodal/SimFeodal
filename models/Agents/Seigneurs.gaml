/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../T8.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agglomerations.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Amenites.gaml"

entities {
	species Seigneurs {
		string type <- "Petit Seigneur"; // Grand Seigneur / Chatelain / Petit Seigneur 
		float richesse <- 1.0;
		float pouvoir_armee <- 0.0;
		float taux_prelevement <- 1.0;
		list<Foyers_Paysans> FP_controlles <- [];
		list<Chateaux> chateaux_controlles <- [];
		list<Seigneurs> vassaux <- [];
		float richesse_autorite_centrale;
		
		reflex MaJ_richesse {
			set richesse <- richesse + (length(FP_controlles) * taux_prelevement);
		}
		
		reflex construction_chateau when: (richesse > 2000){
			if (rnd(100) / 100 > 0.7) {
				Chateaux nouveauChateau <- nil;
				Seigneurs proprio <- nil;
				if (rnd(10) >= 5 or (self.type = "Petit Seigneur")) {
					set proprio <- self;
				} else {
					set proprio <- one_of(Seigneurs where (each.type = "Petit Seigneur"));
				}
				create Chateaux number: 1 {
					set monSeigneur <- proprio;
					set monAgglo <- one_of(Agglomerations);
					set location <- any_location_in(500 around monAgglo.location);
					set nouveauChateau <- self;
				}
				if (proprio != self) {
					vassaux <+ proprio;
					ask proprio {
						chateaux_controlles <+ nouveauChateau;
					}
				} else {
					chateaux_controlles <+ nouveauChateau;
				}

				set richesse <- self.richesse - 2000;		
			}
		}
		
		reflex MaJ_type {
			if (self.type != "Grand Seigneur") {
				set type <- (length(self.chateaux_controlles) > 0) ? "Chatelain" : "Petit Seigneur";
			}			
		}
		
		reflex MaJ_pouvoir_armee {
			set pouvoir_armee <- length(FP_controlles) + sum(vassaux collect each.richesse);
		}
		reflex disparition when: (richesse = 0){
			do die;
		}
	}
}