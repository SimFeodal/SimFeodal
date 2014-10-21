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
		
		list<Foyers_Paysans> FP_assujettis <- [];
		
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
							set droits_banaux <- true;
							set droits_moyenneBasseJustice <- true;
							// MaJ des FP assujettis : lesquels ? ou ?
						}
					}
					
					if (!droits_banaux) {set droits_banaux <- flip(0.1);}
					if (!droits_moyenneBasseJustice){set droits_moyenneBasseJustice <- flip(0.1);}
					
					
				} else if (Annee = 900) {
					set droits_hauteJustice <-true;
					set droits_banaux <- true;
					set droits_moyenneBasseJustice <- true;
				}
		}
		
		action MaJ_droits_Petits_Seigneurs {
			
		}
		
		action MaJ_droits_Chatelains {
			
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
