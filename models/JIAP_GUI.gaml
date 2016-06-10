/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 */

model t8

// L'ordre compte...
import "run.gaml"



experiment JIAP_base type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [400];
}



experiment JIAP_paroissiens type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){ // OK
	parameter 'myName' var: myName among: ["JIAP_paroissiens"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [75];
}



experiment JIAP_gros_chateaux type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){ // OK
	parameter 'myName' var: myName among: ["JIAP_gros_chateaux"];
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [400];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.75];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.25];
}

experiment JIAP_dist_dem_local type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){ // OK
	parameter 'myName' var: myName among: ["JIAP_dist_dem_local"];
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [400];
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [5000];
}

experiment JIAP_attrac_poles type: batch repeat:5 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_attrac_poles"];
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [400];	
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.35];
	parameter "attrac_PC" var: attrac_PC among: [0.05];	
}
 
experiment JIAP_base2 type: batch repeat:10 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base2"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [200];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [10];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [5000]; // DIFF
	
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.35];
	parameter "attrac_PC" var: attrac_PC among: [0.05];	
}

experiment JIAP_base2_compo5_2 type: batch repeat:5 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base2_compo5_2"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [200];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [10];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];

	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.35];
	parameter "attrac_PC" var: attrac_PC among: [0.05];	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [2500]; // Fusion JIAP_base2_compo5_2 et JIAP_base2_compo5_2bis
}

experiment JIAP_base2_compo5_2bis type: batch repeat:10 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base2_compo5_2bis"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [200];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [10];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];

	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.35];
	parameter "attrac_PC" var: attrac_PC among: [0.05];	
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [5000]; // Fusion JIAP_base2_compo5_2 et JIAP_base2_compo5_2bis
}

experiment JIAP_base2_compo5_2ter type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base2_compo5_2ter"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [200];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [10];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];
	
	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [2500];
	
	parameter "nb_chateaux_potentiels_GS" var: nb_chateaux_potentiels_GS among: [3];
	parameter "communautes_attractives" var: communautes_attractives among:[true];
	parameter "attrac_communautes" var:attrac_communautes among: [0.10];	
	parameter "deplacement_alternate" var: deplacement_alternate among: [true];
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.10];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.35];
	parameter "attrac_PC" var: attrac_PC among: [0.10];	
}

experiment JIAP_base2_compo5_2_5 type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base2_compo5_2_5"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [200];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [10];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];
	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [2500];
	parameter "nb_chateaux_potentiels_GS" var: nb_chateaux_potentiels_GS among: [3];
	parameter "communautes_attractives" var: communautes_attractives among:[true];
	parameter "attrac_communautes" var:attrac_communautes among: [0.10];	
	parameter "deplacement_alternate" var: deplacement_alternate among: [true];
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.10];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.35];
	parameter "attrac_PC" var: attrac_PC among: [0.10];	

}

experiment JIAP_base2_compo5_2_6 type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base2_compo5_2_6"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [300];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [20];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];
	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "nb_chateaux_potentiels_GS" var: nb_chateaux_potentiels_GS among: [2];
	parameter "communautes_attractives" var: communautes_attractives among:[true];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "deplacement_alternate" var: deplacement_alternate among: [true];
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];	

}

experiment "JIAP_base3_1" type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base3_1"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [300];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [20];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];
	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "nb_chateaux_potentiels_GS" var: nb_chateaux_potentiels_GS among: [2];
	parameter "communautes_attractives" var: communautes_attractives among:[true];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "deplacement_alternate" var: deplacement_alternate among: [true];
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];	
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [true];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
}

experiment "JIAP_base3_2" type: batch repeat:30 multicore: true until: (Annee >= fin_simulation){
	parameter 'myName' var: myName among: ["JIAP_base3_2"];
	
	parameter 'ratio_paroissiens_agregats' var: ratio_paroissiens_agregats among: [300];
	parameter 'nb_paroissiens_mecontents_necessaires' var: nb_paroissiens_mecontents_necessaires among: [20];
	parameter "proba_promotion_groschateau_multipole" var: proba_promotion_groschateau_multipole among: [0.8];
	parameter "proba_promotion_groschateau_autre"  var: proba_promotion_groschateau_autre among: [0.3];
	parameter "chateaux_GS_alternate" var: chateaux_GS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_GS" var: puissance_necessaire_creation_chateau_GS among: [1000];
	parameter "chateaux_PS_alternate" var: chateaux_PS_alternate among: [true];
	parameter "puissance_necessaire_creation_chateau_PS" var: puissance_necessaire_creation_chateau_PS among: [0];
	parameter "puissance_armee_FP_alternate" var: puissance_armee_FP_alternate among: [true];
	parameter "distance_max_dem_local" var: distance_max_dem_local among: [4000];
	parameter "nb_chateaux_potentiels_GS" var: nb_chateaux_potentiels_GS among: [2];
	parameter "communautes_attractives" var: communautes_attractives among:[true];
	parameter "attrac_communautes" var:attrac_communautes among: [0.1];	
	parameter "deplacement_alternate" var: deplacement_alternate among: [true];
	
	parameter "attrac_0_eglises" var: attrac_0_eglises among: [0.0];
	parameter "attrac_1_eglises" var: attrac_1_eglises among: [0.05];
	parameter "attrac_2_eglises" var: attrac_2_eglises among: [0.25];
	parameter "attrac_3_eglises" var: attrac_3_eglises among: [0.55];
	parameter "attrac_4_eglises" var: attrac_4_eglises among: [0.65];
	parameter "attrac_GC" var: attrac_GC among: [0.15];
	parameter "attrac_PC" var: attrac_PC among: [0.1];
	
	parameter "agregats_alternate" var: agregats_alternate category: "Seigneurs" among: [true];
	parameter "poles_alternate" var: poles_alternate category: "Seigneurs" among: [true];
	parameter "agregats_alternate2" var: agregats_alternate2 among: [true];
	parameter "recompute_agregats_at_end" var: recompute_agregats_at_end among: [true];
}