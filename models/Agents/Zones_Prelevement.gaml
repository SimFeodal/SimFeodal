/**
 *  ZonesPrelevement
 *  Author: robin
 *  Description: 
 */

model t8

import "../init.gaml"
import "../GUI.gaml"
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
			list<Foyers_Paysans> mes_FP <- floor(nb_FP * taux_captation) among (Foyers_Paysans at_distance rayon_captation);
			switch type_droit {
				match "Haute_Justice"{
					ask mes_FP {
						set seigneur_loyer <- myself.proprietaire;
					}
					ask self.proprietaire {
						set FP_hauteJustice <- remove_duplicates(FP_hauteJustice + mes_FP);
					}
				}
				match "Banaux" {
					ask mes_FP {
						set seigneurs_banaux <- seigneurs_banaux + myself.proprietaire;
					}
					ask proprietaire {
						set FP_banaux <- FP_banaux + mes_FP;
					}
				}
				match "basseMoyenne_Justice" {
					ask mes_FP {
						set seigneurs_basseMoyenneJustice <- seigneurs_basseMoyenneJustice + myself.proprietaire;
					}
					ask proprietaire {
						set FP_basseMoyenneJustice <- FP_basseMoyenneJustice + mes_FP;
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
