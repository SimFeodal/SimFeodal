/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 */

model t8

// L'ordre compte...
// import "run.gaml // Jusqu'à version 4.2
// import "run4_2.gaml" // Jusqu'à version 4.4
import "run4_4.gaml"	
	
experiment Exp_Graphique type: gui multicore: true {
	
	// GLOBAL //
	
	float seed <- 1000.0;
	parameter "Benchmark?" var: benchmark category: "Simulation";
	parameter "Enregistrer sorties ?" var: save_outputs category: "Simulation";
	parameter "Annee debut simulation" var: debut_simulation category: "Simulation";
	parameter "Annee fin simulation" var: fin_simulation category: "Simulation";
	parameter "Duree d'un pas de temps" var: duree_step category: "Simulation";
	
	// AGREGATS //
	
	parameter "Distance agregats" var: distance_detection_agregats category: "Agregats";
	parameter "Nombre de Foyers Paysans pour definir Agregat" var: nombre_FP_agregat category: "Agregats";
	parameter "Nombre d'agglomerations secondaires antiques:" var: nombre_agglos_antiques category: "Agregats";
	parameter "Nombre de villages:" var: nombre_villages category: "Agregats";
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
		
		
		monitor "P.A. GS" value: (Seigneurs where (each.type = "Grand Seigneur")) collect each.puissance_armee;
		
		monitor "Mean Puissance armee" value: mean((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Min Puissance armee" value: min((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Max Puissance armee" value: max((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		
		monitor "Mean Puissance" value: mean(Seigneurs collect (each.puissance));
		monitor "Min Puissance" value: min(Seigneurs collect (each.puissance));
		monitor "Max Puissance" value: max(Seigneurs collect (each.puissance));
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		
		
		monitor "Dist. moyenne au plus proche voisin (FP)" value: 1; // FIXME: Distance moyenne au plus proche voisin (ds même agrégat)
		// TODO : Distribution du nombre de FP par agrégats
		// TODO : Distribution du nombre de châteaux par seigneur
		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
//		
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



experiment "Explo_TMD_base3_1" type: batch repeat:20 keep_seed: true multicore: true until: (Annee >= fin_simulation){
	
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["base3_1"];
	
	// Seuil de paroissiens nécessaire à la création d’une nouvelle paroisse en agrégat : 200
	parameter 'seuil_creation_paroisse' var: seuil_creation_paroisse among: [300];
	
	// Augmenter seuil de FP insatisfait pour promotion église : passer de 5 à 10 FP
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [20];
	
	//  Augmenter un peu la probabilité de promotion en grand châteaux :
	//    Probabilité qu'un château isolé devienne un gros château : 0.3
	//    Probabilité qu'un château situé dans un pôle devienne un gros château : 0.8
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];
	
	
	
	// Exploration pour chap 5.2 :
	
	//Grands seigneurs : croissance exponentielle de la probabilité de construire un château
	// au fur et à mesure de l'augmentation de la puissance du seigneur.
	// Valeurs de cadrage :
	// 		puissance inférieure à 1000 : p = 0
	// 		puissance de 1000 : p = 0,5
	// 		puissance de 2000 : p = 0,7
	// 		puissance de 50 000 : p = 1.
	// Équation : p(puissance) =  1- e-0.00064*puissance
	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	
	// Petits seigneurs : puissance de 0 : p = 0. Puissance de 2000 : p = 1.
	// Croissance linéaire de la probabilité en fonction de la puissance du seigneur.
	// Un seul tirage de probabilité.
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	
	// Pb avec la variable S_protection liée à la puissance armée du châtelain
	// Modification du modèle : supprimer cette variable du modèle
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	
	// Avec cette augmentation du rayon de déplacement des FP à 5km,
	// la distribution rang-taille des agrégats est moins satisfaisante
	// et le nombre de FP isolés un peu plus élevé.
	// -> On repasse la distance max. de déménagement local des FP à 2.5 km
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	
	//Modification à apporter au modèle :
	// trois (et non deux) tirages successifs de probabilité de construire un château pour les grands seigneurs
	parameter "nb_chateaux_potentiels_GS" var: nb_chateaux_potentiels_GS among: [2];
	
	// Deuxième problème : après 940, les FP deviennent majoritairement très insatisfaits, d'où un très grand nombre de déménagements.
	// Actuellement, les attracteurs considérés dans le modèle sont les châteaux et les églises.
	// Ajouter une nouveau type d'attracteur = les communautés (représentation possible :
	// 		un point situé au centre de l'agrégat) avec une attractivité égale à 0,05.
	parameter "communautes_attractives" var: communautes_attractives among:[true];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	
	// Concernant la modélisation des déplacements des foyers paysans :
	// il n'y a pas de mécanisme qui leur fait comparer les aspects push (insatisfaction en leur localisation actuelle)
	// et pull (attractivité d'autres localisations possibles)
	// 		=> Quand ils ne peuvent être pleinement satisfaits là où ils sont (absence de pôle fortement attractif), ils ne cessent de déménager.
	// Modification à apporter au modèle :
	// 		1) Identifier le pôle le plus attractif localement
	// 		2) p(deplacement_local) = MAX [(Attractivité du pôle le plus attractif localement - Satisfaction_FP), 0]
	// 		3) En cas de déplacement local, pour déterminer quel pôle sera choisi par le FP pour s'y localiser,
	// 			appliquer la loterie pondérée par l'attractivité de chaque pôle
	// 		4) Si pas de déplacement local, p(deplacement_lointain) = 0,2 * (1 - Satisfaction_FP)
	//parameter "deplacement_alternate" var: deplacement_alternate among: [true]; // -> Paramètre supprimé car devenu norme
	
		// Attractivité des pôles  : prendre les valeurs bien différenciées
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];	
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [true];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
}


experiment Exp_debug type: gui {
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	
}

experiment Base4_1 type: gui {
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];// CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_simplifie" var: agregats_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
}

experiment Base4_1_FPvillages type: gui {
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "nombre_FP_village" var: nombre_FP_village among: [6]; // CHANGEMENT (par rapport à 3.1) ! TODO
}

experiment Base4_1_FPvillages7 type: gui {
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_simplifie" var: agregats_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "nombre_FP_village" var: nombre_FP_village among: [7]; // CHANGEMENT (par rapport à 3.1) ! TODO
}


experiment Base4_1_FPvillages10batch type: batch repeat:2 keep_seed: true multicore: true until: (Annee >= fin_simulation){
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["afterTMD_FPvillages"];
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
	parameter "nombre_FP_village" var: nombre_FP_village among: [10];
}


experiment Base4_2 type: batch repeat:2 keep_seed: true multicore: true until: (Annee >= fin_simulation) {
	// Changement de l'ordonnancement dans le run.gaml
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.25]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_PC" var: attrac_PC among: [0.1];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_simplifie" var: agregats_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "nombre_FP_village" var: nombre_FP_village among: [10]; // CHANGEMENT (par rapport à 3.1) ! TODO
}


experiment Exp_Graphique_4_2 type: gui multicore: true {
		// Changement de l'ordonnancement dans le run.gaml
	
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_2_SansCroissance"];
	
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];// CHANGEMENT (par rapport à 4.1) ! TODO
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15]; // CHANGEMENT (par rapport à 4.1) ! TODO
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25]; // CHANGEMENT (par rapport à 4.1) ! TODO
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5]; // CHANGEMENT (par rapport à 4.1) ! TODO
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6]; // CHANGEMENT (par rapport à 4.1) ! TODO
	parameter "attrac_GC" var: attrac_GC among: [0.25]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_simplifie" var: agregats_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
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
		monitor "Attractivite globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		
		
		monitor "P.A. GS" value: (Seigneurs where (each.type = "Grand Seigneur")) collect each.puissance_armee;
		
		monitor "Mean Puissance armee" value: mean((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Min Puissance armee" value: min((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Max Puissance armee" value: max((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		
		monitor "Mean Puissance" value: mean(Seigneurs collect (each.puissance));
		monitor "Min Puissance" value: min(Seigneurs collect (each.puissance));
		monitor "Max Puissance" value: max(Seigneurs collect (each.puissance));
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		
		
		monitor "Dist. moyenne au plus proche voisin (FP)" value: 1; // FIXME: Distance moyenne au plus proche voisin (ds même agrégat)
		// TODO : Distribution du nombre de FP par agrégats
		// TODO : Distribution du nombre de châteaux par seigneur
		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
//			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
//			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}

experiment Exp_Graphique_4_3 type: gui {
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_3"];
	
	
	// proba Deplacement local devient 1- Satisfaction MAIS rayon dem_local augmente au cours du temps
	 // Rayon augmente avec temps 
	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true]; // CHANGEMENT (par rapport à 4.2) ! TODO
	// Changement désactivé du mécanisme simplifié de flip de déplacement local
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false];
	
	
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
	parameter "attrac_GC" var: attrac_GC among: [0.25]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_simplifie" var: agregats_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "nombre_FP_village" var: nombre_FP_village among: [10]; // CHANGEMENT (par rapport à 3.1) ! TODO
	

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
		
		
		monitor "P.A. GS" value: (Seigneurs where (each.type = "Grand Seigneur")) collect each.puissance_armee;
		
		monitor "Mean Puissance armee" value: mean((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Min Puissance armee" value: min((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Max Puissance armee" value: max((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		
		monitor "Mean Puissance" value: mean(Seigneurs collect (each.puissance));
		monitor "Min Puissance" value: min(Seigneurs collect (each.puissance));
		monitor "Max Puissance" value: max(Seigneurs collect (each.puissance));
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		
		
		monitor "Dist. moyenne au plus proche voisin (FP)" value: 1; // FIXME: Distance moyenne au plus proche voisin (ds même agrégat)
		// TODO : Distribution du nombre de FP par agrégats

		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
//			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
//			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}


experiment Exp_Graphique_4_3bis type: gui {
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_3bis"];
	
	
	// proba Deplacement local devient 1- Satisfaction MAIS rayon dem_local augmente au cours du temps
	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true]; // Rayon augmente avec temps
	
	// Changement du mécanisme simplifié de flip de déplacement local
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [true]; // CHANGEMENT (par rapport à 4.3) ! TODO 
	
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
	parameter "attrac_GC" var: attrac_GC among: [0.25];
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
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
		monitor "Attractivite globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		
		
		monitor "P.A. GS" value: (Seigneurs where (each.type = "Grand Seigneur")) collect each.puissance_armee;
		
		monitor "Mean Puissance armee" value: mean((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Min Puissance armee" value: min((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Max Puissance armee" value: max((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		
		monitor "Mean Puissance" value: mean(Seigneurs collect (each.puissance));
		monitor "Min Puissance" value: min(Seigneurs collect (each.puissance));
		monitor "Max Puissance" value: max(Seigneurs collect (each.puissance));
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		
		
		monitor "Dist. moyenne au plus proche voisin (FP)" value: 1; // FIXME: Distance moyenne au plus proche voisin (ds même agrégat)
		// TODO : Distribution du nombre de FP par agrégats

		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
//			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
//			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}


experiment Exp_Graphique_4_3ter type: gui {
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_3ter"];
	

	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true];
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false]; // CHANGEMENT (par rapport à 4.3bis) ! TODO
	// Changement calcul satisfaction en augmentant poids communauté
	parameter "satisfaction_alternate" var: satisfaction_alternate among: [true];  // CHANGEMENT (par rapport à 4.3bis) ! TODO
	
	
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	// CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];// CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];// CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];// CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];// CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_GC" var: attrac_GC among: [0.25]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "attrac_PC" var: attrac_PC among: [0.15];// CHANGEMENT (par rapport à 3.1) ! TODO
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "agregats_simplifie" var: agregats_simplifie among: [true]; // CHANGEMENT (par rapport à 3.1) ! TODO
	parameter "nombre_FP_village" var: nombre_FP_village among: [10]; // CHANGEMENT (par rapport à 3.1) ! TODO
	

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
		
		
		monitor "P.A. GS" value: (Seigneurs where (each.type = "Grand Seigneur")) collect each.puissance_armee;
		
		monitor "Mean Puissance armee" value: mean((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Min Puissance armee" value: min((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		monitor "Max Puissance armee" value: max((Seigneurs where (each.type = "Chatelain")) collect (each.puissance_armee));
		
		monitor "Mean Puissance" value: mean(Seigneurs collect (each.puissance));
		monitor "Min Puissance" value: min(Seigneurs collect (each.puissance));
		monitor "Max Puissance" value: max(Seigneurs collect (each.puissance));
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;
		
		
		monitor "Dist. moyenne au plus proche voisin (FP)" value: 1; // FIXME: Distance moyenne au plus proche voisin (ds même agrégat)
		// TODO : Distribution du nombre de FP par agrégats

		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
//			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
//			species Foyers_Paysans transparency: 0.5;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}


experiment Exp_Graphique_4_4 type: batch repeat: 10 keep_seed: true multicore: true until: (Annee >= fin_simulation){
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_4"];
	parameter "benchmark" var: benchmark among: [true]; // Changement pour connaitre perfs fonctions
	
	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true];
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false];
	parameter "satisfaction_alternate" var: satisfaction_alternate among: [true];
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
	parameter "attrac_GC" var: attrac_GC among: [0.25];
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
	parameter "nombre_FP_village" var: nombre_FP_village among: [10];
	

	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);

		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
				
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;


		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}


experiment Exp_Graphique_4_4bis type: batch repeat: 2 keep_seed: true multicore: true until: (Annee >= fin_simulation){
	// On a juste changé l'ordonnancement en mettant promo chateaux juste avant construction chateaux
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_4"];
	parameter "benchmark" var: benchmark among: [false]; // Changement pour connaitre perfs fonctions
	
	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true];
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false];
	parameter "satisfaction_alternate" var: satisfaction_alternate among: [true];
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
	parameter "attrac_GC" var: attrac_GC among: [0.25];
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
	parameter "nombre_FP_village" var: nombre_FP_village among: [10];
	

	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);

		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
				
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;


		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}


experiment Exp_Graphique_4_4ter type: batch repeat: 2 keep_seed: true multicore: true until: (Annee >= fin_simulation){
	// On a juste changé l'ordonnancement en mettant promo chateaux juste avant construction chateaux
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_4ter"];
	parameter "benchmark" var: benchmark among: [false]; // Changement pour connaitre perfs fonctions
	
	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true];
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false];
	parameter "satisfaction_alternate" var: satisfaction_alternate among: [true];
	parameter "deplacement_local_agregats_alternate" var: deplacement_local_agregats_alternate among:[true]; // Nouveau 4_4ter
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
	parameter "attrac_GC" var: attrac_GC among: [0.25];
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
	parameter "nombre_FP_village" var: nombre_FP_village among: [10];
	

	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);

		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
				
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;


		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}

experiment Exp_Graphique_4_4quatro type: batch repeat: 2 keep_seed: true multicore: true until: (Annee >= fin_simulation){
	// On change un des seuils d'évolution de la distance locale, cf. global (après 1000, reste à 4000 (au lieu de 6000)).
	
	
	// On a juste changé l'ordonnancement en mettant promo chateaux juste avant construction chateaux
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_4quatro"];
	parameter "benchmark" var: benchmark among: [false]; // Changement pour connaitre perfs fonctions
	
	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true];
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false];
	parameter "satisfaction_alternate" var: satisfaction_alternate among: [true];
	parameter "deplacement_local_agregats_alternate" var: deplacement_local_agregats_alternate among:[true]; // Nouveau 4_4ter
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
	parameter "attrac_GC" var: attrac_GC among: [0.25];
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
	parameter "nombre_FP_village" var: nombre_FP_village among: [10];
	

	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);

		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
				
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;


		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}


