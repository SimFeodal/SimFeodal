/**
 *  T8
 *  Author: Robin
 */

model t8

import "init.gaml"
import "global.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"

global {
	
	string enquote (unknown text) {
		return '"' + string(text) + '"';
	}
	
	
	action save_outputs_data {
		string currentPrefix <- prefix_output;
		if (annee = 820) {do save_parameters(currentPrefix);}
		do save_global(currentPrefix);
		do save_seigneurs(currentPrefix);
		do save_agregats(currentPrefix);
		do save_poles(currentPrefix);
		do save_paroisses(currentPrefix);
		do save_chateaux(currentPrefix);
		do save_FP(currentPrefix);
	}
	
	action save_summarised_data {
		string currentPrefix <- prefix_output;
		if (annee = 820) {do save_parameters(currentPrefix);}
		do save_global(currentPrefix);
		do save_seigneurs(currentPrefix);
	}
	
	action save_parameters(string sim_name) {
		string seed <- string(seed);
		string besoin_protection_fp <- world.enquote(besoin_protection_fp);
		string proba_gain_haute_justice_gs <- world.enquote(proba_gain_haute_justice_gs);
		string proba_gain_haute_justice_chateau_ps <- world.enquote(proba_gain_haute_justice_chateau_ps);
		string periode_promotion_chateaux <- world.enquote(periode_promotion_chateaux);
		string dist_min_eglise <- world.enquote(dist_min_eglise);
		string dist_max_eglise <- world.enquote(dist_max_eglise);
		string rayon_migration_locale_fp <- world.enquote(rayon_migration_locale_fp);
		string puissance_communautes <- world.enquote(puissance_communautes);
		
		save [
				seed, sim_name,
				////////////
				// Inputs //
				////////////
				// Espace du modèle
				taille_cote_monde,
				// FP
				init_nb_total_fp, //avant v6 : nombre_foyers_paysans
				// Agrégats
				init_nb_agglos, // avant v6 : anciennement nombre_agglos_antiques
				init_nb_fp_agglo, // avant v6 : nouveau paramètre en v6 : vallait 30
				init_nb_villages, // avant v6 : anciennement nombre_villages
				init_nb_fp_village, // avant v6 : nombre_FP_village
				// Seigneurs
				init_nb_gs, // avant v6 : nombre_grands_seigneurs
				puissance_grand_seigneur1, puissance_grand_seigneur2,
				init_nb_ps, // avant v6 : nombre_petits_seigneurs
				// Eglises
				init_nb_eglises, // avant v6 nombre_eglises
				init_nb_eglises_paroissiales, // avant v6 : nb_eglises_paroissiales
				////////////////////////////
				// Paramètres de contexte //
				////////////////////////////
				// FP
				croissance_demo, // avant v6 : taux_augmentation_FP
				taux_renouvellement_fp, // avant v6 : taux_renouvellement
				proba_fp_dependant, // avant v6 : proba_FP_dependants
				besoin_protection_fp, // nouveau paramètre en v6 : vallait [800::0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0] avant		
				// Agrégats
				puissance_communautes, // Changement de type: de float (0.25) à time-dependant : [800::0.2,1060::0.3,1100::0.4,1160::0.5]
				proba_institution_communaute,
				coef_redevances,
				// Seigneurs
				objectif_nombre_seigneurs, // avant v6 :  nombre_seigneurs_objectif
				proba_gain_haute_justice_gs, // nouveau paramètre en v6 : vallait [800::0,900::0.1,1000::1.0] avant
				debut_cession_droits_seigneurs, // TODO: nouveau paramètre en v6 : vallait 900 avant
				debut_garde_chateaux_seigneurs, // TODO: nouveau paramètre en v6 : vallait 950 avant
				// Chateaux
				debut_construction_chateaux, // avant v6 : apparition_chateaux
				periode_promotion_chateaux, // nouveau paramètre en v6 : vallait [800::false,960::true,1060::false] avant
				/////////////////////////////
				// Paramètres de mécanisme //
				/////////////////////////////
				// FP
				dist_min_eglise, // TODO : nouveau paramètre en v6 : vallait [800::5000,960::3000,1060::1500] avant
				dist_max_eglise, // TODO : nouveau paramètre en v6 : vallait [800::25000,960::10000,1060::5000] avant
				dist_min_chateau, // TODO : nouveau paramètre en v6 : vallait 1500 avant
				dist_max_chateau, // TODO : nouveau paramètre en v6 : vallait 5000 avant
				min_s_distance_chateau, // TODO : nouveau paramètre en v6 : vallait 0.0 avant
				rayon_migration_locale_fp, // TODO : avant v6 : seuils_max_dem_local_st
				prop_migration_lointaine_fp, // TODO : avant v6 : proba_ponderee_deplacement_lointain
				// Agregats
				nb_min_fp_agregat, // TODO : avant v6 : nombre_FP_agregat
				distance_detection_agregat, // TODO : avant v6 : distance_detection_agregats
				distance_fusion_agregat, // TODO : nouveau paramètre en v6 : vallait 100 avant
				// Seigneurs
				proba_collecter_loyer_ps,
				proba_creation_zp_autres_droits_ps, // avant v6 : calcul différent, vallait ~ 5% + 5%
				rayon_min_zp_ps, // TODO : avant v6 : rayon_min_PS
				rayon_max_zp_ps, // TODO : avant v6 : rayon_max_PS
				min_taux_prelevement_zp_ps, // TODO : avant v6 : min_fourchette_loyers_PS
				max_taux_prelevement_zp_ps, // TODO : avant v6 : max_fourchette_loyers_PS
				proba_cession_droits_zp, // TODO : avant v6 : proba_don_partie_ZP
				rayon_cession_locale_droits_ps, // TODO : nouveau paramètre en v6 : vallait 3000 avant
				proba_don_chateau, // TODO : avant v6 : proba_don_chateau_GS
				proba_gain_haute_justice_chateau_ps, // TODO : avant v6 : proba_gain_droits_hauteJustice_chateau

				// FIXME : A reprendre
				droits_haute_justice_zp, // TODO : nouveau paramètre en v6 : vallait 1 avant
				droits_haute_justice_zp_cession, // TODO : nouveau paramètre en v6 : vallait 1.25 avant
				droits_fonciers_zp, // TODO : nouveau paramètre en v6 : vallait 1 avant
				droits_fonciers_zp_cession, // Nouveau paramètre en v6.1 : vallait 0 avant
				autres_droits_zp, // TODO : nouveau paramètre en v6 : vallait 0.25 avant
				autres_droits_zp_cession, // TODO : nouveau paramètre en v6 : vallait 0.35 avant
				
				// Chateaux
				rayon_min_zp_chateau, // TODO : nouveau paramètre en v6, vallait 2000 avant
				rayon_max_zp_chateau, // TODO : nouveau paramètre en v6, vallait 10000 avant
				dist_min_entre_chateaux,  // TODO : nouveau paramètre en v6, vallait 3000 ou 5000 avant (PS ou GS)
				proba_chateau_gs_agregat, // TODO : avant v6 : proba_chateau_agregat
				proba_promotion_chateau_pole, // TODO : avant v6 : proba_promotion_groschateau_multipole
				proba_promotion_chateau_isole, // TODO : avant v6 : proba_promotion_groschateau_autre
				// Eglises paroissiales
				seuil_creation_paroisse,
				nb_requis_paroissiens_insatisfaits,
				// Poles d'attraction
				attractivite_petit_chateau, // TODO : avant v6 : attrac_PC
				attractivite_gros_chateau, // TODO : avant v6 : attrac_GC
				attractivite_1_eglise, // TODO : avant v6 : attrac_1_eglises
				attractivite_2_eglise, // TODO : avant v6 : attrac_2_eglises
				attractivite_3_eglise, // TODO : avant v6 : attrac_3_eglises
				attractivite_4_eglise, // TODO : avant v6 : attrac_4_eglises
				attractivite_communaute // TODO : avant v6 : attrac_communautes
				
			] to: (output_folder_path + sim_name +"_parameters.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_global(string sim_name) {
		int nb_chateaux <- length(Chateaux);
		int nb_grands_chateaux <- Chateaux count (each.type = "Grand Chateau");
		int nb_eglises <- length(Eglises);
		int nb_eglises_paroissiales <-  Eglises count (each.eglise_paroissiale);
		int nb_agregats <- length(Agregats);
		int nb_fp <- length(Foyers_Paysans);
		
		string seed <- world.enquote(seed);
		
		save [
				seed, sim_name, annee,
				nb_fp, nb_agregats,
				nb_chateaux, nb_grands_chateaux,
				nb_eglises, nb_eglises_paroissiales,
				distance_eglises, distance_eglises_paroissiales,
				prop_fp_isoles, charge_fiscale, dist_ppv_agregat,
				total_duration
				
			] to: (output_folder_path + sim_name +"_results_global.csv") type: "csv" header: true rewrite: false;
	}
	
	action save_seigneurs(string sim_name) {
		string seed <- world.enquote(seed);
		
		ask Seigneurs {
			int id_seigneur <- int(replace(self.name, 'Seigneurs', ''));
			int nbChateauxProprio <- Chateaux count (each.proprietaire = self);
			int nbChateauxGardien <- Chateaux count (each.gardien = self);
			int nbFPassujettis <- length(FP_assujettis);
			int nbVassaux <- Seigneurs count (each.monSuzerain = self);
			int nbDebiteurs <- length(mesDebiteurs);
			string geom <- world.enquote(location with_precision 2);

			save [
				seed, sim_name,annee,id_seigneur, 
				type, initial, puissance,
				nbChateauxProprio, nbChateauxGardien,
				nbFPassujettis, nbVassaux, nbDebiteurs, monAgregat, geom
				]
			to: (output_folder_path + sim_name +"_results_seigneurs.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_agregats(string sim_name) {
		string seed <- enquote(seed);
		
		ask Agregats {
			int nombre_fp_agregat <- length(fp_agregat);
			float superficie <- shape.area;
			string geom <- world.enquote(shape with_precision 2);
			int id_agregat <- int(replace(self.name, 'Agregats', ''));
			int monpole <- (monPole != nil) ? int(replace(monPole.name, 'Poles', '')) : -1;
			
			save [
				seed, sim_name, annee, id_agregat,
				nombre_fp_agregat, superficie, communaute, monpole, geom
			] to: (output_folder_path + sim_name +"_results_agregats.csv") type: "csv" header: true rewrite: false;
		}
	}
	
	action save_poles(string sim_name) {
		string seed <- world.enquote(seed);
		
		ask Poles {
			int nbAttracteurs <- length(mesAttracteurs);
			int nbEglises <- length(mesAttracteurs of_species Eglises);
			int nbParoisses <- (mesAttracteurs of_species Eglises) count (each.eglise_paroissiale);
			int nbGC <- (mesAttracteurs of_species Chateaux) count (each.type = "Grand Chateau");
			int nbPC <- (mesAttracteurs of_species Chateaux) count (each.type = "Petit Chateau");
			int nbCA <- length(mesAttracteurs of_species Agregats);
			string geom <- world.enquote(shape with_precision 2);
			int id_pole <- int(replace(self.name, 'Poles', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
				
			save [
				seed, sim_name, annee, id_pole,
				attractivite, nbAttracteurs, monagregat,
				nbEglises, nbParoisses, nbGC, nbPC, nbCA, geom
				
			] to: (output_folder_path + sim_name +"_results_poles.csv") type: "csv" header: true rewrite: false;
		}
		
	}
	
	action save_FP(string sim_name) {
		string seed <- enquote(seed);
		
		ask Foyers_Paysans {
			float satisfaction <- satisfaction with_precision 2;
			string geom <- world.enquote(shape with_precision 2);
			int id_fp <- int(replace(self.name, 'Foyers_Paysans', ''));
			int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
			
			save [
				seed, sim_name, annee, id_fp,
				appartenance_communaute, monagregat,
				s_materielle, s_religieuse, s_protection,
				satisfaction, mobile, type_deplacement,
				deplacement_from, deplacement_to,
				redevances_acquittees, geom
			] to: (output_folder_path + sim_name +"_results_FP.csv") type: "csv" header: true rewrite: false;
		}

	}
	
		action save_paroisses(string sim_name) {
			string seed <- world.enquote(seed);
			
			ask  Paroisses {
				int nbFideles <- length(mesFideles);
				float SatisfactionParoisse <- Satisfaction_Paroisse with_precision 3;
				string geom <- world.enquote(shape with_precision 2);
				int id_paroisse <- int(replace(self.name, 'Paroisses', ''));
				int moneglise <- (monEglise != nil) ? int(replace(monEglise.name, 'Eglises', '')) : -1;

				save [
					seed, sim_name, annee, id_paroisse,
					moneglise, mode_promotion, shape.area,
					nbFideles, nb_paroissiens_insatisfaits, SatisfactionParoisse, geom
				] to: (output_folder_path + sim_name +"_results_paroisses.csv") type: "csv" header: true rewrite: false;
			}
		}
		
			action save_chateaux(string sim_name) {
			string seed <- world.enquote(seed);
			
			ask  Chateaux {
				string geom <- world.enquote(shape with_precision 2);
				int id_chateau <- int(replace(self.name, 'Chateaux', ''));
				int monagregat <- (monAgregat != nil) ? int(replace(monAgregat.name, 'Agregats', '')) : -1;
				int monproprietaire <- (proprietaire != nil) ? int(replace(proprietaire.name, 'Seigneurs', '')) : -1;
				string monproprietaire_type <- proprietaire.type;
				int mongardien <- (gardien != nil) ? int(replace(gardien.name, 'Seigneurs', '')) : -1;

				save [
					seed, sim_name, annee, id_chateau,
					type, rayon_zp_chateau, attractivite, droits_haute_justice,
					monagregat, monproprietaire, monproprietaire_type, mongardien,
					geom
				] to: (output_folder_path + sim_name +"_results_chateaux.csv") type: "csv" header: true rewrite: false;
				}
			}
}	