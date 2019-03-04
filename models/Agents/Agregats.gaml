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
    
     action update_agregats {
     	
     	// On crée un graphe de distance sur FP + Chateaux + eglises paroissiales
    	list<Eglises> eglises_paroissiales <- Eglises where (each.eglise_paroissiale);
    	list<container<agent>> agregats_detectes <- simple_clustering_by_distance((Foyers_Paysans + Chateaux + eglises_paroissiales), distance_detection_agregat);
    	// On ne conserve que les composantes constituées de > 5 (parametre) FP
    	list<container<agent>> agregats_corrects <- agregats_detectes where (length(each of_species Foyers_Paysans) >= nb_min_fp_agregat);

 	   	loop nouveauxAgregats over: agregats_corrects {
			create tmpAgregats number: 1 {
				list<point> mesPoints <- nouveauxAgregats collect each.location;			
				geometry monPoly <- convex_hull(polygon(mesPoints));
	    		set shape <- monPoly + distance_fusion_agregat;
	    		set mesAgents <- agents overlapping self;
	    		set mesFP <- mesAgents of_species Foyers_Paysans;
	    		set mesEglisesParoissiales <- mesAgents of_species Eglises;
	    		set mesChateaux <- mesAgents of_species Chateaux;
	    		
			}
    	}
	// Desaffectation des FP //
		ask Foyers_Paysans {
		set monAgregat <- nil ;
		}	

		loop cetAgregat over: tmpAgregats {
			if (!dead(cetAgregat)){
			list<tmpAgregats> autresAgregats <- list(tmpAgregats) - cetAgregat;
			loop autreAgregat over: autresAgregats {
				if (autreAgregat.shape intersects cetAgregat.shape){
					set cetAgregat.shape <- cetAgregat.shape + autreAgregat.shape;
					set cetAgregat.mesAgents <- distinct(cetAgregat.mesAgents + autreAgregat.mesAgents);
					set cetAgregat.mesFP <- distinct(cetAgregat.mesFP + autreAgregat.mesFP);
					set cetAgregat.mesEglisesParoissiales <- distinct(cetAgregat.mesEglisesParoissiales + autreAgregat.mesEglisesParoissiales);
					set cetAgregat.mesChateaux <- distinct(cetAgregat.mesChateaux + autreAgregat.mesChateaux);
					ask autreAgregat {
						do die;
					}
				}
			}
			}

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
					monPole <- thisOldAgregat.monPole ;
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
			Poles cePole <- monPole ;
			create Agregats number: 1 {
				set communaute <- recreateCA;
				set shape <- myShape;
				set mesParoisses <- cesParoisses;
				set monPole <- cePole ;
				
				//list<Chateaux> chateaux_proches <- Chateaux at_distance 2000;
				// at_distance est extrêmement lent et renvoie des résultats étranges
				list<Chateaux> chateaux_proches <- Chateaux inside (self.shape + 2000);
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
			}
			if (proba_institution_communaute > 0.0){do update_communaute;}
		}
 	}
    
    action update_agregats_fp {
    	
    	ask Foyers_Paysans {
    		set monAgregat <- nil;
    	}
    	
    	ask Agregats {
    		set fp_agregat <- Foyers_Paysans overlapping self;
    		ask fp_agregat {
    			set monAgregat <- myself;
    		}
    		
    		
    	}
    	ask Foyers_Paysans where (each.monAgregat = nil){
    	}
    	
    }
    
}
	
	species tmpAgregats schedules: []{
		bool CA <- false;
		geometry shape <- nil;
		list<agent> mesAgents <- [];
		list<Foyers_Paysans> mesFP <- [];
		list<Eglises> mesEglisesParoissiales <- [];
		list<Chateaux> mesChateaux <- [];
		Poles monPole <- nil;
	}

	species Agregats parent: Attracteurs schedules: []{
		int attractivite <- 0;
		list<Foyers_Paysans> fp_agregat ;
		bool communaute <- false;
		list<Chateaux> mesChateaux <- [];
		list<Eglises> mesParoisses;
		Poles monPole <- nil; // FIXME : jusqu'ici, toujours nil
		
		action update_chateau {
			// FIXME : Chateaux trop proches sinon
			
			if (length(mesChateaux) = 0 or (self distance_to one_of(mesChateaux) > 1000)) {
				
				//list<Chateaux> Chateaux_proches <- Chateaux at_distance 1000;
				// Remplacement du at_distance, lent et buggé
				list<Chateaux> Chateaux_proches <- Chateaux inside (self.shape + 1000);
				
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
				if (flip(proba_institution_communaute)) {
					set communaute <- true;
					ask self.fp_agregat {
						set appartenance_communaute <- true;
					}
				} else {
					ask self.fp_agregat {
						set appartenance_communaute <- false;
					}
				}
			} else {
				ask self.fp_agregat {
					set appartenance_communaute <- true;
				}
			}
		}	
		
		
		action update_satisfaction_religieuse_fp {
			list<Eglises> eglises_paroissiales <- (Eglises where (each.eglise_paroissiale));
			float distance_eglise <- min(eglises_paroissiales collect (each distance_to self)); // self distance_to eglise_paroissiale_proche;
			// Longer but more explicit
			float satisfaction_religieuse_raw <- (dist_max_eglise_actuel - distance_eglise) / (dist_max_eglise_actuel - dist_min_eglise_actuel);
			float satisfaction_religieuse_min <- min([1.0, satisfaction_religieuse_raw]);
			float satisfaction_religieuse_agregat <- max([0.0, satisfaction_religieuse_raw]);
			ask fp_agregat { set s_religieuse <- satisfaction_religieuse_agregat with_precision 2; }
		}
	
		
		action update_satisfaction_protection_fp {
			Chateaux plusProcheChateau <- Chateaux with_min_of (self distance_to each);
			float satisfaction_distance <- nil;
	
			if (plusProcheChateau = nil) {
				set satisfaction_distance <- min_s_distance_chateau; // 0.0 (default) or 0.01 (v5.1)
			} else {
				float distance_chateau <- plusProcheChateau distance_to self;
				// Longer but more explicit
				float satisfaction_distance_raw <- (dist_max_chateau - distance_chateau) / (dist_max_chateau - dist_min_chateau);
				float satisfaction_distance_min <- min([1.0, satisfaction_distance_raw]);
				set satisfaction_distance <- max([min_s_distance_chateau, satisfaction_distance_min]); // min_S_distance_chateau = 0 (default) or 0.01 (v5.1)
				// satisfaction_distance in [0.0 -> 1.0] (default) or [0.01 -> 1.0] (v5.1)
			}
			float agregat_satisfaction_protection <- satisfaction_distance ^ (besoin_protection_fp_actuel);
			ask fp_agregat { set s_protection <- agregat_satisfaction_protection with_precision 2; }
		}
	}
