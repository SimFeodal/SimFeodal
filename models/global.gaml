/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */
model t8

import "init.gaml"
import "T8.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"

import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"

global {
	int Annee <- 800;
	int nombre_foyers_paysans <- 1000 ;
	int nombre_agglos_antiques <- 3 ;
	int nombre_villages <- 20 ;
	int nombre_foyers_villages <- 10 ;
	int nombre_chateaux <- 0 ;
	int nombre_seigneurs <- 20;
	int nombre_eglises <- 150 ;
	float Seuil_satisfaction <- 0.8 ;
	float taux_renouvellement <- 0.05 ;
	float taux_mobilite <- 0.8;
	int nb_demenagement_local <- 0;
	int nb_demenagement_lointain <- 0;
	int nb_non_demenagement <- 0;
	float proba_devenir_seigneur <- 0.01;
	
	file shape_file_bounds <- file("../includes/Emprise_territoire.shp");

	
	geometry shape <- envelope(shape_file_bounds) ;
	geometry worldextent <- envelope(shape_file_bounds) ;
	geometry reduced_worldextent <- worldextent scaled_by 0.99;
	
	reflex upate_year {
		 set Annee <- ((cycle + 1)* 20) + 800;
	}
	
    reflex reset_globals {
		set nb_demenagement_local <- 0;
		set nb_demenagement_lointain <- 0;
		set nb_non_demenagement <- 0;
	}
}