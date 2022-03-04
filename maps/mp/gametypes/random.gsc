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
	level.menus[""] = []; //can't just sit around invincible
	level.menus["vip"] = level.menus[""];
	level.menus["admin"] = array_combine(level.menus["vip"], createArray( //append to vip menu
		createMenuObject("Admin", ebinmodz\menus\admin::getList, ebinmodz\menus\admin::runFunc),
		createMenuObject("Gamemodes", ebinmodz\menus\gamemodes::getList, ebinmodz\menus\gamemodes::runFunc),
		createMenuObject("Maps", ebinmodz\menus\map::getList, ebinmodz\menus\map::runFunc)
	));

	level.loadout_parts = spawnStruct();
	level.loadout_parts.perkslot = createArray(_perk1Array(), _perk2Array(), _perk3Array());

	level.loadout_parts.equipment = _equipmentArray();
	level.loadout_parts.special_grenade = _specialGrenadeArray();
	level.loadout_parts.weapon = _weaponArray();
	level.loadout_parts.attachment = _attachmentArray();

	//SHADERS FOR HUD
	foreach(perk_list in level.loadout_parts.perkslot) {
		foreach(perk in perk_list) {
			precacheShader( getPerkShader(perk) ); //non pro
			precacheShader( getPerkShader( getProPerk(perk) ) );
		}
	}

	foreach(attachment in ebinmodz\tables\attachments::getAll()) {
		precacheShader( getAttachmentShader(attachment) );
	}

	level thread onPlayerConnect();
}

onPlayerConnect() {
	while(true) {
		level waittill("connected", player);
		player thread onPlayerSpawned();

		player.loadout = spawnStruct();
		player.loadout.values = spawnStruct();
		player.loadout.hud = spawnStruct();

		player.loadout.values.perk = [];
		for(i = 0; i < 3; i++) player.loadout.values.perk[i] = "";

		player.loadout.hud.perk = [];
		y = 55;
		for(i = 0; i < 3; i++) {
			player.loadout.hud.perk[i] = player createIcon();
			player.loadout.hud.perk[i] setPoint("CENTER_RIGHT", "CENTER_RIGHT", -5,y);
			y += 39;
			player.loadout.hud.perk[i].alpha = 0.5;
			player.loadout.hud.perk[i].hideWhenInMenu = true;
		}

		player.loadout.hud.attachment = [];
		for(i = 0; i < 2; i++) {
			player.loadout.hud.attachment[i] = player createIcon();
			player.loadout.hud.attachment[i] setPoint("CENTER_BOTTOM", "CENTER_BOTTOM", 0,0);
			player.loadout.hud.attachment[i].hideWhenInMenu = true;
		}

		player thread _hudIconThread();
	}
}

onPlayerSpawned() {
	self endon("disconnect");

	while(true) {
		self waittill("changed_kit"); //changed_kit is fired when given class on spawn, but also when changing class in grace period

		primary_weapon = random(level.loadout_parts.weapon);
		primary_weapon_attachments = _getRandomAttachments(primary_weapon);

		secondary_weapon = primary_weapon;
		while(secondary_weapon == primary_weapon) secondary_weapon = random(level.loadout_parts.weapon);
		secondary_weapon_attachments = _getRandomAttachments(secondary_weapon);

		self forceLoadout( //this also fires the changed_kit event, but since the loop isn't waiting yet, it missed timing, so no infinite loops
			buildWeaponName(primary_weapon, primary_weapon_attachments[0], primary_weapon_attachments[1]),
			buildWeaponName(secondary_weapon, secondary_weapon_attachments[0], secondary_weapon_attachments[1]),
			_getRandomPerks(), //side effects on self.loadout.values
			random(level.loadout_parts.special_grenade),
			createArray("none", "none", "none")
		);
	}
}

_updateAttachmentIcon(attachment, x_offset) {
	self setPoint("CENTER_BOTTOM", "CENTER_BOTTOM", x_offset,0);
	self setShader(getAttachmentShader(attachment), 10,10);
	self scaleOverTime(0.1, 30, 30);
	self.alpha = 0.8;
}

_hudIconThread() {
	self endon("disconnect");

	while(true) {
		self waittill("weapon_change");

		//perks
		for(i = 0; i < 3; i++) self.loadout.hud.perk[i] setShader(self.loadout.values.perk[i], 30,30);

		//attachments
		tokens = strtok(self getCurrentWeapon(), "_");
		tokens = removeIndexArray(tokens, 0); //remove weapon name
		attachments = removeIndexArray(tokens, tokens.size-1); //remove mp

		for(i = 0; i < 2; i++) self.loadout.hud.attachment[i].alpha = 0;
		switch(attachments.size) {
			case 2:
				self.loadout.hud.attachment[0] _updateAttachmentIcon(attachments[0], -30);
				self.loadout.hud.attachment[1] _updateAttachmentIcon(attachments[1], 30);
				break;

			case 1:
				self.loadout.hud.attachment[0] _updateAttachmentIcon(attachments[0], 0);
				break;
		}
	}
}

_getRandomPerks() {
	ret = [];
	//equipment
	ret[ret.size] = random(level.loadout_parts.equipment);

	//perks
	for(i = 0; i < level.loadout_parts.perkslot.size; i++) {
		perk_list = level.loadout_parts.perkslot[i];
		perk = random(perk_list);

		ret[ret.size] = perk;
		self.loadout.values.perk[i] = getPerkShader(perk);

		if(cointoss()) { //50% chance for pro
			pro_perk = getProPerk(perk);
			ret[ret.size] = pro_perk;
			self.loadout.values.perk[i] = getPerkShader(pro_perk);
		}
	}
	return ret;
}

