// ----------------------------------------------------------------
// Timezone names
//
// this file is created half-manually
// ----------------------------------------------------------------

//! module Calendar
//! submodule TZnames
//!	This module contains listnings of available timezones,
//!	in some different ways

#pike __REAL_VERSION__

//! method string _zone_tab()
//! method array(array) zone_tab()
//!	This returns the raw respectively parsed zone tab file
//!	from the timezone data files.
//!
//!	The parsed format is an array of zone tab line arrays,
//!	<pre>
//!	({ string country_code,
//!	   string position,
//!	   string zone_name,
//!	   string comment })
//!	</pre>
//!
//!	To convert the position to a Geography.Position, simply
//!	feed it to the constructor.

protected string raw_zone_tab=0;
string _zone_tab()
{
   return raw_zone_tab ||
      (raw_zone_tab = ( master()->master_read_file(
         combine_path(__FILE__,"..","tzdata/zone.tab")) - "\r"));
}

protected array(array(string)) parsed_zone_tab=0;
array(array(string)) zone_tab()
{
   return parsed_zone_tab ||
      (parsed_zone_tab=
       map(_zone_tab()/"\n",
	   lambda(string s)
	   {
	      if (s=="" || s[0]=='#')
		 return 0;
	      else
	      {
		 array v=s/"\t";
		 if (sizeof(v)==3) return v+=({""});
		 else return v;
	      }
	   })
	   -({0}));
}

//! method array(string) zonenames()
//!	This reads the zone.tab file and returns name of all
//!	standard timezones, like "Europe/Belgrade".

protected array(string) zone_names=0;
array(string) zonenames()
{
   return zone_names || (zone_names=column(zone_tab(),2));
}

//! constant mapping(string:array(string)) zones
//!	This constant is a mapping that can be
//!	used to loop over to get all the region-based
//!	timezones.
//!
//!	It looks like this:
//!	<pre>
//!	([ "America": ({ "Los_Angeles", "Chicago", <i>[...]</i> }),
//!	   "Europe":  ({ "Stockholm", <i>[...]</i> }),
//!        <i>[...]</i> }),
//!	</pre>
//!
//!	Please note that loading all the timezones can take some
//!	time, since they are generated and compiled on the fly.

mapping zones =
([
   "America":   ({"Anguilla", "Antigua", "Argentina/ComodRivadavia", "Aruba",
                  "Cayman", "Coral_Harbour", "Dominica", "Ensenada",
                  "Grenada", "Guadeloupe", "Montreal", "Montserrat",
                  "Rosario", "St_Kitts", "St_Lucia", "St_Thomas",
                  "St_Vincent", "Tortola", "Danmarkshavn", "Scoresbysund",
                  "Godthab", "Thule", "New_York", "Chicago",
                  "North_Dakota/Center", "North_Dakota/New_Salem",
                  "North_Dakota/Beulah", "Denver", "Los_Angeles", "Juneau",
                  "Sitka", "Metlakatla", "Yakutat", "Anchorage", "Nome",
                  "Adak", "Phoenix", "Boise", "Indiana/Indianapolis",
                  "Indiana/Marengo", "Indiana/Vincennes", "Indiana/Tell_City",
                  "Indiana/Petersburg", "Indiana/Knox", "Indiana/Winamac",
                  "Indiana/Vevay", "Kentucky/Louisville",
                  "Kentucky/Monticello", "Detroit", "Menominee", "St_Johns",
                  "Goose_Bay", "Halifax", "Glace_Bay", "Moncton",
                  "Blanc-Sablon", "Toronto", "Thunder_Bay", "Nipigon",
                  "Rainy_River", "Atikokan", "Winnipeg", "Regina",
                  "Swift_Current", "Edmonton", "Vancouver", "Dawson_Creek",
                  "Fort_Nelson", "Creston", "Pangnirtung", "Iqaluit",
                  "Resolute", "Rankin_Inlet", "Cambridge_Bay", "Yellowknife",
                  "Inuvik", "Whitehorse", "Dawson", "Cancun", "Merida",
                  "Matamoros", "Monterrey", "Mexico_City", "Ojinaga",
                  "Chihuahua", "Hermosillo", "Mazatlan", "Bahia_Banderas",
                  "Tijuana", "Nassau", "Barbados", "Belize", "Costa_Rica",
                  "Havana", "Santo_Domingo", "El_Salvador", "Guatemala",
                  "Port-au-Prince", "Tegucigalpa", "Jamaica", "Martinique",
                  "Managua", "Panama", "Puerto_Rico", "Miquelon",
                  "Grand_Turk", "Argentina/Buenos_Aires", "Argentina/Cordoba",
                  "Argentina/Salta", "Argentina/Tucuman",
                  "Argentina/La_Rioja", "Argentina/San_Juan",
                  "Argentina/Jujuy", "Argentina/Catamarca",
                  "Argentina/Mendoza", "Argentina/San_Luis",
                  "Argentina/Rio_Gallegos", "Argentina/Ushuaia", "La_Paz",
                  "Noronha", "Belem", "Santarem", "Fortaleza", "Recife",
                  "Araguaina", "Maceio", "Bahia", "Sao_Paulo", "Campo_Grande",
                  "Cuiaba", "Porto_Velho", "Boa_Vista", "Manaus", "Eirunepe",
                  "Rio_Branco", "Santiago", "Punta_Arenas", "Bogota",
                  "Curacao", "Guayaquil", "Cayenne", "Guyana", "Asuncion",
                  "Lima", "Paramaribo", "Port_of_Spain", "Montevideo",
                  "Caracas"}),
   "Pacific":   ({"Fiji", "Gambier", "Marquesas", "Tahiti", "Guam", "Tarawa",
                  "Enderbury", "Kiritimati", "Majuro", "Kwajalein", "Chuuk",
                  "Pohnpei", "Kosrae", "Nauru", "Noumea", "Auckland",
                  "Chatham", "Rarotonga", "Niue", "Norfolk", "Palau",
                  "Port_Moresby", "Bougainville", "Pitcairn", "Pago_Pago",
                  "Apia", "Guadalcanal", "Fakaofo", "Tongatapu", "Funafuti",
                  "Wake", "Efate", "Wallis", "Johnston", "Midway", "Saipan",
                  "Honolulu", "Easter", "Galapagos"}),
   "Antarctica":({"Casey", "Davis", "Mawson", "DumontDUrville", "Syowa",
                  "Troll", "Vostok", "Rothera", "Macquarie", "McMurdo",
                  "Palmer"}),
   "Atlantic":  ({"Cape_Verde", "Jan_Mayen", "St_Helena", "Faroe",
                  "Reykjavik", "Azores", "Madeira", "Canary", "Bermuda",
                  "Stanley", "South_Georgia"}),
   "Indian":    ({"Mauritius", "Reunion", "Mahe", "Kerguelen", "Chagos",
                  "Maldives", "Christmas", "Cocos", "Antananarivo", "Comoro",
                  "Mayotte"}),
   "Europe":    ({"Belfast", "Guernsey", "Isle_of_Man", "Jersey", "Ljubljana",
                  "Sarajevo", "Skopje", "Tiraspol", "Vaduz", "Zagreb",
                  "London", "Dublin", "Tirane", "Andorra", "Vienna", "Minsk",
                  "Brussels", "Sofia", "Prague", "Copenhagen", "Tallinn",
                  "Helsinki", "Paris", "Berlin", "Gibraltar", "Athens",
                  "Budapest", "Rome", "Riga", "Vilnius", "Luxembourg",
                  "Malta", "Chisinau", "Monaco", "Amsterdam", "Oslo",
                  "Warsaw", "Lisbon", "Bucharest", "Kaliningrad", "Moscow",
                  "Simferopol", "Astrakhan", "Volgograd", "Saratov", "Kirov",
                  "Samara", "Ulyanovsk", "Belgrade", "Madrid", "Stockholm",
                  "Zurich", "Istanbul", "Kiev", "Uzhgorod", "Zaporozhye"}),
   "Africa":    ({"Algiers", "Ndjamena", "Abidjan", "Cairo", "Accra",
                  "Bissau", "Nairobi", "Monrovia", "Tripoli", "Casablanca",
                  "El_Aaiun", "Maputo", "Windhoek", "Lagos", "Sao_Tome",
                  "Johannesburg", "Khartoum", "Juba", "Tunis", "Addis_Ababa",
                  "Asmara", "Bamako", "Bangui", "Banjul", "Blantyre",
                  "Brazzaville", "Bujumbura", "Conakry", "Dakar",
                  "Dar_es_Salaam", "Djibouti", "Douala", "Freetown",
                  "Gaborone", "Harare", "Kampala", "Kigali", "Kinshasa",
                  "Libreville", "Lome", "Luanda", "Lubumbashi", "Lusaka",
                  "Malabo", "Maseru", "Mbabane", "Mogadishu", "Niamey",
                  "Nouakchott", "Ouagadougou", "Porto-Novo", "Timbuktu",
                  "Ceuta"}),
   "Asia":      ({"Kabul", "Yerevan", "Baku", "Dhaka", "Thimphu", "Brunei",
                  "Yangon", "Shanghai", "Urumqi", "Hong_Kong", "Taipei",
                  "Macau", "Nicosia", "Famagusta", "Tbilisi", "Dili",
                  "Kolkata", "Jakarta", "Pontianak", "Makassar", "Jayapura",
                  "Tehran", "Baghdad", "Jerusalem", "Tokyo", "Amman",
                  "Almaty", "Qyzylorda", "Aqtobe", "Aqtau", "Atyrau", "Oral",
                  "Bishkek", "Seoul", "Pyongyang", "Beirut", "Kuala_Lumpur",
                  "Kuching", "Hovd", "Ulaanbaatar", "Choibalsan", "Kathmandu",
                  "Karachi", "Gaza", "Hebron", "Manila", "Qatar", "Riyadh",
                  "Singapore", "Colombo", "Damascus", "Dushanbe", "Bangkok",
                  "Ashgabat", "Dubai", "Samarkand", "Tashkent", "Ho_Chi_Minh",
                  "Aden", "Bahrain", "Chongqing", "Hanoi", "Harbin",
                  "Kashgar", "Kuwait", "Muscat", "Phnom_Penh", "Tel_Aviv",
                  "Vientiane", "Yekaterinburg", "Omsk", "Barnaul",
                  "Novosibirsk", "Tomsk", "Novokuznetsk", "Krasnoyarsk",
                  "Irkutsk", "Chita", "Yakutsk", "Vladivostok", "Khandyga",
                  "Sakhalin", "Magadan", "Srednekolymsk", "Ust-Nera",
                  "Kamchatka", "Anadyr"}),
   "Australia": ({"Darwin", "Perth", "Eucla", "Brisbane", "Lindeman",
                  "Adelaide", "Hobart", "Currie", "Melbourne", "Sydney",
                  "Broken_Hill", "Lord_Howe"}),
]);

// this is used to dwim timezone

//! constant mapping(string:array(string)) abbr2zones
//!	This mapping is used to look up abbreviation
//!	to the possible regional zones.
//!
//!	It looks like this:
//!	<pre>
//!	([ "CET": ({ "Europe/Stockholm", <i>[...]</i> }),
//!	   "CST": ({ "America/Chicago", "Australia/Adelaide", <i>[...]</i> }),
//!        <i>[...]</i> }),
//!	</pre>
//!
//!	Note this: Just because it's noted "CST" doesn't mean it's a
//!	unique timezone. There is about 7 *different* timezones that
//!	uses "CST" as abbreviation; not at the same time,
//!	though, so the DWIM routines checks this before
//!	it's satisfied. Same with some other timezones.
//!
//!     For most timezones, there is a number of region timezones that for the
//!     given time are equal. This is because region timezones include rules
//!     about local summer time shifts and possible historic shifts.
//!
//!	The <ref>YMD.parse</ref> functions can handle timezone abbreviations
//!	by guessing.

