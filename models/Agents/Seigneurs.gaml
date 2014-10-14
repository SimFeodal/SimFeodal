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
import "Chateaux.gaml"
import "Eglises.gaml"
import "Attracteurs.gaml"

entities {
	species Seigneurs schedules: shuffle(Seigneurs) {
		string type <- "Petit Seigneur";
		bool initialement_present <- false;
		float puissance <- 1.0;
		float pouvoir_armee <- 0.0;
		float taux_prelevement <- 1.0;
		int rayon_captation ;
		list<Foyers_Paysans> FP_controlles <- [];
		list<Chateaux> chateaux_controlles <- [];
		list<Seigneurs> vassaux <- [];
		Seigneurs suzerain <- nil;
		float richesse_autorite_centrale;
		list<Foyers_Paysans> FP_hauteJustice <- [];
		list<Foyers_Paysans> FP_banaux <- [];
		list<Foyers_Paysans> FP_basseMoyenneJustice <- [];
		Seigneurs suzerain_loyer <- nil;
		Seigneurs suzerain_hauteJustice <- nil ;
		Seigneurs suzerain_banaux <- nil;
		Seigneurs suzerain_basseMoyenneJustice <- nil;
		

		
		reflex MaJ_puissance {
			float loyers_propres <- length(Foyers_Paysans where (each.seigneur_loyer = self)) * 1.0;
			list<Seigneurs> mes_seigneurs_loyer <- Seigneurs where (each.suzerain_loyer = self);
			float loyers_garde <- length(Foyers_Paysans where (mes_seigneurs_loyer contains each.seigneur_loyer)) * 1.25;
			float loyers_total <- loyers_propres + loyers_garde;
			
			float hauteJustice_propre <- length(Foyers_Paysans where (each.seigneur_hauteJustice = self)) * 1.0;
			list<Seigneurs> mes_seigneurs_hauteJustice <- Seigneurs where (each.suzerain_loyer = self);
			float hauteJustice_garde <- length(Foyers_Paysans where (mes_seigneurs_hauteJustice contains each.seigneur_hauteJustice)) * 1.25;
			float hauteJustice_total <- hauteJustice_propre + hauteJustice_garde;
			
			set puissance <- puissance + loyers_total + hauteJustice_total;
		}
		
		reflex construction_chateau when: (puissance > 2000 and (type = "Grand Seigneur" or (type = "Chatelain" and chatelain_cree_chateau))){
			if (rnd(100) / 100 >= proba_creer_chateau) {
				Chateaux nvxChateau <- nil;
				create Chateaux number: 1 {
					set nvxChateau <- self;
					set monSeigneur <- myself;
					set monAgregat <- one_of(Agregats);
					set location <- any_location_in(500 around monAgregat.location);
				}
				chateaux_controlles <+ nvxChateau;
				puissance <- puissance - 2000;
			}
		}
		
		reflex don_chateaux when: (length(chateaux_controlles) > 1 and Annee > 950) {
			loop chateau over: (chateaux_controlles - one_of(chateaux_controlles)) {
				if (rnd(100) / 100 >= proba_don_chateau) {
					Seigneurs monNouveauSeigneur <- nil ;
					ask chateau {
						set monNouveauSeigneur <- one_of(Seigneurs where (each.type != "Grand Seigneur" and (each.suzerain_loyer = nil or each.suzerain_loyer = myself)));
						set monSeigneur <- monNouveauSeigneur;
					}
					ask monNouveauSeigneur {
						set suzerain_loyer <- myself;
						chateaux_controlles <+ chateau;
					}
					chateaux_controlles >- chateau;
				}
			}
		}
		
	
		reflex MaJ_type {
			if (self.type != "Grand Seigneur") {
				set type <- (length(self.chateaux_controlles) > 0) ? "Chatelain" : "Petit Seigneur";
			}			
		}
		
		reflex MaJ_pouvoir_armee {
			set pouvoir_armee <- length(FP_controlles) + sum(vassaux collect each.puissance);
		}
		reflex disparition when: (puissance = 0){
			do die;
		}
	}
	
}
