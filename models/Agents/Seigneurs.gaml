/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8


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
			
			if (length(Agregats) > 0){
				Agregats cetAgregat <- one_of(Agregats);
				point thisLocation <- any_location_in(cetAgregat.shape inter reduced_worldextent);
				location <- thisLocation;
			} else {
				location <- any_location_in(reduced_worldextent);
			}
			
			set droits_haute_justice <- false;
			
			if (flip(proba_collecter_loyer)){
				int rayon_zone <- rayon_min_zp_ps + rnd(rayon_max_zp_ps - rayon_min_zp_ps);
				float txPrelev <- min_taux_prelevement_zp_ps + rnd(max_taux_prelevement_zp_ps - min_taux_prelevement_zp_ps);
				Seigneurs ceSeigneur <- self;
				ask world {
					do creer_zone_prelevement (centre_zone: ceSeigneur.location, rayon: rayon_zone, proprio: ceSeigneur, typeDroit: "foncier", txPrelev: txPrelev, chateau_zp: nil);
				}
				
			}			
		}
	}
}

species Seigneurs schedules: [] {
	
	string type <- "Petit Seigneur";
	bool initial <- false;
	
	float puissance_init;
	float puissance <- 0.0;

	bool droits_haute_justice <- false ;
	bool chatelain <- false;
	
	Seigneurs monSuzerain <- nil;
	
	int nbFP_concernes <- 0 ;
	
	list<Foyers_Paysans> FP_assujettis <- [];
	
	list<Foyers_Paysans> FP_foncier <- [];
	list<Foyers_Paysans> FP_foncier_garde <- [];
	
	list<Foyers_Paysans> FP_haute_justice <- [];
	list<Foyers_Paysans> FP_haute_justice_garde <- [];
	
	list<Foyers_Paysans> FP_autres_droits <- [];
	list<Foyers_Paysans> FP_autres_droits_garde <- [];
	
	list<Seigneurs> mesDebiteurs <- [];
	Agregats monAgregat <- nil;
	
	
	action gains_droits_ps {		
		if flip(proba_creation_zp_autres_droits_ps){
			int rayon_zone <- rayon_min_zp_ps + rnd(rayon_max_zp_ps - rayon_min_zp_ps);
			float taux_ZP <- min_taux_prelevement_zp_ps + rnd(max_taux_prelevement_zp_ps - min_taux_prelevement_zp_ps);
			point location_zp <- any_location_in(3000 around self.location inter reduced_worldextent);
			Seigneurs ceSeigneur <- self;
			ask world {
				do creer_zone_prelevement (centre_zone: location_zp, rayon: rayon_zone, proprio: ceSeigneur, typeDroit: "autres_droits", txPrelev: taux_ZP, chateau_zp: nil);
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
					do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: ceChateau.rayon_zps, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: 1.0, chateau_zp: ceChateau);
				}
				ask Zones_Prelevement where (each.monChateau = ceChateau){
					set gardien <- ceChateau.gardien;
				}	
			}
		}
	}
	
	action don_droits_ps {
		Seigneurs seigneur_donateur <- self;
		ask Zones_Prelevement where (each.proprietaire = seigneur_donateur and each.gardien = nil){
			if (flip(proba_cession_droits_zp)) { // On donne
				Seigneurs seigneur_beneficiaire <- nil;
				if (flip(proba_cession_locale)){ // Cession à un PS local
					set seigneur_beneficiaire <- one_of(Seigneurs where (each.type = "Petit Seigneur"and (each distance_to self < rayon_cession_locale_droits_ps) and each != self));
				}
				if (seigneur_beneficiaire = nil){ // Comme ça, on capte aussi les cas où il n'y a pas de PS à proximité
					set seigneur_beneficiaire <- one_of(Seigneurs where (each.type = "Petit Seigneur" and (each distance_to self > rayon_cession_locale_droits_ps) and each != self));
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
	
	
	action construction_chateaux {	
		
		float proba_creation <- self.type =  "Grand Seigneur" ? (1 - exp(-0.00064 * self.puissance) ) : self.puissance / 2000;
		int  nb_chateaux_potentiels <- self.type =  "Grand Seigneur" ? nb_max_chateaux_par_tour_gs : nb_max_chateaux_par_tour_ps;
		bool is_gs <-  self.type =  "Grand Seigneur" ? true : false;
			
		float maxPuissance <- max(Seigneurs collect each.puissance) ;
		float minPuissance <- min(Seigneurs collect each.puissance) ;
		int rayon_chateau <- int(max([
			min_rayon_zp_chateau, min([
				max_rayon_zp_chateau,
				( maxPuissance / (maxPuissance - minPuissance) )- (self.puissance / (maxPuissance - minPuissance))
				])])
		);
		
		loop times: nb_chateaux_potentiels {
			if (espace_dispo_chateaux != nil) {
			if flip(proba_creation){
				// Si création tirée
				geometry espace_disponible <- espace_dispo_chateaux;
				
				point location_chateau <- nil;
				Agregats choix_agregat <- nil;
				if (is_gs){ // Chateau de GS
					if (flip(proba_chateau_gs_agregat)){
						set choix_agregat <- one_of(agregats_loins_chateaux);
					}
					if (choix_agregat != nil){
						set location_chateau <- any_location_in(choix_agregat.shape);
					} else {
						set location_chateau <- any_location_in(espace_disponible);
					}
				} else { // chateau de PS
					list<Agregats> agregats_possibles <- agregats_loins_chateaux where (length(each.mesChateaux) = 0);
					set choix_agregat <- !empty(agregats_possibles) ? agregats_possibles closest_to self : nil;
					set location_chateau <- (choix_agregat != nil) ? any_location_in(choix_agregat.shape + 500) : any_location_in(espace_disponible);
					// On met à jour les droits de haute justice pour les PS au passage
					if (proba_gain_haute_justice_chateau_ps_actuel > 0.0 and !droits_haute_justice){
						set droits_haute_justice <- flip(proba_gain_haute_justice_chateau_ps_actuel);
						if (droits_haute_justice){
							Seigneurs ceSeigneur <- self;
							ask Chateaux where (each.proprietaire = ceSeigneur) {
								Chateaux ceChateau <- self;
								ask world {
									do creer_zone_prelevement (centre_zone: ceChateau.location, rayon: ceChateau.rayon_zps, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: 1.0, chateau_zp: ceChateau);
								}
							}
						}
					}
				}
				// Construction Chateau
				Chateaux ceChateau <- nil;
				create Chateaux number: 1 {
					set location <- location_chateau;
					if (choix_agregat != nil){
						set monAgregat <- choix_agregat;
						ask monAgregat {mesChateaux <+ myself;}
					}
					set proprietaire <- myself;
					set rayon_zps <- rayon_chateau;
					set ceChateau <- self;
				}
				geometry espace_affecte <- dist_min_entre_chateaux around ceChateau.location;
				set espace_dispo_chateaux <- espace_dispo_chateaux - espace_affecte;
				list<Agregats> agregats_dans_espace_affecte <- distinct(Agregats inside espace_affecte);
				set agregats_loins_chateaux <- distinct(agregats_loins_chateaux - agregats_dans_espace_affecte);
				set chatelain <- true;
				// Construction ZPs
				Seigneurs ceSeigneur <- self;
				ask world {
					do creer_zone_prelevement (centre_zone: location_chateau, rayon: rayon_chateau, proprio: ceSeigneur, typeDroit: "foncier", txPrelev: 1.0, chateau_zp: ceChateau);
					do creer_zone_prelevement (centre_zone: location_chateau, rayon: rayon_chateau, proprio: ceSeigneur, typeDroit: "autres_droits", txPrelev: 1.0, chateau_zp: ceChateau);
				}
				if (droits_haute_justice){
					ask world {
						do creer_zone_prelevement (centre_zone: location_chateau, rayon: rayon_chateau, proprio: ceSeigneur, typeDroit: "haute_justice", txPrelev: 1.0, chateau_zp: ceChateau);
					}
				}
			}
		} // Sinon, on ne fait rien
	}
	}
	
	action update_agregats_seigneurs {
		set monAgregat <- nil;
		Agregats plusProcheAgregat <- Agregats closest_to self;
		if ((plusProcheAgregat distance_to self) < 200){
			set monAgregat <- plusProcheAgregat;
		}
	}
	
}
