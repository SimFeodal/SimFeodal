/**
 *  Display nested species
 *  Author: Robin Cura
 *  Description: 
 */

model nestedDisplay

global{
	init {
		create bigSquare number: 10 {
			set location <- any_location_in(world);
			set shape <- square(10);
			create littleSquare number: 1 {
				set mybigSquare <- myself;
				set location <- myself.location;
			}

		}
	}
}

entities {
	species bigSquare {
		species littleSquare {
			bigSquare mybigSquare;
			rgb color <- rgb('orange');
			reflex reshape {
				set shape <- mybigSquare.shape scaled_by 0.5;
			}
		}
	}
}


experiment nestedDisplay type: gui {

	output {
		display world_display {
			species bigSquare {
				species littleSquare;
			}
			//species littleSquare;
		}
	}
}

