model machinetime
experiment machinetime type: gui {
			user_command current_time {
			write machine_time as_date "%h:%m:%s";
			write as_time(machine_time);
		}
}
