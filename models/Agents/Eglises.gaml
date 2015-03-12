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
	
	species Eglises parent: Attracteurs schedules: shuffle(Eglises) {
		string type;
		//list<string> droits_paroissiaux <- []; // ["Baptême" / "Inhumation" / "Eucharistie"]
		bool eglise_paroissiale <- false;
		int attractivite <- 0;
		rgb color <- #blue ;
		
		action update_attractivite {
			//set attractivite <- length(droits_paroissiaux);
		}
		
		action update_droits_paroissiaux {
			if (!eglise_paroissiale) {
				set eglise_paroissiale <- flip(proba_gain_droits_paroissiaux);
			}
		}
		
		aspect base {
			draw circle(200) color: color ;
		}
		
	}
	

}