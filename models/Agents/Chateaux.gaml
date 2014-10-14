/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../GUI.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agregats.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"


entities {
	species Chateaux parent: Attracteurs  schedules: shuffle(Chateaux){
		string type;
		list<string> fonctions_possedees;
		float aire_attraction;
		Agregats monAgregat;
		int attractivite <- 0;
		Seigneurs monSeigneur;
		Seigneurs monGardien;
		
		reflex update_attractivite {
			set attractivite <- length(fonctions_possedees);
		}
		
		
		reflex update_agglo {
			list<Agregats> agregats_proches <- Agregats at_distance 1000;
			// Si une agglo intersecte mon shape
			if (agregats_proches != nil){
				set monAgregat <- agregats_proches closest_to self;
			} else {
				set monAgregat <- nil;
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