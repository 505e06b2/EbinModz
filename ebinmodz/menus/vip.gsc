#include ebinmodz\utility;
#include maps\mp\killstreaks\_airdrop;
#include common_scripts\utility;

getList() {
	ret = [];
	ret[ret.size] = "Toggle Care Package Bullets";
	ret[ret.size] = "Toggle Money Trail";
	ret[ret.size] = "Toggle UFO Mode";
	return ret;
}

//use player context
runFunc(index) {
	switch(index) {
		case 0:
			if(isDefined(self.care_package_bullets)) {
				self.care_package_bullets = undefined;
				self iPrintLn("Care Package Bullets Off");
				self notify("disable_care_package_bullets");
			} else {
				self.care_package_bullets = true;
				self iPrintLn("Care Package Bullets On");
				self thread _shootCarePackages();
			}
			break;

		case 1:
			if(isDefined(self.money_trail)) {
				self.money_trail = undefined;
				self iPrintLn("Money Trail Off");
				self notify("disable_money_trail");
			} else {
				self iPrintLn("Money Trail On");
				self.money_trail = true;
				self thread _moneyTrail();
			}
			break;

		case 2:
			if(isDefined(self.ufo_mode)) {
				self.ufo_mode = undefined;
				self iPrintLn("UFO Mode Off");
				self notify("disable_ufo_mode");
			} else {
				self iPrintLn("UFO Mode On - Hold [{+frag}] to fly forwards");
				self.ufo_mode = true;
				self thread _ufo();
			}
			break;

		default:
			self iPrintLn("^1No function for that menu option");
			break;
	}
}

_shootCarePackages() {
	self endon("disconnect");
	self endon("disable_care_package_bullets");

	package_array = [];

	while(true) {
		self waittill("weapon_fired");
		while(package_array.size >= 4) { //keep deleting them
			package_array[0] deleteCrate(); //_airdrop
			package_array = removeIndexArray(package_array, 0);
		}

		player_angles = self getPlayerAngles();
		player_facing = anglesToForward(player_angles);
		object_offset = vector_multiply(player_facing, 100);
		object_destination = bulletTrace(self getEye(), self getEye() + object_offset, false, self)["position"];

		drop_type = "airdrop";
		package_killstreak = getRandomCrateType(drop_type); //_airdrop
		package = createAirDropCrate(self, drop_type, package_killstreak, object_destination); //_airdrop
		package.angles = (player_angles[0]+90, player_angles[1], player_angles[2]); //raw, yaw, pitch
		package physicsLaunchServer((0,0,0), vector_multiply(player_facing, 800));
		package thread physicsWaiter(drop_type, package_killstreak); //_airdrop

		package_array = appendArray(package_array, package);
	}
}

_moneyTrail() {
	self endon("disconnect");
	self endon("disable_money_trail");

	while(true) {
		playFx(level._effect["money"], self getTagOrigin("j_spine4"));
		wait 1/5; //5fps
	}
}

_ufo() {
	self endon("disconnect");
	self endon("ufo_mode_off");

	while(true) {
		if(!self.menu.open && self fragButtonPressed()) {
			current_origin = self getOrigin();
			forward = anglesToForward(self getPlayerAngles());
			self setOrigin(current_origin + vector_multiply(forward, 50));
			self setVelocity((0,0,0));
		}
		wait 1/30;
	}
}
