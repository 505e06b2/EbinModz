#include ebinmodz\utility;
#include ebinmodz\gamemodes\rpg\utility;
#include maps\mp\gametypes\_hud_util;

main() {
	self endon("disconnect");

	while(true) {
		self waittill("spawned_player"); //initial spawn, but also returning to non-pvp
		self.pvp = false;

		self setClientDvar( "clanname", "{@@}");

		clearLaptopWaypoints();
		addLaptopWaypoint(level.use_crates.enter, "dpad_killstreak_nuke");

		self visionSetNakedForPlayer(getDvar("mapname"), 0);
		self visionSetPainForPlayer(getDvar("mapname"), 0);

		self setVelocity((0,0,0));
		self setOrigin(level.spawn_origin);
		self setPlayerAngles(level.spawn_angles);

		if(isDefined(self.health_bar)) self.health_bar destroyElem(); //_regenhealth

		self forceLoadout(
			undefined,
			undefined,
			createArray(
				"specialty_marathon", getProPerk("specialty_marathon"),
				"specialty_lightweight", getProPerk("specialty_lightweight"),
				"specialty_extendedmelee", getProPerk("specialty_extendedmelee")
			),
			undefined, //no special
			createArray("none", "none", "none") //no killstreaks
		);

		self openMenu("perk_hide"); //don't show class perks
		self notify("perks_hidden"); //just in case threads are waiting on it

		self thread _attemptToEnter();
	}
}

_attemptToEnter() { //only active when not in the zone
	self endon("disconnect");
	self endon("spawned_in_pvp");
	self endon("spawned_player");
	self endon("death");

	while(true) {
		self waittill("attempted_spawn_in_pvp"); //triggered by crate
		/*if(self.health != self.maxhealth) {
			self iPrintLnBold("^1You must be at full health to leave");
			continue;
		}*/
		self notify("spawned_in_pvp");
	}
}
