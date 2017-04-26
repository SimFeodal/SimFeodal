/**
 *  T8
 *  Author: Robin
 *  Description: Les agglomérations sont des agents "persistants", mais dont on vérifie l'existence à chaque pas de temps.
 */

model t8

import "../init.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"

global {
    action update_agregats_alternate {
    	
    	// ******************************* //
    	// Detection des nouveaux agrégats //
    	// ******************************* //
    	
    	
    	// Clustering //
    	list<Eglises> eglises_paroissiales <- Eglises where (each.eglise_paroissiale);
    	list<list<agent>> agregats_detectes <- list<list<agent>>(simple_clustering_by_distance((Foyers_Paysans + Chateaux + eglises_paroissiales), 
    		distance_detection_agregats
    		)  where (length(each) >= nombre_FP_agregat));
    	list<list<agent>> agregats_debut <- agregats_detectes where (length(each of_species Foyers_Paysans) >= nombre_FP_agregat);
    	list<list<agent>> agregats_cibles <- agregats_debut;
    	
    	// Fusion //
    	
    	loop petitAgregat over: agregats_debut {
    		list<agent> thisAg <- petitAgregat;
    		list<Foyers_Paysans> thisFP <- thisAg of_species Foyers_Paysans;
			list<Eglises> thisEglisesParoissiales <- thisAg of_species Eglises;
			list<Chateaux> thisChateaux <- thisAg of_species Chateaux;
			list<point> thisPoints <- thisAg collect each.location;
			geometry thisPoly <- convex_hull(polygon(thisPoints));
    		geometry thisShape <- thisPoly + 100;
    		
    		loop agregat_cible over: (agregats_cibles){
    			if (thisAg != agregat_cible){
		    		list<agent> thoseAg <- agregat_cible;
		    		list<Foyers_Paysans> thoseFP <- thoseAg of_species Foyers_Paysans;
					list<Eglises> thoseEglisesParoissiales <- thoseAg of_species Eglises;
					list<Chateaux> thoseChateaux <- thoseAg of_species Chateaux;
					list<point> thosePoints <- thoseAg collect each.location;
					geometry thosePoly <- convex_hull(polygon(thosePoints));
	    			geometry thoseShape <- thosePoly + 100;
					
					
					if (thoseShape intersects thisShape){
						agregats_cibles >- thisAg;
						agregats_cibles >- thoseAg;
						agregats_cibles <+ (thisAg + thoseAg);
						break;
					}
    			}
    		}
    	}
    	
    	// Création des tmpAgregats //
	
		loop nouvelAgregat over: agregats_cibles {
			create tmpAgregats number: 1 {
				list<point> mesPoints <- nouvelAgregat collect each.location;				
				geometry monPoly <- convex_hull(polygon(mesPoints));
	    		set shape <- monPoly + 100;
	    		set mesAgents <- agents overlapping self;
	    		set mesFP <- mesAgents of_species Foyers_Paysans;
	    		set mesEglisesParoissiales <- mesAgents of_species Eglises;
	    		set mesChateaux <- mesAgents of_species Chateaux;
	    		
			}
		}
	
		// Desaffectation des FP //
		ask Foyers_Paysans {
		if (monAgregat != nil){
			set typeInter <- "In";
		} else {
			set typeInter <- "Out";
		}
		set monAgregat <- nil ;
		}
		
		
    	// ****************************************************** //
    	//  Detection des intersection anciens/nouveaux agrégats  //
    	// ****************************************************** //
		
		list<list<agent>> AgClusters <- list<list<agent>>(simple_clustering_by_distance((tmpAgregats + Agregats), 0));
		
		list<list<agent>> agregatsIntersectes <- AgClusters where (length(each) > 1);
		list<list<agent>> agregatsIsoles <- AgClusters where (length(each) = 1);
		list<tmpAgregats> nouveauxAgregats <- (agregatsIsoles accumulate each) of_species tmpAgregats;
		list<Agregats> agregatsDisparus <- (agregatsIsoles accumulate each) of_species Agregats;
		
		
		// Suppression des anciens sans intersection //
		ask agregatsDisparus {do die;}
		list<list<agent>> goodClusters <- [];
		
		loop currAg over: agregatsIntersectes {
			if (length(currAg of_species tmpAgregats) < 1){
				ask currAg {do die;}
			} else {
				goodClusters <+ currAg;
			}
		}
		
		
		
		// Création des nouveaux sans intersection //
		loop nouvelAgregat over: nouveauxAgregats {
			create Agregats number: 1{
				set shape <- nouvelAgregat.shape;
			}
		}
		
		// Passation des Communautés des anciens aux nouveaux //
		
		
		loop goodCluster over: goodClusters {
			list<Agregats> anciensAg <- goodCluster of_species Agregats;
			list<tmpAgregats> nouveauxAg <- goodCluster of_species tmpAgregats;
			
			Agregats predecesseurAg <- nil;
			
			if (length(nouveauxAg) > 1){
				Agregats AgGagnant <- nil;
				if (agregats_alternate2){
					//Fusion !
					list<Agregats> anciennes_comm <- anciensAg where (each.communaute);
					
					if (length(anciennes_comm) > 0){
						set AgGagnant <- anciennes_comm with_max_of (each.attractivite);
					} else {
						set AgGagnant <- anciensAg with_max_of (each.attractivite);
					}
					ask AgGagnant {
						set shape <- union((nouveauxAg where (!dead(each))) collect each.shape);
					}
				}

			} else if (length(anciensAg) = 1){
				set predecesseurAg <- one_of(anciensAg);
			} else if (anciensAg count (each.communaute) >= 1 ) {
				set predecesseurAg <- (anciensAg where each.communaute) with_max_of (each.attractivite);
			} else {
				set predecesseurAg <- anciensAg with_max_of (each.attractivite);
			}
			
			if (predecesseurAg != nil){
				ask predecesseurAg {
					set shape <- one_of(nouveauxAg).shape;
				}	
			}
				list<Agregats> cesAnciensAg <- anciensAg;
				loop ceNouvelAg over: nouveauxAg {
					if (length(cesAnciensAg) < 1){
						create Agregats number: 1 {
							set shape <- ceNouvelAg.shape;
						}
					} else {
						Agregats cetAncienAg <- one_of(cesAnciensAg);
						ask cetAncienAg{
							set shape <- ceNouvelAg.shape;
						}
						cesAnciensAg >- cetAncienAg;
					}
				}
		}
	
    	// ***************************** //
    	//  Suppression des tmpAgregats  //
    	// ***************************** //
    	
    	ask tmpAgregats {do die;}
		
		ask Agregats {
			set fp_agregat <- Foyers_Paysans overlapping self;
			set mesChateaux <- Chateaux overlapping self;
			set mesParoisses <- (Eglises where (each.eglise_paroissiale) overlapping self);
			Agregats thisAg <- self;
			ask fp_agregat {
				if (monAgregat != nil) {
					monAgregat.fp_agregat >- self;
				}
				set monAgregat <- thisAg;
				set typeInter <- typeInter + "In";
			}
			if (Annee >= apparition_communautes){do update_communaute;}
		}
		
    	ask Foyers_Paysans where (each.monAgregat = nil){	
    		set typeInter <- typeInter + "Out";
    	}
    	
    }
    
     action update_agregats_simplifie {
    	list<Eglises> eglises_paroissiales <- Eglises where (each.eglise_paroissiale);
    	list<list<agent>> agregats_detectes <- simple_clustering_by_distance((Foyers_Paysans + Chateaux + eglises_paroissiales), distance_detection_agregats);
    	list<list<agent>> agregats_corrects <- agregats_detectes where (length(each of_species Foyers_Paysans) >= nombre_FP_agregat);

 	   	loop nouveauxAgregats over: agregats_corrects {
			create tmpAgregats number: 1 {
				list<point> mesPoints <- nouveauxAgregats collect each.location;			
				geometry monPoly <- convex_hull(polygon(mesPoints));
	    		set shape <- monPoly + 100;
	    		set mesAgents <- agents overlapping self;
	    		set mesFP <- mesAgents of_species Foyers_Paysans;
	    		set mesEglisesParoissiales <- mesAgents of_species Eglises;
	    		set mesChateaux <- mesAgents of_species Chateaux;
	    		
			}
    	}

    			// Desaffectation des FP //
		ask Foyers_Paysans {
		if (monAgregat != nil){
			set typeInter <- "In";
		} else {
			set typeInter <- "Out";
		}
		set monAgregat <- nil ;
		}
		
		
		ask tmpAgregats {
			geometry myShape <- shape;
			Agregats thisOldAgregat <- nil;
			float thisGeomArea <- 0.0;
			loop ancienAgregat over: Agregats {
				if (ancienAgregat.shape intersects myShape){
					geometry thisUnion <- ancienAgregat.shape inter myShape;
					if (thisUnion.area > thisGeomArea) {
						thisOldAgregat <- ancienAgregat;
						thisGeomArea <- thisUnion.area;
					}
				}
			}
			if (thisOldAgregat != nil) {
				if (thisOldAgregat.communaute){
					CA <- true;
				}
			}
		}

		ask Agregats {
			do die;
		}
	
		ask tmpAgregats {
			geometry myShape <- shape;
			bool recreateCA <- CA;
			list<Eglises> cesParoisses <- mesEglisesParoissiales;
			create Agregats number: 1 {
				set communaute <- recreateCA;
				set shape <- myShape;
				set mesParoisses <- cesParoisses;
				list<Chateaux> chateaux_proches <- Chateaux at_distance 2000;
				geometry maGeom <- shape + 200;
				
				loop ceChateau over: chateaux_proches {
					if (ceChateau intersects maGeom) {
						self.mesChateaux <+ ceChateau; 
					}
				}
			set fp_agregat <- Foyers_Paysans overlapping self;	
			}
		}
    	// ***************************** //
    	//  Suppression des tmpAgregats  //
    	// ***************************** //
    	
    	ask tmpAgregats {do die;}
		
		ask Agregats {
			Agregats thisAg <- self;
			ask fp_agregat {
				if (monAgregat != nil) {
					monAgregat.fp_agregat >- self;
				}
				set monAgregat <- thisAg;
				set typeInter <- typeInter + "In";
			}
			if (Annee >= apparition_communautes){do update_communaute;}
		}
		
    	ask Foyers_Paysans where (each.monAgregat = nil){	
    		set typeInter <- typeInter + "Out";
    	}
     }
    
    action update_agregats_fp {
    	
    	ask Foyers_Paysans {
    		if (monAgregat != nil){
    			set typeIntra <- "In";
    		} else {
    			set typeIntra <- "Out";
    		}
    		set monAgregat <- nil;
    	}
    	
    	ask Agregats {
    		set nbfp_avant_dem <- length(fp_agregat);
    		set fp_agregat <- Foyers_Paysans overlapping self;
    		ask fp_agregat {
    			set monAgregat <- myself;
    			set typeIntra <- typeIntra + "In";
    		}
    		
    		
    	}
    	ask Foyers_Paysans where (each.monAgregat = nil){
    		set typeIntra <- typeIntra + "Out";
    	}
    	
    }
    
}

