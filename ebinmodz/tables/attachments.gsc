/*
	Why does this exist? So other files aren't bogged down with huge line counts
	Why not just use a csv? Because they can't be easily altered since they must be packed into a .ff - this hurts compatibility
	Files like this should be written for speed only (use a switch) - do not be concerned by maintainability
*/

getAll() {
	ret = [];
	ret[ret.size] = "reflex";
	ret[ret.size] = "acog";
	ret[ret.size] = "eotech";
	ret[ret.size] = "thermal";
	ret[ret.size] = "akimbo";
	ret[ret.size] = "tactical";
	ret[ret.size] = "grip";
	ret[ret.size] = "gl";
	ret[ret.size] = "shotgun";
	ret[ret.size] = "silencer";
	ret[ret.size] = "heartbeat";
	ret[ret.size] = "fmj";
	ret[ret.size] = "rof";
	ret[ret.size] = "xmags";
	return ret;
}

getAttachPoint(attachment_name) {
	switch(attachment_name) {
		case "reflex":
		case "acog":
		case "eotech":
		case "thermal":
		case "akimbo": //because it conflicts with sights
		case "tactical": //because of akimbo on pistols
			return "rail";

		case "grip":
		case "gl":
		case "shotgun":
			return "undermount";

		//unique
		case "silencer":
		case "heartbeat":
		case "fmj":
		case "rof":
		case "xmags":
			return attachment_name;
	}
	return "none";
}

//can just use tablelookup("mp/attachmenttable.csv", 4, attachment_name, 6); - helper is in ebinmodz\utility
getShader(attachment_name) {
	switch(attachment_name) {
		//edge cases
		case "none": return "weapon_missing_image";
		case "gl":   return "weapon_attachment_m203";

		//every
		default: return "weapon_attachment_" + attachment_name;
	}
}

getValidAttachments(weapon_name) {
	ret = [];
	//weaponclass isn't precise enough
	switch(weapon_name) {
		case "m4":
		case "famas":
		case "scar":
		case "tavor":
		case "fal":
		case "m16":
		case "masada":
		case "fn2000":
		case "ak47":
			ret[ret.size] = "gl";
			ret[ret.size] = "reflex";
			ret[ret.size] = "silencer";
			ret[ret.size] = "acog";
			ret[ret.size] = "fmj";
			ret[ret.size] = "shotgun";
			ret[ret.size] = "eotech";
			ret[ret.size] = "heartbeat";
			ret[ret.size] = "thermal";
			ret[ret.size] = "xmags";
			return ret;

		case "mp5k":
		case "ump45":
		case "kriss":
		case "p90":
		case "uzi":
			ret[ret.size] = "rof";
			ret[ret.size] = "reflex";
			ret[ret.size] = "silencer";
			ret[ret.size] = "acog";
			ret[ret.size] = "fmj";
			ret[ret.size] = "akimbo";
			ret[ret.size] = "eotech";
			ret[ret.size] = "thermal";
			ret[ret.size] = "xmags";
			return ret;

		case "sa80":
		case "rpd":
		case "mg4":
		case "aug":
		case "m240":
			ret[ret.size] = "grip";
			ret[ret.size] = "reflex";
			ret[ret.size] = "silencer";
			ret[ret.size] = "acog";
			ret[ret.size] = "fmj";
			ret[ret.size] = "eotech";
			ret[ret.size] = "heartbeat";
			ret[ret.size] = "thermal";
			ret[ret.size] = "xmags";
			return ret;

		case "cheytac":
		case "barrett":
		case "wa2000":
		case "m21":
			ret[ret.size] = "silencer";
			ret[ret.size] = "acog";
			ret[ret.size] = "fmj";
			ret[ret.size] = "heartbeat";
			ret[ret.size] = "thermal";
			ret[ret.size] = "xmags";
			return ret;

		//pistols
		case "usp":
		case "beretta":
			ret[ret.size] = "fmj";
			ret[ret.size] = "silencer";
			ret[ret.size] = "tactical";
			ret[ret.size] = "akimbo";
			ret[ret.size] = "xmags";
			return ret;

		//big pistols
		case "coltanaconda":
		case "deserteagle":
			ret[ret.size] = "fmj";
			ret[ret.size] = "tactical";
			ret[ret.size] = "akimbo";
			return ret;

		//machine pistols
		case "glock":
		case "beretta393":
		case "pp2000":
		case "tmp":
			ret[ret.size] = "reflex";
			ret[ret.size] = "silencer";
			ret[ret.size] = "fmj";
			ret[ret.size] = "akimbo";
			ret[ret.size] = "eotech";
			ret[ret.size] = "xmags";
			return ret;

		//shotgun
		case "spas12":
		case "aa12":
		case "striker":
		case "m1014":
			ret[ret.size] = "reflex";
			ret[ret.size] = "silencer";
			ret[ret.size] = "grip";
			ret[ret.size] = "fmj";
			ret[ret.size] = "eotech";
			ret[ret.size] = "xmags";
			return ret;

		//ranger_model
		case "ranger":
		case "model1887":
			ret[ret.size] = "fmj";
			ret[ret.size] = "akimbo";
			return ret;
	}
	return ret;
}
