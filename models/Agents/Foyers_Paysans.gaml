/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
//import "../GUI.gaml"
import "../global.gaml"
import "Agregats.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"


entities {
	species Foyers_Paysans schedules: shuffle(Foyers_Paysans){
		bool comm_agraire <- false;
		Agregats monAgregat <- nil;
		float satisfaction_materielle;
		float satisfaction_religieuse;
		float satisfaction_protection;
		
		float Satisfaction ;
		bool mobile; // Si true : ce FP peut se déplacer / si false, serf/esclave, pas de déplacement
		
		Seigneurs seigneur_loyer <- nil;
		Seigneurs seigneur_hauteJustice <- nil;
		list<Seigneurs> seigneurs_banaux <- [];
		list<Seigneurs> seigneurs_basseMoyenneJustice <- [];
		int nb_preleveurs <- 0;
		
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
		
		action reset_preleveurs {
			set seigneur_loyer <- nil;
			set seigneur_hauteJustice <- nil;
			set seigneurs_banaux <- [];
			set seigneurs_basseMoyenneJustice <- [];
		}
		
		action update_satisfaction_materielle {
			int loyer <- (self.seigneur_loyer != nil) ? 1 : 0;
			int hauteJustice <- (self.seigneur_hauteJustice != nil) ? 1 : 0;
			int banaux <- length(self.seigneurs_banaux);
			int basseMoyenneJustice <- length(self.seigneurs_basseMoyenneJustice);
			
			int nb_seigneurs <- loyer + hauteJustice + banaux + basseMoyenneJustice;
			set nb_preleveurs <- nb_seigneurs;
			
			float S_redevances <- max([1 - (nb_seigneurs * 0.2), 0.0]);
			float S_contributions <- 0.0;
			if (self.monAgregat = nil){
				set S_contributions <- 0.0;
			} else {
				set S_contributions <- (self.comm_agraire ? puissance_comm_agraire : 0) + (self.monAgregat.marche ? 0.25 : 0);
			}
			

			float Satisfaction_materielle <- (S_redevances)^(1 - S_contributions);
			set satisfaction_materielle <-  Satisfaction_materielle;
		}
		
		action update_satisfaction_religieuse {
			Eglises eglise_paroissiale_proche <- (Eglises where (each.eglise_paroissiale)) closest_to self;
			float distance_eglise <- self distance_to eglise_paroissiale_proche;

			if (Annee < 950) {
				if (distance_eglise < 5000){
					set satisfaction_religieuse <- 1.0;
				} else if (distance_eglise < 8000) {
					set satisfaction_religieuse <- -(1/3 * (distance_eglise / 1000)) + (8/3);
				} else {
					set satisfaction_religieuse <- 0.0;
				}
			} else if (Annee < 1050) {
				if (distance_eglise < 3000){
					set satisfaction_religieuse <- 1.0;
				} else if (distance_eglise < 5000) {
					set satisfaction_religieuse <- -(1/2 * (distance_eglise / 1000)) + (2.5);
				} else {
					set satisfaction_religieuse <- 0.0;
				}	
			} else {
				if (distance_eglise < 1500){
					set satisfaction_religieuse <- 1.0;
				} else if (distance_eglise < 3000) {
					set satisfaction_religieuse <- -(2/3 * (distance_eglise / 1000)) + (2);
				} else {
					set satisfaction_religieuse <- 0.0;
				}	
			}
		}
		
		action update_satisfaction_protection {
			if (Annee < debut_besoin_protection){
				set satisfaction_protection <- 1.0;
			} else {
				Chateaux plusProcheChateau <- Chateaux closest_to self;
				if (plusProcheChateau = nil) {return(0.0);}
				if (self distance_to plusProcheChateau <= 5000) {
					int protection_seigneur <- plusProcheChateau.gardien.puissance_armee ;
					set satisfaction_protection <- max([protection_seigneur / 1000 , 1.0]);
				} else {
					set satisfaction_protection <- 0.0;
				}
			}
		}
		
		
		action update_satisfaction {
			do update_satisfaction_materielle;
			do update_satisfaction_religieuse;
			do update_satisfaction_protection;
			//set satisfaction_materielle <- update_satisfaction_materielle();
			//set satisfaction_religieuse <- update_satisfaction_religieuse();
			//set satisfaction_protection <- update_satisfaction_protection();
			
			set Satisfaction <- min([satisfaction_materielle, satisfaction_religieuse, satisfaction_protection]);
		}
		
		action demenagement {
			if (rnd(100) / 100 > Satisfaction){
				point baseLoc <- self.location;
				float baseSat <- self.Satisfaction;
				point localLoc <- nil;
				float localSat <- nil;
				
				set location <- demenagement_local();
				do update_satisfaction();
				set localLoc <- self.location;
				set localSat <- self.Satisfaction;
				if (Satisfaction > baseSat){
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
		
		// ATTENTION : Actuellement, déménagement lointain peut se faire dans même agrégat...
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
			
			// reset variables
			set seigneur_loyer <- nil;
			set seigneur_hauteJustice <- nil;
			set seigneurs_banaux <- [];
			set seigneurs_basseMoyenneJustice <- [];
			
			return FPlocation;
		}
		
	rgb color <- #gray ;
	aspect base {
		draw circle(500) color: color;
	}	
	}
}