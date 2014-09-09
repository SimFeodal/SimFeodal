/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model transition8

// L'ordre compte...
import "init.gaml"
import "global.gaml"
import "Agents/Agglomerations.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Amenites.gaml"

global schedules: list(world) + list(Amenites) + list(Agglomerations) + list(Foyers_Paysans) + list(Chateaux) + list(Eglises) + list(Seigneurs){
	init {
		do generer_monde;
    }
}
	
experiment base_experiment type: gui {

	parameter "Nombre de Foyers Paysans:" var: nombre_foyers_paysans category: "Initialisation";
	parameter "Nombre d'agglomérations secondaires antiques:" var: nombre_agglos_antiques category: "Initialisation";
	parameter "Nombre de villages:" var: nombre_villages category: "Initialisation";
	parameter "Nombre de Foyers Paysans par village:" var: nombre_foyers_villages category: "Initialisation";
	parameter "Nombre de Seigneurs:" var: nombre_seigneurs category: "Initialisation";
	parameter "Nombre d'églises:" var: nombre_eglises category: "Initialisation";
	
	parameter "Taux renouvellement" var: taux_renouvellement category: "Modèle";
	parameter "Taux mobilité des FP" var: taux_mobilite category: "Modèle";
	parameter "Probabilité devenir seigneur" var: proba_devenir_seigneur category: "Modèle";

	output {
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agglos" value: length(Foyers_Paysans where (each.monAgglo != nil));
		monitor "Nombre d'agglomération rurales" value: length(Agglomerations);
		//monitor "Nombre Agglos CP" value: length(Agglomerations where (length(each.Communaute_Agraire)  > 0));
		monitor "Nombre FP CP" value: length(Foyers_Paysans where (each.comm_agraire));
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: length(Seigneurs where (each.type = "Grand Seigneur"));
		monitor "Nombre Chatelains" value: length(Seigneurs where (each.type = "Chatelain"));
		monitor "Nombre Petits Seigneurs" value: length(Seigneurs where (each.type = "Petit Seigneur"));
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "Attractivité globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		monitor "Attractivité agglos" value: sum(Agglomerations where (!each.fake_agglo) collect each.attractivite);
		display world_display {
			
			species Agglomerations;
			//species Foyers_Paysans aspect: base ;
			species Eglises aspect: base ;
			species Chateaux aspect: base ;
		}
		
	    display demenagements {
	        chart "Déménagements" type: series  {
	            data "Local" value: nb_demenagement_local color: #blue; 
	            data "Lointain" value: nb_demenagement_lointain color: #red;
	            data "Non" value: nb_non_demenagement color: #black;
	        }
    	}
    	
    	display comm_agraires {
			chart "FP" type: series  {
	            data "Hors CA" value: length(Foyers_Paysans where !each.comm_agraire) color: #blue; 
	            data "Dans CA" value: length(Foyers_Paysans where each.comm_agraire)  color: #red;
	        }
    	}
    	
    	display richesses_seigneurs {
    		chart "Richesse seigneurs" type:series {
    			data "Min" value: min(Seigneurs collect each.richesse) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.richesse) color: #blue;
    			data "Max" value: max(Seigneurs collect each.richesse) color: #red;
    		}
    	}
    	
    	display satisfaction_FP {
    		chart "Satisfaction_FP" type:series {
    			data "Satisfaction Materielle" value: mean(Foyers_Paysans collect each.satisfaction_materielle) color: #blue;
    			data "Satisfaction Spirituelle" value: mean(Foyers_Paysans collect each.satisfaction_spirituelle) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.satisfaction_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.Satisfaction) color: #black;
    		}
    	}
	}
}