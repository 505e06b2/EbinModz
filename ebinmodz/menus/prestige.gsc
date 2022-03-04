//currently not used as it's a bit redundant - does show the flexibility of the menu creation system

getList() {
	ret = [];
	ret[ret.size] = "No Prestige";
	for(i = 1; i <= 11; i++) {
		ret[ret.size] = "Prestige " + (i);
	}
	return ret;
}

//use player context
runFunc(prestige) {
	if(prestige < 0 || prestige > 11) {
		self iPrintLn("Invalid prestige: " + prestige);
		return;
	}

	self setPlayerData("prestige", prestige);
	self setPlayerData("experience", 2516000);
	self iPrintLn("^:Leave the game to save");
	self playSound("mp_level_up");
}