entities {
	
	species tmpAgregats schedules: shuffle(tmpAgregats){
		bool CA <- false;
		geometry shape <- nil;
		list<agent> mesAgents <- [];
		list<Foyers_Paysans> mesFP <- [];
		list<Eglises> mesEglisesParoissiales <- [];
		list<Chateaux> mesChateaux <- [];
	}

	species Agregats parent: Attracteurs schedules: shuffle(Agregats){
		int attractivite <- 0;
		list<Foyers_Paysans> fp_agregat ;
		bool communaute <- false;
		list<Chateaux> mesChateaux <- [];
		list<Eglises> mesParoisses;
		int nb_fp_attires <- 0 update: 0;
		int nbfp_avant_dem <- 0 update: 0;
		
		action update_chateau {
			// FIXME : Chateaux trop proches sinon
			
			if (length(mesChateaux) = 0 or (self distance_to one_of(mesChateaux) > 1000)) {
				list<Chateaux> Chateaux_proches <- Chateaux at_distance 1000;
				if (empty(Chateaux_proches)) {
					mesChateaux <- [];
				} else {
					mesChateaux <- Chateaux_proches;
				}
			}
		}
		
		
		action update_attractivite {
			set attractivite <- length(fp_agregat);
		}
		
		
		action update_communaute {
			if (!self.communaute) {
				if (flip(proba_apparition_communaute)) {
					set communaute <- true;
					ask self.fp_agregat {
						set communaute <- true;
					}
				} else {
					ask self.fp_agregat {
						set communaute <- false;
					}
				}
			} else {
				ask self.fp_agregat {
					set communaute <- true;
				}
			}
		}
		
		
	}
}