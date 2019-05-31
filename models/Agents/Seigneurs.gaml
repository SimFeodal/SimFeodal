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
import "Chateaux.gaml"
import "Eglises.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"


global {
	action creation_nouveaux_seigneurs {
		int variabilite_nb_seigneurs <- round(nb_moyen_petits_seigneurs_par_tour / 3);
		int nb_seigneurs_a_creer <- nb_moyen_petits_seigneurs_par_tour + variabilite_nb_seigneurs - rnd(variabilite_nb_seigneurs * 2);
		// Varie entre -1/3 et +1/3 autour de la moyenne
		create Seigneurs number: nb_seigneurs_a_creer {
			set type <- "Petit Seigneur";
			set date_apparition <- annee;
			
			if (length(Agregats) > 0){
				Agregats cetAgregat <- one_of(Agregats);
				point thisLocation <- any_location_in(cetAgregat.shape inter reduced_worldextent);
				location <- thisLocation;
			} else {
				location <- any_location_in(reduced_worldextent);
			}
			
			set droits_haute_justice <- false;
			
			if (flip(proba_collecter_foncier_ps)){
				int rayon_zp_ps <- rayon_min_zp_ps + rnd(rayon_max_zp_ps - rayon_min_zp_ps);
				float taux_prelevement_zp <- min_taux_prelevement_zp_ps + rnd(max_taux_prelevement_zp_ps - min_taux_prelevement_zp_ps);
				Seigneurs ceSeigneur <- self;
				ask world {
					do creer_zone_prelevement (centre_zone: ceSeigneur.location, rayon: rayon_zp_ps, proprio: ceSeigneur, typeDroit: "foncier", txPrelev: taux_prelevement_zp, chateau_zp: nil);
				}
				
			}			
		}
	}
}

