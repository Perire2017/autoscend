script "level_11.ash"

int shenItemsReturned()
{
	int progress = internalQuestStatus("questL11Shen");
	if (progress < 1) return 0;
	if (progress < 3) return 1;
	else if (progress < 5) return 2;
	else return 3;
}

boolean[location] shenSnakeLocations(int day, int n_items_returned)
{
	// Returns the locations in which we will find snakes for Shen, on a particular day.
	// From https://kol.coldfront.net/thekolwiki/index.php/Shen_Copperhead,_Nightclub_Owner

	boolean[location] union(boolean[location] one, boolean[location] two, boolean[location] three)
	{
		boolean[location] ret;
		switch (n_items_returned)
		{
		case 0:
		foreach z, _ in one { ret[z] = true; }
		case 1:
		foreach z, _ in two { ret[z] = true; }
		case 2:
		foreach z, _ in three { ret[z] = true; }
		case 3:
		}
		return ret;
	}
	boolean[location] batsnake  = $locations[The Batrat and Ratbat Burrow];
	boolean[location] frozen    = $locations[Lair of the Ninja Snowmen];
	boolean[location] burning   = $locations[The Castle in the Clouds in the Sky (Top Floor)];
	boolean[location] ten_heads = $locations[The Hole in the Sky];
	boolean[location] frattle   = $locations[The Smut Orc Logging Camp];
	boolean[location] snakleton = $locations[The Unquiet Garves, The VERY Unquiet Garves];

	if (in_koe())
	{
		return union(ten_heads, frattle, frozen);
	}

	switch (day) {
	case 1: return union(batsnake, frozen, burning);
	case 2: return union(frattle, snakleton, ten_heads);
	case 3: return union(frozen, batsnake, snakleton);
	case 4: return union(frattle, batsnake, snakleton);
	case 5: return union(burning, batsnake, ten_heads);
	case 6: return union(burning, batsnake, ten_heads);
	case 7: return union(frattle, snakleton, ten_heads);
	case 8: return union(snakleton, burning, frattle);
	case 9: return union(snakleton, frattle, ten_heads);
	case 10: return union(ten_heads, batsnake, burning);
	case 11: return union(frozen, batsnake, burning);
	}
	boolean[location] empty;
	return empty;
}

boolean[location] shenZonesToAvoidBecauseMaybeSnake()
{
	if (get_property("auto_shenSkipLastLevel").to_int() >= my_level())
	{
		boolean[location] empty;
		return empty;
	}
	if (get_property("auto_shenStarted") != "")
	{
		int day = get_property("auto_shenStarted").to_int();
		int items_returned = shenItemsReturned();
		return shenSnakeLocations(day, items_returned);
	}
	else
	{
		// Assume we're going to start Shen today, tomorrow, or two days from now.
		boolean[location] zones_to_avoid;

		for (int d=0; d<3; d++)
		{
			foreach z, _ in shenSnakeLocations(d+my_daycount(), 0)
			{
				zones_to_avoid[z] = true;
			}

		}
		return zones_to_avoid;
	}
}

boolean shenShouldDelayZone(location loc)
{
	return shenZonesToAvoidBecauseMaybeSnake() contains loc;
}

boolean LX_unlockHiddenTemple() {
	// replaces L2_treeCoin(),  L2_spookyMap(),  L2_spookyFertilizer() & L2_spookySapling()
	if (hidden_temple_unlocked()) {
		return false;
	}
	if (item_amount($item[Spooky Sapling]) == 0 && my_meat() < 100) {
		return false;
	}
	// Arboreal Respite choice adventure has a delay of 5 adventures.
	// TODO: add a check for delay burning
	auto_log_info("Attempting to make the Hidden Temple less hidden.", "blue");
	pullXWhenHaveY($item[Spooky-Gro Fertilizer], 1, 0);
	providePlusNonCombat(25, true);
	if (autoAdv($location[The Spooky Forest])) {
		if (item_amount($item[Spooky Temple map]) > 0 && item_amount($item[Spooky-Gro Fertilizer]) > 0 && item_amount($item[Spooky Sapling]) > 0) {
			use(1, $item[Spooky Temple Map]);
		}
		return true;
	}
	return false;
}

boolean LX_unlockHauntedBilliardsRoom() {
	if (internalQuestStatus("questM20Necklace") != 0) {
		return false;
	}

	if (get_property("manorDrawerCount").to_int() >= 24) {
		cli_execute("refresh inv");
	}

	if (item_amount($item[Spookyraven billiards room key]) > 0) {
		return false;
	}
	
	boolean delayKitchen = get_property("auto_delayHauntedKitchen").to_boolean();
	if(isAboutToPowerlevel())
	{
		// if we're at the point where we need to level up to get more quests other than this, we might as well just do this instead
		delayKitchen = false;
	}
	if(delayKitchen)
	{
		int [element] resGoals;
		resGoals[$element[hot]] = 9;
		resGoals[$element[stench]] = 9;
		// check to see if we can acquire sufficient hot and stench res for the kitchen
		int [element] resPossible = provideResistances(resGoals, true, true);
		delayKitchen = (resPossible[$element[hot]] < 9 || resPossible[$element[stench]] < 9);
		if (delayKitchen && isActuallyEd()) {
			// If we already have all the elemental wards as ed we're probably not going to get any better, so might as well get it over with
			delayKitchen = !have_skill($skill[Even More Elemental Wards]);
		}
	}

	if (!delayKitchen) {
		int [element] resGoal;
		resGoal[$element[hot]] = 9;
		resGoal[$element[stench]] = 9;
		int [element] resPossible = provideResistances(resGoal, true, false);
		auto_log_info("Looking for the Billards Room key (Hot/Stench:" + resPossible[$element[hot]] + "/" + resPossible[$element[stench]] + "): Progress " + get_property("manorDrawerCount") + "/24", "blue");
		if (autoAdv($location[The Haunted Kitchen])) {
			return true;
		}
	}
	return false;
}

boolean LX_unlockHauntedLibrary()
{
	//Adventure in the haunted billiards room to get the key to the haunted library
	if (internalQuestStatus("questM20Necklace") < 1 || internalQuestStatus("questM20Necklace") > 2)
	{
		return false;
	}
	if (item_amount($item[Spookyraven billiards room key]) < 1 || hasSpookyravenLibraryKey())
	{
		return false;
	}
	
	//equipment handling
	int expectPool = speculative_pool_skill();
	item staffOfFats = $item[2268];		//regular staff of fats. +5 pool +2 training
	item EdStaffOfFats = $item[7964];	//ed path version of staff of fats. +5 pool
	item EdStaffOfEd = $item[7961];		//ed path version of staff of ed. +5 pool
	
	if(in_boris())
	{
		auto_log_info("Boris cannot equip a pool cue.", "blue");
	}
	else if(in_tcrs())
	{
		auto_log_info("During this Crazy Summer Pool Cues are used differently.", "blue");
	}
	else if(expectPool > 17)
	{
		auto_log_info("I don't need to equip a cue to beat this ghostie.", "blue");
	}
	else
	{
		if(possessEquipment(staffOfFats))
		{
			autoEquip(staffOfFats);		//+5 pool skill & +2 training gains.
			expectPool += 5;
		}
		else if(possessEquipment(EdStaffOfEd) && expectPool + 5 > 13)
		{
			autoEquip(EdStaffOfEd);		//+5 pool skill
			expectPool += 5;
		}
		else if(possessEquipment(EdStaffOfFats) && expectPool + 5 > 13)
		{
			autoEquip(EdStaffOfFats);	//+5 pool skill
			expectPool += 5;
		}
		else if(possessEquipment($item[Pool Cue]) && expectPool + 3 > 13)
		{
			autoEquip($item[Pool Cue]);	//+3 pool skill
			expectPool += 3;
		}
	}
	
	//inebrity handling. do not care if: auto succeed or can't drink or ran out of things to do.
	if(expectPool < 18 && can_drink() && !isAboutToPowerlevel())
	{
		//paths with inebrity limit under 11 should wait until they are at max to do this
		if(my_inebriety() < inebriety_limit() && inebriety_limit() < 11)
		{
			auto_log_info("I will come back when I had more to drink.", "green");
			resetMaximize();	//cancel equipping pool cue
			return false;
		}
		if(my_inebriety() < 8)
		{
			auto_log_info("I will come back when I had more to drink.", "green");
			resetMaximize();	//cancel equipping pool cue
			return false;
		}
		if(my_inebriety() > 11)
		{
			int penalty = 2 * (10 - my_inebriety());
			auto_log_info("I overshot my inebrity goal for the [Haunted Billiards Room] which gives me a penalty of " + penalty + "pool skill. I will come back tomorrow or if I run out of things to do.", "green");
			resetMaximize();	//cancel equipping pool cue
			return false;
		}
	}
	
	//+3 pool skill & +1 training gains. speculative_pool_skill() already assumed we would use it if we can.
	buffMaintain($effect[Chalky Hand], 0, 1, 1);

	if(!auto_forceNextNoncombat())
	{
		providePlusNonCombat(25, true);
	}
	auto_log_info("It's billiards time!", "blue");
	return autoAdv($location[The Haunted Billiards Room]);
}

