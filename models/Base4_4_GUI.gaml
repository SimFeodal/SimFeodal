/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 */

model t8

// L'ordre compte...
import "run.gaml"	
	
experiment Exp_4_4_gui type: gui multicore: true {
	parameter 'save_outputs' var: save_outputs among: [true];
	parameter 'prefix' var: prefix_output among: ["4_4ter"];
	parameter "benchmark" var: benchmark among: [false]; // Changement pour connaitre perfs fonctions
	
	parameter "nombre_FP_village" var: nombre_FP_village among: [10];

	

	output {
		monitor "Annee" value: Annee;
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
		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}	
		
	    display "Foyers Paysans" {
	        chart "Demenagements" type: series position: {0,0} size: {0.5,0.5}{
	            data "Local" value: nb_demenagement_local color: #blue; 
	            data "Lointain" value: nb_demenagement_lointain color: #red;
	        }
			chart "FP" type: series position: {0.0,0.5} size: {0.5,0.5}{
	            data "Hors CA" value: Foyers_Paysans count (!each.communaute) color: #blue; 
	            data "Dans CA" value: Foyers_Paysans count (each.communaute)  color: #red;
	        }
    		chart "Satisfaction_FP" type:series position: {0.5,0} size: {0.5,1}{
    			data "Satisfaction Materielle" value: mean(Foyers_Paysans collect each.satisfaction_materielle) color: #blue;
    			data "Satisfaction Religieuse" value: mean(Foyers_Paysans collect each.satisfaction_religieuse) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.satisfaction_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.Satisfaction) color: #black;
    		}
    	}

    	display "Agregats"{
    		chart "Nombre d'agregats" type: series position: {0.0,0.0} size: {1.0, 0.33}{
    			data "Nombre d'agregats" value: length(Agregats) color: #red;
    			data "Nombre d'agregats avec CA" value: Agregats count (each.communaute) color: #blue;
    		}
    		chart "Composition des agregats" type: series position: {0.0, 0.33} size: {1.0, 0.33}{
    			data "Max" value: max(Agregats collect length(each.fp_agregat)) color: #red;
    			data "Mean" value: mean(Agregats collect length(each.fp_agregat)) color: #green;
    			data "Median" value: median(Agregats collect length(each.fp_agregat)) color: #orange;
    			data "Min" value: min(Agregats collect length(each.fp_agregat)) color: #blue;
    		}
    		chart "Nb FP agregats" type: series position: {0.0, 0.66} size: {1.0, 0.33}{
    			data "NB FP ds Agregats" value: Foyers_Paysans count (each.monAgregat != nil);
    		}
    		
    	}
    	
    	display "Chateaux/Eglises"{
    		chart "Nombre de chateaux" type: series position: {0.0,0.0} size: {1.0, 0.33}{
    			data "Importants (>=5km)" value: Chateaux count (each.monRayon >= 5000) color: #red;
    			data "Mineurs (<5km)" value: Chateaux count (each.monRayon < 5000) color: #blue;
    		}
    		chart "Eglises" type: series position: {0.0, 0.33} size: {1.0, 0.33}{
    			data "Batiments" value: length(Eglises) color: #red;
    			data "Paroisses" value: Eglises count (each.eglise_paroissiale) color: #blue;		
    		}
    		chart "Eglises ds paroisses" type: series position:{0.0, 0.66} size: {1.0, 0.33 }{
    			data "Nb eglises / paroisse Mean" value: mean(Paroisses collect length(Eglises inside (each.shape)));
    		}
    	}	
	}
}

//
//experiment Exp_4_4_batch type: batch repeat: 20 keep_seed: true multicore: true until: (Annee >= fin_simulation){
//	// On a juste changé l'ordonnancement en mettant promo chateaux juste avant construction chateaux
//	parameter 'save_TMD' var: save_TMD among: [true];
//	parameter 'prefix' var: prefix_output among: ["4_4ter"];
//	parameter "benchmark" var: benchmark among: [false]; // Changement pour connaitre perfs fonctions
//	
//	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true];
//	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false];
//	parameter "satisfaction_alternate" var: satisfaction_alternate among: [true];
//	parameter "deplacement_local_agregats_alternate" var: deplacement_local_agregats_alternate among:[true]; // Nouveau 4_4ter
//	
//	
//	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
//	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
//	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
//	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
//	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
//	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
//	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
//	parameter "attrac_GC" var: attrac_GC among: [0.25];
//	parameter "attrac_PC" var: attrac_PC among: [0.15];
//	
//	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
//	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
//	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
//	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
//	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
//	parameter "nombre_FP_village" var: nombre_FP_village among: [10];
//	
//
//	output {
//		monitor "Annee" value: Annee;
//		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
//
//		monitor "Nombre d'agregats" value: length(Agregats);
//
//		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
//		monitor "Nombre Seigneurs" value: length(Seigneurs);
//		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
//		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
//		monitor "Nombre Eglises" value: length(Eglises);
//		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
//		monitor "Nombre Chateaux" value: length(Chateaux);
//				
//		
//		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
//
//
//		
//		display "Carte" {
//			species Paroisses transparency: 0.9 ;
//			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
//			species Chateaux aspect: base ;
//			species Agregats transparency: 0.3;
//			species Poles transparency: 0.3;
//			
//			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
//		}
//	}
//}
