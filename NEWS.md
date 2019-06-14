### SimFeodal 6.4.3 (2019-06-14) - 040c855

* On teste avec :
	- `nb_tirages_chateaux_gs` = 3 (produit entre 35 et 50 châteaux de GS)
	- `proba_construction_chateau_ps` dans \[0.4, 0.5, 0.6, 0.7, 0.8\] (0.8 produit \~10 châteaux de PS)

### SimFeodal 6.4.2 (2019-06-13) - ea2e37e

* Modification construction château :
	- PS : idem 6.4.1
	- GS : paramètre `nb_tirages_chateaux_gs`, puis `loop times: nb_tirages {if (espace_dispo_chateaux != nil and flip(proba_creer_chateau)) [...construction...]}`
	- Paramètre `proba_construction_chateau_ps` changé à 0.8


### SimFeodal 6.4.1 (2019-05-31) - 2e3581c

* Modification construction château :
	- GS : `puissance/Sum(puissance_GS) * rnd(min = nb_max_chateaux_par_tour_gs, max = nb_max_chateaux_par_tour_gs+1, step = 1)`
	- PS : `proba_chateau_PS` (\~0.7) + lotterie pondéré (`puissance`) parmi les PS pour savoir qui le construit

## SimFeodal 6.4.0 (2019-05-26) - 0b3fc3f

* Ajout du mécanisme de construction de châteaux `construction_chateau_alternate` : logique de `puissance_i/ Sum(puissance_ i+1)`


## SimFeodal 6.3.0 (2019-05-12) - 88860b5

* Renommage de paramètres et nouvelles valeurs par défaut
* On bloque le nouveau mécanisme de construction de châteaux (\*1.25\*2 et \*7)
* Correction calcul `s_religieuse`
* Ajout outputs pour les seigneurs
* Ajout des scénarios principaux : PopGrowth vs PopInit
* Ajout des scénarios "Objectif50k"

## SimFeodal 6.2.0 (2019-03-07) - e377f0b

* Test et calibrage de `nb_requis_paroissiens_insatisfaits`
* Ajout params nb max châteaux par tour
* Test `seuil_creation_paroisse`

## SimFeodal 6.1.0 (2019-01-09) - 2891f35

* Simplification du modèle (seigneurs, châteaux)
* Optimisation requêtes spatiales (`at_distance` remplacées par `inside (self.shape + distance)`)
* Ajout calcul espace disponible construction chateau (proba * 1.25 / 2 tirages GS + proba * 7 / 1 tirage PS)
* Nouvelle règle création châteaux
* Ajout châteaux dans les outputs
* Renommage de paramètres

# SimFeodal 6.0.0 (2019-01-09) - 397bcba

* Optimisation performances modèle
* Renommage des paramètres
* Paramétrage de valeurs en brut
* Modification de valeurs de paramètres