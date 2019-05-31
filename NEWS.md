### SimFeodal 6.4.1 (2019-05-31) - 2e3581c3ecaded90abf181ee4ad1f1e1df0b4dd1

* Modification construction château :
	- GS : `puissance/Sum(puissance_GS) * rnd(min = nb_max_chateaux_par_tour_gs, max = nb_max_chateaux_par_tour_gs+1, step = 1)`
	- PS : `proba_chateau_PS` (\~0.7) + lotterie pondéré (`puissance`) parmi les PS pour savoir qui le construit

## SimFeodal 6.4.0 (2019-05-26) - 0b3fc3f0a84fa60ae942173600142819bf90b940

* Ajout du mécanisme de construction de châteaux `construction_chateau_alternate` : logique de `puissance_i/ Sum(puissance_ i+1)`


## SimFeodal 6.3.0 (2019-05-12) - 88860b55140b6b03cca80d9fdcd2a1852bb08f93

* Renommage de paramètres et nouvelles valeurs par défaut
* On bloque le nouveau mécanisme de construction de châteaux (\*1.25\*2 et \*7)
* Correction calcul `s_religieuse`
* Ajout outputs pour les seigneurs
* Ajout des scénarios principaux : PopGrowth vs PopInit
* Ajout des scénarios "Objectif50k"

## SimFeodal 6.2.0 (2019-03-07) - e377f0b2016592e50b54259af5360345f7a7eeac

* Test et calibrage de `nb_requis_paroissiens_insatisfaits`
* Ajout params nb max châteaux par tour
* Test `seuil_creation_paroisse`

## SimFeodal 6.1.0 (2019-01-09) - 2891f352a91853817bc72cfcb41bbca8d0300464

* Simplification du modèle (seigneurs, châteaux)
* Optimisation requêtes spatiales (`at_distance` remplacées par `inside (self.shape + distance)`)
* Ajout calcul espace disponible construction chateau (proba * 1.25 / 2 tirages GS + proba * 7 / 1 tirage PS)
* Nouvelle règle création châteaux
* Ajout châteaux dans les outputs
* Renommage de paramètres

# SimFeodal 6.0.0 (2019-01-09) - 397bcba4a8fc59f946d8e38c39769f3074e8682d

* Optimisation performances modèle
* Renommage des paramètres
* Paramétrage de valeurs en brut
* Modification de valeurs de paramètres