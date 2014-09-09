/**
 *  Break/ask enhancement request
 *  Author: Robin Cura
 *  Description: 
 */

model nestedSpecies

global{
	init {
		create ABC number: 10 {
			create DEF number: 2;
		}
		create XYZ number: 1 {
			set myABC <- one_of(ABC);
		}
	}
	reflex test2 {
		ask 2 among ABC {
			set test <- true;
		}
		//write length(ABC where each.test);
		ask 1 among (ABC where each.test){
			set test <- false;
		}
		//write length(ABC where each.test);
		ask 1 among (ABC where each.test) {
			ask DEF {
				set myself.test <- false ;
			}
		}
		//write length(ABC where each.test);
	}
	
	reflex test3 {
		ask XYZ {
			set one_of(DEF of myABC).testvalue <- 5;
		}
		ask ABC {
			ask DEF where (each.testvalue != 0){
				//write self.testvalue;
			}
			
		}
		write string(length(ABC accumulate (each.DEF where (each.testvalue != 0))));
	}
}

entities {
	species ABC {
		bool test  <- false;
		species DEF {
			int testvalue <- 0;
		}
	}
	species XYZ {
		ABC myABC;
	}
}


experiment test type: gui {
	user_command nestedTest {
	write 'Init';
	write 'Nb ABC : ' + string(length(ABC));
	write 'Nb DEF : ' + string(sum(ABC collect length(each.DEF)));
	write 'Nb ABC ayant 0 DEF : ' + length(ABC where (length(each.DEF) = 0));
	write 'Nb ABC ayant 1 DEF : ' + length(ABC where (length(each.DEF) = 1));
	write 'Nb ABC ayant 2 DEF : ' + length(ABC where (length(each.DEF) = 2));
	ask ABC {
		ask DEF {
			if flip(0.3) {
				do die;
			}
		}
		if flip(0.3){
			do die;
		}
	}
	
	write "After...";
	write 'Nb ABC : ' + string(length(ABC));
	write 'Nb DEF : ' + string(sum(ABC collect length(each.DEF)));
	write 'Nb ABC ayant 0 DEF : ' + length(ABC where (length(each.DEF) = 0));
	write 'Nb ABC ayant 1 DEF : ' + length(ABC where (length(each.DEF) = 1));
	write 'Nb ABC ayant 2 DEF : ' + length(ABC where (length(each.DEF) = 2));
	}
}

