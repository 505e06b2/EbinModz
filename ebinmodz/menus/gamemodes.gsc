#include ebinmodz\utility;

getList() { //will run roughly once a frame
	ret = [];
	ret[ret.size] = "Free-For-All";
	ret[ret.size] = "Team Deathmatch";
	ret[ret.size] = "[WIP] [Custom] Dodgeball";
	ret[ret.size] = "[Custom] Random Loadouts";
	ret[ret.size] = "[Custom] CoDJumper";
	ret[ret.size] = "[Custom] All or Nothing";
	ret[ret.size] = "[WIP] `nwewa[Custom] The Zone: RPG";
	return ret;
}

forceStartGametype(gametype_name) {
	switch(gametype_name) {
		case "dodgeball":
			maps\mp\gametypes\dodgeball::main();
			break;

		case "random":
			maps\mp\gametypes\random::main();
			break;

		case "codjumper":
			maps\mp\gametypes\codjumper::main();
			break;

		case "aon":
			maps\mp\gametypes\aon::main();
			break;

		case "rpg":
			maps\mp\gametypes\rpg::main();
			break;
	}
}

//use player context
runFunc(index) {
	gametype = undefined;
	map_needed = undefined;
	base_gametype = undefined;
	switch(index) {
		case 0:
			gametype = "dm";
			base_gametype = "dm";
			break;

		case 1:
			gametype = "war";
			base_gametype = "war";
			break;

		case 2:
			gametype = "dodgeball";
			map_needed = maps\mp\gametypes\dodgeball::needMap();
			base_gametype = maps\mp\gametypes\dodgeball::baseGametype();
			break;

		case 3:
			gametype = "random";
			map_needed = maps\mp\gametypes\random::needMap();
			base_gametype = maps\mp\gametypes\random::baseGametype();
			break;

		case 4:
			gametype = "codjumper";
			map_needed = maps\mp\gametypes\codjumper::needMap();
			base_gametype = maps\mp\gametypes\codjumper::baseGametype();
			break;

		case 5:
			gametype = "aon";
			map_needed = maps\mp\gametypes\aon::needMap();
			base_gametype = maps\mp\gametypes\aon::baseGametype();
			break;

		case 6:
			gametype = "rpg";
			map_needed = maps\mp\gametypes\rpg::needMap();
			base_gametype = maps\mp\gametypes\rpg::baseGametype();
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

	if(getDvarInt("dedicated") > 0) {
		setDvar("g_gametype", gametype);
	} else {
		setDvar("g_gametype", base_gametype);
		setDvar("ebin_custom_gametype", gametype);
	}
	setDvar("ui_gametype", gametype);

	if(!isDefined(map_needed)) map_needed = getDvar("mapname");
	map(map_needed);
}
