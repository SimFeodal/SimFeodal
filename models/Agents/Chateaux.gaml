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
		bool ZP_loyer;
		bool ZP_hauteJustice;
		bool ZP_banaux;
		bool ZP_basseMoyenneJustice;
		
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
			}
			set ZP_loyer <- true;
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
			}
			set ZP_hauteJustice <- true;
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
			}
			set ZP_banaux <- true;
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
			}
			set ZP_basseMoyenneJustice <- true;
		}
		
		aspect base {
			draw circle(500) color: #red ;
		}
	}
}