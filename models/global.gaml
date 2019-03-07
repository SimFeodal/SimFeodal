/**
 *  T8
 *  Author: Robin
 *  Description: SimFeodal, v6.1 (avec mécanisme châteaux v3)
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
	int taille_cote_monde <- 80 ; // km
		// FOYERS PAYSANS //
	int init_nb_total_fp <- 4000; // XXX : anciennement : nombre_foyers_paysans : Renommé dans BDD
		// AGREGATS //
	int init_nb_agglos <- 4; // XXX : anciennement : nombre_agglos_antiques : Renommé dans BDD
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
	map<int,float> besoin_protection_fp <- [800::0.0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0]; // FIXME: avant v6 : besoin_protection / A renommer + retyper dans BDD
		// AGREGATS //
	map<int, float> puissance_communautes <- [800::0.2,1060::0.3,1100::0.4,1160::0.5]; // FIXME : était un float qui vallait 0.25
	float proba_institution_communaute <- 0.2;
		// SEIGNEURS //
	int objectif_nombre_seigneurs <- 200; // FIXME : avant v6 : nombre_seigneurs_objectif / A renommer dans BDD
	map<int,float> proba_gain_haute_justice_gs <- [800::0.0,900::0.2,1000::1.0]; // TODO : Inactif : ajouter dans modèle + Ajouter aux outputs + SimEDB + RENOMMER POUR COLLER ? / J'en suis encore là !
	map<int,float> proba_gain_haute_justice_chateau_ps <- [800::0.0, 1000::0.2]; // TODO : avant v6 : proba_gain_droits_hauteJustice_chateau, vallait 0.1
	int debut_cession_droits_seigneurs <- 880 ; // FIXME : Nouveau paramètre, A ajouter dans BDD
	int debut_garde_chateaux_seigneurs <- 960 ; // FIXME : Nouveau paramètre, A ajouter dans BDD
		// CHATEAUX //
	int debut_construction_chateaux <- 940; // FIXME : avant v6 : apparition_chateaux / A renommer dans BDD	
	map<int,bool> periode_promotion_chateaux <- [800::false,940::true,1060::false]; // FIXME : Nouveau paramètre, A ajouter dans BDD
	
	///////////////
	// MECANISME //
	///////////////
		// FOYERS PAYSANS //
	map<int,int> dist_min_eglise <- [800::5000,960::3000,1060::1500]; // FIXME : Nouveau paramètre en v6 : vallait [800::5000,960::3000,1060::1500] avant
	map<int,int> dist_max_eglise <- [800::25000,960::10000,1060::5000]; // FIXME : Nouveau paramètre en v6 : vallait [800::25000,960::10000,1060::5000] avant
	int dist_min_chateau <- 1500; // FIXME : Nouveau paramètre en v6 : vallait 1500 avant
	int dist_max_chateau <- 5000; // FIXME : Nouveau paramètre en v6 : vallait 5000 avant
	map<int,int> rayon_migration_locale_fp <- [800::2500]; // TODO : avant v6 : seuils_max_dem_local
	float prop_migration_lointaine_fp <- 0.2; // // TODO : avant v6 : proba_ponderee_deplacement_lointain
		// AGREGATS //
	int nb_min_fp_agregat <- 5; // TODO : avant v6 : nombre_FP_agregat
	int distance_detection_agregat <- 100; // avant v6 : distance_detection_agregats
		// SEIGNEURS //
	int nb_max_chateaux_par_tour_gs <- 2; // FIXME : avant v6 : nb_chateaux_potentiels_GS, puis nb_chateaux_potentiels_gs, vallait 2
	int nb_max_chateaux_par_tour_ps <- 1; // FIXME : Nouveau paramètre en v6, vallait 1 avant, à ajouter dans BDD
	float proba_collecter_loyer_ps <- 0.1; // TODO : Peut-être à renommer
	float proba_creation_zp_autres_droits_ps <- 0.15; // TODO : avant v6 : proba_creation_ZP_banaux : vallait 5% (mais + basse et moyenne justice qui vallait aussi 5%)
	int rayon_min_zp_ps <- 1000; // TODO : avant v6 : rayon_min_PS
	int rayon_max_zp_ps <- 5000; // TODO : avant v6 : rayon_max_PS
	float min_taux_prelevement_zp_ps <- 0.05; // TODO : avant v6 : min_fourchette_loyers_PS
	float max_taux_prelevement_zp_ps <- 0.25; // TODO : avant v6 : max_fourchette_loyers_PS
	float taux_prelevement_zp_chateau <- 1.0; // TODO : nouveau paramètre en v6.1
	float proba_cession_droits_zp <- 0.33; // TODO : avant v6 : proba_don_partie_ZP
	int rayon_cession_locale_droits_ps <- 5000; // TODO : nouveau paramètre en v6 : vallait 3000 avant // Changement de nom en 6.1 : rayon_cession_droits_ps vallait 3000
	float proba_cession_locale <- 0.8; // FIXME : nouveau paramètre en v6.1, correspondant à un nouveau mécanisme
	float proba_don_chateau <- 0.50; // TODO : avant v6 : proba_don_chateau_GS, puis proba_don_chateau_gs
		// CHATEAUX
	int rayon_min_zp_chateau <- 2000; // TODO : nouveau paramètre en v6, vallait 2000 avant
	int rayon_max_zp_chateau <- 15000; // TODO : nouveau paramètre en v6, vallait 10000 avant // FIXME; changé en v6.1 : vallait 10000 avant
	int dist_min_entre_chateaux <- 3000; // TODO : nouveau paramètre en v6, vallait 3000 avant // FIXME : Nouveau paramètre en v6.1 : confondu entre gs et ps
	float proba_chateau_gs_agregat <- 0.5 ; // TODO : avant v6 : proba_chateau_agregat
	float proba_promotion_chateau_pole <- 0.8; // TODO : avant v6 : proba_promotion_groschateau_multipole
	float proba_promotion_chateau_isole <- 0.3; // TODO : avant v6 : proba_promotion_groschateau_autre
		// EGLISES PAROISSIALES
	int seuil_creation_paroisse <- 600;
	int nb_requis_paroissiens_insatisfaits <- 20;
		// POLES
	float attractivite_petit_chateau <- 0.15; // TODO : avant v6 : attrac_PC
	float attractivite_gros_chateau <- 0.25; // TODO : avant v6 : attrac_GC
	float attractivite_1_eglise <- 0.15; // TODO : avant v6 : attrac_1_eglises
	float attractivite_2_eglise <- 0.25; // TODO : avant v6 : attrac_2_eglises
	float attractivite_3_eglise <- 0.50; // TODO : avant v6 : attrac_3_eglises
	float attractivite_4_eglise <- 0.60; // TODO : avant v6 : attrac_4_eglises
	float attractivite_communaute <- 0.15; // TODO : avant v6 : attrac_communautes


	//////////////////////////
	// PARAMETRES TECHNIQUE //
	//////////////////////////
		// Foyers Paysans //
	int coef_redevances <- 15;
	float min_s_distance_chateau <- 0.01; // FIXME : Nouveau paramètre en v6 : vallait 0.0 avant
		// Agrégats //
	int distance_fusion_agregat <- 100; // FIXME : Nouveau paramètre en v6 : vallait 100 avant
		// Seigneurs //
	float droits_haute_justice_zp <- 2.0; // TODO : nouveau paramètre en v6 : vallait 1 avant
	float droits_haute_justice_zp_cession <- 2.5; // TODO : nouveau paramètre en v6 : vallait 1.25 avant
	float droits_fonciers_zp <- 1.0; // TODO : nouveau paramètre en v6 : vallait 1 avant
	float droits_fonciers_zp_cession <- 1.25; // Nouveau paramètre en v6.1 : vallait 0 avant
	float autres_droits_zp <- 0.25; // TODO : nouveau paramètre en v6 : vallait 0.25 avant
	float autres_droits_zp_cession <- 0.35; // TODO : nouveau paramètre en v6 : vallait 0.35 avant
	
	
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
	int rayon_migration_locale_fp_actuel;
	float puissance_communautes_actuel;

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
		// FP //
	int nb_demenagement_local update: 0; // le update remet à 0 au début de chaque nouveau step
	int nb_demenagement_lointain update: 0;
		// CHATEAUX //
	int nb_chateaux ;	
		// FOYERS_PAYSANS //
	
	geometry espace_dispo_chateaux <- nil;
	list<Agregats> agregats_loins_chateaux <- nil;
	int somme_puissance;
	

	
	action update_variables_temporelles {
		set besoin_protection_fp_actuel <- (besoin_protection_fp.keys contains annee) ? besoin_protection_fp at annee : besoin_protection_fp_actuel;
		set proba_gain_haute_justice_gs_actuel <- (proba_gain_haute_justice_gs.keys contains annee) ? proba_gain_haute_justice_gs at annee : proba_gain_haute_justice_gs_actuel;
		set proba_gain_haute_justice_chateau_ps_actuel <- (proba_gain_haute_justice_chateau_ps.keys contains annee) ? proba_gain_haute_justice_chateau_ps at annee : proba_gain_haute_justice_chateau_ps_actuel;
		set rayon_migration_locale_fp_actuel <- (rayon_migration_locale_fp.keys contains annee) ? rayon_migration_locale_fp at annee : rayon_migration_locale_fp_actuel;
		set chateaux_promouvables <- (periode_promotion_chateaux.keys contains annee) ? periode_promotion_chateaux at annee : chateaux_promouvables;
		set dist_min_eglise_actuel <- (dist_min_eglise.keys contains annee) ? dist_min_eglise at annee : dist_min_eglise_actuel;
		set dist_max_eglise_actuel <- (dist_max_eglise.keys contains annee) ? dist_max_eglise at annee : dist_max_eglise_actuel;
		set puissance_communautes_actuel <- (puissance_communautes.keys contains annee) ? puissance_communautes at annee : puissance_communautes_actuel;
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
