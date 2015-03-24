/**
 *  testAskDecomposition
 *  Author: robin
 *  Description: 
 */

model testAskDecomposition

global {
	/** Insert the global definitions, variables and actions here */
	init {
		create A number: 10000 ;
	}
}

entities {
	species A {
		float valX <- 0.0 ;
		float valY <- 0.0 ;
	}
}

experiment testAskDecomposition type: gui {
	/** Insert here the definition of the input and output of the model */
	user_command Ensemble {
		float t <- machine_time;
		loop times: 1000 {
			ask A {
			set valX <- rnd_float(100.0);
			set valY <- rnd_float(100.0);
			}
		}
		write "Ensemble : " + string(machine_time - t);
	}
	user_command Decompose {
		float t <- machine_time;
		loop times: 1000 {
			ask A {
				set valX <- rnd_float(100.0);
			}
			ask A {
				set valY <- rnd_float(100.0);
			}
		}
		write "Decompose : " + string(machine_time - t);
	}
}
