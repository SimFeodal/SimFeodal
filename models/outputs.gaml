	map<string, string> dbParams <- ['dbtype'::'sqlite', 'database'::'../includes/output.db'];
	
	action connectDB {
		create agentDB number: 1 {
			if (self testConnection (params::dbParams) = false) {
				write "Impossible connection";
			} else {
				write "Connection of " + self;
				do connect params: dbParams;
			}
		}
	}
	action createTable {
		ask agentDB {
			do executeUpdate updateComm: "CREATE TABLE bounds " +
               "(id INTEGER PRIMARY KEY, " +
			   " geom BLOB NOT NULL); "  ;
		}
	}
}

entities {
	species agentDB parent: AgentDB {
	
	}	
}