boolean LX_unlockManorSecondFloor() {
	if (internalQuestStatus("questM20Necklace") < 3 || internalQuestStatus("questM20Necklace") > 4) {
		return false;
	}

	if (!hasSpookyravenLibraryKey() || possessEquipment($item[ghost of a necklace])) {
		return false;
	}

	if (item_amount($item[Lady Spookyraven\'s Necklace]) > 0) {
		auto_log_info("Giving Lady Spookyraven her necklace.", "blue");
		visit_url("place.php?whichplace=manor1&action=manor1_ladys");
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		return true;
	}

	auto_log_info("Well, we need writing desks", "blue");
	auto_log_info("Going to the library!", "blue");
	if (autoAdv($location[The Haunted Library])) {
		return true;
	}
	return false;
}

boolean LX_spookyravenManorFirstFloor() {
	if (get_property("lastSecondFloorUnlock").to_int() >= my_ascensions()) {
		return false;
	}

	if (LX_unlockManorSecondFloor() || LX_unlockHauntedLibrary() || LX_unlockHauntedBilliardsRoom()) {
		return true;
	}
	return false;
}

boolean LX_danceWithLadySpookyraven() {
	if (internalQuestStatus("questM21Dance") != 2) {
		return false;
	}

	if (item_amount($item[Lady Spookyraven\'s Powder Puff]) != 1 && item_amount($item[Lady Spookyraven\'s Dancing Shoes]) != 1 && item_amount($item[Lady Spookyraven\'s Finest Gown]) != 1) {
		return false;
	}
	auto_log_info("Finished Spookyraven, just dancing with the lady.", "blue");
	visit_url("place.php?whichplace=manor2&action=manor2_ladys");
	if (autoAdv($location[The Haunted Ballroom])) {
		if (in_lowkeysummer()) {
			// need to open the Haunted Nursery for the music box key.
			visit_url("place.php?whichplace=manor3&action=manor3_ladys");
		}
		return true;
	}
	return false;
}

boolean getLadySpookyravensFinestGown() {
	if (internalQuestStatus("questM21Dance") != 1) {
		return false;
	}
	// Elegant animated nightstand has a delay of 6(?) adventures.
	// TODO: add a check for delay burning?
	// Might not be worth it since we need to fight ornate nightstands for the spectacles and camera
	if (item_amount($item[Lady Spookyraven\'s Finest Gown]) > 0) {
		// got the Bedroom item but we might still need items for other parts
		// of the macguffin quest if we got unlucky
		boolean needSpectacles = (item_amount($item[Lord Spookyraven\'s Spectacles]) == 0 && internalQuestStatus("questL11Manor") < 2);
		boolean needCamera = (item_amount($item[disposable instant camera]) == 0 && internalQuestStatus("questL11Palindome") < 1);
		if (in_boris() || auto_my_path() == "Way of the Surprising Fist" || (auto_my_path() == "Nuclear Autumn" && in_hardcore())) {
			needSpectacles = false;
		}

		if(!needSpectacles && !needCamera) {
			return false;
		}
	}

	auto_log_info("Spookyraven: Bedroom, rummaging through nightstands looking for naughty meatbag trinkets.", "blue");
	if (autoAdv($location[The Haunted Bedroom])) {
		return true;
	}
	return false;
}

boolean getLadySpookyravensDancingShoes() {
	if (internalQuestStatus("questM21Dance") != 1) {
		return false;
	}

	if (item_amount($item[Lady Spookyraven\'s Dancing Shoes]) > 0) {
		return false;
	}

	// Louvre It or Leave It choice adventure has a delay of 5 adventures.
	backupSetting("louvreDesiredGoal", "7"); // lets just let mafia automate this for us.
	auto_log_info("Spookyraven: Gallery", "blue");

	auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);

	if ($location[The Haunted Gallery].turns_spent >= 5) {
		if (!auto_forceNextNoncombat()) {
			providePlusNonCombat(25, true);
		}
	}
	if (autoAdv($location[The Haunted Gallery])) {
		return true;
	}
	return false;
}

boolean getLadySpookyravensPowderPuff() {
	if (internalQuestStatus("questM21Dance") != 1) {
		return false;
	}
		
	if (item_amount($item[Lady Spookyraven\'s Powder Puff]) > 0) {
		return false;
	}
	// Never Gonna Make You Up choice adventure has a delay of 5 adventures.
	auto_log_info("Spookyraven: Bathroom", "blue");

	auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);

	if ($location[The Haunted Bathroom].turns_spent >= 5) {
		if (!auto_forceNextNoncombat()) {
			providePlusNonCombat(25, true);
		}
	}
	if (autoAdv($location[The Haunted Bathroom])) {
		return true;
	}
	return false;
}

boolean LX_spookyravenManorSecondFloor()
{
	if (get_property("lastSecondFloorUnlock").to_int() < my_ascensions()) {
		return false;
	}
	if (LX_danceWithLadySpookyraven() || getLadySpookyravensFinestGown() || getLadySpookyravensDancingShoes() || getLadySpookyravensPowderPuff()) {
		return true;
	}
	return false;
}

boolean L11_blackMarket()
{
	if (internalQuestStatus("questL11Black") < 0 || internalQuestStatus("questL11Black") > 1 || black_market_available())
	{
		return false;
	}
	if ((possessEquipment($item[Blackberry Galoshes]) && !auto_can_equip($item[Blackberry Galoshes])) && !isAboutToPowerlevel())
	{
		return false;
	}

	if($location[The Black Forest].turns_spent > 12)
	{
		auto_log_warning("We have spent a bit many adventures in The Black Forest... manually checking", "red");
		visit_url("place.php?whichplace=woods");
		visit_url("woods.php");
		if($location[The Black Forest].turns_spent > 30)
		{
			abort("We have spent too many turns in The Black Forest and haven't found The Black Market. Something is wrong. (try \"refresh quests\" on the cli)");
		}
	}

	auto_log_info("Must find the Black Market: " + get_property("blackForestProgress"), "blue");
	if (internalQuestStatus("questL11Black") == 0 && item_amount($item[black map]) == 0)
	{
		council();
		if (!possessEquipment($item[Blackberry Galoshes]) && auto_can_equip($item[Blackberry Galoshes]))
		{
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
		}
	}

	if(item_amount($item[beehive]) > 0)
	{
		set_property("auto_getBeehive", false);
	}

	if(auto_my_path() != "Live. Ascend. Repeat.")
	{
		providePlusCombat(5, true);
	}

	autoEquip($slot[acc3], $item[Blackberry Galoshes]);

	if((my_ascensions() == 0) || (item_amount($item[Reassembled Blackbird]) == 0))
	{
		handleFamiliar($familiar[Reassembled Blackbird]);
	}

	//If we want the Beehive, and don\'t have enough adventures, this is dangerous.
	if (get_property("auto_getBeehive").to_boolean() && my_adventures() < 3) {
		return false;
	}
	boolean advSpent = autoAdv($location[The Black Forest]);
	//For people with autoCraft set to false for some reason
	if(item_amount($item[Reassembled Blackbird]) == 0 && creatable_amount($item[Reassembled Blackbird]) > 0)
	{
		create(1, $item[Reassembled Blackbird]);
	}
	if (advSpent) {
		return true;
	}
	return false;
}

boolean L11_getBeehive()
{
	if (!black_market_available() || !get_property("auto_getBeehive").to_boolean())
	{
		return false;
	}
	if((internalQuestStatus("questL13Final") >= 7) || (item_amount($item[Beehive]) > 0))
	{
		auto_log_info("Nevermind, wall of skin already defeated (or we already have a beehiven). We do not need a beehive. Bloop.", "blue");
		set_property("auto_getBeehive", false);
		return false;
	}

	auto_log_info("Must find a beehive!", "blue");

	if (!auto_forceNextNoncombat()) {
		providePlusNonCombat(25, true);
	}
	boolean advSpent = autoAdv($location[The Black Forest]);
	if(item_amount($item[beehive]) > 0)
	{
		set_property("auto_getBeehive", false);
	}
	if (advSpent) {
		return true;
	}
	return false;
}

boolean L11_forgedDocuments()
{
	if (internalQuestStatus("questL11Black") < 0 || internalQuestStatus("questL11Black") > 2 || !black_market_available())
	{
		return false;
	}
	if (item_amount($item[Forged Identification Documents]) > 0)
	{
		return false;
	}
	if (my_meat() < npc_price($item[Forged Identification Documents]))
	{
		abort("Could not buy Forged Identification Documents, can not steal identities!");
		return false;
	}

	auto_log_info("Getting the McMuffin Book", "blue");
	if(auto_my_path() == "Way of the Surprising Fist")
	{
		// TODO: move this to WotSF path file if one is ever created.
		string[int] pages;
		pages[0] = "shop.php?whichshop=blackmarket";
		pages[1] = "shop.php?whichshop=blackmarket&action=fightbmguy";
		return autoAdvBypass(0, pages, $location[Noob Cave], "");
	}
	buyUpTo(1, $item[Forged Identification Documents]);
	if(item_amount($item[Forged Identification Documents]) > 0)
	{
		return true;
	}
	auto_log_warning("Could not buy Forged Identification Documents, can't get booze now!", "red");
	return false;
}

boolean L11_mcmuffinDiary()
{
	if (internalQuestStatus("questL11MacGuffin") < 1 || internalQuestStatus("questL11MacGuffin") > 1 || internalQuestStatus("questL11Black") < 2)
	{
		return false;
	}
	if (in_koe() && item_amount($item[Forged Identification Documents]) > 0)
	{
		council(); // Shore doesn't exist in Exploathing so we acquire diary from the council
	}
	if(item_amount($item[Your Father\'s Macguffin Diary]) > 0)
	{
		use(item_amount($item[Your Father\'s Macguffin Diary]), $item[Your Father\'s Macguffin Diary]);
		return true;
	}
	if(item_amount($item[Copy of a Jerk Adventurer\'s Father\'s Diary]) > 0)
	{
		use(item_amount($item[Copy of a Jerk Adventurer\'s Father\'s Diary]), $item[Copy of a Jerk Adventurer\'s Father\'s Diary]);
		return true;
	}
	if (my_adventures() < 4 || my_meat() < 500 || item_amount($item[Forged Identification Documents]) == 0)
	{
		abort("Could not vacation at the shore to find your fathers diary!");
		return false;
	}

	auto_log_info("Getting the McMuffin Diary", "blue");
	doVacation();
	foreach diary in $items[Your Father\'s Macguffin Diary, Copy of a Jerk Adventurer\'s Father\'s Diary]
	{
		if(item_amount(diary) > 0)
		{
			use(item_amount(diary), diary);
			return true;
		}
	}
	return false;
}

boolean L11_aridDesert()
{
	if (internalQuestStatus("questL11Desert") < 0 || internalQuestStatus("questL11Desert") > 0)
	{
		return false;
	}

	// Mafia probably handles this correctly (and probably has done so for a while). (failing again as of r19010)
	if(auto_my_path() == "Pocket Familiars")
	{
		string temp = visit_url("place.php?whichplace=desertbeach", false);
	}
	
	// TODO: Mafia currently (r20019) does not properly track desert exploration progress in plumber
	// Not sure if this fix can do exact progress, but when I visited that page it corrected my explortion to 100 and quest progress to done so it will prevent adv loss at least
	if(in_zelda() && get_property("desertExploration").to_int() < 100)
	{
		string discard = visit_url("place.php?whichplace=desertbeach");
	}

	if(get_property("desertExploration").to_int() >= 100)
	{
		return false;
	}

	item desertBuff = $item[none];
	int progress = 1;
	if(possessEquipment($item[UV-resistant compass]))
	{
		desertBuff = $item[UV-resistant compass];
		progress = 2;
	}
	if(possessEquipment($item[Ornate Dowsing Rod]) && is_unrestricted($item[Hibernating Grimstone Golem]))
	{
		desertBuff = $item[Ornate Dowsing Rod];
		progress = 3;
	}
	if((get_property("bondDesert").to_boolean()) && ($location[The Arid\, Extra-Dry Desert].turns_spent > 0))
	{
		progress += 2;
	}

	boolean failDesert = true;
	if(possessEquipment(desertBuff))
	{
		failDesert = false;
	}
	if($classes[Avatar of Boris, Avatar of Sneaky Pete] contains my_class())
	{
		failDesert = false;
	}
	if(auto_my_path() == "Way of the Surprising Fist")
	{
		failDesert = false;
	}
	if(get_property("bondDesert").to_boolean())
	{
		failDesert = false;
	}
	if(in_koe())
	{
		failDesert = false;
	}

	if(failDesert)
	{
		if((my_level() >= 12) && !in_hardcore())
		{
			auto_log_warning("Do you actually have a UV-resistant compass? Try 'refresh inv' in the CLI! If possible, pull a Grimstone mask and rerun, we may have missed that somehow.", "green");
			if(is_unrestricted($item[Hibernating Grimstone Golem]) && have_familiar($familiar[Grimstone Golem]))
			{
				abort("I can't do the Oasis without an Ornate Dowsing Rod. You can manually get a UV-resistant compass and I'll use that if you really hate me that much.");
			}
			else
			{
				cli_execute("refresh inv");
				if(possessEquipment($item[UV-resistant compass]))
				{
					desertBuff = $item[UV-resistant compass];
					progress = 2;
				}
				else if((my_adventures() > 3) && (my_meat() > 1200))
				{
					doVacation();
					if(item_amount($item[Shore Inc. Ship Trip Scrip]) > 0)
					{
						cli_execute("make UV-Resistant Compass");
					}
					if(!possessEquipment($item[UV-Resistant Compass]))
					{
						abort("Could not acquire a UV-Resistant Compass. Failing.");
					}
					return true;
				}
				else
				{
					abort("Can not handle the desert in our current situation.");
				}
			}
		}
		else
		{
			auto_log_warning("Skipping desert, don't have a rod or a compass.");
			set_property("auto_skipDesert", my_turncount());
		}
		return false;
	}

	if((have_effect($effect[Ultrahydrated]) > 0) || (get_property("desertExploration").to_int() == 0))
	{
		auto_log_info("Searching for the pyramid", "blue");
		if(auto_my_path() == "Heavy Rains")
		{
			autoEquip($item[Thor\'s Pliers]);
		}
		if(auto_have_familiar($familiar[Artistic Goth Kid]))
		{
			handleFamiliar($familiar[Artistic Goth Kid]);
		}

		if(possessEquipment($item[reinforced beaded headband]) && possessEquipment($item[bullet-proof corduroys]) && possessEquipment($item[round purple sunglasses]))
		{
			foreach it in $items[Beer Helmet, Distressed Denim Pants, Bejeweled Pledge Pin]
			{
				take_closet(closet_amount(it), it);
			}
		}

		buyUpTo(1, $item[hair spray]);
		buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);
		if(my_primestat() == $stat[Muscle])
		{
			buyUpTo(1, $item[Ben-Gal&trade; Balm]);
			buffMaintain($effect[Go Get \'Em, Tiger!], 0, 1, 1);
			buyUpTo(1, $item[Blood of the Wereseal]);
			buffMaintain($effect[Temporary Lycanthropy], 0, 1, 1);
		}

		if(my_mp() > 30 && my_hp() < (my_maxhp()*0.5))
		{
			acquireHP();
		}

		if((in_hardcore() || (pulls_remaining() == 0)) && (item_amount($item[Worm-Riding Hooks]) > 0) && (get_property("desertExploration").to_int() <= (100 - (5 * progress))) && ((get_property("gnasirProgress").to_int() & 16) != 16) && (item_amount($item[Stone Rose]) == 0))
		{
			if(item_amount($item[Drum Machine]) > 0)
			{
				auto_log_info("Found the drums, now we use them!", "blue");
				use(1, $item[Drum Machine]);
			}
			else
			{
				auto_log_info("Off to find the drums!", "blue");
				autoAdv(1, $location[The Oasis]);
			}
			return true;
		}

		if(((get_property("gnasirProgress").to_int() & 1) != 1))
		{
			int expectedOasisTurns = 8 - $location[The Oasis].turns_spent;
			int equivProgress = expectedOasisTurns * progress;
			int need = 100 - get_property("desertExploration").to_int();
			auto_log_info("expectedOasis: " + expectedOasisTurns, "brown");
			auto_log_info("equivProgress: " + equivProgress, "brown");
			auto_log_info("need: " + need, "brown");
			if((need <= 15) && (15 >= equivProgress) && (item_amount($item[Stone Rose]) == 0))
			{
				auto_log_info("It seems raisinable to hunt a Stone Rose. Beep", "blue");
				autoAdv(1, $location[The Oasis]);
				return true;
			}
		}

		if(desertBuff != $item[none])
		{
			autoEquip(desertBuff);
		}
		handleFamiliar("initSuggest");
		set_property("choiceAdventure805", 1);
		int need = 100 - get_property("desertExploration").to_int();
		auto_log_info("Need for desert: " + need, "blue");
		auto_log_info("Worm riding: " + item_amount($item[Worm-Riding Manual Page]), "blue");

		if(!get_property("auto_gnasirUnlocked").to_boolean() && ($location[The Arid\, Extra-Dry Desert].turns_spent > 10) && (get_property("desertExploration").to_int() > 10))
		{
			auto_log_info("Did not appear to notice that Gnasir unlocked, assuming so at this point.", "green");
			set_property("auto_gnasirUnlocked", true);
		}

		if(get_property("auto_gnasirUnlocked").to_boolean() && (item_amount($item[Stone Rose]) > 0) && ((get_property("gnasirProgress").to_int() & 1) != 1))
		{
			auto_log_info("Returning the stone rose", "blue");
			auto_visit_gnasir();
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			visit_url("choice.php?whichchoice=805&option=2&pwd=");
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
			{
				cli_execute("refresh inv");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					abort("Returned stone rose but did not return stone rose.");
				}
				else
				{
					if((get_property("gnasirProgress").to_int() & 1) != 1)
					{
						auto_log_warning("Mafia did not track gnasir Stone Rose (0x1). Fixing.", "red");
						set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 1);
					}
				}
			}
			use(1, $item[desert sightseeing pamphlet]);
			return true;
		}

		if(get_property("auto_gnasirUnlocked").to_boolean() && ((get_property("gnasirProgress").to_int() & 2) != 2))
		{
			boolean canBuyPaint = true;
			if((auto_my_path() == "Way of the Surprising Fist") || (auto_my_path() == "Nuclear Autumn"))
			{
				canBuyPaint = false;
			}

			if((item_amount($item[Can of Black Paint]) > 0) || ((my_meat() >= npc_price($item[Can of Black Paint])) && canBuyPaint))
			{
				buyUpTo(1, $item[Can of Black Paint]);
				auto_log_info("Returning the Can of Black Paint", "blue");
				auto_visit_gnasir();
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				visit_url("choice.php?whichchoice=805&option=2&pwd=");
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					cli_execute("refresh inv");
					if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
					{
						if(item_amount($item[Can Of Black Paint]) == 0)
						{
							auto_log_warning("Mafia did not track gnasir Can of Black Paint (0x2). Fixing.", "red");
							set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 2);
							return true;
						}
						else
						{
							abort("Returned can of black paint but did not return can of black paint.");
						}
					}
					else
					{
						if((get_property("gnasirProgress").to_int() & 2) != 2)
						{
							auto_log_warning("Mafia did not track gnasir Can of Black Paint (0x2). Fixing.", "red");
							set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 2);
						}
					}
				}
				use(1, $item[desert sightseeing pamphlet]);
				return true;
			}
		}

		if(get_property("auto_gnasirUnlocked").to_boolean() && (item_amount($item[Killing Jar]) > 0) && ((get_property("gnasirProgress").to_int() & 4) != 4))
		{
			auto_log_info("Returning the killing jar", "blue");
			auto_visit_gnasir();
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			visit_url("choice.php?whichchoice=805&option=2&pwd=");
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
			{
				cli_execute("refresh inv");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					abort("Returned killing jar but did not return killing jar.");
				}
				else
				{
					if((get_property("gnasirProgress").to_int() & 4) != 4)
					{
						auto_log_warning("Mafia did not track gnasir Killing Jar (0x4). Fixing.", "red");
						set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 4);
					}
				}
			}
			use(1, $item[desert sightseeing pamphlet]);
			return true;
		}

		if((item_amount($item[Worm-Riding Manual Page]) >= 15) && ((get_property("gnasirProgress").to_int() & 8) != 8))
		{
			auto_log_info("Returning the worm-riding manual pages", "blue");
			auto_visit_gnasir();
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			visit_url("choice.php?whichchoice=805&option=2&pwd=");
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			if(item_amount($item[Worm-Riding Hooks]) == 0)
			{
				auto_log_critical("We messed up in the Desert, get the Worm-Riding Hooks and use them please.");
				abort("We messed up in the Desert, get the Worm-Riding Hooks and use them please.");
			}
			if(item_amount($item[Worm-Riding Manual Page]) >= 15)
			{
				auto_log_warning("Mafia doesn't realize that we've returned the worm-riding manual pages... fixing", "red");
				cli_execute("refresh all");
				if((get_property("gnasirProgress").to_int() & 8) != 8)
				{
					auto_log_warning("Mafia did not track gnasir Worm-Riding Manual Pages (0x8). Fixing.", "red");
					set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 8);
				}
			}
			return true;
		}

		need = 100 - get_property("desertExploration").to_int();
		if((item_amount($item[Worm-Riding Hooks]) > 0) && ((get_property("gnasirProgress").to_int() & 16) != 16))
		{
			pullXWhenHaveY($item[Drum Machine], 1, 0);
			if(item_amount($item[Drum Machine]) > 0)
			{
				auto_log_info("Drum machine desert time!", "blue");
				use(1, $item[Drum Machine]);
				return true;
			}
		}

		need = 100 - get_property("desertExploration").to_int();
		# If we have done the Worm-Riding Hooks or the Killing jar, don\'t do this.
		if((need <= 15) && ((get_property("gnasirProgress").to_int() & 12) == 0))
		{
			pullXWhenHaveY($item[Killing Jar], 1, 0);
			if(item_amount($item[Killing Jar]) > 0)
			{
				auto_log_info("Secondary killing jar handler", "blue");
				auto_visit_gnasir();
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				visit_url("choice.php?whichchoice=805&option=2&pwd=");
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					cli_execute("refresh inv");
					if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
					{
						abort("Returned killing jar (secondard) but did not return killing jar.");
					}
					else
					{
						if((get_property("gnasirProgress").to_int() & 4) != 4)
						{
							auto_log_warning("Mafia did not track gnasir Killing Jar (0x4). Fixing.", "red");
							set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 4);
						}
					}
				}
				use(1, $item[desert sightseeing pamphlet]);
				return true;
			}
		}

		autoAdv(1, $location[The Arid\, Extra-Dry Desert]);
		handleFamiliar("item");

		if(contains_text(get_property("lastEncounter"), "A Sietch in Time"))
		{
			auto_log_info("We've found the gnome!! Sightseeing pamphlets for everyone!", "green");
			set_property("auto_gnasirUnlocked", true);
		}

		if(contains_text(get_property("lastEncounter"), "He Got His Just Desserts"))
		{
			take_closet(closet_amount($item[Beer Helmet]), $item[Beer Helmet]);
			take_closet(closet_amount($item[Distressed Denim Pants]), $item[Distressed Denim Pants]);
			take_closet(closet_amount($item[Bejeweled Pledge Pin]), $item[Bejeweled Pledge Pin]);
		}
	}
	else
	{
		int need = 100 - get_property("desertExploration").to_int();
		auto_log_info("Getting some ultrahydrated, I suppose. Desert left: " + need, "blue");

		if((need > (5 * progress)) && (cloversAvailable() > 2) && !get_property("lovebugsUnlocked").to_boolean())
		{
			auto_log_info("Gonna clover this, yeah, it only saves 2 adventures. So?", "green");
			cloverUsageInit();
			autoAdvBypass("adventure.php?snarfblat=122", $location[The Oasis]);
			cloverUsageFinish();
		}
		else
		{
			if(!autoAdv(1, $location[The Oasis]))
			{
				auto_log_warning("Could not visit the Oasis for some raisin, assuming desertExploration is incorrect.", "red");
				set_property("desertExploration", 0);
			}
		}
	}
	return true;
}

boolean L11_wishForBaaBaaBuran()
{
	if (!canGenieCombat() || canEat($item[fortune cookie]))
	{
		return false;
	}
	if(!get_property("auto_useWishes").to_boolean())
	{
		auto_log_warning("Skipping wishing for Baa'baa'bu'ran because auto_useWishes=false", "red");
	}
	else
	{
		auto_log_info("I'm sorry we don't already have stone wool. You might even say I'm sheepish. Sheep wish.", "blue");
		handleFamiliar("item");
		if((numeric_modifier("item drop") >= 100))
		{
			if (!makeGenieCombat($monster[Baa\'baa\'bu\'ran]) || item_amount($item[Stone Wool]) == 0)
			{
				auto_log_warning("Wishing for stone wool failed.", "red");
				return false;
			}
			return true;
		}
		else
		{
			auto_log_warning("Never mind, we couldn't get a mere +100% item for the Baa'baa'bu'ran wish.", "red");
		}
	}
	return false;
}

boolean L11_unlockHiddenCity()
{
	if (!hidden_temple_unlocked() || internalQuestStatus("questL11Worship") < 0 || internalQuestStatus("questL11Worship") > 2)
	{
		return false;
	}
	if(my_adventures() <= 3)
	{
		return false;
	}
	if (item_amount($item[The Nostril of the Serpent]) < 1)
	{
		return false;
	}

	boolean useStoneWool = true;

	if (auto_my_path() == "G-Lover" || in_tcrs())
	{
		if(my_adventures() <= 3)
		{
			return false;
		}
		useStoneWool = false;
		backupSetting("choiceAdventure581", 1);
		backupSetting("choiceAdventure579", 3);
	}

	auto_log_info("Searching for the Hidden City", "blue");
	if(useStoneWool)
	{
		if((item_amount($item[Stone Wool]) == 0) && (have_effect($effect[Stone-Faced]) == 0))
		{
			L11_wishForBaaBaaBuran();
			pullXWhenHaveY($item[Stone Wool], 1, 0);
		}
		buffMaintain($effect[Stone-Faced], 0, 1, 1);
		if(have_effect($effect[Stone-Faced]) == 0)
		{
			abort("We do not smell like Stone nor have the face of one. We currently donut farm Stone Wool. Please get some");
		}
	}

	boolean bypassResult = autoAdvBypass(280);

	if (auto_my_path() == "G-Lover" || in_tcrs())
	{
		if(get_property("lastEncounter") != "The Hidden Heart of the Hidden Temple")
		{
			restoreSetting("choiceAdventure579");
			restoreSetting("choiceAdventure581");
			return true;
		}
	}
	else
	{
		if(bypassResult)
		{
			auto_log_warning("Wandering monster interrupted our attempt at the Hidden City", "red");
			return true;
		}
		if(get_property("lastEncounter") != "Fitting In")
		{
			abort("We donut fit in. You are not a munchkin or your donut is invalid. Failed getting the correct adventure at the Hidden Temple. Exit adventure and restart.");
		}
	}

	if(get_property("lastEncounter") == "Fitting In")
	{
		visit_url("choice.php?whichchoice=582&option=2&pwd");
	}

	visit_url("choice.php?whichchoice=580&option=2&pwd");
	visit_url("choice.php?whichchoice=584&option=4&pwd");
	visit_url("choice.php?whichchoice=580&option=1&pwd");
	visit_url("choice.php?whichchoice=123&option=2&pwd");
	visit_url("choice.php");
	cli_execute("dvorak");
	visit_url("choice.php?whichchoice=125&option=3&pwd");
	auto_log_info("Hidden City Unlocked");

	restoreSetting("choiceAdventure579");
	restoreSetting("choiceAdventure581");
	return true;
}


boolean L11_nostrilOfTheSerpent()
{
	if (!hidden_temple_unlocked() || internalQuestStatus("questL11Worship") < 0 || internalQuestStatus("questL11Worship") > 2)
	{
		return false;
	}
	if(item_amount($item[The Nostril of the Serpent]) != 0)
	{
		return false;
	}

	auto_log_info("Must get a snake nose.", "blue");
	boolean useStoneWool = true;

	if (auto_my_path() == "G-Lover" || in_tcrs())
	{
		if(my_adventures() <= 3)
		{
			return false;
		}
		useStoneWool = false;
		backupSetting("choiceAdventure581", 1);
	}

	if(useStoneWool)
	{
		if((item_amount($item[Stone Wool]) == 0) && (have_effect($effect[Stone-Faced]) == 0))
		{
			L11_wishForBaaBaaBuran();
			pullXWhenHaveY($item[Stone Wool], 1, 0);
		}
		buffMaintain($effect[Stone-Faced], 0, 1, 1);
		if(have_effect($effect[Stone-Faced]) == 0)
		{
			abort("We are not Stone-Faced. Please get a stone wool and run me again.");
		}
	}

	set_property("choiceAdventure582", "1");
	set_property("choiceAdventure579", "2");
	if (auto_my_path() == "G-Lover" || in_tcrs())
	{
		if(!autoAdvBypass(280))
		{
			if(get_property("lastEncounter") == "The Hidden Heart of the Hidden Temple")
			{
				string page = visit_url("main.php");
				if(contains_text(page, "decorated with that little lightning"))
				{
					visit_url("choice.php?whichchoice=580&option=1&pwd");
					visit_url("choice.php?whichchoice=123&option=2&pwd");
					visit_url("choice.php");
					cli_execute("dvorak");
					visit_url("choice.php?whichchoice=125&option=3&pwd");
					auto_log_info("Hidden City Unlocked");
				}
				else
				{
					visit_url("choice.php?whichchoice=580&option=2&pwd");
					visit_url("choice.php?whichchoice=583&option=1&pwd");
				}
			}
		}
	}
	else
	{
		autoAdv(1, $location[The Hidden Temple]);
	}

	if(get_property("lastAdventure") == "Such Great Heights")
	{
		cli_execute("refresh inv");
	}
	if(item_amount($item[The Nostril of the Serpent]) == 1)
	{
		set_property("choiceAdventure579", "0");
	}
	restoreSetting("choiceAdventure581");
	return true;
}

boolean L11_hiddenTavernUnlock()
{
	return L11_hiddenTavernUnlock(false);
}

boolean L11_hiddenTavernUnlock(boolean force)
{
	if(!auto_is_valid($item[Book of Matches]))
	{
		return false;
	}

	if(my_ascensions() == get_property("hiddenTavernUnlock").to_int())
	{
		return true;
	}

	if(force)
	{
		if(!in_hardcore())
		{
			pullXWhenHaveY($item[Book of Matches], 1, 0);
		}
	}

	if(my_ascensions() > get_property("hiddenTavernUnlock").to_int())
	{
		if(item_amount($item[Book of Matches]) > 0)
		{
			use(1, $item[Book of Matches]);
			return true;
		}
		return false;
	}
	return true;
}

boolean L11_hiddenCity()
{
	if (internalQuestStatus("questL11Worship") < 3 || internalQuestStatus("questL11Worship") > 4)
	{
		return false;
	}

	if(item_amount($item[[2180]Ancient Amulet]) == 1)
	{
		return true;
	}
	else if (item_amount($item[[7963]Ancient Amulet]) == 0 && isActuallyEd())
	{
		return true;
	}

	if (internalQuestStatus("questL11Curses") > 1 || item_amount($item[Moss-Covered Stone Sphere]) > 0)
	{
		uneffect($effect[Thrice-Cursed]);
		if((have_effect($effect[On The Trail]) > 0) && (get_property("olfactedMonster") == $monster[Pygmy Shaman]))
		{
			if(item_amount($item[soft green echo eyedrop antidote]) > 0)
			{
				auto_log_info("They stink so much!", "blue");
				uneffect($effect[On The Trail]);
			}
		}
	}

	if (internalQuestStatus("questL11Business") > 1 || item_amount($item[Crackling Stone Sphere]) > 0)
	{
		if((have_effect($effect[On The Trail]) > 0) && (get_property("olfactedMonster") == $monster[Pygmy Witch Accountant]))
		{
			if(item_amount($item[soft green echo eyedrop antidote]) > 0)
			{
				auto_log_info("No more accountants to hunt!", "blue");
				uneffect($effect[On The Trail]);
			}
		}
	}

	if (internalQuestStatus("questL11Spare") > 1 || item_amount($item[Scorched Stone Sphere]) > 0)
	{
		if((have_effect($effect[On The Trail]) > 0) && (get_property("olfactedMonster") == $monster[Pygmy Bowler]))
		{
			if(item_amount($item[soft green echo eyedrop antidote]) > 0)
			{
				auto_log_info("No more stinky bowling shoes to worry about!", "blue");
				uneffect($effect[On The Trail]);
			}
		}
	}

	if (item_amount($item[Moss-Covered Stone Sphere]) == 0 && internalQuestStatus("questL11Business") < 1)
	{
		if(get_counters("Fortune Cookie", 0, 9) == "Fortune Cookie")
		{
			return false;
		}
	}

	if (internalQuestStatus("questL11Curses") < 2 && get_counters("Fortune Cookie", 0, 9) != "Fortune Cookie" && have_effect($effect[Ancient Fortitude]) == 0)
	{
		auto_log_info("The idden [sic] apartment!", "blue");

		boolean elevatorAction = ($location[The Hidden Apartment Building].turns_spent > 0 && $location[The Hidden Apartment Building].turns_spent % 8 == 0);

		if(auto_canForceNextNoncombat())
		{
			if((my_ascensions() == get_property("hiddenTavernUnlock").to_int() && (inebriety_left() >= 3*$item[Cursed Punch].inebriety) && !in_tcrs())
				|| (0 != have_effect($effect[Thrice-Cursed]) && $location[The Hidden Apartment Building].turns_spent <= 4))
			{
				elevatorAction = auto_forceNextNoncombat();

				if(auto_my_path() == "Pocket Familiars")
				{
					if(get_property("relocatePygmyLawyer").to_int() != my_ascensions())
					{
						return autoAdv($location[The Hidden Apartment Building]);
					}
				}
			}
		}

		if(!elevatorAction)
		{
			auto_log_info("Hidden Apartment Progress: " + get_property("hiddenApartmentProgress"), "blue");
			return autoAdv($location[The Hidden Apartment Building]);
		}
		else
		{
			if(have_effect($effect[Thrice-Cursed]) == 0)
			{
				L11_hiddenTavernUnlock(true);
				while(have_effect($effect[Thrice-Cursed]) == 0 && inebriety_left() >= $item[Cursed Punch].inebriety && canDrink($item[Cursed Punch]) && my_ascensions() == get_property("hiddenTavernUnlock").to_int() && !in_tcrs())
				{
					buyUpTo(1, $item[Cursed Punch]);
					if(item_amount($item[Cursed Punch]) == 0)
					{
						abort("Could not acquire Cursed Punch, unable to deal with Hidden Apartment Properly");
					}
					autoDrink(1, $item[Cursed Punch]);
				}
			}
			auto_log_info("Hidden Apartment Progress: " + get_property("hiddenApartmentProgress"), "blue");
			return autoAdv($location[The Hidden Apartment Building]);
		}
	}

	if (internalQuestStatus("questL11Business") < 2 && my_adventures() >= 11)
	{
		auto_log_info("The idden [sic] office!", "blue");

		if((item_amount($item[Boring Binder Clip]) == 1) && (item_amount($item[McClusky File (Page 5)]) == 1))
		{
			visit_url("inv_use.php?pwd=&which=3&whichitem=6694");
			cli_execute("refresh inv");
		}

		auto_log_info("Hidden Office Progress: " + get_property("hiddenOfficeProgress"), "blue");
		backupSetting("autoCraft", false);
		boolean advSpent = autoAdv($location[The Hidden Office Building]);
		restoreSetting("autoCraft");
		return advSpent;
	}

	if (internalQuestStatus("questL11Spare") < 2)
	{
		auto_log_info("The idden [sic] bowling alley!", "blue");
		L11_hiddenTavernUnlock(true);
		if(my_ascensions() == get_property("hiddenTavernUnlock").to_int())
		{
			if(item_amount($item[Bowl Of Scorpions]) == 0)
			{
				buyUpTo(1, $item[Bowl Of Scorpions]);
				if(auto_my_path() == "One Crazy Random Summer")
				{
					buyUpTo(3, $item[Bowl Of Scorpions]);
				}
			}
		}

		buffMaintain($effect[Fishy Whiskers], 0, 1, 1);
		auto_log_info("Hidden Bowling Alley Progress: " + get_property("hiddenBowlingAlleyProgress"), "blue");
		return autoAdv($location[The Hidden Bowling Alley]);
	}

	if (internalQuestStatus("questL11Doctor") < 2)
	{
		if(item_amount($item[Dripping Stone Sphere]) > 0)
		{
			return true;
		}
		auto_log_info("The idden osptial!! [sic]", "blue");

		autoEquip($item[bloodied surgical dungarees]);
		autoEquip($item[half-size scalpel]);
		autoEquip($item[surgical apron]);
		autoEquip($slot[acc3], $item[head mirror]);
		autoEquip($slot[acc2], $item[surgical mask]);
		auto_log_info("Hidden Hospital Progress: " + get_property("hiddenHospitalProgress"), "blue");
		return autoAdv($location[The Hidden Hospital]);
	}

	if (item_amount($item[moss-covered stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Northwest)]);
	}

	if (item_amount($item[crackling stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Northeast)]);
	}

	if (item_amount($item[dripping stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Southwest)]);
	}

	if (item_amount($item[scorched stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Southeast)]);
	}

	if (item_amount($item[stone triangle]) == 4) {
		auto_log_info("Fighting the out-of-work spirit", "blue");
		acquireHP();
		handleFamiliar("initSuggest");
		return autoAdv($location[A Massive Ziggurat]);
	}
	
	return false;
}

boolean L11_hiddenCityZones()
{
	if (internalQuestStatus("questL11Worship") < 3 || internalQuestStatus("questL11Worship") > 4)
	{
		return false;
	}

	boolean equipMachete()
	{
		if (auto_can_equip($item[Antique Machete]))
		{
			if (!possessEquipment($item[Antique Machete]))
			{
				pullXWhenHaveY($item[Antique Machete], 1, 0);
			}
			return autoForceEquip($item[Antique Machete]);
		}
		else
		{
			if (!possessEquipment($item[Muculent Machete]))
			{
				pullXWhenHaveY($item[Muculent Machete], 1, 0);
			}
			return autoForceEquip($item[Muculent Machete]);
		}
		return false;
	}

	L11_hiddenTavernUnlock();

	boolean needMachete = !possessEquipment($item[Antique Machete]);
	boolean needRelocate = (get_property("relocatePygmyJanitor").to_int() != my_ascensions());

	if (!in_hardcore() || in_boris() || auto_my_path() == "Way of the Surprising Fist" || auto_my_path() == "Pocket Familiars")
	{
		needMachete = false;
	}

	if (needMachete || needRelocate) {
		// Try to get the NC so that we can relocate Janitors and get items quickly
		if ($location[The Hidden Park].turns_spent < 6 && !auto_forceNextNoncombat()) {
			// Machete NC is guaranteed on the 7th adventure here
			providePlusNonCombat(25, true);
		}
		return autoAdv($location[The Hidden Park]);
	}

	if (get_property("hiddenApartmentProgress") == 0)
	{
		if (!equipMachete()) {
			return false;
		}
		boolean advSpent = autoAdv($location[An Overgrown Shrine (Northwest)]);
		loopHandlerDelayAll();
		return advSpent;
	}

	if (get_property("hiddenOfficeProgress") == 0)
	{
		if (!equipMachete()) {
			return false;
		}
		boolean advSpent = autoAdv($location[An Overgrown Shrine (Northeast)]);
		loopHandlerDelayAll();
		return advSpent;
	}

	if (get_property("hiddenHospitalProgress") == 0)
	{
		if (!equipMachete()) {
			return false;
		}
		boolean advSpent = autoAdv($location[An Overgrown Shrine (Southwest)]);
		loopHandlerDelayAll();
		return advSpent;
	}

	if (get_property("hiddenBowlingAlleyProgress") == 0)
	{
		if (!equipMachete()) {
			return false;
		}
		boolean advSpent = autoAdv($location[An Overgrown Shrine (Southeast)]);
		loopHandlerDelayAll();
		return advSpent;
	}

	if ($location[A Massive Ziggurat].turns_spent < 3)
	{
		if (!equipMachete()) {
			return false;
		}
		boolean advSpent = autoAdv($location[A Massive Ziggurat]);
		loopHandlerDelayAll();
		return advSpent;
	}
	return false;
}

boolean L11_mauriceSpookyraven()
{
	if (internalQuestStatus("questL11Manor") < 0 || internalQuestStatus("questL11Manor") > 3 || internalQuestStatus("questM21Dance") < 4)
	{
		return false;
	}

	if ((isActuallyEd() && item_amount($item[7962]) == 0) || item_amount($item[2286]) > 0)
	{
		return true;
	}

	if (internalQuestStatus("questL11Manor") < 1)
	{
		auto_log_info("Searching for the basement of Spookyraven", "blue");
		if(!cangroundHog($location[The Haunted Ballroom]))
		{
			return false;
		}

		if (!auto_forceNextNoncombat()) {
			providePlusNonCombat(25, true);
		}

		handleFamiliar("initSuggest");

		return autoAdv($location[The Haunted Ballroom]);
	}
	if(item_amount($item[recipe: mortar-dissolving solution]) == 0)
	{
		if(possessEquipment($item[Lord Spookyraven\'s Spectacles]))
		{
			equip($slot[acc3], $item[Lord Spookyraven\'s Spectacles]);
		}
		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		use(1, $item[recipe: mortar-dissolving solution]);
	}

	if (internalQuestStatus("questL11Manor") > 2)
	{
		auto_log_info("Down with the tyrant of Spookyraven!", "blue");
		acquireHP();
		int [element] resGoal;
		foreach ele in $elements[hot, cold, stench, sleaze, spooky]
		{
			resGoal[ele] = 3;
		}
		provideResistances(resGoal, false);

		# The autoAdvBypass case is probably suitable for Ed but we'd need to verify it.
		if (isActuallyEd())
		{
			visit_url("place.php?whichplace=manor4&action=manor4_chamberboss");
		}
		else
		{
			autoAdv($location[Summoning Chamber]);
		}
		return true;
	}

	if(!get_property("auto_haveoven").to_boolean())
	{
		ovenHandle();
	}

	if(item_amount($item[wine bomb]) == 1)
	{
		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		if (internalQuestStatus("questL11Manor") == 3)
		{
			return true;
		}
		else
		{
			abort("Tried to use the wine bomb but it somehow failed?");
		}
	}

	if(!possessEquipment($item[Lord Spookyraven\'s Spectacles]) || in_boris() || (auto_my_path() == "Way of the Surprising Fist") || ((auto_my_path() == "Nuclear Autumn") && !get_property("auto_haveoven").to_boolean()))
	{
		auto_log_warning("Alternate fulminate pathway... how sad :(", "red");
		# I suppose we can let anyone in without the Spectacles.
		if(item_amount($item[Loosening Powder]) == 0)
		{
			autoAdv($location[The Haunted Kitchen]);
			return true;
		}
		if(item_amount($item[Powdered Castoreum]) == 0)
		{
			autoAdv($location[The Haunted Conservatory]);
			return true;
		}
		if(item_amount($item[Drain Dissolver]) == 0)
		{
			autoAdv($location[The Haunted Bathroom]);
			return true;
		}
		if(item_amount($item[Triple-Distilled Turpentine]) == 0)
		{
			autoAdv($location[The Haunted Gallery]);
			return true;
		}
		if(item_amount($item[Detartrated Anhydrous Sublicalc]) == 0)
		{
			autoAdv($location[The Haunted Laboratory]);
			return true;
		}
		if(item_amount($item[Triatomaceous Dust]) == 0)
		{
			autoAdv($location[The Haunted Storage Room]);
			return true;
		}

		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		return true;
	}

	if((item_amount($item[blasting soda]) == 1) && (item_amount($item[bottle of Chateau de Vinegar]) == 1))
	{
		auto_log_info("Time to cook up something explosive! Science fair unstable fulminate time!", "green");
		ovenHandle();
		autoCraft("cook", 1, $item[bottle of Chateau de Vinegar], $item[blasting soda]);
		if(item_amount($item[Unstable Fulminate]) == 0)
		{
			auto_log_warning("We could not make an Unstable Fulminate but we think we have an oven. Do this manually and resume?", "red");
			auto_log_warning("Speculating that get_campground() was incorrect at ascension start...", "red");
			// This issue is valid as of mafia r16799
			set_property("auto_haveoven", false);
			ovenHandle();
			autoCraft("cook", 1, $item[bottle of Chateau de Vinegar], $item[blasting soda]);
			if(item_amount($item[Unstable Fulminate]) == 0)
			{
				if(auto_my_path() == "Nuclear Autumn")
				{
					auto_log_warning("Could not make an Unstable Fulminate, assuming we have no oven for realz...", "red");
					return true;
				}
				else
				{
					abort("Could not make an Unstable Fulminate, make it manually and resume");
				}
			}
		}
	}

	if(get_property("spookyravenRecipeUsed") != "with_glasses")
	{
		abort("Did not read Mortar Recipe with the Spookyraven glasses. We can't proceed.");
	}

	if (item_amount($item[bottle of Chateau de Vinegar]) == 0 && !possessEquipment($item[Unstable Fulminate]) && internalQuestStatus("questL11Manor") < 3)
	{
		auto_log_info("Searching for vinegar", "blue");
		if(!bat_wantHowl($location[The Haunted Wine Cellar]))
		{
			bat_formBats();
		}
		return autoAdv($location[The Haunted Wine Cellar]);
	}
	if (item_amount($item[blasting soda]) == 0 && !possessEquipment($item[Unstable Fulminate]) && internalQuestStatus("questL11Manor") < 3)
	{
		auto_log_info("Searching for baking soda, I mean, blasting pop.", "blue");
		if(!bat_wantHowl($location[The Haunted Wine Cellar]))
		{
			bat_formBats();
		}
		return autoAdv($location[The Haunted Laundry Room]);
	}

	if (possessEquipment($item[Unstable Fulminate]) && internalQuestStatus("questL11Manor") < 3)
	{
		auto_MaxMLToCap(auto_convertDesiredML(82), true);
		addToMaximize("500ml " + auto_convertDesiredML(82) + "max");

		if((auto_my_path() == "Picky") && (item_amount($item[gumshoes]) > 0))
		{
			auto_change_mcd(0);
			autoEquip($slot[acc2], $item[gumshoes]);
		}
		
		if(monster_level_adjustment() < 57)
		{
			buffMaintain($effect[Sweetbreads Flamb&eacute;], 0, 1, 1);
		}
		
		if(!autoForceEquip($slot[off-hand], $item[Unstable Fulminate]))
		{
			abort("Unstable Fulminate was not equipped. Please report this and include the following: Equipped items and if you have or don't have an Unstable Fulminate. For now, get the wine bomb manually, and run again.");
		}
		
		auto_log_info("Now we mix and heat it up.", "blue");
		return autoAdv($location[The Haunted Boiler Room]);
	}
	return false;
}

boolean L11_redZeppelin()
{
	if (internalQuestStatus("questL11Shen") < 8 && !isAboutToPowerlevel())
	{
		return false;
	}

	if (internalQuestStatus("questL11Ron") < 0 || internalQuestStatus("questL11Ron") > 1)
	{
		return false;
	}

	if(internalQuestStatus("questL11Ron") == 0)
	{
		return autoAdv($location[A Mob Of Zeppelin Protesters]);
	}

	// TODO: create lynyrd skin items

	set_property("choiceAdventure856", 1);
	set_property("choiceAdventure857", 1);
	set_property("choiceAdventure858", 1);
	buffMaintain($effect[Greasy Peasy], 0, 1, 1);
	buffMaintain($effect[Musky], 0, 1, 1);
	buffMaintain($effect[Blood-Gorged], 0, 1, 1);
	pullXWhenHaveY($item[deck of lewd playing cards], 1, 0);

	providePlusNonCombat(25);

	if(item_amount($item[Flamin\' Whatshisname]) > 0)
	{
		backupSetting("choiceAdventure866", 3);
	}
	else
	{
		backupSetting("choiceAdventure866", 2);
	}

	addToMaximize("100sleaze damage,100sleaze spell damage");
	auto_beachCombHead("sleaze");
	foreach it in $items[lynyrdskin breeches, lynyrdskin cap, lynyrdskin tunic]
	{
		if(possessEquipment(it) && auto_can_equip(it) &&
		   (numeric_modifier(equipped_item(to_slot(it)), "sleaze damage") < 5) &&
		   (numeric_modifier(equipped_item(to_slot(it)), "sleaze spell damage") < 5))
		{
			autoEquip(it);
		}
	}

	if(item_amount($item[lynyrd snare]) > 0 && get_property("_lynyrdSnareUses").to_int() < 3 && my_hp() > 150)
	{
		return autoAdvBypass("inv_use.php?pwd=&whichitem=7204&checked=1", $location[A Mob of Zeppelin Protesters]);
	}

	if(cloversAvailable() > 0 && get_property("zeppelinProtestors").to_int() < 75)
	{
		if(cloversAvailable() >= 3 && get_property("auto_useWishes").to_boolean())
		{
			makeGenieWish($effect[Fifty Ways to Bereave Your Lover]); // +100 sleaze dmg
			makeGenieWish($effect[Dirty Pear]); // double sleaze dmg
		}
		if(in_tcrs())
		{
			if(my_class() == $class[Sauceror] && my_sign() == "Blender")
			{
				if (0 == have_effect($effect[Improprie Tea]))
				{
					buyUpTo(1, $item[Ben-Gal&trade; Balm], 25);
					use(1, $item[Ben-Gal&trade; Balm]);
				}
			}
		}
		float fire_protestors = item_amount($item[Flamin\' Whatshisname]) > 0 ? 10 : 3;
		float sleaze_amount = numeric_modifier("sleaze damage") + numeric_modifier("sleaze spell damage");
		float sleaze_protestors = square_root(sleaze_amount);
		float lynyrd_protestors = have_effect($effect[Musky]) > 0 ? 6 : 3;
		foreach it in $items[lynyrdskin cap, lynyrdskin tunic, lynyrdskin breeches]
		{
			if((item_amount(it) > 0) && can_equip(it))
			{
				lynyrd_protestors += 5;
			}
		}
		auto_log_info("Hiding in the bushes: " + lynyrd_protestors, "blue");
		auto_log_info("Going to a bench: " + sleaze_protestors, "blue");
		auto_log_info("Heading towards the flames" + fire_protestors, "blue");
		float best_protestors = max(fire_protestors, max(sleaze_protestors, lynyrd_protestors));
		if(best_protestors >= 10)
		{
			if(best_protestors == lynyrd_protestors)
			{
				foreach it in $items[lynyrdskin cap, lynyrdskin tunic, lynyrdskin breeches]
				{
					autoEquip(it);
				}
				set_property("choiceAdventure866", 1);
			}
			else if(best_protestors == sleaze_protestors)
			{
				set_property("choiceAdventure866", 2);
			}
			else if (best_protestors == fire_protestors)
			{
				set_property("choiceAdventure866", 3);
			}
			cloverUsageInit();
			boolean retval = autoAdv(1, $location[A Mob of Zeppelin Protesters]);
			cloverUsageFinish();
			return retval;
		}
	}

	int lastProtest = get_property("zeppelinProtestors").to_int();
	boolean retval = autoAdv($location[A Mob Of Zeppelin Protesters]);
	if(!lastAdventureSpecialNC())
	{
		if(lastProtest == get_property("zeppelinProtestors").to_int())
		{
			set_property("zeppelinProtestors", get_property("zeppelinProtestors").to_int() + 1);
		}
	}
	else
	{
		set_property("lastEncounter", "Clear Special NC");
	}
	restoreSetting("choiceAdventure866");
	set_property("choiceAdventure856", 2);
	set_property("choiceAdventure857", 2);
	set_property("choiceAdventure858", 2);
	return retval;
}


boolean L11_ronCopperhead()
{
	if (internalQuestStatus("questL11Ron") < 2 || internalQuestStatus("questL11Ron") > 4)
	{
		return false;
	}


	if (internalQuestStatus("questL11Ron") > 1 && internalQuestStatus("questL11Ron") < 5)
	{
		if (item_amount($item[Red Zeppelin Ticket]) < 1)
		{
			// use the priceless diamond since we go to the effort of trying to get one in the Copperhead Club
			// and it saves us 4.5k meat.
			if (item_amount($item[priceless diamond]) > 0)
			{
				buy($coinmaster[The Black Market], 1, $item[Red Zeppelin Ticket]);
			}
			else if (my_meat() > npc_price($item[Red Zeppelin Ticket]))
			{
				buy(1, $item[Red Zeppelin Ticket]);
			}
		}
		// For Glark Cables. OPTIMAL!
		bat_formBats();
		boolean retval = autoAdv($location[The Red Zeppelin]);
		// open red boxes when we get them (not sure if this is the place for this but it'll do for now)
		if (item_amount($item[red box]) > 0)
		{
			use (item_amount($item[red box]), $item[red box]);
		}
		return retval;
	}

	if (internalQuestStatus("questL11Ron") < 5)
	{
		abort("Ron should be done with but tracking is not complete!");
	}

	// Copperhead Charm (rampant) autocreated successfully
	return false;
}

boolean L11_shenCopperhead()
{
	if (internalQuestStatus("questL11Shen") < 0 || internalQuestStatus("questL11Shen") > 7)
	{
		return false;
	}

	set_property("choiceAdventure1074", 1);

	if (internalQuestStatus("questL11Shen") == 0 || internalQuestStatus("questL11Shen") == 2 || internalQuestStatus("questL11Shen") == 4 || internalQuestStatus("questL11Shen") == 6)
	{
		if (item_amount($item[Crappy Waiter Disguise]) > 0 && have_effect($effect[Crappily Disguised as a Waiter]) == 0 && !in_tcrs())
		{
			use(1, $item[Crappy Waiter Disguise]);

			// default to getting unnamed cocktails to turn into Flamin' Whatsisnames.
			int behindtheStacheOption = 4;
			if (item_amount($item[priceless diamond]) > 0 || item_amount($item[Red Zeppelin Ticket]) > 0 || (internalQuestStatus("questL11Shen") == 6 && item_amount($item[unnamed cocktail]) > 0))
			{
				if (get_property("copperheadClubHazard") != "lantern")
				{
					// got priceless diamond or zeppelin ticket so lets burn the place down (and make Flamin' Whatsisnames)
					behindtheStacheOption = 3;
				}
			}
			else
			{
				if (get_property("copperheadClubHazard") != "ice")
				{
					// knock over the ice bucket & try for the priceless diamond.
					behindtheStacheOption = 2;
				}
			}
			set_property("choiceAdventure855", behindtheStacheOption);
		}

		if (!maximizeContains("-10ml"))
		{
			addToMaximize("-10ml");
		}
		boolean retval = autoAdv($location[The Copperhead Club]);
		if (maximizeContains("-10ml"))
		{
			removeFromMaximize("-10ml");
		}
		return retval;
	}

	if((internalQuestStatus("questL11Shen") == 1) || (internalQuestStatus("questL11Shen") == 3) || (internalQuestStatus("questL11Shen") == 5))
	{
		item it = to_item(get_property("shenQuestItem"));
		if (it == $item[none] && isActuallyEd())
		{
			// temp workaround until mafia bug is fixed - https://kolmafia.us/showthread.php?23742
			cli_execute("refresh quests");
			it = to_item(get_property("shenQuestItem"));
		}
		location goal = $location[none];
		switch(it)
		{
		case $item[The Stankara Stone]:					goal = $location[The Batrat and Ratbat Burrow];						break;
		case $item[The First Pizza]:					goal = $location[Lair of the Ninja Snowmen];						break;
		case $item[Murphy\'s Rancid Black Flag]:		goal = $location[The Castle in the Clouds in the Sky (Top Floor)];	break;
		case $item[The Eye of the Stars]:				goal = $location[The Hole in the Sky];								break;
		case $item[The Lacrosse Stick of Lacoronado]:	goal = $location[The Smut Orc Logging Camp];						break;
		case $item[The Shield of Brook]:				goal = $location[The VERY Unquiet Garves];							break;
		}
		if(goal == $location[none])
		{
			abort("Could not parse Shen event");
		}

		if(!zone_isAvailable(goal))
		{
			// handle paths which don't need Tower keys but the World's Biggest Jerk asks for The Eye of the Stars
			if (goal == $location[The Hole in the Sky])
			{
				if (!get_property("auto_holeinthesky").to_boolean())
				{
					set_property("auto_holeinthesky", true);
				}
				return (L10_topFloor() || L10_holeInTheSkyUnlock());
			}
			return false;
		}
		else
		{
			// If we haven't completed the top floor, try to complete it.
			if (goal == $location[The Castle in the Clouds in the Sky (Top Floor)] && (L10_topFloor() || L10_holeInTheSkyUnlock()))
			{
				return true;
			}
			else if (goal == $location[The Smut Orc Logging Camp] && (L9_ed_chasmStart() || L9_chasmBuild()))
			{
				return true;
			}

			return autoAdv(goal);
		}
	}

	if (internalQuestStatus("questL11Shen") < 8)
	{
		abort("Shen should be done with but tracking is not complete! Status: " + get_property("questL11Shen"));
	}

	//Now have a Copperhead Charm
	return false;
}

boolean L11_talismanOfNam()
{
	if(L11_shenCopperhead() || L11_redZeppelin() || L11_ronCopperhead())
	{
		return true;
	}
	if(creatable_amount($item[Talisman O\' Namsilat]) > 0)
	{
		if(create(1, $item[Talisman O\' Namsilat]))
		{
			return true;
		}
	}

	return false;
}

boolean L11_palindome()
{
	if (internalQuestStatus("questL11Palindome") < 0 || internalQuestStatus("questL11Palindome") > 5)
	{
		return false;
	}

	int total = 0;
	total = total + item_amount($item[Photograph Of A Red Nugget]);
	total = total + item_amount($item[Photograph Of An Ostrich Egg]);
	total = total + item_amount($item[Photograph Of God]);
	total = total + item_amount($item[Photograph Of A Dog]);

	boolean lovemeDone = hasILoveMeVolI() || (internalQuestStatus("questL11Palindome") >= 1);
	if(!lovemeDone && (get_property("palindomeDudesDefeated").to_int() >= 5))
	{
		string palindomeCheck = visit_url("place.php?whichplace=palindome");
		lovemeDone = lovemeDone || contains_text(palindomeCheck, "pal_drlabel");
	}

	auto_log_info("In the palindome : emodnilap eht nI", "blue");
	#
	#	In hardcore, guild-class, the right side of the or doesn't happen properly due us farming the
	#	Mega Gem within the if, with pulls, it works fine. Need to fix this. This is bad.
	#
	if((item_amount($item[Bird Rib]) > 0) && (item_amount($item[Lion Oil]) > 0) && (item_amount($item[Wet Stew]) == 0))
	{
		autoCraft("cook", 1, $item[Bird Rib], $item[Lion Oil]);
	}
	if((item_amount($item[Stunt Nuts]) > 0) && (item_amount($item[Wet Stew]) > 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0))
	{
		autoCraft("cook", 1, $item[wet stew], $item[stunt nuts]);
	}

	if((item_amount($item[Wet Stunt Nut Stew]) > 0) && !possessEquipment($item[Mega Gem]))
	{
		if(equipped_amount($item[Talisman o\' Namsilat]) == 0)
			equip($slot[acc3], $item[Talisman o\' Namsilat]);
		visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
	}

	if((total == 0) && !possessEquipment($item[Mega Gem]) && lovemeDone && in_hardcore() && (item_amount($item[Wet Stunt Nut Stew]) == 0) && ((internalQuestStatus("questL11Palindome") >= 3) || isGuildClass()) && !get_property("auto_bruteForcePalindome").to_boolean())
	{
		if(item_amount($item[Wet Stunt Nut Stew]) == 0)
		{
			handleFamiliar("item");
			equipBaseline();
			if((item_amount($item[Bird Rib]) == 0) || (item_amount($item[Lion Oil]) == 0))
			{
				if(item_amount($item[white page]) > 0)
				{
					set_property("choiceAdventure940", 1);
					if(item_amount($item[Bird Rib]) > 0)
					{
						set_property("choiceAdventure940", 2);
					}

					if(get_property("lastGuildStoreOpen").to_int() < my_ascensions())
					{
						auto_log_warning("This is probably no longer needed as of r16907. Please remove me", "blue");
						auto_log_warning("Going to pretend we have unlocked the Guild because Mafia will assume we need to do that before going to Whitey's Grove and screw up us. We'll fix it afterwards.", "red");
					}
					backupSetting("lastGuildStoreOpen", my_ascensions());
					string[int] pages;
					pages[0] = "inv_use.php?pwd&which=3&whichitem=7555";
					pages[1] = "choice.php?pwd&whichchoice=940&option=" + get_property("choiceAdventure940");
					if(autoAdvBypass(0, pages, $location[Whitey\'s Grove], "")) {}
					restoreSetting("lastGuildStoreOpen");
					return true;
				}
				// +item is nice to get that food
				bat_formBats();
				auto_log_info("Off to the grove for some doofy food!", "blue");
				autoAdv(1, $location[Whitey\'s Grove]);
			}
			else if(item_amount($item[Stunt Nuts]) == 0)
			{
				auto_log_info("We got no nuts!! :O", "Blue");
				autoEquip($slot[acc3], $item[Talisman o\' Namsilat]);
				autoAdv(1, $location[Inside the Palindome]);
			}
			else
			{
				abort("Some sort of Wet Stunt Nut Stew error. Try making it yourself?");
			}
			return true;
		}
	}
	if((((total == 4) && hasILoveMeVolI()) || ((total == 0) && possessEquipment($item[Mega Gem]))) && loveMeDone)
	{
		if(hasILoveMeVolI())
		{
			useILoveMeVolI();
		}
		if (equipped_amount($item[Talisman o\' Namsilat]) == 0)
			equip($slot[acc3], $item[Talisman o\' Namsilat]);
		visit_url("place.php?whichplace=palindome&action=pal_drlabel");
		visit_url("choice.php?pwd&whichchoice=872&option=1&photo1=2259&photo2=7264&photo3=7263&photo4=7265");

		if (isActuallyEd())
		{
			return true;
		}


		# is step 4 when we got the wet stunt nut stew?
		if (internalQuestStatus("questL11Palindome") < 5)
		{
			if(item_amount($item[&quot;2 Love Me\, Vol. 2&quot;]) > 0)
			{
				use(1, $item[&quot;2 Love Me\, Vol. 2&quot;]);
				auto_log_info("Oh no, we died from reading a book. I'm going to take a nap.", "blue");
				acquireHP();
				bat_reallyPickSkills(20);
			}
			if (equipped_amount($item[Talisman o\' Namsilat]) == 0)
				equip($slot[acc3], $item[Talisman o\' Namsilat]);
			visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
			if(!in_hardcore() && (item_amount($item[Wet Stunt Nut Stew]) == 0))
			{
				if((item_amount($item[Wet Stew]) == 0) && (item_amount($item[Mega Gem]) == 0))
				{
					pullXWhenHaveY($item[Wet Stew], 1, 0);
				}
				if((item_amount($item[Stunt Nuts]) == 0) && (item_amount($item[Mega Gem]) == 0))
				{
					pullXWhenHaveY($item[Stunt Nuts], 1, 0);
				}
			}
			if(in_hardcore() && isGuildClass())
			{
				return true;
			}
		}

		if((item_amount($item[Bird Rib]) > 0) && (item_amount($item[Lion Oil]) > 0) && (item_amount($item[Wet Stew]) == 0))
		{
			autoCraft("cook", 1, $item[Bird Rib], $item[Lion Oil]);
		}

		if((item_amount($item[Stunt Nuts]) > 0) && (item_amount($item[Wet Stew]) > 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0))
		{
			autoCraft("cook", 1, $item[wet stew], $item[stunt nuts]);
		}

		if(!possessEquipment($item[Mega Gem]))
		{
			if (equipped_amount($item[Talisman o\' Namsilat]) == 0)
				equip($slot[acc3], $item[Talisman o\' Namsilat]);
			visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
		}

		if(!possessEquipment($item[Mega Gem]))
		{
			auto_log_warning("No mega gem for us. Well, no raisin to go further here....", "red");
			return false;
		}
		autoEquip($slot[acc2], $item[Mega Gem]);
		autoEquip($slot[acc3], $item[Talisman o\' Namsilat]);
		int palinChoice = random(3) + 1;
		set_property("choiceAdventure131", palinChoice);

		auto_log_info("War sir is raw!!", "blue");

		string[int] pages;
		pages[0] = "place.php?whichplace=palindome&action=pal_drlabel";
		pages[1] = "choice.php?pwd&whichchoice=131&option=" + palinChoice;
		autoAdvBypass(0, pages, $location[Noob Cave], "");
		return true;
	}
	else
	{
		if((my_mp() > 60) || considerGrimstoneGolem(true))
		{
			handleBjornify($familiar[Grimstone Golem]);
		}
		if (internalQuestStatus("questL11Palindome") > 1)
		{
			if(!get_property("auto_bruteForcePalindome").to_boolean())
			{
				auto_log_critical("Palindome failure:", "red");
				auto_log_critical("You probably just need to get a Mega Gem to fix this.", "red");
				abort("We have made too much progress in the Palindome and should not be here.");
			}
			else
			{
				auto_log_critical("We need wet stunt nut stew to get the Mega Gem, but I've been told to get it via the mercy adventure.", "red");
				auto_log_critical("Set auto_bruteForcePalindome=false to try to get a stunt nut stew", "red");
				auto_log_critical("(We typically only set this option in hardcore Kingdom of Exploathing, in which the White Forest isn't available)", "red");
			}
		}

		if((have_effect($effect[On The Trail]) > 0) && !($monsters[Bob Racecar, Racecar Bob] contains get_property("olfactedMonster").to_monster()) && internalQuestStatus("questL11Palindome") < 2)
		{
			if(item_amount($item[soft green echo eyedrop antidote]) > 0)
			{
				auto_log_info("Gotta hunt down them Naskar boys.", "blue");
				uneffect($effect[On The Trail]);
			}
		}

		autoEquip($slot[acc3], $item[Talisman o\' Namsilat]);
		autoAdv(1, $location[Inside the Palindome]);
		if(($location[Inside the Palindome].turns_spent > 30) && (auto_my_path() != "Pocket Familiars") && (auto_my_path() != "G-Lover") && !in_koe())
		{
			abort("It appears that we've spent too many turns in the Palindome. If you run me again, I'll try one more time but many I failed finishing the Palindome");
		}
	}
	return true;
}

boolean L11_unlockPyramid()
{
  if (internalQuestStatus("questL11Desert") < 1 || get_property("desertExploration").to_int() < 100 || internalQuestStatus("questL11Pyramid") > 0)
	{
		return false;
	}
	if (isActuallyEd())
	{
		return false;
	}

	if((item_amount($item[[2325]Staff Of Ed]) > 0) || ((item_amount($item[[2180]Ancient Amulet]) > 0) && (item_amount($item[[2268]Staff Of Fats]) > 0) && (item_amount($item[[2286]Eye Of Ed]) > 0)))
	{
		auto_log_info("Reveal the pyramid", "blue");
		if(item_amount($item[[2325]Staff Of Ed]) == 0)
		{
			if((item_amount($item[[2180]Ancient Amulet]) > 0) && (item_amount($item[[2286]Eye Of Ed]) > 0))
			{
				autoCraft("combine", 1, $item[[2180]Ancient Amulet], $item[[2286]Eye Of Ed]);
			}
			if((item_amount($item[Headpiece of the Staff of Ed]) > 0) && (item_amount($item[[2268]Staff Of Fats]) > 0))
			{
				autoCraft("combine", 1, $item[headpiece of the staff of ed], $item[[2268]Staff Of Fats]);
			}
		}
		if(item_amount($item[[2325]Staff Of Ed]) == 0)
		{
			abort("Failed making Staff of Ed (2325) via CLI. Please do it manually and rerun.");
		}

		if (in_koe())
		{
			visit_url("place.php?whichplace=exploathing_beach&action=expl_pyramidpre");
			cli_execute("refresh quests");
		}
		else
		{
			visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
		}

		if (internalQuestStatus("questL11Pyramid") < 0)
		{
			auto_log_info("No burning Ed's model now!", "blue");
			if((auto_my_path() == "One Crazy Random Summer") && (get_property("desertExploration").to_int() == 100))
			{
				auto_log_warning("We might have had an issue due to OCRS and the Desert, please finish the desert (and only the desert) manually and run again.", "red");
				string page = visit_url("place.php?whichplace=desertbeach");
				matcher desert_matcher = create_matcher("title=\"[(](\\d+)% explored[)]\"", page);
				if(desert_matcher.find())
				{
					int found = to_int(desert_matcher.group(1));
					if(found < 100)
					{
						set_property("desertExploration", found);
					}
				}

				if(get_property("desertExploration").to_int() == 100)
				{
					abort("Tried to open the Pyramid but could not - exploration at 100?. Something went wrong :(");
				}
				else
				{
					auto_log_info("Incorrectly had exploration value of 100 however, this was correctable. Trying to resume.", "blue");
					return false;
				}
			}
			if(my_turncount() == get_property("auto_skipDesert").to_int())
			{
				auto_log_warning("Did not have an Arid Desert Item and the Pyramid is next. Must backtrack and recover", "red");
				if((my_adventures() >= 3) && (my_meat() >= 500))
				{
					doVacation();
					if(item_amount($item[Shore Inc. Ship Trip Scrip]) > 0)
					{
						cli_execute("make UV-Resistant Compass");
					}
					if(item_amount($item[UV-Resistant Compass]) == 0)
					{
						abort("Could not acquire a UV-Resistant Compass. Failing.");
					}
				}
				else
				{
					abort("Could not backtrack to handle getting a UV-Resistant Compass");
				}
				return true;
			}
			abort("Tried to open the Pyramid but could not. Something went wrong :(");
		}

		buffMaintain($effect[Snow Shoes], 0, 1, 1);
		autoAdv(1, $location[The Upper Chamber]);
		return true;
	}
	else
	{
		return false;
	}
}

boolean L11_unlockEd()
{
	if (internalQuestStatus("questL11Pyramid") < 0 || internalQuestStatus("questL11Pyramid") > 3 || get_property("pyramidBombUsed").to_boolean())
	{
		return false;
	}
	if (isActuallyEd())
	{
		return true;
	}

	if (internalQuestStatus("questL03Rat") < 2)
	{
		auto_log_warning("Uh oh, didn\'t do the tavern and we are at the pyramid....", "red");

		// Forcing Tavern.
		set_property("auto_forceTavern", true);
		return false;
	}

	auto_log_info("In the pyramid (W:" + item_amount($item[crumbling wooden wheel]) + ") (R:" + item_amount($item[tomb ratchet]) + ") (U:" + get_property("controlRoomUnlock") + ")", "blue");

	if(!get_property("middleChamberUnlock").to_boolean())
	{
		autoAdv(1, $location[The Upper Chamber]);
		return true;
	}

	int total = item_amount($item[Crumbling Wooden Wheel]);
	total = total + item_amount($item[Tomb Ratchet]);

	if((total >= 10) && (my_adventures() >= 4) && get_property("controlRoomUnlock").to_boolean())
	{
		visit_url("place.php?whichplace=pyramid&action=pyramid_control");
		int x = 0;
		while(x < 10)
		{
			if(item_amount($item[crumbling wooden wheel]) > 0)
			{
				visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
			}
			else
			{
				visit_url("choice.php?whichchoice=929&option=2&pwd");
			}
			x = x + 1;
			if((x == 3) || (x == 7) || (x == 10))
			{
				visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
			}
			if((x == 3) || (x == 7))
			{
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
			}
		}
		return true;
	}
	if(total < 10)
	{
		buffMaintain($effect[Joyful Resolve], 0, 1, 1);
		buffMaintain($effect[One Very Clear Eye], 0, 1, 1);
		buffMaintain($effect[Fishy Whiskers], 0, 1, 1);
		buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
		buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
		buffMaintain($effect[Unusual Perspective], 0, 1, 1);
		if(!bat_wantHowl($location[The Middle Chamber]))
		{
			bat_formBats();
		}
		if(get_property("auto_dickstab").to_boolean())
		{
			buffMaintain($effect[Wet and Greedy], 0, 1, 1);
			buffMaintain($effect[Frosty], 0, 1, 1);
		}
		if((item_amount($item[possessed sugar cube]) > 0) && (have_effect($effect[Dance of the Sugar Fairy]) == 0))
		{
			cli_execute("make sugar fairy");
			buffMaintain($effect[Dance of the Sugar Fairy], 0, 1, 1);
		}
		if((have_effect($effect[On The Trail]) > 0) && (get_property("olfactedMonster") != $monster[Tomb Rat]))
		{
			if(item_amount($item[soft green echo eyedrop antidote]) > 0)
			{
				uneffect($effect[On The Trail]);
			}
		}
		if(have_effect($effect[items.enh]) == 0)
		{
			auto_sourceTerminalEnhance("items");
		}
		handleFamiliar("item");
	}

	if(get_property("controlRoomUnlock").to_boolean())
	{
		if(!contains_text(get_property("auto_banishes"), $monster[Tomb Servant]) && !contains_text(get_property("auto_banishes"), $monster[Tomb Asp]) && (get_property("olfactedMonster") != $monster[Tomb Rat]))
		{
			autoAdv(1, $location[The Upper Chamber]);
			return true;
		}
	}

	autoAdv(1, $location[The Middle Chamber]);
	return true;
}

boolean L11_defeatEd()
{
	if (internalQuestStatus("questL11Pyramid") < 3 || internalQuestStatus("questL11Pyramid") > 3 || !get_property("pyramidBombUsed").to_boolean())
	{
		return false;
	}
	if(my_adventures() <= 7)
	{
		return false;
	}

	if(item_amount($item[[2334]Holy MacGuffin]) == 1)
	{
		council();
		return true;
	}

	int baseML = monster_level_adjustment();
	if(auto_my_path() == "Heavy Rains")
	{
		baseML = baseML + 60;
	}
	if(baseML > 150)
	{
		foreach s in $slots[acc1, acc2, acc3]
		{
			if(equipped_item(s) == $item[Hand In Glove])
			{
				equip(s, $item[none]);
			}
		}
		uneffect($effect[Ur-kel\'s Aria of Annoyance]);
		if(possessEquipment($item[Beer Helmet]))
		{
			autoEquip($item[beer helmet]);
		}
	}
	if(in_koe())
	{
		retrieve_item(1, $item[low-pressure oxygen tank]);
		autoForceEquip($item[low-pressure oxygen tank]);
	}

	zelda_equipTool($stat[moxie]);

	// When we disable adventure handling, we also disable the maximizer that
	// would normally happen in pre-adventure.
	equipMaximizedGear();

	acquireHP();
	auto_log_info("Time to waste all of Ed's Ka Coins :(", "blue");

	set_property("choiceAdventure976", "1");

	int edFights = 0;
	set_property("auto_disableAdventureHandling", true);
	while(item_amount($item[[2334]Holy MacGuffin]) == 0)
	{
		edFights++;
		auto_log_info("Hello Ed #" + edFights + " give me McMuffin please.", "blue");
		autoAdv(1, $location[The Lower Chambers]);
		if(have_effect($effect[Beaten Up]) > 0 && item_amount($item[[2334]Holy MacGuffin]) == 0)
		{
			set_property("auto_disableAdventureHandling", false);
			abort("Got Beaten Up by Ed the Undying - generally not safe to try to recover.");
		}
		if (edFights > 10)
		{
			abort("Trying to fight too many Eds, leave the poor dude alone!");
		}
		if(auto_my_path() == "Pocket Familiars" || in_koe())
		{
			cli_execute("refresh inv");
		}
	}
	set_property("auto_disableAdventureHandling", false);

	if(item_amount($item[[2334]Holy MacGuffin]) != 0)
	{
		council();
	}
	return true;
}
