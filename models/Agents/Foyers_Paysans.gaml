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
import "Agregats.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"


global
{
	action renouvellement_FP
	{
		int nb_fp_total <- length(Foyers_Paysans);
		int attractivite_totale <- nb_fp_total;
		int nb_FP_impactes <- round(taux_renouvellement_fp * length(Foyers_Paysans));
		int attractivite_agregats <- sum(Agregats collect each.attractivite);
		float proba_apparition_agregat <- attractivite_agregats / attractivite_totale;
		
		ask nb_FP_impactes among Foyers_Paysans
		{
			if (monAgregat != nil){ ask monAgregat { fp_agregat >- myself;}}
			do die;
		}
		
		list<Agregats> tousAgregats <- Agregats sort_by (each.attractivite);
		list<int> attrac_agregats <- tousAgregats collect each.attractivite;
		create Foyers_Paysans number: round((nb_fp_total * croissance_demo) + nb_FP_impactes)
		{
			if (flip(proba_apparition_agregat)){
				Agregats meilleurAgregat <- tousAgregats at rnd_choice(attrac_agregats);
				set location <- any_location_in(meilleurAgregat.shape inter reduced_worldextent);
				set monAgregat <- meilleurAgregat;
				ask monAgregat {fp_agregat <+ myself;}
			} else {
				set location <- any_location_in(reduced_worldextent);
			}
			set mobile <- flip((1 - proba_fp_dependant));
			set s_religieuse <- 1.0 with_precision 2; // Comme ça, ne concerne que les nouveaux arrivants
		}

	}
}

