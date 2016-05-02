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
	
	float myseed <- seed;
	
	bool benchmark <- false;
	bool save_outputs <- false;
	bool save_TMD <- false;
	int debut_simulation <- 800;
	int fin_simulation <- 1160;
	int duree_step <- 20;
	float besoin_protection <- 0.0;
	
	// AGREGATS //
	
	int distance_detection_agregats <- 100;
	int nombre_FP_agregat <- 5;
	int nombre_agglos_antiques <- 4 ;
	int nombre_villages <- 20 ;
	int nombre_foyers_villages_max <- 5 ;
	float puissance_communautes <- 0.25;
	int apparition_communautes <- 800;
	float proba_apparition_communaute <- 0.2;
	
	// FOYERS_PAYSANS //
	
	int nombre_foyers_paysans <- 4000 ;
	float taux_renouvellement <- 0.05 ;
	float taux_mobilite <- 0.8;
	int distance_max_dem_local <- 7000;
	int seuil_puissance_armee <- 400; // P.A. d'un proprio de chateau pour que le FP soit satisfait.
	bool deplacement_alternate <- false;
	
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
	
	float proba_promotion_groschateau_multipole <- 0.5;
	float proba_promotion_groschateau_autre <- 0.1;
	int puissance_necessaire_creation_chateau_GS <- 2000;
	int puissance_necessaire_creation_chateau_PS <- 2000;


	// EGLISES //
	
	int nombre_eglises <- 150 ;
	int nb_eglises_paroissiales <- 50 ;
	float proba_gain_droits_paroissiaux <- 0.05;
	int nb_max_paroissiens <- 40;
	int nb_min_paroissiens <- 10;
	int ratio_paroissiens_agregats <- 400;
	int nb_paroissiens_mecontents_necessaires <- 5;
	
	// POLES //
	float attrac_0_eglises <- 0.0;
	float attrac_1_eglises <- 0.17;
	float attrac_2_eglises <- 0.34;
	float attrac_3_eglises <- 0.51;
	float attrac_4_eglises <- 0.66;
	float attrac_GC <- 0.34;
	float attrac_PC <- 0.17;
	
	float attrac_communautes <- 0.0;
	
	bool chateaux_GS_alternate <- false;
	bool chateaux_PS_alternate <- false;
	bool puissance_armee_FP_alternate <- false;
	bool communautes_attractives <- false;
	bool agregats_alternate <- false;
	bool poles_alternate <- false;
	

	
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
	float distance_eglises <- 0.0; // Moyenne des distances au plus proche voisin
	float distance_eglises_paroissiales <- 0.0;
	float prop_FP_isoles <- 0.0;
	float ratio_charge_fiscale <- 0.0;
	float charge_fiscale_debut <- 0.0;
	float charge_fiscale <- 0.0;
	float dist_ppv_agregat <- 0.0;
	list<int> Chateaux_chatelains <- [];
	list<int> reseaux_chateaux <- [];
	
	
	string prefix_output <- nil;
	
	// FP //
	int nb_demenagement_local update: 0; // le update remet à 0 au début de chaque nouveau step
	int nb_demenagement_lointain update: 0;
	int nb_FP_sat_024 update: 0;
	int nb_FP_sat_2549 update: 0;
	int nb_FP_sat_5075 update: 0;
	int nb_FP_sat_75100 update: 0;
	int nbInInIntra update: 0;
	int nbInOutIntra update: 0;
	int nbOutInIntra update: 0;
	int nbOutOutIntra update: 0;
	
	int nbInInInter update: 0;
	int nbInOutInter update: 0;
	int nbOutInInter update: 0;
	int nbOutOutInter update: 0;
	
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
	
	action update_output_indexes {
		//list<Eglises> currParoisses <- Eglises where (each.eglise_paroissiale);
		//set distance_eglises <- mean(currParoisses collect (each distance_to (currParoisses closest_to self)));
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
		
		
		
		set prop_FP_isoles <- Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans);
		set charge_fiscale <- mean(Foyers_Paysans collect float(each.nb_preleveurs));
		
		list<Foyers_Paysans> FP_Agregat <- Foyers_Paysans where (each.monAgregat != nil);
		
		list<float> liste_ppv_agregats <- [];
		ask FP_Agregat {
			list<Foyers_Paysans> mesFP <- (Foyers_Paysans where (each.monAgregat = self.monAgregat)) - self;
			if (!empty(mesFP)){
				//write(mesFP);
				float myDist <- self distance_to (mesFP with_min_of (each distance_to self));
				liste_ppv_agregats <+ myDist;
			}
		}
		//write(max(liste_ppv_agregats));
		set dist_ppv_agregat <- mean(liste_ppv_agregats);
		//write(dist_ppv_agregat);
		
		list<int> nbChateaux_chatelains <- []; 
		ask Seigneurs where (each.type != "Petit Seigneur"){
			list<Chateaux> mesChateaux <- Chateaux where ( (each.proprietaire = self) or (each.gardien = self) );
			set nbChateaux_chatelains <- nbChateaux_chatelains +  length(mesChateaux);	
		}
		set Chateaux_chatelains <- nbChateaux_chatelains;
		
		list<int> nbChateaux_reseau <- [];
		ask Seigneurs where (each.type != "Petit Seigneur"){
			list<Chateaux> mesChateaux <- Chateaux where (each.proprietaire = self);
			set nbChateaux_reseau <- nbChateaux_reseau +  length(mesChateaux);	
		}
		set reseaux_chateaux <- nbChateaux_reseau;
		
		//write(mean(Agregats collect (each.shape.area)));

	}
	
	action update_outputs_fp {
	set nb_FP_sat_024 <- Foyers_Paysans count (each.Satisfaction < 0.25);
	set nb_FP_sat_2549 <- Foyers_Paysans count (each.Satisfaction >= 0.25 and each.Satisfaction < 0.5);
	set nb_FP_sat_5075 <- Foyers_Paysans count (each.Satisfaction >= 0.5 and each.Satisfaction <= 0.75);
	set nb_FP_sat_75100 <- Foyers_Paysans count (each.Satisfaction > 0.75);
	
	set nbInInIntra <-  Foyers_Paysans count (each.typeIntra = "InIn");
	set nbInOutIntra <-  Foyers_Paysans count (each.typeIntra = "InOut");
	set nbOutInIntra <-  Foyers_Paysans count (each.typeIntra = "OutIn");
	set nbOutOutIntra <-  Foyers_Paysans count (each.typeIntra = "OutOut");
	
	set nbInInInter <-  Foyers_Paysans count (each.typeInter = "InIn");
	set nbInOutInter <-  Foyers_Paysans count (each.typeInter = "InOut");
	set nbOutInInter <-  Foyers_Paysans count (each.typeInter = "OutIn");
	set nbOutOutInter <-  Foyers_Paysans count (each.typeInter = "OutOut");
	}
	
	
	
}