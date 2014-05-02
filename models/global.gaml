/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */
model t8

import "init.gaml"
import "T8.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Agglomerations.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"

global {
	int nombre_foyers_paysans <- 1000 ;
	int nombre_agglos_antiques <- 3 ;
	int nombre_villages <- 20 ;
	int nombre_foyers_villages <- 10 ;
	int nombre_chateaux <- 20 ;
	int nombre_eglises <- 600 ;
	float Seuil_satisfaction <- 0.8 ;
	float taux_renouvellement <- 0.05 ;
	
	file shape_file_bounds <- file("../includes/Emprise_territoire.shp");

	
	geometry shape <- envelope(shape_file_bounds) ;
	geometry worldextent <- envelope(shape_file_bounds) ;
	geometry reduced_worldextent <- worldextent scaled_by 0.99;
	
    }