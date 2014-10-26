/**
 *  Break/ask enhancement request
 *  Author: Robin Cura
 *  Description: 
 */

model breakingBad

global{
	init {
		create Heisenbergs number: 1;
		create ABC number: 4;
	}
			map<ABC, int> mymap <- [];
}

entities {
	species Heisenbergs {
	}
	
	species ABC {
		list<Heisenbergs> myList <- [];
	}
}


experiment test type: gui {
	user_command breakingTest {
	ask Heisenbergs {
		if (flip(0.3)){
			//do break;
		}
		write "not my turn";
	}
	write 'show must go on !';
	}
	user_command breakingTest2 {
	loop heisen over: shuffle(Heisenbergs) {
		write heisen;
	}
	write 'show must go on !';
	}
	
	user_command listTest {
		ask ABC {
			set myList <- myList + one_of(Heisenbergs);
			write string(myList);
			set myList <- myList + one_of(Heisenbergs);
			write string(myList);
			
			//ask remove_duplicates(myList){
			ask myList{
				write string(self);
			}
		}	
	}
	
	
	user_command mapTest {

		ABC myAgent <- one_of(ABC);
		if (mymap.keys contains myAgent) {
			write "yes";
			mymap[myAgent] <- mymap[myAgent] + 1;
		} else {
			write "no";
			add myAgent::1 to: mymap;
		}
		write string(mymap);
	}
	
	user_command map2Test {
		map<string, int> testmap <- ["A"::1, "B"::2, "C"::3];
		write(testmap);
		string tmpVar <- "B";
		if (tmpVar in testmap.keys) {
			write 'yes';
			testmap[tmpVar] <- testmap[tmpVar] + 5;
			write(testmap);
		} else {
			write "no";
			write(testmap);
		}
		//write string(testmap at "C");
		write string((rnd(20) * 10)/200);
	}
}


