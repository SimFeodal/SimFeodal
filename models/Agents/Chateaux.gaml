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
import "Amenites.gaml"


entities {
	species Chateaux parent: Amenites{
		string type;
		list<string> fonctions_possedees;
		float aire_attraction;
		Agglomerations monAgglo;
		int attractivite <- 0;
		Seigneurs monSeigneur;
		
		reflex update_attractivite {
			set attractivite <- length(fonctions_possedees);
		}
		
		
		reflex update_agglo {
			list<Agglomerations> agglos_proches <- Agglomerations at_distance 1000;
			// Si une agglo intersecte mon shape
			if (agglos_proches != nil){
				set monAgglo <- agglos_proches closest_to self;
			} else {
				set monAgglo <- nil;
			}
			//Sinon, on cherche à 1000m et on prend la plus proche
			
			// Sinon, pas d'agglo
		}
		
		rgb color <- #red;
	aspect base {
		draw circle(500) color: color ;
	}
	}
}