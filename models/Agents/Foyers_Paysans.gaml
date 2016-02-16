/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */
model t8

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
		int attractivite_totale <- length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		int nb_FP_impactes <- int(taux_renouvellement * length(Foyers_Paysans));
		ask nb_FP_impactes among Foyers_Paysans
		{
			if (monAgregat != nil)
			{
				ask monAgregat
				{
					fp_agregat >- myself;
				}

			}

			do die;
		}

		create Agregats number: 1
		{
			set fake_agregat <- true;
			set attractivite <- attractivite_totale - sum(Agregats collect each.attractivite);
		}

		create Foyers_Paysans number: nb_FP_impactes
		{
			int attractivite_cagnotte <- attractivite_totale;
			point FPlocation <- nil;
			loop agregat over: shuffle(Agregats)
			{
				if (agregat.attractivite >= attractivite_cagnotte)
				{
					if (length(agregat.fp_agregat) > 0)
					{
						set FPlocation <- any_location_in(distance_detection_agregats around one_of(agregat.fp_agregat).location);
					} else
					{
						set FPlocation <- any_location_in(worldextent);
					}

					break;
				} else
				{
					set attractivite_cagnotte <- attractivite_cagnotte - agregat.attractivite;
				}

			}

			set location <- FPlocation;
			set mobile <- flip(taux_mobilite);
		}

		ask Agregats where each.fake_agregat
		{
			do die;
		}

	}

}

