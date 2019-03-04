/***
* Name: NewModel
* Author: robin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

global {
	init {
		create shapeAgent number: 10 {
			set location <- any_location_in(world);
			set shape <- 2 around location;
			set color <- #red;
		}
		loop i from: 0 to: length(shapeAgent) -1 {
			ask shapeAgent[i] {set id <- string(i);}
		}
		
		create blobAgent number: 1 {
			set location <- point(50,50);
			set shape <- 2 around location;
			set color <- #blue;
		}
	}
	
//	reflex testIntersections {
//		ask blobAgent {
//			list<shapeAgent> shpinside <- shapeAgent inside self.shape;
//			list<shapeAgent> shpDistance <- shapeAgent at_distance 30;
//			list<shapeAgent> shpOverlap <- shapeAgent overlapping self.shape;
//			list<shapeAgent> shpCustom <- shapeAgent inside (30 around self.location);
//			list<shapeAgent> shpNotInside <- shapeAgent - (shapeAgent overlapping self.shape);
//			
//			write length(shpinside);
//			write length(shpDistance);
//			write length(shpOverlap);
//			write length(shpCustom);
//			write length(shpNotInside);
//			
//			write shpinside collect each.id;
//			write shpDistance collect each.id;
//			write shpOverlap collect each.id;
//			write shpCustom collect each.id;
//			write shpNotInside collect each.id;
//		}
//	}

	reflex agentMove {
		ask shapeAgent {
			set location <- any_location_in(world);
		}
	}
	
	reflex testClosest {
		ask blobAgent {
			float minDist1 <- min(shapeAgent collect (each distance_to self));
			float minDist1_bis <- min(shapeAgent collect (each distance_to self.location));
			
//			float minDist2 <- (shapeAgent with_min_of (self distance_to each)) distance_to self; 
//			float minDist2_bis <- (shapeAgent with_min_of (self.location distance_to each)) distance_to self.location; 
			
//			write minDist1;
//			write minDist1_bis;
//			write minDist2;
//			write minDist2_bis;
			
		}
	}
	
	
//	
}

species shapeAgent {
	string id;
	aspect base {
		draw shape color: #blue;
		draw id size: 8 color: #black;
	}
}

species blobAgent {
	aspect base {
		draw shape color: #yellow;
	}
}


experiment NewModel type: gui benchmark: true{
	/** Insert here the definition of the input and output of the model */
	output {
		display Circle {
			species shapeAgent transparency: 0.5 aspect: base;
			species blobAgent transparency: 0.5 aspect: base;
		}
	}
}
