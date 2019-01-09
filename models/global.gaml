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
	
	
	///////////////
	// TECHNIQUE //
	///////////////
	
	bool benchmark <- false;
	bool save_outputs <- false;
	string prefix_output <- "6";
	string output_folder_path <- "/home/robin/SimFeodal/outputs/";
	int debut_simulation <- 800;
	int fin_simulation <- 1160;
	int duree_step <- 20;
	string experimentType <- "batch";
	bool summarised_outputs <- false;
	string sensibility_parameter <- "";
	string sensibility_value <- "" ;
	
	////////////
	// INPUTS //
	////////////
	
	// ESPACE DU MODELE //
	int taille_cote_monde <- 80 ; // km
	// FOYERS PAYSANS //
	int init_nb_total_fp <- 4000 ; // XXX : anciennement : nombre_foyers_paysans : Renommé dans BDD
	// AGREGATS //
	int init_nb_agglos <- 4 ; // XXX : anciennement : nombre_agglos_antiques : Renommé dans BDD
	int init_nb_fp_agglo <- 30; // XXX : anciennement en dur : Ajouté dans BDD
	int init_nb_villages <- 20 ; // XXX : anciennement : nombre_villages : Renommé dans BDD
	int init_nb_fp_village <- 10; // XXX : anciennement : nombre_FP_village : Renommé dans BDD
	// SEIGNEURS //
	int init_nb_gs <- 2; // XXX : anciennement : nombre_grands_seigneurs : Renommé dans BDD
	float puissance_grand_seigneur1 <- 0.5; // Anciennement 5 : FIXME : A transformer dans BDD
	float puissance_grand_seigneur2 <- 0.5; // Anciennement 5 : FIXME : A transformer dans BDD
	int init_nb_ps <- 18; // XXX : anciennement : nombre_petits_seigneurs : Renommé dans BDD
	// EGLISES //
	int init_nb_eglises <- 150 ; // XXX : anciennement : nombre_eglises : Renommé dans BDD
	int init_nb_eglises_paroissiales <- 50 ; // XXX : anciennement : nb_eglises_paroissiales : Renommé dans BDD
		
	//////////////
	// CONTEXTE //
	//////////////
	
	// FOYERS PAYSANS //
	float croissance_demo <- 0.0; // FIXME : avant v6 : taux_augmentation_FP / A renommer dans BDD
	float taux_renouvellement_fp <- 0.05 ; // FIXME : avant v6 : taux_renouvellement / A renommer dans BDD
	float proba_fp_dependant <- 0.2; // FIXME : avant v6 : proba_FP_dependants / A renommer dans BDD
	map<int,float> besoin_protection_fp <- [800::0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0]; // FIXME: avant v6 : besoin_protection / A renommer + retyper dans BDD
	// AGREGATS //
	float puissance_communautes <- 0.25;
	int coef_redevances <- 15;
	// SEIGNEURS //
	int objectif_nombre_seigneurs <- 200; // FIXME : avant v6 : nombre_seigneurs_objectif / A renommer dans BDD
	map<int,float> proba_gain_haute_justice_gs <- [800::0,900::0.1,1000::1.0]; // TODO : Inactif : ajouter dans modèle + Ajouter aux outputs + SimEDB + RENOMMER POUR COLLER ? / J'en suis encore là !
	int debut_cession_droits_seigneurs <- 900 ; // FIXME : Nouveau paramètre, A ajouter dans BDD
	int debut_garde_chateaux_seigneurs <- 960 ; // FIXME : Nouveau paramètre, A ajouter dans BDD
	// CHATEAUX //
	int debut_construction_chateaux <- 940; // FIXME : avant v6 : apparition_chateaux / A renommer dans BDD	
	int nb_chateaux_potentiels_gs <- 2; // FIXME : avant v6 : nb_chateaux_potentiels_GS
	map<int,bool> periode_promotion_chateaux <- [800::false,940::true,1060::false]; // FIXME : Nouveau paramètre, A ajouter dans BDD
	
	///////////////
	// MECANISME //
	///////////////
	
	// FOYERS PAYSANS //
	map<int,int> dist_min_eglise <- [800::5000,960::3000,1060::1500]; // FIXME : Nouveau paramètre en v6 : vallait [800::5000,960::3000,1060::1500] avant
	map<int,int> dist_max_eglise <- [800::25000,960::10000,1060::5000]; // FIXME : Nouveau paramètre en v6 : vallait [800::25000,960::10000,1060::5000] avant
	int dist_min_chateau <- 1500; // FIXME : Nouveau paramètre en v6 : vallait 1500 avant
	int dist_max_chateau <- 5000; // FIXME : Nouveau paramètre en v6 : vallait 5000 avant
	float min_s_distance_chateau <- 0.01; // FIXME : Nouveau paramètre en v6 : vallait 0.0 avant
	map<int,int> rayon_migration_locale_fp <- [800::2500]; // TODO : avant v6 : seuils_max_dem_local
	float freq_migration_lointaine <- 0.2; // // TODO : avant v6 : proba_ponderee_deplacement_lointain
	// AGREGATS //
	int nb_min_fp_agregat <- 5; // TODO : avant v6 : nombre_FP_agregat
	float proba_apparition_communaute <- 0.2;
	int apparition_communautes <- 800;
	int distance_detection_agregat <- 100; // avant v6 : distance_detection_agregats
	int distance_fusion_agregat <- 100; // FIXME : Nouveau paramètre en v6 : vallait 100 avant
	// SEIGNEURS 
	float proba_collecter_loyer <- 0.1;
	float proba_creation_zp_banaux <- 0.05; // TODO : avant v6 : proba_creation_ZP_banaux
	float proba_creation_zp_basse_justice <- 0.05; // TODO : avant v6 : proba_creation_ZP_basseMoyenneJustice
	int rayon_min_zp_ps <- 1000; // TODO : avant v6 : rayon_min_PS
	int rayon_max_zp_ps <- 5000; // TODO : avant v6 : rayon_max_PS
	float min_taux_prelevement_zp_ps <- 0.05; // TODO : avant v6 : min_fourchette_loyers_PS
	float max_taux_prelevement_zp_ps <- 0.25; // TODO : avant v6 : max_fourchette_loyers_PS
	float proba_cession_droits_zp <- 0.33; // TODO : avant v6 : proba_don_partie_ZP
	int rayon_cession_droits_ps <- 3000; // TODO : nouveau paramètre en v6 : vallait 3000 avant
	float proba_don_chateau_gs <- 0.50; // TODO : avant v6 : proba_don_chateau_GS
	float proba_gain_haute_justice_chateau_ps <- 0.1; // TODO : avant v6 : proba_gain_droits_hauteJustice_chateau
	float proba_gain_droits_banaux_chateau <- 0.1;
	float proba_gain_droits_basse_justice_chateau <- 0.1; // TODO : avant v6 : proba_gain_droits_basseMoyenneJustice_chateau
	float droits_haute_justice_zp <- 1.0; // TODO : nouveau paramètre en v6 : vallait 1 avant
	float droits_haute_justice_zp_suzerain <- 1.25; // TODO : nouveau paramètre en v6 : vallait 1.25 avant
	float droits_basse_justice_zp <- 0.25; // TODO : nouveau paramètre en v6 : vallait 0.25 avant
	float droits_basse_justice_zp_suzerain <- 0.35; // TODO : nouveau paramètre en v6 : vallait 0.35 avant
	float droits_banaux_zp <- 0.25; // TODO : nouveau paramètre en v6 : vallait 0.25 avant
	float droits_banaux_zp_suzerain <- 0.35; // TODO : nouveau paramètre en v6 : vallait 0.35 avant
	float droits_fonciers_zp <- 1.0; // TODO : nouveau paramètre en v6 : vallait 1 avant
	// CHATEAUX
	int min_rayon_zp_chateau <- 2000; // TODO : nouveau paramètre en v6, vallait 2000 avant
	int max_rayon_zp_chateau <- 10000; // TODO : nouveau paramètre en v6, vallait 10000 avant
	int dist_min_entre_chateaux_ps <- 3000; // TODO : nouveau paramètre en v6, vallait 3000 avant
	int dist_min_entre_chateaux_gs <- 5000;  // TODO : nouveau paramètre en v6, vallait 5000 avant
	float proba_chateau_gs_agregat <- 0.5 ; // TODO : avant v6 : proba_chateau_agregat
	float proba_promotion_chateau_pole <- 0.8; // TODO : avant v6 : proba_promotion_groschateau_multipole
	float proba_promotion_chateau_isole <- 0.3; // TODO : avant v6 : proba_promotion_groschateau_autre
	// EGLISES PAROISSIALES
	int nb_min_paroissiens <- 10; // FIXME : param peu utile : préfiltrage des agrégats pour lesquels ont étudie la création d'une paroisse
	int seuil_creation_paroisse <- 600;
	int nb_paroissiens_mecontents_necessaires <- 20;
	// POLES
	float attractivite_petit_chateau <- 0.15; // TODO : avant v6 : attrac_PC
	float attractivite_gros_chateau <- 0.25; // TODO : avant v6 : attrac_GC
	float attractivite_1_eglise <- 0.15; // TODO : avant v6 : attrac_1_eglises
	float attractivite_2_eglise <- 0.25; // TODO : avant v6 : attrac_2_eglises
	float attractivite_3_eglise <- 0.50; // TODO : avant v6 : attrac_3_eglises
	float attractivite_4_eglise <- 0.60; // TODO : avant v6 : attrac_4_eglises
	float attractivite_communaute <- 0.15; // TODO : avant v6 : attrac_communautes
	// ARRET LÀ //
	
	
	
	// VARIABLES DE  MECANISME //
	
	
	////////////////////////
	// VARIABLE GLOBABLES //
	////////////////////////
	
	int annee <- debut_simulation; 
	geometry world_bounds <- square(taille_cote_monde #km) translated_by {taille_cote_monde #km/2 , taille_cote_monde #km/2 };
	
	geometry shape <- envelope(world_bounds) ;
	geometry worldextent <- envelope(world_bounds) ;
	geometry reduced_worldextent <- worldextent - 1 #km; // On retranche 1km de chaque coté du monde
	
	int nb_seigneurs_a_creer_total <- objectif_nombre_seigneurs - (init_nb_gs + init_nb_ps);
	int nb_moyen_petits_seigneurs_par_tour <- round(nb_seigneurs_a_creer_total / ((fin_simulation - debut_simulation) / duree_step));
	
	// Variables evoluant dans le temps
	float besoin_protection_fp_actuel <- 0.0;
	float proba_gain_haute_justice_gs_actuel <- 0.0;
	bool chateaux_promouvables <- false;
	int dist_min_eglise_actuel <- 0;
	int dist_max_eglise_actuel <- 0;
	int rayon_migration_locale_fp_actuel <- 0;

	/////////////
	// OUTPUTS //
	/////////////
	float distance_eglises_paroissiales <- 0.0;
	float distance_eglises <- 0.0;
	float prop_FP_isoles <- 0.0;
	float ratio_charge_fiscale <- 0.0;
	float charge_fiscale <- 0.0;
	float dist_ppv_agregat <- 0.0;
	list<int> Chateaux_chatelains <- [];
	list<int> reseaux_chateaux <- [];
	// FP //
	int nb_demenagement_local update: 0; // le update remet à 0 au début de chaque nouveau step
	int nb_demenagement_lointain update: 0;
	// CHATEAUX //
	int nb_chateaux ;	
	// FOYERS_PAYSANS //

	bool serfs_mobiles <- true; // FIXME : Toujours true depuis la v5
	

	
	action update_variables_temporelles {
		
		set annee <- annee + duree_step;
		
		if ((besoin_protection_fp at annee) is float){
			set besoin_protection_fp_actuel <- besoin_protection_fp at annee;
		}
		
		if ((proba_gain_haute_justice_gs at annee) is float) {
			set proba_gain_haute_justice_gs_actuel <- proba_gain_haute_justice_gs at annee;
		}
		
		if ((rayon_migration_locale_fp at annee) is float){
			set rayon_migration_locale_fp_actuel <- rayon_migration_locale_fp at annee;
		}
		
		if ((periode_promotion_chateaux at annee) is bool) {
			set chateaux_promouvables <- periode_promotion_chateaux at annee;
		}
		
		if ((dist_min_eglise at annee) is int){
			set dist_min_eglise_actuel <- dist_min_eglise at annee;
		}
		
		if ((dist_max_eglise at annee) is int){
			set dist_max_eglise_actuel <- dist_max_eglise at annee;
		}
	}
	

	action update_summarised_outputs {
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
		
		set prop_FP_isoles <- Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans);
		set charge_fiscale <- mean(Foyers_Paysans collect float(each.nb_preleveurs));
	}
}
