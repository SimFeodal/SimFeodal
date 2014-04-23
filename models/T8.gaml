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
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agglos" value: length(Foyers_Paysans where (each.monAgglo != nil));
		monitor "Nombre d'agglomération rurales" value: length(Agglomerations);
		monitor "Nombre Agglos CP" value: length(Agglomerations where (each.Communaute_agraire));
		monitor "Nombre FP CP" value: length(Foyers_Paysans where (each.comm_agraire));
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Chateaux" value: length(Chateaux);
		display world_display {
			//species Foyers_Paysans aspect: base ;
			species Eglises aspect: base ;
			species Chateaux aspect: base ;
			species Agglomerations ;
		}

	}
}