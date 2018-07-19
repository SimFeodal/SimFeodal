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
				set mode_promotion <- myself.mode_promotion;
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
			int nb_FP_agregat <- length(agregat.fp_agregat) ;
			int nb_paroisses_agregat <- Paroisses count (each intersects agregat) ;
			
			float proba_creation_paroisse <- min([1.0, (1/seuil_creation_paroisse) * (nb_FP_agregat / nb_paroisses_agregat)]);

			if flip(proba_creation_paroisse) {
				create Eglises number: 1 {
					set location <- any_location_in((agregat.shape + 200) inter reduced_worldextent) ;
					set eglise_paroissiale <- true;
					set mode_promotion <- "creation agregat";
				}
			}
		}
	}
	
	action promouvoir_paroisses {
		string typePromo <- "nil";
	/* ask Paroisses {
			write string(self )+ "  : " + string(Satisfaction_Paroisse);
		} */
		ask Paroisses {
			if flip(1 - Satisfaction_Paroisse){
				bool eglise_batie <- false ;
				
				Eglises paroisse_a_creer <- nil ;
				list<Eglises> eglises_dans_polygone <- Eglises where !(each.eglise_paroissiale) inside self.shape;
				// Si < 0, on regarde plus loin
				if (length(eglises_dans_polygone) = 0) {
					// on regarde plus loin
					list<Eglises> eglises_proximite <- Eglises where !(each.eglise_paroissiale) inside (self.shape + 2000) ;
					if (length(eglises_proximite) = 0){
						// Créer nouvelle église autour du point le plus éloigné du polygone
						create Eglises number: 1 {
							geometry cetteParoisse <- myself.shape;
							geometry cetteParoisseDansMonde <- myself.shape inter reduced_worldextent;
							set location <- cetteParoisseDansMonde farthest_point_to myself.location;
							set paroisse_a_creer <- self ;
							set mode_promotion <- "creation isole";
							set typePromo <- "creation isole";
						}
						set eglise_batie <- true ;
					} else {
						set paroisse_a_creer <- one_of(eglises_proximite) ;
						set typePromo <- "promotion isole";
					}
				} else if (length(eglises_dans_polygone) <= 3) {
					set paroisse_a_creer <- one_of(eglises_dans_polygone) ;
					set typePromo <- "promotion isole";
				} else {
					// Triangulation
					list<geometry> triangles_Delaunay <- triangulate((Eglises where !(each.eglise_paroissiale)) collect each.location);
					// On ne peut pas faire de overlap parce qu'une paroisse peut être en dehors de la triangulation Delaunay
					geometry monTriangle <- triangles_Delaunay closest_to location;
					set paroisse_a_creer <- shuffle(Eglises) first_with (location = (monTriangle farthest_point_to location));
					set typePromo <- "promotion isole";
				}
				if (paroisse_a_creer != nil){
					list<geometry> potentiel_maillage_paroissial <- voronoi((Paroisses collect each.location) + [paroisse_a_creer.location]);
					set shape <- shuffle(potentiel_maillage_paroissial) first_with (each overlaps location);
					do update_fideles ;
					do update_satisfaction ;
					ask paroisse_a_creer {
							set eglise_paroissiale <- true;
							set mode_promotion <- typePromo;
					}
				}

			}
		}
	
	}
}


species Paroisses {
	Eglises monEglise <- nil;
	list<Foyers_Paysans> mesFideles <- nil ;
	rgb color <- #white ;
	float Satisfaction_Paroisse <- 1.0 ;
	string mode_promotion <- "nil" update: "nil";
	
	

	action update_fideles {
		set mesFideles <- Foyers_Paysans inside self.shape ;
		
	}

	action update_satisfaction {
		if length(mesFideles) > 0 {
			int nb_paroissiens_mecontents <- mesFideles count (each.satisfaction_religieuse = 0.0);
			// write string(self) + " : Nb Paroissiens : " + string(length(mesFideles)) + " / Mecontents : "+ string(nb_paroissiens_mecontents);
			if nb_paroissiens_mecontents > nb_paroissiens_mecontents_necessaires {
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

species Eglises parent: Attracteurs schedules: [] {
	string type;
	//list<string> droits_paroissiaux <- []; // ["Baptême" / "Inhumation" / "Eucharistie"]
	bool eglise_paroissiale <- false;
	int attractivite <- 0;
	rgb color <- #blue ;
	string mode_promotion <- "nil" update: "nil";

	aspect base {
		draw circle(200) color: color ;
	}
	
}
	