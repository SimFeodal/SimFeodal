/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */
model t8

import "init.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"


global {
	int Annee <- 800 update: Annee + 20;
	int nombre_foyers_paysans <- 4000 ;
	int distance_detection_agregats <- 100;
	int nombre_agglos_antiques <- 3 ;
	int nombre_villages <- 20 ;
	int nombre_foyers_villages <- 10 ;
	int nombre_eglises <- 150 ;
	float Seuil_satisfaction <- 0.8 ;
	float taux_renouvellement <- 0.05 ;
	float taux_mobilite <- 0.8;
	int nb_demenagement_local <- 0;
	int nb_demenagement_lointain <- 0;
	int nb_non_demenagement <- 0;
	float proba_devenir_seigneur <- 0.01;
	
	float proba_don_chateau_GS <- 0.33;
	float proba_creer_chateau_GS <- 1.0;
	
	float proba_don_chateau_PS <- 0.15;
	float proba_creer_chateau_PS <- 1.0;
	
	
	bool chatelain_cree_chateau <- false ;
	int nombre_grands_seigneurs <- 2;
	int nombre_petits_seigneurs <- 18;
	int debut_simulation <- 800;
	int fin_simulation <- 1160;
	float puissance_comm_agraire <- 0.5;
	int debut_besoin_protection <- 900;
	int nombre_seigneurs_objectif <- 200;
	int puissance_grand_seigneur1 <- 5;
	int puissance_grand_seigneur2 <- 5;
	
	float proba_don_partie_ZP <- 0.33;
	
	float min_fourchette_loyers_PS_init <- 0.05;
	float max_fourchette_loyers_PS_init <- 0.25;
	float min_fourchette_loyers_PS_nouveau <- 0.0;
	float max_fourchette_loyers_PS_nouveau <- 0.15;
	float proba_collecter_loyer <- 0.1;
	
	int rayon_min_PS_init <- 1000;
	int rayon_max_PS_init <- 5000;
	int rayon_min_PS_nouveau <- 300;
	int rayon_max_PS_nouveau <- 2000;
	
	float proba_gain_droits_hauteJustice_chateau <- 0.1;
	float proba_gain_droits_banaux_chateau <- 0.1;
	float proba_gain_droits_basseMoyenneJustice_chateau <- 0.1;
	
	float proba_creation_ZP_banaux <- 0.05;
	float proba_creation_ZP_basseMoyenneJustice <- 0.05;
	
	int nb_eglises_paroissiales <- 50 ;
	float proba_gain_droits_paroissiaux <- 0.05;
	int nb_max_paroissiens <- 60;
	int nb_min_paroissiens <- 10;
	
	int nb_seigneurs_a_creer_total <- nombre_seigneurs_objectif - (nombre_grands_seigneurs + nombre_petits_seigneurs);
	int nb_moyen_petits_seigneurs_par_tour <- round(nb_seigneurs_a_creer_total / ((fin_simulation - debut_simulation) / 20));
	
	bool save_outputs <- false;
	
	int nb_chateaux ;
	
	const world_bounds type: geometry <- square(100 #km) translated_by {50 #km , 50 #km};
	
	const shape type: geometry <- envelope(world_bounds) ;
	const worldextent type: geometry <- envelope(world_bounds) ;
	const reduced_worldextent type: geometry<- worldextent scaled_by 0.99;
	
    action reset_globals {
		set nb_demenagement_local <- 0;
		set nb_demenagement_lointain <- 0;
		set nb_non_demenagement <- 0;
	}
	
	action outputs_FP {
		
	}
	
	action outputs_Seigneurs {
		
	}
	
	action outputs_ZP {
		
	}
	
	action outputs_Chateaux {
		
	}
	
	action outputs_Agregats {
		
	}
	
	action output_Churches {
		
	}
	
}