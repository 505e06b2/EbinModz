clearLaptopWaypoints() {
	if(isDefined(self.waypoints)) {
		foreach(icon in self.waypoints) icon ebinmodz\utils\waypoint::del();
	}
	self.waypoints = [];
}

addLaptopWaypoint(use_crate, shader) {
	self.waypoints[self.waypoints.size] = self ebinmodz\utils\waypoint::new(use_crate.laptop.origin, shader);
}

perkStruct(name, pro) {
	ret = spawnStruct();
	ret.name = name;
	if(isDefined(pro) && pro == true) ret.pro = true;
	else pro = false;
	return ret;
}
