script "auto_deprecation.ash"

/****

Functions in here are defined in autoscend/autoscend_header.ash

These functions exist to handle outdated configuartions of the script. These would have been removed but we might as well keep them (in case we need to do any new configuration mangling) and they might actually help recover a long-forgotten ascension.

****/


boolean trackingSplitterFixer(string oldSetting, int day, string newSetting)
{
	string setting = get_property(oldSetting);
	if(setting == "")
	{
		return false;
	}

	matcher cleanSpaces = create_matcher(", ", setting);
	setting = replace_all(cleanSpaces, ",");
	string[int] retval = split_string(setting, ",");
	foreach x in retval
	{
		if(retval[x] == "")
		{
			continue;
		}
		matcher dayAdder = create_matcher("[(]", retval[x]);
		retval[x] = replace_all(dayAdder, "(" + day + ":");
		if(get_property(newSetting) != "")
		{
			set_property(newSetting, get_property(newSetting) + "," + retval[x]);
		}
		else
		{
			set_property(newSetting, retval[x]);
		}
	}
	set_property(oldSetting, "");
	return true;
}

boolean settingFixer()
{
	/***
		This will be removed at some point once a reasonable amount of time has
		passed such that anyone who used the script before a conversion in here
		should have had it fix them.

		Maybe it won\t. It doesn't really need to be I guess.
		Backwards compatibility forever!!!
	***/
	if(get_property("auto_debug") == "true"){
		set_property("auto_logLevel", "debug");
	}

	trackingSplitterFixer("auto_banishes_day1", 1, "auto_banishes");
	trackingSplitterFixer("auto_banishes_day2", 2, "auto_banishes");
	trackingSplitterFixer("auto_banishes_day3", 3, "auto_banishes");
	trackingSplitterFixer("auto_banishes_day4", 4, "auto_banishes");
	trackingSplitterFixer("auto_yellowRay_day1", 1, "auto_yellowRays");
	trackingSplitterFixer("auto_yellowRay_day2", 2, "auto_yellowRays");
	trackingSplitterFixer("auto_yellowRay_day3", 3, "auto_yellowRays");
	trackingSplitterFixer("auto_yellowRay_day4", 4, "auto_yellowRays");
	trackingSplitterFixer("auto_lashes_day1", 1, "auto_lashes");
	trackingSplitterFixer("auto_lashes_day2", 2, "auto_lashes");
	trackingSplitterFixer("auto_lashes_day3", 3, "auto_lashes");
	trackingSplitterFixer("auto_lashes_day4", 4, "auto_lashes");
	trackingSplitterFixer("auto_renenutet_day1", 1, "auto_renenutet");
	trackingSplitterFixer("auto_renenutet_day2", 2, "auto_renenutet");
	trackingSplitterFixer("auto_renenutet_day3", 3, "auto_renenutet");
	trackingSplitterFixer("auto_renenutet_day4", 4, "auto_renenutet");

	if(get_property("auto_delayTimer") == "")
	{
		set_property("auto_delayTimer", 1);
	}
	if(get_property("auto_100familiar") == "yes")
	{
		set_property("auto_100familiar", true);
	}
	if(get_property("auto_100familiar") == "no")
	{
		set_property("auto_100familiar", $familiar[none]);
	}
	if(get_property("auto_100familiar") == "false")
	{
		set_property("auto_100familiar", $familiar[none]);
	}
	if(get_property("auto_killingjar") == "done")
	{
		set_property("auto_killingjar", "finished");
	}
	if(get_property("auto_useCubeling") == "yes")
	{
		set_property("auto_useCubeling", true);
	}
	if(get_property("auto_sonata") == "finished")
	{
		set_property("auto_sonata", "");
	}

	if(get_property("auto_useCubeling") == "no")
	{
		set_property("auto_useCubeling", false);
	}
	if(get_property("auto_wandOfNagamar") == "yes")
	{
		set_property("auto_wandOfNagamar", true);
	}
	if(get_property("auto_wandOfNagamar") == "no")
	{
		set_property("auto_wandOfNagamar", false);
	}
	if(get_property("auto_chasmBusted") == "yes")
	{
		set_property("auto_chasmBusted", true);
	}
	if(get_property("auto_chasmBusted") == "no")
	{
		set_property("auto_chasmBusted", false);
	}

	if(get_property("auto_edDelayTimer") != "")
	{
		set_property("auto_delayTimer", get_property("auto_edDelayTimer"));
		set_property("auto_edDelayTimer", "");
	}
	if(get_property("auto_grimstoneFancyOilPainting") == "need")
	{
		set_property("auto_grimstoneFancyOilPainting", true);
	}
	if(get_property("auto_grimstoneFancyOilPainting") == "no")
	{
		set_property("auto_grimstoneFancyOilPainting", false);
	}
	if(get_property("auto_grimstoneOrnateDowsingRod") == "need")
	{
		set_property("auto_grimstoneOrnateDowsingRod", true);
	}
	if(get_property("auto_grimstoneOrnateDowsingRod") == "no")
	{
		set_property("auto_grimstoneOrnateDowsingRod", false);
	}

	if(get_property("kingLiberatedScript") == "scripts/kingLiberated.ash")
	{
		set_property("kingLiberatedScript", "auto_king.ash");
	}
	if(get_property("afterAdventureScript") == "scripts/postadventure.ash")
	{
		set_property("afterAdventureScript", "auto_post_adv.ash");
	}
	if(get_property("betweenAdventureScript") == "scripts/preadventure.ash")
	{
		set_property("betweenAdventureScript", "auto_pre_adv.ash");
	}
	if(get_property("betweenBattleScript") == "scripts/preadventure.ash")
	{
		set_property("betweenBattleScript", "auto_pre_adv.ash");
	}

	if(get_property("auto_abooclover") == "")
	{
		set_property("auto_abooclover", true);
	}
	if(get_property("auto_abooclover") == "used")
	{
		set_property("auto_abooclover", false);
	}
	if(get_property("auto_aftercore") == "")
	{
		set_property("auto_aftercore", false);
	}
	if(get_property("auto_aftercore") == "done")
	{
		set_property("auto_aftercore", true);
	}

	if(get_property("auto_cubeItems") == "")
	{
		set_property("auto_cubeItems", true);
	}
	if(get_property("auto_cubeItems") == "done")
	{
		set_property("auto_cubeItems", false);
	}

	if(get_property("auto_xiblaxianChoice") == "")
	{
		set_property("auto_xiblaxianChoice", $item[Xiblaxian Ultraburrito]);
	}

	if(get_property("lastPlusSignUnlock") == "true")
	{
		auto_log_debug("lastPlusSignUnlock was changed to a boolean, fixing...", "red");
		set_property("lastPlusSignUnlock", my_ascensions());
	}
	if(get_property("lastTempleUnlock") == "true")
	{
		auto_log_debug("lastTempleUnlock was changed to a boolean, fixing...", "red");
		set_property("lastTempleUnlock", my_ascensions());
	}

	if(property_exists("auto_day1_init"))
	{
		auto_log_debug("Found old day initialization trackers, removing...", "red");
		remove_property("auto_day1_init");
		remove_property("auto_day2_init");
		remove_property("auto_day3_init");
		remove_property("auto_day4_init");
	}

	if(property_exists("auto_gaudy"))
	{
		auto_log_debug("Some lingering stuff from when gaudy pirates mattered is still here, let's get rid of it...", "red");
		remove_property("auto_gaudy");
	}

	if(get_property("auto_paranoia") == "")
	{
		auto_log_debug("No paranoia value, we probably don't want to be paranoid...", "red");
		set_property("auto_paranoia", -1);
	}

	if(get_property("auto_helpMeMafiaIsSuperBrokenAaah") == "")
	{
		auto_log_debug("Mafia probably isn't super broken, so let's set it that way...", "red");
		set_property("auto_helpMeMafiaIsSuperBrokenAaah", false);
	}

	if(property_exists("auto_beta_test"))
	{
		auto_log_debug("Beta testing features should be guarded behind their own individual properties...", "red");
		remove_property("auto_beta_test");
	}

	if(property_exists("auto_invaderKilled"))
	{
		auto_log_debug("No longer need to track the invaders status ourselves as mafia does it now...", "red");
		remove_property("auto_invaderKilled");
	}

	if (property_exists("auto_airship"))
	{
		remove_property("auto_airship");
	}
	if (property_exists("auto_ballroom"))
	{
		remove_property("auto_ballroom");
	}
	if (property_exists("auto_ballroomflat"))
	{
		remove_property("auto_ballroomflat");
	}
	if (property_exists("auto_ballroomopen"))
	{
		remove_property("auto_ballroomopen");
	}
	if (property_exists("auto_ballroomsong"))
	{
		remove_property("auto_ballroomsong");
	}
	if (property_exists("auto_bat"))
	{
		remove_property("auto_bat");
	}
	if (property_exists("auto_bean"))
	{
		remove_property("auto_bean");
	}
	if (property_exists("auto_blackfam"))
	{
		remove_property("auto_blackfam");
	}
	if (property_exists("auto_blackmap"))
	{
		remove_property("auto_blackmap");
	}
	if (property_exists("auto_boopeak"))
	{
		remove_property("auto_boopeak");
	}
	if (property_exists("auto_castlebasement"))
	{
		remove_property("auto_castlebasement");
	}
	if (property_exists("auto_castleground"))
	{
		remove_property("auto_castleground");
	}
	if (property_exists("auto_castletop"))
	{
		remove_property("auto_castletop");
	}
	if (property_exists("auto_consumption"))
	{
		remove_property("auto_consumption");
	}
	if (property_exists("auto_crypt"))
	{
		remove_property("auto_crypt");
	}
	if (property_exists("auto_day1_cobb"))
	{
		remove_property("auto_day1_cobb");
	}
	if (property_exists("auto_fcle"))
	{
		remove_property("auto_fcle");
	}
	if (property_exists("auto_friars"))
	{
		remove_property("auto_friars");
	}
	if (property_exists("auto_goblinking"))
	{
		remove_property("auto_goblinking");
	}
	if (property_exists("auto_gremlins"))
	{
		remove_property("auto_gremlins");
	}
	if (property_exists("auto_gremlinBanishes"))
	{
		remove_property("auto_gremlinBanishes");
	}
	if (property_exists("auto_gunpowder"))
	{
		remove_property("auto_gunpowder");
	}
	if (property_exists("auto_hiddenapartment"))
	{
		remove_property("auto_hiddenapartment");
	}
	if (property_exists("auto_hiddenbowling"))
	{
		remove_property("auto_hiddenbowling");
	}
	if (property_exists("auto_hiddencity"))
	{
		remove_property("auto_hiddenhospital");
	}
	if (property_exists("auto_hiddenoffice"))
	{
		remove_property("auto_hiddenoffice");
	}
	if (property_exists("auto_hiddenunlock"))
	{
		remove_property("auto_hiddenunlock");
	}
	if (property_exists("auto_hiddenzones"))
	{
		remove_property("auto_hiddenzones");
	}
	if (property_exists("auto_highlandlord"))
	{
		remove_property("auto_highlandlord");
	}
	if (property_exists("auto_masonryWall"))
	{
		remove_property("auto_masonryWall");
	}
	if (property_exists("auto_mcmuffin"))
	{
		remove_property("auto_mcmuffin");
	}
	if (property_exists("auto_mistypeak"))
	{
		remove_property("auto_mistypeak");
	}
	if (property_exists("auto_mosquito"))
	{
		remove_property("auto_mosquito");
	}
	if (property_exists("auto_nuns"))
	{
		remove_property("auto_nuns");
	}
	if (property_exists("auto_oilpeak"))
	{
		remove_property("auto_oilpeak");
	}
	if (property_exists("auto_orchard"))
	{
		remove_property("auto_orchard");
	}
	if (property_exists("auto_palindome"))
	{
		remove_property("auto_palindome");
	}
	if (property_exists("auto_phatloot"))
	{
		remove_property("auto_phatloot");
	}
	if (property_exists("auto_prewar"))
	{
		remove_property("auto_prewar");
	}
	if (property_exists("auto_prehippy"))
	{
		remove_property("auto_prehippy");
	}
	if (property_exists("auto_pirateoutfit"))
	{
		remove_property("auto_pirateoutfit");
	}
	if (property_exists("auto_trytower"))
	{
		remove_property("auto_trytower");
	}
	if (property_exists("auto_shenCopperhead"))
	{
		remove_property("auto_shenCopperhead");
	}
	if (property_exists("auto_spookyfertilizer"))
	{
		remove_property("auto_spookyfertilizer");
	}
	if (property_exists("auto_spookymap"))
	{
		remove_property("auto_spookymap");
	}
	if (property_exists("auto_spookyravensecond"))
	{
		remove_property("auto_spookyravensecond");
	}
	if (property_exists("auto_spookysapling"))
	{
		remove_property("auto_spookysapling");
	}
	if (property_exists("auto_sonofa"))
	{
		remove_property("auto_sonofa");
	}
	if (property_exists("auto_sorceress"))
	{
		remove_property("auto_sorceress");
	}
	if (property_exists("auto_swordfish"))
	{
		remove_property("auto_swordfish");
	}
	if (property_exists("auto_tavern"))
	{
		remove_property("auto_tavern");
	}
	if (property_exists("auto_trapper"))
	{
		remove_property("auto_trapper");
	}
	if (property_exists("auto_treecoin"))
	{
		remove_property("auto_treecoin");
	}
	if (property_exists("auto_twinpeak"))
	{
		remove_property("auto_twinpeak");
	}
	if (property_exists("auto_twinpeakprogress"))
	{
		remove_property("auto_twinpeakprogress");
	}
	if (property_exists("auto_war"))
	{
		remove_property("auto_war");
	}
	if (property_exists("auto_winebomb"))
	{
		remove_property("auto_winebomb");
	}

	if (property_exists("auto_legacyConsumeStuff"))
	{
		auto_log_debug("Knapsack consumption algorithm is now for everyone!", "red");
		remove_property("auto_legacyConsumeStuff");
	}

	if (property_exists("betweenAdventureScript"))
	{
		auto_log_debug("betweenAdventureScript might be an old mafia property that was renamed but it does nothing now.");
		remove_property("betweenAdventureScript");
	}

	if (property_exists("auto_copperhead"))
	{
		auto_log_debug("Mafia added tracking for the Copperhead Club non-combat so this is no longer necesssary.");
		remove_property("auto_copperhead");
	}

	if (property_exists("auto_hpAutoRecoveryItems"))
	{
		remove_property("auto_hpAutoRecoveryItems");
	}
	if (property_exists("auto_hpAutoRecovery"))
	{
		remove_property("auto_hpAutoRecovery");
	}
	if (property_exists("auto_hpAutoRecoveryTarget"))
	{
		remove_property("auto_hpAutoRecoveryTarget");
	}
	
	return true;
}
