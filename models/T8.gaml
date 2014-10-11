/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model transition8

// L'ordre compte...
import "init.gaml"
import "global.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Amenites.gaml"

global schedules: list(world) + list(Amenites) + list(Agregats) + list(Foyers_Paysans) + list(Chateaux) + list(Eglises) + list(Seigneurs){
	init {
		do generer_monde;
    }
}
	
experiment base_experiment type: gui {
	
	parameter "Nombre de Foyers Paysans:" var: nombre_foyers_paysans category: "Foyers Paysans";
	parameter "Taux renouvellement" var: taux_renouvellement category: "Foyers Paysans";
	parameter "Taux mobilité des FP" var: taux_mobilite category: "Foyers Paysans";
	
	parameter "Nombre d'agglomérations secondaires antiques:" var: nombre_agglos_antiques category: "Agrégats";
	parameter "Nombre de villages:" var: nombre_villages category: "Agrégats";
	parameter "Nombre de Foyers Paysans par village:" var: nombre_foyers_villages category: "Agrégats";
	
	parameter "Nombre de Seigneurs:" var: nombre_seigneurs category: "Seigneurs";
	parameter "Nombre grands seigneurs" var: nombre_grands_seigneurs category: "Seigneurs";
	parameter "Nombre petits seigneurs" var: nombre_petits_seigneurs category: "Seigneurs";
	parameter "Probabilité (FP) de devenir seigneur" var: proba_devenir_seigneur category: "Seigneurs";
	
	parameter "Nombre d'églises:" var: nombre_eglises category: "Eglises";
		

	output {
		monitor "Année" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agrégat" value: length(Foyers_Paysans where (each.monAgregat != nil));
		monitor "Nombre d'agrégats" value: length(Agregats);
		//monitor "Nombre Agglos CP" value: length(Agglomerations where (length(each.Communaute_Agraire)  > 0));
		monitor "Nombre FP CP" value: length(Foyers_Paysans where (each.comm_agraire));
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: length(Seigneurs where (each.type = "Grand Seigneur"));
		monitor "Nombre Chatelains" value: length(Seigneurs where (each.type = "Chatelain"));
		monitor "Nombre Petits Seigneurs" value: length(Seigneurs where (each.type = "Petit Seigneur"));
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "Attractivité globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		monitor "Attractivité agrégats" value: sum(Agregats where (!each.fake_agregat) collect each.attractivite);
		display world_display {
			
			species Agregats;
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
    			data "Min" value: min(Seigneurs collect each.puissance) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.puissance) color: #blue;
    			data "Max" value: max(Seigneurs collect each.puissance) color: #red;
    		}
    	}
    	
    	display satisfaction_FP {
    		chart "Satisfaction_FP" type:series {
    			data "Satisfaction Materielle" value: mean(Foyers_Paysans collect each.satisfaction_materielle) color: #blue;
    			data "Satisfaction Spirituelle" value: mean(Foyers_Paysans collect each.satisfaction_religieuse) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.satisfaction_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.Satisfaction) color: #black;
    		}
    	}
	}
}