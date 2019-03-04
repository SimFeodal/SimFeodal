/***
* Name: NewModel
* Author: robin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

global {
	int test <- 1;
	
	action writetest {
		write test;
	}
	
	reflex testtest {
		create testAgent number: 3 {
			do die;
			do writeit;
			set test <- test + 1;
		}
		do writetest;
	}
	
	reflex save_agents {
		create testAgent number: 5;
		save testAgent to: "testAgent.csv" type: "csv" header: true rewrite: true with: [test3::"foof", foo::"TEST"];
	}
	
}

species testAgent {
	
	bool test3 <- true;
	int foo <- 3;
	action writeit {
		write 'HELP !';
	}
}

experiment NewModel type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
	}
}
