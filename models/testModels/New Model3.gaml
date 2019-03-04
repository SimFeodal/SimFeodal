/***
* Name: NewModel
* Author: robin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

global {
	int year <- 0;
	map<int,int> global_var <- 	[0::3,5::10, 7::12];
	int current_var <- 0;
	reflex update_vars {
		set year <- year + 1;

		set current_var <- (global_var.keys contains year) ? global_var at year : current_var;
		
		write "year : " + string(year) + " / current_var : " + string(current_var);
		
	}
	
	
	reflex stop_this when: year > 20{
		do pause;
	}

	
}

experiment NewModel type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
	}
}
