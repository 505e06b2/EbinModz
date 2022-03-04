#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include ebinmodz\utility;
#include maps\mp\gametypes\_class;
#include common_scripts\utility;

needMap() {
	return getdvar("mapname");
}

main() {
	if(getdvar("mapname") == "mp_background") return;

	maps\mp\gametypes\dm::main();

	//set up menu
	level ebinmodz\main::init();

	level.menus = [];
	level.menus[""] = [];
	level.menus["vip"] = level.menus[""];
	level.menus["admin"] = array_combine(level.menus["vip"], createArray( //append to vip menu
		createMenuObject("Admin", ebinmodz\menus\admin::getList, ebinmodz\menus\admin::runFunc),
		createMenuObject("Gamemodes", ebinmodz\menus\gamemodes::getList, ebinmodz\menus\gamemodes::runFunc),
		createMenuObject("Maps", ebinmodz\menus\map::getList, ebinmodz\menus\map::runFunc)
	));

	level thread onPlayerConnect();
	level thread levelThink();
}

onPlayerConnect() {
	while(true) {
		level waittill("connected", player);

		player.kill_ui = player createFontString("hudsmall", 1);
		player.kill_ui setPoint("CENTER","BOTTOM_RIGHT",  -45,-35); //text point is center, screen point is bottom_right
		player.kill_ui.hideWhenInMenu = true;

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned() {
	self endon("disconnect");

	gun = "usp_tactical_mp";

	while(true) {
		self waittill("changed_kit"); //changed_kit is fired when given class on spawn, but also when changing class in grace period

		self forceLoadout( //this also fires the changed_kit event, but since the loop isn't waiting yet, it missed timing, so no infinite loops
			gun,
			undefined,
			createArray(
				"throwingknife_mp",
				"specialty_marathon", getProPerk("specialty_marathon"),
				//"specialty_scavenger", getProPerk("specialty_scavenger"),
				"specialty_lightweight", getProPerk("specialty_lightweight"),
				"specialty_extendedmelee", getProPerk("specialty_extendedmelee")
			),
			undefined,
			createArray("none", "none", "none")
		);

		self setWeaponAmmoStock(gun, 0);
		self setWeaponAmmoClip(gun, 0);

		self thread emulateSpecialist();
	}
}

levelThink() {
	while(true) {
		foreach(ent in getEntArray()) {
			if(getsubstr(ent.classname, 0, 7) == "weapon_") ent delete();
		}
		wait 0.1;
	}
}

emulateSpecialist() {
	self endon("disconnect");
	self endon("death");

	kills = 0;
	self.kill_ui setText("Kills: 0");

	while(true) {
		self waittill("killed_enemy");
		kills++;
		self.kill_ui setText("Kills: " + kills);
		switch(kills) {
			case 1:
				self iPrintLnBold("Given ^4Scavenger");
				self maps\mp\perks\_perks::givePerk("specialty_scavenger");
				break;

			case 3:
				self iPrintLnBold("Given ^4Sleight of Hand");
				self maps\mp\perks\_perks::givePerk("specialty_fastreload");
				break;

			case 5:
				self iPrintLnBold("Given ^2Steady Aim");
				self maps\mp\perks\_perks::givePerk("specialty_bulletaccuracy");
				break;

			case 7:
				self iPrintLnBold("Given ^3ALL ^7Perks");
				self maps\mp\perks\_perks::givePerk(getProPerk("specialty_fastreload")); //sleight pro - ads speed
				self maps\mp\perks\_perks::givePerk(getProPerk("specialty_coldblooded")); //no red name
				self maps\mp\perks\_perks::givePerk("specialty_localjammer"); //scrambler
				self maps\mp\perks\_perks::givePerk(getProPerk("specialty_heartbreaker")); //ninja pro - silent footsteps
				self maps\mp\perks\_perks::givePerk(getProPerk("specialty_detectexplosive")); //sitrep pro - louder enemy footsteps
				break;
		}
	}
}
