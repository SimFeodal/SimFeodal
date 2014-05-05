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

entities {
	species Seigneurs {
		string type;
		float richesse <- 5.0;
		float pouvoir_armee;
		list<Foyers_Paysans> FP_controlles;
		list<Chateaux> chateaux_controlles;
		list<Seigneurs> vassaux;
		float richesse_autorite_centrale;
		
		reflex MaJ_FP_controlles {
			set FP_controlles <- 2 among Foyers_Paysans;
			ask FP_controlles {
				mesSeigneurs << myself;
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