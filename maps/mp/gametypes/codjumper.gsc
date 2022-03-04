#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include ebinmodz\utility;
#include maps\mp\gametypes\_class;
#include common_scripts\utility;

needMap() {
	return getdvar("mapname");
}

saveLocation() {
	self.saved_location = spawnStruct();
	self.saved_location.position = self getOrigin();
	self.saved_location.angles = self getPlayerAngles();
	//self.saved_location.stance = self getStance(); //probably unnecessary
	self iPrintLnBold("Saved Location");
}

loadLocation() {
	if(isDefined(self.saved_location)) {
		self setStance(self.saved_location.stance);
		self setPlayerAngles(self.saved_location.angles);
		self setOrigin(self.saved_location.position);
		self setVelocity((0,0,0)); //stop momentum
		self iPrintLn("Loaded Location");
	} else {
		self iPrintLnBold("^1No Location Saved");
	}
}

//unused - keep it simple and don't override the spawn; button combo now used for suicide
clearLocation() {
	if(self fragButtonPressed() && self secondaryOffhandButtonPressed()) {
		self.saved_location = undefined;
		self iPrintLnBold("^1Cleared Saved Location");
	}
}

main() {
	if(getdvar("mapname") == "mp_background") return;

	maps\mp\gametypes\dm::main();

	//set up menu
	level ebinmodz\main::init();

	level.menus = [];
	level.menus[""] = createArray(
		createMenuObject("Main", ebinmodz\menus\main::getList, ebinmodz\menus\main::runFunc)
	);
	level.menus["vip"] = level.menus[""];
	level.menus["admin"] = array_combine(level.menus["vip"], createArray( //append to vip menu
		createMenuObject("Admin", ebinmodz\menus\admin::getList, ebinmodz\menus\admin::runFunc),
		createMenuObject("Gamemodes", ebinmodz\menus\gamemodes::getList, ebinmodz\menus\gamemodes::runFunc),
		createMenuObject("Maps", ebinmodz\menus\map::getList, ebinmodz\menus\map::runFunc)
	));

	setDvar("scr_" + level.gameType + "_timelimit", 0);
	setDvar("scr_" + level.gameType + "_scorelimit", 0);
	setDvar("jump_height", 64); //old school height - disable for stock MW2, but it can help get out of map solo
	setDvar("jump_slowdownEnable", 0); //makes things less frustrating
	setDvar("g_playerCollision", 0); //NEEDS TESTING

	level.callbackPlayerDamage = ::calculateDamage;
	level thread onPlayerConnect();
	level thread onPlayerDisconnect();
}

//self is damaged player - never take damage
calculateDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime) {
	iDamage = 0;
	maps\mp\gametypes\_damage::Callback_PlayerDamage_internal(eInflictor, eAttacker, self, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

onPlayerConnect() {
	while(true) {
		level waittill("connected", player);
		player setClientDvar("laserForceOn", 1);
		player setRadarAlwaysOn(true);

		player thread onPlayerSpawned();

		player notifyOnPlayerCommand("load_loc", "+smoke"); //3
		player notifyOnPlayerCommand("save_loc", "+frag"); //5
		player notifyOnPlayerCommand("suicide", "+actionslot 3"); //3

		player thread codjumperCommand("save_loc");
		player thread codjumperCommand("load_loc");
		player thread codjumperCommand("suicide");

		player.gamemode_controls = player createFontString("hudsmall", 0.8);
		player.gamemode_controls setPoint("BOTTOM", "BOTTOM", 0,-5);
		player.gamemode_controls setText("[{+frag}] Save / [{+smoke}] Load / [{+actionslot 3}] Suicide");
		player.gamemode_controls.alpha = 0.5;
		player.gamemode_controls.hideWhenInMenu = true;

		player.bounce_gun = "deserteaglegold_mp";
		player.bounce_pad = player ebinmodz\utils\bounce_pad::new();
	}
}

onPlayerDisconnect() {
	while(true) {
		level waittill("disconnect", player);
		if(isDefined(player.bounce_pad)) player.bounce_pad ebinmodz\utils\bounce_pad::del();
	}
}

onPlayerSpawned() {
	self endon("disconnect");

	while(true) {
		self waittill("spawned_player");

		self forceLoadout(
			"deserteaglegold_mp",
			undefined,
			createArray( //no equipment
				"specialty_marathon", getProPerk("specialty_marathon"),
				"specialty_lightweight", getProPerk("specialty_lightweight"),
				"specialty_extendedmelee", getProPerk("specialty_extendedmelee")
			),
			undefined,
			createArray("none", "none", "none")
		);

		self thread infiniteInventory();
		self thread shootBouncePackages();
	}
}

codjumperCommand(command) {
	self endon("disconnect");

	while(true) {
		self waittill(command);
		if(self.menu.open) continue; //ebinmodz - if menu open

		switch(command) {
			case "save_loc": self saveLocation(); break;
			case "load_loc": self loadLocation(); break;
			case "clear_loc": self clearLocation(); break;
			case "suicide": self suicide(); break;
		}
	}
}

infiniteInventory() {
	self endon("disconnect");
	self endon("death");

	while(true) {
		self setWeaponAmmoClip(self.bounce_gun, 9999);
		self giveMaxAmmo(self.bounce_gun);

		if(isDefined(self.pers["killstreaks"][0]) && self.pers["killstreaks"][0].streakName != "airdrop") {
			self maps\mp\killstreaks\_killstreaks::clearKillstreaks();
		}
		if(!isDefined(self.pers["killstreaks"][0])) self maps\mp\killstreaks\_killstreaks::giveKillstreak("airdrop", false);
		wait 1/5; //5fps
	}
}

shootBouncePackages() {
	self endon("disconnect");
	self endon("death");

	while(true) {
		self waittill("weapon_fired");
		if(self getCurrentWeapon() != self.bounce_gun) continue;
		forward = anglesToForward(self getPlayerAngles());
		max_distance = vector_multiply(forward, 1000000000);

		trace = bulletTrace(self getEye(), self getEye() + max_distance, false, self);
		//don't bother checking if it hit a player, since the packages aren't solid
		self.bounce_pad ebinmodz\utils\bounce_pad::update(trace["position"]);
	}
}
