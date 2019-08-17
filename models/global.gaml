/**
 *  SimFeodal
 *  Author: R. Cura, C. Tannier, S. Leturcq, E. Zadora-Rio
 *  Description: https://simfeodal.github.io/
 *  Repository : https://github.com/SimFeodal/SimFeodal
 *  Version : 6.5
 *  Run with : Gama 1.8 (git) (1.7.0.201906131338)
 */

model simfeodal

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
	float seed <- seed;
	bool save_outputs <- false;
	string prefix_output <- "6";
	string output_folder_path <- "/home/robin/SimFeodal/outputs/";
	int debut_simulation <- 800;
	int fin_simulation <- 1200;
	int duree_step <- 20;
	string experimentType <- "batch";
	bool summarised_outputs <- false;
	string sensibility_parameter <- "";
	string sensibility_value <- "" ;
	
	////////////
	// INPUTS //
	////////////
		// ESPACE DU MODELE //
	int taille_cote_monde <- 80; // km
		// FOYERS PAYSANS //
	int init_nb_total_fp <- 40000;
		// AGREGATS //
	int init_nb_agglos <- 8;
	int init_nb_fp_agglo <- 30;
	int init_nb_villages <- 20;
	int init_nb_fp_village <- 10;
		// SEIGNEURS //
	int init_nb_gs <- 2;
	float puissance_grand_seigneur1 <- 0.5;
	float puissance_grand_seigneur2 <- 0.5;
	int init_nb_ps <- 18;
		// EGLISES //
	int init_nb_eglises <- 150;
	int init_nb_eglises_paroissiales <- 50;
		
	//////////////
	// CONTEXTE //
	//////////////
		// FOYERS PAYSANS //
	float croissance_demo <- 0.0;
	float taux_renouvellement_fp <- 0.05;
	float proba_fp_dependant <- 0.2;
	map<int,float> besoin_protection_fp <- [800::0.0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0];
		// AGREGATS //
	map<int, float> puissance_communautes <- [800::0.2,1060::0.3,1100::0.4,1160::0.5];
	float proba_institution_communaute <- 0.2;
		// SEIGNEURS //
	int objectif_nombre_seigneurs <- 200;
	map<int,float> proba_gain_haute_justice_gs <- [800::0.0,900::0.2,1000::1.0];
	map<int,float> proba_gain_haute_justice_chateau_ps <- [800::0.0, 1000::0.2];
	int debut_cession_droits_seigneurs <- 880;
	int debut_garde_chateaux_seigneurs <- 960;
		// CHATEAUX //
	int debut_construction_chateaux <- 940;
	map<int,bool> periode_promotion_chateaux <- [800::false,940::true,1060::false];
	
	///////////////
	// MECANISME //
	///////////////
		// FOYERS PAYSANS //
	map<int,int> dist_min_eglise <- [800::5000,960::3000,1060::1500];
	map<int,int> dist_max_eglise <- [800::25000,960::10000,1060::5000]; 
	int dist_min_chateau <- 1500;
	int dist_max_chateau <- 5000;
	map<int,int> rayon_migration_locale_fp <- [800::2500];
	float prop_migration_lointaine_fp <- 0.2;
		// AGREGATS //
	int nb_min_fp_agregat <- 5;
	int distance_detection_agregat <- 100;
		// SEIGNEURS //
	float proba_construction_chateau_ps <- 0.5;
	float proba_collecter_foncier_ps <- 0.1;
	float proba_creation_zp_autres_droits_ps <- 0.15;
	int rayon_min_zp_ps <- 1000;
	int rayon_max_zp_ps <- 5000;
	float min_taux_prelevement_zp_ps <- 0.05;
	float max_taux_prelevement_zp_ps <- 0.25;
	float taux_prelevement_zp_chateau <- 1.0;
	float proba_cession_droits_zp <- 0.33;
	int rayon_voisinage_ps <- 5000;
	float proba_cession_locale <- 0.8;
	float proba_don_chateau <- 0.50;
		// CHATEAUX
	int rayon_min_zp_chateau <- 2000;
	int rayon_max_zp_chateau <- 15000;
	int dist_min_entre_chateaux <- 3000;
	float proba_chateau_agregat <- 0.5 ;
	float proba_promotion_chateau_pole <- 0.8;
		// EGLISES PAROISSIALES
	int ponderation_creation_paroisse_agregat <- 2000;
	int seuil_nb_paroissiens_insatisfaits <- 20;
		// POLES
	float attractivite_petit_chateau <- 0.15;
	float attractivite_gros_chateau <- 0.25;
	float attractivite_1_eglise <- 0.15;
	float attractivite_2_eglise <- 0.25;
	float attractivite_3_eglise <- 0.50;
	float attractivite_4_eglise <- 0.60;
	float attractivite_communaute <- 0.15;


	//////////////////////////
	// PARAMETRES TECHNIQUE //
	//////////////////////////
		// Foyers Paysans //
	int coef_redevances <- 15;
	float min_s_distance_chateau <- 0.01;
		// Agrégats //
	int distance_fusion_agregat <- 100;
		// Seigneurs //
	float droits_haute_justice_zp <- 2.0;
	float droits_haute_justice_zp_cession <- 2.5;
	float droits_fonciers_zp <- 1.0;
	float droits_fonciers_zp_cession <- 1.25;
	float autres_droits_zp <- 0.25;
	float autres_droits_zp_cession <- 0.35;
	int nb_tirages_chateaux_gs <- 3;
	int nb_tirages_chateaux_ps <- 1;

	// Nouveau

	
	
	
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
	float besoin_protection_fp_actuel;
	float proba_gain_haute_justice_gs_actuel;
	float proba_gain_haute_justice_chateau_ps_actuel;
	bool chateaux_promouvables;
	int dist_min_eglise_actuel;
	int dist_max_eglise_actuel;
	float puissance_communautes_actuel;
	int rayon_migration_locale_fp_actuel;

	/////////////
	// OUTPUTS //
	/////////////
	float distance_eglises_paroissiales <- 0.0;
	float distance_eglises <- 0.0;
	float prop_fp_isoles <- 0.0;
	float ratio_charge_fiscale <- 0.0;
	float charge_fiscale <- 0.0;
	float dist_ppv_agregat <- 0.0;
	list<int> Chateaux_chatelains <- [];
	list<int> reseaux_chateaux <- [];
	float charge_fiscale_debut <- 1.0;
	// FP //
	int nb_demenagement_local update: 0; // le update remet à 0 au début de chaque nouveau step
	int nb_demenagement_lointain update: 0;
	// CHATEAUX //
	int nb_chateaux ;

	
	geometry espace_dispo_chateaux <- nil;
	list<Agregats> agregats_loins_chateaux <- nil;
	

	
	action update_variables_temporelles {
		set besoin_protection_fp_actuel <- (besoin_protection_fp.keys contains annee) ? besoin_protection_fp at annee : besoin_protection_fp_actuel;
		set proba_gain_haute_justice_gs_actuel <- (proba_gain_haute_justice_gs.keys contains annee) ? proba_gain_haute_justice_gs at annee : proba_gain_haute_justice_gs_actuel;
		set proba_gain_haute_justice_chateau_ps_actuel <- (proba_gain_haute_justice_chateau_ps.keys contains annee) ? proba_gain_haute_justice_chateau_ps at annee : proba_gain_haute_justice_chateau_ps_actuel;
		set chateaux_promouvables <- (periode_promotion_chateaux.keys contains annee) ? periode_promotion_chateaux at annee : chateaux_promouvables;
		set dist_min_eglise_actuel <- (dist_min_eglise.keys contains annee) ? dist_min_eglise at annee : dist_min_eglise_actuel;
		set dist_max_eglise_actuel <- (dist_max_eglise.keys contains annee) ? dist_max_eglise at annee : dist_max_eglise_actuel;
		set puissance_communautes_actuel <- (puissance_communautes.keys contains annee) ? puissance_communautes at annee : puissance_communautes_actuel;
		set rayon_migration_locale_fp_actuel <- (rayon_migration_locale_fp.keys contains annee) ? rayon_migration_locale_fp at annee : rayon_migration_locale_fp_actuel;
	}
	

	action update_summarised_outputs {
		list<float> distances_pp_eglise <- [];
		ask Eglises {
			Eglises pp_eglise <- Eglises closest_to self;
			if (pp_eglise != nil){
			float distEglise <- self distance_to pp_eglise;
			distances_pp_eglise <+ distEglise;
			}
		}
		set distance_eglises <- mean(distances_pp_eglise);
		
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
		
		set prop_fp_isoles <- Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans);
		set charge_fiscale <- mean(Foyers_Paysans collect float(each.redevances_acquittees));
	}
}
