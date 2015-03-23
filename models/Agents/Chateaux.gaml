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
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"


entities {
	species Chateaux parent: Attracteurs  schedules: shuffle(Chateaux){
	
		string type;
		list<string> fonctions_possedees;
		int attractivite <- 0;
		Agregats monAgregat <- nil;
		Seigneurs proprietaire <- nil;
		Seigneurs gardien <- nil;
		Zones_Prelevement ZP_loyer <- nil;
		Zones_Prelevement ZP_hauteJustice;
		Zones_Prelevement ZP_banaux;
		Zones_Prelevement ZP_basseMoyenneJustice;
		bool reel <- true;
		
		action update_attractivite {
			set attractivite <- length(fonctions_possedees);
		}
		
		action creation_ZP_loyer (point centre, int rayon, Seigneurs proprio, float taux_taxation){
			create Zones_Prelevement number: 1 {
				set location <- centre;
				set ZP_chateau <- true;
				set proprietaire <- proprio;
				set type_droit <- "Loyer" ;
				set rayon_captation <- rayon;
				set taux_captation <- taux_taxation;
				set preleveurs <- map([proprio::1.0]);
				set myself.ZP_loyer <- self;
			}
		}
		
		action creation_ZP_hauteJustice (point centre, int rayon, Seigneurs proprio, float taux_taxation){
			create Zones_Prelevement number: 1 {
				set location <- centre;
				set ZP_chateau <- true;
				set proprietaire <- proprio;
				set type_droit <- "Haute_Justice" ;
				set rayon_captation <- rayon;
				set taux_captation <- taux_taxation;
				set preleveurs <- map([proprio::1.0]);
				set myself.ZP_hauteJustice <- self;
			}
		}
		
		action creation_ZP_banaux (point centre, int rayon, Seigneurs proprio, float taux_taxation){
			create Zones_Prelevement number: 1 {
				set location <- centre;
				set ZP_chateau <- true;
				set proprietaire <- proprio;
				set type_droit <- "Banaux" ;
				set rayon_captation <- rayon;
				set taux_captation <- taux_taxation;
				set preleveurs <- map([proprio::1.0]);
				set myself.ZP_banaux <- self;
			}
		}
		
		action creation_ZP_basseMoyenne_Justice (point centre, int rayon, Seigneurs proprio, float taux_taxation){
			create Zones_Prelevement number: 1 {
				set location <- centre;
				set ZP_chateau <- true;
				set proprietaire <- proprio;
				set type_droit <- "basseMoyenne_Justice" ;
				set rayon_captation <- rayon;
				set taux_captation <- taux_taxation;
				set preleveurs <- map([proprio::1.0]);
				set myself.ZP_basseMoyenneJustice <- self;
			}
		}
		
		aspect base {
			draw circle(500) color: #red ;
		}
	}
}