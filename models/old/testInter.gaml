/**
 *  testInter
 *  Author: robin
 *  Description: 
 */

model testInter

global {
	init {
		create testAgent number: 2 {
			set location <- any_location_in(world);
		}
	}
}

entities {
	species testAgent {
		aspect base {
			draw circle(1) color: #red ;
		}
	}
}

experiment testInter type: gui {
	user_command breakingTest {
	ask one_of(testAgent){
		write (self distance_to one_of(testAgent at_distance 100));
	}
	write 'show must go on !';
	}
	
	user_command breakingTest2 {
	ask one_of(testAgent){
		testAgent other_agent <- one_of(testAgent at_distance 100);
		float goDist <- self distance_to other_agent;
		point abc <- point(line([self.location, other_agent.location]) inter ((goDist/2) around self));
		geometry testPoint <- (line([self.location, other_agent.location]) inter ((goDist/2) around self));

		write testPoint.points;
		write 'goodpoint distance ? : ' + (self distance_to (testPoint.points)[1]);
		write "original distance : " + goDist;
		write "travelled distance : " + (self distance_to abc);
		//set location <- abc;
	}
	write 'show must go on !';
	}
	output {
	display world_display {
			species testAgent aspect: base;
		}
	}
}
