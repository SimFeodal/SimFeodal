/***
* Name: NewModel
* Author: robin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel678

global {
	int temps <- 0;
	int param1 <- 0;
	int param2 <- 19;
	int param3 <- 56;
	int param4 <- 5;
	//string bloub <- "TYUI";
	string param_name <- "param1";
	string param_value <- "bar";

	reflex increase_time {
		set temps <- temps + 1;
	}
}


experiment test type: batch repeat: 2 keep_seed: false benchmark: false until: (temps >= 10){

	parameter "param_name" var: param_name init: "param1";
	parameter "param1" var: param1 among: [1,2];
	// 1 experiment
	
	reflex blob {
		string bloub <- "OIU";
	}
	reflex foofoo {
		ask simulations {
				
				set param_value <- string(eval_gaml(param_name));
				write(param_name + " : " + param_value);
				//save [ temps, param2, param_name, param_value] to: "/home/robin/test_gama.csv" type: "csv" header: false rewrite: false;
				do die;
		}
	}
}

experiment test2 type: batch repeat: 2 keep_seed: false benchmark: false until: (temps >= 10) parent: test{
	parameter "param_name" var: param_name init: "bloub";
}
