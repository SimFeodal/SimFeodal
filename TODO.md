TODO
--------------------

 1. Modifications mineures
-------------------------------------------------------------
- [x] Renommer Puissance -> Richesse
- [x] Renommer Agglomérations -> Agrégats
- [x] Modification règle FP devient chevalier
- [ ] Modification attribution seigneurs aux FP (4 max dont 1 grand max)
- [ ] Paramètre de puissance des Communautés Agraires
- [x] Nombre seigneurs à la fin (~ 200)


2. Ajouts mineurs
-------------------------------------------------------------
- [ ] Dons châteaux
- [ ] Ajouter gestions des droits
	- [ ] Droits de haute justice
	- [ ] Droits banaux
	- [ ] Droits d'usage
- [ ] Règles satisfactions à reprendre
	- [ ] Satisfaction protection (selon temps)
	- [ ] Satisfaction matérielle
	- [ ] Satisfaction religieuse

3. Ajouts majeurs
-------------------------------------------------------------
- [ ] Différenciation des Seigneurs
	- [ ] Règles communes
	- [ ] Grands seigneurs
	- [ ] Seigneurs châtelains
	- [ ] Petits Seigneurs
- [ ] Apparition / Disparition des églises
	- [ ] Gain de droits
	- [ ] Disparition
	- [ ] Création
		- [ ] Selon potentiel Voronoï
- [ ] Mettre en place les fonctions dans les agrégats


4. A éclaircir :

Chaque FP a 4 seigneurs (NB: Ça peut être 4 fois le même...):
- Un seigneur qui collecte son loyer
- Un seigneur qui collecte ses droits de haute justice
- Un seigneur qui collecte ses droits banaux
- Un seigneur qui collecte ses droits de basse et moyenne justice


- Loyer : 
	-> Si petit seigneur dans rayon n {
		si tirage > proba {
			ce seigneur devient seigneur_loyer
		} sinon {
			un grand seigneur est tiré au hasard pour devenir seigneur_loyer
		}
	} sinon {
		un grand seigneur est tiré au hasard pour devenir seigneur_loyer
	}

- Haute Justice : 
	-> Forcément un grand seigneur (aléatoire) au début
	-> Ce Grand Seigneur peut céder son droit à un Petit Seigneur/Châtelain

- Banaux : Idem 


Qui fait attribution seigneurs ?