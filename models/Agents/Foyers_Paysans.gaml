/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../global.gaml"
import "Agregats.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"

global {
	

	action renouvellement_FP {
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
						set FPlocation <- any_location_in(distance_detection_agregats around one_of(agregat.fp_agregat).location);
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
		float satisfaction_religieuse;
		float satisfaction_protection;
		
		float Satisfaction ;
		bool mobile; // Si true : ce FP peut se déplacer / si false, serf/esclave, pas de déplacement
		
		Seigneurs seigneur_loyer <- nil;
		Seigneurs seigneur_hauteJustice <- nil;
		list<Seigneurs> seigneurs_banaux <- [];
		list<Seigneurs> seigneurs_basseMoyenneJustice <- [];
		int nb_preleveurs <- 0;
		
		
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
			
			float S_redevances <- max([1 - (nb_seigneurs * (1/15)), 0.0]);
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
			//float distance_eglise <- self distance_to eglise_paroissiale_proche;
			list<Eglises> eglises_paroissiales <- (Eglises where (each.eglise_paroissiale)) ;
			
			float distance_eglise <-min(eglises_paroissiales collect (each distance_to self));// self distance_to eglise_paroissiale_proche;
			
			int seuil1 <- 0 ;
			int  seuil2 <- 0 ;
			if (Annee < 950) {
				set seuil1 <- 5000 ;
				set seuil2 <- 25000 ;
			} else if (Annee < 1050) {
				set seuil1 <- 3000 ;
				set seuil2 <- 10000 ;
			} else {
				set seuil1 <- 1500 ;
				set seuil2 <- 5000 ;
			}
			set satisfaction_religieuse <-  max([0.0,min([ 1.0, - ( distance_eglise / (seuil2 - seuil1))  + ( seuil2 / (seuil2 - seuil1) ) ])]);
		}
		
		action update_satisfaction_protection {
			if (Annee < debut_besoin_protection){
				set satisfaction_protection <- 1.0;
			} else {
				//Chateaux plusProcheChateau <- Chateaux closest_to self;
				float distance_chateau <- min(Chateaux collect (each distance_to self)) ;
				//if (plusProcheChateau = nil) {return(0.0);}
				
				int seuil1 <- 1500 ;
				int seuil2 <- 5000 ;
				set satisfaction_protection <- max([0.0,min([ 1.0, - ( distance_chateau / (seuil2 - seuil1))  + ( seuil2/ (seuil2 - seuil1) ) ])]);
			}
		}
		
		
		action update_satisfaction {
			do update_satisfaction_materielle;
			do update_satisfaction_religieuse;
			do update_satisfaction_protection;
			
			set Satisfaction <- max([0, min([satisfaction_religieuse, satisfaction_protection]) - (1 - satisfaction_materielle)]);
		}
		
		action demenagement {
				set location <- demenagement_local();
				do update_satisfaction();
			if (flip(1 - Satisfaction)){
					set location <- demenagement_lointain();
					do update_satisfaction();
					nb_demenagement_lointain <- nb_demenagement_lointain + 1;
			}
		}
				
		point demenagement_local {
			int rayon_local <- distance_max_dem_local ;
			

			if (empty(attracteurs_proches)) {
				return(location);
			} else {
				point centre_gravite <- mean(attracteurs_proches collect each.location);
				if (self distance_to centre_gravite <= distance_max_dem_local){
					return(any_location_in(distance_detection_agregats around centre_gravite));
				} else {
					point pointEtape <- (line([self.location, centre_gravite]) inter (distance_max_dem_local around self)).points[1];
					return(pointEtape);
				}
			}
		}
		
		// ATTENTION : Actuellement, déménagement lointain peut se faire dans même agrégat...
		// A choisir entre deux possibilités : forcé de déménager ds un autre agrégat ou si meilleur agrégat = sien : ne bouge pas
		point demenagement_lointain {
			
			int attractivite_cagnotte <- sum(Agregats collect each.attractivite);
			//int attractivite_cagnotte <- sum((Agregats - monAgregat) collect each.attractivite);
			
			
			point FPlocation <- nil;
			
			list<Agregats> other_Agregats <- shuffle(Agregats) ;
			//list<Agregats> other_Agregats <- shuffle(Agregats - monAgregat);
			
			loop agregat over: other_Agregats {
				if (agregat.attractivite >= attractivite_cagnotte){
					if (length(agregat.fp_agregat) > 0) {
						if (agregat != monAgregat) {
							set FPlocation <- any_location_in(distance_detection_agregats around one_of(agregat.fp_agregat).location);
						} else {
							set FPlocation <- location;
							nb_demenagement_lointain <- nb_demenagement_lointain - 1;
						}
						
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