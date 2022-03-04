#include ebinmodz\utility;
#include maps\mp\gametypes\_hud_util;

getList() {
	ret = [];
	ret[ret.size] = "Godmode";
	ret[ret.size] = "Toggle Fullbright";
	ret[ret.size] = "Toggle Third Person";
	ret[ret.size] = "Toggle Print Debug Info";
	ret[ret.size] = "Toggle Laser";
	ret[ret.size] = "Show GUID";
	ret[ret.size] = "Set Prestige: None";
	ret[ret.size] = "Set Prestige: 9";
	ret[ret.size] = "Set Prestige: 10";
	ret[ret.size] = "Set Prestige: 11";
	return ret;
}

//use player context
runFunc(index) {
	switch(index) {
		case 0:
			allPlayersHudMessage(self.name + " died lol");
			self suicide();
			break;

		case 1:
			if(self.r_fullbright == "0") { //is true if uninitialised
				self.r_fullbright = "1";
				self iPrintLn("Fullbright On");
			} else {
				self.r_fullbright = "0";
				self iPrintLn("Fullbright Off");
			}
			self setClientDvar("r_fullbright", self.r_fullbright);
			break;

		case 2:
			if(isDefined(self.cg_thirdPerson)) {
				self notify("disable_third_person");
				self setClientDvar("cg_thirdPerson", "0");
				self.cg_thirdPerson = undefined;
				self iPrintLn("Third Person Off");
			} else {
				self thread _thirdPerson();
				self.cg_thirdPerson = true;
				self iPrintLn("Third Person On");
			}

			break;

		case 3:
			if(isDefined(self.print_debug_info)) {
				self.print_debug_info = undefined;
				self notify("disable_print_position");
			} else {
				self.print_debug_info = true;
				self thread _printDebugInfo();
			}
			break;

		case 4:
			if(self.laserForceOn == "0") {
				self.laserForceOn = "1";
				self iPrintLn("Laser On");
			} else {
				self.laserForceOn = "0";
				self iPrintLn("Laser Off");
			}
			self setClientDvar("laserForceOn", self.laserForceOn);
			break;

		case 5:
			self iPrintLn("GUID: " + self getGuid());
			break;

		case 6:
			self _setPrestige(0);
			break;

		case 7:
			self _setPrestige(9);
			break;

		case 8:
			self _setPrestige(10);
			break;

		case 9:
			self _setPrestige(11);
			break;

		default:
			self iPrintLn("^1No function for that menu option");
			break;
	}
}

_setPrestige(i) {
	self setPlayerData("prestige", i);
	self setPlayerData("experience", 2516000);
	self iPrintLn("Leave the game to save");
	self playSound("mp_level_up");
}

_thirdPerson() {
	self endon("disconnect");
	self endon("disable_third_person");

	self setClientDvar("cg_thirdPerson", "1");
	while(true) {
		self waittill("spawned_player");
		self setClientDvar("cg_thirdPerson", "1");
	}
}

_printDebugInfo() {
	self endon("disconnect");
	self endon("disable_print_position");

	while(true) {
		origin = self getOrigin();
		angles = self getPlayerAngles();
		self iPrintLn("pos:(" + origin[0] + ", " + origin[1] + ", " + origin[2] + ") ang:(" + angles[0] + ", " + angles[1] + ", " + angles[2] + ")");
		wait 1;
	}
}
