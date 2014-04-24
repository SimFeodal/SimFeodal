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
import "Eglises.gaml"
import "Seigneurs.gaml"


entities {
	species Chateaux {
		string type;
		list<string> fonctions_possedees;
		float aire_attraction;
		Agglomerations monAgglo;
		float attractivite ;
		Seigneurs monSeigneur;
		
		reflex update_attractivite {
			set attractivite <- length(fonctions_possedees);
		}
		
		reflex update_agglo {
			loop agglo over: Agglomerations {
				if (agglo.shape intersects self)
				{
					set monAgglo <- agglo;
					break;	
				}
			}
		}
		
		rgb color <- rgb('red') ;
	aspect base {
		draw circle(500) color: color ;
	}
	}
}