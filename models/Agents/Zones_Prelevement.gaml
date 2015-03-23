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
		
		action update_taxes_FP {
			int nb_FP <- length(Foyers_Paysans at_distance rayon_captation);
			list<Foyers_Paysans> FP_impactes <- floor(nb_FP * taux_captation) among (Foyers_Paysans at_distance rayon_captation);
			float mon_taux_FP <- (!empty(preleveurs)) ? (1.0 - sum(preleveurs.values)): 1.0;
			switch type_droit {
				match "Haute_Justice"{
					if (mon_taux_FP = 1.0){
						ask FP_impactes {
							set seigneur_hauteJustice <- myself.proprietaire;
						}
						ask self.proprietaire {
							set FP_hauteJustice <- remove_duplicates(FP_hauteJustice + FP_impactes);
						}
					} else {
						ask ((mon_taux_FP * length(FP_impactes)) among FP_impactes) {
							set seigneur_hauteJustice <- myself.proprietaire;
							set myself.proprietaire.FP_hauteJustice <- remove_duplicates(myself.proprietaire.FP_hauteJustice + FP_impactes);
						}
						loop currentPreleveur over: (preleveurs.keys){
							ask (((preleveurs[currentPreleveur]) * length(FP_impactes)) among FP_impactes) {
								set seigneur_hauteJustice <- currentPreleveur;
								set currentPreleveur.FP_hauteJustice <- remove_duplicates(currentPreleveur.FP_hauteJustice + self);
								set myself.proprietaire.FP_hauteJustice_garde <- remove_duplicates( myself.proprietaire.FP_hauteJustice_garde + self);
							}
						}
					}
				}
				match "Banaux" {
					if (mon_taux_FP = 1.0){
						ask FP_impactes {
							set seigneurs_banaux <- seigneurs_banaux + myself.proprietaire;
						}
						ask self.proprietaire {
							set FP_banaux <- FP_banaux + FP_impactes;
						}
					} else {
						ask ((mon_taux_FP * length(FP_impactes)) among FP_impactes) {
							set seigneurs_banaux <- seigneurs_banaux + myself.proprietaire;
							set myself.proprietaire.FP_banaux <- myself.proprietaire.FP_banaux + FP_impactes;
						}
						loop currentPreleveur over: (preleveurs.keys){
							ask (((preleveurs[currentPreleveur]) * length(FP_impactes)) among FP_impactes) {
								set seigneurs_banaux <- seigneurs_banaux + currentPreleveur;
								set currentPreleveur.FP_banaux <- currentPreleveur.FP_banaux + self;
								set myself.proprietaire.FP_banaux_garde <- myself.proprietaire.FP_banaux_garde + self;
							}
						}
					}
				}
				match "basseMoyenne_Justice" {
					if (mon_taux_FP = 1.0){
						ask FP_impactes {
							set seigneurs_basseMoyenneJustice <- seigneurs_basseMoyenneJustice + myself.proprietaire;
						}
						ask self.proprietaire {
							set FP_basseMoyenneJustice <- FP_basseMoyenneJustice + FP_impactes;
						}
					} else {
						ask ((mon_taux_FP * length(FP_impactes)) among FP_impactes) {
							set seigneurs_basseMoyenneJustice <- seigneurs_basseMoyenneJustice + myself.proprietaire;
							set myself.proprietaire.FP_basseMoyenneJustice <- myself.proprietaire.FP_basseMoyenneJustice + FP_impactes;
						}
						
						loop currentPreleveur over: (preleveurs.keys){
							ask (((preleveurs[currentPreleveur]) * length(FP_impactes)) among FP_impactes) {
								set seigneurs_basseMoyenneJustice <- seigneurs_basseMoyenneJustice + currentPreleveur;
								set currentPreleveur.FP_basseMoyenneJustice <- currentPreleveur.FP_basseMoyenneJustice + self;
								set myself.proprietaire.FP_basseMoyenneJustice_garde <- myself.proprietaire.FP_basseMoyenneJustice_garde + self;
							}
						}
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
