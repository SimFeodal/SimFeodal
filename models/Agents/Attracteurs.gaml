/**
 *  SimFeodal
 *  Author: R. Cura, C. Tannier, S. Leturcq, E. Zadora-Rio
 *  Description: https://simfeodal.github.io/
 *  Repository : https://github.com/SimFeodal/SimFeodal
 *  Version : 6.3
 *  Run with : Gama 1.8 (git) (1.7.0.201903051304)
 */

model simfeodal

import "../init.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agregats.gaml"
import "Eglises.gaml"
import "Chateaux.gaml"
import "Seigneurs.gaml"
import "Zones_Prelevement.gaml"

global {
	
	action update_poles {
		
		ask Poles {do die;}
    	// ****************************** //
    	// Detection des poles d'agrégats //
    	// ****************************** //
    	
    	list<Agregats> agregats_dans_poles <- list(Agregats);
    	list<Chateaux> chateaux_dans_poles <- list(Chateaux);
    	list<Eglises> eglises_dans_poles <- Eglises where each.eglise_paroissiale;
    	ask Agregats {
    		if ((length(mesChateaux) + length(mesParoisses)) >= 1){
    			create Poles number: 1 {
					set mesAttracteurs <- myself.mesChateaux + myself.mesParoisses;
					if(myself.communaute){mesAttracteurs <+ myself;}
					set shape <- myself.shape;
					set monAgregat <- myself;
    			}
    			agregats_dans_poles >- self;
    			chateaux_dans_poles >- mesChateaux;
    			eglises_dans_poles >- mesParoisses;
    		}
    	}
		
		list<list> poles_uniques <- simple_clustering_by_distance((eglises_dans_poles + chateaux_dans_poles + (agregats_dans_poles where each.communaute)) of_generic_species Attracteurs, 200);

		loop currentPole over: poles_uniques {
			create Poles number: 1 {
				set mesAttracteurs <- list<Attracteurs>(currentPole);
				set shape <- convex_hull(polygon(mesAttracteurs collect each.location)) + 200; // Buffer de 200m autour du convex_hull
			}
		}
		
		loop cetAgregat over: Agregats {
			loop cePole over: Poles {
				if (dead(cePole)){break;}
				geometry cetAgregatShape <- cetAgregat.shape;

				if (cePole.shape intersects cetAgregatShape){
					set cetAgregat.monPole <- cePole;
					set cePole.shape <- cePole.shape + cetAgregatShape;
					set cePole.monAgregat <- cetAgregat;
					loop pole_a_absorber over: (Poles - cePole) {
						if (dead(pole_a_absorber)){break;}
						if (pole_a_absorber.shape intersects cePole.shape){
							set cePole.mesAttracteurs <- cePole.mesAttracteurs + pole_a_absorber.mesAttracteurs;
							set cePole.shape <- cePole.shape + pole_a_absorber.shape;
							ask pole_a_absorber {do die;}
						}
					}
				}
			}
		}
    	
		ask Poles {
			list<Eglises> mesEglises <- mesAttracteurs of_species Eglises;
			list<Chateaux> mesChateaux <- mesAttracteurs of_species Chateaux;
			list<Agregats> mesCommunautes <- mesAttracteurs of_species Agregats;
			set attractivite <- 0.0 ;


			switch length(mesEglises) {
				match 0 {set attractivite <- 0.0;}
				match 1 {set attractivite <- attractivite_1_eglise;}
				match 2 {set attractivite <- attractivite_2_eglise;}
				match 3 {set attractivite <- attractivite_3_eglise;}
				default {set attractivite <- attractivite_4_eglise;} // 4 et +
			}
			
			if (length(mesChateaux) > 0){
				if ( (mesChateaux count (each.type = "Grand Chateau")) > 0){
					set attractivite <- attractivite + attractivite_gros_chateau;
				} else {
					set attractivite <- attractivite + attractivite_petit_chateau;
				}
			}
			if (length(mesCommunautes) > 0){
				set attractivite <- attractivite + attractivite_communaute;
			}
		}
	}
			
}

	
species Attracteurs schedules: [] {
	int attractivite <- 0;
}

species Poles schedules: [] {
	float attractivite;
	list<Attracteurs> mesAttracteurs;
	Agregats monAgregat;
}
