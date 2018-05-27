def empty_database
	Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
end