experiment Exp_Graphique_4_4terGraphique type: gui {
	// On a juste changé l'ordonnancement en mettant promo chateaux juste avant construction chateaux
	parameter 'save_TMD' var: save_TMD among: [true];
	parameter 'prefix' var: prefix_output among: ["4_4ter"];
	parameter "benchmark" var: benchmark among: [false]; // Changement pour connaitre perfs fonctions
	
	parameter "augmentation_max_dem_local" var: augmentation_max_dem_local among: [true];
	parameter "deplacement_local_alternate" var: deplacement_local_alternate among: [false];
	parameter "satisfaction_alternate" var: satisfaction_alternate among: [true];
	parameter "deplacement_local_agregats_alternate" var: deplacement_local_agregats_alternate among:[true]; // Nouveau 4_4ter
	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "attrac_communautes" var:attrac_communautes among: [0.15];	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.15];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.5];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.6];
	parameter "attrac_GC" var: attrac_GC among: [0.25];
	parameter "attrac_PC" var: attrac_PC among: [0.15];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [false];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [false];
	parameter "poles_shape_simplifie" var: poles_shape_simplifie among: [true];
	parameter "agregats_simplifie" var: agregats_simplifie among: [true];
	parameter "nombre_FP_village" var: nombre_FP_village among: [10];
	

	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);

		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP Comm." value: Foyers_Paysans count (each.communaute);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
				
		
		monitor "% FP dispersés" value: Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans) * 100;


		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base transparency: 0.5;
			species Chateaux aspect: base ;
			species Agregats transparency: 0.3;
			species Poles transparency: 0.3;
			
			text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
	}
}


////// ON RESTE SUR 4_4ter qui devient 4_4 ////////////