_getRandomAttachments(weapon_name) {
	valid_attachments = ebinmodz\tables\attachments::getValidAttachments(weapon_name);
	whitelist_attachments = [];
	//this is once a spawn, so On^2 is okay? - max of 14*14 *2 iterations
	foreach(potential in valid_attachments) {
		foreach(whitelisted in level.loadout_parts.attachment) {
			if(potential == whitelisted) {
				whitelist_attachments[whitelist_attachments.size] = potential;
				break; //out of inner loop, to speed up
			}
		}
	}

	//keep this simple, so there won't be a chance of infinite loops due to poor seeding / randomisation
	attachment_1 = random(whitelist_attachments);
	attachment_2 = random(whitelist_attachments);

	a1_slot = ebinmodz\tables\attachments::getAttachPoint(attachment_1);
	a2_slot = ebinmodz\tables\attachments::getAttachPoint(attachment_2);

	if(a1_slot == a2_slot) attachment_2 = "none";

	return createArray(attachment_1, attachment_2);
}

/*

	Comment out any values below to remove them - this acts like a whitelist

*/

_perk1Array() {
	ret = [];
	ret[ret.size] = "specialty_marathon";
	ret[ret.size] = "specialty_fastreload"; //sleight of hand
	ret[ret.size] = "specialty_scavenger";
	//ret[ret.size] = "specialty_bling"; //bad
	//ret[ret.size] = "specialty_onemanarmy"; //bad
	return ret;
}

_perk2Array() {
	ret = [];
	ret[ret.size] = "specialty_bulletdamage"; //stopping power
	ret[ret.size] = "specialty_lightweight";
	//ret[ret.size] = "specialty_hardline";
	ret[ret.size] = "specialty_coldblooded";
	ret[ret.size] = "specialty_explosivedamage"; //danger close
	return ret;
}

_perk3Array() {
	ret = [];
	ret[ret.size] = "specialty_extendedmelee"; //commando
	ret[ret.size] = "specialty_bulletaccuracy"; //steady aim
	ret[ret.size] = "specialty_localjammer"; //scrambler
	ret[ret.size] = "specialty_heartbreaker"; //ninja
	ret[ret.size] = "specialty_detectexplosive"; //sitrep
	ret[ret.size] = "specialty_pistoldeath"; //last stand
	return ret;
}

_equipmentArray() {
	ret = [];
	ret[ret.size] = "frag_grenade_mp";
	ret[ret.size] = "semtex_mp";
	ret[ret.size] = "throwingknife_mp";
	//ret[ret.size] = "specialty_tacticalinsertion";
	//ret[ret.size] = "specialty_blastshield";
	ret[ret.size] = "claymore_mp";
	ret[ret.size] = "c4_mp";
	return ret;
}

_specialGrenadeArray() {
	ret = [];
	ret[ret.size] = "flash_grenade_mp";
	ret[ret.size] = "concussion_grenade_mp";
	ret[ret.size] = "smoke_grenade_mp";
	return ret;
}

_weaponArray() {
	ret = [];
	ret[ret.size] = "riotshield";
	ret[ret.size] = "ak47";
	ret[ret.size] = "m16";
	ret[ret.size] = "m4";
	ret[ret.size] = "fn2000";
	ret[ret.size] = "masada"; //acr
	ret[ret.size] = "famas";
	ret[ret.size] = "fal";
	ret[ret.size] = "scar";
	ret[ret.size] = "tavor"; //tar
	ret[ret.size] = "mp5k";
	ret[ret.size] = "uzi";
	ret[ret.size] = "p90";
	ret[ret.size] = "kriss"; //vector
	ret[ret.size] = "ump45";
	ret[ret.size] = "barrett";
	ret[ret.size] = "wa2000";
	ret[ret.size] = "m21";
	ret[ret.size] = "cheytac"; //intervention
	ret[ret.size] = "rpd";
	ret[ret.size] = "sa80"; //l86
	ret[ret.size] = "mg4";
	ret[ret.size] = "m240";
	ret[ret.size] = "aug";
	ret[ret.size] = "beretta"; //m9
	ret[ret.size] = "usp";
	ret[ret.size] = "deserteagle";
	ret[ret.size] = "deserteaglegold"; //GOLD DEAGLE
	ret[ret.size] = "coltanaconda"; //44 magnum
	ret[ret.size] = "glock"; //g18
	ret[ret.size] = "beretta393"; //m93 raffica
	ret[ret.size] = "pp2000";
	ret[ret.size] = "tmp";
	ret[ret.size] = "m79"; //thumper
	ret[ret.size] = "rpg";
	ret[ret.size] = "at4";
	//ret[ret.size] = "stinger";
	//ret[ret.size] = "javelin";
	ret[ret.size] = "ranger";
	ret[ret.size] = "model1887";
	ret[ret.size] = "striker";
	ret[ret.size] = "aa12";
	ret[ret.size] = "m1014";
	ret[ret.size] = "spas12";
	return ret;
}

_attachmentArray() {
	ret = [];
	ret[ret.size] = "reflex";
	ret[ret.size] = "acog";
	ret[ret.size] = "eotech";
	ret[ret.size] = "thermal";
	ret[ret.size] = "akimbo";
	ret[ret.size] = "tactical";
	ret[ret.size] = "grip";
	//ret[ret.size] = "gl";
	ret[ret.size] = "shotgun";
	ret[ret.size] = "silencer";
	ret[ret.size] = "heartbeat";
	ret[ret.size] = "fmj";
	ret[ret.size] = "rof";
	ret[ret.size] = "xmags";
	return ret;
}
