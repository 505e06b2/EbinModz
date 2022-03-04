#include ebinmodz\utility;
#include maps\mp\killstreaks\_airdrop;

getList() { //will run roughly once a frame
	ret = [];
	ret[ret.size] = "Authorise All";
	ret[ret.size] = "Deauthorise All";
	ret[ret.size] = "Fast Restart";
	ret[ret.size] = "Map Restart";
	ret[ret.size] = "Toggle Jump Height";
	ret[ret.size] = "Toggle Sprint Speed";
	ret[ret.size] = "Toggle Knockback";
	ret[ret.size] = "Remove All Care Packages";
	ret[ret.size] = "Remove All Killstreaks";
	ret[ret.size] = "Give EMP";
	ret[ret.size] = "Give Nuke";
	return ret;
}

//use player context
runFunc(index) {
	switch(index) {
		case 0:
			foreach(player in level.players) {
				if(player.menu.access_level != "") continue;
				player.menu.access_level = "vip";
				player thread maps\mp\gametypes\_hud_message::hintMessage("Authorised, enjoy VIP");
				player suicide();
				self iPrintLn(player.name + " given VIP");
			}
			self iPrintLn("Done");
			break;

		case 1:
			foreach(player in level.players) {
				if(player.menu.access_level == "vip") {
					player.menu.access_level = "";
					//remove all privileges
					player.care_package_bullets = undefined;
					player notify("disable_care_package_bullets");
					player thread maps\mp\gametypes\_hud_message::hintMessage("^1Deauthorised");
					player suicide();
					self iPrintLn(player.name + " deauthorised");
				}
			}
			self iPrintLn("Done");
			break;


		case 2:
			map_restart(false);
			break;

		case 3:
			map(getDvar("mapname"));
			break;

		case 4:
			if(getDvar("jump_height") != "39") {
				message = "Jump Height Reset";
				setDvar("jump_height", 39);
				setDvar("bg_fallDamageMaxHeight", 300);
				setDvar("bg_fallDamageMinHeight", 128);
			} else {
				message = "Altered Jump Height";
				setDvar("jump_height", 390);
				setDvar("bg_fallDamageMaxHeight", 99999);
				setDvar("bg_fallDamageMinHeight", 99999);
			}
			allPlayersHudMessage(message);
			break;

		case 5:
			if(getDvar("player_sprintSpeedScale") != "1.5") {
				message = "Sprint Speed Reset";
				setDvar("player_sprintSpeedScale", 1.5);
				setDvar("player_sprintUnlimited", 0);
			} else {
				message = "Altered Sprint Speed";
				setDvar("player_sprintSpeedScale", 4);
				setDvar("player_sprintUnlimited", 1);
			}
			allPlayersHudMessage(message);
			break;

		case 6:
			if(getDvar("g_knockback") != "1000") {
				message = "Knockback Reset";
				setDvar("g_knockback", 1000);
			} else {
				message = "Altered Knockback";
				setDvar("g_knockback", 99999);
			}
			allPlayersHudMessage(message);
			break;

		case 7:
			old_crates = getEntArray("care_package", "targetname");
			foreach(crate in old_crates) crate deleteCrate(); //_airdrop
			allPlayersHudMessage("Map cleared of crates");
			break;

		case 8:
			foreach(player in level.players) {
				player maps\mp\killstreaks\_killstreaks::clearKillstreaks();
				player setActionSlot(4, ""); //remove icon
			}
			level maps\mp\killstreaks\_emp::destroyActiveVehicles();
			allPlayersHudMessage("Removed all killstreaks");
			break;

		case 9:
			self maps\mp\killstreaks\_killstreaks::giveKillstreak("emp", false);
			self iPrintLn("Gave EMP");
			break;

		case 10:
			allPlayersHudMessage(self.name + " is salty lol");
			self maps\mp\killstreaks\_killstreaks::giveKillstreak("nuke", false);
			self iPrintLn("Gave Nuke");
			break;

		default:
			self iPrintLn("^1No function for that Admin menu option");
			break;
	}
}
