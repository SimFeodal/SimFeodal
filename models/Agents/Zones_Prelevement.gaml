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
