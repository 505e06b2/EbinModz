#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include ebinmodz\utility;
#include common_scripts\utility;

needMap() {
	return "mp_rust";
}

main() {
	precacheShader("dpad_killstreak_nuke");
	precacheShader("cardicon_8ball");

	level.warn_admin = []; //special checked value

	if(getdvar("mapname") == "mp_background") return;
	if(getdvar("mapname") != needMap()) {
		level.warn_admin[level.warn_admin.size] = "Wrong map for " + level.gameType;
		maps\mp\gametypes\dm::main(); //default so that non-hosts (Admins) can change the server properly
		return;
	}

	maps\mp\gametypes\dm::main();
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

	setDvar("scr_" + level.gameType + "_timelimit", 0);
	setDvar("scr_" + level.gameType + "_scorelimit", 0);
	//setDvar("g_hardcore", 1); //disable hud, don't need auto regen

	level thread levelThink();
	level thread onPlayerConnect();
	level.callbackPlayerDamage = ::calculateDamage;

	//non-pvp spawns
	level.spawn_origin = (1948, 704, -182);
	level.spawn_angles = (0, -180, 0);

	level.classes = [];
	level.classes["sniper"] = spawnStruct();
	level.classes["sniper"].possible_primaries = createArray("barrett", "wa2000", "m21", "cheytac");
	level.classes["sniper"].secondary = "deserteagle_tactical_mp";
	level.classes["sniper"].starting_perks = createArray(
		"Sleight of Hand",
		"Stopping Power",
		"Commando"
	);

	waittillframeend; //so collision works
	level.use_crates = spawnStruct();
	level.use_crates.enter = createCrateWithLaptop((1820, 702, -190), "Enter the Zone", "attempted_spawn_in_pvp");
	level.use_crates.exit = createCrateWithLaptop((1616, 706, -220), "Exit the Zone", "attempted_spawn_in_nonpvp");
	level.use_crates.exit.crate.angles = (0,180+90,0);
}

levelThink() {
	while(true) {
		foreach(ent in getEntArray()) {
			if(getsubstr(ent.classname, 0, 7) == "weapon_") ent delete();
		}
		wait 0.1;
	}
}

onPlayerConnect() {
	while(true) {
		level waittill("connected", player);
		player.waypoints = [];
		player.pvp = false;

		player.inventory = spawnStruct();
		player.inventory.max_health = 100;
		player.inventory.regen_health_per_second = 10;

		player.inventory.damage_multiplier = 1;
		player.inventory.reload_multiplier = 1;

		player.inventory.class = random(getArrayKeys(level.classes));
		player.inventory.primary = random(level.classes[ player.inventory.class ].possible_primaries);
		player.inventory.perks = [];
		foreach(perk_name in level.classes[ player.inventory.class ].starting_perks) { //FOR A CLASS CHANGE, THESE MUST BE DELETED
			player.inventory.perks[player.inventory.perks.size] = player ebinmodz\gamemodes\rpg\perks::new(perk_name);
		}

		player.inventory.challenges = [];
		foreach(perk in player.inventory.perks) {
			challenge = perk.challenge;
			player.inventory.challenges[player.inventory.challenges.size] = challenge; //should be passed by reference
			challenge thread ebinmodz\gamemodes\rpg\challenges::monitor(); //start challenge
		}

		player.challenge_bars = [];
		for(i = 0; i < 3; i++) {
			player.challenge_bars[i] = player createPrimaryProgressBar();
			player.challenge_bars[i] setPoint("TOP_LEFT", "TOP_LEFT", 6, 150 + (50*i));
			player.challenge_bars[i].hideWhenInMenu = true;

			player.challenge_bars[i].bar.x += 2; //because of TOP_LEFT
			player.challenge_bars[i].bar.y += 2;
			player.challenge_bars[i].bar.hideWhenInMenu = true;

			player.challenge_bars[i].bar_text = player createFontString("hudsmall", 0.75);
			player.challenge_bars[i].bar_text.yOffset = -30; //enough for 2 lines
			player.challenge_bars[i].bar_text setParent(player.challenge_bars[i]);
			player.challenge_bars[i].bar_text.hideWhenInMenu = true;
		}
		player thread _updateChallengeBars();
		player notifyOnPlayerCommand("+melee", "+melee"); //used for the commando challenge

		player thread ebinmodz\gamemodes\rpg\player_pvp::main();
		player thread ebinmodz\gamemodes\rpg\player_nonpvp::main();

		//player thread _debugHealth();
		//player thread ebinmodz\menus\main::_printDebugInfo();
		//player thread ebinmodz\menus\main::runFunc(2);
	}
}

//self is player being damaged
calculateDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime) {
	//self iPrintLn("?");
	//self iPrintLn(isDefined(eInflictor));
	//self iPrintLn(isDefined(eAttacker));
	if(self.pvp == false) iDamage = 0; //while in non-pvp, can't be damaged
	else if(isPlayer(eAttacker) && eAttacker.pvp == false) iDamage = 0; //while in pvp, can't be damaged by non-pvp

	//if(sMeansOfDeath == "MOD_FALLING") self notify("fall_damaged");

	maps\mp\gametypes\_damage::Callback_PlayerDamage_internal(eInflictor, eAttacker, self, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

_updateChallengeBars() {
	self endon("disconnect");

	while(true) {
		//MOVE THESE FEW LINES TO CHALLENGES.GSC
		sorted = sortByDistance(self.inventory.challenges, (0,0,0)); //each has an origin of current progress, with x value set to completion
		not_complete = [];
		foreach(challenge in sorted) {
			if(challenge.progress < 1.0) not_complete[not_complete.size] = challenge;
		}

		for(i = 0; i < self.challenge_bars.size; i++) {
			if(not_complete.size <= i || self.menu.open) { //hide if menu open
				self.challenge_bars[i].alpha = 0;
				self.challenge_bars[i].bar.alpha = 0;
				self.challenge_bars[i].bar_text.alpha = 0;
				continue;
			}
			self.challenge_bars[i].alpha = 0.5;
			self.challenge_bars[i].bar.alpha = 1;
			self.challenge_bars[i].bar_text.alpha = 1;

			self.challenge_bars[i].bar.color = ebinmodz\tables\colours::getRGB(not_complete[i].colour);
			self.challenge_bars[i] updateBar(not_complete[i].progress);

			self.challenge_bars[i].bar_text setText(
				"[^" + not_complete[i].colour + not_complete[i].name + "^7]\n" + not_complete[i].requirement
			);
		}
		wait 0.2;
	}
}

_debugHealth() {
	self endon("disconnect");
	while(true) {
		self iPrintLn(self.health + " / " + self.maxhealth);
		wait 1;
	}
}
