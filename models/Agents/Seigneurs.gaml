/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8


import "../init.gaml"
//import "../GUI.gaml"
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
		
		int monNbZP <- 0;
		
		
		init {
			if (type = "Chatelain") {
				int rayon_zone <- 20000;
				float txPrelev <- 1.0;
				do creer_zone_prelevement(self.location, rayon_zone, self, "Loyer", txPrelev);
			}
		}
		
		
		action gains_droits_PS {
			if (flip(proba_creation_ZP_banaux)){				
				int rayon_ZP <- (self.initialement_present) ? (rayon_min_PS_init + rnd(rayon_max_PS_init - rayon_min_PS_init)) : (rayon_min_PS_nouveau + rnd(rayon_max_PS_nouveau - rayon_min_PS_nouveau));
				float taux_ZP <- (self.initialement_present) ? (min_fourchette_loyers_PS_init + rnd(max_fourchette_loyers_PS_init - min_fourchette_loyers_PS_init)) : (min_fourchette_loyers_PS_nouveau + rnd(max_fourchette_loyers_PS_nouveau - min_fourchette_loyers_PS_nouveau));
				do creer_zone_prelevement(any_location_in(3000 around self.location), rayon_ZP, self, "Banaux", taux_ZP);
			}
			
			if flip(proba_creation_ZP_basseMoyenneJustice){
				int rayon_ZP <- (self.initialement_present) ? (rayon_min_PS_init + rnd(rayon_max_PS_init - rayon_min_PS_init)) : (rayon_min_PS_nouveau + rnd(rayon_max_PS_nouveau - rayon_min_PS_nouveau));
				float taux_ZP <- (self.initialement_present) ? (min_fourchette_loyers_PS_init + rnd(max_fourchette_loyers_PS_init - min_fourchette_loyers_PS_init)) : (min_fourchette_loyers_PS_nouveau + rnd(max_fourchette_loyers_PS_nouveau - min_fourchette_loyers_PS_nouveau));
				do creer_zone_prelevement(any_location_in(3000 around self.location), rayon_ZP, self, "basseMoyenne_Justice", taux_ZP);
			}
		}
		
		action don_droits_GS {
			Seigneurs choixSeigneur <- one_of(Seigneurs where (each.type != 'Grand Seigneur' and each.initialement_present and ((each.monSuzerain = self or each.monSuzerain = nil))));
			string monType_droit <- flip(0.33) ? "Haute_Justice" : (flip(0.5) ? "Banaux" : "basseMoyenne_Justice");
			Agregats choixAgregat <- one_of(Agregats);
			int rayon_taxe <- (rayon_min_PS_init + rnd(rayon_max_PS_init - rayon_min_PS_init));
			create Zones_Prelevement number: 1 {
				set location <- any_location_in(choixAgregat.shape);
				set ZP_chateau <- false;
				set proprietaire <- myself;
				set type_droit <- monType_droit ;
				set rayon_captation <- rayon_taxe;
				set taux_captation <- 1.0;
				set preleveurs <- map([choixSeigneur::1.0]);
			}
			ask choixSeigneur { set monSuzerain <- myself;}
		}
		
		action don_droits_PS {
			loop currentZP over: (Zones_Prelevement where (!each.ZP_chateau and each.proprietaire = self)){
				list<Seigneurs> preleveurs_potentiels <- [];
				float pourcentage_donne <- (rnd(20) * 10) /200; // par pas de 5%
				ask currentZP {
					set preleveurs_potentiels <- Seigneurs where (each.type != "Grand Seigneur" and each != currentZP.proprietaire) at_distance 3000;
				}
				if (flip(proba_don_partie_ZP) and (sum(currentZP.preleveurs.values) < (1.0 - pourcentage_donne) ) and !empty(preleveurs_potentiels)) {
					Seigneurs monPreleveur <- one_of(preleveurs_potentiels);
					ask currentZP {
						set preleveurs[monPreleveur] <- (preleveurs.keys contains monPreleveur) ? preleveurs[monPreleveur] + pourcentage_donne : pourcentage_donne;
					}
				}
			}
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
					set droits_banaux <- flip(proba_gain_droits_banaux_chateau);
					if (droits_banaux) {
						set droits_banaux <- true;
						do MaJ_ZP_chateaux(self, "Banaux");	
					}
				}
				
				if (!droits_moyenneBasseJustice) {
					set droits_moyenneBasseJustice <- flip(proba_gain_droits_basseMoyenneJustice_chateau);
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
			if (!droits_banaux) {
				set droits_banaux <- flip(proba_gain_droits_banaux_chateau);
				if (droits_banaux) {
					set droits_banaux <- true;
					do MaJ_ZP_chateaux(self, "Banaux");	
				}
			}
			
			if (!droits_moyenneBasseJustice) {
				set droits_moyenneBasseJustice <- flip(proba_gain_droits_basseMoyenneJustice_chateau);
				if (droits_moyenneBasseJustice) {
					set droits_moyenneBasseJustice <- true;
					do MaJ_ZP_chateaux(self, "basseMoyenne_Justice");
				}
			}
		}
		
		action MaJ_droits_Chatelains {
			
		}
		
		action MaJ_ZP_chateaux(Seigneurs seigneur, string type_droit){
			switch type_droit {
				match "Loyer" {
					ask Chateaux where (each.proprietaire = self and each.ZP_loyer = nil){
						do creation_ZP_loyer(self.location, 10000, seigneur, 1.0);
					}
				}
				match "Haute_Justice" {
					ask Chateaux where (each.proprietaire = self and each.ZP_hauteJustice = nil){
						do creation_ZP_hauteJustice(self.location, 10000, seigneur, 1.0);
					}
				}
				match "Banaux" {
					ask Chateaux where (each.proprietaire = self and each.ZP_banaux = nil){
						do creation_ZP_banaux(self.location, 10000, seigneur, 1.0);
					}
				}
				match "basseMoyenne_Justice" {
					ask Chateaux where (each.proprietaire = self and each.ZP_basseMoyenneJustice = nil){
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
			
			set FP_loyer <- [];
			set FP_loyer_garde <- [];
		
			set FP_hauteJustice <- [];
			set FP_hauteJustice_garde <- [];
			
			set FP_banaux <- [];
			set FP_banaux_garde <- [];
			
			set FP_basseMoyenneJustice <- [];
			set FP_basseMoyenneJustice_garde <- [];
		}
		
		float MaJ_loyers {
			float Loyers <- length(FP_loyer) * taux_prelevement * 1.0;
			float Loyers_garde <- length(FP_loyer_garde) * taux_prelevement * 1.25;
			set FP_assujettis <- remove_duplicates(FP_assujettis + FP_loyer + FP_loyer_garde);
			return(Loyers + Loyers_garde);
		}
		
		float MaJ_hauteJustice {
			float HteJustice <- length(FP_hauteJustice) * taux_prelevement * 1.0;
			float HteJustice_garde <- length(FP_hauteJustice_garde) * taux_prelevement * 1.25;
			set FP_assujettis <- remove_duplicates(FP_assujettis + FP_hauteJustice + FP_hauteJustice_garde);
			return(HteJustice + HteJustice_garde);
		}
		
		float MaJ_banaux {
			float Banaux <- length(FP_banaux) * taux_prelevement * 0.25;
			float Banaux_garde <- length(FP_banaux_garde) * taux_prelevement * 0.35;
			set FP_assujettis <- remove_duplicates(FP_assujettis + FP_banaux + FP_banaux_garde);
			return(Banaux + Banaux_garde);
		}
		
		float MaJ_moyenneBasseJustice {
			float moyenneBasseJustice <- length(FP_basseMoyenneJustice) * taux_prelevement * 0.25;
			float moyenneBasseJustice_garde <- length(FP_basseMoyenneJustice_garde) * taux_prelevement * 0.35;
			set FP_assujettis <- remove_duplicates(FP_assujettis + FP_basseMoyenneJustice + FP_basseMoyenneJustice_garde);
			return(moyenneBasseJustice + moyenneBasseJustice_garde);
		}
		
		action MaJ_puissance {
			set puissance <- puissance + MaJ_loyers() + MaJ_hauteJustice() + MaJ_banaux() + MaJ_moyenneBasseJustice();
		}
		
		
		action don_chateaux_GS {
			loop chateau over: Chateaux where (each.proprietaire = self and each.gardien = self){
				if (flip(proba_don_chateau_GS)){
					Seigneurs choixSeigneur <- one_of(Seigneurs where (each.type != 'Grand Seigneur' and each.initialement_present and ((each.monSuzerain = self or each.monSuzerain = nil) or (each.monSuzerain.type != "Grand Seigneur"))));
					set chateau.gardien <- choixSeigneur;
					set choixSeigneur.type <- "Chatelain";
					set choixSeigneur.monSuzerain <- self;
					
					if (chateau.ZP_loyer != nil) {
						ask chateau.ZP_loyer {
							set preleveurs <- map(choixSeigneur::1.0);
						}
					}
					
					if (chateau.ZP_hauteJustice != nil) {
						ask chateau.ZP_hauteJustice {
							set preleveurs[choixSeigneur] <- 0.33;
						}
					}
					
					if (chateau.ZP_banaux != nil){
						ask chateau.ZP_banaux {
							set preleveurs[choixSeigneur] <- 0.33;
						}
					}

					if (chateau.ZP_basseMoyenneJustice != nil) {
						ask chateau.ZP_basseMoyenneJustice {
							set preleveurs[choixSeigneur] <- 0.33;
						}
					}
				}
			}
		}
		
		action update_droits_chateaux_GS {
			loop chateau over: Chateaux where (each.proprietaire = self and each.gardien != self){
				
				if (chateau.ZP_banaux != nil){
					ask chateau.ZP_banaux {
						if (sum(preleveurs.values) < 1){
							set preleveurs[preleveurs.keys[0]] <- (preleveurs[preleveurs.keys[0]] = 0.66) ? 1.0 : preleveurs[preleveurs.keys[0]] + 0.33;
						}
					}
				}
				
				if (chateau.ZP_hauteJustice != nil){
					ask chateau.ZP_hauteJustice {
						if (sum(preleveurs.values) < 1){
							set preleveurs[preleveurs.keys[0]] <- (preleveurs[preleveurs.keys[0]] = 0.66) ? 1.0 : preleveurs[preleveurs.keys[0]] + 0.33;
						}
					}
				}
				
				if (chateau.ZP_basseMoyenneJustice != nil){
					ask chateau.ZP_basseMoyenneJustice {
						if (sum(preleveurs.values) < 1){
							set preleveurs[preleveurs.keys[0]] <- (preleveurs[preleveurs.keys[0]] = 0.66) ? 1.0 : preleveurs[preleveurs.keys[0]] + 0.33;
						}
					}
				}
			}
		}
		
		action don_chateaux_PS {
			
		}
		
		
		action construction_chateau_GS {
			int nbChateauxPotentiel <- int(floor(self.puissance / 2000));
			
			list<Agregats> agregatsPotentiel <- Agregats where (each.monChateau = nil);
			
			int nbChateaux <- min([rnd(nbChateauxPotentiel), length(agregatsPotentiel)]);
			create Chateaux number: nbChateaux {
				if (!flip(proba_creer_chateau_GS)){
					do die;
				}
				set proprietaire <- myself;
				set gardien <- myself;
				Agregats choixAgregat <- one_of(agregatsPotentiel where (each.monChateau = nil));
				// FIXME : Chateaux trop proches sinon
				if (choixAgregat distance_to (Chateaux closest_to choixAgregat) < 3000) {do die;}
				ask choixAgregat {
					set monChateau <- myself;
				}
				set location <- any_location_in(choixAgregat.shape + 500));
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
		
		action construction_chateau_PS {
			
			Agregats agregatPotentiel <- Agregats closest_to self;
			set agregatPotentiel <- (agregatPotentiel.monChateau = nil) ? agregatPotentiel : nil ;
			if (agregatPotentiel != nil) {
				// FIXME : Chateaux trop proches sinon
				if (agregatPotentiel distance_to (Chateaux closest_to agregatPotentiel) < 3000) {return();}
				create Chateaux number: 1 {
					if (!flip(proba_creer_chateau_PS)){
						do die;
					}
					set proprietaire <- myself;
					set gardien <- myself;
					do die;
					set myself.type <- "Chatelain";
					ask agregatPotentiel {
						set monChateau <- myself;
					}
					set location <- any_location_in(agregatPotentiel.shape + 500);
					do creation_ZP_loyer(location, 10000, myself, 1.0);
					
					if (Annee > 900 and flip(proba_gain_droits_hauteJustice_chateau)){
						ask myself {
							set droits_hauteJustice <- true;
							set droits_banaux <- true;
							set droits_moyenneBasseJustice <- true;
						}
						do creation_ZP_hauteJustice(location, 10000, myself, 1.0);
						do creation_ZP_banaux(location, 10000, myself, 1.0);
						do creation_ZP_basseMoyenne_Justice(location, 10000, myself, 1.0);
						
					}
					if (flip(proba_gain_droits_banaux_chateau)){
						ask myself {set droits_banaux <- true;}
						do creation_ZP_banaux(location, 10000, myself, 1.0);
					}
					if (flip(proba_gain_droits_basseMoyenneJustice_chateau)){
						ask myself {set droits_moyenneBasseJustice <- true;}
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
