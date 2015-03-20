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
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"

global schedules: list(world) + list(Attracteurs) + list(Agregats) + list(Foyers_Paysans) + list(Chateaux) + list(Eglises) + list(Seigneurs){
    
    
	init {
		float t <- machine_time;
		do generer_monde;
		write 'Generation monde : ' + string(machine_time - t);
	}
	
	reflex MaJ_globale {
		float t <- machine_time;
		do reset_globals;
		write 'MaJ globale : ' + string(machine_time - t);
	}
	
	
	reflex renouvellement_monde when: (time > 0){
		float t <- machine_time;
		do renouvellement_FP;
		write 'renouvellement_monde : ' + string(machine_time - t);
	}
		
	reflex MaJ_Agregats{
		float t <- machine_time;
		do update_agregats;
		do creation_nouveaux_seigneurs;
		if (length(Chateaux) > 0){
			ask Agregats {do update_chateau;}
		}
		ask Agregats {do update_attractivite;}
		write 'MaJ_Agregats : ' + string(machine_time - t);
	}
	
	reflex Demenagement_FP {
		float t <- machine_time;
		ask Foyers_Paysans{
			do demenagement;
		}
		write 'Demenagement_FP : ' + string(machine_time - t);
		
	}
	
	reflex MaJ_Chateaux {
		float t <- machine_time;
		ask Chateaux {do update_attractivite;}
		write 'MaJ_Chateaux : ' + string(machine_time - t);
	}
	
	
	reflex MaJ_Eglises {
		float t <- machine_time;
		ask Eglises {do update_attractivite;}
		//ask Eglises where (!each.eglise_paroissiale) {do update_droits_paroissiaux;}
		write 'MaJ_Eglises : ' + string(machine_time - t);
	}
	
	
	reflex MaJ_Droits_Seigneurs {
				float t <- machine_time;
		ask Seigneurs where (each.type="Grand Seigneur"){do MaJ_droits_Grands_Seigneurs;}
		ask Seigneurs where (each.type != "Grand Seigneur") { do MaJ_droits_Petits_Seigneurs; do gains_droits_PS; }
				write 'MaJ_Droits_Seigneurs : ' + string(machine_time - t);
	}
	
	
	reflex MaJ_ZP_et_preleveurs {
		float t <- machine_time;
		ask Zones_Prelevement {do update_shape;}
		write 'MaJ_ZP_et_preleveurs 1/5: ' + string(machine_time - t);
		float t1 <- machine_time;
		ask Foyers_Paysans {do reset_preleveurs;}
		write 'MaJ_ZP_et_preleveurs 2/5: ' + string(machine_time - t1);
		float t2 <- machine_time;
		ask Seigneurs {do reset_variables;}
		write 'MaJ_ZP_et_preleveurs 3/5: ' + string(machine_time - t2);
		float t3 <- machine_time;
		do attribution_loyers_FP;
		write 'MaJ_ZP_et_preleveurs 4/5: ' + string(machine_time - t3);
		float t4 <- machine_time;
		ask Zones_Prelevement where (each.type_droit != "Loyer"){ do update_taxes_FP;}
		write 'MaJ_ZP_et_preleveurs 5/5: ' + string(machine_time - t4);
		write 'MaJ_ZP_et_preleveurs : ' + string(machine_time - t);
	}
	
		
	reflex Dons_des_Seigneurs {
		float t <- machine_time;
		// Don droits
		if (Annee > 880) {
			ask Seigneurs where (each.type = "Grand Seigneur"){ do don_droits_GS; }
			ask Seigneurs where (each.type != "Grand Seigneur"){ do don_droits_PS; }
		}
		// Don châteaux
		if (Annee > 950) {
			ask Seigneurs where (each.type = "Grand Seigneur"){ do update_droits_chateaux_GS; do don_chateaux_GS; }
		}
		ask Seigneurs { do MaJ_puissance; do MaJ_puissance_armee; }
		write 'Dons_des_Seigneurs : ' + string(machine_time - t);
	}
	
	
	reflex Constructions_chateaux {
		float t <- machine_time;
		ask Seigneurs where (each.type = "Grand Seigneur" and each.puissance > 2000) { do construction_chateau_GS;}
		ask Seigneurs where (each.type != "Grand Seigneur" and each.puissance > 2000){ do construction_chateau_PS;}
		write 'Constructions_chateaux : ' + string(machine_time - t);
	}
	
	
	reflex MaJ_satisfaction_FP {
		float t <- machine_time;
		ask Foyers_Paysans {do update_satisfaction;}
		write 'MaJ_satisfaction_FP : ' + string(machine_time - t);
	}
	
	
	reflex MaJ_paroisses {
		float t <- machine_time;
		do compute_paroisses ;
		ask Paroisses {
			do update_fideles;
			do update_satisfaction;
		}
		do promouvoir_paroisses;
		do compute_paroisses ;
		write 'MaJ_paroisses : ' + string(machine_time - t);
	}
	
	
	reflex update_plot {
		float t <- machine_time;
		set nb_non_demenagement <- length(Foyers_Paysans) - (nb_demenagement_local + nb_demenagement_lointain) ;
		ask Seigneurs {
			set monNbZP <- length(Zones_Prelevement where ((each.preleveurs.keys contains self) or (each.proprietaire = self)));
		}
		write 'update_plot : ' + string(machine_time - t);
	}
	
	
	reflex fin_simulation {
		float t <- machine_time;
		if (Annee >= fin_simulation) {ask world {do pause;}}
		write 'fin_simulation : ' + string(machine_time - t);
	}
}
	
