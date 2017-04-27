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
		
	list<tmpAgregats> tmpAgregatsRestants <- list(tmpAgregats);	
	
	loop cetAgregat over: tmpAgregatsRestants {
		if (dead(cetAgregat)){tmpAgregatsRestants >- cetAgregat;break;}
		list<agent> cetAgregatAgents <- cetAgregat.mesAgents;
		loop autreAgregat over: (tmpAgregatsRestants - cetAgregat){
			if (autreAgregat.shape intersects cetAgregat.shape){
				set cetAgregat.shape <- cetAgregat.shape + autreAgregat.shape;
				set cetAgregat.mesAgents <- cetAgregat.mesAgents + autreAgregat.mesAgents;
				set cetAgregat.mesFP <- cetAgregat.mesFP + autreAgregat.mesFP;
	    		set cetAgregat.mesEglisesParoissiales <- cetAgregat.mesEglisesParoissiales + autreAgregat.mesEglisesParoissiales;
	    		set cetAgregat.mesChateaux <- cetAgregat.mesChateaux + autreAgregat.mesChateaux;
				tmpAgregatsRestants>- autreAgregat;
				ask autreAgregat {do die;}	
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
		Poles monPole <- nil;
		
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