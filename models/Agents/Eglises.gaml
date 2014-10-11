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
import "Agregats.gaml"
import "Chateaux.gaml"
import "Seigneurs.gaml"
import "Amenites.gaml"


entities {
	
	species Eglises parent: Amenites{
		string type;
		list<string> droits_paroissiaux <- []; // ["Baptême" / "Inhumation" / "Eucharistie"]
		int attractivite <- 0;
		rgb color <- #blue ;
		
		reflex update_attractivite {
			set attractivite <- length(droits_paroissiaux);
		}
		
		aspect base {
			draw circle(200) color: color ;
		}
		
	}
	

}