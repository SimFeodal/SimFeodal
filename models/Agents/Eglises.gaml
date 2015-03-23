/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
//import "../GUI.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agregats.gaml"
import "Chateaux.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"


entities {
	
	species Paroisses {
		Eglises monEglise <- nil;
		list<Foyers_Paysans> mesFideles <- nil ;
		rgb color <- #white ;
		float Satisfaction_Paroisse <- 1.0 ;
		
		action update_fideles {
			set mesFideles <- Foyers_Paysans inside self ;
		}
		action update_satisfaction {
			if length(mesFideles) > 0 {
				float satisfaction_fideles <- mean(mesFideles collect each.satisfaction_religieuse);
				int nombre_fideles <- length(mesFideles) ;
				set Satisfaction_Paroisse <- min([1, (20/nombre_fideles)]) * satisfaction_fideles;	
			} else {
				set Satisfaction_Paroisse <- 1.0 ;
			}
		}
		
		
		aspect base {
			draw shape color: color;
		}
	}
	
	species Eglises parent: Attracteurs schedules: shuffle(Eglises) {
		string type;
		//list<string> droits_paroissiaux <- []; // ["Baptême" / "Inhumation" / "Eucharistie"]
		bool eglise_paroissiale <- false;
		int attractivite <- 0;
		rgb color <- #blue ;
		bool reel <- false;
		
		action update_attractivite {
			//set attractivite <- length(droits_paroissiaux);
		}
		
		action update_droits_paroissiaux {
			if (!eglise_paroissiale) {
				set eglise_paroissiale <- flip(proba_gain_droits_paroissiaux);
				if (eglise_paroissiale) {set reel <- true;}
			}
		}
		
		
		aspect base {
			draw circle(200) color: color ;
		}
		
	}
	

}