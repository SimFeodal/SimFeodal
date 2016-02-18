/**
 *  T8
 *  Author: Robin
 *  Description: Les agglomérations sont des agents "persistants", mais dont on vérifie l'existence à chaque pas de temps.
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
	
	string simName <- (machine_time/1000 + 2 #hours) as_date "%h%m%s";
	string folder_prefix <- "../outputs/";
	string file_suffix <- "_data" + simName + ".csv" ;
	string FP_file <- folder_prefix + "FP" + file_suffix;
	string Agregats_file <- folder_prefix + "Agregats" + file_suffix;
	string ZP_file <- folder_prefix + "ZP" + file_suffix;
	string Chateaux_file <- folder_prefix + "Chateaux" + file_suffix;
	string Seigneurs_file <- folder_prefix + "Seigneurs" + file_suffix;
	string Eglises_file <- folder_prefix + "Eglises" + file_suffix;
	string Paroisses_file <- folder_prefix + "Paroisses" + file_suffix;
	string Param_file <- folder_prefix + "Params" + file_suffix;
	
	action save_Parameters {
		if (!file_exists(Param_file)){
			save ["Année début simulation", "Année fin simulation", "Nombre de Foyers Paysans","Taux renouvellement",
				"Taux mobilité des FP",   "Nombre d'agglomérations secondaires antiques",
				"Nombre de villages",  "Nombre de Foyers Paysans par village (borne max)","Puissance Communautés",
				"Nombre grands seigneurs", "Nombre petits seigneurs","Puissance Grand Seigneur 1", 
				"Puissance Grand Seigneur 2", "Probabilité créer château GS", "Probabilité don château GS",
				 "Proba. gain droits haute justice sur château", 
				"Proba. gain droits banaux sur château","Proba. gain droits BM Justice sur château",
				"Probabilité créer château PS", "Proba. don droits sur ZP",
				"%FP payant un loyer (Petit Seigneur) - Borne Min", "%FP payant un loyer (Petit Seigneur) - Borne Max",
				"Rayon min Zone Prélevement - Petits Seigneurs", "Rayon max Zone Prélevement - Petits Seigneurs",
				 "Proba gain nouveaux droits banaux", "Proba gain nouveaux droits BM justice","Nombre visé de seigneurs en fin de simulation",
				 "Nombre d'églises", "Dont églises paroissiales", "Probabilité gain des droits paroissiaux", 
				 "Nombre max de paroissiens", "Nombre min de paroissiens"] to: Param_file type: "csv";
			save [debut_simulation, fin_simulation, nombre_foyers_paysans, taux_renouvellement, taux_mobilite,
				 nombre_agglos_antiques, nombre_villages, nombre_foyers_villages_max,
				puissance_communautes, nombre_grands_seigneurs, nombre_petits_seigneurs,
				puissance_grand_seigneur1, puissance_grand_seigneur2, proba_creer_chateau_GS, proba_don_chateau_GS,
				 proba_gain_droits_hauteJustice_chateau, proba_gain_droits_banaux_chateau,
				proba_gain_droits_basseMoyenneJustice_chateau, proba_creer_chateau_PS,
				proba_don_partie_ZP,  min_fourchette_loyers_PS, max_fourchette_loyers_PS, 
				rayon_min_PS, rayon_max_PS,proba_creation_ZP_banaux, proba_creation_ZP_basseMoyenneJustice,
				nombre_seigneurs_objectif, proba_collecter_loyer,
				nombre_eglises,nb_eglises_paroissiales, proba_gain_droits_paroissiaux,
				nb_max_paroissiens, nb_min_paroissiens] to: Param_file type: "csv";
		}
	}
	
	
	action save_FP {
		if (!file_exists(FP_file)){
			save ["Annee", "ID_FP", "Agregat", "X", "Y", "Satisfaction",
			"Smat", "Srel", "Sprot"] to: FP_file type: "csv";
		}
		ask Foyers_Paysans {
			save [Annee, self,monAgregat, int(location.x), int(location.y),
				Satisfaction with_precision 3, satisfaction_materielle with_precision 3,
				satisfaction_religieuse with_precision 3, satisfaction_protection with_precision 3]
				to: FP_file type: "csv";
		}
	}
	
	action save_Agregats {
		if (!file_exists(Agregats_file)){
			save ["Annee", "ID_Agregat","Geom", "Nb_FP"] to: Agregats_file type: "csv";
		}
		ask Agregats {
			save [Annee, self, shape.points, attractivite] to: Agregats_file type: "csv";
		}
	}
	
	action save_ZP {
		if (!file_exists(ZP_file)){
			save ["Annee", "ID_ZP","X", "Y", "ID_owner", "Type", "Rayon", "Taux"]
			to: ZP_file type: "csv";
		}
		ask Zones_Prelevement {
			save [Annee, self, int(location.x), int(location.y), proprietaire,
				type_droit, rayon_captation, taux_captation with_precision 3
			] to: ZP_file type: "csv";
		}
	}
	
	action save_Chateaux{
		if (!file_exists(Chateaux_file)){
			save ["Annee", "ID_Chateau","X", "Y", "ID_Owner", "ID_gardien", "ID_Agregat", "Rayon"]
			to: Chateaux_file type: "csv";
		}
		ask Chateaux {
			save [Annee, self, int(location.x), int(location.y), proprietaire, gardien, monAgregat, monRayon]
			to: Chateaux_file type: "csv";
		}
	}
	
	action save_Seigneurs {
		if (!file_exists(Seigneurs_file)){
			save ["Annee", "ID_Seigneur", "X", "Y", "type", "Puissance","Puissance_armee",
				"Loyer","HteJustice", "Banaux", "MBJustice","ID_Suzerain","Nb_FP"]
			to: Seigneurs_file type: "csv";	
		}
		ask Seigneurs {
			save [Annee, self, int(location.x), int(location.y), type, puissance with_precision 3, puissance_armee with_precision 3,
				droits_loyer, droits_hauteJustice, droits_banaux, droits_moyenneBasseJustice,
				monSuzerain, length(FP_assujettis)]
			to: Seigneurs_file type: "csv";
		}
	}
	
	action save_Eglises {
		if (!file_exists(Eglises_file)){
			save ["Annee", "ID_Eglise", "X", "Y", "Paroisse"]
			to: Eglises_file type: "csv";	
		}
		ask Eglises {
			save [Annee, self, int(location.x), int(location.y), eglise_paroissiale]
			to: Eglises_file type: "csv";	
		}
	}
	
	action save_Paroisses {
		if (!file_exists(Paroisses_file)){
			save ["Annee", "ID_Paroisse", "ID_Eglise", "Shape", "nbFideles", "Satisfaction"]
			to: Paroisses_file type: "csv";	
		}
		ask Paroisses {
			save [Annee, self, monEglise, shape.points, length(mesFideles), Satisfaction_Paroisse with_precision 3]
			to: Paroisses_file type: "csv";	
		}
	}
	
	action save_TMD {
		do save_simul_TMD;
		do save_seigneurs_TMD;
		do save_agregats_TMD;
	}
	
	action save_simul_TMD {
		if (!file_exists("../outputs/results_TMD_end.csv")){
			// FIXME  : Add params
			save [
			"Simulation", "Seed","Annee",
			"Nb_chateaux", "Nb_Agregats", "Nb_Paroisses",
			"Distance_entre_eglises", "Taux_FP_isoles", "Augm_charge_fisc",
			"Dist_ppv_agregat", "nb_chateaux_chatelains"
			] to: "../outputs/results_TMD.csv" type: "csv";
			save [
				simulation, seed, Annee,
				length(Chateaux), length(Agregats), Eglises count (each.eglise_paroissiale),
				distance_eglises, prop_FP_isoles*100, ratio_charge_fiscale,
				dist_ppv_agregat, Chateaux_chatelains
			] to: "../outputs/results_TMD.csv" type: "csv";
		}
		
	}
	
	action save_seigneurs_TMD {
		if (!file_exists("../outputs/results_TMD_seigneurs.csv")){
			save [
			"Simulation", "Seed", "Annee",
			"ID_Seigneur", "type","initial", "Puissance","Puissance_armee",
				"Loyer","HteJustice", "Banaux", "MBJustice",
				"ID_Suzerain","Nb_FP",
				"Nb_chateaux_garde", "Nb_chateaux_proprio",
				"Nb_vassaux"
				]
			to: "../outputs/results_TMD_seigneurs.csv" type: "csv";	
		}
		ask Seigneurs {
			save [
				simulation, seed, Annee, 
				self, type, initial, puissance with_precision 3, puissance_armee with_precision 3,
				droits_loyer, droits_hauteJustice, droits_banaux, droits_moyenneBasseJustice,
				monSuzerain, length(FP_assujettis),
				Chateaux count (each.gardien = self), Chateaux count (each.proprietaire = self),
				Seigneurs count (each.monSuzerain = self)
				]
			to: "../outputs/results_TMD_seigneurs.csv" type: "csv";
		}
	}
	
	action save_agregats_TMD {
		if (!file_exists("../outputs/results_TMD_agregats.csv")){
			save [
			"Simulation", "Seed", "Annee",
				 "ID_Agregat", "Nb_FP_contenus", "Nb_FP_attires"
			] to: "../outputs/results_TMD_agregats.csv" type: "csv";
		}
		ask Agregats {
			save [
				simulation, seed, Annee, 
			self, length(fp_agregat), nb_fp_attires
			] to: "../outputs/results_TMD_agregats.csv" type: "csv";
		}
	}
	
}	