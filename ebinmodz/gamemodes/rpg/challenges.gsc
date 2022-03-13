//self is the player
new(func) {
	ret = spawnStruct();
	ret.owner = self;
	ret.name = "Challenge";
	ret.requirement = "Requirement?";
	ret.colour = 7; //colour code
	ret.started = false; //set to true when the monitor function starts
	ret.progress = 0;
	ret.origin = (1,0,0);
	ret.monitor_function = func; //could be undefined
	return ret;
}

monitor() {
	self.owner endon("disconnect");
	self endon("death");

	self.started = true;
	self [[self.monitor_function]]();
}

//ALWAYS use this to increase the progress
increaseProgress(amount) {
	if(self.owner.pvp == false) return; //just in case
	self.progress += amount;
	self.origin = (1-self.progress, 0,0); //for sorting - invert so it's closer to 0, instead of 1
}

waitForCompletion(event, occurrences, min_delay) {
	self.owner endon("disconnect");
	self endon("death"); //on perk/obj delete

	percent_increase = 1 / occurrences;
	if(!isDefined(min_delay)) min_delay = 0;

	while(self.progress < 1.0) {
		self.owner waittill(event); //happens when an [event] is complete - this event must be built-in to the game
		self increaseProgress(percent_increase);
		wait min_delay;
	}
}

//self is challenge obj
del() {
	self delete();
}
