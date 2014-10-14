/**
 *  ZonesPrelevements
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
		Seigneurs proprietaire <- nil;
		string type_droit <- nil ;
		int rayon;
		float taux_captation;
		point location;
		geometry shape;
		rgb color;
		
		reflex update_shape {
			set shape <- circle(rayon);
		}
	
		aspect base {
			draw shape color: color ;
		}
	}
}
