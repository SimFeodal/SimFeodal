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
import "Chateaux.gaml"
import "Seigneurs.gaml"
import "Zones_Prelevement.gaml"

entities {
	
	species Attracteurs schedules: shuffle(Attracteurs) {
		int attractivite <- 0;
	}
	

}