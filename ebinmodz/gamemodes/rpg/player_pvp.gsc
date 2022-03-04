#include common_scripts\utility;
#include ebinmodz\utility;
#include ebinmodz\gamemodes\rpg\utility;
#include maps\mp\gametypes\_hud_util;

main() {
	self endon("disconnect");

	while(true) {
		self waittill("spawned_in_pvp");
		self.pvp = true;

		clearLaptopWaypoints();
		addLaptopWaypoint(level.use_crates.exit, "dpad_killstreak_nuke");

		//self visionSetNakedForPlayer("mpnuke_aftermath", 0);
		//self visionSetPainForPlayer("mpnuke_aftermath", 0);

		self setVelocity((0,0,0));
		spawnpoint = self [[level.getSpawnPoint]]();
		self setOrigin(spawnpoint.origin);
		self setPlayerAngles(spawnpoint.angles);

		self forceLoadout(
			maps\mp\gametypes\_class::buildWeaponName(self.inventory.primary, undefined, undefined),
			level.classes[ self.inventory.class ].secondary,
			undefined,
			self.inventory.special,
			createArray("none", "none", "none") //no killstreaks
		);

		foreach(perk in self.inventory.perks) {
			perk ebinmodz\gamemodes\rpg\perks::give();
		}

		playRumbleOnPosition("grenade_rumble", self.origin);
		earthquake(0.5, 0.75, self.origin, 800);
		self shellShock("frag_grenade_mp", 0.5);
		//self playsound("frag_grenade_mp"); //cant find sound atm

		self openMenu("perk_display"); //for debugging

		self thread _infiniteStock();
		self thread _attemptToExit();

		self.maxhealth = self.inventory.max_health;
		self.health = 0; //remove auto regen changing max health + make bloody screen effect, but no audio
		wait 2;
		self.health = self.maxhealth;
		self thread _regenHealth();
	}
}

_attemptToExit() { //only active when in the zone
	self endon("disconnect");
	self endon("spawned_in_pvp");
	self endon("spawned_player");
	self endon("death");

	while(true) {
		self waittill("attempted_spawn_in_nonpvp"); //triggered by crate
		if(self.health != self.maxhealth) {
			self iPrintLnBold("^1You must be at full health to leave");
			continue;
		}
		self notify("spawned_player");
	}
}

_regenHealth() {
	self endon("disconnect");
	self endon("spawned_in_pvp");
	self endon("spawned_player");
	self endon("death");

	if(isDefined(self.health_bar)) self.health_bar destroyElem(); //destroying set it to undefined - no use after free?
	self.health_bar = createPrimaryProgressBar(-200);
	self.health_bar.hideWhenInMenu = true; //bg
	self.health_bar.bar.hideWhenInMenu = true; //fg
	self.health_bar.bar.color = (1, 0.2, 0.2);

	while(true) {
		if(self.health < self.maxhealth) {
			self.health += int((self.inventory.regen_health_per_second / 10.0)); //division depends on wait, but seems to always need to be an int
			self.health_bar.alpha = 0.5;
			self.health_bar.bar.alpha = 1;
			self.health_bar updateBar(self.health / self.maxhealth);

		} else if(self.health >= self.maxhealth) {
			self.health = self.maxhealth;
			self.health_bar.alpha = 0;
			self.health_bar.bar.alpha = 0;
			self maps\mp\gametypes\_damage::resetAttackerList(); //from maps/mp/gametypes/_healthoverlay.gsc:170, since health = 0 stopped the function that would handle this normally
		}
		wait 0.1;
	}
}

_infiniteStock() {
	self endon("disconnect");
	self endon("spawned_in_pvp");
	self endon("spawned_player");
	self endon("death");

	while(true) {
		current_weapon = self getCurrentWeapon();
		if(isDefined(current_weapon)) self giveMaxAmmo(current_weapon);
		wait 0.2;
	}
}
