/*
	Why does this exist? So other files aren't bogged down with huge line counts
	Why not just use a csv? Because they can't be easily altered since they must be packed into a .ff - this hurts compatibility
	Files like this should be written for speed only (use a switch) - do not be concerned by maintainability
*/

getRGB(colour_code) {
	switch(colour_code) {
		case 1: return (0.94, 0.30, 0.27); //red
		case 2: return (0.50, 0.71, 0.00); //green
		case 5: return (0.13, 0.74, 0.95); //cyan/blue
		default: return (1.00, 1.00, 1.00); //white
	}
}

getCode(rgb) {
	switch(rgb) {
		case (0.94, 0.30, 0.27): return 1; //red
		case (0.50, 0.71, 0.00): return 2; //green
		case (0.13, 0.74, 0.95): return 5; //cyan/blue
		default: return 7; //white
	}
}

//TEST
//do not use in real-time, cache result as it requires allocation/deallocation
getClosestCode(rgb) {
	valid_colours = [];
	valid_colours[valid_colours.size] = (0.94, 0.30, 0.27); //red: 1
	valid_colours[valid_colours.size] = (0.50, 0.71, 0.00); //green: 2
	valid_colours[valid_colours.size] = (0.13, 0.74, 0.95); //cyan/blue: 5
	valid_colours[valid_colours.size] = (1.00, 1.00, 1.00); //white: 7

	colour_objects = [];
	foreach(colour in valid_colours) {
		obj = spawnStruct();
		obj.origin = colour;
		colour_objects[colour_objects.size] = obj;
	}

	sorted = sortByDistance(colour_objects, rgb);
	ret = getCode(sorted[0].origin);

	foreach(obj in colour_objects) {
		obj delete();
	}

	return ret;
}
