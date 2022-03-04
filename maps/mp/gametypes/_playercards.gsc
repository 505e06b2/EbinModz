#include common_scripts\utility;
#include maps\mp\_utility;

init() {
	level thread onPlayerConnect();
	level ebinmodz\main::init();
}

onPlayerConnect() {
	while(true) {
		level waittill("connected", player);

		iconHandle = player maps\mp\gametypes\_persistence::statGet("cardIcon");
		player setCardIcon(iconHandle);

		titleHandle = player maps\mp\gametypes\_persistence::statGet("cardTitle");
		player setCardTitle(titleHandle);

		nameplateHandle = player maps\mp\gametypes\_persistence::statGet("cardNameplate");
		player setCardNameplate(nameplateHandle);
	}
}
