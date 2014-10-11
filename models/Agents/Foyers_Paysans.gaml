/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../T8.gaml"
import "../global.gaml"
import "Agregats.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Amenites.gaml"

global {
	reflex renouvellement_FP when: (time > 0) {
		int attractivite_totale <- length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);

		int nb_FP_impactes <- int(taux_renouvellement * length(Foyers_Paysans));
		ask nb_FP_impactes among Foyers_Paysans {
			if (monAgregat != nil){
				ask monAgregat {
					fp_agregat >- myself;
				}
			}
			ask mesSeigneurs {
				FP_controlles >- myself;
			}
			do die;
		}
		create Agregats number: 1 {
			set fake_agregat <- true;
			set attractivite <- attractivite_totale - sum(Agregats collect each.attractivite);
		}
		create Foyers_Paysans number: nb_FP_impactes {
			int attractivite_cagnotte <- attractivite_totale;
			point FPlocation <- nil;
			loop agregat over: shuffle(Agregats) {
				if (agregat.attractivite >= attractivite_cagnotte){
					if (length(agregat.fp_agregat) > 0) {
						set FPlocation <- any_location_in(200 around one_of(agregat.fp_agregat).location);
					} else {
						set FPlocation <- any_location_in(worldextent);
					}
					break;
				} else {
					set attractivite_cagnotte <- attractivite_cagnotte - agregat.attractivite;
				}
			}
			set location <- FPlocation;
			set mobile <- flip (taux_mobilite);
			set mesSeigneurs <- (rnd(3) + 1) among Seigneurs;
			ask mesSeigneurs {
				FP_controlles <+ myself;
			}
			
		}
		
		ask Agregats where each.fake_agregat {
			do die;
		}
	}
	
	
}