experiment base_experiment type: gui multicore: true {
	
	parameter "Année début simulation" var: debut_simulation category: "Simulation";
	parameter "Année fin simulation" var: fin_simulation category: "Simulation";
	
	parameter "Nombre de Foyers Paysans:" var: nombre_foyers_paysans category: "Foyers Paysans";
	parameter "Taux renouvellement" var: taux_renouvellement category: "Foyers Paysans";
	parameter "Taux mobilité des FP" var: taux_mobilite category: "Foyers Paysans";
	parameter "Année début besoin protection" var: debut_besoin_protection category: "Foyers Paysans";
	
	parameter "Nombre d'agglomérations secondaires antiques:" var: nombre_agglos_antiques category: "Agrégats";
	parameter "Nombre de villages:" var: nombre_villages category: "Agrégats";
	parameter "Nombre de Foyers Paysans par village:" var: nombre_foyers_villages category: "Agrégats";
	parameter "Puissance Communautés Agraires" var: puissance_comm_agraire min: 0.0 max: 0.75 category: "Agrégats";
	
	parameter "Nombre grands seigneurs" var: nombre_grands_seigneurs category: "Seigneurs - Init" min: 1 max: 2;
	parameter "Nombre petits seigneurs" var: nombre_petits_seigneurs category: "Seigneurs - Init";
	
	parameter "Puissance Grand Seigneur 1" var: puissance_grand_seigneur1 category: "Grands Seigneurs";
	parameter "Puissance Grand Seigneur 2" var: puissance_grand_seigneur2 category: "Grands Seigneurs";
	parameter "Probabilité créer château GS" var: proba_creer_chateau_GS category: "Grands Seigneurs";
	parameter "Probabilité don château GS" var: proba_don_chateau_GS category: "Grands Seigneurs";
	
	//parameter "Probabilité (FP) de devenir seigneur" var: proba_devenir_seigneur category: "Seigneurs";
	parameter "Châtelain peut créer château" var: chatelain_cree_chateau category: "Seigneurs";

	parameter "Proba. gain droits haute justice sur château" var: proba_gain_droits_hauteJustice_chateau category: "Châtelains";
	parameter "Proba. gain droits banaux sur château" var: proba_gain_droits_banaux_chateau category: "Châtelains";
	parameter "Proba. gain droits BM Justice sur château" var: proba_gain_droits_basseMoyenneJustice_chateau category: "Châtelains";
	parameter "Probabilité créer château GS" var: proba_creer_chateau_PS category: "Châtelains";
	parameter "Probabilité don château GS" var: proba_don_chateau_PS category: "Châtelains";
	
	//parameter "Nombre visé de petits seigneurs en fin de simulation" var: nombre_seigneurs_objectif category: "Petits Seigneurs";
	parameter "Proba. don droits sur ZP" var: proba_don_partie_ZP category: "Petits Seigneurs";	

	parameter "%FP payant un loyer (Petit Seigneur initial) - Borne Min" var: min_fourchette_loyers_PS_init category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "%FP payant un loyer (Petit Seigneur initial) - Borne Max" var: max_fourchette_loyers_PS_init category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "Rayon min Zone Prélevement - Petits Seigneurs Init" var: rayon_min_PS_init category: "Petits Seigneurs" min: 100 max: 20000;
	parameter "Rayon max Zone Prélevement - Petits Seigneurs Init" var: rayon_max_PS_init category: "Petits Seigneurs" min: 100 max: 25000;
	
	parameter "Proba gain nouveaux droits banaux"	var: proba_creation_ZP_banaux category: "Petis Seigneurs";
	parameter "Proba gain nouveaux droits BM justice"	var: proba_creation_ZP_basseMoyenneJustice category: "Petis Seigneurs";

	
	
	parameter "Nombre visé de seigneurs en fin de simulation" var: nombre_seigneurs_objectif category: "Petits Seigneurs";
	parameter "Proba d'obtenir un loyer pour la terre (Petit Seigneur nouveau)" var: proba_collecter_loyer category: "Petits Seigneurs";
	parameter "%FP payant un loyer (Petit Seigneur nouveau) - Borne Min" var: min_fourchette_loyers_PS_nouveau category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "%FP payant un loyer (Petit Seigneur nouveau) - Borne Max" var: max_fourchette_loyers_PS_nouveau category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "Rayon min Zone Prélevement - Petits Seigneurs nouveau" var: rayon_min_PS_nouveau category: "Petits Seigneurs" min: 100 max: 2000;
	parameter "Rayon max Zone Prélevement - Petits Seigneurs nouveau" var: rayon_max_PS_nouveau category: "Petits Seigneurs" min: 100 max: 10000;
	
	parameter "Nombre d'églises:" var: nombre_eglises category: "Eglises";
	parameter "Dont églises paroissiales:" var: nb_eglises_paroissiales category: "Eglises" ;
	parameter "Probabilité gain des droits paroissiaux" var: proba_gain_droits_paroissiaux category: "Eglises";
		

	output {
		monitor "Année" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agrégat" value: length(Foyers_Paysans where (each.monAgregat != nil));
		monitor "Nombre d'agrégats" value: length(Agregats);

		monitor "Nombre FP CP" value: length(Foyers_Paysans where (each.comm_agraire));
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: length(Seigneurs where (each.type = "Grand Seigneur"));
		monitor "Nombre Chatelains" value: length(Seigneurs where (each.type = "Chatelain"));
		monitor "Nombre Petits Seigneurs" value: length(Seigneurs where (each.type = "Petit Seigneur"));
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: length(Eglises where each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "Attractivité globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		monitor "Attractivité agrégats" value: sum(Agregats where (!each.fake_agregat) collect each.attractivite);
		
		
		display "Carte" {
			species Paroisses transparency: 0.9;
			species Zones_Prelevement transparency: 0.9;
			species Eglises aspect: base ;
			species Chateaux aspect: base ;
			species Agregats transparency: 0.3;
			//species Foyers_Paysans aspect: base ;	
		 	text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
		
	    display "Foyers Paysans" {
	        chart "Déménagements" type: series position: {0,0} size: {0.5,0.5}{
	            data "Local" value: nb_demenagement_local color: #blue; 
	            data "Lointain" value: nb_demenagement_lointain color: #red;
	            data "Non" value: nb_non_demenagement color: #black;
	        }
			chart "FP" type: series position: {0.0,0.5} size: {0.5,0.5}{
	            data "Hors CA" value: length(Foyers_Paysans where !each.comm_agraire) color: #blue; 
	            data "Dans CA" value: length(Foyers_Paysans where each.comm_agraire)  color: #red;
	        }
    		chart "Satisfaction_FP" type:series position: {0.5,0} size: {0.5,1}{
    			data "Satisfaction Materielle" value: mean(Foyers_Paysans collect each.satisfaction_materielle) color: #blue;
    			data "Satisfaction Religieuse" value: mean(Foyers_Paysans collect each.satisfaction_religieuse) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.satisfaction_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.Satisfaction) color: #black;
    		}
    	}
    	
	    display "FP et preleveurs" {
    		chart "Nombre de Droits acquittés" type:series position: {0,0} size: {1,1}{
    			data "Nb Droits Max" value: max(Foyers_Paysans collect each.nb_preleveurs) color: #blue;
    			data "Nb Droits Mean" value: mean(Foyers_Paysans collect each.nb_preleveurs) color: #green;
    			data "Nb Droits Median" value: median(Foyers_Paysans collect each.nb_preleveurs) color: #orange;
    			data "Nb Droits Min" value: min(Foyers_Paysans collect each.nb_preleveurs) color: #red;
    		}
    	}
    	
    	
    	display "Seigneurs" {
    		chart "Puissance des seigneurs" type:series position: {0,0} size: {0.33,1}{
    			data "Min" value: min(Seigneurs collect each.puissance) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.puissance) color: #blue;
    			data "Median" value: median(Seigneurs collect each.puissance) color: #orange;
    			data "Max" value: max(Seigneurs collect each.puissance) color: #red;
    		}
    		
    		chart "Puissance armée des seigneurs" type:series position: {0.33,0} size: {0.33,1}{
    			data "Min" value: min(Seigneurs collect each.puissance_armee) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.puissance_armee) color: #blue;
    			data "Med" value:  median(Seigneurs collect each.puissance_armee) color: #orange;
    			data "Max" value: max(Seigneurs collect each.puissance_armee) color: #red;
    		}
    		chart "Dépendance (loyer) des FP" type:series position: {0.66,0} size: {0.33,1}{
    			data "FP payant un loyer à un GS" value: length(Foyers_Paysans where (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Grand Seigneur")) color: #green;
    			data "FP payant un loyer à un PS initial" value: length(Foyers_Paysans where (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Petit Seigneur" and each.seigneur_loyer.initialement_present)) color: #blue;
    			data "FP payant un loyer à un PS nouveau" value: length(Foyers_Paysans where (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Petit Seigneur" and !each.seigneur_loyer.initialement_present)) color: #red;
    		}
    	}
    	    	
    	display "Zones Prelevement"{
    		chart "Nombre de ZP" type:series position: {0.0, 0.0} size: {1.0, 0.33}{
    			data "Loyers" value: length(Zones_Prelevement where (each.type_droit = "Loyer")) color: #blue;
    			data "Haute Justice" value: length(Zones_Prelevement where (each.type_droit = "Haute_Justice")) color: #red;
    			data "Banaux" value: length(Zones_Prelevement where (each.type_droit = "Banaux")) color: #green;
    			data "Basse et Moyenne Justice" value: length(Zones_Prelevement where (each.type_droit = "basseMoyenne_Justice")) color: #yellow;
    		}
    		chart "Nb de preleveurs" type: series position: {0, 0.33} size: {1.0, 0.33}{
    			data "Max" value: max ( Zones_Prelevement collect (length(each.preleveurs.keys))) color: #red;
    			data "Mean" value: mean ( Zones_Prelevement collect (length(each.preleveurs.keys))) color: #green;
    			data "Min" value: min ( Zones_Prelevement collect (length(each.preleveurs.keys))) color: #blue;
    			data "Med" value: median(Zones_Prelevement collect (length(each.preleveurs.keys))) color: #orange;
    		}
    		chart "Nb ZP / Seigneur" type: series position: {0.0, 0.66} size: {1.0, 0.33}{
    			data "Max" value: max(Seigneurs collect each.monNbZP) color: #red;
    			data "Mean" value: mean(Seigneurs collect each.monNbZP) color: #green;
    			data "Median" value: median(Seigneurs collect each.monNbZP) color: #orange;
    			data "Min" value: min(Seigneurs collect each.monNbZP) color: #blue;	
    		}
    	}
    	
    	display "Agrégats"{
    		chart "Nombre d'agrégats" type: series position: {0.0,0.0} size: {1.0, 0.5}{
    			data "Nombre d'agrégats" value: length(Agregats) color: #red;
    			data "Nombre d'agrégats avec CA" value: length(Agregats where each.communaute_agraire) color: #blue;
    		}
    		chart "Composition des agrégats" type: series position: {0.0, 0.5} size: {1.0, 0.5}{
    			data "Max" value: max(Agregats collect length(each.fp_agregat)) color: #red;
    			data "Mean" value: mean(Agregats collect length(each.fp_agregat)) color: #green;
    			data "Median" value: median(Agregats collect length(each.fp_agregat)) color: #orange;
    			data "Min" value: min(Agregats collect length(each.fp_agregat)) color: #blue;
    			
    		}
    	}	
	}
}