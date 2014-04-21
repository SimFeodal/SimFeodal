/**
 *  test
 *  Author: robin
 *  Description: 
 */

model test

global{}

experiment test type: gui {
	user_command testthat {
		loop i over: [1,2,3]{
			loop j over: [1,2,3]{
				if (i = j){ /* leave j */}
				write string(i) + "-" + string(j);
			}
		}
	}
}

