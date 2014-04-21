/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "../init.gaml"
import "../T8.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agglomerations.gaml"
import "Chateaux.gaml"
import "Seigneurs.gaml"


entities {
	
	species Eglises {
		string type;
		int droits_paroissiaux;
		rgb color <- rgb('blue') ;
		aspect base {
			draw circle(200) color: color ;
		}
		
	}
	

}