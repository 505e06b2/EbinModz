#include ebinmodz\utility;

getList() { //will run roughly once a frame
	ret = [];
	ret[ret.size] = "Free-For-All";
	ret[ret.size] = "Team Deathmatch";
	ret[ret.size] = "[Custom] Dodgeball";
	ret[ret.size] = "[Custom] Random Loadouts";
	ret[ret.size] = "[Custom] CoDJumper";
	ret[ret.size] = "[Custom] All or Nothing";
	ret[ret.size] = "[Custom] The Zone: RPG";
	return ret;
}

//use player context
runFunc(index) {
	gametype = undefined;
	map_needed = undefined;
	switch(index) {
		case 0:
			gametype = "dm";
			break;

		case 1:
			gametype = "war";
			break;

		case 2:
			gametype = "dodgeball";
			map_needed = maps\mp\gametypes\dodgeball::needMap();
			break;

		case 3:
			gametype = "random";
			map_needed = maps\mp\gametypes\random::needMap();
			break;

		case 4:
			gametype = "codjumper";
			map_needed = maps\mp\gametypes\codjumper::needMap();
			break;

		case 5:
			gametype = "aon";
			map_needed = maps\mp\gametypes\aon::needMap();
			break;

		case 6:
			gametype = "rpg";
			map_needed = maps\mp\gametypes\rpg::needMap();
			break;

		default:
			self iPrintLn("^1No function for that Admin menu option");
			break;
	}

	name = getList()[index];
	foreach(player in level.players) {
		player iPrintLnBold("Changing gamemode to " + name);
	}
	wait 1;
	setDvar("g_gametype", gametype);
	setDvar("ui_gametype", gametype);
	if(!isDefined(map_needed)) map_needed = getDvar("mapname");
	map(map_needed);
}
