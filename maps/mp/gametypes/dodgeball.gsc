#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include ebinmodz\utility;
#include common_scripts\utility;

needMap() {
	return "mp_nightshift";
}

main() {
	level.warn_admin = []; //special checked value

	if(getdvar("mapname") == "mp_background") return;
	if(getdvar("mapname") != needMap()) {
		//map( needMap() ); //crashes dedi
		level.warn_admin[level.warn_admin.size] = "Wrong map for " + level.gameType;
		maps\mp\gametypes\dm::main(); //default so that non-hosts can change the server properly
		return;
	}

	maps\mp\gametypes\sd::main();
	game["dialog"]["gametype"] = "searchdestroy_pro";
	allowed[0] = "airdrop_pallet";
	maps\mp\gametypes\_gameobjects::main(allowed);

	//set up menu
	level ebinmodz\main::init();

	level.menus = [];
	level.menus[""] = []; //can't just sit around invincible
	level.menus["vip"] = level.menus[""];
	level.menus["admin"] = array_combine(level.menus["vip"], createArray( //append to vip menu
		createMenuObject("Admin", ebinmodz\menus\admin::getList, ebinmodz\menus\admin::runFunc),
		createMenuObject("Gamemodes", ebinmodz\menus\gamemodes::getList, ebinmodz\menus\gamemodes::runFunc)
	));

	level._default_spawns = [];
	level._default_spawns["attackers"] = createArray(
		(10324.9, -10761.2, -63.875)
	);
	level._default_spawns["defenders"] = createArray(
		(10313.4, -11541.5, -63.875)
	);

	level.spawn_points = [];
	level.spawn_points["attackers"] = level._default_spawns["attackers"];
	level.spawn_points["defenders"] = level._default_spawns["defenders"];

	level thread onPlayerConnect();
	level thread onRoundEnd();
}

onPlayerConnect() {
	while(true) {
		level waittill("connected", player);
		player thread ebinmodz\menus\main::_printDebugInfo();
		player thread onPlayerSpawned();
		player notifyOnPlayerCommand("kill_me", "+stance");
		player thread killme();
	}
}

killme() {
	self endon("disconnect");

	while(true) {
		self waittill("kill_me");
		self suicide();
	}
}

onRoundEnd() {
	while(true) {
		level waittill("game_ended");
		level.spawn_points["attackers"] = level._default_spawns["attackers"];
		level.spawn_points["defenders"] = level._default_spawns["defenders"];
	}
}

onPlayerSpawned() {
	self endon("disconnect");

	while(true) {
		self waittill("spawned_player");
		if(self.pers["team"] == game["attackers"]) {
			team_name = "attackers";
			angle = -90;
		} else if(self.pers["team"] == game["defenders"]) {
			team_name = "defenders";
			angle = 90;
		} else { //spectator
			continue;
		}

		if(level.spawn_points[team_name].size) {
			self setOrigin(level.spawn_points[team_name][0]);
			level.spawn_points[team_name] = removeIndexArray(level.spawn_points[team_name], 0);
			self setPlayerAngles((0, angle, 0));
			self setActionSlot(1, ""); //disable nightvision
		} else {
			self iPrintLnBold("No more spawn points - pester for more");
			self [[level.spectator]]();
		}
	}
}
