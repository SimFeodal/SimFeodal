/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 * Version 5.0 (ex 4.5)
 * Run with : gama 1.7 git : commit : 9484b484f0e07981670fcab6122209292c0c3f5a
 * (Gama 1.7 git 2017-07-12 14h35h09 +0700)
 */

model t8

// L'ordre compte...
import "run.gaml"	
	
experiment Exp_6_base_FullGUI type: gui benchmark: false until: (annee >= fin_simulation){
	parameter 'experimentType' var: experimentType init: "gui";
	parameter 'prefix' var: prefix_output init: "6_0";
	
	parameter 'save_outputs' var: save_outputs init: false;
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions

output {
		monitor "Annee" value: annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agregat" value: Foyers_Paysans count (each.monAgregat != nil);
		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Chatelains" value: Seigneurs count (each.type = "Chatelain");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		monitor "Sat moyenne" value: mean(Foyers_Paysans collect each.Satisfaction);
		
		display "Carte" type: "opengl" {
			species Paroisses transparency: 0.9 ;
			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
	//		text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}		
	    display "Foyers Paysans" {
	        chart "Déménagements" type: series position: {0,0} size: {0.5,0.5}{
	            data "Local" value: nb_demenagement_local color: #blue; 
	            data "Lointain" value: nb_demenagement_lointain color: #red;
	            data "Non" value: length(Foyers_Paysans) - (nb_demenagement_local + nb_demenagement_lointain) color: #black;
	        }
			chart "Concentration" type: series position: {0.0,0.5} size: {0.5,0.5}{
	            data "% FP dans agrégat" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100 color: #blue; 
	        }
    		chart "Satisfaction_FP" type:series position: {0.5,0} size: {0.5,1}{
    			data "Satisfaction Materielle" value: mean(Foyers_Paysans collect each.satisfaction_materielle) color: #blue;
    			data "Satisfaction Spirituelle" value: mean(Foyers_Paysans collect each.satisfaction_religieuse) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.satisfaction_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.Satisfaction) color: #black;
    		}
    	}
	}
}

experiment Exp_6_0_Debug type: gui repeat: 1 keep_seed: false until: (annee >= fin_simulation){
	parameter 'save_outputs' var: save_outputs init: true;
	parameter 'prefix' var: prefix_output init: "6_0_Debug";
	parameter "benchmark" var: benchmark init: false; // Changement pour connaitre perfs fonctions
	// 1 experiment
}
