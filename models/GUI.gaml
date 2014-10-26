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
		do generer_monde;
	}
	
	reflex MaJ_globale {
		do reset_globals;
		if (time > 0) {do renouvellement_FP;}
		do update_agregats;
		do creation_nouveaux_seigneurs;
	}
	
	reflex MaJ_Agregats1 when: (length(Chateaux) > 0){
		ask Agregats {do update_chateau;}
	} 
	
	reflex MaJ_Agregats{
		ask Agregats {do update_attractivite;}
	}
	
	reflex MaJ_FP {
		ask Foyers_Paysans{ do update_satisfaction;}
		ask Foyers_Paysans {do demenagement;}
	}
	
	reflex MaJ_Chateaux {
		ask Chateaux {do update_attractivite;}
		//ask Chateaux {do update_agglo;}
	}
	
	reflex MaJ_Eglises {
		ask Eglises {do update_attractivite;}
		ask Eglises where (!each.eglise_paroissiale) {do update_droits_paroissiaux;}
	}
	
	reflex MaJ_Seigneurs1 {
		// TODO : Maj  Droits (sauf Loyers)-> Creation de nouvelles ZP
		ask Seigneurs where (each.type="Grand Seigneur"){do MaJ_droits_Grands_Seigneurs;} // MaJ droits chateaux
		ask Seigneurs where (each.type != "Grand Seigneur") {do MaJ_droits_Petits_Seigneurs;} //MaJ droits chateaux
		
		ask Seigneurs where (each.type != "Grand Seigneur"){do gains_droits_PS;}
		//ask Seigneurs where (each.type="Petit Seigneur"){do MaJ_droits_Petits_Seigneurs;} // FIXME
		//ask Seigneurs where (each.type="Chatelain"){do MaJ_droits_Chatelains;} // FIXME
	}
		
	reflex MaJ_Zones_Prelevement {
		ask Zones_Prelevement {do update_shape;}
	}
	
	reflex MaJ_preleveurs {
		ask Foyers_Paysans {do reset_preleveurs;}
		ask Seigneurs {do reset_variables;}
		do attribution_loyers_FP;
		ask Zones_Prelevement where (each.type_droit != "Loyer"){ do update_taxes_FP;}
	}
		
	reflex MaJ_Seigneurs2 {
		// TODO : Cession de droits sur les ZP (cf. feuille A1b) 

		// TODO : Cession droits châteaux


		if (Annee > 950) {
			ask Seigneurs where (each.type = "Grand Seigneur"){
				do update_droits_chateaux_GS;
				do don_chateaux_GS;
			}
			 
			ask Seigneurs where (each.type = "Chatelain"){
				do don_chateaux_PS;
			}
		} // TODO
		
		ask Seigneurs {
			do MaJ_puissance; // TODO
			do MaJ_puissance_armee;
		}

		ask Seigneurs where (each.type = "Grand Seigneur" and each.puissance > 2000) {
			do construction_chateau_GS;
		}
		
		ask Seigneurs where (each.type != "Grand Seigneur" and each.puissance > 2000){
			do construction_chateau_PS;
		}

		
	}
	
	reflex fin_simulation {
		if (Annee >= fin_simulation) {ask world {do pause;}}
	}
}
	
experiment base_experiment type: gui {
	
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
	
	parameter "Nombre visé de petits seigneurs en fin de simulation" var: nombre_seigneurs_objectif category: "Petits Seigneurs";
	

	
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
    			data "Satisfaction Spirituelle" value: mean(Foyers_Paysans collect each.satisfaction_religieuse) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.satisfaction_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.Satisfaction) color: #black;
    		}
    	}
    	
	    display "FP2" {
    		chart "Nombre de Seigneurs Preleveurs" type:series position: {0,0} size: {1,1}{
    			data "Nb Seigneurs Max" value: max(Foyers_Paysans collect each.nb_preleveurs) color: #blue;
    			data "Nb Seigneurs Mean" value: mean(Foyers_Paysans collect each.nb_preleveurs) color: #green;
    			data "Nb Seigneurs Min" value: min(Foyers_Paysans collect each.nb_preleveurs) color: #red;
    		}
    	}
    	
    	
    	display "Seigneurs" {
    		chart "Puissance des seigneurs" type:series position: {0,0} size: {0.33,1}{
    			data "Min" value: min(Seigneurs collect each.puissance) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.puissance) color: #blue;
    			data "Max" value: max(Seigneurs collect each.puissance) color: #red;
    		}
    		
    		chart "Puissance armée des seigneurs" type:series position: {0.33,0} size: {0.33,1}{
    			data "Min" value: min(Seigneurs collect each.puissance_armee) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.puissance_armee) color: #blue;
    			data "Max" value: max(Seigneurs collect each.puissance_armee) color: #red;
    		}
    		chart "Dépendance (loyer) des FP" type:series position: {0.66,0} size: {0.33,1}{
    			data "FP payant un loyer à un GS" value: length(Foyers_Paysans where (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Grand Seigneur")) color: #green;
    			data "FP payant un loyer à un PS initial" value: length(Foyers_Paysans where (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Petit Seigneur" and each.seigneur_loyer.initialement_present)) color: #blue;
    			data "FP payant un loyer à un PS nouveau" value: length(Foyers_Paysans where (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Petit Seigneur" and !each.seigneur_loyer.initialement_present)) color: #red;
    		}
    	}	
	}
}