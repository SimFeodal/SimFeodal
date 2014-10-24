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
import "Zones_Prelevement.gaml"


entities {
	species Seigneurs schedules: shuffle(Seigneurs) {
		
		string type <- "Petit Seigneur";
		bool initialement_present <- false;
		float taux_prelevement <- 1.0;
		
		float puissance_init;
		float puissance <- 0.0;
		int puissance_armee <- 0;
		
		bool droits_loyer <- false;
		bool droits_hauteJustice <- false ;
		bool droits_banaux <- false;
		bool droits_moyenneBasseJustice <- false;
		
		Seigneurs monSuzerain <- nil;
		
		list<Foyers_Paysans> FP_assujettis <- [];
		
		list<Foyers_Paysans> FP_loyer <- [];
		list<Foyers_Paysans> FP_loyer_garde <- [];
		
		list<Foyers_Paysans> FP_hauteJustice <- [];
		list<Foyers_Paysans> FP_hauteJustice_garde <- [];
		
		list<Foyers_Paysans> FP_banaux <- [];
		list<Foyers_Paysans> FP_banaux_garde <- [];
		
		list<Foyers_Paysans> FP_basseMoyenneJustice <- [];
		list<Foyers_Paysans> FP_basseMoyenneJustice_garde <- [];
		
		
		init {
			if (type = "Chatelain") {
				int rayon_zone <- 20000;
				float txPrelev <- 1.0;
				do creer_zone_prelevement(self.location, rayon_zone, self, "Loyer", txPrelev);
			}
		}
		
		
		action gains_droits_banaux {
			// 1 seul seigneur aussi	
		}
		
		action MaJ_droits_Grands_Seigneurs {
			if (Annee < 900){
				if (!droits_hauteJustice) {
					set droits_hauteJustice <- flip(0.1);
					if (droits_hauteJustice){
						do MaJ_ZP_chateaux(self, "Haute_Justice");
						if (!droits_banaux) {
							set droits_banaux <- true;
							do MaJ_ZP_chateaux(self, "Banaux");
							
						}
						if (!droits_moyenneBasseJustice) {
							set droits_moyenneBasseJustice <- true;
							do MaJ_ZP_chateaux(self, "basseMoyenne_Justice");
						}
					}
				}
					
				if (!droits_banaux) {
					set droits_banaux <- flip(0.1);
					if (droits_banaux) {
						set droits_banaux <- true;
						do MaJ_ZP_chateaux(self, "Banaux");	
					}
				}
				
				if (!droits_moyenneBasseJustice) {
					set droits_moyenneBasseJustice <- flip(0.1);
					if (droits_moyenneBasseJustice) {
						set droits_moyenneBasseJustice <- true;
						do MaJ_ZP_chateaux(self, "basseMoyenne_Justice");
					}
				}
			} else if (Annee = 900) {
				set droits_hauteJustice <-true;
				do MaJ_ZP_chateaux(self, "Haute_Justice");
				set droits_banaux <- true;
				do MaJ_ZP_chateaux(self, "Banaux");
				set droits_moyenneBasseJustice <- true;
				do MaJ_ZP_chateaux(self, "basseMoyenne_Justice");
			}
		}
		
		action MaJ_droits_Petits_Seigneurs {
			
		}
		
		action MaJ_droits_Chatelains {
			
		}
		
		action MaJ_ZP_chateaux(Seigneurs seigneur, string type_droit){
			switch type_droit {
				match "Loyer" {
					ask Chateaux where (each.proprietaire = self and !each.ZP_loyer){
						do creation_ZP_loyer(self.location, 10000, seigneur, 1.0);
					}
				}
				match "Haute_Justice" {
					ask Chateaux where (each.proprietaire = self and !each.ZP_hauteJustice){
						do creation_ZP_hauteJustice(self.location, 10000, seigneur, 1.0);
					}
				}
				match "Banaux" {
					ask Chateaux where (each.proprietaire = self and !each.ZP_banaux){
						do creation_ZP_banaux(self.location, 10000, seigneur, 1.0);
					}
				}
				match "basseMoyenne_Justice" {
					ask Chateaux where (each.proprietaire = self and !each.ZP_basseMoyenneJustice){
						do creation_ZP_basseMoyenne_Justice(self.location, 10000, seigneur, 1.0);
					}
				}
			}
		}
		
		action creer_zone_prelevement (point centre_zone, int rayon, Seigneurs proprio, string typeDroit, float txPrelev) {
			create Zones_Prelevement number: 1 {
				set proprietaire <- proprio;
				set type_droit <- typeDroit ;
				set rayon_captation <- rayon;
				set taux_captation <- txPrelev;
				set preleveurs <- map([proprio::txPrelev]);
			}
		}
		
		action reset_variables {
			set FP_assujettis <- [];
		}
		
		float MaJ_loyers {
			list<Foyers_Paysans> mesLocataires <- Foyers_Paysans where (each.seigneur_loyer = self);
			float mesLoyers <- length(mesLocataires) * taux_prelevement;
			set FP_assujettis <- FP_assujettis + mesLocataires;
			return(mesLoyers);
		}
		
		float MaJ_hauteJustice {
			if (type = "Grand Seigneur" and droits_hauteJustice){
				list<Foyers_Paysans> mesLocataires <- Foyers_Paysans where (each.seigneur_loyer = self);
			}
			// On collecte les droits de haute justice et on attribue les FP à soi-même.
			return(1);
		}
		
		float MaJ_banaux {
			// On collecte les droits banaux et on s'ajoute à la liste des seigneurs des FP.
			return(1);
		}
		
		float MaJ_moyenneBasseJustice {
			// On collecte les droits de moyenne/basse justice et on s'ajoute à la liste des seigneurs des FP.
			return(1);
		}
		
		action MaJ_puissance {
			set puissance <- puissance + MaJ_loyers() + MaJ_hauteJustice() + MaJ_banaux() + MaJ_moyenneBasseJustice();
		}
		
		
		action don_chateaux {
			// On donne ses châteaux...
		}
		
		action construction_chateau {
			// on construit un château...
		}
		
		action construction_chateau_GS {
			int nbChateauxPotentiel <- int(floor(self.puissance / 2000));
			
			list<Agregats> agregatsPotentiel <- Agregats where (each.monChateau = nil);
			
			int nbChateaux <- min([rnd(nbChateauxPotentiel), length(agregatsPotentiel)]);
			create Chateaux number: nbChateaux {
				set proprietaire <- myself;
				set gardien <- myself;
				Agregats choixAgregat <- one_of(agregatsPotentiel where (each.monChateau = nil));
				ask choixAgregat {
					set monChateau <- myself;
				}
				set location <- any_location_in(500 around choixAgregat);
				do creation_ZP_loyer(location, 10000, myself, 1.0);
				if (myself.droits_hauteJustice){
					do creation_ZP_hauteJustice(location, 10000, myself, 1.0);
					do creation_ZP_banaux(location, 10000, myself, 1.0);
					do creation_ZP_basseMoyenne_Justice(location, 10000, myself, 1.0);
				} else {
					if (myself.droits_banaux) {
						do creation_ZP_banaux(location, 10000, myself, 1.0);
					}
					if (myself.droits_moyenneBasseJustice){
						do creation_ZP_basseMoyenne_Justice(location, 10000, myself, 1.0);
					}
				}
			}
		}
		

	
		action MaJ_type {
			if (self.type = "Petit Seigneur") {
				set type <- (!empty(Chateaux where ( (each.proprietaire = self) or (each.gardien = self) ))) ? "Chatelain" : "Petit Seigneur";
			}			
		}
		
		action MaJ_puissance_armee {
			// C'est le nombre (unique) de FP qui versent des droits à ce seigneur.
			set puissance_armee <- length(FP_assujettis);
		}
		
	}
}
