//specifically used for the rpg gamemode - look in maps/mp/gametypes/rpg.gsc
//to be used like a C language class type thing (wrapping structs)

//specifically used for the CoDJumper gamemode - look in maps/mp/gametypes/codjumper.gsc
//to be used like a C language class type thing (wrapping structs)

#include maps\mp\_utility;

//player as self
new(origin, shader, type) { //type = "2d" / "3d" / "both"
	ret = spawnStruct();

	if(!isDefined(type)) type = "both";
	type = toLower(type);

	if(type != "2d") { //don't just want 2d (this is 3d)
		ret.hud_icon = newClientHudElem(self);
		ret.hud_icon.elemType = "icon";
		ret.hud_icon.x = origin[0];
		ret.hud_icon.y = origin[1];
		ret.hud_icon.z = origin[2] + 20;
		ret.hud_icon.alpha = 1;
		ret.hud_icon setShader(shader, 64, 64);
		ret.hud_icon.shader = shader;
		ret.hud_icon.hideWhenInMenu = true;
		ret.hud_icon setWaypoint(true, true, false);
	}

	if(type != "3d") { //don't just want 3d (this is 2d)
		current_objective_id = maps\mp\gametypes\_gameobjects::getNextObjID();
		objective_add(current_objective_id, "invisible", (0,0,0));
		objective_position(current_objective_id, origin);
		objective_state(current_objective_id, "active");
		objective_icon(current_objective_id, shader);
		ret.objective_icon = current_objective_id;
	}

	return ret;
}

//waypoint as self
del() {
	if(isDefined(self.hud_icon)) self.hud_icon destroy();
	if(isDefined(self.objective_icon)) _objective_delete(self.objective_icon);
}
