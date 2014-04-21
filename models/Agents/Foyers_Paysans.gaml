/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../T8.gaml"
import "../global.gaml"
import "Agglomerations.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"

entities {
	species Foyers_Paysans {
		string type;
		bool comm_agraire <- false;
		Agglomerations monAgglo <- nil;
		float Satisfaction ;
		list<Seigneurs> mesSeigneurs ;
		
		reflex update_comm_agraire {
			if (monAgglo = nil){
				set comm_agraire <- false ;
			} else if (comm_agraire = false and monAgglo.Communaute_agraire and (rnd(100) / 100 > 0.75)){
					set comm_agraire <- true ;
			}
		}
		
		float update_satisfaction_materielle {
			//f(Droits paroissiaux) + f(Droits seigneuriaux) + f(Comm agraire)
			return rnd(100) / 100;
		}
		
		float update_satisfaction_spirituelle {
			// f(Frequentation eglise) + f(distance église)
			return rnd(100) / 100 ;
		}
		
		float update_satisfaction_protection {
			// Protection seigneur = f(Nb_FP)
			if (length(self.mesSeigneurs) > 0){
			write "Local : " + string(sum(mesSeigneurs collect length(each.FP_controlles)));
			write "Global : " + string(sum(Seigneurs collect length(each.FP_controlles)));
			}

			float ratio_fp_seigneurs <- sum(mesSeigneurs collect length(each.FP_controlles)) / sum(Seigneurs collect length(each.FP_controlles));
			//write ratio_fp_seigneurs;
			return ratio_fp_seigneurs;
		}
		
		reflex update_satisfaction {
			set Satisfaction <- (update_satisfaction_materielle() + update_satisfaction_spirituelle() + update_satisfaction_protection()) / 3;
		}
		
		
		reflex demenagement {
			if (Satisfaction < 0.1) {
				//do die;
			} else if (Satisfaction < 0.2) {
				//do demenagement_lointain;
			} else {
				do demenagement_local;
			}
		}
				
		action demenagement_local {
			location <- any_location_in(100 around self.location);
			//write "local";
		}
		
		action demenagement_lointain {
			location <- any_location_in(worldextent);
			//write "lointain";
		}
	rgb color <- rgb('gray') ;
	aspect base {
		draw circle(500) color: color;
	}	
	}
}