mapping abbr2zones =
([
   "": ({"Europe/Amsterdam", "Europe/Moscow"}),
   "%s": ({"Europe/Belfast", "Europe/Guernsey", "Europe/Isle_of_Man",
       "Europe/Jersey"}),
   "+00": ({"America/Scoresbysund", "Antarctica/Troll", "Atlantic/Azores",
       "Atlantic/Madeira", "Atlantic/Reykjavik"}),
   "+0020": ({"Africa/Accra", "Europe/Amsterdam"}),
   "+01": ({"Etc/GMT-1", "Africa/Freetown", "Atlantic/Madeira"}),
   "+0120": ({"Europe/Amsterdam"}),
   "+0130": ({"Africa/Windhoek"}),
   "+02": ({"Antarctica/Troll", "Etc/GMT-2", "Europe/Ulyanovsk",
       "Europe/Samara"}),
   "+0220": ({"Europe/Zaporozhye"}),
   "+0230": ({"Africa/Mogadishu", "Africa/Kampala", "Africa/Nairobi"}),
   "+0245": ({"Africa/Dar_es_Salaam", "Africa/Nairobi", "Africa/Kampala"}),
   "+03": ({"Antarctica/Syowa", "Asia/Aden", "Asia/Baghdad", "Asia/Bahrain",
       "Asia/Kuwait", "Asia/Qatar", "Asia/Riyadh", "Etc/GMT-3",
       "Europe/Istanbul", "Europe/Kirov", "Europe/Minsk", "Europe/Volgograd",
       "Asia/Famagusta", "Europe/Saratov", "Europe/Astrakhan",
       "Europe/Ulyanovsk", "Europe/Kaliningrad", "Europe/Samara",
       "Asia/Yerevan", "Asia/Baku", "Asia/Tbilisi", "Asia/Atyrau",
       "Asia/Oral"}),
   "+0330": ({"Asia/Tehran"}),
   "+04": ({"Asia/Baghdad", "Asia/Baku", "Asia/Dubai", "Asia/Muscat",
       "Asia/Tbilisi", "Asia/Yerevan", "Etc/GMT-4", "Europe/Astrakhan",
       "Europe/Samara", "Europe/Saratov", "Europe/Ulyanovsk", "Indian/Mahe",
       "Indian/Mauritius", "Indian/Reunion", "Europe/Kirov",
       "Europe/Volgograd", "Asia/Aqtau", "Asia/Atyrau", "Asia/Oral",
       "Asia/Aqtobe", "Asia/Yekaterinburg", "Asia/Qyzylorda", "Asia/Bahrain",
       "Asia/Qatar", "Asia/Ashgabat", "Asia/Tehran", "Europe/Istanbul",
       "Asia/Kabul", "Asia/Samarkand"}),
   "+0430": ({"Asia/Kabul", "Asia/Tehran"}),
   "+05": ({"Antarctica/Mawson", "Asia/Aqtau", "Asia/Aqtobe",
       "Asia/Ashgabat", "Asia/Atyrau", "Asia/Baku", "Asia/Dushanbe",
       "Asia/Oral", "Asia/Samarkand", "Asia/Tashkent", "Asia/Yekaterinburg",
       "Asia/Yerevan", "Etc/GMT-5", "Indian/Kerguelen", "Indian/Maldives",
       "Indian/Mauritius", "Antarctica/Davis", "Europe/Samara",
       "Asia/Qyzylorda", "Asia/Tbilisi", "Indian/Chagos", "Asia/Almaty",
       "Asia/Omsk", "Europe/Astrakhan", "Europe/Kirov", "Europe/Ulyanovsk",
       "Europe/Saratov", "Europe/Volgograd", "Asia/Kashgar", "Asia/Karachi",
       "Asia/Bishkek", "Asia/Tehran", "Europe/Moscow"}),
   "+0530": ({"Asia/Colombo", "Asia/Thimphu", "Asia/Kathmandu",
       "Asia/Karachi", "Asia/Dhaka", "Asia/Kashgar"}),
   "+0545": ({"Asia/Kathmandu"}),
   "+06": ({"Antarctica/Vostok", "Asia/Almaty", "Asia/Bishkek", "Asia/Dhaka",
       "Asia/Omsk", "Asia/Qyzylorda", "Asia/Thimphu", "Asia/Urumqi",
       "Etc/GMT-6", "Indian/Chagos", "Asia/Novosibirsk", "Asia/Tomsk",
       "Asia/Barnaul", "Asia/Yekaterinburg", "Asia/Novokuznetsk",
       "Antarctica/Mawson", "Asia/Colombo", "Asia/Aqtobe", "Asia/Atyrau",
       "Asia/Aqtau", "Asia/Oral", "Asia/Krasnoyarsk", "Asia/Dushanbe",
       "Asia/Samarkand", "Asia/Hovd", "Asia/Ashgabat", "Asia/Tashkent"}),
   "+0630": ({"Asia/Yangon", "Indian/Cocos", "Asia/Colombo", "Asia/Dhaka",
       "Asia/Karachi", "Asia/Kolkata"}),
   "+07": ({"Antarctica/Davis", "Asia/Bangkok", "Asia/Barnaul", "Asia/Dhaka",
       "Asia/Hanoi", "Asia/Ho_Chi_Minh", "Asia/Hovd", "Asia/Krasnoyarsk",
       "Asia/Novokuznetsk", "Asia/Novosibirsk", "Asia/Phnom_Penh",
       "Asia/Tomsk", "Asia/Vientiane", "Etc/GMT-7", "Indian/Christmas",
       "Asia/Omsk", "Asia/Almaty", "Asia/Qyzylorda", "Asia/Irkutsk",
       "Asia/Bishkek", "Asia/Dushanbe", "Asia/Chongqing", "Asia/Choibalsan",
       "Asia/Ulaanbaatar", "Asia/Tashkent", "Asia/Kuala_Lumpur",
       "Asia/Singapore"}),
   "+0720": ({"Asia/Kuala_Lumpur", "Asia/Singapore", "Asia/Jakarta"}),
   "+0730": ({"Asia/Kuala_Lumpur", "Asia/Singapore", "Asia/Jakarta",
       "Asia/Pontianak", "Asia/Brunei", "Asia/Kuching"}),
   "+08": ({"Antarctica/Casey", "Asia/Brunei", "Asia/Choibalsan",
       "Asia/Hovd", "Asia/Irkutsk", "Asia/Kuala_Lumpur", "Asia/Kuching",
       "Asia/Manila", "Asia/Singapore", "Asia/Ulaanbaatar", "Etc/GMT-8",
       "Asia/Chita", "Asia/Krasnoyarsk", "Asia/Novokuznetsk", "Asia/Dili",
       "Asia/Khandyga", "Asia/Yakutsk", "Asia/Barnaul", "Asia/Novosibirsk",
       "Asia/Tomsk", "Asia/Ho_Chi_Minh", "Asia/Vientiane", "Asia/Hanoi",
       "Asia/Phnom_Penh", "Asia/Jakarta", "Asia/Pontianak", "Asia/Makassar",
       "Asia/Ust-Nera"}),
   "+0820": ({"Asia/Kuching"}),
   "+0830": ({"Asia/Harbin"}),
   "+0845": ({"Australia/Eucla"}),
   "+09": ({"Asia/Chita", "Asia/Choibalsan", "Asia/Dili", "Asia/Khandyga",
       "Asia/Manila", "Asia/Ulaanbaatar", "Asia/Yakutsk", "Etc/GMT-9",
       "Pacific/Palau", "Asia/Irkutsk", "Asia/Vladivostok", "Asia/Ust-Nera",
       "Pacific/Saipan", "Asia/Harbin", "Asia/Jakarta", "Asia/Makassar",
       "Asia/Pontianak", "Asia/Kuala_Lumpur", "Asia/Kuching",
       "Asia/Singapore", "Asia/Hanoi", "Asia/Ho_Chi_Minh", "Asia/Phnom_Penh",
       "Asia/Vientiane", "Asia/Sakhalin", "Pacific/Bougainville",
       "Asia/Yangon", "Asia/Jayapura", "Pacific/Nauru"}),
   "+0930": ({"Asia/Jayapura"}),
   "+0945": ({"Australia/Eucla"}),
   "+10": ({"Antarctica/DumontDUrville", "Asia/Ust-Nera", "Asia/Vladivostok",
       "Etc/GMT-10", "Pacific/Chuuk", "Pacific/Port_Moresby", "Asia/Magadan",
       "Asia/Sakhalin", "Pacific/Bougainville", "Asia/Chita",
       "Asia/Khandyga", "Asia/Yakutsk", "Pacific/Saipan",
       "Asia/Srednekolymsk", "Asia/Choibalsan"}),
   "+1030": ({"Australia/Lord_Howe"}),
   "+11": ({"Antarctica/Macquarie", "Asia/Magadan", "Asia/Sakhalin",
       "Asia/Srednekolymsk", "Australia/Lord_Howe", "Etc/GMT-11",
       "Pacific/Bougainville", "Pacific/Efate", "Pacific/Guadalcanal",
       "Pacific/Kosrae", "Pacific/Norfolk", "Pacific/Noumea",
       "Pacific/Pohnpei", "Antarctica/Casey", "Asia/Ust-Nera",
       "Asia/Vladivostok", "Asia/Khandyga", "Asia/Anadyr", "Asia/Kamchatka",
       "Pacific/Kwajalein", "Pacific/Majuro"}),
   "+1112": ({"Pacific/Norfolk"}),
   "+1130": ({"Pacific/Norfolk", "Pacific/Nauru", "Australia/Lord_Howe"}),
   "+12": ({"Asia/Anadyr", "Asia/Kamchatka", "Etc/GMT-12", "Pacific/Efate",
       "Pacific/Fiji", "Pacific/Funafuti", "Pacific/Kwajalein",
       "Pacific/Majuro", "Pacific/Nauru", "Pacific/Noumea", "Pacific/Tarawa",
       "Pacific/Wake", "Pacific/Wallis", "Asia/Magadan",
       "Asia/Srednekolymsk", "Asia/Ust-Nera", "Pacific/Kosrae",
       "Asia/Sakhalin"}),
   "+1215": ({"Pacific/Chatham"}),
   "+1220": ({"Pacific/Tongatapu"}),
   "+1230": ({"Pacific/Norfolk"}),
   "+1245": ({"Pacific/Chatham"}),
   "+13": ({"Etc/GMT-13", "Pacific/Apia", "Pacific/Enderbury",
       "Pacific/Fakaofo", "Pacific/Fiji", "Pacific/Tongatapu", "Asia/Anadyr",
       "Asia/Kamchatka"}),
   "+1345": ({"Pacific/Chatham"}),
   "+14": ({"Etc/GMT-14", "Pacific/Apia", "Pacific/Kiritimati",
       "Pacific/Tongatapu", "Asia/Anadyr"}),
   "-00": ({"Factory", "Antarctica/Troll", "Antarctica/Rothera",
       "Antarctica/Davis", "Antarctica/Casey", "Antarctica/Palmer",
       "Antarctica/Vostok", "Antarctica/Syowa", "America/Rankin_Inlet",
       "Antarctica/DumontDUrville", "Antarctica/McMurdo",
       "Antarctica/Mawson", "America/Inuvik", "Indian/Kerguelen",
       "Antarctica/Macquarie", "America/Resolute", "America/Iqaluit",
       "America/Yellowknife", "America/Pangnirtung", "America/Cambridge_Bay"}),
   "-0020": ({"Africa/Freetown"}),
   "-01": ({"America/Scoresbysund", "Atlantic/Azores", "Atlantic/Cape_Verde",
       "Atlantic/Jan_Mayen", "Etc/GMT+1", "Africa/El_Aaiun", "Africa/Bissau",
       "Africa/Freetown", "America/Noronha", "Atlantic/Madeira",
       "Atlantic/Reykjavik", "Africa/Banjul", "Africa/Nouakchott",
       "Africa/Bamako", "Africa/Conakry", "Atlantic/Canary", "Africa/Dakar",
       "Africa/Niamey"}),
   "-0130": ({"America/Montevideo"}),
   "-02": ({"America/Argentina/Buenos_Aires", "America/Argentina/Cordoba",
       "America/Argentina/Tucuman", "America/Godthab", "America/Miquelon",
       "America/Montevideo", "America/Noronha", "America/Sao_Paulo",
       "Atlantic/South_Georgia", "Etc/GMT+2", "America/Argentina/Jujuy",
       "America/Argentina/San_Luis", "America/Scoresbysund",
       "Atlantic/Cape_Verde", "America/Araguaina",
       "America/Argentina/Catamarca", "America/Argentina/ComodRivadavia",
       "America/Argentina/La_Rioja", "America/Argentina/Mendoza",
       "America/Argentina/Rio_Gallegos", "America/Argentina/Salta",
       "America/Argentina/San_Juan", "America/Argentina/Ushuaia",
       "America/Bahia", "America/Belem", "America/Danmarkshavn",
       "America/Fortaleza", "America/Maceio", "America/Recife",
       "America/Rosario", "Antarctica/Palmer", "Atlantic/Azores",
       "Atlantic/Stanley"}),
   "-0230": ({"America/Montevideo"}),
   "-03": ({"America/Araguaina", "America/Argentina/Buenos_Aires",
       "America/Argentina/Catamarca", "America/Argentina/ComodRivadavia",
       "America/Argentina/Cordoba", "America/Argentina/Jujuy",
       "America/Argentina/La_Rioja", "America/Argentina/Mendoza",
       "America/Argentina/Rio_Gallegos", "America/Argentina/Salta",
       "America/Argentina/San_Juan", "America/Argentina/San_Luis",
       "America/Argentina/Tucuman", "America/Argentina/Ushuaia",
       "America/Asuncion", "America/Bahia", "America/Belem",
       "America/Campo_Grande", "America/Cayenne", "America/Cuiaba",
       "America/Fortaleza", "America/Godthab", "America/Maceio",
       "America/Miquelon", "America/Montevideo", "America/Paramaribo",
       "America/Punta_Arenas", "America/Recife", "America/Rosario",
       "America/Santarem", "America/Santiago", "America/Sao_Paulo",
       "Antarctica/Palmer", "Antarctica/Rothera", "Atlantic/Stanley",
       "Etc/GMT+3", "America/Guyana", "America/Danmarkshavn",
       "America/Boa_Vista", "America/Manaus", "America/Porto_Velho"}),
   "-0330": ({"America/Paramaribo", "America/Montevideo"}),
   "-0345": ({"America/Guyana"}),
   "-04": ({"America/Asuncion", "America/Boa_Vista", "America/Bogota",
       "America/Campo_Grande", "America/Caracas", "America/Cuiaba",
       "America/Guayaquil", "America/Guyana", "America/La_Paz",
       "America/Lima", "America/Manaus", "America/Porto_Velho",
       "America/Santiago", "Etc/GMT+4", "America/Eirunepe",
       "America/Rio_Branco", "America/Santarem", "America/Argentina/Mendoza",
       "America/Argentina/San_Juan", "America/Argentina/San_Luis",
       "America/Argentina/Catamarca", "America/Argentina/ComodRivadavia",
       "America/Argentina/La_Rioja", "America/Argentina/Rio_Gallegos",
       "America/Argentina/Ushuaia", "America/Argentina/Tucuman",
       "America/Argentina/Cordoba", "America/Argentina/Salta",
       "America/Argentina/Jujuy", "America/Argentina/Buenos_Aires",
       "America/Punta_Arenas", "America/Rosario", "Antarctica/Palmer",
       "Atlantic/Stanley", "America/Cayenne", "America/Montevideo"}),
   "-0430": ({"America/Caracas", "America/Santo_Domingo", "America/Aruba",
       "America/Curacao"}),
   "-05": ({"America/Bogota", "America/Eirunepe", "America/Guayaquil",
       "America/Lima", "America/Rio_Branco", "Etc/GMT+5", "Pacific/Easter",
       "Pacific/Galapagos", "America/Punta_Arenas", "America/Santiago"}),
   "-0530": ({"America/Belize"}),
   "-06": ({"Etc/GMT+6", "Pacific/Easter", "Pacific/Galapagos"}),
   "-07": ({"Etc/GMT+7", "Pacific/Easter"}),
   "-08": ({"Etc/GMT+8", "Pacific/Pitcairn"}),
   "-0830": ({"Pacific/Pitcairn"}),
   "-09": ({"Etc/GMT+9", "Pacific/Gambier"}),
   "-0930": ({"Pacific/Marquesas", "Pacific/Rarotonga"}),
   "-10": ({"Etc/GMT+10", "Pacific/Rarotonga", "Pacific/Tahiti",
       "Pacific/Kiritimati", "Pacific/Apia", "Pacific/Midway"}),
   "-1030": ({"Pacific/Rarotonga"}),
   "-1040": ({"Pacific/Kiritimati"}),
   "-11": ({"Etc/GMT+11", "Pacific/Midway", "Pacific/Niue",
       "Pacific/Fakaofo", "Pacific/Enderbury", "Pacific/Apia"}),
   "-1120": ({"Pacific/Niue"}),
   "-1130": ({"Pacific/Niue", "Pacific/Apia"}),
   "-12": ({"Etc/GMT+12", "Pacific/Kwajalein", "Pacific/Enderbury"}),
   "ACDT": ({"Australia/Adelaide", "Australia/Broken_Hill",
       "Australia/Darwin"}),
   "ACST": ({"Australia/Adelaide", "Australia/Broken_Hill",
       "Australia/Darwin"}),
   "ADDT": ({"America/Goose_Bay", "America/Pangnirtung"}),
   "ADMT": ({"Africa/Addis_Ababa", "Africa/Asmara"}),
   "ADT": ({"America/Barbados", "America/Glace_Bay", "America/Goose_Bay",
       "America/Halifax", "America/Moncton", "America/Thule",
       "Atlantic/Bermuda", "America/Martinique", "America/Anchorage",
       "America/Blanc-Sablon", "America/Pangnirtung", "America/Puerto_Rico"}),
   "AEDT": ({"Australia/Brisbane", "Australia/Currie", "Australia/Hobart",
       "Australia/Lindeman", "Australia/Melbourne", "Australia/Sydney",
       "Antarctica/Macquarie"}),
   "AEST": ({"Australia/Brisbane", "Australia/Currie", "Australia/Hobart",
       "Australia/Lindeman", "Australia/Melbourne", "Australia/Sydney",
       "Australia/Lord_Howe", "Antarctica/Macquarie",
       "Australia/Broken_Hill"}),
   "AHDT": ({"America/Adak", "America/Anchorage"}),
   "AHPT": ({"America/Adak", "America/Anchorage"}),
   "AHST": ({"America/Adak", "America/Anchorage"}),
   "AHWT": ({"America/Adak", "America/Anchorage"}),
   "AKDT": ({"America/Anchorage", "America/Juneau", "America/Metlakatla",
       "America/Nome", "America/Sitka", "America/Yakutat"}),
   "AKPT": ({"America/Anchorage", "America/Juneau", "America/Metlakatla",
       "America/Nome", "America/Sitka", "America/Yakutat"}),
   "AKST": ({"America/Anchorage", "America/Juneau", "America/Metlakatla",
       "America/Nome", "America/Sitka", "America/Yakutat"}),
   "AKWT": ({"America/Anchorage", "America/Juneau", "America/Metlakatla",
       "America/Nome", "America/Sitka", "America/Yakutat"}),
   "AMT": ({"Europe/Amsterdam", "America/Asuncion", "Europe/Athens",
       "Africa/Asmara"}),
   "APT": ({"America/Glace_Bay", "America/Goose_Bay", "America/Halifax",
       "America/Moncton", "Atlantic/Bermuda", "America/Anchorage",
       "America/Blanc-Sablon", "America/Pangnirtung", "America/Puerto_Rico"}),
   "AST": ({"America/Anguilla", "America/Antigua", "America/Aruba",
       "America/Barbados", "America/Blanc-Sablon", "America/Curacao",
       "America/Dominica", "America/Glace_Bay", "America/Goose_Bay",
       "America/Grenada", "America/Guadeloupe", "America/Halifax",
       "America/Martinique", "America/Moncton", "America/Montserrat",
       "America/Port_of_Spain", "America/Puerto_Rico",
       "America/Santo_Domingo", "America/St_Kitts", "America/St_Lucia",
       "America/St_Thomas", "America/St_Vincent", "America/Thule",
       "America/Tortola", "Atlantic/Bermuda", "America/Grand_Turk",
       "America/Miquelon", "America/Anchorage", "America/Pangnirtung"}),
   "AWDT": ({"Australia/Perth"}),
   "AWST": ({"Australia/Perth"}),
   "AWT": ({"America/Glace_Bay", "America/Goose_Bay", "America/Halifax",
       "America/Moncton", "Atlantic/Bermuda", "America/Anchorage",
       "America/Blanc-Sablon", "America/Pangnirtung", "America/Puerto_Rico"}),
   "BDST": ({"Europe/Dublin", "Europe/Gibraltar", "Europe/London"}),
   "BDT": ({"America/Adak", "America/Nome"}),
   "BMT": ({"Africa/Banjul", "America/Barbados", "Europe/Bucharest",
       "Europe/Chisinau", "Europe/Tiraspol", "Asia/Jakarta", "Asia/Bangkok",
       "Asia/Baghdad", "America/Bogota", "Europe/Zurich", "Europe/Brussels"}),
   "BPT": ({"America/Adak", "America/Nome"}),
   "BST": ({"Europe/Belfast", "Europe/Guernsey", "Europe/Isle_of_Man",
       "Europe/Jersey", "Europe/London", "America/Adak", "America/Nome",
       "Europe/Dublin", "Europe/Gibraltar", "America/La_Paz"}),
   "BWT": ({"America/Adak", "America/Nome"}),
   "CAST": ({"Africa/Juba", "Africa/Khartoum", "Africa/Gaborone"}),
   "CAT": ({"Africa/Blantyre", "Africa/Bujumbura", "Africa/Gaborone",
       "Africa/Harare", "Africa/Khartoum", "Africa/Kigali",
       "Africa/Lubumbashi", "Africa/Lusaka", "Africa/Maputo",
       "Africa/Windhoek", "Africa/Juba"}),
   "CDDT": ({"America/Rankin_Inlet", "America/Resolute"}),
   "CDT": ({"America/Bahia_Banderas", "America/Belize", "America/Chicago",
       "America/Costa_Rica", "America/El_Salvador", "America/Guatemala",
       "America/Havana", "America/Indiana/Knox", "America/Indiana/Tell_City",
       "America/Managua", "America/Matamoros", "America/Menominee",
       "America/Merida", "America/Mexico_City", "America/Monterrey",
       "America/North_Dakota/Beulah", "America/North_Dakota/Center",
       "America/North_Dakota/New_Salem", "America/Rainy_River",
       "America/Rankin_Inlet", "America/Resolute", "America/Tegucigalpa",
       "America/Winnipeg", "Asia/Chongqing", "Asia/Harbin", "Asia/Kashgar",
       "Asia/Macau", "Asia/Shanghai", "Asia/Taipei", "CST6CDT",
       "America/Indiana/Marengo", "America/Kentucky/Louisville",
       "America/Atikokan", "America/Cambridge_Bay", "America/Cancun",
       "America/Chihuahua", "America/Indiana/Indianapolis",
       "America/Indiana/Petersburg", "America/Indiana/Vevay",
       "America/Indiana/Vincennes", "America/Indiana/Winamac",
       "America/Iqaluit", "America/Kentucky/Monticello", "America/Ojinaga",
       "America/Pangnirtung"}),
   "CE%sT": ({"Europe/Ljubljana", "Europe/Sarajevo", "Europe/Skopje",
       "Europe/Vaduz", "Europe/Zagreb", "Europe/Guernsey", "Europe/Jersey",
       "Europe/Tiraspol"}),
   "CEMT": ({"Europe/Berlin", "Europe/Madrid", "Europe/Monaco",
       "Europe/Paris"}),
   "CEST": ({"Africa/Ceuta", "Africa/Tunis", "CET", "Europe/Amsterdam",
       "Europe/Andorra", "Europe/Belgrade", "Europe/Berlin",
       "Europe/Brussels", "Europe/Budapest", "Europe/Copenhagen",
       "Europe/Gibraltar", "Europe/Luxembourg", "Europe/Madrid",
       "Europe/Malta", "Europe/Monaco", "Europe/Oslo", "Europe/Paris",
       "Europe/Prague", "Europe/Rome", "Europe/Stockholm", "Europe/Tirane",
       "Europe/Vienna", "Europe/Warsaw", "Europe/Zurich", "Europe/Vilnius",
       "Europe/Lisbon", "Africa/Algiers", "Africa/Tripoli", "Europe/Athens",
       "Europe/Chisinau", "Europe/Kaliningrad", "Europe/Kiev",
       "Europe/Minsk", "Europe/Riga", "Europe/Simferopol", "Europe/Sofia",
       "Europe/Tallinn", "Europe/Uzhgorod", "Europe/Zaporozhye",
       "Europe/Ljubljana", "Europe/Sarajevo", "Europe/Skopje",
       "Europe/Zagreb"}),
   "CET": ({"Africa/Algiers", "Africa/Ceuta", "Africa/Tunis", "CET",
       "Europe/Amsterdam", "Europe/Andorra", "Europe/Belgrade",
       "Europe/Berlin", "Europe/Brussels", "Europe/Budapest",
       "Europe/Copenhagen", "Europe/Gibraltar", "Europe/Luxembourg",
       "Europe/Madrid", "Europe/Malta", "Europe/Monaco", "Europe/Oslo",
       "Europe/Paris", "Europe/Prague", "Europe/Rome", "Europe/Stockholm",
       "Europe/Tirane", "Europe/Vienna", "Europe/Warsaw", "Europe/Zurich",
       "Europe/Vilnius", "Europe/Lisbon", "Europe/Uzhgorod",
       "Africa/Casablanca", "Europe/Ljubljana", "Europe/Sarajevo",
       "Europe/Skopje", "Europe/Zagreb", "Europe/Vaduz", "Africa/Tripoli",
       "Europe/Athens", "Europe/Chisinau", "Europe/Kaliningrad",
       "Europe/Kiev", "Europe/Minsk", "Europe/Riga", "Europe/Simferopol",
       "Europe/Sofia", "Europe/Tallinn", "Europe/Zaporozhye"}),
   "CMT": ({"America/La_Paz", "America/Argentina/Buenos_Aires",
       "America/Argentina/Catamarca", "America/Argentina/ComodRivadavia",
       "America/Argentina/Cordoba", "America/Argentina/Jujuy",
       "America/Argentina/La_Rioja", "America/Argentina/Mendoza",
       "America/Argentina/Rio_Gallegos", "America/Argentina/Salta",
       "America/Argentina/San_Juan", "America/Argentina/San_Luis",
       "America/Argentina/Tucuman", "America/Argentina/Ushuaia",
       "America/Rosario", "Europe/Chisinau", "Europe/Tiraspol",
       "America/Caracas", "America/St_Lucia", "America/Panama",
       "Europe/Copenhagen"}),
   "CPT": ({"America/Chicago", "America/Indiana/Knox",
       "America/Indiana/Tell_City", "America/Matamoros", "America/Menominee",
       "America/North_Dakota/Beulah", "America/North_Dakota/Center",
       "America/North_Dakota/New_Salem", "America/Rainy_River",
       "America/Rankin_Inlet", "America/Resolute", "America/Winnipeg",
       "CST6CDT", "America/Atikokan", "America/Cambridge_Bay",
       "America/Indiana/Indianapolis", "America/Indiana/Marengo",
       "America/Indiana/Petersburg", "America/Indiana/Vevay",
       "America/Indiana/Vincennes", "America/Indiana/Winamac",
       "America/Iqaluit", "America/Kentucky/Louisville",
       "America/Kentucky/Monticello", "America/Monterrey",
       "America/Pangnirtung"}),
   "CST": ({"America/Bahia_Banderas", "America/Belize", "America/Chicago",
       "America/Costa_Rica", "America/El_Salvador", "America/Guatemala",
       "America/Havana", "America/Indiana/Knox", "America/Indiana/Tell_City",
       "America/Managua", "America/Matamoros", "America/Menominee",
       "America/Merida", "America/Mexico_City", "America/Monterrey",
       "America/North_Dakota/Beulah", "America/North_Dakota/Center",
       "America/North_Dakota/New_Salem", "America/Rainy_River",
       "America/Rankin_Inlet", "America/Regina", "America/Resolute",
       "America/Swift_Current", "America/Tegucigalpa", "America/Winnipeg",
       "Asia/Chongqing", "Asia/Harbin", "Asia/Kashgar", "Asia/Macau",
       "Asia/Shanghai", "Asia/Taipei", "CST6CDT", "America/Cambridge_Bay",
       "America/Chihuahua", "America/Ojinaga", "America/Cancun",
       "America/Atikokan", "America/Indiana/Indianapolis",
       "America/Indiana/Marengo", "America/Indiana/Petersburg",
       "America/Indiana/Vevay", "America/Indiana/Vincennes",
       "America/Indiana/Winamac", "America/Iqaluit",
       "America/Kentucky/Louisville", "America/Kentucky/Monticello",
       "America/Pangnirtung", "America/Hermosillo", "America/Mazatlan",
       "America/Detroit", "America/Thunder_Bay"}),
   "CWT": ({"America/Bahia_Banderas", "America/Chicago",
       "America/Indiana/Knox", "America/Indiana/Tell_City",
       "America/Matamoros", "America/Menominee", "America/Merida",
       "America/Mexico_City", "America/Monterrey",
       "America/North_Dakota/Beulah", "America/North_Dakota/Center",
       "America/North_Dakota/New_Salem", "America/Rainy_River",
       "America/Rankin_Inlet", "America/Resolute", "America/Winnipeg",
       "CST6CDT", "America/Atikokan", "America/Cambridge_Bay",
       "America/Cancun", "America/Chihuahua", "America/Indiana/Indianapolis",
       "America/Indiana/Marengo", "America/Indiana/Petersburg",
       "America/Indiana/Vevay", "America/Indiana/Vincennes",
       "America/Indiana/Winamac", "America/Iqaluit",
       "America/Kentucky/Louisville", "America/Kentucky/Monticello",
       "America/Ojinaga", "America/Pangnirtung"}),
   "ChST": ({"Pacific/Guam", "Pacific/Saipan"}),
   "DFT": ({"Europe/Oslo", "Europe/Paris"}),
   "DMT": ({"Europe/Belfast", "Europe/Dublin"}),
   "E%sT": ({"America/Montreal", "America/Coral_Harbour"}),
   "EAST": ({"Indian/Antananarivo"}),
   "EAT": ({"Africa/Addis_Ababa", "Africa/Asmara", "Africa/Dar_es_Salaam",
       "Africa/Djibouti", "Africa/Juba", "Africa/Kampala",
       "Africa/Mogadishu", "Africa/Nairobi", "Indian/Antananarivo",
       "Indian/Comoro", "Indian/Mayotte", "Africa/Khartoum"}),
   "EDDT": ({"America/Iqaluit"}),
   "EDT": ({"America/Detroit", "America/Grand_Turk",
       "America/Indiana/Indianapolis", "America/Indiana/Marengo",
       "America/Indiana/Petersburg", "America/Indiana/Vevay",
       "America/Indiana/Vincennes", "America/Indiana/Winamac",
       "America/Iqaluit", "America/Kentucky/Louisville",
       "America/Kentucky/Monticello", "America/Nassau", "America/New_York",
       "America/Nipigon", "America/Pangnirtung", "America/Port-au-Prince",
       "America/Thunder_Bay", "America/Toronto", "EST5EDT", "America/Cancun",
       "America/Indiana/Tell_City", "America/Jamaica", "America/Montreal",
       "America/Santo_Domingo"}),
   "EE%sT": ({"Europe/Tiraspol"}),
   "EEST": ({"Africa/Cairo", "Asia/Amman", "Asia/Beirut", "Asia/Damascus",
       "Asia/Famagusta", "Asia/Gaza", "Asia/Hebron", "Asia/Nicosia", "EET",
       "Europe/Athens", "Europe/Bucharest", "Europe/Chisinau",
       "Europe/Helsinki", "Europe/Kiev", "Europe/Riga", "Europe/Sofia",
       "Europe/Tallinn", "Europe/Uzhgorod", "Europe/Vilnius",
       "Europe/Zaporozhye", "Europe/Istanbul", "Europe/Kaliningrad",
       "Europe/Minsk", "Europe/Moscow", "Europe/Simferopol",
       "Europe/Tiraspol", "Europe/Warsaw"}),
   "EET": ({"Africa/Cairo", "Africa/Tripoli", "Asia/Amman", "Asia/Beirut",
       "Asia/Damascus", "Asia/Famagusta", "Asia/Gaza", "Asia/Hebron",
       "Asia/Nicosia", "EET", "Europe/Athens", "Europe/Bucharest",
       "Europe/Chisinau", "Europe/Helsinki", "Europe/Kaliningrad",
       "Europe/Kiev", "Europe/Riga", "Europe/Sofia", "Europe/Tallinn",
       "Europe/Uzhgorod", "Europe/Vilnius", "Europe/Zaporozhye",
       "Europe/Istanbul", "Europe/Minsk", "Europe/Moscow",
       "Europe/Simferopol", "Europe/Tiraspol", "Europe/Warsaw"}),
   "EMT": ({"Pacific/Easter"}),
   "EPT": ({"America/Detroit", "America/Grand_Turk",
       "America/Indiana/Indianapolis", "America/Indiana/Marengo",
       "America/Indiana/Petersburg", "America/Indiana/Vevay",
       "America/Indiana/Vincennes", "America/Indiana/Winamac",
       "America/Iqaluit", "America/Kentucky/Louisville",
       "America/Kentucky/Monticello", "America/Nassau", "America/New_York",
       "America/Nipigon", "America/Pangnirtung", "America/Thunder_Bay",
       "America/Toronto", "EST5EDT", "America/Indiana/Tell_City",
       "America/Jamaica", "America/Santo_Domingo"}),
   "EST": ({"America/Atikokan", "America/Cancun", "America/Cayman",
       "America/Coral_Harbour", "America/Detroit", "America/Grand_Turk",
       "America/Indiana/Indianapolis", "America/Indiana/Marengo",
       "America/Indiana/Petersburg", "America/Indiana/Vevay",
       "America/Indiana/Vincennes", "America/Indiana/Winamac",
       "America/Iqaluit", "America/Jamaica", "America/Kentucky/Louisville",
       "America/Kentucky/Monticello", "America/Nassau", "America/New_York",
       "America/Nipigon", "America/Panama", "America/Pangnirtung",
       "America/Port-au-Prince", "America/Thunder_Bay", "America/Toronto",
       "EST", "EST5EDT", "America/Resolute", "America/Indiana/Knox",
       "America/Indiana/Tell_City", "America/Rankin_Inlet",
       "America/Cambridge_Bay", "America/Managua", "America/Merida",
       "America/Menominee", "America/Montreal", "America/Santo_Domingo",
       "America/Antigua", "America/Chicago", "America/Moncton"}),
   "EWT": ({"America/Detroit", "America/Grand_Turk",
       "America/Indiana/Indianapolis", "America/Indiana/Marengo",
       "America/Indiana/Petersburg", "America/Indiana/Vevay",
       "America/Indiana/Vincennes", "America/Indiana/Winamac",
       "America/Iqaluit", "America/Kentucky/Louisville",
       "America/Kentucky/Monticello", "America/Nassau", "America/New_York",
       "America/Nipigon", "America/Pangnirtung", "America/Thunder_Bay",
       "America/Toronto", "EST5EDT", "America/Cancun",
       "America/Indiana/Tell_City", "America/Jamaica",
       "America/Santo_Domingo"}),
   "FFMT": ({"America/Martinique"}),
   "FMT": ({"Africa/Freetown", "Atlantic/Madeira"}),
   "GMT": ({"Africa/Abidjan", "Africa/Accra", "Africa/Bamako",
       "Africa/Banjul", "Africa/Bissau", "Africa/Conakry", "Africa/Dakar",
       "Africa/Lome", "Africa/Monrovia", "Africa/Nouakchott",
       "Africa/Ouagadougou", "Africa/Timbuktu", "America/Danmarkshavn",
       "Atlantic/Reykjavik", "Atlantic/St_Helena", "Etc/GMT",
       "Europe/Belfast", "Europe/Dublin", "Europe/Guernsey",
       "Europe/Isle_of_Man", "Europe/Jersey", "Europe/London",
       "Africa/Sao_Tome", "Africa/Freetown", "Europe/Gibraltar",
       "Africa/Malabo", "Africa/Niamey", "Europe/Prague",
       "Africa/Porto-Novo"}),
   "GST": ({"Pacific/Guam"}),
   "HDT": ({"America/Adak", "Pacific/Honolulu"}),
   "HKST": ({"Asia/Hong_Kong"}),
   "HKT": ({"Asia/Hong_Kong"}),
   "HMT": ({"Asia/Dhaka", "America/Havana", "Europe/Helsinki",
       "Atlantic/Azores", "Asia/Kolkata"}),
   "HPT": ({"America/Adak"}),
   "HST": ({"America/Adak", "HST", "Pacific/Honolulu", "Pacific/Johnston"}),
   "HWT": ({"America/Adak"}),
   "IDDT": ({"Asia/Jerusalem", "Asia/Tel_Aviv", "Asia/Gaza", "Asia/Hebron"}),
   "IDT": ({"Asia/Jerusalem", "Asia/Tel_Aviv", "Asia/Gaza", "Asia/Hebron"}),
   "IMT": ({"Asia/Irkutsk", "Europe/Istanbul", "Europe/Sofia"}),
   "IST": ({"Asia/Jerusalem", "Asia/Kolkata", "Asia/Tel_Aviv",
       "Europe/Dublin", "Asia/Gaza", "Asia/Hebron", "Europe/Belfast"}),
   "JDT": ({"Asia/Tokyo"}),
   "JMT": ({"Atlantic/St_Helena", "Asia/Jerusalem", "Asia/Tel_Aviv"}),
   "JST": ({"Asia/Tokyo", "Asia/Taipei", "Asia/Hong_Kong", "Asia/Seoul",
       "Asia/Pyongyang"}),
   "KDT": ({"Asia/Seoul"}),
   "KMT": ({"Europe/Kiev", "Europe/Vilnius", "America/Cayman",
       "America/Grand_Turk", "America/Jamaica", "America/St_Vincent"}),
   "KST": ({"Asia/Pyongyang", "Asia/Seoul"}),
   "LMT": ({"Asia/Aden", "Asia/Kuwait", "Asia/Thimphu", "Asia/Riyadh",
       "Africa/Kigali", "Africa/El_Aaiun", "Asia/Jayapura",
       "Pacific/Galapagos", "Africa/Juba", "Africa/Khartoum", "Asia/Amman",
       "Africa/Dar_es_Salaam", "Atlantic/Bermuda", "Africa/Kampala",
       "Africa/Nairobi", "Asia/Kashgar", "Asia/Urumqi", "Asia/Chongqing",
       "Asia/Harbin", "Asia/Kuching", "Asia/Brunei", "Asia/Yerevan",
       "Asia/Baku", "Asia/Aqtau", "Asia/Oral", "Asia/Atyrau", "Asia/Aqtobe",
       "Asia/Ashgabat", "Asia/Qyzylorda", "Asia/Samarkand", "Asia/Dushanbe",
       "Asia/Tashkent", "Asia/Bishkek", "Asia/Almaty", "Asia/Magadan",
       "Asia/Srednekolymsk", "Asia/Anadyr", "Europe/Astrakhan",
       "Asia/Novokuznetsk", "America/Barbados", "Asia/Vladivostok",
       "Asia/Kamchatka", "Atlantic/Canary", "America/Ensenada",
       "America/Tijuana", "America/Bahia_Banderas", "America/Chihuahua",
       "America/Hermosillo", "America/Mazatlan", "America/Mexico_City",
       "America/Ojinaga", "America/Cancun", "America/Matamoros",
       "America/Merida", "America/Monterrey", "Asia/Nicosia",
       "Asia/Famagusta", "America/Tegucigalpa", "Pacific/Nauru",
       "America/El_Salvador", "Asia/Krasnoyarsk", "Europe/Volgograd",
       "Africa/Tripoli", "Asia/Damascus", "Asia/Bahrain", "Asia/Qatar",
       "Asia/Dubai", "Asia/Muscat", "Asia/Kathmandu", "Asia/Makassar",
       "Asia/Tomsk", "Asia/Chita", "Asia/Yakutsk", "Asia/Khandyga",
       "Asia/Ust-Nera", "Asia/Novosibirsk", "Asia/Barnaul", "Asia/Omsk",
       "Africa/Lagos", "Europe/Kirov", "Europe/Samara", "Europe/Saratov",
       "Europe/Ulyanovsk", "America/Guatemala", "Africa/Accra",
       "America/Thule", "America/Godthab", "America/Scoresbysund",
       "America/Danmarkshavn", "Asia/Yekaterinburg", "Asia/Tehran",
       "Pacific/Fiji", "America/Guyana", "America/Eirunepe",
       "America/Rio_Branco", "America/Porto_Velho", "America/Boa_Vista",
       "America/Manaus", "America/Cuiaba", "America/Santarem",
       "America/Campo_Grande", "America/Belem", "America/Araguaina",
       "America/Sao_Paulo", "America/Bahia", "America/Fortaleza",
       "America/Maceio", "America/Recife", "America/Noronha",
       "Europe/Tirane", "Africa/Casablanca", "Europe/Guernsey",
       "Pacific/Tahiti", "Pacific/Marquesas", "Pacific/Gambier",
       "Pacific/Guadalcanal", "America/Belize", "America/Nassau",
       "America/Anguilla", "America/St_Kitts", "America/Antigua",
       "America/Port_of_Spain", "America/Aruba", "America/Curacao",
       "Pacific/Noumea", "Pacific/Efate", "Atlantic/Cape_Verde",
       "Africa/Dakar", "Africa/Banjul", "Africa/Nouakchott", "Africa/Bissau",
       "Africa/Conakry", "Africa/Bamako", "Africa/Abidjan",
       "Africa/Timbuktu", "Africa/Ouagadougou", "Africa/Sao_Tome",
       "Europe/Lisbon", "Africa/Niamey", "Africa/Porto-Novo",
       "Africa/Malabo", "Africa/Libreville", "Africa/Douala",
       "Africa/Luanda", "Africa/Ndjamena", "Africa/Brazzaville",
       "Africa/Bangui", "Asia/Macau", "Asia/Dili", "America/St_Thomas",
       "America/Tortola", "America/Montserrat", "America/Grenada",
       "America/Dominica", "America/Cayenne", "Africa/Djibouti",
       "Indian/Comoro", "Indian/Mayotte", "Indian/Antananarivo",
       "America/Guadeloupe", "Indian/Reunion", "America/Miquelon",
       "Pacific/Apia", "Pacific/Pago_Pago", "America/Paramaribo",
       "America/Lima", "America/Montevideo", "Asia/Pontianak",
       "Asia/Pyongyang", "Asia/Seoul", "Atlantic/Faroe",
       "Atlantic/Reykjavik", "Indian/Mauritius", "Asia/Karachi",
       "Indian/Chagos", "America/Edmonton", "Asia/Vientiane",
       "Asia/Phnom_Penh", "Asia/Hanoi", "Asia/Ho_Chi_Minh", "Indian/Mahe",
       "America/Swift_Current", "America/Regina", "Asia/Sakhalin",
       "Asia/Hovd", "Asia/Ulaanbaatar", "Asia/Choibalsan", "America/Detroit",
       "Asia/Hong_Kong", "Europe/Luxembourg", "Africa/Maseru",
       "Africa/Lusaka", "Africa/Harare", "Africa/Mbabane", "Africa/Maputo",
       "Africa/Blantyre", "America/Halifax", "America/Glace_Bay",
       "Pacific/Midway", "Pacific/Fakaofo", "Pacific/Enderbury",
       "Pacific/Niue", "Pacific/Rarotonga", "Pacific/Kiritimati",
       "Pacific/Pitcairn", "Africa/Ceuta", "Europe/Madrid", "Europe/Andorra",
       "Asia/Kuala_Lumpur", "Asia/Singapore", "Asia/Shanghai",
       "Pacific/Palau", "Pacific/Guam", "Pacific/Saipan", "Pacific/Chuuk",
       "Pacific/Pohnpei", "Pacific/Kosrae", "Pacific/Wake",
       "Pacific/Kwajalein", "Pacific/Norfolk", "Pacific/Majuro",
       "Pacific/Tarawa", "Pacific/Funafuti", "Pacific/Wallis",
       "Pacific/Tongatapu", "Africa/Cairo", "Asia/Gaza", "Asia/Hebron",
       "America/Adak", "America/Nome", "America/Anchorage",
       "America/Yakutat", "America/Sitka", "America/Juneau",
       "America/Metlakatla", "America/Dawson", "America/Whitehorse",
       "Indian/Cocos", "Asia/Manila", "America/Puerto_Rico", "Europe/Jersey",
       "Africa/Kinshasa", "Africa/Lubumbashi", "Pacific/Honolulu",
       "Asia/Taipei", "Australia/Perth", "Australia/Eucla", "Europe/Athens",
       "Australia/Currie", "Australia/Hobart", "Indian/Christmas",
       "Australia/Darwin", "Australia/Adelaide", "Australia/Broken_Hill",
       "Australia/Melbourne", "Australia/Sydney", "Australia/Lord_Howe",
       "America/Rainy_River", "America/Atikokan", "America/Thunder_Bay",
       "America/Nipigon", "America/Toronto", "Europe/Oslo",
       "Australia/Lindeman", "Australia/Brisbane", "America/Rosario",
       "America/Argentina/Rio_Gallegos", "America/Argentina/Mendoza",
       "America/Argentina/San_Juan", "America/Argentina/Ushuaia",
       "America/Argentina/ComodRivadavia", "America/Argentina/La_Rioja",
       "America/Argentina/San_Luis", "America/Argentina/Catamarca",
       "America/Argentina/Salta", "America/Argentina/Jujuy",
       "America/Argentina/Tucuman", "America/Argentina/Cordoba",
       "America/Argentina/Buenos_Aires", "Europe/Vaduz", "Europe/Malta",
       "Africa/Mogadishu", "Europe/Berlin", "Europe/Vienna",
       "Europe/Kaliningrad", "Africa/Lome", "Africa/Windhoek",
       "Africa/Johannesburg", "Europe/Bucharest", "Europe/Paris",
       "Africa/Algiers", "Europe/Monaco", "Europe/Budapest",
       "Europe/Uzhgorod", "Pacific/Easter", "America/Managua",
       "America/Costa_Rica", "America/Havana", "America/Cayman",
       "America/Guayaquil", "America/Panama", "America/Jamaica",
       "America/Port-au-Prince", "America/Grand_Turk",
       "America/Punta_Arenas", "America/Santiago", "America/Santo_Domingo",
       "America/La_Paz", "America/Caracas", "America/St_Vincent",
       "America/Martinique", "America/St_Lucia", "Atlantic/Stanley",
       "America/Asuncion", "Atlantic/South_Georgia", "Atlantic/St_Helena",
       "Europe/Copenhagen", "Africa/Bujumbura", "Asia/Baghdad", "Asia/Kabul",
       "Asia/Dhaka", "Asia/Tokyo", "America/Winnipeg", "America/Menominee",
       "Africa/Gaborone", "America/Bogota", "America/Vancouver",
       "America/Fort_Nelson", "America/Dawson_Creek", "America/Creston",
       "America/Coral_Harbour", "America/Montreal", "America/Goose_Bay",
       "America/Blanc-Sablon", "America/St_Johns", "Atlantic/Azores",
       "Atlantic/Madeira", "Europe/Ljubljana", "Europe/Zagreb",
       "Europe/Sarajevo", "Europe/Belgrade", "Europe/Skopje",
       "America/Moncton", "America/Boise", "America/Los_Angeles",
       "America/Denver", "America/North_Dakota/Beulah",
       "America/North_Dakota/Center", "America/North_Dakota/New_Salem",
       "America/Phoenix", "America/Chicago", "America/Indiana/Indianapolis",
       "America/Indiana/Knox", "America/Indiana/Marengo",
       "America/Indiana/Petersburg", "America/Indiana/Tell_City",
       "America/Indiana/Vevay", "America/Indiana/Vincennes",
       "America/Indiana/Winamac", "America/Kentucky/Louisville",
       "America/Kentucky/Monticello", "America/New_York",
       "Europe/Isle_of_Man", "Africa/Freetown", "Africa/Monrovia",
       "Africa/Tunis", "Europe/Dublin", "Europe/Belfast", "Europe/Gibraltar",
       "Europe/Brussels", "Europe/Warsaw", "Europe/Sofia", "Europe/Riga",
       "Europe/Tallinn", "Europe/Vilnius", "Europe/Minsk", "Europe/Chisinau",
       "Europe/Istanbul", "Europe/Tiraspol", "Europe/Kiev",
       "Europe/Simferopol", "Asia/Tel_Aviv", "Europe/Zaporozhye",
       "Asia/Jerusalem", "Asia/Beirut", "Europe/Moscow", "Asia/Tbilisi",
       "Indian/Maldives", "Asia/Colombo", "Asia/Yangon", "Asia/Bangkok",
       "Asia/Irkutsk", "Pacific/Port_Moresby", "Pacific/Bougainville",
       "Europe/Stockholm", "Europe/Helsinki", "Africa/Addis_Ababa",
       "Africa/Asmara", "Pacific/Auckland", "Pacific/Chatham",
       "Asia/Jakarta", "Europe/Rome", "Asia/Kolkata", "Europe/Zurich",
       "Europe/Prague", "Europe/London", "Europe/Amsterdam"}),
   "LST": ({"Europe/Riga"}),
   "MDDT": ({"America/Cambridge_Bay", "America/Inuvik",
       "America/Yellowknife"}),
   "MDST": ({"Europe/Moscow"}),
   "MDT": ({"America/Boise", "America/Cambridge_Bay", "America/Chihuahua",
       "America/Denver", "America/Edmonton", "America/Inuvik",
       "America/Mazatlan", "America/Ojinaga", "America/Yellowknife",
       "MST7MDT", "America/Bahia_Banderas", "America/Hermosillo",
       "America/North_Dakota/Beulah", "America/North_Dakota/Center",
       "America/North_Dakota/New_Salem", "America/Phoenix", "America/Regina",
       "America/Swift_Current"}),
   "MEST": ({"MET"}),
   "MET": ({"MET"}),
   "MMT": ({"Africa/Monrovia", "Europe/Moscow", "Indian/Maldives",
       "America/Managua", "Asia/Makassar", "Europe/Minsk",
       "America/Montevideo", "Asia/Colombo", "Asia/Kolkata"}),
   "MPT": ({"America/Boise", "America/Cambridge_Bay", "America/Denver",
       "America/Edmonton", "America/Inuvik", "America/Ojinaga",
       "America/Yellowknife", "MST7MDT", "America/North_Dakota/Beulah",
       "America/North_Dakota/Center", "America/North_Dakota/New_Salem",
       "America/Phoenix", "America/Regina", "America/Swift_Current"}),
   "MSD": ({"Europe/Tiraspol", "Europe/Moscow", "Europe/Simferopol",
       "Europe/Kaliningrad", "Europe/Tallinn", "Europe/Vilnius",
       "Europe/Chisinau", "Europe/Kiev", "Europe/Minsk", "Europe/Riga",
       "Europe/Uzhgorod", "Europe/Zaporozhye"}),
   "MSK": ({"Europe/Moscow", "Europe/Simferopol", "Europe/Tiraspol",
       "Europe/Minsk", "Europe/Uzhgorod", "Europe/Kaliningrad",
       "Europe/Tallinn", "Europe/Vilnius", "Europe/Chisinau", "Europe/Kiev",
       "Europe/Riga", "Europe/Zaporozhye"}),
   "MST": ({"America/Boise", "America/Cambridge_Bay", "America/Chihuahua",
       "America/Creston", "America/Dawson_Creek", "America/Denver",
       "America/Edmonton", "America/Fort_Nelson", "America/Hermosillo",
       "America/Inuvik", "America/Mazatlan", "America/Ojinaga",
       "America/Phoenix", "America/Yellowknife", "MST", "MST7MDT",
       "America/Bahia_Banderas", "America/North_Dakota/Beulah",
       "America/North_Dakota/Center", "America/North_Dakota/New_Salem",
       "America/Regina", "America/Swift_Current", "Europe/Moscow",
       "America/Ensenada", "America/Mexico_City", "America/Tijuana"}),
   "MWT": ({"America/Boise", "America/Cambridge_Bay", "America/Chihuahua",
       "America/Denver", "America/Edmonton", "America/Inuvik",
       "America/Mazatlan", "America/Ojinaga", "America/Yellowknife",
       "MST7MDT", "America/Bahia_Banderas", "America/Hermosillo",
       "America/North_Dakota/Beulah", "America/North_Dakota/Center",
       "America/North_Dakota/New_Salem", "America/Phoenix", "America/Regina",
       "America/Swift_Current"}),
   "NDDT": ({"America/Goose_Bay", "America/St_Johns"}),
   "NDT": ({"America/St_Johns", "America/Adak", "America/Goose_Bay",
       "America/Nome"}),
   "NFT": ({"Europe/Oslo", "Europe/Paris"}),
   "NPT": ({"America/St_Johns", "America/Adak", "America/Goose_Bay",
       "America/Nome"}),
   "NST": ({"America/St_Johns", "America/Adak", "America/Goose_Bay",
       "America/Nome", "Europe/Amsterdam"}),
   "NWT": ({"America/St_Johns", "America/Adak", "America/Goose_Bay",
       "America/Nome"}),
   "NZDT": ({"Antarctica/McMurdo", "Pacific/Auckland"}),
   "NZMT": ({"Antarctica/McMurdo", "Pacific/Auckland"}),
   "NZST": ({"Antarctica/McMurdo", "Pacific/Auckland"}),
   "P%sT": ({"America/Ensenada"}),
   "PDDT": ({"America/Dawson", "America/Inuvik", "America/Whitehorse"}),
   "PDT": ({"America/Dawson", "America/Los_Angeles", "America/Tijuana",
       "America/Vancouver", "America/Whitehorse", "PST8PDT", "America/Boise",
       "America/Dawson_Creek", "America/Fort_Nelson", "America/Inuvik",
       "America/Juneau", "America/Metlakatla", "America/Sitka"}),
   "PKST": ({"Asia/Karachi"}),
   "PKT": ({"Asia/Karachi"}),
   "PLMT": ({"Asia/Hanoi", "Asia/Ho_Chi_Minh", "Asia/Phnom_Penh",
       "Asia/Vientiane"}),
   "PMMT": ({"Pacific/Bougainville", "Pacific/Port_Moresby"}),
   "PMT": ({"America/Paramaribo", "Asia/Pontianak", "Asia/Yekaterinburg",
       "Europe/Paris", "Africa/Algiers", "Africa/Tunis", "Europe/Monaco",
       "Europe/Prague"}),
   "PPMT": ({"America/Port-au-Prince"}),
   "PPT": ({"America/Dawson", "America/Los_Angeles", "America/Tijuana",
       "America/Vancouver", "America/Whitehorse", "PST8PDT", "America/Boise",
       "America/Dawson_Creek", "America/Fort_Nelson", "America/Inuvik",
       "America/Juneau", "America/Metlakatla", "America/Sitka"}),
   "PST": ({"America/Dawson", "America/Los_Angeles", "America/Tijuana",
       "America/Vancouver", "America/Whitehorse", "PST8PDT",
       "America/Metlakatla", "America/Ensenada", "America/Bahia_Banderas",
       "America/Hermosillo", "America/Mazatlan", "America/Boise",
       "America/Dawson_Creek", "America/Fort_Nelson", "America/Inuvik",
       "America/Juneau", "America/Sitka", "America/Creston"}),
   "PWT": ({"America/Dawson", "America/Los_Angeles", "America/Tijuana",
       "America/Vancouver", "America/Whitehorse", "PST8PDT", "America/Boise",
       "America/Dawson_Creek", "America/Fort_Nelson", "America/Inuvik",
       "America/Juneau", "America/Metlakatla", "America/Sitka"}),
   "QMT": ({"America/Guayaquil"}),
   "RMT": ({"Europe/Riga", "Asia/Yangon", "Europe/Rome"}),
   "S": ({"Europe/Amsterdam", "Europe/Moscow"}),
   "SAST": ({"Africa/Johannesburg", "Africa/Maseru", "Africa/Mbabane",
       "Africa/Windhoek", "Africa/Gaborone"}),
   "SDMT": ({"America/Santo_Domingo"}),
   "SET": ({"Europe/Stockholm"}),
   "SJMT": ({"America/Costa_Rica"}),
   "SMT": ({"America/Punta_Arenas", "America/Santiago", "Europe/Simferopol",
       "Atlantic/Stanley", "Asia/Kuala_Lumpur", "Asia/Singapore"}),
   "SST": ({"Pacific/Pago_Pago"}),
   "TBMT": ({"Asia/Tbilisi"}),
   "TMT": ({"Asia/Tehran", "Europe/Tallinn"}),
   "UCT": ({"Etc/UCT"}),
   "UTC": ({"Etc/UTC"}),
   "WAST": ({"Africa/Ndjamena"}),
   "WAT": ({"Africa/Bangui", "Africa/Brazzaville", "Africa/Douala",
       "Africa/Kinshasa", "Africa/Lagos", "Africa/Libreville",
       "Africa/Luanda", "Africa/Malabo", "Africa/Ndjamena", "Africa/Niamey",
       "Africa/Porto-Novo", "Africa/Sao_Tome", "Africa/Windhoek"}),
   "WEMT": ({"Atlantic/Madeira", "Europe/Lisbon", "Africa/Ceuta",
       "Europe/Madrid", "Europe/Monaco", "Europe/Paris"}),
   "WEST": ({"Africa/Casablanca", "Africa/El_Aaiun", "Atlantic/Canary",
       "Atlantic/Faroe", "Atlantic/Madeira", "Europe/Lisbon", "WET",
       "Atlantic/Azores", "Africa/Algiers", "Africa/Ceuta",
       "Europe/Luxembourg", "Europe/Madrid", "Europe/Monaco", "Europe/Paris",
       "Europe/Brussels"}),
   "WET": ({"Africa/Casablanca", "Africa/El_Aaiun", "Atlantic/Canary",
       "Atlantic/Faroe", "Atlantic/Madeira", "Europe/Lisbon", "WET",
       "Atlantic/Azores", "Africa/Algiers", "Africa/Ceuta",
       "Europe/Luxembourg", "Europe/Madrid", "Europe/Monaco", "Europe/Paris",
       "Europe/Andorra", "Europe/Brussels"}),
   "WIB": ({"Asia/Jakarta", "Asia/Pontianak"}),
   "WIT": ({"Asia/Jayapura"}),
   "WITA": ({"Asia/Makassar", "Asia/Pontianak"}),
   "WMT": ({"Europe/Vilnius", "Europe/Warsaw"}),
   "YDDT": ({"America/Dawson", "America/Whitehorse"}),
   "YDT": ({"America/Anchorage", "America/Dawson", "America/Juneau",
       "America/Nome", "America/Sitka", "America/Whitehorse",
       "America/Yakutat"}),
   "YPT": ({"America/Anchorage", "America/Dawson", "America/Juneau",
       "America/Nome", "America/Sitka", "America/Whitehorse",
       "America/Yakutat"}),
   "YST": ({"America/Anchorage", "America/Dawson", "America/Juneau",
       "America/Nome", "America/Sitka", "America/Whitehorse",
       "America/Yakutat"}),
   "YWT": ({"America/Anchorage", "America/Dawson", "America/Juneau",
       "America/Nome", "America/Sitka", "America/Whitehorse",
       "America/Yakutat"}),
]);

