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
	   			create Agglomerations number: 1 {
	   				set fp_agglo <- list<Foyers_Paysans>(nouvelle_agglo);
	   				ask fp_agglo {
	   					set monAgglo <- myself;
	   				}
	   			}
	   		}
	    }
}

entities {

	species Agglomerations {
		float attractivite;
		list<Foyers_Paysans> fp_agglo ;
		bool Communaute_agraire <- false;
		
		reflex update_shape {
			set shape <- convex_hull(polygon(fp_agglo collect each.location));
		}
		
		reflex update_attractivite {
			set attractivite <- length(fp_agglo) +  sum(Chateaux where (self = each.monAgglo) collect each.attractivite);
		}
		
		reflex update_comm_agraire {
			if (!Communaute_agraire) {
				if (rnd(100) > 80) {
					set Communaute_agraire <- true;
					ask 5 among fp_agglo {
						set comm_agraire <- true ;
					}
				}
			} else {
				int nbCommAgraire <- (fp_agglo where (each.comm_agraire) count each);
				if (nbCommAgraire < 5) {
					ask (5 - nbCommAgraire) among fp_agglo where (!each.comm_agraire) {
						set comm_agraire <- true ;
					}
				}
			}
		}
	}
}