entities {
	species Foyers_Paysans {
		bool comm_agraire <- false;
		Agregats monAgregat <- nil;
		float satisfaction_materielle;
		float satisfaction_religieuse ;
		float satisfaction_protection;
		
		float Satisfaction ;
		list<Seigneurs> mesSeigneurs;
		list<Chateaux> mesChateaux <- [];
		bool mobile; // Si true : ce FP peut se déplacer / si false, serf/esclave, pas de déplacement
		
		reflex devenir_seigneur {
			if (self.monAgregat != nil){
				if (rnd(1000) / 1000 <= proba_devenir_seigneur){
					create Seigneurs number: 1{
						set taux_prelevement <- rnd(100) / 100;
					}
				}
			}
		}
		
		reflex maj_protecteur {
			do update_protecteur;
		}
		
		action update_protecteur {
			
			if (!empty(Chateaux at_distance 20000)){
				mesChateaux <- Chateaux at_distance 20000;
				Chateaux plus_proche_chateau <- Chateaux closest_to(self);
				mesSeigneurs <+ plus_proche_chateau.monSeigneur;
				ask (plus_proche_chateau.monSeigneur) {
					FP_controlles <+ myself;
				}
			}
		}
		
		action update_seigneurs {
			// supression anciens seigneurs
			ask mesSeigneurs {
				FP_controlles >- myself;
			}
			// ré-assignation nouveaux seigneurs
			set mesSeigneurs <- (rnd(3) + 1) among Seigneurs;
			ask mesSeigneurs {
				FP_controlles <+ myself;
			}
			
		}
		
		float update_satisfaction_materielle {
			// float: 0 -> 1
			//f(Droits paroissiaux) + f(Droits seigneuriaux) + f(Comm agraire)
			
			// Max 4 seigneurs, donc (4 - droits)/4 pour avoir droits [0; 1] (0 si 4 seigneurs et taux = 1)
			Foyers_Paysans tempA <- one_of(list<Foyers_Paysans>(Foyers_Paysans with_max_of length(each.mesSeigneurs)));
			int max_nb_seigneurs <- length(tempA.mesSeigneurs);
			float Droits_seigneuriaux <- (max_nb_seigneurs - sum(mesSeigneurs collect each.taux_prelevement)) / max_nb_seigneurs;
			// O ou 1 si comm agraire
			int Satisfaction_comm_agraire <- (self.comm_agraire ? 1 : 0);
			float Satisfaction_materielle <- (Droits_seigneuriaux + Satisfaction_comm_agraire) / 2;
			return Satisfaction_materielle;
		}
		
		float update_satisfaction_religieuse {
			// f(Frequentation eglise) + f(distance église)
			return rnd(100) / 100 ;
		}
		
		float update_satisfaction_protection {
			// dépend du pouvoir_armee de mesSeigneurs
			int mon_nombre_chateaux <- length(mesChateaux);
			int max_chateaux <- max([1, max(Foyers_Paysans collect length(each.mesChateaux))]);
			float ma_satisfaction_protection <-  mon_nombre_chateaux / max_chateaux ;
			return ma_satisfaction_protection;
		}
		
		reflex maj_satisfaction {
			do update_satisfaction;
		}
		
		action update_satisfaction {
			set satisfaction_materielle <- update_satisfaction_materielle();
			set satisfaction_religieuse <- update_satisfaction_religieuse();
			set satisfaction_protection <- update_satisfaction_protection();
			
			set Satisfaction <- min([0.33 * satisfaction_materielle,
				0.33 * satisfaction_religieuse,
				0.33 * satisfaction_protection]);
		}
		
		reflex demenagement {
			if (rnd(100) / 100 > Satisfaction){
				point baseLoc <- self.location;
				float baseSat <- self.Satisfaction;
				point localLoc <- nil;
				float localSat <- nil;
				
				// On tente le local
				
				set location <- demenagement_local();
				do update_satisfaction();
				set localLoc <- self.location;
				set localSat <- self.Satisfaction;
				if (Satisfaction >= baseSat){
					set nb_demenagement_local <- nb_demenagement_local + 1;
				} else {
					set location <- demenagement_lointain();
					list<Seigneurs> oldSeigneurs <- self.mesSeigneurs;
					do update_protecteur;
					do update_seigneurs;
					do update_satisfaction();
					if (Satisfaction > localSat) {
						set nb_demenagement_lointain <- nb_demenagement_lointain + 1;
					} else {
						set location <- baseLoc ;
						set Satisfaction <- baseSat;
						set nb_non_demenagement <- nb_non_demenagement + 1;
						ask mesSeigneurs { FP_controlles >- myself; }
						set mesSeigneurs <- oldSeigneurs ;
						ask mesSeigneurs {FP_controlles <+ myself;}
						do update_protecteur;
					}
				}
			}
		}
				
		point demenagement_local {
			// Modèle gravitaire local, dans un rayon de 5km
			// Amenités : Chateaux / Églises / Agregats
			int rayon_local <- 5000 ;
			//list<Foyers_Paysans> meilleure_ca <- [1,2];
			list<Amenites> amenites_proches <- Amenites at_distance rayon_local;
			Amenites meilleureAmenite <- amenites_proches with_max_of (each.attractivite /max([self distance_to each, 1]));
			
			if (meilleureAmenite = nil) {
				return location;
			} else {
				point bestPoint <- nil;
			if ((self distance_to meilleureAmenite) <= 1000) {
				point bestPoint <- any_location_in(100 around meilleureAmenite.location);
			} else {
				//point bestPoint <- (lmostAttractive) inter (1000 around self);
				point bestPoint <- (line([self.location, meilleureAmenite.location]) inter (1000 around self)).points[1];
			}
			//point bestPoint <- any_location_in(100 around self.location);
			return bestPoint;
			}
		}
		
		point demenagement_lointain {
			
			int attractivite_cagnotte <- sum(Agregats collect each.attractivite);
			
			point FPlocation <- nil;
			loop agregat over: shuffle(Agregats) {
				if (agregat.attractivite >= attractivite_cagnotte){
					if (length(agregat.fp_agregat) > 0) {
						set FPlocation <- any_location_in(200 around one_of(agregat.fp_agregat).location);
					} else {
						set FPlocation <- any_location_in(worldextent);
					}
					break;
				} else {
					set attractivite_cagnotte <- attractivite_cagnotte - agregat.attractivite;
				}
			}
			return FPlocation;
		}
		
	rgb color <- #gray ;
	aspect base {
		draw circle(500) color: color;
	}	
	}
}