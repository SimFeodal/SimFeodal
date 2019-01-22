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
	
	action prelevements_fonciers_gs {
		list<Foyers_Paysans> FP_dispos <- Foyers_Paysans where (each.seigneur_foncier = nil);
		ask Seigneurs where (each.type = "Grand Seigneur") {
			set nbFP_concernes <- round(self.puissance_init * length(FP_dispos));
		}
		
		ask Seigneurs where (each.type = "Grand Seigneur") {
			list<Foyers_Paysans> FP_concernes <- nbFP_concernes among FP_dispos;
			Seigneurs ceSeigneur <- self;
			ask FP_concernes {
				set seigneur_foncier <- ceSeigneur;
			}
			FP_foncier <<+ FP_concernes;
			FP_dispos >>- FP_concernes;
		}
	}
	
	action prelevements_haute_justice_gs {
		ask (Seigneurs where (each.type = "Grand Seigneur" and each.droits_haute_justice)){
			Seigneurs ceSeigneur <- self;
			list<Foyers_Paysans> nouveaux_FP_foncier <- remove_duplicates(FP_foncier) where (each.seigneur_haute_justice = nil);
			ask nouveaux_FP_foncier {
				set seigneur_haute_justice <- ceSeigneur;
			}
			FP_foncier <<+ nouveaux_FP_foncier;
		}
	}
	
	action creer_zone_prelevement (point centre_zone, int rayon, Seigneurs proprio, string typeDroit, float txPrelev, Chateaux chateau_zp) {
		create Zones_Prelevement number: 1 {
			set location <- centre_zone;
			set proprietaire <- proprio;
			set type_droit <- typeDroit ;
			set rayon_captation <- rayon;
			set taux_captation <- txPrelev;
			set monChateau <- monChateau;
			set shape <- circle(rayon_captation);
			switch type_droit { // ["foncier", "haute_justice", "autres_droits"]
				match "foncier" {color <- #blue;}
				match "haute_justice" {color <- #red;}
				match "autres_droits" {color <- #yellow;}
			}
		}
	}
	
}

species Zones_Prelevement schedules: shuffle(Zones_Prelevement) {
	Chateaux monChateau <- nil;
	Seigneurs proprietaire <- nil;
	Seigneurs gardien <- nil;
	string type_droit <- nil ; // ["foncier", "haute_justice", "autres_droits"]
	int rayon_captation;
	float taux_captation;
	rgb color; 
	
	action update_prelevements {
		Zones_Prelevement cetteZP <- self;
		list<Foyers_Paysans> FP_proches <- Foyers_Paysans at_distance rayon_captation;
		list<Foyers_Paysans> FP_impactes <- int(floor(length(FP_proches) * taux_captation)) among (FP_proches);
		if (cetteZP.type_droit = "foncier"){
			ask FP_impactes {
				set seigneur_foncier <- cetteZP.proprietaire;
			}
			ask cetteZP.proprietaire {
				FP_foncier <<+ FP_impactes;
			}
			if (cetteZP.gardien != nil){
				ask cetteZP.gardien {
					FP_foncier_garde <<+ FP_impactes;
				}
			}
		} else if (cetteZP.type_droit = "haute_justice"){
			ask FP_impactes {
				set seigneur_haute_justice <- cetteZP.proprietaire;
			}
			ask cetteZP.proprietaire {
				FP_haute_justice <<+ FP_impactes;
			}
			if (cetteZP.gardien != nil){
				ask cetteZP.gardien {
					FP_haute_justice_garde <<+ FP_impactes;
				}
			}
		} else { // Forcément "autres_droits"
			ask FP_impactes {
				seigneurs_autres_droits <+ cetteZP.proprietaire;
			}
			ask cetteZP.proprietaire {
				FP_autres_droits <<+ FP_impactes;
			}
			if (cetteZP.gardien != nil){
				ask cetteZP.gardien {
					FP_autres_droits_garde <<+ FP_impactes;
				}
			}
		}
	}
}
