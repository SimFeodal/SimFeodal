/**
 *  testBuffer
 *  Author: robin
 *  Description: 
 */

model testBuffer

global {
	/** Insert the global definitions, variables and actions here */
	init {
		create A number: 5 {
			set location <- any_location_in(world - 5);
		}
		A test <- one_of(A);
		write (10 around test).points ;
		write (10 around test).holes ;
	}
}

entities {
	species A {
		aspect base {
			draw circle(1) color: #red;
		}
	}
	
	
}

experiment testBuffer type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display world_display {
			species A aspect: base;
			graphics "test"  {
				//draw (convex_hull(polygon(A collect each.location)) + 10) color: #green ; 
				//draw convex_hull(polygon(A collect each.location)) color: #blue ;
				A abc <- one_of(A);
				draw (abc.location + 5) color: #blue ;
				draw (5 around abc.location) color: #red ;
			}
			
		}
	}
}
