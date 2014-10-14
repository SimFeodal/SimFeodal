/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */
model t8

import "init.gaml"
import "GUI.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"

import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"

global {
	int Annee <- 800;
	int nombre_foyers_paysans <- 1000 ;
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
	float proba_don_chateau <- 0.33;
	float proba_creer_chateau <- 0.33;
	bool chatelain_cree_chateau <- false ;
	int nombre_grands_seigneurs <- 2;
	int nombre_petits_seigneurs <- 18;
	int debut_simulation <- 800;
	int fin_simulation <- 1160;
	float puissance_comm_agraire <- 0.5;
	int max_rayon_captation_petits_seigneurs <- 10000 ;
	int min_rayon_captation_petits_seigneurs <- 3000;
	int debut_besoin_protection <- 900;
	int nombre_seigneurs_objectif <- 200;
	int puissance_grand_seigneur1 <- 5;
	int puissance_grand_seigneur2 <- 5;
	
	float min_fourchette_loyers_PS_init <- 0.05;
	float max_fourchette_loyers_PS_init <- 0.15;
	float min_fourchette_loyers_PS_nouveau <- 0.0;
	float max_fourchette_loyers_PS_nouveau <- 0.10;
	float proba_collecter_loyer <- 0.1;
	
	int nb_moyen_petits_seigneurs_par_tour <- 10;
	
	file shape_file_bounds <- file("../includes/Emprise_territoire.shp");

	
	geometry shape <- envelope(shape_file_bounds) ;
	geometry worldextent <- envelope(shape_file_bounds) ;
	geometry reduced_worldextent <- worldextent scaled_by 0.99;
	
	reflex upate_year {
		 set Annee <- ((cycle + 1)* 20) + debut_simulation;
		 if ((Annee) >= fin_simulation) {
		 	ask world {
		 		do pause;
		 	}
		 }
	}
	
	reflex MaJ_suzerains_FP {
		// MAJ loyers
		ask Seigneurs where (each.type = "Chatelain"){
			list<Foyers_Paysans> sujets <- [];
			ask chateaux_controlles {
				sujets <- sujets + (Foyers_Paysans at_distance(20000));
			}
			ask sujets {
				set seigneur_loyer <- myself;
			}
		}
		ask Seigneurs where (each.type = "Petit Seigneur") {
			list<Foyers_Paysans> potentielsSujets <- Foyers_Paysans at_distance(rayon_captation);
			set potentielsSujets <- potentielsSujets where (each.seigneur_loyer = nil);
			if !empty(potentielsSujets) {
				ask round(1/3 * length(potentielsSujets)) among potentielsSujets {
					set seigneur_loyer <- myself;
				}
			}
		}
		ask Foyers_Paysans where (each.seigneur_loyer = nil){
			set seigneur_loyer <- one_of(Seigneurs where (each.type = "Grand Seigneur"));
		}
	}
	
    reflex reset_globals {
		set nb_demenagement_local <- 0;
		set nb_demenagement_lointain <- 0;
		set nb_non_demenagement <- 0;
	}
	
	init {
		int nb_seigneurs_a_creer <- nombre_seigneurs_objectif - (nombre_grands_seigneurs + nombre_petits_seigneurs);
		set nb_moyen_petits_seigneurs_par_tour <- round(nb_seigneurs_a_creer / ((fin_simulation - debut_simulation) / 20));
	}
	
	reflex creation_nouveaux_seigneurs {
			int variabilite_nb_seigneurs <- round(nb_moyen_petits_seigneurs_par_tour / 3);
			int nb_seigneurs_a_creer <- nb_moyen_petits_seigneurs_par_tour + variabilite_nb_seigneurs - rnd(variabilite_nb_seigneurs * 2);
			// Varie entre -1/3 et +1/3 autour de la moyenne
			create Seigneurs number: nb_seigneurs_a_creer {
			set type <- "Petit Seigneur";
			set initialement_present <- false;
			set taux_prelevement <- rnd(100) / 100;
			set location <- any_location_in(one_of(Agregats collect each.shape));
			set rayon_captation <- min_rayon_captation_petits_seigneurs + rnd(max_rayon_captation_petits_seigneurs - min_rayon_captation_petits_seigneurs);
			}
		}

}