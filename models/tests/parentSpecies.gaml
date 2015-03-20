/**
 *  Break/ask enhancement request
 *  Author: Robin Cura
 *  Description: 
 */

model parentSpecies

global{
	init {
		create XYZ number: 1 {
		}
		create DEF number: 1 {
			
		}
	}
}

entities {
	species ABC {
		int myAttribute <- 2;
	}
	species XYZ parent: ABC {
		int myAttribute <- 3;
	}
	species DEF parent: ABC {
		int test <- 5;
	}
}


experiment test type: gui {
	user_command parentTest {
	write 'Init';
	list agentSet <- list(XYZ) + list(DEF);
	ask agentSet {
		write self.name + self.myAttribute;
	}
	}
}

