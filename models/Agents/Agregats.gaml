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
    	list<container<agent>> agregats_detectes <- simple_clustering_by_distance((Foyers_Paysans + Chateaux + eglises_paroissiales), distance_detection_agregats);
    	// On ne conserve que les composantes constituées de > 5 (parametre) FP
    	list<container<agent>> agregats_corrects <- agregats_detectes where (length(each of_species Foyers_Paysans) >= nombre_FP_agregat);

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
			}
			if (Annee >= apparition_communautes){do update_communaute;}
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
		
	action enquote (unknown text) {
		return '"' + string(text) + '"';
	}
		
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
