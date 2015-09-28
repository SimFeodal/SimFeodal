/**
 *  ZonesPrelevement
 *  Author: robin
 *  Description: 
 */

model t8


import "../init.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agregats.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"

global {
	action attribution_loyers_FP {
		list<Foyers_Paysans> FP_dispos <- Foyers_Paysans where (each.seigneur_loyer = nil);
		
		ask Zones_Prelevement where (each.type_droit = "Loyer") {
			list<Foyers_Paysans> FP_zone <- FP_dispos inside self.shape;
			int nbFP_concernes <- round(self.taux_captation * length(FP_zone));
			ask nbFP_concernes among FP_zone {
				set seigneur_loyer <- myself.proprietaire;
				set myself.proprietaire.FP_loyer <- remove_duplicates(myself.proprietaire.FP_loyer + self);
				FP_dispos >- self;
			}
		}
		
		ask Seigneurs where (each.type = "Grand Seigneur") {
			int nbFP_concernes <- round(self.puissance_init * length(FP_dispos));
			ask nbFP_concernes among FP_dispos {
				set seigneur_loyer <- myself;
				set myself.FP_loyer <- remove_duplicates(myself.FP_loyer + self);
			}
			set FP_dispos <- Foyers_Paysans where (each.seigneur_loyer = nil);
		}
	}
	
}

entities {
	species Zones_Prelevement schedules: shuffle(Zones_Prelevement) {
		bool ZP_chateau;
		Seigneurs proprietaire <- nil;
		string type_droit <- nil ;
		int rayon_captation;
		float taux_captation;
		map<Seigneurs,float> preleveurs; // map<Seigneur, taux_prelev>
		// Avec map.keys = Seigneurs et map.values = taux_prelev
		// Avec sum(map.values = taux_captation)
		rgb color; 
		
		action update_taxes_FP_HteJustice {
			list<Foyers_Paysans> FP_proche <- Foyers_Paysans at_distance rayon_captation;
			int nb_FP <- length(FP_proche);
			list<Foyers_Paysans> FP_impactes <- int(floor(nb_FP * taux_captation)) among (FP_proche);
			float mon_taux_FP <- (!empty(preleveurs)) ? (1.0 - sum(preleveurs.values)): 1.0;
			if (mon_taux_FP = 1.0){
				ask FP_impactes {
					set seigneur_hauteJustice <- myself.proprietaire;
				}
				ask self.proprietaire {
					set FP_hauteJustice <- union(FP_hauteJustice,FP_impactes);
				}
			} else {
				list<Foyers_Paysans> FP_a_taxer <- FP_impactes;
				ask (int(mon_taux_FP * length(FP_impactes)) among FP_impactes) {
					set seigneur_hauteJustice <- myself.proprietaire;
					set myself.proprietaire.FP_hauteJustice <- union(myself.proprietaire.FP_hauteJustice, FP_impactes);
					FP_a_taxer >- self;
				}
				loop currentPreleveur over: (preleveurs.keys){
					ask (int(preleveurs[currentPreleveur] * length(FP_impactes)) among FP_a_taxer) {
						set seigneur_hauteJustice <- currentPreleveur;
						FP_a_taxer >- self;
						if not (self in currentPreleveur.FP_hauteJustice) {
							set currentPreleveur.FP_hauteJustice <- currentPreleveur.FP_hauteJustice + self;
						}
						
						if not (self in myself.proprietaire.FP_hauteJustice_garde) {
							set myself.proprietaire.FP_hauteJustice_garde <- myself.proprietaire.FP_hauteJustice_garde + self;
						}
					}
				}
			}
		}
		
		action update_taxes_FP_Banaux {
			list<Foyers_Paysans> FP_proche <- Foyers_Paysans at_distance rayon_captation;
			int nb_FP <- length(FP_proche);
			list<Foyers_Paysans> FP_impactes <- int(floor(nb_FP * taux_captation)) among (FP_proche);
			float mon_taux_FP <- (!empty(preleveurs)) ? (1.0 - sum(preleveurs.values)): 1.0;
			if (mon_taux_FP = 1.0){
				ask FP_impactes {
					set seigneurs_banaux <- seigneurs_banaux + myself.proprietaire;
				}
				ask self.proprietaire {
					set FP_banaux <- FP_banaux + FP_impactes;
				}
			} else {
				list<Foyers_Paysans> FP_a_taxer <- FP_impactes;
				ask (int(mon_taux_FP * length(FP_impactes)) among FP_impactes) {
					set seigneurs_banaux <- seigneurs_banaux + myself.proprietaire;
					set myself.proprietaire.FP_banaux <- myself.proprietaire.FP_banaux + FP_impactes;
					FP_a_taxer >- self;
				}
				loop currentPreleveur over: (preleveurs.keys){
					ask (int(preleveurs[currentPreleveur] * length(FP_impactes)) among FP_a_taxer) {
						set seigneurs_banaux <- seigneurs_banaux + currentPreleveur;
						set currentPreleveur.FP_banaux <- currentPreleveur.FP_banaux + self;
						set myself.proprietaire.FP_banaux_garde <- myself.proprietaire.FP_banaux_garde + self;
						FP_a_taxer >- self;
					}
				}
			}
		}
		
		
		
		action update_taxes_FP_BM_Justice {
			list<Foyers_Paysans> FP_proche <- Foyers_Paysans at_distance rayon_captation;
			int nb_FP <- length(FP_proche);
			list<Foyers_Paysans> FP_impactes <- int(floor(nb_FP * taux_captation)) among (FP_proche);
			float mon_taux_FP <- (!empty(preleveurs)) ? (1.0 - sum(preleveurs.values)): 1.0;
			if (mon_taux_FP = 1.0){
				ask FP_impactes {
					set seigneurs_basseMoyenneJustice <- seigneurs_basseMoyenneJustice + myself.proprietaire;
				}
				ask self.proprietaire {
					set FP_basseMoyenneJustice <- FP_basseMoyenneJustice + FP_impactes;
				}
			} else {
				list<Foyers_Paysans> FP_a_taxer <- FP_impactes;
				ask ( int(mon_taux_FP * length(FP_impactes)) among FP_impactes) {
					set seigneurs_basseMoyenneJustice <- seigneurs_basseMoyenneJustice + myself.proprietaire;
					set myself.proprietaire.FP_basseMoyenneJustice <- myself.proprietaire.FP_basseMoyenneJustice + FP_impactes;
					FP_a_taxer >- self;
				}
				
				loop currentPreleveur over: (preleveurs.keys){
					ask ( int((preleveurs[currentPreleveur]) * length(FP_impactes)) among FP_a_taxer) {
						set seigneurs_basseMoyenneJustice <- seigneurs_basseMoyenneJustice + currentPreleveur;
						set currentPreleveur.FP_basseMoyenneJustice <- currentPreleveur.FP_basseMoyenneJustice + self;
						set myself.proprietaire.FP_basseMoyenneJustice_garde <- myself.proprietaire.FP_basseMoyenneJustice_garde + self;
						FP_a_taxer >- self;
					}
				}
			}
		}
		
		
		action update_shape {
			set shape <- circle(rayon_captation);
			switch type_droit {
				match "Loyer" {color <- #blue;}
				match "Haute_Justice" {color <- #red;}
				match "Banaux" {color <- #green;}
				match "basseMoyenne_Justice" {color <- #yellow;}
			}
		}
	}
}