entities
{
	species Foyers_Paysans schedules: shuffle(Foyers_Paysans)
	{
		bool communaute <- false;
		Agregats monAgregat <- nil;
		float satisfaction_materielle;
		float satisfaction_religieuse;
		float satisfaction_protection;
		float Satisfaction;
		bool mobile; // Si true : ce FP peut se déplacer / si false, serf/esclave, pas de déplacement
		Seigneurs seigneur_loyer <- nil;
		Seigneurs seigneur_hauteJustice <- nil;
		list<Seigneurs> seigneurs_banaux <- [];
		list<Seigneurs> seigneurs_basseMoyenneJustice <- [];
		int nb_preleveurs <- 0;
		action reset_preleveurs
		{
			set seigneur_loyer <- nil;
			set seigneur_hauteJustice <- nil;
			set seigneurs_banaux <- [];
			set seigneurs_basseMoyenneJustice <- [];
		}

		action update_satisfaction_materielle
		{
			int loyer <- (self.seigneur_loyer != nil) ? 1 : 0;
			int hauteJustice <- (self.seigneur_hauteJustice != nil) ? 1 : 0;
			int banaux <- length(self.seigneurs_banaux);
			int basseMoyenneJustice <- length(self.seigneurs_basseMoyenneJustice);
			int nb_seigneurs <- loyer + hauteJustice + banaux + basseMoyenneJustice;
			set nb_preleveurs <- nb_seigneurs;
			float S_redevances <- max([1 - (nb_seigneurs * (1 / 15)), 0.0]);
			float S_contributions <- 0.0;
			if (self.monAgregat = nil)
			{
				set S_contributions <- 0.0;
			} else
			{
				set S_contributions <- (self.communaute ? puissance_communautes : 0);
			}

			float Satisfaction_materielle <- (S_redevances) ^ (1 - S_contributions);
			set satisfaction_materielle <- Satisfaction_materielle;
		}

		action update_satisfaction_religieuse
		{
		//float distance_eglise <- self distance_to eglise_paroissiale_proche;
			list<Eglises> eglises_paroissiales <- (Eglises where (each.eglise_paroissiale));
			float distance_eglise <- min(eglises_paroissiales collect (each distance_to self)); // self distance_to eglise_paroissiale_proche;
			int seuil1 <- 0;
			int seuil2 <- 0;
			if (Annee < 950)
			{
				set seuil1 <- 5000;
				set seuil2 <- 25000;
			} else if (Annee < 1050)
			{
				set seuil1 <- 3000;
				set seuil2 <- 10000;
			} else
			{
				set seuil1 <- 1500;
				set seuil2 <- 5000;
			}

			set satisfaction_religieuse <- max([0.0, min([1.0, -(distance_eglise / (seuil2 - seuil1)) + (seuil2 / (seuil2 - seuil1))])]);
		}

		action update_satisfaction_protection
		{
			Chateaux plusProcheChateau <- Chateaux with_min_of (self distance_to each);
			float satisfaction_distance;
			float satisfaction_puissance;
			// FIXME : Trop lent, à recoder (peut-être depuis point de vue chateau)
			if (plusProcheChateau = nil)
			{
				set satisfaction_distance <- 0.0;
				set satisfaction_puissance <- 0.0;
			} else
			{
				int seuil1 <- 1500;
				int seuil2 <- 5000;
				float distance_chateau <- plusProcheChateau distance_to self;
				set satisfaction_distance <- max([0.0, min([1.0, -(distance_chateau / (seuil2 - seuil1)) + (seuil2 / (seuil2 - seuil1))])]); // [0 -> 1]
				set satisfaction_puissance <- min([1, plusProcheChateau.proprietaire.puissance_armee / seuil_puissance_armee]);
			}

			set satisfaction_protection <- ((satisfaction_puissance + satisfaction_distance) / 2) ^ (besoin_protection);
			//TODO : MaJ Doc (descript. + paramètres)

		}

		action update_satisfaction
		{
			do update_satisfaction_materielle;
			do update_satisfaction_religieuse;
			do update_satisfaction_protection;

			// FIXME : MaJ Doc pour satisf.
			set Satisfaction <- min([satisfaction_religieuse, satisfaction_protection, satisfaction_materielle]);
		}

		action deplacement
		{
			set location <- flip(1 - Satisfaction) ? (flip(0.8) ? deplacement_local() : deplacement_lointain()) : location;
		}

		point deplacement_local
		{
			point point_local;
			list<Poles> polesLocaux <- Poles at_distance distance_max_dem_local;
			if (empty(polesLocaux))
			{ // Si pas de pole, on reste sur place
				set point_local <- location;
			} else if (length(polesLocaux) < 2)
			{ // Si un seul pole, on y va
				set point_local <- any_location_in(one_of(polesLocaux).shape);
				// TODO : Changer nom variable
				set nb_demenagement_local <- nb_demenagement_local + 1;
			} else
			{ // Si plus de 1 pole, lotterie ponderée
				Poles poleVainqueur <- (polesLocaux sort_by (each)) at rnd_choice((polesLocaux sort_by (each)) collect (each.attractivite));
				set point_local <- any_location_in(poleVainqueur.shape);
				set nb_demenagement_local <- nb_demenagement_local + 1;
			}

			return (point_local);
		}

		point deplacement_lointain
		{
			point point_lointain;
			list<Poles> agregatsPolarisants <- Poles where (each.monAgregat != nil);
			// Uniquement les poles qui ne sont pas dans le rayon local
			list<Poles> agregatsPolarisantsLointains <- agregatsPolarisants - (agregatsPolarisants at_distance distance_max_dem_local);
			if (empty(agregatsPolarisantsLointains))
			{ // Si pas de pole, on reste sur place
				set point_lointain <- location;
			} else if (length(agregatsPolarisantsLointains) < 2)
			{ // Si un seul pole, on y va
				Poles choixPole <- one_of(agregatsPolarisantsLointains);
				ask choixPole.monAgregat
				{
					set nb_fp_attires <- nb_fp_attires + 1;
				}

				set point_lointain <- any_location_in(choixPole.shape);
				// TODO : Changer nom variable
				set nb_demenagement_lointain <- nb_demenagement_lointain + 1;
			} else
			{ // Si plus de 1 pole, lotterie ponderée
				Poles poleVainqueur <- (agregatsPolarisantsLointains sort_by (each)) at rnd_choice((agregatsPolarisantsLointains sort_by (each)) collect (each.attractivite));
				ask poleVainqueur.monAgregat
				{
					set nb_fp_attires <- nb_fp_attires + 1;
				}

				set point_lointain <- any_location_in(poleVainqueur.monAgregat);
				set nb_demenagement_lointain <- nb_demenagement_lointain + 1;
			}

			return (point_lointain);
		}

		// FIXME : Useless
		//		point demenagement_local {
		//			int rayon_local <- distance_max_dem_local ;
		//			list<Eglises> eglises_proches <- Eglises where (each.reel) at_distance rayon_local;
		//			list<Chateaux> chateaux_proches <- Chateaux where (each.reel) at_distance rayon_local;
		//			list<Agregats> agregats_proches <- Agregats where (each.reel) at_distance rayon_local;
		//			
		//			list<agent> attracteurs_proches <- (agents of_generic_species Attracteurs) where (each.reel) at_distance rayon_local;
		//			list<Attracteurs> attracteurs_proches <- agents_at_distance(rayon_local) of_generic_species Attracteurs where (each.reel) ;
		//			// TODO : report bug : the first one doens't work, the second does
		//			// probably because Agregats is a shape while others are points
		//			// at_distance may not work in this situation
		//			}
		rgb color <- # gray;
		aspect base
		{
			draw circle(500) color: color;
		}

	}

}