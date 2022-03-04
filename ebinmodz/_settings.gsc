//if you need to change something, check here first
#include ebinmodz\utility;
#include common_scripts\utility;

init() {
	level.settings = spawnStruct();
	level.settings.onPC = true; //set to false for console - mostly just changes control displays

	level.settings.primary_colour = "^1"; //colour code - ":" is for iw4x, but console won't have it
	level.settings.secondary_colour = "^5"; //colour code

	//guids
	level.settings.admins = []; //only used if hosting on dedicated server / want more than one admin
	level.settings.admins[level.settings.admins.size] = "1d1be9c2bfe01bed"; //Me - copy this line and change the guid to append to admins
	level.settings.admins[level.settings.admins.size] = "5aed656b8fad1c94"; //Neem

	level.settings._default_menus = []; //used for initial spawn
	level.settings._default_menus[""] = createArray( //pleb menu
		createMenuObject("Main", ebinmodz\menus\main::getList, ebinmodz\menus\main::runFunc)
	);
	level.settings._default_menus["vip"] = array_combine(level.settings._default_menus[""], createArray(
		createMenuObject("VIP", ebinmodz\menus\vip::getList, ebinmodz\menus\vip::runFunc),
		createMenuObject("Weapons", ebinmodz\menus\weapons::getList, ebinmodz\menus\weapons::runFunc)
	));
	level.settings._default_menus["admin"] = array_combine(level.settings._default_menus["vip"], createArray( //add to vip menu
		createMenuObject("Maps", ebinmodz\menus\map::getList, ebinmodz\menus\map::runFunc),
		createMenuObject("Gamemodes", ebinmodz\menus\gamemodes::getList, ebinmodz\menus\gamemodes::runFunc),
		createMenuObject("Admin", ebinmodz\menus\admin::getList, ebinmodz\menus\admin::runFunc) //set this last so it can be cycled left quickly
	));
}
