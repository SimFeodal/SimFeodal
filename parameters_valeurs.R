library(tidyverse)
library(glue)
# sensib_params <- tibble(
#   param = character(),
#   type = character(),
#   valeur = character()
# )

distance_detection_agregats <- seq(from = 50, to = 300, length.out = 10) %>%
                                    round() %>%
                                    as.integer()
  

nombre_FP_agregat <- seq(from = 3, to = 25) %>%
  round() %>%
  as.integer()

nombre_agglos_antiques <- seq(from = 0, to = 20) %>%
  round() %>%
  as.integer()

nombre_villages <- seq(from = 5, to = 100, by = 5) %>%
  round() %>%
  as.integer()

nombre_FP_village <- seq(from = 5, to = 25) %>%
  round() %>%
  as.integer()

puissance_communautes <- seq(from = 0, to = 1, by = .05)

apparition_communautes <- seq(from = 800, to = 1100, by = 20) %>%
  round() %>%
  as.integer()

proba_apparition_communaute <- seq(from = 0, to = 1, by = .05)

nombre_foyers_paysans <- seq(from = 1000, to = 10000, by = 500) %>%
  round() %>%
  as.integer()

taux_renouvellement <- seq(from = 0, to = 1, by = .05)

taux_augmentation_FP <- seq(from = 0, to = 0.05, length.out = 20)

taux_mobilite <- seq(from = 0, to = 1, by = .05)

distance_max_dem_local <- seq(from = 500, to = 10000, by = 500) %>%
  round() %>%
  as.integer()

seuil_puissance_armee <- seq(from = 0, to = 1000, by = 50) %>%
  round() %>%
  as.integer()

proba_ponderee_deplacement_lointain <- seq(from = 0, to = 1, by = 0.05)

coef_redevances <- seq(from = 0, to = 40, by = 2) %>%
  round() %>%
  as.integer()

### FIXME : serfs_mobiles <- c(TRUE, FALSE)

# list<int> seuils_distance_max_dem_local <- [2500, 4000, 6000];

nombre_seigneurs_objectif <- seq(from = 50, to = 450, by = 20) %>%
  round() %>%
  as.integer()


nombre_grands_seigneurs <- seq(from = 0, to = 2, by = 1) %>%
  round() %>%
  as.integer()

nombre_petits_seigneurs <- seq(from = 0, to = 50, by = 2) %>%
  round() %>%
  as.integer()

proba_collecter_loyer <- seq(from = 0, to = .5, by = 0.025)

proba_creation_ZP_banaux <- seq(from = 0, to = .5, by = 0.025)

proba_creation_ZP_basseMoyenneJustice <- seq(from = 0, to = .5, by = 0.025)

rayon_min_PS <- seq(from = 100, to = 2000, by = 100) %>%
  round() %>%
  as.integer()

rayon_max_PS <- seq(from = 1000, to = 10000, by = 500) %>%
  round() %>%
  as.integer()

min_fourchette_loyers_PS <- seq(0, .5,  by = .025)
max_fourchette_loyers_PS <- seq(0.25, 1,  by = .05)

proba_don_partie_ZP <- seq(0, 1,  by = .05)

apparition_chateaux <- seq(from = 800, to = 1160, by = 20) %>%
  round() %>%
  as.integer()

nb_chateaux_potentiels_GS <- seq(from = 0, to = 15, by = 1) %>%
  round() %>%
  as.integer()

seuil_attractivite_chateau <- seq(from = 1000, to = 10000, by = 500) %>%
  round() %>%
  as.integer()

proba_creer_chateau_GS <- seq(0, 1,  by = .05)

proba_chateau_agregat <- seq(0, 1,  by = .05)

proba_don_chateau_GS <- seq(0, 1,  by = .05)

proba_creer_chateau_PS <- seq(0, 1,  by = .05)

proba_gain_droits_hauteJustice_chateau <- seq(0, 1,  by = .05)
proba_gain_droits_banaux_chateau <- seq(0, 1,  by = .05)
proba_gain_droits_basseMoyenneJustice_chateau <- seq(0, 1,  by = .05)

proba_promotion_groschateau_multipole <- seq(0, 1,  by = .05)
proba_promotion_groschateau_autre <- seq(0, 1,  by = .05)

puissance_necessaire_creation_chateau_GS <- seq(from = 0, to = 5000, by = 250) %>%
  round() %>%
  as.integer()

puissance_necessaire_creation_chateau_PS <- seq(from = 0, to = 1000, by = 50) %>%
  round() %>%
  as.integer()



nombre_eglises <- seq(from = 0, to = 500, by = 25) %>%
  round() %>%
  as.integer()

nb_eglises_paroissiales <- seq(from = 0, to = 500, by = 25) %>%
  round() %>%
  as.integer()


nb_max_paroissiens <- seq(from = 10, to = 200, by = 10) %>%
  round() %>%
  as.integer()

nb_min_paroissiens <- seq(from = 0, to = 40, by = 5) %>%
  round() %>%
  as.integer()
  
seuil_creation_paroisse <- seq(from = 0, to = 500, by = 25) %>%
  round() %>%
  as.integer()

nb_paroissiens_mecontents_necessaires <- seq(from = 0, to = 100, by = 5) %>%
  round() %>%
  as.integer()

variables <- ls()
variables <- variables[variables != "variables"]

param_name_to_tibble <- function(string){
  name <- string
  type <- class(eval(parse(text = name)))
  values <- eval(parse(text = name))
  tibble(param = name, type = type, valeur = values)
}

types_gama <- tibble(
  type = c("integer","numeric"),
  type_gama = c("INT", "FLOAT")
)

sensib_params <- lapply(X = variables, FUN = param_name_to_tibble) %>%
  bind_rows() %>%
  mutate(id = 1:nrow(.)) %>%
  left_join(types_gama, by = "type") %>%
  mutate(sensibility_value = as.character(valeur)) %>%
  mutate(seed = 1)
  

vars <- ls()
rm(list = vars[vars != "sensib_params"])

xml_header <- '<?xml version="1.0" encoding="UTF-8"?>\n<Experiment_plan>'
xml_content <- '<Simulation id="{id}" sourcePath="/home/robin/transition8/models/Base4_5_GUI.gaml" finalStep="18" experiment="Exp_4_5_sensibility" seed="{seed}">
      <Parameters>
        <Parameter var="{param}" type="{type_gama}" value="{valeur}" />
        <Parameter var="sensibility_parameter" type="STRING" value="{param}" />
        <Parameter var="sensibility_value" type="STRING" value="{sensibility_value}" />
      </Parameters>
      <Outputs>
      </Outputs>
</Simulation>'


for (i in 1:10) {
  sensib_params <- sensib_params %>%
    mutate(seed = i)
  
  simulations_xml <- sensib_params %>%
    glue_data(xml_content) %>%
    paste(collapse = "\n")
  
  final_xml <- paste(xml_header, simulations_xml, sep = "\n")
  final_xml <- paste(final_xml, "</Experiment_plan>", sep = "\n")
  final_xml <- paste(final_xml, "\n")
  writeLines(final_xml, con = glue("simFEODAL_analyse_sensibilite_{i}.xml"))
}

# 
# // POLES //
#   float attrac_0_eglises <- 0.0;
# float attrac_1_eglises <- 0.15;
# float attrac_2_eglises <- 0.25;
# float attrac_3_eglises <- 0.5;
# float attrac_4_eglises <- 0.6;
# float attrac_GC <- 0.25;
# float attrac_PC <- 0.15;
# float attrac_communautes <- 0.15;