species Foyers_Paysans schedules: []
{
	bool appartenance_communaute <- false;
	Agregats monAgregat <- nil;
	float s_materielle;
	float s_religieuse;
	float s_protection;
	float satisfaction;
	bool mobile;

	Seigneurs seigneur_foncier <- nil;
	Seigneurs seigneur_haute_justice <- nil;
	list<Seigneurs> seigneurs_autres_droits <- [];
	int redevances_acquittees <- 0;
	string type_deplacement <- nil update: nil; //	"fixe", lointain, local
	string deplacement_from <- nil update: nil; //	"isole", "agregat"
	string deplacement_to <- nil update: nil; // "pole local avec agregat", "pole local sans agregat", "pole local avec agregat plus attractif", "pole local sans agregat plus attractif", "agregat lointain unique", "agregat lointain attractif"
	
	action reset_preleveurs
	{
		set seigneur_foncier <- nil;
		set seigneur_haute_justice <- nil;
		set seigneurs_autres_droits <- [];
	}

	action update_satisfaction_materielle
	{
		int foncier <- (self.seigneur_foncier != nil) ? 1 : 0;
		int haute_justice <- (self.seigneur_haute_justice != nil) ? 1 : 0;
		int autres_droits <- length(self.seigneurs_autres_droits);
		int nb_seigneurs <- foncier + haute_justice + autres_droits;
		set redevances_acquittees <- nb_seigneurs;
		float S_redevances <- max([1 - (redevances_acquittees * (1 / coef_redevances)), 0.0]);
		float S_contributions <- 0.0;
		if (self.monAgregat = nil)
		{
			set S_contributions <- 0.0;
		} else
		{
			set S_contributions <- (self.appartenance_communaute ? puissance_communautes_actuel : 0);
		}

		set s_materielle <- ((S_redevances) ^ (1 - S_contributions)) with_precision 2;
	}

	action update_satisfaction_religieuse
	{
	//float distance_eglise <- self distance_to eglise_paroissiale_proche;
		list<Eglises> eglises_paroissiales <- (Eglises where (each.eglise_paroissiale));
		float distance_eglise <- min(eglises_paroissiales collect (each distance_to self)); // self distance_to eglise_paroissiale_proche;
		// Longer but more explicit
		float satisfaction_religieuse_raw <- (dist_max_eglise_actuel - distance_eglise) / (dist_max_eglise_actuel - dist_min_eglise_actuel);
		float satisfaction_religieuse_min <- min([1.0, satisfaction_religieuse_raw]);
		set s_religieuse <- max([0.0, satisfaction_religieuse_min]) with_precision 2;
		
	}

	action update_satisfaction_protection
	{
		Chateaux plusProcheChateau <- Chateaux with_min_of (self distance_to each);
		float satisfaction_distance <- nil;

		if (plusProcheChateau = nil)
		{
			set satisfaction_distance <- min_s_distance_chateau; // 0.0 (default) or 0.01 (v5.1)
		} else
		{
			float distance_chateau <- plusProcheChateau distance_to self;
			// Longer but more explicit
			float satisfaction_distance_raw <- (dist_max_chateau - distance_chateau) / (dist_max_chateau - dist_min_chateau);
			float satisfaction_distance_min <- min([1.0, satisfaction_distance_raw]);
			set satisfaction_distance <- max([min_s_distance_chateau, satisfaction_distance_min]); // min_S_distance_chateau = 0 (default) or 0.01 (v5.1)
			// satisfaction_distance in [0.0 -> 1.0] (default) or [0.01 -> 1.0] (v5.1)
		}
			set s_protection <- (satisfaction_distance ^ (besoin_protection_fp_actuel)) with_precision 2;

	}

	action deplacement {
		point oldLoc <- location;
		set deplacement_from <- monAgregat != nil ? "agregat" : "isole";
			if (monAgregat != nil and monAgregat.monPole != nil){ // Si dans un agrégat doté de pôle
				do deplacement_avec_pole_agregat(oldLoc);
			} else { // Si pas dans un agrégat doté de pôle
				do deplacement_sans_pole_agregat(oldLoc);
			}		
	}
	
	action deplacement_avec_pole_agregat(point oldLoc) {
		// Poles meilleurPole <- (Poles at_distance rayon_migration_locale_fp_actuel) with_max_of (each.attractivite);
		// remplacement du at_distance buggé et lent
		Foyers_Paysans moi <- self;
		list<Poles> poles_locaux <- Poles overlapping (rayon_migration_locale_fp around moi.location);
		
//		write "deplacement_avec_pole_agregat : " + string(length(poles_locaux));
		Poles meilleurPole <- poles_locaux with_max_of (each.attractivite);
		if (meilleurPole != nil and monAgregat.monPole.attractivite >= meilleurPole.attractivite) { //  Si le pole de mon agrégat a une attractivié > attrac des  poles du voisinage
		// Alors la proba de deplacement local vaut 0 et donc je m'en remet au depl. lointain sous condition etc;
			set location <- flip(prop_migration_lointaine_fp * (1 - satisfaction)) ? deplacement_lointain() : location;
			if (oldLoc = location){
				set type_deplacement <- "fixe";
			} else {
				set type_deplacement <- "lointain";
			}
		} else { // Si un pole du voisinage a une attrac > monAgregat.pole
		// Alors la proba de deplacement local vaut 1 - Satisfaction
			if (flip(1 - satisfaction)) {
				set location <- deplacement_local();
				if (oldLoc = location){
					set type_deplacement <- "fixe";
				} else {
					set type_deplacement <- "local";
				}
			} else {
				set location <- flip(prop_migration_lointaine_fp * (1 - satisfaction)) ? deplacement_lointain() : location;
				if (oldLoc = location){
					set type_deplacement <- "fixe";
				} else {
					set type_deplacement <- "lointain";
				}
			}
		}
	}
	
	action deplacement_sans_pole_agregat(point oldLoc) {
		if (flip(1 - satisfaction)) {
			set location <- deplacement_local();
			if (oldLoc = location){
				set type_deplacement <- "fixe";
			} else {
				set type_deplacement <- "local";
			}
		} else {
			set location <- flip(prop_migration_lointaine_fp * (1 - satisfaction)) ? deplacement_lointain() : location;
			if (oldLoc = location){
				set type_deplacement <- "fixe";
			} else {
				set type_deplacement <- "lointain";
			}
		}	
	}
	
	action deplacement_serfs
	{
		point oldLoc <- location;
		set deplacement_from <- monAgregat != nil ? "agregat" : "isole";
			if (monAgregat != nil and monAgregat.monPole != nil){ // Si dans un agrégat doté de pôle
				do deplacement_avec_pole_agregat_serfs(oldLoc);
			} else { // Si pas dans un agrégat doté de pôle
				do deplacement_sans_pole_agregat_serfs(oldLoc);
			}		
	}
	
	action deplacement_avec_pole_agregat_serfs(point oldLoc) {
		
		//Poles meilleurPole <- (Poles at_distance rayon_migration_locale_fp_actuel) with_max_of (each.attractivite);
		// remplacement du at_distance buggé et lent
		Foyers_Paysans moi <- self;
		Poles meilleurPole <- (Poles overlapping (rayon_migration_locale_fp around moi.location)) with_max_of (each.attractivite);
		if (meilleurPole != nil and monAgregat.monPole.attractivite >= meilleurPole.attractivite) {
				set type_deplacement <- "fixe";
		} else {
			if (flip(1 - satisfaction)) {
				set location <- deplacement_local();
				if (oldLoc = location){
					set type_deplacement <- "fixe";
				} else {
					set type_deplacement <- "local";
				}
			} else {
				set type_deplacement <- "fixe";
			}
		}
	}
	
	action deplacement_sans_pole_agregat_serfs(point oldLoc) {
		if (flip(1 - satisfaction)) {
			set location <- deplacement_local();
			if (oldLoc = location){
				set type_deplacement <- "fixe";
			} else {
				set type_deplacement <- "local";
			}
		} else {
			set type_deplacement <- "fixe";
		}	
	}

	point deplacement_local
	{
		point point_local <- nil;
		//list<Poles> polesLocaux <- Poles at_distance rayon_migration_locale_fp_actuel;
		// remplacement du at_distance buggé et lent
		Foyers_Paysans moi <- self;
		list<Poles> polesLocaux <- Poles inside (rayon_migration_locale_fp around moi.location);
//		write "deplacement local : " + string(length(polesLocaux));
		if (empty(polesLocaux))
		{ // Si pas de pole, on reste sur place
			set point_local <- location;
		} else if (length(polesLocaux) < 2)
		{ // Si un seul pole, on y va
			set point_local <- any_location_in(one_of(polesLocaux).shape inter reduced_worldextent);
			set deplacement_to <- one_of(polesLocaux).monAgregat != nil ? "pole local avec agregat" : "pole local sans agregat";
			
		} else
		{ // Si plus de 1 pole, lotterie ponderée
			Poles poleVainqueur <- (polesLocaux sort_by (each)) at rnd_choice((polesLocaux sort_by (each)) collect (each.attractivite));
			set point_local <- any_location_in(poleVainqueur.shape inter reduced_worldextent);
			set deplacement_to <- poleVainqueur.monAgregat != nil ? "pole local avec agregat plus attractif" : "pole local sans agregat plus attractif";
		}
		return (point_local);
	}

	point deplacement_lointain
	{
		point point_lointain <- nil;
		list<Poles> agregatsPolarisants <- Poles where (each.monAgregat != nil);
		// Uniquement les poles qui ne sont pas dans le rayon local
		//list<Poles> agregatsPolarisantsLointains <- agregatsPolarisants - (agregatsPolarisants at_distance rayon_migration_locale_fp_actuel);
		// remplacement du at_distance lent et buggé
		Foyers_Paysans moi <- self;
		list<Poles> agregatsPolarisantsLointains <- agregatsPolarisants - (agregatsPolarisants overlapping (rayon_migration_locale_fp around moi.location));
		if (empty(agregatsPolarisantsLointains))
		{ // Si pas de pole, on reste sur place
			set point_lointain <- location;
		} else if (length(agregatsPolarisantsLointains) < 2)
		{ // Si un seul pole, on y va
			Poles choixPole <- one_of(agregatsPolarisantsLointains);
			set monAgregat <- choixPole.monAgregat;
			set point_lointain <- any_location_in(monAgregat.shape inter reduced_worldextent);
			set deplacement_to <- "agregat lointain unique";
		} else
		{ // Si plus de 1 pole, lotterie ponderée
			Poles poleVainqueur <- (agregatsPolarisantsLointains sort_by (each)) at rnd_choice((agregatsPolarisantsLointains sort_by (each)) collect (each.attractivite));

			set point_lointain <- any_location_in(poleVainqueur.monAgregat.shape inter reduced_worldextent);
			set monAgregat <- poleVainqueur.monAgregat;
			set deplacement_to <- "agregat lointain attractif";
			}

		return (point_lointain);
	}

	aspect base
	{
		draw geometry:circle(10) color:#black;
	}

}