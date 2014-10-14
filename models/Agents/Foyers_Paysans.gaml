/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../GUI.gaml"
import "../global.gaml"
import "Agregats.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"

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
			
		}
		
		ask Agregats where each.fake_agregat {
			do die;
		}
	}
	
	
}

entities {
	species Foyers_Paysans schedules: shuffle(Foyers_Paysans){
		bool comm_agraire <- false;
		Agregats monAgregat <- nil;
		float satisfaction_materielle;
		float satisfaction_religieuse ;
		float satisfaction_protection;
		
		float Satisfaction ;
		list<Chateaux> mesChateaux <- [];
		bool mobile; // Si true : ce FP peut se déplacer / si false, serf/esclave, pas de déplacement
		Seigneurs seigneur_loyer <- nil;
		Seigneurs seigneur_hauteJustice <- nil;
		list<Seigneurs> seigneurs_banaux <- [];
		list<Seigneurs> seigneurs_basseMoyenneJustice <- [];
		
		/*
		// Désactivé pour l'instant
		reflex devenir_seigneur {
			if (Annee >= 1050 and self.monAgregat != nil){
				if (rnd(1000) / 1000 <= proba_devenir_seigneur){
					create Seigneurs number: 1{
						set taux_prelevement <- rnd(100) / 100;
						set type <- "Petit Seigneur";
						set location <- myself.location;
						set rayon_captation <- min_rayon_captation_petits_seigneurs + rnd(max_rayon_captation_petits_seigneurs - min_rayon_captation_petits_seigneurs);
					}
				}
			}
		}
		*/
		
		
		float update_satisfaction_materielle {
			int loyer <- (self.seigneur_loyer != nil ? 1 : 0);
			int hauteJustice <- (self.seigneur_hauteJustice != nil ? 1 : 0);
			int banaux <- length(self.seigneurs_banaux);
			int basseMoyenneJustice <- length(self.seigneurs_basseMoyenneJustice);
			
			int nb_seigneurs <- loyer + hauteJustice + banaux + basseMoyenneJustice;
			
			
			float S_redevances <- max([1 - (nb_seigneurs * 0.2), 0.0]);
			float S_contributions <- 0.0;
			if (self.monAgregat = nil){
				set S_contributions <- 0.0;
			} else {
				set S_contributions <- (self.comm_agraire ? puissance_comm_agraire : 0) + (self.monAgregat.marche ? 0.25 : 0);
			}
			

			float Satisfaction_materielle <- (S_redevances)^(1 - S_contributions);
			return Satisfaction_materielle;
		}
		
		float update_satisfaction_religieuse {
			// f(Frequentation eglise) + f(distance église)
			return rnd(100) / 100 ;
		}
		
		float update_satisfaction_protection {
			if (Annee < debut_besoin_protection){
				return(1.0);
			} else {
				Chateaux plusProcheChateau <- Chateaux closest_to self;
				if (self distance_to plusProcheChateau <= 5000) {
					float protection_seigneur <- plusProcheChateau.monSeigneur.pouvoir_armee ;
					float S_protection <- max([protection_seigneur / 300 , 1.0]);
					
					return(S_protection);
				} else {
					return(0.0);
				}
			}
			return(0.0);
		}
		
		reflex maj_satisfaction {
			do update_satisfaction;
		}
		
		action update_satisfaction {
			set satisfaction_materielle <- update_satisfaction_materielle();
			set satisfaction_religieuse <- update_satisfaction_religieuse();
			set satisfaction_protection <- update_satisfaction_protection();
			
			set Satisfaction <- min([satisfaction_materielle, satisfaction_religieuse, satisfaction_protection]);
		}
		
		reflex demenagement {
			if (rnd(100) / 100 > Satisfaction){
				point baseLoc <- self.location;
				float baseSat <- self.Satisfaction;
				point localLoc <- nil;
				float localSat <- nil;
				
				set location <- demenagement_local();
				do update_satisfaction();
				set localLoc <- self.location;
				set localSat <- self.Satisfaction;
				if (Satisfaction >= baseSat){
					set nb_demenagement_local <- nb_demenagement_local + 1;
				} else {
					set location <- demenagement_lointain();
					do update_satisfaction();
					nb_demenagement_lointain <- nb_demenagement_lointain + 1;
				}
			}
		}
				
		point demenagement_local {
			// Modèle gravitaire local, dans un rayon de 5km
			// Amenités : Chateaux / Églises / Agregats
			int rayon_local <- 5000 ;
			list<Attracteurs> attracteurs_proches <- Attracteurs at_distance rayon_local;
			
			/*
			// On supprime cette logique, FP se dirige maintenant vers barycentre des attracteurs à proximité
			Attracteurs meilleurAttracteur <- attracteurs_proches with_max_of (each.attractivite /max([self distance_to each, 1]));
			if (meilleurAttracteur = nil) {
				return location;
			} else {
				point bestPoint <- nil;
			if ((self distance_to meilleurAttracteur) <= 1000) {
				point bestPoint <- any_location_in(100 around meilleurAttracteur.location);
			} else {
				//point bestPoint <- (lmostAttractive) inter (1000 around self);
				point bestPoint <- (line([self.location, meilleurAttracteur.location]) inter (1000 around self)).points[1];
			}
			//point bestPoint <- any_location_in(100 around self.location);
			return bestPoint;
			}
			*/
			if (empty(attracteurs_proches)) {
				return(location);
			} else {
				point centre_gravite <- mean(attracteurs_proches collect each.location);
				if (self distance_to centre_gravite <= 1000){
					return(any_location_in(100 around centre_gravite));
				} else {
					point pointEtape <- (line([self.location, centre_gravite]) inter (1000 around self)).points[1];
					return(pointEtape);
				}
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