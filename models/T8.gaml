/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model transition8

// L'ordre compte...
import "init.gaml"
import "global.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Agglomerations.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"

global {
	init {
		do generer_monde;
    }
}
	
experiment base_experiment type: gui {

	parameter "Nombre de Foyers Paysans:" var: nombre_foyers_paysans category: "Initialisation";
	parameter "Nombre d'agglomérations secondaires antiques:" var: nombre_agglos_antiques category: "Initialisation";
	parameter "Nombre de villages:" var: nombre_villages category: "Initialisation";
	parameter "Nombre de Foyers Paysans par village:" var: nombre_foyers_villages category: "Initialisation";
	parameter "Nombre de Châteaux:" var: nombre_chateaux category: "Initialisation";
	parameter "Nombre d'églises:" var: nombre_eglises category: "Initialisation";

	output {
		monitor "Nombre de Foyers paysans" value: Foyers_Paysans count each;
		monitor "Nombre FP dans agglos" value: (Foyers_Paysans where (each.monAgglo != nil)) count each;
		monitor "Nombre d'agglomération rurales" value: Agglomerations count each;
		monitor "Nombre Agglos CP" value: (Agglomerations where (each.Communaute_agraire)) count each;
		monitor "Nombre FP CP" value: (Foyers_Paysans where (each.comm_agraire) count each);
		monitor "Nombre Seigneurs" value: Seigneurs count each;
		monitor "Nombre Eglises" value: Eglises count each;
		monitor "Nombre Chateaux" value: Chateaux count each;
		display world_display {
			//species Foyers_Paysans aspect: base ;
			species Eglises  aspect: base ;
			species Chateaux aspect: base ;
			species Agglomerations ;
		}

	}
}