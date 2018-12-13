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
		string test <- "A";
		//write test;
	}
	
	reflex testtest {
		do writetest;
		set test <- 2;
		write(rnd(10));
	}
}

experiment NewModel type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
	}
}
