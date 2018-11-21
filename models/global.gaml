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


global torus: false{
	////////////
	// INPUTS //
	////////////
	
	// GLOBAL //
	
//	float myseed <- seed;
	
	bool benchmark <- false;
	bool save_outputs <- false;
	int debut_simulation <- 800;
	int fin_simulation <- 1160;
	int duree_step <- 20;
	float besoin_protection <- 0.0;
	string experimentType <- "batch";
	bool summarised_outputs <- false;
	string sensibility_parameter <- "";
	string sensibility_value <- "" ;
	int taille_cote_monde <- 80 ; // km
	
	// AGREGATS //
	
	int distance_detection_agregats <- 100;
	int nombre_FP_agregat <- 5;
	int nombre_agglos_antiques <- 4 ;
	int nombre_villages <- 20 ;
	int nombre_FP_village <- 10;
	float puissance_communautes <- 0.25;
	int apparition_communautes <- 800;
	float proba_apparition_communaute <- 0.2;
	
	// FOYERS_PAYSANS //
	
	int nombre_foyers_paysans <- 4000 ;
	float taux_renouvellement <- 0.05 ;
	float taux_augmentation_FP <- 0.0;
	float taux_mobilite <- 0.8;
	int distance_max_dem_local <- 4000;
	int seuil_puissance_armee <- 400; // P.A. d'un proprio de chateau pour que le FP soit satisfait.
	list<int> seuils_distance_max_dem_local <- [2500, 2500, 2500];
	float proba_ponderee_deplacement_lointain <- 0.2;
	int coef_redevances <- 15;
	bool serfs_mobiles <- true;
	float min_S_distance_chateau <- 0.0; // Nouveau paramètre pour le calcul de s_protection
	
	 
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
	int nb_chateaux_potentiels_GS <- 2;
	
	int seuil_attractivite_chateau <- 3000;
	
	float proba_creer_chateau_GS <- 0.5;
	float proba_chateau_agregat <- 0.5; // FIXME : A appliquer aussi aux PS
	float proba_don_chateau_GS <- 0.50; //TODO : update doc
	float proba_creer_chateau_PS <- 1.0;
	
	float proba_gain_droits_hauteJustice_chateau <- 0.1;
	float proba_gain_droits_banaux_chateau <- 0.1;
	float proba_gain_droits_basseMoyenneJustice_chateau <- 0.1;
	
	float proba_promotion_groschateau_multipole <- 0.8;
	float proba_promotion_groschateau_autre <- 0.3;
	int puissance_necessaire_creation_chateau_GS <- 1000;
	int puissance_necessaire_creation_chateau_PS <- 0;


	// EGLISES //
	
	int nombre_eglises <- 150 ;
	int nb_eglises_paroissiales <- 50 ;
	int nb_max_paroissiens <- 40;
	int nb_min_paroissiens <- 10;
	int seuil_creation_paroisse <- 600;
	int nb_paroissiens_mecontents_necessaires <- 20;
	
	// POLES //
	float attrac_0_eglises <- 0.0;
	float attrac_1_eglises <- 0.15;
	float attrac_2_eglises <- 0.25;
	float attrac_3_eglises <- 0.5;
	float attrac_4_eglises <- 0.6;
	float attrac_GC <- 0.25;
	float attrac_PC <- 0.15;
	float attrac_communautes <- 0.15;
	
	
	////////////
	/// TEMP ///
	////////////
	

	int Annee <- debut_simulation update: Annee + duree_step;
	geometry world_bounds <- square(taille_cote_monde #km) translated_by {taille_cote_monde #km/2 , taille_cote_monde #km/2 };
	
	geometry shape <- envelope(world_bounds) ;
	geometry worldextent <- envelope(world_bounds) ;
	geometry reduced_worldextent <- worldextent - 1 #km; // On retranche 1km de chaque coté du monde
	
	int nb_seigneurs_a_creer_total <- nombre_seigneurs_objectif - (nombre_grands_seigneurs + nombre_petits_seigneurs);
	int nb_moyen_petits_seigneurs_par_tour <- round(nb_seigneurs_a_creer_total / ((fin_simulation - debut_simulation) / duree_step));
	
	/////////////
	// OUTPUTS //
	/////////////
	float distance_eglises <- 0.0; // Moyenne des distances au plus proche voisin
	float distance_eglises_paroissiales <- 0.0;
	float prop_FP_isoles <- 0.0;
	float ratio_charge_fiscale <- 0.0;
	float charge_fiscale_debut <- 0.0;
	float charge_fiscale <- 0.0;
	float dist_ppv_agregat <- 0.0;
	list<int> Chateaux_chatelains <- [];
	list<int> reseaux_chateaux <- [];

	string prefix_output <- "global";
	string output_folder_path <- "/home/robin/SimFeodal/outputs/";
	
	// OpenMole outputs //
	int nb_agregats_om <- 0 ;
	int nb_chateaux_om <- 0 ;
	int nb_gros_chateaux_om <- 0 ;
	int nb_seigneurs_om <- 0 ;
	int nb_eglises_om <- 0 ;
	int nb_eglises_paroissiales_om <- 0 ;
	int distance_eglises_paroissiales_om <- 0 ;
	float proportion_fp_isoles_om <- 0.0 ;
	float augmentation_charge_fiscale_om <- 0.0 ;
		
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
	
	action update_distance_max_dem_local {
		if Annee < 900 {
			set distance_max_dem_local <- seuils_distance_max_dem_local[0];
		} else if (Annee >= 900 and Annee < 1000) {
			 set distance_max_dem_local <- seuils_distance_max_dem_local[1];
		} else  if (Annee >= 1000) {
			set distance_max_dem_local <- seuils_distance_max_dem_local[2];
		}
	}
	
	action update_output_indexes {
		float t <- machine_time;
		list<float> distances_pp_eglise <- [];
		ask Eglises {
			Eglises pp_eglise <- Eglises closest_to self;
			if (pp_eglise != nil){
			float distEglise <- self distance_to pp_eglise;
			distances_pp_eglise <+ distEglise;
			}
		}
		set distance_eglises <- mean(distances_pp_eglise);
		if (benchmark){write 'update_output_indexes_1 : ' + string(machine_time - t);}
		set t <- machine_time;
		list<float> distances_pp_paroisses <- [];
		list<Eglises> eglises_paroissiales <- Eglises where (each.eglise_paroissiale);
		ask eglises_paroissiales{
			Eglises pp_eglise <- (eglises_paroissiales - self) closest_to self;
			if (pp_eglise != nil){
			float distEglise <- self distance_to pp_eglise;
			distances_pp_paroisses <+ distEglise;
			}
		}
		
		set distance_eglises_paroissiales <- mean(distances_pp_paroisses);
		if (benchmark){write 'update_output_indexes_2 : ' + string(machine_time - t);}
		set t <- machine_time;
		
		set prop_FP_isoles <- Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans);
		set charge_fiscale <- mean(Foyers_Paysans collect float(each.nb_preleveurs));
		
		list<Foyers_Paysans> FP_Agregat <- Foyers_Paysans where (each.monAgregat != nil);
		if (benchmark){write 'update_output_indexes_3 : ' + string(machine_time - t);}
//		float t <- machine_time;
//		list<float> liste_ppv_agregats <- [];
//		ask FP_Agregat {
//			list<Foyers_Paysans> mesFP <- (Foyers_Paysans where (each.monAgregat = self.monAgregat)) - self;
//			if (!empty(mesFP)){
//				float myDist <- self distance_to (mesFP with_min_of (each distance_to self));
//				liste_ppv_agregats <+ myDist;
//			}
//		}
//		set dist_ppv_agregat <- mean(liste_ppv_agregats);
//		if (benchmark){write 'update_output_indexes_4 : ' + string(machine_time - t);}
		set t <- machine_time;
		list<int> nbChateaux_chatelains <- []; 
		ask Seigneurs where (each.type != "Petit Seigneur"){
			list<Chateaux> mesChateaux <- Chateaux where ( (each.proprietaire = self) or (each.gardien = self) );
			set nbChateaux_chatelains <- nbChateaux_chatelains +  length(mesChateaux);	
		}
		set Chateaux_chatelains <- nbChateaux_chatelains;
		if (benchmark){write 'update_output_indexes_5 : ' + string(machine_time - t);}
		set t <- machine_time;
		list<int> nbChateaux_reseau <- [];
		ask Seigneurs where (each.type != "Petit Seigneur"){
			list<Chateaux> mesChateaux <- Chateaux where (each.proprietaire = self);
			set nbChateaux_reseau <- nbChateaux_reseau +  length(mesChateaux);	
		}
		set reseaux_chateaux <- nbChateaux_reseau;
		if (benchmark){write 'update_output_indexes_6 : ' + string(machine_time - t);}
	}
}