// this is used by the timezone expert system,
// that uses localtime (or whatever) to figure out the *correct* timezone

// note that at least Red Hat 6.2 has an error in the time database,
// so a lot of Europeean (Paris, Brussels) times get to be Luxembourg /Mirar

mapping timezone_expert_tree=
([ "test":57801600, // 1971-11-01 00:00:00
   -36000:
   ([ "test":688490994, // 1991-10-26 15:29:54
      -32400:"Asia/Vladivostok",
      -36000:
      ([ "test":-441849600, // 1956-01-01 00:00:00
	 -32400:
	 ({
	    "Pacific/Saipan",
	    "Pacific/Yap",
	 }),
	 0:"Antarctica/DumontDUrville",
	 -36000:
	 ({
	    "Pacific/Guam",
	    "Pacific/Truk",
	    "Pacific/Port_Moresby",
	 }),]),
      -37800:"Australia/Lord_Howe",]),
   3600:
   ([ "test":157770005, // 1975-01-01 01:00:05
      3600:"Africa/El_Aaiun",
      0:"Africa/Bissau",]),
   36000:
   ([ "test":9979204, // 1970-04-26 12:00:04
      36000:
      ([ "test":-725846400, // 1947-01-01 00:00:00
	 37800:"Pacific/Honolulu",
	 36000:
	 ([ "test":-1830384000, // 1912-01-01 00:00:00
	    36000:"Pacific/Fakaofo",
	    35896:"Pacific/Tahiti",]),]),
      32400:"America/Anchorage",]),
   -19800:
   ([ "test":832962604, // 1996-05-24 18:30:04
      -23400:"Asia/Colombo",
      -20700:"Asia/Katmandu",
      -19800:"Asia/Calcutta",
      -21600:"Asia/Thimbu",]),
   43200:
   ([ "test":307627204, // 1979-10-01 12:00:04
      43200:"Pacific/Kwajalein",
      39600:"Pacific/Enderbury",]),
   10800:
   ([ "test":323845205, // 1980-04-06 05:00:05
      10800:
      ([ "test":511149594, // 1986-03-14 01:59:54
	 14400:"Antarctica/Palmer",
	 10800:
	 ([ "test":-189388800, // 1964-01-01 00:00:00
	    14400:"America/Cayenne",
	    10800:
	    ([ "test":-1767225600, // 1914-01-01 00:00:00
	       8572:"America/Maceio",
	       11568:"America/Araguaina",
	       9240:"America/Fortaleza",
	       11636:"America/Belem",]),
	    7200:"America/Sao_Paulo",]),
	 7200:
	 ([ "test":678319194, // 1991-06-30 21:59:54
	    14400:
	    ([ "test":686721605, // 1991-10-06 04:00:05
	       14400:"America/Mendoza",
	       10800:"America/Jujuy",]),
	    10800:
	    ([ "test":678337204, // 1991-07-01 03:00:04
	       7200:"America/Catamarca",
	       10800:"America/Cordoba",]),
	    7200:
	    ([ "test":938901595, // 1999-10-02 21:59:55
	       10800:"America/Rosario",
	       7200:"America/Buenos_Aires",]),]),]),
      14400:"America/Santiago",
      7200:"America/Godthab",]),
   -12600:"Asia/Tehran",
   2670:"Africa/Monrovia",
   -28800:
   ([ "test":690314404, // 1991-11-16 18:00:04
      -25200:"Asia/Irkutsk",
      -28800:
      ([ "test":515520004, // 1986-05-03 16:00:04
	 -28800:
	 ([ "test":9315004, // 1970-04-18 19:30:04
	    -28800:
	    ([ "test":133977605, // 1974-03-31 16:00:05
	       -28800:
	       ([ "test":259344004, // 1978-03-21 16:00:04
		  -32400:"Asia/Manila",
		  -28800:
		  ([ "test":-788918400, // 1945-01-01 00:00:00
		     -28800:"Asia/Brunei",
		     -32400:
		     ([ "test":-770601600, // 1945-08-01 00:00:00
			-32400:"Asia/Kuching",
			-28800:"Asia/Ujung_Pandang",]),
		     0:"Antarctica/Casey",]),]),
	       -32400:"Asia/Taipei",]),
	    -32400:
	    ([ "test":72214195, // 1972-04-15 19:29:55
	       -32400:"Asia/Macao",
	       -28800:"Asia/Hong_Kong",]),]),
	 -32400:"Asia/Shanghai",]),
      -32400:"Australia/Perth",]),
   -45000:"Pacific/Auckland",
   34200:"Pacific/Marquesas",
   -21600:
   ([ "test":515520004, // 1986-05-03 16:00:04
      -25200:
      ([ "test":717526795, // 1992-09-26 16:59:55
	 -25200:"Asia/Almaty",
	 -21600:
	 ([ "test":683582405, // 1991-08-30 20:00:05
	    -21600:"Asia/Tashkent",
	    -18000:"Asia/Bishkek",]),
	 -18000:"Asia/Dushanbe",]),
      -28800:"Asia/Hovd",
      -32400:"Asia/Urumqi",
      -21600:
      ([ "test":670363205, // 1991-03-30 20:00:05
	 -18000:"Asia/Omsk",
	 -21600:
	 ([ "test":-504921600, // 1954-01-01 00:00:00
	    -21600:"Asia/Dacca",
	    0:"Antarctica/Mawson",]),]),]),
   41400:"Pacific/Niue",
   -14400:
   ([ "test":606866404, // 1989-03-25 22:00:04
      -10800:
      ([ "test":606866394, // 1989-03-25 21:59:54
	 -10800:
	 ([ "test":-1609459200, // 1919-01-01 00:00:00
	    -12368:"Asia/Qatar",
	    -12140:"Asia/Bahrain",]),
	 -14400:"Europe/Samara",]),
      -14400:
      ([ "test":-2019686400, // 1906-01-01 00:00:00
	 -14060:"Asia/Muscat",
	 -13800:"Indian/Mauritius",
	 -13272:"Asia/Dubai",
	 -13308:"Indian/Mahe",
	 -13312:"Indian/Reunion",]),
      -18000:
      ([ "test":796172395, // 1995-03-25 22:59:55
	 -10800:"Asia/Yerevan",
	 -14400:"Asia/Baku",
	 -18000:"Asia/Tbilisi",]),]),
   18000:
   ([ "test":104914805, // 1973-04-29 07:00:05
      14400:
      ([ "test":9961194, // 1970-04-26 06:59:54
	 14400:"America/Havana",
	 18000:
	 ([ "test":9961204, // 1970-04-26 07:00:04
	    14400:
	    ([ "test":126687605, // 1974-01-06 07:00:05
	       18000:
	       ([ "test":162370804, // 1975-02-23 07:00:04
		  18000:
		  ([ "test":-210556800, // 1963-05-01 00:00:00
		     18000:"America/Nassau",
		     14400:"America/Montreal",]),
		  14400:
		  ([ "test":199263605, // 1976-04-25 07:00:05
		     14400:"America/Louisville",
		     18000:"America/Indiana/Marengo",]),]),
	       14400:"America/New_York",]),
	    18000:"America/Detroit",]),]),
      18000:
      ([ "test":514969195, // 1986-04-27 06:59:55
	 14400:
	 ([ "test":421217995, // 1983-05-08 04:59:55
	    14400:"America/Grand_Turk",
	    18000:"America/Port-au-Prince",]),
	 21600:"Pacific/Galapagos",
	 18000:
	 ([ "test":954658805, // 2000-04-02 07:00:05
	    14400:
	    ([ "test":9961204, // 1970-04-26 07:00:04
	       18000:"America/Nipigon",
	       14400:"America/Thunder_Bay",]),
	    18000:
	    ([ "test":9961204, // 1970-04-26 07:00:04
	       18000:
	       ([ "test":136364405, // 1974-04-28 07:00:05
		  18000:
		  ([ "test":704782804, // 1992-05-02 05:00:04
		     18000:
		     ([ "test":536475605, // 1987-01-01 05:00:05
			14400:"America/Lima",
			18000:
			([ "test":-1830384000, // 1912-01-01 00:00:00
			   18432:"America/Cayman",
			   18840:"America/Guayaquil",
			   16272:"America/Porto_Acre",
			   18000:"America/Panama",]),]),
		     14400:"America/Bogota",]),
		  14400:"America/Jamaica",]),
	       14400:
	       ([ "test":41410805, // 1971-04-25 07:00:05
		  14400:"America/Indiana/Vevay",
		  18000:"America/Indianapolis",]),]),
	    21600:"America/Iqaluit",]),]),
      21600:"America/Menominee",]),
   -7200:
   ([ "test":291761995, // 1979-03-31 20:59:55
      -7200:
      ([ "test":323816404, // 1980-04-05 21:00:04
	 -7200:
	 ([ "test":386125194, // 1982-03-28 00:59:54
	    -7200:
	    ([ "test":767746795, // 1994-04-30 22:59:55
	       -7200:
	       ([ "test":10364394, // 1970-04-30 22:59:54
		  -7200:
		  ([ "test":10364404, // 1970-04-30 23:00:04
		     -7200:
		     ([ "test":142379994, // 1974-07-06 21:59:54
			-10800:"Asia/Damascus",
			-7200:
			([ "test":142380004, // 1974-07-06 22:00:04
			   -10800:
			   ([ "test":828655204, // 1996-04-04 22:00:04
			      -10800:"Asia/Gaza",
			      -7200:"Asia/Jerusalem",]),
			   -7200:
			   ([ "test":-820540800, // 1944-01-01 00:00:00
			      -7200:
			      ([ "test":-2114380800, // 1903-01-01 00:00:00
				 -7216:"Africa/Kigali",
				 -7200:
				 ({
				    "Africa/Bujumbura",
				    "Africa/Lubumbashi",
				 }),
				 -7452:"Africa/Harare",
				 -6788:"Africa/Lusaka",
				 -7464:"Africa/Mbabane",
				 -7820:"Africa/Maputo",
				 -8400:"Africa/Blantyre",]),
			      -10800:
			      ([ "test":-852076800, // 1943-01-01 00:00:00
				 -10800:"Africa/Johannesburg",
				 -7200:
				 ([ "test":-2114380800, // 1903-01-01 00:00:00
				    -6600:"Africa/Maseru",
				    -7200:"Africa/Gaborone",]),]),
			      -3600:"Europe/Athens",]),]),]),
		     -10800:"Africa/Cairo",]),
		  -10800:"Africa/Khartoum",]),
	       -10800:
	       ([ "test":354686404, // 1981-03-29 04:00:04
		  -7200:
		  ([ "test":108165594, // 1973-06-05 21:59:54
		     -10800:"Asia/Beirut",
		     -7200:"Asia/Amman",]),
		  -10800:"Europe/Helsinki",]),
	       -3600:"Africa/Windhoek",]),
	    -10800:"Asia/Nicosia",
	    -3600:"Africa/Tripoli",]),
	 -10800:
	 ([ "test":291762005, // 1979-03-31 21:00:05
	    -7200:"Europe/Bucharest",
	    -10800:"Europe/Sofia",]),
	 -3600:"Europe/Berlin",]),
      -10800:"Europe/Istanbul",
      -3600:
      ([ "test":-810086400, // 1944-05-01 00:00:00
	 -3600:"Europe/Monaco",
	 -7200:"Europe/Paris",]),]),
   -37800:
   ([ "test":384280204, // 1982-03-06 16:30:04
      -37800:"Australia/Broken_Hill",
      -34200:"Australia/Adelaide",]),
   25200:
   ([ "test":954665994, // 2000-04-02 08:59:54
      25200:
      ([ "test":9968404, // 1970-04-26 09:00:04
	 25200:
	 ([ "test":73472404, // 1972-04-30 09:00:04
	    25200:
	    ([ "test":325674005, // 1980-04-27 09:00:05
	       25200:
	       ([ "test":28795, // 1970-01-01 07:59:55
		  28800:
		  ([ "test":923216404, // 1999-04-04 09:00:04
		     21600:"America/Mazatlan",
		     25200:"America/Hermosillo",]),
		  25200:"America/Phoenix",]),
	       21600:"America/Yellowknife",]),
	    21600:"America/Edmonton",]),
	 21600:
	 ([ "test":126694804, // 1974-01-06 09:00:04
	    25200:"America/Boise",
	    21600:"America/Denver",]),]),
      18000:"America/Cambridge_Bay",
      21600:"America/Swift_Current",]),
   -30600:"Asia/Harbin",
   9000:"America/Montevideo",
   32400:
   ([ "test":325681205, // 1980-04-27 11:00:05
      32400:"Pacific/Gambier",
      25200:"America/Dawson",
      28800:"America/Yakutat",]),
   -46800:
   ([ "test":938782794, // 1999-10-01 12:59:54
      -43200:"Asia/Anadyr",
      -46800:"Pacific/Tongatapu",]),
   -23400:"Asia/Rangoon",
   39600:
   ([ "test":436291204, // 1983-10-29 16:00:04
      32400:"America/Adak",
      28800:"America/Nome",
      39600:
      ([ "test":-631152000, // 1950-01-01 00:00:00
	 39600:"Pacific/Midway",
	 41400:
	 ([ "test":-1861920000, // 1911-01-01 00:00:00
	    41216:"Pacific/Apia",
	    40968:"Pacific/Pago_Pago",]),]),]),
   16200:"America/Santo_Domingo",
   -39600:
   ([ "test":625593594, // 1989-10-28 15:59:54
      -43200:"Pacific/Efate",
      -39600:
      ([ "test":849366004, // 1996-11-30 15:00:04
	 -39600:
	 ([ "test":670345204, // 1991-03-30 15:00:04
	    -36000:"Asia/Magadan",
	    -39600:
	    ([ "test":-1830384000, // 1912-01-01 00:00:00
	       -38388:"Pacific/Guadalcanal",
	       -39600:"Pacific/Ponape",]),]),
	 -43200:"Pacific/Noumea",]),
      -36000:
      ([ "test":636480005, // 1990-03-03 16:00:05
	 -36000:
	 ([ "test":719942404, // 1992-10-24 16:00:04
	    -39600:
	    ([ "test":89136004, // 1972-10-28 16:00:04
	       -39600:"Australia/Sydney",
	       -36000:"Australia/Lindeman",]),
	    -36000:"Australia/Brisbane",]),
	 -39600:
	 ([ "test":5673595, // 1970-03-07 15:59:55
	    -36000:"Australia/Melbourne",
	    -39600:"Australia/Hobart",]),]),]),
   -16200:"Asia/Kabul",
   0:
   ([ "test":512528405, // 1986-03-30 01:00:05
      -7200:"Africa/Ceuta",
      0:
      ([ "test":57722395, // 1971-10-31 01:59:55
	 0:
	 ([ "test":141264004, // 1974-06-24 00:00:04
	    0:
	    ([ "test":-862617600, // 1942-09-01 00:00:00
	       0:
	       ([ "test":-63158400, // 1968-01-01 00:00:00
		  0:
		  ([ "test":-915148800, // 1941-01-01 00:00:00
		     0:
		     ([ "test":-1830384000, // 1912-01-01 00:00:00
			968:"Africa/Abidjan",
			364:"Africa/Ouagadougou",
			0:"UTC", // "Africa/Lome",
			724:"Africa/Timbuktu",
			2192:"Africa/Sao_Tome",]),
		     3600:"Africa/Dakar",]),
		  3600:"Atlantic/Reykjavik",]),
	       1200:"Africa/Freetown",
	       3600:
	       ([ "test":-189388800, // 1964-01-01 00:00:00
		  0:
		  ([ "test":-312940800, // 1960-02-01 00:00:00
		     3600:
		     ([ "test":-299894400, // 1960-07-01 00:00:00
			3600:"Africa/Nouakchott",
			0:"Africa/Bamako",]),
		     0:"Africa/Conakry",]),
		  3600:"Africa/Banjul",]),
	       1368:"Atlantic/St_Helena",
	       -1200:"Africa/Accra",]),
	    -3600:"Africa/Casablanca",]),
	 -3600:
	 ([ "test":-718070400, // 1947-04-01 00:00:00
	    -3600:"Europe/Dublin",
	    0:
	    ([ "test":-1704153600, // 1916-01-01 00:00:00
	       1521:"Europe/Belfast",
	       0:"Europe/London",]),]),]),
      3600:"Atlantic/Azores",
      -3600:
      ([ "test":354675605, // 1981-03-29 01:00:05
	 0:"Africa/Algiers",
	 -3600:
	 ([ "test":323827205, // 1980-04-06 00:00:05
	    -3600:"Atlantic/Canary",
	    0:"Atlantic/Faeroe",]),]),]),
   -32400:
   ([ "test":547570804, // 1987-05-09 15:00:04
      -28800:"Asia/Dili",
      -32400:
      ([ "test":670352405, // 1991-03-30 17:00:05
	 -28800:"Asia/Yakutsk",
	 -32400:
	 ([ "test":-283996800, // 1961-01-01 00:00:00
	    -28800:"Asia/Pyongyang",
	    -32400:
	    ({
	       "Pacific/Palau",
	       "Asia/Tokyo",
	    }),
	    -34200:"Asia/Jayapura",]),]),
      -36000:"Asia/Seoul",]),
   30600:"Pacific/Pitcairn",
   -25200:
   ([ "test":671558395, // 1991-04-13 15:59:55
      -25200:
      ([ "test":-410227200, // 1957-01-01 00:00:00
	 -25200:
	 ([ "test":-2019686400, // 1906-01-01 00:00:00
	    -24624:"Asia/Vientiane",
	    -25180:"Asia/Phnom_Penh",
	    -25200:"Indian/Christmas",
	    -24124:"Asia/Bangkok",
	    -25600:"Asia/Saigon",]),
	 -27000:"Asia/Jakarta",
	 0:"Antarctica/Davis",]),
      -28800:"Asia/Chungking",
      -32400:"Asia/Ulaanbaatar",
      -21600:
      ([ "test":738140405, // 1993-05-23 07:00:05
	 -25200:"Asia/Krasnoyarsk",
	 -21600:"Asia/Novosibirsk",]),]),
   38400:"Pacific/Kiritimati",
   7200:
   ([ "test":354675604, // 1981-03-29 01:00:04
      7200:
      ([ "test":-1167609600, // 1933-01-01 00:00:00
	 7200:"Atlantic/South_Georgia",
	 3600:"America/Noronha",]),
      3600:"Atlantic/Cape_Verde",
      0:"America/Scoresbysund",]),
   37800:"Pacific/Rarotonga",
   -18000:
   ([ "test":670366805, // 1991-03-30 21:00:05
      -25200:"Asia/Samarkand",
      -28800:"Asia/Kashgar",
      -14400:"Asia/Yekaterinburg",
      -21600:"Asia/Ashkhabad",
      -18000:
      ([ "test":828212405, // 1996-03-30 19:00:05
	 -14400:"Asia/Aqtau",
	 -18000:
	 ([ "test":-599616000, // 1951-01-01 00:00:00
	    -17640:"Indian/Maldives",
	    -19800:"Asia/Karachi",
	    -18000:"Indian/Kerguelen",]),
	 -21600:"Asia/Aqtobe",]),]),
   14400:
   ([ "test":796802394, // 1995-04-02 05:59:54
      10800:"Atlantic/Stanley",
      14400:
      ([ "test":733903204, // 1993-04-04 06:00:04
	 10800:
	 ([ "test":9957604, // 1970-04-26 06:00:04
	    14400:
	    ([ "test":73461604, // 1972-04-30 06:00:04
	       14400:
	       ([ "test":136360805, // 1974-04-28 06:00:05
		  10800:"Atlantic/Bermuda",
		  14400:"America/Thule",]),
	       10800:"America/Glace_Bay",]),
	    10800:"America/Halifax",]),
	 14400:
	 ([ "test":234943204, // 1977-06-12 06:00:04
	    14400:
	    ([ "test":323841605, // 1980-04-06 04:00:05
	       14400:
	       ([ "test":86760004, // 1972-10-01 04:00:04
		  14400:
		  ([ "test":-788918400, // 1945-01-01 00:00:00
		     14400:
		     ([ "test":-1861920000, // 1911-01-01 00:00:00
			14404:"America/Manaus",
			15584:"America/St_Thomas",
			14764:"America/Port_of_Spain",
			15336:"America/Porto_Velho",
			15052:"America/St_Kitts",
			15136:"America/Anguilla",
			15508:"America/Tortola",
			14640:"America/St_Lucia",
			14820:"America/Grenada",
			14736:"America/Dominica",
			13460:"America/Cuiaba",
			16356:"America/La_Paz",
			14560:"America/Boa_Vista",
			14932:"America/Montserrat",
			14696:"America/St_Vincent",
			14768:"America/Guadeloupe",]),
		     10800:"America/Puerto_Rico",
		     12600:"America/Goose_Bay",
		     16200:
		     ([ "test":-1830384000, // 1912-01-01 00:00:00
			16064:"America/Caracas",
			16544:"America/Curacao",
			16824:"America/Aruba",]),
		     18000:"America/Antigua",]),
		  10800:"America/Asuncion",]),
	       10800:"America/Martinique",]),
	    10800:"America/Barbados",]),]),
      7200:"America/Miquelon",
      18000:"America/Pangnirtung",]),
   21600:
   ([ "test":891763194, // 1998-04-05 07:59:54
      14400:"America/Cancun",
      25200:"America/Chihuahua",
      21600:
      ([ "test":9964805, // 1970-04-26 08:00:05
	 25200:"Pacific/Easter",
	 21600:
	 ([ "test":136368004, // 1974-04-28 08:00:04
	    21600:
	    ([ "test":325670404, // 1980-04-27 08:00:04
	       21600:
	       ([ "test":828864004, // 1996-04-07 08:00:04
		  21600:
		  ([ "test":123919195, // 1973-12-05 05:59:55
		     21600:
		     ([ "test":123919205, // 1973-12-05 06:00:05
			21600:
			([ "test":547020004, // 1987-05-03 06:00:04
			   18000:
			   ([ "test":-1546300800, // 1921-01-01 00:00:00
			      20932:"America/Tegucigalpa",
			      21408:"America/El_Salvador",]),
			   21600:"America/Regina",]),
			18000:"America/Belize",]),
		     18000:"America/Guatemala",]),
		  18000:"America/Mexico_City",]),
	       18000:"America/Rankin_Inlet",]),
	    18000:"America/Rainy_River",]),
	 18000:
	 ([ "test":126691205, // 1974-01-06 08:00:05
	    21600:"America/Winnipeg",
	    18000:"America/Chicago",]),]),
      18000:
      ([ "test":9964805, // 1970-04-26 08:00:05
	 21600:
	 ([ "test":288770405, // 1979-02-25 06:00:05
	    21600:"America/Managua",
	    18000:"America/Costa_Rica",]),
	 18000:"America/Indiana/Knox",]),]),
   -41400:
   ([ "test":294323404, // 1979-04-30 12:30:04
      -41400:"Pacific/Norfolk",
      -43200:"Pacific/Nauru",]),
   13500:"America/Guyana",
   -34200:"Australia/Darwin",
   28800:
   ([ "test":452080795, // 1984-04-29 09:59:55
      32400:"America/Juneau",
      28800:
      ([ "test":9972004, // 1970-04-26 10:00:04
	 28800:
	 ([ "test":199274404, // 1976-04-25 10:00:04
	    25200:"America/Tijuana",
	    28800:"America/Whitehorse",]),
	 25200:
	 ([ "test":126698404, // 1974-01-06 10:00:04
	    28800:"America/Vancouver",
	    25200:"America/Los_Angeles",]),]),
      25200:"America/Dawson_Creek",
      21600:"America/Inuvik",]),
   -10800:
   ([ "test":646786804, // 1990-06-30 23:00:04
      -10800:
      ([ "test":909277204, // 1998-10-25 01:00:04
	 -10800:
	 ([ "test":670395594, // 1991-03-31 04:59:54
	    -10800:
	    ([ "test":670395604, // 1991-03-31 05:00:04
	       -10800:
	       ([ "test":-662688000, // 1949-01-01 00:00:00
		  -9000:"Africa/Mogadishu",
		  -11212:"Asia/Riyadh",
		  -10800:
		  ([ "test":-499824000, // 1954-03-01 00:00:00
		     -10800:
		     ([ "test":-1861920000, // 1911-01-01 00:00:00
			-10856:"Indian/Mayotte",
			-9320:
			({
			   "Africa/Asmera",
			   "Africa/Addis_Ababa",
			}),
			-10356:"Africa/Djibouti",
			-10384:"Indian/Comoro",]),
		     -14400:"Indian/Antananarivo",]),
		  -10848:"Asia/Aden",
		  -11516:"Asia/Kuwait",
		  0:"Antarctica/Syowa",
		  -9900:
		  ([ "test":-725846400, // 1947-01-01 00:00:00
		     -10800:"Africa/Dar_es_Salaam",
		     -9000:"Africa/Kampala",
		     -9900:"Africa/Nairobi",]),]),
	       -7200:"Europe/Tiraspol",]),
	    -7200:"Europe/Moscow",]),
	 -7200:
	 ([ "test":686102394, // 1991-09-28 23:59:54
	    -7200:
	    ([ "test":670374004, // 1991-03-30 23:00:04
	       -10800:"Europe/Zaporozhye",
	       -7200:"Europe/Kaliningrad",]),
	    -10800:
	    ([ "test":686102404, // 1991-09-29 00:00:04
	       -7200:
	       ([ "test":701820004, // 1992-03-28 22:00:04
		  -7200:"Europe/Riga",
		  -10800:"Europe/Minsk",]),
	       -10800:"Europe/Tallinn",]),]),
	 -3600:"Europe/Vilnius",]),
      -7200:
      ([ "test":796168805, // 1995-03-25 22:00:05
	 -7200:"Europe/Kiev",
	 -10800:"Europe/Chisinau",
	 -14400:"Europe/Simferopol",]),
      -14400:"Asia/Baghdad",
      -3600:"Europe/Uzhgorod",]),
   -27000:
   ({
      "Asia/Kuala_Lumpur",
      "Asia/Singapore",
   }),
   12600:
   ([ "test":465449405, // 1984-10-01 03:30:05
      10800:"America/Paramaribo",
      12600:"America/St_Johns",]),
   -43200:
   ([ "test":686671204, // 1991-10-05 14:00:04
      -43200:
      ([ "test":920123995, // 1999-02-27 13:59:55
	 -43200:
	 ([ "test":-31536000, // 1969-01-01 00:00:00
	    -43200:
	    ({
	       "Pacific/Tarawa",
	       "Pacific/Funafuti",
	       "Pacific/Wake",
	       "Pacific/Wallis",
	    }),
	    -39600:"Pacific/Majuro",]),
	 -46800:"Pacific/Fiji",
	 -39600:"Pacific/Kosrae",]),
      -46800:"Antarctica/McMurdo",
      -39600:"Asia/Kamchatka",
      39600:"Pacific/Auckland",]),
   -3600:
   ([ "test":433299604, // 1983-09-25 01:00:04
      -7200:"Europe/Tirane",
      0:
      ([ "test":717555604, // 1992-09-27 01:00:04
	 -3600:"Europe/Lisbon",
	 0:"Atlantic/Madeira",]),
      -3600:
      ([ "test":481078795, // 1985-03-31 00:59:55
	 -3600:
	 ([ "test":481078805, // 1985-03-31 01:00:05
	    -3600:
	    ([ "test":308703605, // 1979-10-13 23:00:05
	       -3600:
	       ([ "test":231202804, // 1977-04-29 23:00:04
		  -7200:"Africa/Tunis",
		  -3600:
		  ([ "test":-220924800, // 1963-01-01 00:00:00
		     -3600:
		     ([ "test":-347155200, // 1959-01-01 00:00:00
			-3600:
			([ "test":-1861920000, // 1911-01-01 00:00:00
			   -3668:"Africa/Brazzaville",
			   -2268:"Africa/Libreville",
			   -2328:"Africa/Douala",
			   -4460:"Africa/Bangui",
			   -3124:"Africa/Luanda",
			   -628:"Africa/Porto-Novo",
			   -816:"Africa/Lagos",
			   -3600:"Africa/Kinshasa",]),
			0:"Africa/Niamey",]),
		     0:"Africa/Malabo",]),]),
	       -7200:"Africa/Ndjamena",]),
	    -7200:
	    ([ "test":354675605, // 1981-03-29 01:00:05
	       -3600:
	       ([ "test":386125205, // 1982-03-28 01:00:05
		  -3600:
		  ([ "test":417574804, // 1983-03-27 01:00:04
		     -7200:"Europe/Belgrade",
		     -3600:"Europe/Andorra",]),
		  -7200:"Europe/Gibraltar",]),
	       -7200:
	       ([ "test":228877205, // 1977-04-03 01:00:05
		  -3600:
		  ([ "test":291776404, // 1979-04-01 01:00:04
		     -3600:
		     ([ "test":323830795, // 1980-04-06 00:59:55
			-3600:
			([ "test":323830805, // 1980-04-06 01:00:05
			   -3600:
			   ([ "test":-683856000, // 1948-05-01 00:00:00
			      -3600:
			      ([ "test":-917827200, // 1940-12-01 00:00:00
				 -7200:"Europe/Zurich",
				 -3600:"Europe/Vaduz",]),
			      -7200:"Europe/Vienna",]),
			   -7200:
			   ([ "test":12956404, // 1970-05-30 23:00:04
			      -3600:
			      ([ "test":-681177600, // 1948-06-01 00:00:00
				 -3600:
				 ([ "test":-788918400, // 1945-01-01 00:00:00
				    -3600:"Europe/Stockholm",
				    -7200:"Europe/Oslo",]),
				 -7200:"Europe/Copenhagen",]),
			      -7200:"Europe/Rome",]),]),
			-7200:
			([ "test":323827195, // 1980-04-05 23:59:55
			   -7200:"Europe/Malta",
			   -3600:"Europe/Budapest",]),]),
		     -7200:
		     ([ "test":-652320000, // 1949-05-01 00:00:00
			-3600:"Europe/Madrid",
			-7200:"Europe/Prague",]),]),
		  -7200:
		  ([ "test":-788918400, // 1945-01-01 00:00:00
		     -7200:"Europe/Amsterdam",
		     -3600:
		     ([ "test":-1283472000, // 1929-05-01 00:00:00
			-3600:"Europe/Luxembourg",
			0:"Europe/Brussels",]),]),]),]),]),
	 -7200:"Europe/Warsaw",]),]),]);
