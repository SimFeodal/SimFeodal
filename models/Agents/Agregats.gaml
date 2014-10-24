/**
 *  T8
 *  Author: Robin
 *  Description: Les agglomérations sont des agents "persistants", mais dont on vérifie l'existence à chaque pas de temps.
 */

model t8

import "../init.gaml"
import "../GUI.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"


entities {

	species Agregats parent: Attracteurs schedules: shuffle(Agregats){
		bool fake_agregat <- false;
		int attractivite <- 0;
		list<Foyers_Paysans> fp_agregat ;
		bool communaute_agraire <- false;
		bool marche <- false;
		Chateaux monChateau <- nil;
		
		action update_shape {
			set shape <- convex_hull(polygon(fp_agregat collect each.location));
		}
		
		action update_attractivite {
			// Temporairement désactivé
			//set attractivite <- length(fp_agregat) +  sum(Chateaux where (self = each.monAgregat) collect each.attractivite);
			set attractivite <- length(fp_agregat);
		}
		
		
		action update_comm_agraire {
			if (!self.communaute_agraire) {
				if (rnd(100) > 80) {
					set communaute_agraire <- true;
					ask self.fp_agregat {
						set comm_agraire <- true;
					}
				} else {
					ask self.fp_agregat {
						set comm_agraire <- false;
					}
				}
			} else {
				ask self.fp_agregat {
					set comm_agraire <- true;
				}
			}
		}
		
		
	}
}