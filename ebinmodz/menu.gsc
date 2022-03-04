#include maps\mp\gametypes\_hud_util;

init() {
	self endon("disconnect");
	self endon("death");
	self endon("menu_end"); //like ondeath, but without triggering everything

	laptop = "killstreak_ac130_mp";

	while(true) {
		self waittill("menu_open");
		if(self getCurrentWeapon() == "none") {
			self notify("menu_close");
			continue; //no weapon will break the exit functionality
		}

		self giveWeapon(laptop);
		self switchToWeapon(laptop);
		wait 2.2;

		if(self getCurrentWeapon() != laptop) {
			self takeWeapon(laptop); //for if you do it before spawn
			self switchToWeapon(self getWeaponsListPrimaries()[0]); //makes weapnext work again
			continue;
		}

		self freezeControls(true);
		self visionSetNakedForPlayer("blacktest", 1);
		self.menu.open = true;
		self.menu.index = 0;
		self.menu.which = 0;

		self thread dontDie();
		self thread checkLaptop(laptop);
		self thread monitorMenuEvent("menu_up");
		self thread monitorMenuEvent("menu_down");
		self thread monitorMenuEvent("menu_left");
		self thread monitorMenuEvent("menu_right");
		self thread monitorMenuEvent("menu_select");
		self thread contents();

		self waittill("menu_close");
		self.menu.open = false;
		self visionSetNakedForPlayer(getDvar("mapname"), 1);
		self freezeControls(false);
		self switchToWeapon(self getWeaponsListPrimaries()[0]); //didn't save, since the menu may change weapons
	}
}

dontDie() {
	self endon("disconnect");
	self endon("death"); //health should be set back to normal

	previous_health = self.health;
	previous_max_health = self.maxhealth;
	self.maxhealth = 1000000; //max health can regen is *almost* 2bn
	while(self.menu.open) {
		if(self.health < self.maxhealth) self.health = self.maxhealth;
		wait 0.2;
	}

	if(previous_health == 1000000 || previous_max_health == 1000000) { //no cheating plz
		self.health = 100;
		self.maxhealth = 100;
		return;
	}

	self.maxhealth = previous_max_health;
	self.health = previous_health;
}

checkLaptop(laptop) {
	self endon("disconnect");

	while(self.menu.open && self.menu.access_level && self getCurrentWeapon() == laptop) {
		wait 0.2;
	}

	self notify("menu_close");
	self.menu.open = false;
}

//this will be started at least 3 times
monitorMenuEvent(event) {
	self endon("disconnect");
	self endon("death");
	self endon("menu_end"); //like ondeath, but without triggering everything
	self endon("menu_close");

	while(true) {
		self waittill(event);
		switch(event) {
			case "menu_up":      self.menu.index--; break;
			case "menu_down":    self.menu.index++; break;
			case "menu_left":    self.menu.index = 0; self.menu.which--; break;
			case "menu_right":   self.menu.index = 0; self.menu.which++; break;
			case "menu_select":
				//will only work if admin concats from vip
				item = level.menus[self.menu.access_level][self.menu.which];
				if(isDefined(item)) {
					[[item.runFunc]](self.menu.index);
				} else {
					self iPrintLn("^1Invalid menu item");
				}
				break;

			default:
				self iPrintLn("^1No function for event: " + event);
				break;
		}
	}
}

contents() {
	self endon("disconnect");

	//init
	if(level.settings.onPC) {
		self.menu.assets.controls setText("[{+forward}] Up / [{+back}] Down | [{+gostand}] Select | [{weapnext}] Exit");
	} else {
		self.menu.assets.controls setText("[{+actionslot 1}] Up / [{+actionslot 4}] Down | [{+gostand}] Select | [{weapnext}] Exit");
	}

	display_list = level.menus[self.menu.access_level];

	//main
	while(self.menu.open) {
		//!!!beware of race conditions!!!
		if(self.menu.which >= display_list.size) self.menu.which = 0;
		else if(self.menu.which < 0) self.menu.which = display_list.size-1;

		//menu titles
		if(level.settings.onPC) {
			title = "[{+moveleft}]" + level.settings.secondary_colour + " | " + display_list[self.menu.which].title + level.settings.secondary_colour + " | ^7[{+moveright}]";
		} else {
			title = "[{+actionslot 3}] | " + display_list[self.menu.which].title + " | [{+actionslot 4}]";
		}
		self.menu.assets.ui_title setText(title);

		which = self.menu.which + 1;
		if(which >= display_list.size) which = 0;
		self.menu.assets.ui_title_next setText( display_list[which].title );

		which = self.menu.which - 1;
		if(which < 0) which = display_list.size-1;
		self.menu.assets.ui_title_prev setText( display_list[which].title );

		//menu items
		current_menu = [[display_list[self.menu.which].menu]](); //menu is a function pointer to ::getList

		if(self.menu.index >= current_menu.size) self.menu.index = 0;
		else if(self.menu.index < 0) self.menu.index = current_menu.size-1;

		self.menu.assets.ui_list_selected setText(level.settings.secondary_colour + current_menu[self.menu.index]);

		display_index = self.menu.index + 1; //one after will go below
		for(i = 0; i < self.menu.assets.ui_list_bottom.size; i++) {
			if(display_index >= current_menu.size) display_index = 0;
			self.menu.assets.ui_list_bottom[i] setText( current_menu[display_index] );
			display_index++;
		}

		display_index = self.menu.index - 1; //one before will go above
		for(i = 0; i < self.menu.assets.ui_list_top.size; i++) {
			if(display_index < 0) display_index = current_menu.size-1;
			self.menu.assets.ui_list_top[i] setText( current_menu[display_index] );
			display_index--;
		}
		wait 1/30; //30fps - to keep responsiveness
	}

	//exit
	self.menu.assets.controls setText(self.menu.assets.controls._default);

	//empty menu
	self.menu.assets.ui_title setText("");
	self.menu.assets.ui_title_next setText("");
	self.menu.assets.ui_title_prev setText("");
	self.menu.assets.ui_list_selected setText("");
	for(i = 0; i < self.menu.assets.ui_list_top.size; i++) self.menu.assets.ui_list_top[i] setText("");
	for(i = 0; i < self.menu.assets.ui_list_bottom.size; i++) self.menu.assets.ui_list_bottom[i] setText("");
}