species Seigneurs schedules: [] {
	
	string type <- "Petit Seigneur";
	int date_apparition;
	
	float puissance_init;
	float puissance <- 0.0;

	bool droits_haute_justice <- false ;
	bool chatelain <- false;
	
	int nbFP_concernes <- 0 ;
	
	list<Foyers_Paysans> FP_assujettis <- [];
	
	list<Foyers_Paysans> FP_foncier <- [];
	list<Foyers_Paysans> FP_foncier_garde <- [];
	
	list<Foyers_Paysans> FP_haute_justice <- [];
	list<Foyers_Paysans> FP_haute_justice_garde <- [];
	
	list<Foyers_Paysans> FP_autres_droits <- [];
	list<Foyers_Paysans> FP_autres_droits_garde <- [];
	
	Agregats monAgregat <- nil;
	
	
	action gains_droits_ps {		
		if flip(proba_creation_zp_autres_droits_ps){
			int rayon_zp_ps <- rayon_min_zp_ps + rnd(rayon_max_zp_ps - rayon_min_zp_ps);
			float taux_prelevement_zp <- min_taux_prelevement_zp_ps + rnd(max_taux_prelevement_zp_ps - min_taux_prelevement_zp_ps);
			point location_zp <- any_location_in(3000 around self.location inter reduced_worldextent);
			Seigneurs ceSeigneur <- self;
			ask world {
				do creer_zone_prelevement (centre_zone: location_zp, rayon: rayon_zp_ps, proprio: ceSeigneur, typeDroit: "autres_droits", txPrelev: taux_prelevement_zp, chateau_zp: nil);
			}
		}
	}
	
	action don_chateau (Chateaux chateau_donne) {
		Seigneurs seigneur_donateur <- self;
		Seigneurs seigneur_beneficiaire <- one_of(Seigneurs where (!each.chatelain and each.type != "Grand Seigneur"));
		
		set chateau_donne.gardien <- seigneur_beneficiaire;
		set seigneur_beneficiaire.chatelain <- true;
		ask Zones_Prelevement where (each.monChateau = chateau_donne){
			set gardien <- seigneur_beneficiaire;
		}		
	}
	
	action maj_droits_haute_justice_gs {
		if flip(proba_gain_haute_justice_gs_actuel){
			set droits_haute_justice <- true;
			Seigneurs ceSeigneur <- self;
			ask Chateaux where (each.proprietaire = ceSeigneur) {
				Chateaux ceChateau <- self;
				ask world {
					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: ceChateau.rayon_zp_chateau, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
				}
				ask Zones_Prelevement where (each.monChateau = ceChateau){
					set gardien <- ceChateau.gardien;
				}	
			}
		}
	}
	
	action don_droits_ps {
		Seigneurs seigneur_donateur <- self;
		ask Zones_Prelevement where (each.monChateau = nil and each.proprietaire = seigneur_donateur and each.gardien = nil){
			if (flip(proba_cession_droits_zp)) { // On donne
				Seigneurs seigneur_beneficiaire <- nil;
				if (flip(proba_cession_locale)){ // Cession à un PS local
					set seigneur_beneficiaire <- one_of((Seigneurs - self) where (each.type = "Petit Seigneur"and (each distance_to self < rayon_voisinage_ps)));
				}
				if (seigneur_beneficiaire = nil){ // Comme ça, on capte aussi les cas où il n'y a pas de PS à proximité
					set seigneur_beneficiaire <- one_of((Seigneurs - self) where (each.type = "Petit Seigneur" and (each distance_to self > rayon_voisinage_ps)));
				}
				set gardien <- seigneur_beneficiaire;	
			} // On ne donne pas
		} 
	}
	
	action reset_variables {
		set FP_assujettis <- [];
		
		set FP_foncier <- [];
		set FP_foncier_garde <- [];
	
		set FP_haute_justice <- [];
		set FP_haute_justice_garde <- [];
		
		set FP_autres_droits <- [];
		set FP_autres_droits_garde <- [];
		
	}
	
	action MaJ_puissance {
		set FP_foncier <- remove_duplicates(FP_foncier);
		set FP_foncier_garde <- remove_duplicates(FP_foncier_garde);
		set FP_haute_justice <- remove_duplicates(FP_haute_justice);
		set FP_haute_justice_garde <- remove_duplicates(FP_haute_justice_garde);
		
		float total_foncier <- (length(FP_foncier) * droits_fonciers_zp) + (length(FP_foncier_garde) * droits_fonciers_zp_cession);
		float total_haute_justice <- (length(FP_haute_justice) * droits_haute_justice_zp) + (length(FP_haute_justice_garde) * droits_haute_justice_zp_cession);
		float total_autres_droits <- (length(FP_autres_droits) * autres_droits_zp) + (length(FP_autres_droits_garde) * autres_droits_zp_cession);
		
		set FP_assujettis <- remove_duplicates(FP_foncier + FP_foncier_garde + FP_haute_justice + FP_haute_justice_garde + FP_autres_droits + FP_autres_droits_garde);
		
		set puissance <- puissance + total_foncier + total_haute_justice + total_autres_droits;
	}
	
	
	
	Chateaux creer_chateau (point location_chateau, int rayon_zp_associees, Seigneurs seigneur_chatelain, Agregats agregat_chateau){
		Chateaux ceChateau;
		create Chateaux number: 1 {
			set location <- location_chateau;
			if (agregat_chateau != nil){
				set monAgregat <- agregat_chateau;
				ask monAgregat {mesChateaux <+ myself;}
			}
			set proprietaire <- seigneur_chatelain;
			set rayon_zp_chateau <- rayon_zp_associees;
			set ceChateau <- self;
		}
		return(ceChateau);
	}
	
//	action construction_chateaux {	
//		bool is_gs <- (self.type = "Grand Seigneur");
//		
//		float ponderation_proba <- (is_gs) ? ponderation_proba_chateau_gs : ponderation_proba_chateau_ps;
//		float proba_creer_chateau <- (self.puissance / somme_puissance) * ponderation_proba ;
//		int  nb_chateaux_potentiels <- (is_gs) ? nb_max_chateaux_par_tour_gs : nb_max_chateaux_par_tour_ps;
//			
//		float maxPuissance <- max(Seigneurs collect each.puissance) ;
//		float minPuissance <- min(Seigneurs collect each.puissance) ;
//		int rayon_zp <- int(max([
//			rayon_min_zp_chateau, min([
//				rayon_max_zp_chateau,
//				( maxPuissance / (maxPuissance - minPuissance) )- (self.puissance / (maxPuissance - minPuissance))
//				])])
//		);
//		
//		loop times: nb_chateaux_potentiels {
//			if (espace_dispo_chateaux != nil and flip(proba_creer_chateau)){
//				// Si création tirée
//				geometry espace_disponible <- espace_dispo_chateaux;				
//				
//
//				geometry espace_disponible_seigneur <- (is_gs) ? espace_dispo_chateaux : espace_dispo_chateaux inter (rayon_voisinage_ps around self);
//				list<Agregats> agregats_possibles <- (is_gs) ? agregats_loins_chateaux : distinct(agregats_loins_chateaux inside espace_disponible_seigneur);
//				
//				Chateaux ceChateau;
//				// FIXME : espace_diponible_seigneur buggait pour les PS : corrigé mais vérifier que ça fonctionne correctement
//				if (flip(proba_chateau_agregat) and length(agregats_possibles) > 0){
//					// Construction dans agrégat
//					Agregats agregat_choisi <- one_of(agregats_possibles);
//					point choix_location <- any_location_in(espace_disponible_seigneur inter agregat_choisi.shape);
//					set ceChateau <- creer_chateau(location_chateau: choix_location, rayon_zp_associees: rayon_zp, seigneur_chatelain: self, agregat_chateau: agregat_choisi);
//				} else {
//					// Construction dans zone quelconque
//					point choix_location <- any_location_in(espace_disponible_seigneur);
//					set ceChateau <- creer_chateau(location_chateau: choix_location, rayon_zp_associees: rayon_zp, seigneur_chatelain: self, agregat_chateau: nil);			
//				}
//				
//				geometry espace_affecte <- dist_min_entre_chateaux around ceChateau.location;
//				set espace_dispo_chateaux <- espace_dispo_chateaux - espace_affecte;
//				list<Agregats> agregats_dans_espace_affecte <- distinct(Agregats inside espace_affecte);
//				set agregats_loins_chateaux <- distinct(agregats_loins_chateaux - agregats_dans_espace_affecte);
//				set chatelain <- true;
//				
//				// MaJ droits haute_justice PS :
//				if (!is_gs and !droits_haute_justice and proba_gain_haute_justice_chateau_ps_actuel > 0.0){
//					set droits_haute_justice <- flip(proba_gain_haute_justice_chateau_ps_actuel);
//					if (droits_haute_justice){
//						Seigneurs ceSeigneur <- self;
//						ask Chateaux where (each.proprietaire = ceSeigneur) {
//							Chateaux ceChateau <- self;
//							ask world {
//								do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: ceChateau.rayon_zp_chateau, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//							}
//						}
//					}
//				}
//				
//				// Construction ZPs
//				Seigneurs ceSeigneur <- self;
//				ask world {
//					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "foncier", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "autres_droits", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//				}
//				if (droits_haute_justice){
//					ask world {
//						do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//					}
//				}	
//			}	
//		}
//	}
	
	action construction_chateaux {	
		bool is_gs <- (self.type = "Grand Seigneur");
		float somme_puissance_gs <- sum(Seigneurs where (each.type = "Grand Seigneur") collect (each.puissance));
		float proba_creer_chateau <- (is_gs) ? (self.puissance / somme_puissance_gs) : 1.0;
		//int  nb_chateaux_potentiels <- (is_gs) ? nb_max_chateaux_par_tour_gs : nb_max_chateaux_par_tour_ps;
			
		float maxPuissance <- max(Seigneurs collect each.puissance) ;
		float minPuissance <- min(Seigneurs collect each.puissance) ;
		int rayon_zp <- int(max([
			rayon_min_zp_chateau, min([
				rayon_max_zp_chateau,
				( maxPuissance / (maxPuissance - minPuissance) )- (self.puissance / (maxPuissance - minPuissance))
				])])
		);
		
		int nb_tirages <- (is_gs) ? rnd(nb_max_chateaux_par_tour_gs, nb_max_chateaux_par_tour_gs + 1, 1) : nb_max_chateaux_par_tour_ps;
		loop times: nb_tirages {
			if (espace_dispo_chateaux != nil and flip(proba_creer_chateau)){
				// Si création tirée
				geometry espace_disponible <- espace_dispo_chateaux;				
				

				geometry espace_disponible_seigneur <- (is_gs) ? espace_dispo_chateaux : espace_dispo_chateaux inter (rayon_voisinage_ps around self);
				list<Agregats> agregats_possibles <- (is_gs) ? agregats_loins_chateaux : distinct(agregats_loins_chateaux inside espace_disponible_seigneur);
				
				Chateaux ceChateau;
				// FIXME : espace_diponible_seigneur buggait pour les PS : corrigé mais vérifier que ça fonctionne correctement
				if (flip(proba_chateau_agregat) and length(agregats_possibles) > 0){
					// Construction dans agrégat
					Agregats agregat_choisi <- one_of(agregats_possibles);
					point choix_location <- any_location_in(espace_disponible_seigneur inter agregat_choisi.shape);
					set ceChateau <- creer_chateau(location_chateau: choix_location, rayon_zp_associees: rayon_zp, seigneur_chatelain: self, agregat_chateau: agregat_choisi);
				} else {
					// Construction dans zone quelconque
					point choix_location <- any_location_in(espace_disponible_seigneur);
					set ceChateau <- creer_chateau(location_chateau: choix_location, rayon_zp_associees: rayon_zp, seigneur_chatelain: self, agregat_chateau: nil);			
				}
				
				geometry espace_affecte <- dist_min_entre_chateaux around ceChateau.location;
				set espace_dispo_chateaux <- espace_dispo_chateaux - espace_affecte;
				list<Agregats> agregats_dans_espace_affecte <- distinct(Agregats inside espace_affecte);
				set agregats_loins_chateaux <- distinct(agregats_loins_chateaux - agregats_dans_espace_affecte);
				set chatelain <- true;
				
				// MaJ droits haute_justice PS :
				if (!is_gs and !droits_haute_justice and proba_gain_haute_justice_chateau_ps_actuel > 0.0){
					set droits_haute_justice <- flip(proba_gain_haute_justice_chateau_ps_actuel);
					if (droits_haute_justice){
						Seigneurs ceSeigneur <- self;
						ask Chateaux where (each.proprietaire = ceSeigneur) {
							Chateaux ceChateau <- self;
							ask world {
								do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: ceChateau.rayon_zp_chateau, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
							}
						}
					}
				}
				
				// Construction ZPs
				Seigneurs ceSeigneur <- self;
				ask world {
					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "foncier", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "autres_droits", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
				}
				if (droits_haute_justice){
					ask world {
						do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
					}
				}	
			}	
		}
	}
	
//	action construction_chateaux_alternate {	
//		bool is_gs <- (self.type = "Grand Seigneur");
//		
//		float ponderation_proba <- (is_gs) ? ponderation_proba_chateau_gs : ponderation_proba_chateau_ps;
//		list liste_seigneurs_puissance <- reverse(Seigneurs sort_by (each.puissance));
//		int rang_kp1 <- index_of(liste_seigneurs_puissance, self) + 1;
//		float somme_puissance_kp1 <- sum(first(rang_kp1, liste_seigneurs_puissance) collect (each.puissance));
//		float proba_creer_chateau <- self.puissance / somme_puissance_kp1;
//		
//		int  nb_chateaux_potentiels <- (is_gs) ? nb_max_chateaux_par_tour_gs : nb_max_chateaux_par_tour_ps;
//			
//		float maxPuissance <- max(Seigneurs collect each.puissance) ;
//		float minPuissance <- min(Seigneurs collect each.puissance) ;
//		int rayon_zp <- int(max([
//			rayon_min_zp_chateau, min([
//				rayon_max_zp_chateau,
//				( maxPuissance / (maxPuissance - minPuissance) )- (self.puissance / (maxPuissance - minPuissance))
//				])])
//		);
//		
//		loop times: nb_chateaux_potentiels {
//			int nb_tirages_construction <- (is_gs) ? nb_tirages_chateaux_gs : nb_tirages_chateaux_ps;
//			list tirages_construction_chateau <- list_with(nb_tirages_construction, flip(proba_creer_chateau));
//			bool construire_chateau <- tirages_construction_chateau contains_any [true];
//			if (espace_dispo_chateaux != nil and construire_chateau){
//				// Si création tirée
//				geometry espace_disponible <- espace_dispo_chateaux;				
//				
//
//				geometry espace_disponible_seigneur <- (is_gs) ? espace_dispo_chateaux : espace_dispo_chateaux inter (rayon_voisinage_ps around self);
//				list<Agregats> agregats_possibles <- (is_gs) ? agregats_loins_chateaux : distinct(agregats_loins_chateaux inside espace_disponible_seigneur);
//				
//				Chateaux ceChateau;
//				// FIXME : espace_diponible_seigneur buggait pour les PS : corrigé mais vérifier que ça fonctionne correctement
//				if (flip(proba_chateau_agregat) and length(agregats_possibles) > 0){
//					// Construction dans agrégat
//					Agregats agregat_choisi <- one_of(agregats_possibles);
//					point choix_location <- any_location_in(espace_disponible_seigneur inter agregat_choisi.shape);
//					set ceChateau <- creer_chateau(location_chateau: choix_location, rayon_zp_associees: rayon_zp, seigneur_chatelain: self, agregat_chateau: agregat_choisi);
//				} else {
//					// Construction dans zone quelconque
//					point choix_location <- any_location_in(espace_disponible_seigneur);
//					set ceChateau <- creer_chateau(location_chateau: choix_location, rayon_zp_associees: rayon_zp, seigneur_chatelain: self, agregat_chateau: nil);			
//				}
//				
//				geometry espace_affecte <- dist_min_entre_chateaux around ceChateau.location;
//				set espace_dispo_chateaux <- espace_dispo_chateaux - espace_affecte;
//				list<Agregats> agregats_dans_espace_affecte <- distinct(Agregats inside espace_affecte);
//				set agregats_loins_chateaux <- distinct(agregats_loins_chateaux - agregats_dans_espace_affecte);
//				set chatelain <- true;
//				
//				// MaJ droits haute_justice PS :
//				if (!is_gs and !droits_haute_justice and proba_gain_haute_justice_chateau_ps_actuel > 0.0){
//					set droits_haute_justice <- flip(proba_gain_haute_justice_chateau_ps_actuel);
//					if (droits_haute_justice){
//						Seigneurs ceSeigneur <- self;
//						ask Chateaux where (each.proprietaire = ceSeigneur) {
//							Chateaux ceChateau <- self;
//							ask world {
//								do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: ceChateau.rayon_zp_chateau, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//							}
//						}
//					}
//				}
//				
//				// Construction ZPs
//				Seigneurs ceSeigneur <- self;
//				ask world {
//					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "foncier", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "autres_droits", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//				}
//				if (droits_haute_justice){
//					ask world {
//						do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: rayon_zp, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: taux_prelevement_zp_chateau, chateau_zp: ceChateau);
//					}
//				}	
//			}	
//		}
//	}
	
	action update_agregats_seigneurs {
		set monAgregat <- nil;
		Agregats plusProcheAgregat <- Agregats closest_to self;
		if ((plusProcheAgregat distance_to self) < 200){
			set monAgregat <- plusProcheAgregat;
		}
	}
	
}
