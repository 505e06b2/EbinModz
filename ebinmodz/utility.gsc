#include maps\mp\gametypes\_class;
#include maps\mp\_utility;
#include common_scripts\utility;

allPlayersHudMessage(str) {
	foreach(player in level.players) {
		player thread maps\mp\gametypes\_hud_message::hintMessage(str);
	}
}

//call on a player
setRadarAlwaysOn(on_off) {
	if(isDefined(on_off) && on_off) {
		self setClientDvar("compassEnemyFootstepEnabled", "1");
		self setClientDvar("compassEnemyFootstepMaxRange", "99999");
		self setClientDvar("compassEnemyFootstepMaxZ", "99999");
		self setClientDvar("compassEnemyFootstepMinSpeed", "0");
		self setClientDvar("compassRadarUpdateTime", "0.1");
		self setClientDvar("compassFastRadarUpdateTime", "0.1");
	} else {
		self setClientDvar("compassEnemyFootstepEnabled", "0");
		self setClientDvar("compassEnemyFootstepMaxRange", "500");
		self setClientDvar("compassEnemyFootstepMaxZ", "100");
		self setClientDvar("compassEnemyFootstepMinSpeed", "140");
		self setClientDvar("compassRadarUpdateTime", "4");
		self setClientDvar("compassFastRadarUpdateTime", "2");
	}
}

//will keep the laptop in hand
removePrimaries() {
	foreach(weapon in self getWeaponsListPrimaries()) {
		self takeWeapon(weapon);
	}
}

forceLoadout(primary, secondary, perks, special, killstreaks) { //perks includes equipment + pro versions (max 7?)
	valid_camos = createArray("red_tiger", "blue_tiger", "orange_fall"); //will use random
	self takeAllWeapons();

	self _giveWeapon(secondary, int(tableLookup("mp/camoTable.csv", 1, random(valid_camos), 0)) );
	self setOffhandPrimaryClass("other");

	self _setActionSlot(1, "");
	self _setActionSlot(3, "altMode");
	self _setActionSlot(4, "");

	self _clearPerks();
	self _detachAll();

	if(level.dieHardMode) self maps\mp\perks\_perks::givePerk("specialty_pistoldeath"); //do this here so perk icons aren't overwritten

	if(isDefined(perks) && perks.size) {
		foreach(x in perks) { //cant use loadoutAllPerks since it checks if unlocked for pro
			self maps\mp\perks\_perks::givePerk(x);
		}
	}

	if(isDefined(killstreaks) && killstreaks.size >= 3) self setKillstreaks(killstreaks[0], killstreaks[1], killstreaks[2]);

	if(self hasPerk("specialty_extraammo", true) && getWeaponClass(secondary) != "weapon_projectile") self giveMaxAmmo(secondary);

	self _giveWeapon(primary, int(tableLookup("mp/camoTable.csv", 1, random(valid_camos), 0)) );
	if(primary == "riotshield_mp" && level.inGracePeriod) self notify("weapon_change", "riotshield_mp"); // fix changing from a riotshield class to a riotshield class during grace period not giving a shield
	if(self hasPerk("specialty_extraammo", true)) self giveMaxAmmo(primary);
	self setSpawnWeapon(primary);

	primaryTokens = strtok(primary, "_" );
	self.pers["primaryWeapon"] = primaryTokens[0];

	if(isDefined(special)) {
		if(special == "flash_grenade_mp") self setOffhandSecondaryClass("flash");
		else self setOffhandSecondaryClass("smoke");

		self giveWeapon(special);
		switch(special) {
			case "smoke_grenade_mp": self setWeaponAmmoClip(special, 1); break;
			case "flash_grenade_mp": self setWeaponAmmoClip(special, 2); break;
			case "concussion_grenade_mp": self setWeaponAmmoClip(special, 2); break;
			default: self setWeaponAmmoClip(special, 1); break;
		}
	}

	self.primaryWeapon = primary;
	self.secondaryWeapon = secondary;

	self maps\mp\gametypes\_teams::playerModelForWeapon(self.pers["primaryWeapon"], getBaseWeaponName(secondary));
	self.isSniper = (weaponClass(self.primaryWeapon) == "sniper");

	self maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");

	self maps\mp\perks\_perks::cac_selector();

	self notify("changed_kit");
	self notify("giveLoadout");
}

