/**
 *  Break/ask enhancement request
 *  Author: Robin Cura
 *  Description: 
 */

model breakingBad

global{
	init {
		create Heisenbergs number: 20;
	}
}

entities {
	species Heisenbergs {
	}
}


experiment test type: gui {
	user_command breakingTest {
	ask Heisenbergs {
		if (flip(0.3)){
			break;
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
}

