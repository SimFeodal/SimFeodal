/**
 *  SQLConnection
 *  Author: thaitruongminh
 *  Description: 
 *   00: Test DBMS Connection
 */
model test_connection

global {
	map<string, string> SQLITE <- ['dbtype'::'sqlite', 'database'::'meteo.db'];
	init {
		create DB_connection_tester;
	}

}

species DB_connection_tester skills: [SQLSKILL] {
	init {
		write "Connection to SQLITE is " + self testConnection [params::SQLITE];
	}

}

experiment default_expr type: gui {
}  