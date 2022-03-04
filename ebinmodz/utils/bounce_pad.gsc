//specifically used for the CoDJumper gamemode - look in maps/mp/gametypes/codjumper.gsc
//to be used like a C language class type thing (wrapping structs)

#include common_scripts\utility;

new(owner) {
	initial_pos = (0,0,-1000); //spawn disabled

	ret = spawnStruct();
	if(!isDefined(owner)) ret.owner = self;
	else ret.owner = owner;

	ret.center = spawn("script_model", initial_pos);

	ret.main = ret _create_box("friendly", 0);
	ret.main_enemy = ret _create_box("enemy", 0);

	ret.cross = ret _create_box("friendly", 90);
	ret.cross_enemy = ret _create_box("enemy", 90);

	ret.trigger = undefined;

	ret thread _colour_think();
	ret thread _rotate_think();
	return ret;
}

//package as self
update(position) {
	//if given trace, it is possible to use the normal for a "proper" bounce, and not just over the Z-Axis - not very useful and too complex for what this is?
	trigger_radius = 30;

	if(isDefined(self.trigger)) self.trigger delete();
	self.trigger = spawn("trigger_radius", position, 0, trigger_radius, trigger_radius*2);

	self.center.origin = position;

	self notify("bounce_pad:think_update"); //clear other instances of _think
	self thread _think();
}

//package as self
del() {
	self notify("death"); //do before anything becomes undefined
	self notify("bounce_pad:think_update");
	if(isDefined(self.center)) self.center delete();
	if(isDefined(self.main)) self.main delete();
	if(isDefined(self.cross)) self.cross delete();
	if(isDefined(self.main_enemy)) self.main_enemy delete();
	if(isDefined(self.cross_enemy)) self.cross_enemy delete();
	if(isDefined(self.trigger)) self.trigger delete();
}

_create_box(type, yaw) {
	ret = spawn("script_model", self.center.origin);
	ret.angles = (0,yaw,0);
	ret setModel("com_plasticcase_" + type);
	ret linkTo(self.center);
	return ret;
}

_think() {
	self.owner endon("disconnect"); //if owner disconns
	self endon("bounce_pad:think_update");

	while(true) {
		self.trigger waittill("trigger", player);
		current_velocity = player getVelocity();
		if(current_velocity[2] >= 0) continue;
		player setVelocity((current_velocity[0], current_velocity[1], abs(current_velocity[2])));
	}
}

_colour_think() {
	self.owner endon("disconnect"); //if owner disconns
	self endon("death"); //deleted

	self _colour_check();

	while(true) {
		level waittill("joined_team");
		self _colour_check();
	}
}

_rotate_think() {
	self.owner endon("disconnect"); //if owner disconns
	self endon("death"); //deleted

	yaw = 0;

	while(true) {
		yaw += 90;
		while(yaw >= 360) yaw -= 360;
		self.center rotateTo((0, yaw, 0), 0.5);
		wait 0.5;
	}
}

_colour_check() {
	self.main hide();
	self.main_enemy hide();
	self.cross hide();
	self.cross_enemy hide();

	foreach(player in level.players) {
		if(player == self.owner) {
			self.main showToPlayer(player);
			self.cross showToPlayer(player);
		} else {
			self.main_enemy showToPlayer(player);
			self.cross_enemy showToPlayer(player);
		}
	}
}
