//Check _settings for quick fixes
#include maps\mp\gametypes\_hud_util;

init() {
	if(isDefined(level.ebinmodz_initialised)) return; //so it can be called more precisely instead of just with _playercards
	level.ebinmodz_initialised = true;

	ebinmodz\_settings::init();

	level thread onPlayerConnect();
	level thread onPlayerDisconnect();

	level.menus = level.settings._default_menus;
}

onPlayerConnect() {
	while(true) {
		level waittill("connected", player);
		player.menu = spawnStruct();
		player.menu.open = false;
		player.menu.index = 0;
		player.menu.which = 0;
		player.menu.access_level = "";
		player.menu.assets = spawnStruct();

		//hud assets
		player.menu.assets.title = player createFontString("hudbig", 1);
		player.menu.assets.title setPoint("TOP","TOP",  0,0);
		player.menu.assets.title setText(level.settings.primary_colour + "Ebin^7Modz");

		player.menu.assets.controls = player createFontString("hudsmall", 0.8);
		player.menu.assets.controls setPoint("TOP","TOP",  0,25);
		player.menu.assets.controls._default = "[{+actionslot 1}] to open";
		player.menu.assets.controls.alpha = 0.5;
		player.menu.assets.controls.hideWhenInMenu = true;

		player.menu.assets.access_level = player createFontString("hudsmall", 1);
		player.menu.assets.access_level setPoint("TOP_RIGHT","TOP_RIGHT",  -5,0);
		player.menu.assets.access_level.hideWhenInMenu = true;

		player.menu.assets.ui_title = player createFontString("hudbig", 1);
		player.menu.assets.ui_title setPoint("BOTTOM","CENTER",  0,-120);
		player.menu.assets.ui_title.hideWhenInMenu = true;

		player.menu.assets.ui_title_next = player createFontString("hudbig", 0.8);
		player.menu.assets.ui_title_next setPoint("BOTTOM_RIGHT","CENTER",  300,-120);
		player.menu.assets.ui_title_next.alpha = 0.5;
		player.menu.assets.ui_title_next.hideWhenInMenu = true;

		player.menu.assets.ui_title_prev = player createFontString("hudbig", 0.8);
		player.menu.assets.ui_title_prev setPoint("BOTTOM_LEFT","CENTER",  -300,-120);
		player.menu.assets.ui_title_prev.alpha = 0.5;
		player.menu.assets.ui_title_prev.hideWhenInMenu = true;

		player.menu.assets.ui_list_selected = player createFontString("hudbig", 1);
		player.menu.assets.ui_list_selected setPoint("CENTER","CENTER",  0,0);
		player.menu.assets.ui_list_selected.hideWhenInMenu = true;

		alpha = 0.8;
		player.menu.assets.ui_list_bottom = [];
		for(i = 0; i < 5; i++) {
			player.menu.assets.ui_list_bottom[i] = player createFontString("hudsmall", 1);
			player.menu.assets.ui_list_bottom[i] setPoint("TOP","CENTER",  0,20+(i*20));
			player.menu.assets.ui_list_bottom[i].alpha = alpha;
			player.menu.assets.ui_list_bottom[i].hideWhenInMenu = true;
			alpha -= 0.15;
		}

		alpha = 0.8;
		player.menu.assets.ui_list_top = [];
		for(i = 0; i < 3; i++) {
			player.menu.assets.ui_list_top[i] = player createFontString("hudsmall", 1);
			player.menu.assets.ui_list_top[i] setPoint("BOTTOM","CENTER",  0,-20-(i*20));
			player.menu.assets.ui_list_top[i].alpha = alpha;
			player.menu.assets.ui_list_top[i].hideWhenInMenu = true;
			alpha -= 0.3;
		}

		player thread onPlayerSpawned();
		player notifyOnPlayerCommand("menu_open", "+actionslot 1");
		player notifyOnPlayerCommand("menu_up", "+actionslot 1");
		player notifyOnPlayerCommand("menu_up", "+forward");
		player notifyOnPlayerCommand("menu_down", "+actionslot 2");
		player notifyOnPlayerCommand("menu_down", "+back");
		player notifyOnPlayerCommand("toggle_fullbright", "+actionslot 2");
		player notifyOnPlayerCommand("menu_left", "+actionslot 3");
		player notifyOnPlayerCommand("menu_left", "+moveleft");
		player notifyOnPlayerCommand("menu_right", "+actionslot 4");
		player notifyOnPlayerCommand("menu_right", "+moveright");
		player notifyOnPlayerCommand("menu_select", "+gostand");
		player notifyOnPlayerCommand("menu_close", "weapnext");
		player notifyOnPlayerCommand("menu_close", "weapprev");
	}
}

onPlayerDisconnect() {
	while(true) {
		level waittill("disconnect", player);

		//not sure if this UI cleanup is neccessary
		player.menu.assets.title destroy();
		player.menu.assets.controls destroy();
		player.menu.assets.access_level destroy();

		player.menu.assets.ui_title destroy();
		player.menu.assets.ui_title_next destroy();
		player.menu.assets.ui_title_prev destroy();

		player.menu.assets.ui_list_selected destroy();
		for(i = 0; i < player.menu.assets.ui_list_top.size; i++) {
			player.menu.assets.ui_list_top[i] destroy();
		}
		for(i = 0; i < player.menu.assets.ui_list_bottom.size; i++) {
			player.menu.assets.ui_list_bottom[i] destroy();
		}
	}
}

onPlayerSpawned() {
	self endon("disconnect");

	while(true) {
		self waittill("spawned_player");
		self notify("menu_end"); //like ondeath, but without triggering everything
		self setActionSlot(1, ""); //disable nightvision
		self.menu.open = false; //menu is emptied if this is set, since the menu::contents() will exit

		if(self isHost()) {
			self.menu.access_level = "admin";
		} else {
			foreach(admin_guid in level.settings.admins) {
				if(admin_guid == self getGuid()) {
					self.menu.access_level = "admin";
					break;
				}
			}
		}

		//everyone gets menu access, admins walk first
		if(self.menu.access_level == "admin") {
			self freezecontrols(false);
			if(isDefined(level.warn_admin) && level.warn_admin.size) {
				self iPrintLnBold("^1WARNING(S)^7 - Check the console");
				foreach(warning in level.warn_admin) self iPrintLn("^1" + warning);
			}
		}

		if(level.menus[self.menu.access_level].size > 0) {
			self.menu.assets.access_level setText(self.menu.access_level);
			self.menu.assets.controls setText( self.menu.assets.controls._default );
			self thread ebinmodz\menu::init();
		} else {
			self.menu.assets.access_level setText("");
			self.menu.assets.controls setText("");
		}

		self thread _fullbrightToggle();
	}
}

_fullbrightToggle() {
	self endon("disconnect");
	self endon("death");
	self endon("menu_end");

	while(true) {
		self waittill("toggle_fullbright");
		if(self.menu.open) continue;
		if(self.r_fullbright == "0") { //copied from menus/main.gsc
			self.r_fullbright = "1";
			self iPrintLn("Fullbright On");
		} else {
			self.r_fullbright = "0";
			self iPrintLn("Fullbright Off");
		}
		self setClientDvar("r_fullbright", self.r_fullbright);
	}
}
