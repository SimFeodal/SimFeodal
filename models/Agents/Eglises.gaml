/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agregats.gaml"
import "Chateaux.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"

global {
	action compute_paroisses {
		ask Paroisses {do die;}
		ask Eglises where (each.eglise_paroissiale) {
			create Paroisses number: 1 {
				set location <- myself.location ;
				set monEglise <- myself ;
			}
		}
		list<geometry> maillage_paroissial <- voronoi(Paroisses collect each.location);
		ask Paroisses {
			set shape <- shuffle(maillage_paroissial) first_with (each overlaps location);
			do update_fideles;
			do update_satisfaction ;
		}
	}
	
	action create_paroisses {
		loop agregat over: shuffle(Agregats where (length(each.fp_agregat) > nb_min_paroissiens)) {
			float nb_relatif_paroissiens <- length(agregat.fp_agregat) / Paroisses count (each intersects agregat) ;
//			float proba_creation <- max([0.0,min([ 1.0,
//				(nb_max_paroissiens/ (nb_max_paroissiens - nb_min_paroissiens)) -
//				( nb_relatif_paroissiens / (nb_max_paroissiens - nb_min_paroissiens))
//			])]);
			
			float proba_creation <- min([1.0, 1/400 * nb_relatif_paroissiens]);
			if flip(proba_creation) {
				// on crée
				create Eglises number: 1 {
					set location <- any_location_in(agregat.shape + 200) ;
					set eglise_paroissiale <- true;
					set reel <- true;
				}
			}
		}
	}
	
	action promouvoir_paroisses {
		ask Paroisses {
			if flip(1 - Satisfaction_Paroisse){
				float ancienne_satisfaction <- Satisfaction_Paroisse;
				geometry ancien_shape <- shape ;
				list<Foyers_Paysans> anciens_fideles <- mesFideles;
				bool eglise_batie <- false ;
				
				Eglises paroisse_a_creer <- nil ;
				list<Eglises> eglises_dans_polygone <- Eglises where !(each.eglise_paroissiale) inside self.shape;
				// Si < 0, on regarde plus loin
				if (length(eglises_dans_polygone) = 0) {
					// on regarde plus loin
					list<Eglises> eglises_proximite <- Eglises where !(each.eglise_paroissiale) inside (self.shape + 2000) ;
					if (length(eglises_proximite) = 0){
						// Créer nouvelle église autour du point le plus éloigné du polygone
						//write("Ping !!!");
						create Eglises number: 1 {
							set location <- myself.shape farthest_point_to myself.location;
							set paroisse_a_creer <- self ;
						}
						set eglise_batie <- true ;
					} else {
						set paroisse_a_creer <- one_of(eglises_proximite) ;
						//write("Pong !!!");
					}
				} else if (length(eglises_dans_polygone) <= 3) {
					set paroisse_a_creer <- one_of(eglises_dans_polygone) ;
					//write("Pang !!!");
				} else {
					// Triangulation
					list<geometry> triangles_Delaunay <- triangulate((Eglises where !(each.eglise_paroissiale)) collect each.location);
					// On ne peut pas faire de overlap parce qu'une paroisse peut être en dehors de la triangulation Delaunay
					geometry monTriangle <- triangles_Delaunay closest_to location;
					set paroisse_a_creer <- shuffle(Eglises) first_with (location = (monTriangle farthest_point_to location));
					//write("Pung");
				}
				if (paroisse_a_creer != nil){
					list<geometry> potentiel_maillage_paroissial <- voronoi((Paroisses collect each.location) + [paroisse_a_creer.location]);
					set shape <- shuffle(potentiel_maillage_paroissial) first_with (each overlaps location);
					do update_fideles ;
					do update_satisfaction ;
					ask paroisse_a_creer {
							set eglise_paroissiale <- true;
							set reel <- true;
					}
				}

			}
		}
	
	}
}


entities {
	
	species Paroisses {
		Eglises monEglise <- nil;
		list<Foyers_Paysans> mesFideles <- nil ;
		rgb color <- #white ;
		float Satisfaction_Paroisse <- 1.0 ;
		
		
		// BUG !!!!!
		// mesFideles ==  0 tout le temps
		action update_fideles {
			set mesFideles <- Foyers_Paysans inside self.shape ;
			//write(length(mesFideles));
			
		}
//		action update_satisfaction {
//			if length(mesFideles) > 0 {
//				float satisfaction_fideles <- mean(mesFideles collect each.satisfaction_religieuse);
//				int nombre_fideles <- length(mesFideles) ;
//				set Satisfaction_Paroisse <- min([1, (20/nombre_fideles)]) * satisfaction_fideles;	
//			} else {
//				set Satisfaction_Paroisse <- 1.0 ;
//			}
//		}
		action update_satisfaction {
			if length(mesFideles) > 0 {
				int nb_paroissiens_mecontents <- mesFideles count (each.satisfaction_religieuse = 0.0);
				//write(nb_paroissiens_mecontents);
				//if (nb_paroissiens_mecontents > 10 or length(mesFideles) > 60){
				if nb_paroissiens_mecontents > 5 {
					set Satisfaction_Paroisse <- 0.0;
				} else {
					set Satisfaction_Paroisse <- 1.0 ;
				}
			}
		}
		
		
		aspect base {
			draw shape color: color;
		}
	}
	
	species Eglises parent: Attracteurs schedules: shuffle(Eglises) {
		string type;
		//list<string> droits_paroissiaux <- []; // ["Baptême" / "Inhumation" / "Eucharistie"]
		bool eglise_paroissiale <- false;
		int attractivite <- 0;
		rgb color <- #blue ;
		bool reel <- false;
		
		action update_attractivite {
			//set attractivite <- length(droits_paroissiaux);
		}
		
		action update_droits_paroissiaux {
			if (!eglise_paroissiale) {
				set eglise_paroissiale <- flip(proba_gain_droits_paroissiaux);
				if (eglise_paroissiale) {set reel <- true;}
			}
		}
		
		
		aspect base {
			draw circle(200) color: color ;
		}
		
	}
	

}