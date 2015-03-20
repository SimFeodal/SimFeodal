/**
 *  Delaunay
 *  Author: paris
 *  Description: 
 */

model Delaunay

global {
	/** Insert the global definitions, variables and actions here */
	init {
		
		create A number: 5 {
			set location <- any_location_in(world) ;
		}
		create B number: 5 {
			set location <- any_location_in(world) ;
		}
	}
	
	geometry myTriangle <- nil;
}

entities {
	species A {
		aspect base {
			draw circle(1) color: #red ;
		}
	}
	species B {
		aspect base {
			draw circle(1) color: #blue ;
		}
	}
}

experiment Delaunay type: gui {
	/** Insert here the definition of the input and output of the model */
	user_command testDelaunay {
		ask one_of(A){
			list<geometry> myTriangles <- triangulate(A collect each.location);
			set myTriangle <- one_of(myTriangles);
			//write string(oneTriangle.shape);
			//list<point> abc <- myTriangle ;
			//write string(abc) ;
			write (myTriangle farthest_point_to(point(myTriangle)));
		write 'show must go on !';
		}
	}
	output {
		display world_display {
			species A aspect: base;
			species B aspect: base;
			graphics "test"  {
				//loop g over: triangulate(A collect each.location){
					//draw (g + ["distance"::10.0, "quadrantSegments"::2, "endCapStyle":: 1]) color: #blue;
					//draw (g + ["distance"::5.0, "quadrantSegments"::4, "endCapStyle":: 2]) color: #green;
					//draw (g + ["distance"::1.0, "quadrantSegments"::10, "endCapStyle":: 1]) color: #yellow;
					//draw (5 around g) color: #blue;
					//draw g color: #red;
				//}
				draw myTriangle color:  #red ;
			}	
		}
	}
}
