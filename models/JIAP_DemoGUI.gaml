/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 */

model t8

// L'ordre compte...
import "run.gaml"
	
experiment JIAP_Graphique type: gui multicore: true {
	
	// GLOBAL //
	
	float seed <- 1000.0;
	parameter "Enregistrer sorties ?" var: save_outputs category: "Simulation";
	parameter "Annee debut simulation" var: debut_simulation category: "Simulation";
	parameter "Annee fin simulation" var: fin_simulation category: "Simulation";
	parameter "Duree d'un pas de temps" var: duree_step category: "Simulation";
	
	// AGREGATS //
	
	parameter "Distance agregats" var: distance_detection_agregats category: "Agregats";
	parameter "Nombre de Foyers Paysans pour definir Agregat" var: nombre_FP_agregat category: "Agregats";
	parameter "Nombre d'agglomerations secondaires antiques:" var: nombre_agglos_antiques category: "Agregats";
	parameter "Nombre de villages:" var: nombre_villages category: "Agregats";
	parameter "Nombre max de Foyers Paysans par village:" var: nombre_foyers_villages_max category: "Agregats";
	parameter "Annee d'apparition des communautes" var: apparition_communautes category: "Agregats";
	parameter "Puissance Communautes" var: puissance_communautes min: 0.0 max: 0.75 category: "Agregats";
	parameter "Proba. apparition Communaute" var: proba_apparition_communaute min: 0.0 max: 1.0 category: "Agregats";
	
	// FOYERS_PAYSANS //
	
	parameter "Nombre de Foyers Paysans:" var: nombre_foyers_paysans category: "Foyers Paysans";
	parameter "Taux renouvellement" var: taux_renouvellement category: "Foyers Paysans";
	parameter "Taux mobilite des FP" var: taux_mobilite category: "Foyers Paysans";
	parameter "Distance max deplacement local" var: distance_max_dem_local category: "Foyers Paysans";
	parameter "Seuil de puissance armee necessaire a protection" var: seuil_puissance_armee category: "Foyers Paysans";
	
	// SEIGNEURS //
	
	parameter "Nombre vise de seigneurs en fin de simulation" var: nombre_seigneurs_objectif category: "Seigneurs";
	parameter "Nombre grands seigneurs" var: nombre_grands_seigneurs category: "Seigneurs" min: 1 max: 2;
	parameter "Nombre petits seigneurs" var: nombre_petits_seigneurs category: "Seigneurs";
	
	parameter "Puissance Grand Seigneur 1" var: puissance_grand_seigneur1 category: "Seigneurs";
	parameter "Puissance Grand Seigneur 2" var: puissance_grand_seigneur2 category: "Seigneurs";
	
	parameter "Proba d'obtenir un loyer pour la terre (Petit Seigneur nouveau)" var: proba_collecter_loyer category: "Seigneurs";
	
	parameter "Proba gain nouveaux droits banaux"	var: proba_creation_ZP_banaux category: "Seigneurs";
	parameter "Proba gain nouveaux droits BM justice"	var: proba_creation_ZP_basseMoyenneJustice category: "Seigneurs";
	
	
	// ZONES_PRELEVEMENT //
	
	parameter "Rayon min Zone Prelevement - Petits Seigneurs" var: rayon_min_PS category: "Zones Prelevement" min: 100 max: 20000;
	parameter "Rayon max Zone Prelevement - Petits Seigneurs" var: rayon_max_PS category: "Zones Prelevement" min: 100 max: 25000;
	parameter "%FP payant un loyer (Petit Seigneur) - Borne Min" var: min_fourchette_loyers_PS category: "Zones Prelevement" min: 0.0 max: 1.0;
	parameter "%FP payant un loyer (Petit Seigneur) - Borne Max" var: max_fourchette_loyers_PS category: "Zones Prelevement" min: 0.0 max: 1.0;
	
	parameter "Proba. don droits sur ZP" var: proba_don_partie_ZP category: "Zones Prelevement";	
	
	// CHATEAUX //
		
	parameter "Annee apparition chateaux" var: apparition_chateaux	category:"Chateaux";
	
	//FIXME : Add doc.
	parameter "Seuil max de puissance armée d'un chateau" var: seuil_attractivite_chateau category:"Chateaux";
	
	parameter "Probabilite creer chateau GS" var: proba_creer_chateau_GS category: "Chateaux";
	parameter "Proba. qu'un chateau soit cree dans agregat" var: proba_chateau_agregat category: "Chateaux" min: 0.0 max: 1.0;
	parameter "Probabilite don chateau GS" var: proba_don_chateau_GS category: "Chateaux";
	parameter "Probabilite creer chateau PS" var: proba_creer_chateau_PS category: "Chateaux";
	
	parameter "Proba. gain droits haute justice sur chateau" var: proba_gain_droits_hauteJustice_chateau category: "Chateaux";
	parameter "Proba. gain droits banaux sur chateau" var: proba_gain_droits_banaux_chateau category: "Chateaux";
	parameter "Proba. gain droits BM Justice sur chateau" var: proba_gain_droits_basseMoyenneJustice_chateau category: "Chateaux";

	// EGLISES //
	
	parameter "Nombre d'eglises:" var: nombre_eglises category: "Eglises";
	parameter "Dont eglises paroissiales:" var: nb_eglises_paroissiales category: "Eglises" ;
	parameter "Probabilite gain des droits paroissiaux" var: proba_gain_droits_paroissiaux category: "Eglises";
	parameter "Nombre max de paroissiens" var: nb_max_paroissiens category: "Eglises";
	parameter "Nombre min de paroissiens" var: nb_min_paroissiens category: "Eglises";	

	

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
		monitor "Attractivite globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		monitor "Attractivite agregats" value: sum(Agregats where (!each.fake_agregat) collect each.attractivite);
		
		
		monitor "P.A. GS" value: (Seigneurs where (each.type = "Grand Seigneur")) collect each.puissance_armee;
		
		monitor "Mean Puissance armee" value: mean((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Min Puissance armee" value: min((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Max Puissance armee" value: max((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		
		monitor "Mean Puissance" value: mean(Seigneurs collect (each.puissance));
		monitor "Min Puissance" value: min(Seigneurs collect (each.puissance));
		monitor "Max Puissance" value: max(Seigneurs collect (each.puissance));
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		
		
		monitor "Dist. moyenne au plus proche voisin (FP)" value: 1;
		
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
