#include ebinmodz\utility;

getList() {
	ret = [];
	ret[ret.size] = "Afghan"; //0
	ret[ret.size] = "Derail";
	ret[ret.size] = "Estate";
	ret[ret.size] = "Favela";
	ret[ret.size] = "Highrise";
	ret[ret.size] = "Invasion"; //5
	ret[ret.size] = "Karachi";
	ret[ret.size] = "Quarry";
	ret[ret.size] = "Rundown";
	ret[ret.size] = "Rust";
	ret[ret.size] = "Scrapyard"; //10
	ret[ret.size] = "Skidrow";
	ret[ret.size] = "Sub Base";
	ret[ret.size] = "Terminal";
	ret[ret.size] = "Underpass";
	ret[ret.size] = "Wasteland"; //15
	return ret;
}

//use player context
runFunc(index) {
	map_ff = undefined;
	switch(index) {
		case 0: map_ff = "mp_afghan"; break;
		case 1: map_ff = "mp_derail"; break;
		case 2: map_ff = "mp_estate"; break;
		case 3: map_ff = "mp_favela"; break;
		case 4: map_ff = "mp_highrise"; break;
		case 5: map_ff = "mp_invasion"; break;
		case 6: map_ff = "mp_checkpoint"; break;
		case 7: map_ff = "mp_quarry"; break;
		case 8: map_ff = "mp_rundown"; break;
		case 9: map_ff = "mp_rust"; break;
		case 10: map_ff = "mp_boneyard"; break;
		case 11: map_ff = "mp_nightshift"; break;
		case 12: map_ff = "mp_subbase"; break;
		case 13: map_ff = "mp_terminal"; break;
		case 14: map_ff = "mp_underpass"; break;
		case 15: map_ff = "mp_brecourt"; break;

		default:
			self iPrintLn("Invalid map id: " + index);
			return;
	}

	name = getList()[index];
	foreach(player in level.players) {
		player iPrintLnBold("Changing map to " + name);
	}
	wait 1;
	map(map_ff);
}