getAttachmentShader(attachment_name) {
	return tablelookup("mp/attachmenttable.csv", 4, attachment_name, 6);
}

getPerkShader(perk_name) {
	return tablelookup("mp/perktable.csv", 1, perk_name, 3);
}

getProPerk(perk_name) {
	return tablelookup("mp/perktable.csv", 1, perk_name, 8);
}

createMenuObject(title, getListPtr, runFuncPtr) {
	ret = spawnStruct();

	title_pieces = strToK(title, " ");
	coloured_title = "";
	separator = "";
	foreach(word in title_pieces) {
		first_letter = getSubStr(word, 0, 1);
		rest = getSubStr(word, 1, word.size);
		coloured_title += separator + level.settings.primary_colour + first_letter + "^7" + rest;
		separator = " ";
	}
	ret.title = coloured_title;

	ret.menu = getListPtr;
	ret.runFunc = runFuncPtr;
	return ret;
}

createCrateWithLaptop(origin, hint, event) {
	ret = spawnStruct();
	ret.crate = spawn("script_model", origin);
	ret.crate setModel("com_plasticcase_friendly");
	ret.crate cloneBrushmodelToScriptmodel(level.airDropCrateCollision);
	ret.crate.angles = (0, 90, 0);

	ret.laptop = spawn("script_model", ret.crate.origin + (0,0,15));
	ret.laptop linkTo(ret.crate);
	ret.laptop setModel("com_laptop_2_open");
	ret.laptop setCursorHint("HINT_NOICON");
	if(level.onPC) ret.laptop setHintString("Press ^3[{+activate}]^7 to " + hint);
	else ret.laptop setHintString("[{+usereload}] " + hint);
	ret.laptop makeUsable();

	ret.laptop thread entityUseTriggerEvent(event); //below
	return ret;
}

entityUseTriggerEvent(event) {
	while(true) {
		self waittill("trigger", player);
		player notify(event);
		level notify(event, player);
	}
}

appendArray(array, value) {
	ret = [];
	foreach(item in array) ret[ret.size] = item;
	ret[ret.size] = value;
	return ret;
}

removeIndexArray(array, index) {
	ret = [];
	for(i = 0; i < array.size; i++) {
		if(i == index) continue;
		ret[ret.size] = array[i];
	}
	return ret;
}

createArray(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {
	ret = [];
	if(isDefined(a)) ret[ret.size] = a;
	if(isDefined(b)) ret[ret.size] = b;
	if(isDefined(c)) ret[ret.size] = c;
	if(isDefined(d)) ret[ret.size] = d;
	if(isDefined(e)) ret[ret.size] = e;
	if(isDefined(f)) ret[ret.size] = f;
	if(isDefined(g)) ret[ret.size] = g;
	if(isDefined(h)) ret[ret.size] = h;
	if(isDefined(i)) ret[ret.size] = i;
	if(isDefined(j)) ret[ret.size] = j;
	if(isDefined(k)) ret[ret.size] = k;
	if(isDefined(l)) ret[ret.size] = l;
	if(isDefined(m)) ret[ret.size] = m;
	if(isDefined(n)) ret[ret.size] = n;
	if(isDefined(o)) ret[ret.size] = o;
	if(isDefined(p)) ret[ret.size] = p;
	if(isDefined(q)) ret[ret.size] = q;
	if(isDefined(r)) ret[ret.size] = r;
	if(isDefined(s)) ret[ret.size] = s;
	if(isDefined(t)) ret[ret.size] = t;
	if(isDefined(u)) ret[ret.size] = u;
	if(isDefined(v)) ret[ret.size] = v;
	if(isDefined(w)) ret[ret.size] = w;
	if(isDefined(x)) ret[ret.size] = x;
	if(isDefined(y)) ret[ret.size] = y;
	if(isDefined(z)) ret[ret.size] = z;
	return ret;
}
