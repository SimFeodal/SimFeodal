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
	    reflex update_agglomerations {
	    	
	    	// 1 - On crée une liste des nouvelles agglos
	    	list agglos_detectees <- connected_components_of(list(Foyers_Paysans) as_distance_graph 200) where (length(each) >= 5) ;
	    	ask Foyers_Paysans {
	    		set monAgglo <- nil ;
	    	}
	   		// 2 - On parcourt la liste des anciennes agglos
	   		list<geometry> agglos_existantes <- Agglomerations collect each.shape;
	   		loop i over: Agglomerations {
	   			bool encore_agglo <- false;
	   			loop j over: agglos_detectees {
	   				list<Foyers_Paysans>FP_inclus <- list<Foyers_Paysans>(j);
	   				geometry geom_agglo <- convex_hull(polygon(FP_inclus collect each.location));
	   				if (i.shape intersects geom_agglo){
	   					ask i {
	   						set fp_agglo <- FP_inclus;
	   						ask fp_agglo {
	   							set monAgglo <- myself ;
	   						}
   						do update_shape;
   						do update_comm_agraire;
	   					}
   						agglos_detectees >> j;
   						set encore_agglo <- true;
   						// sortir de la boucle j
   						break;
	   				}
	   			}
	   			if (!encore_agglo) {
					ask i { do die;}	   				
	   			}
	   		}
	   		loop nouvelle_agglo over: agglos_detectees{
	   			create Agglomerations {
	   				set fp_agglo <- list<Foyers_Paysans>(nouvelle_agglo);
	   				ask fp_agglo {
	   					set monAgglo <- myself;
	   				}
	   				do update_shape;
	   				do update_comm_agraire;
	   			}
	   		}
	    }
}

entities {

	species Agglomerations parent: Amenites{
		bool fake_agglo <- false;
		int attractivite <- 0;
		list<Foyers_Paysans> fp_agglo ;
		bool communaute_agraire <- false;
		
		action update_shape {
			set shape <- convex_hull(polygon(fp_agglo collect each.location));
		}
		
		reflex update_attractivite {
			set attractivite <- length(fp_agglo) +  sum(Chateaux where (self = each.monAgglo) collect each.attractivite);
		}
		
		action update_comm_agraire {
			if (!self.communaute_agraire) {
				if (rnd(100) > 80) {
					set communaute_agraire <- true;
					ask self.fp_agglo {
						set comm_agraire <- true;
					}
				} else {
					ask self.fp_agglo {
						set comm_agraire <- false;
					}
				}
			} else {
				ask self.fp_agglo {
					set comm_agraire <- true;
				}
			}
		}
		
		
	}
}