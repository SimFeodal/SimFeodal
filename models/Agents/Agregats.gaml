/**
 *  T8
 *  Author: Robin
 *  Description: Les agglomérations sont des agents "persistants", mais dont on vérifie l'existence à chaque pas de temps.
 */

model t8

import "../init.gaml"
import "../T8.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Amenites.gaml"

global {
	    reflex update_agregats {
	    	
	    	// 1 - On crée une liste des nouvelles agglos
	    	list agregats_detectees <- connected_components_of(list(Foyers_Paysans) as_distance_graph 200) where (length(each) >= 5) ;
	    	ask Foyers_Paysans {
	    		set monAgregat <- nil ;
	    	}
	   		// 2 - On parcourt la liste des anciennes agglos
	   		list<geometry> agregats_existantes <- Agregats collect each.shape;
	   		loop i over: Agregats {
	   			bool encore_agregat <- false;
	   			loop j over: agregats_detectees {
	   				list<Foyers_Paysans>FP_inclus <- list<Foyers_Paysans>(j);
	   				geometry geom_agregat <- convex_hull(polygon(FP_inclus collect each.location));
	   				if (i.shape intersects geom_agregat){
	   					ask i {
	   						set fp_agregat <- FP_inclus;
	   						ask fp_agregat {
	   							set monAgregat <- myself ;
	   						}
   						do update_shape;
   						do update_comm_agraire;
	   					}
   						agregats_detectees >> j;
   						set encore_agregat <- true;
   						// sortir de la boucle j
   						break;
	   				}
	   			}
	   			if (!encore_agregat) {
					ask i { do die;}	   				
	   			}
	   		}
	   		loop nouvel_agregat over: agregats_detectees{
	   			create Agregats {
	   				set fp_agregat <- list<Foyers_Paysans>(nouvel_agregat);
	   				ask fp_agregat {
	   					set monAgregat <- myself;
	   				}
	   				do update_shape;
	   				do update_comm_agraire;
	   			}
	   		}
	    }
}

entities {

	species Agregats parent: Amenites{
		bool fake_agregat <- false;
		int attractivite <- 0;
		list<Foyers_Paysans> fp_agregat ;
		bool communaute_agraire <- false;
		
		action update_shape {
			set shape <- convex_hull(polygon(fp_agregat collect each.location));
		}
		
		reflex update_attractivite {
			set attractivite <- length(fp_agregat) +  sum(Chateaux where (self = each.monAgregat) collect each.attractivite);
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