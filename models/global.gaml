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
	////////////
	// INPUTS //
	////////////
	
	// GLOBAL //
	
	bool save_outputs <- false;
	int debut_simulation <- 800;
	int fin_simulation <- 1160;
	int duree_step <- 20;
	float besoin_protection <- 0.0;
	
	// AGREGATS //
	
	int distance_detection_agregats <- 100;
	int nombre_FP_agregat <- 5;
	int nombre_agglos_antiques <- 4 ;
	int nombre_villages <- 20 ;
	int nombre_foyers_villages <- 5 ;
	float puissance_communautes <- 0.25;
	int apparition_communautes <- 800;
	float proba_apparition_communaute <- 0.2;
	
	// FOYERS_PAYSANS //
	
	int nombre_foyers_paysans <- 4000 ;
	float taux_renouvellement <- 0.05 ;
	float taux_mobilite <- 0.8;
	int debut_besoin_protection <- 900;
	int distance_max_dem_local <- 7000;
	int seuil_puissance_armee <- 400; // P.A. d'un proprio de chateau pour que le FP soit satisfait.
	
	// SEIGNEURS //
	
	int nombre_seigneurs_objectif <- 200;
	int nombre_grands_seigneurs <- 2;
	int nombre_petits_seigneurs <- 18;
	
	int puissance_grand_seigneur1 <- 5;
	int puissance_grand_seigneur2 <- 5;
	
	float proba_collecter_loyer <- 0.1;
	
	float proba_creation_ZP_banaux <- 0.05;
	float proba_creation_ZP_basseMoyenneJustice <- 0.05;

	
	// ZONES_PRELEVEMENT //
	
	int rayon_min_PS <- 1000;
	int rayon_max_PS <- 5000;
	float min_fourchette_loyers_PS <- 0.05;
	float max_fourchette_loyers_PS <- 0.25;
	
	float proba_don_partie_ZP <- 0.33;
	
	// CHATEAUX //
	
	int apparition_chateaux <- 960;
	
	int seuil_attractivite_chateau <- 3000;
	
	float proba_creer_chateau_GS <- 0.5;
	float proba_chateau_agregat <- 0.5; // FIXME : A appliquer aussi aux PS
	float proba_don_chateau_GS <- 0.50; //TODO : update doc
	float proba_creer_chateau_PS <- 1.0;
	
	float proba_gain_droits_hauteJustice_chateau <- 0.1;
	float proba_gain_droits_banaux_chateau <- 0.1;
	float proba_gain_droits_basseMoyenneJustice_chateau <- 0.1;


	// EGLISES //
	
	int nombre_eglises <- 150 ;
	int nb_eglises_paroissiales <- 50 ;
	float proba_gain_droits_paroissiaux <- 0.05;
	int nb_max_paroissiens <- 40;
	int nb_min_paroissiens <- 10;


	
	////////////
	/// TEMP ///
	////////////
	
	int Annee <- debut_simulation update: Annee + duree_step;
	const world_bounds type: geometry <- square(100 #km) translated_by {50 #km , 50 #km};
	
	const shape type: geometry <- envelope(world_bounds) ;
	const worldextent type: geometry <- envelope(world_bounds) ;
	const reduced_worldextent type: geometry<- worldextent scaled_by 0.99;
	
	const nb_seigneurs_a_creer_total type: int <- nombre_seigneurs_objectif - (nombre_grands_seigneurs + nombre_petits_seigneurs);
	const nb_moyen_petits_seigneurs_par_tour type: int <- round(nb_seigneurs_a_creer_total / ((fin_simulation - debut_simulation) / duree_step));
	
	/////////////
	// OUTPUTS //
	/////////////
	
	
	// FP //
	int nb_demenagement_local update: 0; // le update remet à 0 au début de chaque nouveau step
	int nb_demenagement_lointain update: 0;
	
	// CHATEAUX //
	int nb_chateaux ;
	
	action update_besoin_protection{
		switch Annee {
			match 960 {set besoin_protection <- 0.2;}
			match 980  {set besoin_protection <- 0.4;}
			match 1000 {set besoin_protection <- 0.6;}
			match 1020  {set besoin_protection <- 0.8;}
			match 1040  {set besoin_protection <- 1.0;}
			default {}
		}
		
	}
	
	
}