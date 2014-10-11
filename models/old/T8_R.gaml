/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model transition8

global {
	action generer_foyers_paysans {
		// Création agglos antiques
		list centres_agglos <- [];
		loop times: nombre_agglos_antiques {
			add any_location_in(reduced_worldextent) to: centres_agglos;
		}
		loop centre_actuel over: centres_agglos {
			create Foyers_Paysans number: 30 {
				set location <- any_location_in(300 around centre_actuel);
			}
		}
		// Création villages
		list centres_villages <- [];
		loop times: nombre_villages {
			add any_location_in(reduced_worldextent) to: centres_villages;
		}
		loop centre_actuel over: centres_villages {
			create Foyers_Paysans number: nombre_foyers_villages {
				set location <- any_location_in((10 * nombre_foyers_villages) around centre_actuel);
			}
		}
		// Création FP
		create Foyers_Paysans number: (nombre_foyers_paysans - ((nombre_agglos_antiques * 30) + (nombre_villages * nombre_foyers_villages))) {
			set location <- any_location_in(worldextent);
		}
	}
	
	action generer_chateaux {
		create Chateaux number: nombre_chateaux {
			set location <- any_location_in(reduced_worldextent);
		}
	}

	action generer_eglises {
		create Eglises number: nombre_eglises {
			set location <- any_location_in(reduced_worldextent);
		}
	}
	
	action generer_monde {
		do generer_foyers_paysans;
		do generer_chateaux;
		do generer_eglises;
	}
	
	int nombre_foyers_paysans <- 1000 ;
	int nombre_agglos_antiques <- 3 ;
	int nombre_villages <- 20 ;
	int nombre_foyers_villages <- 10 ;
	int nombre_chateaux <- 20 ;
	int nombre_eglises <- 600 ;
	bool creation_avec_R <- false ;
	
	float Seuil_satisfaction <- 0.8 ;
	
	file shape_file_bounds <- file("../includes/Emprise_territoire.shp");
	file shape_file_grid <- file("../includes/Grille_territoire.shp");
	   
	file shape_file_FP <- file("../includes/model_layers/Foyers_Paysans.shp");
	file shape_file_Chateaux <- file("../includes/model_layers/Chateaux.shp");
	file shape_file_Eglises <- file("../includes/model_layers/Eglises.shp");
	
	geometry shape <- envelope(shape_file_bounds) ;
	geometry worldextent <- envelope(shape_file_bounds) ;
	geometry reduced_worldextent <- worldextent scaled_by 0.99;
	init {
		if (creation_avec_R) {
			list parametres_initialisation <- [nombre_foyers_paysans, nombre_agglos_antiques, nombre_villages, nombre_foyers_villages, nombre_chateaux, nombre_eglises];
			string result <- string(R_compute_param("../includes/script_initialisation.R", parametres_initialisation));
	        create Foyers_Paysans from: shape_file_FP with: [
	        	type:: string(read('Type')),
	        	Satisfaction:: (rnd(10) / 10)
	        ] ;
	        create Chateaux from: shape_file_Chateaux with: [type:: string(read('Type'))] ;
	        create Eglises from: shape_file_Eglises with: [type:: string(read('Type')), droits_paroissiaux:: int(read('DroitsPar'))] ;
		} else {
			do generer_monde;
		}
    }
    reflex update_agglomerations {
    	ask Agglomerations {
    		do die;
    	}
    	list agglos <- connected_components_of(list(Foyers_Paysans) as_distance_graph 200) where (length(each) >= 5);
    	loop agglo over: agglos {
    		create Agglomerations number: 1 {
    			set Communaute_agraire <- false;
    			set fp_agglo <- list<Foyers_Paysans>(agglo);
    		}
    	}
    	
    }
}

entities {
	species Grille_analyse {
	}
	
	species Foyers_Paysans {
		string type;
		bool comm_agraire;
		float Satisfaction ;
		list<Seigneurs> mesSeigneurs ;
		
		reflex update_satisfaction {
			float satisfaction_materielle <- (rnd(33) / 100);
			float satisfaction_spirituelle <- (rnd(33) / 100);
			float satisfaction_protection <- (rnd(33) / 100);
			set Satisfaction <- satisfaction_materielle + satisfaction_spirituelle + satisfaction_protection;
		}
		
		reflex demenagement {
			if (Satisfaction < 0.1) {
				do die;
			} else if (Satisfaction < 0.2) {
				do demenagement_lointain;
			} else {do demenagement_local;
				
			}
		}
		
		action demenagement_local {
			location <- any_location_in(100 around self.location);
			//write "local";
		}
		
		action demenagement_lointain {
			location <- any_location_in(worldextent);
			//write "lointain";
		}
		
	}
	
	species Chateaux {
		string type;
		list<string> fonctions_possedees;
		float aire_attraction;
		Agglomerations monAgglo;
		float attractivite ;
		
		reflex update_attractivite {
			set attractivite <- float(length(fonctions_possedees));
		}
	}
	
	species Eglises {
		string type;
		int droits_paroissiaux;
	}
	
	species Agglomerations {
		float attractivite;
		list<Foyers_Paysans> fp_agglo ;
		bool Communaute_agraire ;
		
		reflex update_attractivite {
			set attractivite <- length(fp_agglo) +  sum(Chateaux where (self = each.monAgglo) collect each.attractivite);
		}
		
		reflex update_comm_agraire {
			if (!Communaute_agraire){
				if (rnd(100) > 80) { set Communaute_agraire <- true;} 
			}
		}
	}
	
	species Seigneurs {
		string type;
		float richesse;
		float pouvoir_armee;
		list<Foyers_Paysans> FP_controlles ;
		list<Chateaux> chateaux_controlles;
		list<Seigneurs> vassaux;
		float richesse_autorite_centrale;
		
		reflex MaJ_pouvoir_armee {
			set pouvoir_armee <- (length(FP_controlles)) + sum(vassaux collect each.richesse);
		}
		reflex disparition when: (richesse = 0){
			do die;
		}
	}
}
	
experiment base_experiment type: gui {
	/*user_command testcluster {
		list abc <- list(Foyers_Paysans) as_distance_graph 200;
		write(string(length(abc)));
	}*/
	parameter "Utiliser R pour générer les agents ?" var: creation_avec_R category: "Initialisation";
	parameter "Nombre de Foyers Paysans:" var: nombre_foyers_paysans category: "Initialisation";
	parameter "Nombre d'agglomérations secondaires antiques:" var: nombre_agglos_antiques category: "Initialisation";
	parameter "Nombre de villages:" var: nombre_villages category: "Initialisation";
	parameter "Nombre de Foyers Paysans par village:" var: nombre_foyers_villages category: "Initialisation";
	parameter "Nombre de Châteaux:" var: nombre_chateaux category: "Initialisation";
	parameter "Nombre d'églises:" var: nombre_eglises category: "Initialisation";

	output {
		display world_display {
			species Foyers_Paysans;
			species Eglises;
			species Chateaux;
		}
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre d'agglomération rurales" value: length(Agglomerations);
	}
}


/*

Foyers Paysans :
rgb color <- rgb('gray') ;
aspect base {
	draw circle(500) color: color;
}
		
Eglises :
rgb color <- rgb('blue') ;
aspect base {
	draw circle(500) color: color ;
}

Chateaux :
rgb color <- rgb('red') ;
aspect base {
	draw circle(1000) color: color ;
}

display world_display {
			species Foyers_Paysans aspect: base ;
			species Eglises aspect: base ;
			species Chateaux aspect: base ;
		}
 */