//#include ebinmodz\gamemodes\rpg\challenges;

//self is the player
new(name) {
	ret = spawnStruct();
	ret.pro = false;
	ret.owner = self;
	ret.name = name;
	ret.challenge = ebinmodz\gamemodes\rpg\challenges::new();

	switch(name) {
		case "Sleight of Hand":
			ret.base_name = "specialty_fastreload";
			ret.slot = 1;
			ret.pro_name = "specialty_quickdraw";
			ret.challenge.colour = 5;
			ret.challenge.monitor_function = ::_challengeSleightOfHand;
			break;

		case "Stopping Power":
			ret.base_name = "specialty_bulletdamage";
			ret.slot = 2;
			ret.pro_name = "specialty_armorpiercing";
			ret.challenge.colour = 1;
			ret.challenge.monitor_function = ::_challengeStoppingPower;
			break;

		case "Commando":
			ret.base_name = "specialty_extendedmelee";
			ret.slot = 3;
			ret.pro_name = "specialty_falldamage";
			ret.challenge.colour = 2;
			ret.challenge.monitor_function = ::_challengeCommando;
			break;

		default:
			ret delete(); //structs *may* need to be deleted if not used anymore???
			return undefined;
	}
	return ret;
}

//self is struct
give() {
	self.owner maps\mp\perks\_perks::givePerk(self.base_name);
	if(self.pro) self.owner maps\mp\perks\_perks::givePerk(self.pro_name);
}

//self is struct
del() {
	self iprintln("DELETEDING PERK"); //!!!!!!!!!!!!
	self notify("death"); //can't be too sure??
	self.challenge delete();
	self delete();
}

_challengeComplete() {
	self.owner iPrintLnBold(self.name + " Pro!");
	self.pro = true;
	self.origin = (0,0,0);
	if(isAlive(self.owner)) self.owner maps\mp\perks\_perks::givePerk(self.pro_name); //already alive in pvp, so the normal scripts won't activate yet
	self.owner openMenu("perk_display");
}

//self should be the struct that is holding this
_challengeSleightOfHand() {
	times = 150;
	self.name = "Sleight of Hand Pro";
	self.requirement = "Reload " + times + " times";
	self ebinmodz\gamemodes\rpg\challenges::waitForCompletion("reload", times); //built-in - after reload successful
	_challengeComplete();
}

_challengeStoppingPower() {
	times = 400;
	self.name = "Stopping Power Pro";
	self.requirement = "Shoot " + times + " times";
	self ebinmodz\gamemodes\rpg\challenges::waitForCompletion("weapon_fired", times); //built-in
	_challengeComplete();
}

_challengeCommando() {
	times = 150;
	self.name = "Commando Pro";
	self.requirement = "Melee " + times + " times";
	self ebinmodz\gamemodes\rpg\challenges::waitForCompletion("+melee", times, 1); //in main
	_challengeComplete();
	//_challengeEventThink("fall_damaged", times); //check main::calculateDamage
}
