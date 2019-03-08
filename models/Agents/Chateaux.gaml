/**
 *  SimFeodal
 *  Author: R. Cura, C. Tannier, S. Leturcq, E. Zadora-Rio
 *  Description: https://simfeodal.github.io/
 *  Repository : https://github.com/SimFeodal/SimFeodal
 *  Version : 6.3
 *  Run with : Gama 1.8 (git) (1.7.0.201903051304)
 */

model simfeodal

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