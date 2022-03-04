#include ebinmodz\utility;
#include common_scripts\utility;

getList() {
	ret = [];
	ret[ret.size] = "Funny Gunny";
	ret[ret.size] = "Handy";
	ret[ret.size] = "Become Tortoise";
	ret[ret.size] = "liek 2 snip";
	ret[ret.size] = "Gold Deagle";
	return ret;
}

//use player context
runFunc(index) {
	switch(index) {
		case 0:
			self removePrimaries();
			self giveWeapon("m79_mp", 0, true); //akimbo
			self thread _akimboThumpersAmmo();
			self iPrintLn("Given Akimbo Thumpers");
			break;

		case 1:
			self removePrimaries();
			self giveWeapon("defaultweapon_mp", 0, true);
			self iPrintLn("2 many hands lol");
			break;

		case 2:
			self removePrimaries();
			self giveWeapon("riotshield_mp", 0);
			self AttachShieldModel("weapon_riot_shield_mp", "tag_shield_back");
			self iPrintLn("Riot shield in hands and on back");
			break;

		case 3:
			self removePrimaries();
			self giveWeapon("cheytac_fmj_xmags_mp", 8, true);
			self iPrintLn("Intervention FMJ + Extended Mags");
			break;

		case 4:
			self removePrimaries();
			self giveWeapon("deserteaglegold_mp", 0, true);
			self iPrintLn("Gold Desert Eagle");
			break;

		default:
			self iPrintLn("^1No function for that menu option");
			break;
	}
}

_akimboThumpersAmmo() {
	self endon("disconnect");
	self endon("death");

	while(true) {
		self giveMaxAmmo("m79_mp");
		wait 1/30; //30fps
	}
}
