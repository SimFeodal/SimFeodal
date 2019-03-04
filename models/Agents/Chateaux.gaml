/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agregats.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"


	species Chateaux parent: Attracteurs  schedules: []{
	
		string type <- "Petit Chateau";
		float attractivite <- 0.0;
		Agregats monAgregat <- nil;
		Seigneurs proprietaire <- nil;
		Seigneurs gardien <- nil;
		int rayon_zp_chateau;
		bool droits_haute_justice <- false;
		
		
		action promotion_chateau {
			Poles monPole <- shuffle(Poles) first_with (each.mesAttracteurs contains self);
			if (!empty(list(monPole))){
				if (length(monPole.mesAttracteurs) > 1){
					set type <- flip(proba_promotion_chateau_pole) ? "Grand Chateau" : "Petit Chateau";
				} else {
					set type <- flip(proba_promotion_chateau_isole) ? "Grand Chateau" : "Petit Chateau";
				}
			} else {
				set type <- flip(proba_promotion_chateau_isole) ? "Grand Chateau" : "Petit Chateau";
			}
		}
		
		aspect base {
			draw circle(500) color: #red ;
		}
	}