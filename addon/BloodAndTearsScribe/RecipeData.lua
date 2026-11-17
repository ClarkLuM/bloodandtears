-- Blood and Tears Scribe: the site's recipe data. Written by tools/recipes/addon_data.py; don't edit it by hand.
local _, ns = ...
if not ns then return end
-- What each recipe makes: an item id, or a negative spell id for enchants.
ns.ids = {
 ["9-60 Battery Pack"]=274048,["Accurate Scope"]=4407,["Acolyte's Boots"]=250506,["Acolyte's Chain Belt"]=250516,["Acolyte's Chain Helm"]=250501,["Acolyte's Chain Leggings"]=250496,
 ["Acolyte's Chain Shirt"]=250491,["Acolyte's Gloves"]=250511,["Acolyte's Silvered Chain Helm"]=250531,["Acolyte's Silvered Chain Leggings"]=250526,["Acolyte's Silvered Chain Shirt"]=250521,["Admiral's Hat"]=10030,
 ["Advanced Target Dummy"]=4392,["Alchemist's Stone"]=13503,["Alchemy Laboratory"]=279990,["Anarchist's Workbench"]=279989,["Annihilator"]=12798,["Anti-Venom"]=6452,
 ["Anvil"]=279988,["Aquadynamic Fish Attractor"]=6533,["Arcane Bomb"]=16040,["Arcane Elixir"]=9155,["Arcane Forge"]=279987,["Arcane Salvager"]=279985,
 ["Arcanite Bar"]=12360,["Arcanite Blacksmith Hammer"]=285281,["Arcanite Champion"]=12790,["Arcanite Dragonling"]=16022,["Arcanite Reaper"]=12784,["Arcanite Rod"]=16206,
 ["Arcanite Skeleton Key"]=15872,["Arclight Spanner"]=6219,["Argent Boots"]=19056,["Argent Shoulders"]=19059,["Azerothium Bar"]=249726,["Azerothium Legplates"]=279265,
 ["Azure Gustwoven Belt"]=277025,["Azure Gustwoven Boots"]=277027,["Azure Gustwoven Bracers"]=277023,["Azure Gustwoven Gloves"]=277024,["Azure Gustwoven Harness"]=277022,["Azure Gustwoven Hood"]=277050,
 ["Azure Gustwoven Spaulders"]=277051,["Azure Gustwoven Trousers"]=277026,["Azure Shoulders"]=7060,["Azure Silk Belt"]=7052,["Azure Silk Cloak"]=7053,["Azure Silk Gloves"]=4319,
 ["Azure Silk Hood"]=7048,["Azure Silk Pants"]=7046,["Azure Silk Vest"]=4324,["Azure Skyforged Chain"]=277019,["Azure Skyforged Chainmail"]=277016,["Azure Skyforged Gauntlets"]=277018,
 ["Azure Skyforged Greaves"]=277021,["Azure Skyforged Helm"]=277048,["Azure Skyforged Legguards"]=277020,["Azure Skyforged Pauldrons"]=277049,["Azure Skyforged Wristguards"]=277017,["Azure Stormsewn Cord"]=277037,
 ["Azure Stormsewn Cowl"]=277054,["Azure Stormsewn Cuffs"]=277035,["Azure Stormsewn Epaulets"]=277055,["Azure Stormsewn Handwraps"]=277036,["Azure Stormsewn Leggings"]=277038,["Azure Stormsewn Shoes"]=277039,
 ["Azure Stormsewn Vest"]=277034,["Azure Windraveled Armguards"]=277029,["Azure Windraveled Cover"]=277052,["Azure Windraveled Drapes"]=277053,["Azure Windraveled Footwraps"]=277033,["Azure Windraveled Jerkin"]=277028,
 ["Azure Windraveled Mitts"]=277030,["Azure Windraveled Pants"]=277032,["Azure Windraveled Strap"]=277031,["Bagh Nakh"]=250618,["Baked Salmon"]=13935,["Barbaric Belt"]=4264,
 ["Barbaric Bracers"]=18948,["Barbaric Gloves"]=4254,["Barbaric Harness"]=5739,["Barbaric Iron Boots"]=7916,["Barbaric Iron Breastplate"]=7914,["Barbaric Iron Gloves"]=7917,
 ["Barbaric Iron Helm"]=7915,["Barbaric Iron Shoulders"]=7913,["Barbaric Leggings"]=5963,["Barbaric Linen Vest"]=2578,["Barbaric Shoulders"]=5964,["Barbecued Buzzard Wing"]=4457,
 ["Basic Campfire"]=279981,["Basic Campfire Kit"]=279981,["Bat Hachee"]=250067,["Bear Brisket"]=250074,["Bear Bruscitti"]=250070,["Beer Basted Boar Ribs"]=2888,
 ["Belt of the Archmage"]=18405,["Bent Goggles"]=280311,["Big Bag of Enchantment"]=22249,["Big Bear Steak"]=3726,["Big Black Mace"]=7945,["Big Bronze Bomb"]=4380,
 ["Big Bronze Knife"]=3848,["Big Iron Bomb"]=4394,["Big Voodoo Cloak"]=8216,["Big Voodoo Mask"]=8201,["Big Voodoo Pants"]=8202,["Big Voodoo Robe"]=8200,
 ["Bileblister Boots"]=275612,["Bileblister Claws"]=275610,["Bileblister Girdle"]=275611,["Biznicks 247x128 Accurascope"]=18283,["Black Amnesty"]=19166,["Black Cord"]=254043,
 ["Black Dragonscale Boots"]=16984,["Black Dragonscale Breastplate"]=15050,["Black Dragonscale Helm"]=252605,["Black Dragonscale Leggings"]=15052,["Black Dragonscale Shoulders"]=15051,["Black Gloves"]=254101,
 ["Black Grasp of the Destroyer"]=22194,["Black Handwraps"]=254027,["Black Mageweave Boots"]=10026,["Black Mageweave Gloves"]=10003,["Black Mageweave Headband"]=10024,["Black Mageweave Leggings"]=9999,
 ["Black Mageweave Robe"]=10001,["Black Mageweave Shoulders"]=10027,["Black Mageweave Vest"]=9998,["Black Sandals"]=254113,["Black Silk Pack"]=5765,["Black Slippers"]=254007,
 ["Black Swashbuckler's Shirt"]=4336,["Black Waistcord"]=254087,["Black Whelp Cloak"]=7283,["Black Whelp Slippers"]=252424,["Black Whelp Tunic"]=20575,["Blackfury"]=19167,
 ["Blackguard"]=19168,["Blackmouth Oil"]=6370,["Blazing Rapier"]=12777,["Bleakwood Hew"]=12769,["Blessed Plate Belt"]=250592,["Blessed Plate Boots"]=250587,
 ["Blessed Plate Bracers"]=250590,["Blessed Plate Chest"]=250594,["Blessed Plate Gauntlet"]=250588,["Blessed Plate Helm"]=250593,["Blessed Plate Leggings"]=250591,["Blessed Plate Pauldrons"]=250586,
 ["Blight"]=7959,["Blood Sausage"]=3220,["Blood Talon"]=12795,["Blood Tiger Breastplate"]=19688,["Blood Tiger Shoulders"]=19689,["Bloodsoul Breastplate"]=19690,
 ["Bloodsoul Gauntlets"]=19692,["Bloodsoul Shoulders"]=19691,["Bloodvine Boots"]=19684,["Bloodvine Goggles"]=19999,["Bloodvine Leggings"]=19683,["Bloodvine Lens"]=19998,
 ["Bloodvine Vest"]=19682,["Blue Dragonscale Breastplate"]=15048,["Blue Dragonscale Helm"]=252604,["Blue Dragonscale Leggings"]=20295,["Blue Dragonscale Shoulders"]=15049,["Blue Firework"]=9312,
 ["Blue Glittering Axe"]=7942,["Blue Linen Robe"]=6242,["Blue Linen Shirt"]=2577,["Blue Linen Vest"]=6240,["Blue Overalls"]=6263,["Blue Rocket Cluster"]=21571,
 ["Blue Suede Armor"]=252480,["Blue Suede Belt"]=252481,["Blue Suede Bracers"]=252559,["Blue Suede Gloves"]=252546,["Blue Suede Hat"]=252482,["Blue Suede Pants"]=252478,
 ["Blue Suede Shoes"]=30894,["Blue Suede Shoulders"]=252554,["Boiled Clams"]=5525,["Bold Dirk"]=250616,["Bolt of Linen Cloth"]=2996,["Bolt of Mageweave"]=4339,
 ["Bolt of Runecloth"]=14048,["Bolt of Silk Cloth"]=4305,["Bolt of Woolen Cloth"]=2997,["Boots of Conviction"]=273927,["Boots of Darkness"]=7027,["Boots of the Enchanter"]=4325,
 ["Bottomless Bag"]=14156,["Bottomless Reagent Bag"]=254139,["Bramblewood Belt"]=22761,["Bramblewood Boots"]=22760,["Bramblewood Helm"]=22759,["Brass Knuckles"]=250602,
 ["Brawler's Leather Armor"]=252490,["Brawler's Leather Belt"]=252428,["Brawler's Leather Boots"]=252439,["Brawler's Leather Gloves"]=252494,["Brawler's Leather Helm"]=252512,["Brawler's Leather Hood"]=252504,
 ["Brawler's Leather Legguards"]=252516,["Brawler's Leather Pants"]=252500,["Brawler's Leather Tunic"]=252508,["Breakfast Omelette"]=250080,["Breastplate of Salvation"]=250601,["Bright Yellow Shirt"]=4332,
 ["Bright-Eye Goggles"]=10499,["Brightcloth Cloak"]=14103,["Brightcloth Gloves"]=14101,["Brightcloth Pants"]=14104,["Brightcloth Robe"]=14100,["Brilliant Mana Oil"]=20748,
 ["Brilliant Smallfish"]=6290,["Brilliant Wand"]=249385,["Brilliant Wizard Oil"]=20749,["Briny Seafood Stew"]=274971,["Bristle Whisker Catfish"]=4593,["Bronze Axe"]=2849,
 ["Bronze Bar"]=2841,["Bronze Battle Axe"]=7958,["Bronze Dory"]=250603,["Bronze Framework"]=4382,["Bronze Greatsword"]=7957,["Bronze Mace"]=2848,
 ["Bronze Shortsword"]=2850,["Bronze Tube"]=4371,["Bronze Warhammer"]=7956,["Broodwatcher's Belt"]=275620,["Broodwatcher's Clenchers"]=275619,["Broodwatcher's Treaders"]=275621,
 ["Brown Linen Pants"]=4343,["Brown Linen Robe"]=6238,["Brown Linen Shirt"]=4344,["Brown Linen Vest"]=2568,["Calcified Smoothie"]=249874,["Camp Tent"]=279978,
 ["Carrion Surprise"]=12213,["Catseye Draught"]=10592,["Catseye Ultra Goggles"]=10501,["Caustic Smog Potion"]=250951,["Cenarion Herb Bag"]=22251,["Centaur Banner Deployment Device"]=269900,
 ["Cerulean Dye"]=249409,["Champion's Legplates"]=250598,["Charged Mithril Battleaxe"]=250612,["Charged Scorpid Belt"]=252575,["Charged Scorpid Boots"]=252602,["Charged Scorpid Bracers"]=252593,
 ["Charged Scorpid Gauntlets"]=252596,["Charged Scorpid Helm"]=252581,["Charged Scorpid Leggings"]=252600,["Charged Scorpid Shoulders"]=252583,["Charged Scorpid Vest"]=252598,["Charred Wolf Meat"]=2679,
 ["Chimeric Boots"]=15073,["Chimeric Gloves"]=15074,["Chimeric Leggings"]=15072,["Chimeric Vest"]=15075,["Chromatic Cloak"]=18509,["Chromatic Gauntlets"]=19157,
 ["Cindercloth Boots"]=10044,["Cindercloth Cloak"]=14044,["Cindercloth Gloves"]=14043,["Cindercloth Pants"]=14045,["Cindercloth Robe"]=10042,["Cindercloth Vest"]=14042,
 ["Clam Chowder"]=5526,["Clam Linguine"]=250081,["Clanking Cord"]=280308,["Cleric's Elixir"]=250332,["Clever Poultice"]=255717,["Cloak of Earth and Sky"]=279270,
 ["Cloak of Fire"]=14134,["Cloak of Warding"]=18413,["Cloudy Gustwoven Belt"]=277001,["Cloudy Gustwoven Boots"]=277003,["Cloudy Gustwoven Bracers"]=276999,["Cloudy Gustwoven Gloves"]=277000,
 ["Cloudy Gustwoven Harness"]=276998,["Cloudy Gustwoven Hood"]=277042,["Cloudy Gustwoven Spaulders"]=277043,["Cloudy Gustwoven Trousers"]=277002,["Cloudy Skyforged Chain"]=276995,["Cloudy Skyforged Chainmail"]=276992,
 ["Cloudy Skyforged Gauntlets"]=276994,["Cloudy Skyforged Greaves"]=276997,["Cloudy Skyforged Helm"]=277040,["Cloudy Skyforged Legguards"]=276996,["Cloudy Skyforged Pauldrons"]=277041,["Cloudy Skyforged Wristguards"]=276993,
 ["Cloudy Stormsewn Cord"]=277013,["Cloudy Stormsewn Cowl"]=277046,["Cloudy Stormsewn Cuffs"]=277011,["Cloudy Stormsewn Epaulets"]=277047,["Cloudy Stormsewn Handwraps"]=277012,["Cloudy Stormsewn Leggings"]=277014,
 ["Cloudy Stormsewn Shoes"]=277015,["Cloudy Stormsewn Vest"]=277010,["Cloudy Windraveled Armguards"]=277005,["Cloudy Windraveled Cover"]=277044,["Cloudy Windraveled Drapes"]=277045,["Cloudy Windraveled Footwraps"]=277009,
 ["Cloudy Windraveled Jerkin"]=277004,["Cloudy Windraveled Mitts"]=277006,["Cloudy Windraveled Pants"]=277008,["Cloudy Windraveled Strap"]=277007,["Cluster Launcher"]=21570,["Clutchlord's Grips"]=275625,
 ["Clutchlord's Stompers"]=275627,["Clutchlord's Support"]=275626,["Coarse Blasting Powder"]=4364,["Coarse Dynamite"]=4365,["Coarse Grinding Stone"]=3478,["Coarse Sharpening Stone"]=2863,
 ["Coarse Weightstone"]=3240,["Colorful Kilt"]=10048,["Comfortable Leather Hat"]=8174,["Compact Critter Carrier"]=260807,["Compact Harvest Reaper Kit"]=4391,["Cooked Crab Claw"]=2682,
 ["Cooked Glossy Mightfish"]=13927,["Cookie's Feast"]=279957,["Copper Axe"]=2845,["Copper Bar"]=2840,["Copper Battle Axe"]=3488,["Copper Bracers"]=2853,
 ["Copper Chain Belt"]=2851,["Copper Chain Boots"]=3469,["Copper Chain Pants"]=2852,["Copper Chain Vest"]=3471,["Copper Claymore"]=7955,["Copper Dagger"]=7166,
 ["Copper Mace"]=2844,["Copper Modulator"]=4363,["Copper Rod"]=6217,["Copper Shortsword"]=2847,["Copper Tube"]=4361,["Core Armor Kit"]=18251,
 ["Core Felcloth Bag"]=21342,["Core Marksman Rifle"]=18282,["Corehound Belt"]=19162,["Corehound Boots"]=16982,["Corruption"]=12782,["Coyote Steak"]=2684,
 ["Crab Cake"]=2683,["Cracked Blacksmith Hammer"]=285279,["Crafted Heavy Shot"]=8068,["Crafted Light Shot"]=8067,["Crafted Solid Shot"]=8069,["Craftsman's Monocle"]=4393,
 ["Crimson Dawnwoven Bag"]=239148,["Crimson Silk Belt"]=7055,["Crimson Silk Cloak"]=7056,["Crimson Silk Gloves"]=7064,["Crimson Silk Pantaloons"]=7062,["Crimson Silk Robe"]=7063,
 ["Crimson Silk Shoulders"]=7059,["Crimson Silk Vest"]=7058,["Crispy Bat Wing"]=12224,["Crispy Lizard Tail"]=5479,["Crocolisk Gumbo"]=3664,["Crocolisk Steak"]=3662,
 ["Crude Scope"]=4405,["Crusader's Boots"]=10192,["Crusader's Chain Belt"]=250517,["Crusader's Chain Helm"]=250502,["Crusader's Chain Leggings"]=250497,["Crusader's Chain Shirt"]=250492,
 ["Crusader's Gloves"]=250512,["Crusader's Knapsack"]=239147,["Crusader's Silvered Chain Helm"]=250532,["Crusader's Silvered Chain Leggings"]=250527,["Crusader's Silvered Chain Shirt"]=250522,["Crystal Infused Bandage"]=23684,
 ["Cured Heavy Hide"]=4236,["Cured Light Hide"]=4231,["Cured Medium Hide"]=4233,["Cured Rugged Hide"]=15407,["Cured Thick Hide"]=8172,["Curiously Tasty Omelet"]=3665,
 ["Dark Iron Bar"]=11371,["Dark Iron Bomb"]=16005,["Dark Iron Boots"]=20039,["Dark Iron Bracers"]=17014,["Dark Iron Destroyer"]=17016,["Dark Iron Gauntlets"]=19164,
 ["Dark Iron Helm"]=19148,["Dark Iron Leggings"]=17013,["Dark Iron Mail"]=11606,["Dark Iron Plate"]=11604,["Dark Iron Pulverizer"]=11608,["Dark Iron Reaver"]=17015,
 ["Dark Iron Rifle"]=16004,["Dark Iron Shoulders"]=11605,["Dark Iron Sunderer"]=11607,["Dark Leather Belt"]=4249,["Dark Leather Boots"]=2315,["Dark Leather Cloak"]=2316,
 ["Dark Leather Gloves"]=4248,["Dark Leather Pants"]=5961,["Dark Leather Shoulders"]=4252,["Dark Leather Tunic"]=2317,["Dark Silk Shirt"]=4333,["Darkrune Breastplate"]=20550,
 ["Darkrune Gauntlets"]=20549,["Darkrune Helm"]=20551,["Darksoul Breastplate"]=19693,["Darksoul Leggings"]=19694,["Darksoul Shoulders"]=19695,["Darkspear"]=12802,
 ["Dawn Armor"]=252483,["Dawn Treaders"]=19052,["Dawn's Edge"]=12774,["Dawnbringer Shoulders"]=12625,["Dazzling Mithril Rapier"]=7944,["Deadly Blunderbuss"]=4369,
 ["Deadly Bronze Poniard"]=3490,["Deadly Scope"]=10546,["Deepdive Helmet"]=10506,["Defender's Leather Armor"]=252434,["Defender's Leather Belt"]=252430,["Defender's Leather Boots"]=252441,
 ["Defender's Leather Gloves"]=252496,["Defender's Leather Helm"]=252455,["Defender's Leather Hood"]=252447,["Defender's Leather Kilt"]=252457,["Defender's Leather Pants"]=252445,["Defender's Leather Tunic"]=252450,
 ["Delicate Arcanite Converter"]=16006,["Demon Forged Breastplate"]=12628,["Demonheart Boots"]=273943,["Demonheart Gloves"]=273941,["Demonheart Leggings"]=273940,["Demonheart Spaulders"]=273942,
 ["Dense Blasting Powder"]=15992,["Dense Dynamite"]=18641,["Dense Grinding Stone"]=12644,["Dense Sharpening Stone"]=12404,["Dense Weightstone"]=12643,["Dented Goggles"]=280313,
 ["Depleted Thorium Sabatons"]=279263,["Deviate Scale Belt"]=6468,["Deviate Scale Cloak"]=6466,["Deviate Scale Gloves"]=6467,["Devilsaur Gauntlets"]=15063,["Devilsaur Leggings"]=15062,
 ["Dig Rat Stew"]=5478,["Dimensional Ripper - Everlook"]=18984,["Dimensional Transporter - Mt. Hyjal"]=260823,["Dirge's Kickin' Chimaerok Chops"]=21023,["Discolored Healing Potion"]=4596,["Discombobulator Ray"]=4388,
 ["Distilled Firewater"]=246948,["Dormant Heart of the Mountain"]=249473,["Double-Stitched Woolen Shoulders"]=4314,["Dragonbreath Chili"]=12217,["Dragonfire Potion"]=250953,["Dragonscale Breastplate"]=8367,
 ["Dragonscale Gauntlets"]=8347,["Draught of Detect Demon"]=9233,["Draught of Detect Lesser Invisibility"]=3828,["Draught of Detect Undead"]=9154,["Draught of Dream Vision"]=9197,["Draught of Greater Water Breathing"]=18294,
 ["Draught of Water Breathing"]=5996,["Draught of Water Walking"]=8827,["Dreambough Wand"]=249234,["Dreamless Sleep Potion"]=12190,["Dreamscale Breastplate"]=20380,["Dreamstaff"]=249454,
 ["Dreamweave Circlet"]=10041,["Dreamweave Gloves"]=10019,["Dreamweave Vest"]=10021,["Dry Pork Ribs"]=2687,["Dusky Belt"]=7387,["Dusky Boots"]=7390,
 ["Dusky Bracers"]=7378,["Dusky Leather Armor"]=7374,["Dusky Leather Leggings"]=7373,["EZ and SAF Field Transporter: Mt. Hyjal"]=260821,["EZ-Thro Bronze Mortar"]=260802,["EZ-Thro Copper Bomb XL"]=260795,
 ["EZ-Thro Dark Bomb"]=260817,["EZ-Thro Dynamite"]=6714,["EZ-Thro Dynamite II"]=18588,["EZ-Thro Field Transporter: Gadgetzan"]=260819,["EZ-Thro Fireproof Fuse"]=260801,["EZ-Thro Grenade"]=260803,
 ["EZ-Thro Magnetic Displacer"]=260829,["EZ-Thro Mana Bomb"]=260818,["EZ-Thro Radiation Bomb"]=215168,["EZ-Thro Shell"]=260815,["EZ-Thro Thorium Grenade"]=260816,["EZ-Thro Tru-Trigger"]=260808,
 ["EZ-Thro Wrap"]=260794,["Earthen Leather Shoulders"]=7352,["Earthen Leggings"]=253999,["Earthen Silk Belt"]=7061,["Earthen Silk Cuffs"]=254019,["Earthen Silk Gloves"]=254017,
 ["Earthen Silk Hood"]=254015,["Earthen Silk Shoulders"]=254033,["Earthen Silk Slippers"]=254013,["Earthen Vest"]=7051,["Earthenweave Boots"]=254093,["Earthenweave Cord"]=254077,
 ["Earthenweave Crown"]=254137,["Earthenweave Cuffs"]=254131,["Earthenweave Gloves"]=254075,["Earthenweave Leggings"]=254125,["Earthenweave Mantle"]=254119,["Earthenweave Vest"]=254121,
 ["Ebon Hand"]=19170,["Ebon Shiv"]=7947,["Edge of Winter"]=17704,["Egg Nog"]=17198,["Elderwild Pants"]=279254,["Elderwild Waistcord"]=279252,
 ["Elemental Fire"]=7068,["Elemental Sharpening Stone"]=18262,["Elementium Bar"]=17771,["Elixir of Agility"]=8949,["Elixir of Brute Force"]=13453,["Elixir of Cunning"]=250328,
 ["Elixir of Defense"]=3389,["Elixir of Ferocity"]=250350,["Elixir of Fire Power"]=6373,["Elixir of Fortitude"]=3825,["Elixir of Frost Power"]=17708,["Elixir of Giant Growth"]=6662,
 ["Elixir of Greater Agility"]=9187,["Elixir of Greater Defense"]=8951,["Elixir of Greater Fortitude"]=250335,["Elixir of Greater Intellect"]=9179,["Elixir of Greater Spirit"]=250347,["Elixir of Greater Strength"]=9206,
 ["Elixir of Holy Power"]=21546,["Elixir of Intellect"]=250354,["Elixir of Lesser Agility"]=3390,["Elixir of Lesser Defense"]=3389,["Elixir of Lesser Fortitude"]=3825,["Elixir of Lesser Intellect"]=250353,
 ["Elixir of Lesser Spirit"]=250345,["Elixir of Minor Agility"]=2457,["Elixir of Minor Defense"]=5997,["Elixir of Minor Force"]=247755,["Elixir of Minor Fortitude"]=2458,["Elixir of Minor Spirit"]=250344,
 ["Elixir of Minor Strength"]=2454,["Elixir of Nature Power"]=250343,["Elixir of Ogre Strength"]=3391,["Elixir of Sages"]=250338,["Elixir of Shadow Power"]=9264,["Elixir of Spirit"]=40072,
 ["Elixir of Strength"]=250349,["Elixir of Wicked Regeneration"]=250336,["Elixir of Wisdom"]=3383,["Elixir of the Grizzly"]=250351,["Elixir of the Mongoose"]=13452,["Elixir of the Owl"]=250337,
 ["Elixir of the Phalanx"]=250329,["Elixir of the Sages"]=13447,["Elixir of the Whale"]=250348,["Embossed Leather Boots"]=2309,["Embossed Leather Cloak"]=2310,["Embossed Leather Gloves"]=4239,
 ["Embossed Leather Pants"]=4242,["Embossed Leather Vest"]=2300,["Emergency Field Cloak"]=260806,["Enchant 2H Weapon - Agility"]=-27837,["Enchant 2H Weapon - Greater Impact"]=-13937,["Enchant 2H Weapon - Impact"]=-13695,
 ["Enchant 2H Weapon - Lesser Agility"]=-1248510,["Enchant 2H Weapon - Lesser Impact"]=-13529,["Enchant 2H Weapon - Lesser Intellect"]=-7793,["Enchant 2H Weapon - Lesser Spirit"]=-13380,["Enchant 2H Weapon - Lesser Strength"]=-1248511,["Enchant 2H Weapon - Major Intellect"]=-20036,
 ["Enchant 2H Weapon - Major Spirit"]=-20035,["Enchant 2H Weapon - Mighty Healing Power"]=-1248636,["Enchant 2H Weapon - Mighty Spell Power"]=-1248607,["Enchant 2H Weapon - Minor Impact"]=-7745,["Enchant 2H Weapon - Spellblasting"]=-1219580,["Enchant 2H Weapon - Strength"]=-1248668,
 ["Enchant 2H Weapon - Superior Impact"]=-20030,["Enchant Boots - Agility"]=-13935,["Enchant Boots - Greater Agility"]=-20023,["Enchant Boots - Greater Stamina"]=-20020,["Enchant Boots - Lesser Agility"]=-13637,["Enchant Boots - Lesser Spirit"]=-13687,
 ["Enchant Boots - Lesser Stamina"]=-13644,["Enchant Boots - Minor Agility"]=-7867,["Enchant Boots - Minor Speed"]=-13890,["Enchant Boots - Minor Stamina"]=-7863,["Enchant Boots - Speed"]=-1328948,["Enchant Boots - Spirit"]=-20024,
 ["Enchant Boots - Stamina"]=-13836,["Enchant Bracer - Agility"]=-1248497,["Enchant Bracer - Deflection"]=-13931,["Enchant Bracer - Greater Agility"]=-1248500,["Enchant Bracer - Greater Intellect"]=-20008,["Enchant Bracer - Greater Spellpower"]=-1220624,
 ["Enchant Bracer - Greater Spirit"]=-13846,["Enchant Bracer - Greater Stamina"]=-13945,["Enchant Bracer - Greater Strength"]=-13939,["Enchant Bracer - Healing Power"]=-23802,["Enchant Bracer - Inferior Stamina"]=-7418,["Enchant Bracer - Intellect"]=-13822,
 ["Enchant Bracer - Lesser Agility"]=-1248460,["Enchant Bracer - Lesser Deflection"]=-13646,["Enchant Bracer - Lesser Healing Power"]=-1248498,["Enchant Bracer - Lesser Intellect"]=-13622,["Enchant Bracer - Lesser Spirit"]=-7859,["Enchant Bracer - Lesser Stamina"]=-13501,
 ["Enchant Bracer - Lesser Strength"]=-13536,["Enchant Bracer - Mana Regeneration"]=-23801,["Enchant Bracer - Minor Agility"]=-7779,["Enchant Bracer - Minor Deflect"]=-7428,["Enchant Bracer - Minor Healing Power"]=-1248459,["Enchant Bracer - Minor Intellect"]=-1248458,
 ["Enchant Bracer - Minor Spirit"]=-7766,["Enchant Bracer - Minor Stamina"]=-7457,["Enchant Bracer - Minor Strength"]=-7782,["Enchant Bracer - Spell Power"]=-1217189,["Enchant Bracer - Spirit"]=-13642,["Enchant Bracer - Stamina"]=-13648,
 ["Enchant Bracer - Strength"]=-13661,["Enchant Bracer - Superior Agility"]=-1248599,["Enchant Bracer - Superior Deflection"]=-1248665,["Enchant Bracer - Superior Intellect"]=-1248661,["Enchant Bracer - Superior Spirit"]=-20009,["Enchant Bracer - Superior Stamina"]=-20011,
 ["Enchant Bracer - Superior Strength"]=-20010,["Enchant Chest - Absorption"]=-1249071,["Enchant Chest - Greater Intellect"]=-13663,["Enchant Chest - Greater Stamina"]=-13640,["Enchant Chest - Greater Stats"]=-20025,["Enchant Chest - Inferior Stamina"]=-7420,
 ["Enchant Chest - Intellect"]=-13607,["Enchant Chest - Lesser Absorption"]=-13538,["Enchant Chest - Lesser Intellect"]=-7776,["Enchant Chest - Lesser Stamina"]=-7748,["Enchant Chest - Lesser Stats"]=-13700,["Enchant Chest - Major Intellect"]=-20028,
 ["Enchant Chest - Major Stamina"]=-20026,["Enchant Chest - Minor Absorption"]=-7426,["Enchant Chest - Minor Intellect"]=-7443,["Enchant Chest - Minor Stats"]=-13626,["Enchant Chest - Stamina"]=-7857,["Enchant Chest - Stats"]=-13941,
 ["Enchant Chest - Superior Intellect"]=-13917,["Enchant Chest - Superior Stamina"]=-13858,["Enchant Cloak - Agility"]=-1219587,["Enchant Cloak - Defense"]=-13635,["Enchant Cloak - Dodge"]=-25086,["Enchant Cloak - Fire Resistance"]=-13657,
 ["Enchant Cloak - Greater Defense"]=-13746,["Enchant Cloak - Greater Fire Resistance"]=-25081,["Enchant Cloak - Greater Nature Resistance"]=-25082,["Enchant Cloak - Greater Resistance"]=-20014,["Enchant Cloak - Lesser Agility"]=-13882,["Enchant Cloak - Lesser Fire Resistance"]=-7861,
 ["Enchant Cloak - Lesser Protection"]=-13421,["Enchant Cloak - Lesser Shadow Resistance"]=-13522,["Enchant Cloak - Minor Agility"]=-13419,["Enchant Cloak - Minor Protection"]=-7771,["Enchant Cloak - Minor Resistance"]=-7454,["Enchant Cloak - Resistance"]=-13794,
 ["Enchant Cloak - Stealth"]=-25083,["Enchant Cloak - Subtlety"]=-25084,["Enchant Cloak - Superior Defense"]=-20015,["Enchant Gloves - Advanced Herbalism"]=-13868,["Enchant Gloves - Advanced Mining"]=-13841,["Enchant Gloves - Advanced Skinning"]=-1248528,
 ["Enchant Gloves - Agility"]=-13815,["Enchant Gloves - Arcane Power"]=-1213626,["Enchant Gloves - Fire Power"]=-25078,["Enchant Gloves - Fishing"]=-13620,["Enchant Gloves - Frost Power"]=-25074,["Enchant Gloves - Greater Agility"]=-20012,
 ["Enchant Gloves - Greater Strength"]=-20013,["Enchant Gloves - Healing Power"]=-25079,["Enchant Gloves - Herbalism"]=-13617,["Enchant Gloves - Holy Power"]=-1213622,["Enchant Gloves - Lotus Claw"]=-1294054,["Enchant Gloves - Mining"]=-13612,
 ["Enchant Gloves - Minor Haste"]=-13948,["Enchant Gloves - Natural Power"]=-1248645,["Enchant Gloves - Riding Skill"]=-13947,["Enchant Gloves - Shadow Power"]=-25073,["Enchant Gloves - Skinning"]=-13698,["Enchant Gloves - Strength"]=-13887,
 ["Enchant Gloves - Superior Agility"]=-25080,["Enchant Gloves - Superior Strength"]=-1248640,["Enchant Gloves - Threat"]=-25072,["Enchant Necklace - Agility"]=-1249059,["Enchant Necklace - Deflection"]=-1249060,["Enchant Necklace - Healing Power"]=-1249058,
 ["Enchant Necklace - Spell Power"]=-1249057,["Enchant Necklace - Strength"]=-1249019,["Enchant Off-Hand - Excellent Spirit"]=-1219578,["Enchant Off-Hand - Superior Intellect"]=-1219577,["Enchant Off-Hand - Wisdom"]=-1219579,["Enchant Shield - Critical Strike"]=-1220623,
 ["Enchant Shield - Excellent Stamina"]=-1219581,["Enchant Shield - Frost Resistance"]=-13933,["Enchant Shield - Greater Spirit"]=-13905,["Enchant Shield - Greater Stamina"]=-20017,["Enchant Shield - Lesser Block"]=-13689,["Enchant Shield - Lesser Protection"]=-13464,
 ["Enchant Shield - Lesser Spirit"]=-13485,["Enchant Shield - Lesser Stamina"]=-13631,["Enchant Shield - Minor Stamina"]=-13378,["Enchant Shield - Spirit"]=-13659,["Enchant Shield - Stamina"]=-13817,["Enchant Shield - Superior Spirit"]=-20016,
 ["Enchant Weapon - Agility"]=-23800,["Enchant Weapon - Crusader"]=-20034,["Enchant Weapon - Demonslaying"]=-13915,["Enchant Weapon - Fiery Weapon"]=-13898,["Enchant Weapon - Grand Sorcerer"]=-1231164,["Enchant Weapon - Greater Striking"]=-13943,
 ["Enchant Weapon - Healing Power"]=-22750,["Enchant Weapon - Icy Chill"]=-20029,["Enchant Weapon - Insight"]=-1248757,["Enchant Weapon - Lesser Beastslayer"]=-13653,["Enchant Weapon - Lesser Elemental Slayer"]=-13655,["Enchant Weapon - Lesser Striking"]=-13503,
 ["Enchant Weapon - Lifestealing"]=-20032,["Enchant Weapon - Mighty Intellect"]=-23804,["Enchant Weapon - Mighty Spirit"]=-23803,["Enchant Weapon - Minor Beastslayer"]=-7786,["Enchant Weapon - Minor Striking"]=-7788,["Enchant Weapon - Recovery"]=-1248760,
 ["Enchant Weapon - Revelation"]=-1248805,["Enchant Weapon - Spell Power"]=-22749,["Enchant Weapon - Strength"]=-23799,["Enchant Weapon - Striking"]=-13693,["Enchant Weapon - Superior Striking"]=-20031,["Enchant Weapon - Unholy Weapon"]=-20033,
 ["Enchant Weapon - Winter's Might"]=-21931,["Enchanted Battlehammer"]=12776,["Enchanted Leather"]=12810,["Enchanted Lute"]=279976,["Enchanted Mageweave Pouch"]=22246,["Enchanted Runecloth Bag"]=22248,
 ["Enchanted Thorium Bar"]=12655,["Enchanted Thorium Breastplate"]=12618,["Enchanted Thorium Helm"]=12620,["Enchanted Thorium Leggings"]=12619,["Enchanter's Cowl"]=4322,["Enriched Thorium Breastplate"]=250595,
 ["Enriched Thorium Helm"]=250597,["Enriched Thorium Leggings"]=250596,["Essence of Air"]=7082,["Essence of Earth"]=7076,["Essence of Fire"]=7078,["Essence of Undeath"]=12808,
 ["Essence of Water"]=7080,["Eternity Pauldrons"]=279255,["Evergreen Shield"]=279262,["Expert Campfire Kit"]=279974,["Explosive Arrow"]=10579,["Explosive Sheep"]=4384,
 ["Faction Banner"]=279972,["Feathered Breastplate"]=8349,["Fel Cape"]=279269,["Felblood Soul Bag"]=279271,["Felcloth Bag"]=21341,["Felcloth Boots"]=14108,
 ["Felcloth Gloves"]=18407,["Felcloth Hood"]=14111,["Felcloth Pants"]=14107,["Felcloth Robe"]=14106,["Felcloth Shoulders"]=14112,["Fermenter"]=279970,
 ["Festival Dress"]=21154,["Festival Suit"]=21542,["Field Repair Bot 74A"]=18232,["Fiery Chain Girdle"]=16989,["Fiery Chain Shoulders"]=16988,["Fiery Cord"]=254041,
 ["Fiery Gloves"]=254099,["Fiery Handwraps"]=254025,["Fiery Plate Gauntlets"]=12631,["Fiery Sandals"]=254111,["Fiery Slippers"]=254005,["Fiery Waistcord"]=254085,
 ["Filet o' Flank"]=238638,["Filet of Redgill"]=13930,["Filigreed Flame Circlet"]=253979,["Filigreed Flame Gown"]=253905,["Filigreed Flame Leggings"]=253941,["Filigreed Pearly Circlet"]=253983,
 ["Filigreed Pearly Gown"]=253909,["Filigreed Pearly Leggings"]=253945,["Filigreed Pristine Circlet"]=253975,["Filigreed Pristine Gown"]=253901,["Filigreed Pristine Leggings"]=253937,["Filigreed Shadow Circlet"]=253981,
 ["Filigreed Shadow Gown"]=253907,["Filigreed Shadow Leggings"]=253943,["Filigreed Shining Circlet"]=253985,["Filigreed Shining Gown"]=253911,["Filigreed Shining Leggings"]=253947,["Filigreed Silky Circlet"]=253977,
 ["Filigreed Silky Gown"]=253903,["Filigreed Silky Leggings"]=253939,["Fillet of Frenzy"]=5476,["Fine Leather Belt"]=4246,["Fine Leather Boots"]=2307,["Fine Leather Cloak"]=2308,
 ["Fine Leather Gloves"]=2312,["Fine Leather Pants"]=5958,["Fine Leather Tunic"]=4243,["Fire Goggles"]=10500,["Fire Oil"]=6371,["Fire Protection Potion"]=6049,
 ["Firework Launcher"]=21569,["First Aid Kit"]=279968,["Flame Boots"]=253893,["Flame Circlet"]=253953,["Flame Deflector"]=4376,["Flame Gloves"]=253917,
 ["Flame Gown"]=253965,["Flame Leggings"]=253991,["Flame Sash"]=253929,["Flank au Poivre"]=250069,["Flarecore Gloves"]=16979,["Flarecore Leggings"]=19165,
 ["Flarecore Mantle"]=16980,["Flarecore Robe"]=19156,["Flarecore Wraps"]=18263,["Flash Bomb"]=4852,["Flask of Chromatic Resistance"]=13513,["Flask of Distilled Wisdom"]=13511,
 ["Flask of Natural Accuracy"]=274273,["Flask of Natural Aggression"]=274274,["Flask of Natural Precision"]=274275,["Flask of Natural Swiftness"]=274276,["Flask of Petrification"]=13506,["Flask of Supreme Power"]=13512,
 ["Flask of the Titans"]=13510,["Flawless Arcanite Rifle"]=16007,["Fletcher's Gloves"]=7348,["Floppy Goggles"]=280310,["Flying Tiger Goggles"]=4368,["Force Reactive Disk"]=18168,
 ["Forceful Heavy Armor Kit"]=252453,["Forceful Medium Armor Kit"]=252437,["Forceful Rugged Armor Kit"]=252488,["Forceful Thick Armor Kit"]=252463,["Forest Defender's Axe"]=279260,["Formal White Shirt"]=4334,
 ["Free Action Potion"]=5634,["Frenzy Potion"]=250940,["Frost Leather Cloak"]=7377,["Frost Oil"]=3829,["Frost Protection Potion"]=6050,["Frost Tiger Blade"]=3854,
 ["Frostguard"]=12797,["Frostsaber Boots"]=15071,["Frostsaber Gloves"]=15070,["Frostsaber Leggings"]=15069,["Frostsaber Tunic"]=15068,["Frostweave Gloves"]=13870,
 ["Frostweave Pants"]=13871,["Frostweave Robe"]=13868,["Frostweave Tunic"]=13869,["Frothing Cord"]=254039,["Frothing Gloves"]=254097,["Frothing Handwraps"]=254023,
 ["Frothing Sandals"]=254109,["Frothing Slippers"]=254003,["Frothing Waistcord"]=254083,["Frozen Heart of the Mountain"]=249469,["Gaea's Embrace"]=22660,["Gauntlets of Glory"]=273945,
 ["Gauntlets of the Sea"]=8346,["Gem-studded Leather Belt"]=4262,["Gemmed Copper Boots"]=250620,["Gemmed Copper Gauntlets"]=3474,["Ghost Dye"]=9210,["Ghostweave Belt"]=14143,
 ["Ghostweave Boots"]=254129,["Ghostweave Cord"]=254073,["Ghostweave Gloves"]=14142,["Ghostweave Hood"]=254135,["Ghostweave Mantle"]=254127,["Ghostweave Pants"]=14144,
 ["Ghostweave Vest"]=14141,["Giant Clam Scorcho"]=6038,["Giant Scrambled Eggs"]=250078,["Gift of Arthas"]=9088,["Gilded Cord"]=254037,["Gilded Gloves"]=254095,
 ["Gilded Handwraps"]=254021,["Gilded Sandals"]=254107,["Gilded Slippers"]=254001,["Gilded Waistcord"]=254081,["Gingerbread Cookie"]=17197,["Girdle of Insight"]=18504,
 ["Girdle of the Dawn"]=19051,["Gizmo Girdle"]=280307,["Glacial Cloak"]=22658,["Glacial Gloves"]=22654,["Glacial Vest"]=22652,["Glacial Wrists"]=22655,
 ["Glimmering Staff"]=249392,["Glinting Steel Dagger"]=12259,["Gloves of Conviction"]=273921,["Gloves of Meditation"]=4318,["Gloves of Spell Mastery"]=14146,["Gloves of the Dawn"]=19057,
 ["Gloves of the Greatfather"]=17721,["Glowing Copper Boots"]=250482,["Gnomish Alarm-O-Bot"]=18645,["Gnomish Army Knife"]=40772,["Gnomish Battle Chicken"]=10725,["Gnomish Cloaking Device"]=4397,
 ["Gnomish Death Ray"]=10645,["Gnomish Goggles"]=10545,["Gnomish Ham Radio"]=10723,["Gnomish Harm Prevention Belt"]=10721,["Gnomish Mind Control Cap"]=10726,["Gnomish Net-o-Matic Projector"]=10720,
 ["Gnomish Poultryizer"]=23835,["Gnomish Rocket Boots"]=10724,["Gnomish Shrink Ray"]=10716,["Gnomish Universal Remote"]=7506,["Gnomish Weather Machine"]=260826,["Goblin \"Boom\" Box"]=10580,
 ["Goblin Bomb Dispenser"]=10587,["Goblin Construction Helmet"]=10543,["Goblin Deviled Clams"]=5527,["Goblin Dragon Gun"]=10727,["Goblin Jumper Cables"]=7148,["Goblin Jumper Cables XL"]=18587,
 ["Goblin Land Mine"]=4395,["Goblin Mining Helmet"]=10542,["Goblin Mortar"]=10577,["Goblin Radio"]=10585,["Goblin Rocket Boots"]=7189,["Goblin Rocket Fuel"]=9061,
 ["Goblin Rocket Helmet"]=10588,["Goblin Sapper Charge"]=10646,["Gold Bar"]=3577,["Gold Power Core"]=10558,["Golden Cord"]=254045,["Golden Gloves"]=254103,
 ["Golden Handwraps"]=254029,["Golden Iron Destroyer"]=3852,["Golden Mantle of the Dawn"]=19058,["Golden Rod"]=11128,["Golden Sandals"]=254115,["Golden Scale Boots"]=3847,
 ["Golden Scale Bracers"]=6040,["Golden Scale Coif"]=3837,["Golden Scale Cuirass"]=3845,["Golden Scale Gauntlets"]=9366,["Golden Scale Leggings"]=3843,["Golden Scale Shoulders"]=3841,
 ["Golden Skeleton Key"]=15870,["Golden Slippers"]=254009,["Golden Waistcord"]=254089,["Goldthorn Tea"]=10841,["Gooey Spider Cake"]=3666,["Gordok Ogre Suit"]=18258,
 ["Goregasher Grips"]=275622,["Goregasher Stompers"]=275624,["Goregasher Support"]=275623,["Goretusk Liver Pie"]=724,["Grand Lobster Banquet"]=238642,["Gray Leather Boots"]=2315,
 ["Gray Woolen Robe"]=2585,["Gray Woolen Shirt"]=2587,["Great Rage Potion"]=5633,["Greater Adept's Robe"]=6264,["Greater Arcane Elixir"]=13454,["Greater Arcane Protection Potion"]=13461,
 ["Greater Cleric's Elixir"]=250333,["Greater Discolored Healing Potion"]=247241,["Greater Dreamless Sleep Potion"]=20002,["Greater Eternal Wand"]=249237,["Greater Fire Protection Potion"]=13457,["Greater Frenzy Potion"]=250941,
 ["Greater Frost Protection Potion"]=13456,["Greater Healing Potion"]=1710,["Greater Holy Protection Potion"]=13460,["Greater Mageblood Elixir"]=250341,["Greater Magic Wand"]=11288,["Greater Mana Potion"]=6149,
 ["Greater Mender's Potion"]=250947,["Greater Mystic Wand"]=11290,["Greater Nature Protection Potion"]=13458,["Greater Shadow Protection Potion"]=13459,["Greater Spellblasting Potion"]=250935,["Greater Stoneshield Potion"]=13455,
 ["Greaves of Glory"]=273947,["Green Dragonscale Breastplate"]=15045,["Green Dragonscale Gauntlets"]=20296,["Green Dragonscale Leggings"]=15046,["Green Firework"]=9313,["Green Holiday Shirt"]=17723,
 ["Green Iron Boots"]=3484,["Green Iron Bracers"]=3835,["Green Iron Gauntlets"]=3485,["Green Iron Hauberk"]=3844,["Green Iron Helm"]=3836,["Green Iron Leggings"]=3842,
 ["Green Iron Shoulders"]=3840,["Green Leather Armor"]=4255,["Green Leather Belt"]=4257,["Green Leather Bracers"]=4259,["Green Lens"]=10504,["Green Linen Bracers"]=4308,
 ["Green Linen Shirt"]=2579,["Green Rocket Cluster"]=21574,["Green Silk Armor"]=7065,["Green Silk Pack"]=5764,["Green Silken Shoulders"]=7057,["Green Tinted Goggles"]=4385,
 ["Green Whelp Armor"]=7375,["Green Whelp Bracers"]=7386,["Green Winter Clothes"]=34087,["Green Woolen Bag"]=4241,["Green Woolen Robe"]=6243,["Green Woolen Vest"]=2582,
 ["Greenhammer"]=279261,["Grilled Squid"]=13928,["Grimstitch Boots"]=273931,["Grimstitch Gloves"]=273929,["Grimstitch Pants"]=273928,["Grimstitch Spaulders"]=273930,
 ["Grovekeeper Boots"]=273895,["Grovekeeper Gauntlets"]=273897,["Grovekeeper Grips"]=273885,["Grovekeeper Handguards"]=273893,["Grovekeeper Kilt"]=273888,["Grovekeeper Leggings"]=273896,
 ["Grovekeeper Legguards"]=273892,["Grovekeeper Mantle"]=273890,["Grovekeeper Mitts"]=273889,["Grovekeeper Pauldrons"]=273894,["Grovekeeper Sandals"]=273891,["Grovekeeper Shoulderpads"]=273886,
 ["Grovekeeper Spaulders"]=273898,["Grovekeeper Stompers"]=273887,["Grovekeeper Treads"]=273899,["Grovekeeper Trousers"]=273884,["Guard's Boots"]=250504,["Guard's Chain Belt"]=250514,
 ["Guard's Chain Helm"]=250499,["Guard's Chain Leggings"]=250494,["Guard's Chain Shirt"]=250489,["Guard's Gloves"]=250509,["Guard's Silvered Chain Helm"]=250529,["Guard's Silvered Chain Leggings"]=250524,
 ["Guard's Silvered Chain Shirt"]=250519,["Guardian Armor"]=4256,["Guardian Belt"]=4258,["Guardian Cloak"]=5965,["Guardian Gloves"]=5966,["Guardian Leather Bracers"]=4260,
 ["Guardian Pants"]=5962,["Gurubashi Mojo Madness"]=19931,["Gyrochronatom"]=4389,["Gyrofreeze Ice Reflector"]=18634,["Gyromatic Micro-Adjustor"]=10498,["Hammer of the Titans"]=12796,
 ["Handful of Copper Bolts"]=4359,["Handguards of Conviction"]=273925,["Handguards of Glory"]=273949,["Hands of Darkness"]=7047,["Handstitched Leather Belt"]=4237,["Handstitched Leather Boots"]=2302,
 ["Handstitched Leather Bracers"]=7277,["Handstitched Leather Cloak"]=7276,["Handstitched Leather Pants"]=2303,["Handstitched Leather Vest"]=5957,["Handstitched Linen Britches"]=4309,["Hard Gold Boots"]=250534,
 ["Hard Gold Bracers"]=250535,["Hard Gold Coif"]=250537,["Hard Gold Cuirass"]=250533,["Hard Gold Gauntlet"]=250538,["Hard Gold Leggings"]=250536,["Hard Gold Pauldrons"]=250539,
 ["Hardened Iron Shortsword"]=3849,["Harvester Override Signalcaster"]=277132,["Healing Potion"]=929,["Heartseeker"]=12783,["Heavy Armor Kit"]=4265,["Heavy Blasting Powder"]=4377,
 ["Heavy Bronze Mace"]=3491,["Heavy Copper Broadsword"]=3487,["Heavy Copper Maul"]=6214,["Heavy Crocolisk Stew"]=20074,["Heavy Dynamite"]=4378,["Heavy Earthen Gloves"]=7359,
 ["Heavy Grinding Stone"]=3486,["Heavy Kodo Stew"]=12215,["Heavy Leather"]=4234,["Heavy Leather Ammo Pouch"]=7372,["Heavy Leather Ball"]=18662,["Heavy Linen Bandage"]=2581,
 ["Heavy Linen Gloves"]=4307,["Heavy Mageweave Bandage"]=8545,["Heavy Mithril Axe"]=7941,["Heavy Mithril Boots"]=7933,["Heavy Mithril Breastplate"]=7930,["Heavy Mithril Gauntlet"]=7919,
 ["Heavy Mithril Helm"]=7934,["Heavy Mithril Pants"]=7921,["Heavy Mithril Shoulder"]=7918,["Heavy Obsidian Belt"]=22197,["Heavy Quiver"]=7371,["Heavy Runecloth Bandage"]=14530,
 ["Heavy Scorpid Belt"]=15082,["Heavy Scorpid Boots"]=252594,["Heavy Scorpid Bracers"]=15077,["Heavy Scorpid Gauntlet"]=15078,["Heavy Scorpid Helm"]=15080,["Heavy Scorpid Leggings"]=15079,
 ["Heavy Scorpid Shoulders"]=15081,["Heavy Scorpid Vest"]=15076,["Heavy Sharpening Stone"]=2871,["Heavy Silk Bandage"]=6451,["Heavy Thorium Bar"]=251291,["Heavy Thorium Gauntlets"]=279264,
 ["Heavy Timbermaw Belt"]=19043,["Heavy Timbermaw Boots"]=19048,["Heavy Weightstone"]=3241,["Heavy Wool Bandage"]=3531,["Heavy Woolen Cloak"]=4311,["Heavy Woolen Gloves"]=4310,
 ["Heavy Woolen Pants"]=4316,["Helm of Fire"]=8348,["Helm of the Great Chief"]=12636,["Herb Baked Egg"]=6888,["Herbalist's Gloves"]=7349,["Hi-Explosive Bomb"]=10562,
 ["Hi-Impact Mithril Slugs"]=10512,["Hide of the Wild"]=18510,["High-Yield Radiation Bomb"]=215127,["Hillman's Belt"]=4250,["Hillman's Cloak"]=3719,["Hillman's Leather Boots"]=252449,
 ["Hillman's Leather Gloves"]=4247,["Hillman's Leather Vest"]=4244,["Hillman's Shoulders"]=4251,["Hivethrasher's Boots"]=275615,["Hivethrasher's Claws"]=275613,["Hivethrasher's Girdle"]=275614,
 ["Holy Protection Potion"]=6051,["Hoof-Shaped Foot Pedal"]=269902,["Hot Lion Chops"]=3727,["Hot Smoked Bass"]=13929,["Hot Wolf Ribs"]=13851,["Huge Thorium Battleaxe"]=12775,
 ["Hyper Deluxe Sniper Rifle Mk XVII"]=279273,["Hyper-Radiant Flame Reflector"]=18638,["Hyperconductive Arcano-Filament"]=213379,["Ice Deflector"]=4386,["Icebane Bracers"]=22671,["Icebane Breastplate"]=22669,
 ["Icebane Gauntlets"]=22670,["Icy Cloak"]=4327,["Icy Scale Bracers"]=22665,["Icy Scale Breastplate"]=22664,["Icy Scale Gauntlets"]=22666,["Idol of Swiftness"]=279250,
 ["Idol of the Dream"]=220606,["Idol of the Ursine Twins"]=279251,["Imperial Plate Belt"]=12424,["Imperial Plate Boots"]=12426,["Imperial Plate Bracers"]=12425,["Imperial Plate Chest"]=12422,
 ["Imperial Plate Gauntlets"]=250589,["Imperial Plate Helm"]=12427,["Imperial Plate Leggings"]=12429,["Imperial Plate Shoulders"]=12428,["Inferno Gloves"]=18408,["Inlaid Mithril Cylinder"]=9060,
 ["Inlaid Thorium Hammer"]=12772,["Invisibility Potion"]=9172,["Invulnerable Mail"]=12641,["Iridescent Hammer"]=5541,["Iron Bar"]=3575,["Iron Buckle"]=7071,
 ["Iron Counterweight"]=6043,["Iron Fists"]=250604,["Iron Grenade"]=4390,["Iron Morningstar"]=250606,["Iron Oven"]=279982,["Iron Shield Spike"]=6042,
 ["Iron Strut"]=4387,["Ironfeather Breastplate"]=15066,["Ironfeather Leggings"]=252486,["Ironfeather Shoulders"]=15067,["Ironforge Breastplate"]=6731,["Ironforge Chain"]=6730,
 ["Ironforge Gauntlets"]=6733,["Ironvine Belt"]=22764,["Ironvine Breastplate"]=22762,["Ironvine Gloves"]=22763,["Ironwood Blade"]=279259,["Jade Serpentblade"]=3850,
 ["Jagged Obsidian Shield"]=22198,["Journeyman Campfire Kit"]=279961,["Jungle Stew"]=12212,["Justicar's Belt"]=250560,["Justicar's Boots"]=250550,["Justicar's Gauntlet"]=250570,
 ["Justicar's Gloves"]=250555,["Justicar's Pauldrons"]=250580,["Justicar's Sabatons"]=250565,["Justicar's Waistguard"]=250575,["Justicar's Wristguards"]=250585,["Justice Epaulets"]=273914,
 ["Justice Gauntlets"]=273909,["Justice Gloves"]=273913,["Justice Greaves"]=273911,["Justice Handguards"]=273917,["Justice Leggings"]=273908,["Justice Legguards"]=273916,
 ["Justice Legplates"]=273912,["Justice Pauldrons"]=273918,["Justice Sabatons"]=273919,["Justice Spaulders"]=273910,["Justice Treads"]=273915,["Kaldorei Spider Kabob"]=5472,
 ["Kodo Hide Bag"]=5081,["Large Blue Rocket"]=21589,["Large Blue Rocket Cluster"]=21714,["Large Copper Bomb"]=4370,["Large Green Rocket"]=21590,["Large Green Rocket Cluster"]=21716,
 ["Large Purple Rocket"]=21591,["Large Purple Rocket Cluster"]=21717,["Large Red Rocket"]=21592,["Large Red Rocket Cluster"]=21718,["Large Seaforium Charge"]=4398,["Large White Rocket"]=21593,
 ["Large White Rocket Cluster"]=21719,["Large Yellow Rocket"]=21595,["Large Yellow Rocket Cluster"]=21720,["Lava Belt"]=19149,["Lavender Mageweave Shirt"]=10054,["Lean Venison"]=5480,
 ["Lean Wolf Steak"]=12209,["Leather Tourniquet"]=255721,["Leggings of Conviction"]=273924,["Legguards of Glory"]=273948,["Legionite Bar"]=251290,["Legionite Glaive"]=250619,
 ["Legplates of Glory"]=273944,["Lesser Arcane Elixir"]=250342,["Lesser Cleric's Elixir"]=250331,["Lesser Discolored Healing Potion"]=247239,["Lesser Eternal Wand"]=249232,["Lesser Frenzy Potion"]=250939,
 ["Lesser Healing Potion"]=858,["Lesser Invisibility Potion"]=3823,["Lesser Mageblood Elixir"]=250340,["Lesser Magic Wand"]=11287,["Lesser Mana Oil"]=20747,["Lesser Mana Potion"]=3385,
 ["Lesser Mender's Potion"]=250945,["Lesser Mystic Wand"]=11289,["Lesser Spellblasting Potion"]=250933,["Lesser Stoneshield Potion"]=4623,["Lesser Troll's Blood Elixir"]=3388,["Lesser Wizard Oil"]=20746,
 ["Lesser Wizard's Robe"]=5766,["Libram of Holy Alacrity"]=228175,["Libram of Infusion"]=279248,["Libram of Invocation"]=249442,["Lifelike Mechanical Toad"]=15996,["Light Armor Kit"]=2304,
 ["Light Leather"]=2318,["Light Leather Bracers"]=7281,["Light Leather Pants"]=7282,["Light Leather Quiver"]=7278,["Light Leather Reagent Bag"]=277715,["Light Obsidian Belt"]=22195,
 ["Lil' Smoky"]=11826,["Limited Invulnerability Potion"]=3387,["Linen Bag"]=4238,["Linen Bandage"]=1251,["Linen Belt"]=7026,["Linen Boots"]=2569,
 ["Linen Cloak"]=2570,["Linen Reagent Bag"]=253664,["Lionheart Helm"]=12640,["Living Action Potion"]=20008,["Living Breastplate"]=15059,["Living Crown"]=252561,
 ["Living Essence"]=12803,["Living Leggings"]=15060,["Living Shoulders"]=15061,["Lobster Stew"]=13933,["Loch Frenzy Delight"]=6316,["Lodestone"]=279960,
 ["Long Silken Cloak"]=4326,["Longjaw Mud Snapper"]=4592,["Loom"]=279959,["Loot-A-Rang"]=260812,["Lovingly Crafted Boomstick"]=4372,["Low-Background Truesilver Plates"]=213376,
 ["Mageblood Elixir"]=20007,["Magenta Dye"]=249430,["Mageweave Bag"]=10050,["Mageweave Bandage"]=8544,["Mageweave Reagent Bag"]=254035,["Magic Resistance Potion"]=9036,
 ["Major Discolored Healing Potion"]=241650,["Major Frenzy Potion"]=250943,["Major Healing Potion"]=13446,["Major Mana Potion"]=13444,["Major Mender's Potion"]=250949,["Major Recombobulator"]=18637,
 ["Major Rejuvenation Potion"]=18253,["Major Spellblasting Potion"]=250937,["Major Troll's Blood Elixir"]=3826,["Mana Potion"]=3827,["Mana Well"]=279956,["Mana-infused Cord"]=279267,
 ["Manaflare Boots"]=273907,["Manaflare Gloves"]=273905,["Manaflare Mantle"]=273906,["Manaflare Pants"]=273904,["Mantle of Conviction"]=273922,["Mantle of the Timbermaw"]=19050,
 ["Martyr's Legplates"]=250600,["Massive Iron Axe"]=3855,["Master Engineer's Goggles"]=16008,["Master Forge"]=279955,["Masterwork Stormhammer"]=12794,["Masterwork Target Dummy"]=16023,
 ["Mechanical Dragonling"]=4396,["Mechanical Repair Kit"]=11590,["Mechanical Squirrel Box"]=4401,["Medium Armor Kit"]=2313,["Medium Leather"]=2319,["Mender's Leather Belt"]=252523,
 ["Mender's Leather Boots"]=252472,["Mender's Leather Bracers"]=252543,["Mender's Leather Gauntlets"]=252551,["Mender's Leather Gloves"]=252530,["Mender's Leather Shoes"]=252533,["Mender's Leather Shoulders"]=252538,
 ["Mender's Leather Waistguard"]=252477,["Mender's Mail Belt"]=252591,["Mender's Mail Boots"]=252565,["Mender's Mail Bracers"]=252573,["Mender's Mail Gauntlets"]=252587,["Mender's Mail Sabatons"]=252579,
 ["Mender's Mail Shoulders"]=252569,["Mender's Potion"]=250946,["Might of the Timbermaw"]=19044,["Mightfish Steak"]=13934,["Mighty Iron Hammer"]=3492,["Mighty Rage Potion"]=13442,
 ["Minor Arcane Elixir"]=247754,["Minor Cleric's Elixir"]=250330,["Minor Discolored Healing Potion"]=4596,["Minor Frenzy Potion"]=250938,["Minor Healing Potion"]=118,["Minor Mageblood Elixir"]=250339,
 ["Minor Magic Resistance Potion"]=3384,["Minor Mana Oil"]=20745,["Minor Mana Potion"]=2455,["Minor Mender's Potion"]=250944,["Minor Recombobulator"]=4381,["Minor Rejuvenation Potion"]=2456,
 ["Minor Spellblasting Potion"]=250932,["Minor Troll's Blood Elixir"]=3382,["Minor Wizard Oil"]=20744,["Mithril Bar"]=3860,["Mithril Blacksmith Hammer"]=285280,["Mithril Blunderbuss"]=10508,
 ["Mithril Casing"]=10561,["Mithril Claws"]=250609,["Mithril Claymore"]=250610,["Mithril Coif"]=7931,["Mithril Frag Bomb"]=10514,["Mithril Gyro-Shot"]=10513,
 ["Mithril Head Trout"]=8364,["Mithril Heavy-bore Rifle"]=10510,["Mithril Mechanical Dragonling"]=10576,["Mithril Plate Bracers"]=7924,["Mithril Plate Gloves"]=7925,["Mithril Plate Pants"]=7920,
 ["Mithril Plate Shoulders"]=7932,["Mithril Shield Spike"]=7967,["Mithril Shortsword"]=250607,["Mithril Spurs"]=7969,["Mithril Stiletto"]=250611,["Mithril Tube"]=10559,
 ["Mithril Warhammer"]=250608,["Mobile Alarm"]=10719,["Molten Belt"]=19163,["Molten Foundry"]=279952,["Molten Heart of the Mountain"]=249470,["Molten Helm"]=16983,
 ["Mongoose Boots"]=18506,["Monster Omelet"]=12218,["Mooncloth"]=14342,["Mooncloth Bag"]=14155,["Mooncloth Boots"]=15802,["Mooncloth Circlet"]=14140,
 ["Mooncloth Gloves"]=18409,["Mooncloth Leggings"]=14137,["Mooncloth Reagent Bag"]=254133,["Mooncloth Robe"]=18486,["Mooncloth Shoulders"]=14139,["Mooncloth Vest"]=14138,
 ["Moonglow Boots"]=252427,["Moonglow Vest"]=6709,["Moonsight Rifle"]=4383,["Moonsteel Broadsword"]=3853,["Mote of Magic"]=247786,["Mourning Handguards"]=279257,
 ["Mrrggl Smrrthle"]=249873,["Murloc Fin Soup"]=3663,["Murloc Scale Belt"]=5780,["Murloc Scale Bracers"]=5783,["Murloc Scale Breastplate"]=5781,["Murloc Scale Shoes"]=252426,
 ["Mystery Stew"]=12214,["Mystic Heavy Armor Kit"]=252452,["Mystic Medium Armor Kit"]=252436,["Mystic Mushroom"]=249396,["Mystic Rugged Armor Kit"]=252487,["Mystic Thick Armor Kit"]=252462,
 ["Nature Protection Potion"]=6052,["Netherflame Cuffs"]=254065,["Netherflame Shoulders"]=254053,["Netherfroth Cuffs"]=254063,["Netherfroth Shoulders"]=254051,["Nethergeld Cuffs"]=254061,
 ["Nethergeld Shoulders"]=254049,["Netherlight Cuffs"]=254071,["Netherlight Shoulders"]=254059,["Netherpearl Cuffs"]=254067,["Netherpearl Shoulders"]=254055,["Nethershine Cuffs"]=254069,
 ["Nethershine Shoulders"]=254057,["Nightfall"]=19169,["Nightfin Soup"]=13931,["Nightscape Boots"]=8197,["Nightscape Cloak"]=8195,["Nightscape Headband"]=8176,
 ["Nightscape Pants"]=8193,["Nightscape Shoulders"]=8192,["Nightscape Tunic"]=8175,["Nimble Leather Gloves"]=7285,["No Slip SAF-T Padding"]=260796,["Novice Arcanist's Sash"]=253885,
 ["Novice Ardent's Sash"]=253887,["Novice's Practice Wand"]=247789,["Obsidian Mail Tunic"]=22191,["Officer's Belt"]=250556,["Officer's Boots"]=250546,["Officer's Gauntlet"]=250566,
 ["Officer's Gloves"]=250551,["Officer's Pauldrons"]=250576,["Officer's Sabatons"]=250561,["Officer's Waistguard"]=250571,["Officer's Wristguards"]=250581,["Oil of Immolation"]=8956,
 ["Onyxia Scale Cloak"]=15138,["Orange Mageweave Shirt"]=10056,["Orange Martial Shirt"]=10052,["Orb of Mystic Insight"]=249394,["Orb of Souls"]=249395,["Orcish War Leggings"]=7929,
 ["Ornate Mithril Boots"]=7936,["Ornate Mithril Breastplate"]=7935,["Ornate Mithril Gloves"]=7927,["Ornate Mithril Helm"]=7937,["Ornate Mithril Pants"]=7926,["Ornate Mithril Shoulders"]=7928,
 ["Ornate Spyglass"]=5507,["Ornate Thorium Handaxe"]=12773,["Outlaw's Collar"]=279253,["Pants of Conviction"]=273920,["Parachute Cloak"]=10518,["Patterned Bronze Bracers"]=2868,
 ["Pauldrons of Conviction"]=273926,["Pauldrons of Glory"]=273950,["Peace Tea"]=249865,["Pearl-clasped Cloak"]=5542,["Pearl-handled Dagger"]=5540,["Pearly Boots"]=253897,
 ["Pearly Circlet"]=253957,["Pearly Gloves"]=253921,["Pearly Gown"]=253969,["Pearly Leggings"]=253995,["Pearly Sash"]=253933,["Persuader"]=22384,
 ["Pet Bombling"]=11825,["Phantom Blade"]=7961,["Philosopher's Stone"]=9149,["Phoenix Gloves"]=4331,["Phoenix Pants"]=4317,["Pilferer's Gloves"]=7358,
 ["Pincer Bites"]=263512,["Pink Mageweave Shirt"]=10055,["Plague Doctor's Laboratory"]=279951,["Plain Ol' Paletusk"]=274976,["Plated Armorfish"]=13890,["Poached Sunscale Salmon"]=13932,
 ["Polar Bracers"]=22663,["Polar Gloves"]=22662,["Polar Tunic"]=22661,["Polished Driftwood Icon"]=249398,["Polished Steel Boots"]=3846,["Polished Truesilver Gears"]=213383,
 ["Pop-Up Shrub"]=237023,["Portable Bronze Mortar"]=4403,["Potent Anti-Venom"]=255715,["Potion of Beast Slaying"]=250955,["Potion of Demon Slaying"]=9224,["Potion of Elemental Purging"]=250954,
 ["Potion of Poison Cleansing"]=3386,["Potion of Predatory Senses"]=250327,["Potion of Venomous Blood"]=250950,["Powerful Anti-Venom"]=19440,["Powerful Poultice"]=255719,["Powerful Seaforium Charge"]=18594,
 ["Practice Lock"]=6712,["Prefect's Belt"]=250559,["Prefect's Boots"]=250549,["Prefect's Gauntlet"]=250569,["Prefect's Gloves"]=250554,["Prefect's Pauldrons"]=250579,
 ["Prefect's Sabatons"]=250564,["Prefect's Waistguard"]=250574,["Prefect's Wristguards"]=250584,["Prehistoric Pulled Raptor"]=250075,["Primal Batskin Bracers"]=19687,["Primal Batskin Gloves"]=19686,
 ["Primal Batskin Jerkin"]=19685,["Pristine Boots"]=253889,["Pristine Circlet"]=253949,["Pristine Gloves"]=253913,["Pristine Gown"]=253961,["Pristine Leggings"]=253987,
 ["Pristine Sash"]=253925,["Pristine Scorpid Leggings"]=252606,["Protector's Boots"]=31420,["Protector's Chain Belt"]=250515,["Protector's Chain Helm"]=250500,["Protector's Chain Leggings"]=250495,
 ["Protector's Chain Shirt"]=250490,["Protector's Gloves"]=250510,["Protector's Silvered Chain Helm"]=250530,["Protector's Silvered Chain Leggings"]=250525,["Protector's Silvered Chain Shirt"]=250520,["Prowler Steak"]=238637,
 ["Prowler's Leather Belt"]=252459,["Prowler's Leather Boots"]=252468,["Prowler's Leather Bracers"]=252539,["Prowler's Leather Gauntlets"]=252547,["Prowler's Leather Gloves"]=252524,["Prowler's Leather Shoes"]=252465,
 ["Prowler's Leather Shoulders"]=252534,["Prowler's Leather Waistguard"]=252473,["Purification Potion"]=13462,["Purple Rocket Cluster"]=21575,["Quickdraw Quiver"]=8217,["Radiant Belt"]=12416,
 ["Radiant Boots"]=12419,["Radiant Breastplate"]=12415,["Radiant Circlet"]=12417,["Radiant Cord"]=254047,["Radiant Gloves"]=12418,["Radiant Handwraps"]=254031,
 ["Radiant Leggings"]=12420,["Radiant Sandals"]=254117,["Radiant Slippers"]=254011,["Radiant Staff"]=249453,["Radiant Waistcord"]=254091,["Rage Potion"]=5631,
 ["Raging Raptor Ribs"]=250073,["Rainbow Fin Albacore"]=5095,["Raptor Hide Belt"]=4456,["Raptor Hide Harness"]=4455,["Raptor Rouladen"]=250076,["Reagent Bot"]=279950,
 ["Red Dragonscale Breastplate"]=15047,["Red Dragonscale Leggings"]=252603,["Red Firework"]=9318,["Red Linen Bag"]=5762,["Red Linen Robe"]=2572,["Red Linen Shirt"]=2575,
 ["Red Linen Vest"]=6239,["Red Mageweave Bag"]=10051,["Red Mageweave Gloves"]=10018,["Red Mageweave Headband"]=10033,["Red Mageweave Pants"]=10009,["Red Mageweave Shoulders"]=10029,
 ["Red Mageweave Vest"]=10007,["Red Rocket Cluster"]=21576,["Red Swashbuckler's Shirt"]=6796,["Red Whelp Gloves"]=7284,["Red Winter Clothes"]=34085,["Red Woolen Bag"]=5763,
 ["Red Woolen Boots"]=4313,["Redridge Goulash"]=1082,["Refined Scale of Onyxia"]=17967,["Reinforced Linen Cape"]=2580,["Reinforced Woolen Shoulders"]=4315,["Repair Bot"]=279949,
 ["Restorative Potion"]=9030,["Rich Purple Silk Shirt"]=4335,["Rime-encrusted Boots"]=279268,["Roast Raptor"]=12210,["Roasted Boar Meat"]=2681,["Roasted Kodo Meat"]=5474,
 ["Robe of Power"]=7054,["Robe of Winter Night"]=14136,["Robe of the Archmage"]=14152,["Robe of the Void"]=14153,["Robes of Arcana"]=5770,["Robes of Fiery Devastation"]=279266,
 ["Rock Garden"]=279948,["Rockscale Cod"]=4594,["Root Tea"]=249867,["Rose Colored Goggles"]=10503,["Rough Blasting Powder"]=4357,["Rough Boomstick"]=4362,
 ["Rough Bronze Boots"]=6350,["Rough Bronze Bracers"]=2867,["Rough Bronze Cuirass"]=2866,["Rough Bronze Leggings"]=2865,["Rough Bronze Shoulders"]=3480,["Rough Copper Bomb"]=4360,
 ["Rough Copper Chain Boots"]=277672,["Rough Copper Vest"]=10421,["Rough Dynamite"]=4358,["Rough Grinding Stone"]=3470,["Rough Sharpening Stone"]=2862,["Rough Weightstone"]=3239,
 ["Royal Tea"]=249866,["Rugged Armor Kit"]=15564,["Rugged Leather"]=8170,["Rugged Leather Pants"]=7280,["Rune Edge"]=12779,["Runecloth Bag"]=14046,
 ["Runecloth Bandage"]=14529,["Runecloth Belt"]=13856,["Runecloth Boots"]=13864,["Runecloth Cloak"]=13860,["Runecloth Cuffs"]=254123,["Runecloth Gloves"]=13863,
 ["Runecloth Headband"]=13866,["Runecloth Pants"]=13865,["Runecloth Reagent Bag"]=254079,["Runecloth Robe"]=13858,["Runecloth Shoulders"]=13867,["Runecloth Tunic"]=13857,
 ["Runed Arcanite Rod"]=16207,["Runed Copper Belt"]=2857,["Runed Copper Bracers"]=2854,["Runed Copper Breastplate"]=2864,["Runed Copper Gauntlets"]=3472,["Runed Copper Pants"]=3473,
 ["Runed Copper Rod"]=6218,["Runed Golden Rod"]=11130,["Runed Mithril Hammer"]=7946,["Runed Silver Rod"]=6339,["Runed Stygian Belt"]=20539,["Runed Stygian Boots"]=20537,
 ["Runed Stygian Leggings"]=20538,["Runed Truesilver Rod"]=11145,["Runic Breastplate"]=12613,["Runic Leather Armor"]=15090,["Runic Leather Belt"]=15093,["Runic Leather Bracers"]=15092,
 ["Runic Leather Gauntlets"]=15091,["Runic Leather Headband"]=15094,["Runic Leather Pants"]=15095,["Runic Leather Shoulders"]=15096,["Runic Plate Boots"]=12611,["Runic Plate Helm"]=12612,
 ["Runic Plate Leggings"]=12614,["Runic Plate Shoulders"]=12610,["Runn Tum Tuber Surprise"]=18254,["SAF-T Bell"]=260799,["SAF-T Bomb"]=260805,["SAF-T Bronze Bomb"]=260797,
 ["SAF-T Casing"]=260804,["SAF-T Clever Dynamite"]=260814,["SAF-T Copper Bomb"]=260793,["SAF-T Disposable Parachute"]=260810,["SAF-T Dynamite"]=260792,["SAF-T Emergency Ripper: Everlook"]=260820,
 ["SAF-T Jumbo Dynamite"]=260798,["SAF-T Nitro Boosts"]=260828,["SAF-T Tabs"]=260784,["SAF-T Teleport"]=260830,["SAF-T Tube"]=260813,["SAF-T Ultra Precision Scope"]=279272,
 ["Sabatons of Glory"]=273951,["Sage's Tea"]=249870,["Sageblade"]=22383,["Sagefish Delight"]=21217,["Salt Shaker"]=15846,["Sandpaper"]=249432,
 ["Sandstalker Bracers"]=20476,["Sandstalker Breastplate"]=20478,["Sandstalker Gauntlets"]=20477,["Satchel of Bronze Bombs"]=285276,["Satchel of Cenarius"]=22252,["Satchel of Copper Bombs"]=285275,
 ["Satchel of Dark Iron Bombs"]=285278,["Satchel of Iron Bombs"]=285277,["Savory Deviate Delight"]=6657,["Savory Stag Sliders"]=250065,["Savory Turtle Stew"]=250068,["Savory Whimsyfin Delight"]=251525,
 ["Scalegut Belt"]=275617,["Scalegut Clenchers"]=275616,["Scalegut Treaders"]=275618,["Scorpid Surprise"]=5473,["Scroll of Spatial Mending"]=220792,["Searing Golden Blade"]=12260,
 ["Seasoned Wolf Kabob"]=1017,["Sentinel's Belt"]=250557,["Sentinel's Boots"]=250547,["Sentinel's Gauntlet"]=250567,["Sentinel's Gloves"]=250552,["Sentinel's Pauldrons"]=250577,
 ["Sentinel's Sabatons"]=250562,["Sentinel's Waistguard"]=250572,["Sentinel's Wristguards"]=250582,["Serenity"]=12781,["Sewing Machine"]=279945,["Shadow Boots"]=253895,
 ["Shadow Circlet"]=253955,["Shadow Crescent Axe"]=3856,["Shadow Gloves"]=253919,["Shadow Goggles"]=4373,["Shadow Gown"]=253967,["Shadow Hood"]=4323,
 ["Shadow Leggings"]=253993,["Shadow Oil"]=3824,["Shadow Protection Potion"]=6048,["Shadow Sash"]=253931,["Shadoweave Boots"]=10031,["Shadoweave Gloves"]=10023,
 ["Shadoweave Mask"]=10025,["Shadoweave Pants"]=10002,["Shadoweave Robe"]=10004,["Shadoweave Shoulders"]=10028,["Shadowskin Gloves"]=18238,["Shafety Sheep"]=260800,
 ["Sharpening Wheel"]=279944,["Shifting Cloak"]=18511,["Shining Boots"]=253899,["Shining Circlet"]=253959,["Shining Gloves"]=253923,["Shining Gown"]=253971,
 ["Shining Leggings"]=253997,["Shining Mithril Boots"]=250542,["Shining Mithril Breastplate"]=250540,["Shining Mithril Gauntlet"]=250545,["Shining Mithril Helm"]=250543,["Shining Mithril Pants"]=250544,
 ["Shining Mithril Pauldrons"]=250541,["Shining Sash"]=253935,["Shining Silver Breastplate"]=2870,["Shoulders of Glory"]=273946,["Shredder Autosalvage Unit"]=210147,["Silk Bandage"]=6450,
 ["Silk Headband"]=7050,["Silk Reagent Bag"]=253973,["Silky Boots"]=253891,["Silky Circlet"]=253951,["Silky Gloves"]=253915,["Silky Gown"]=253963,
 ["Silky Leggings"]=253989,["Silky Sash"]=253927,["Silver Bar"]=2842,["Silver Contact"]=4404,["Silver Rod"]=6338,["Silver Skeleton Key"]=15869,
 ["Silver-plated Shotgun"]=4379,["Silvered Bronze Boots"]=3482,["Silvered Bronze Breastplate"]=2869,["Silvered Bronze Gauntlets"]=3483,["Silvered Bronze Leggings"]=10423,["Silvered Bronze Shoulders"]=3481,
 ["Simple Black Dress"]=10053,["Simple Dress"]=6786,["Simple Kilt"]=10047,["Simple Linen Boots"]=10046,["Simple Linen Pants"]=10045,["Simple Poultice"]=255716,
 ["Skirmisher's Leather Belt"]=252461,["Skirmisher's Leather Gloves"]=252528,["Skirmisher's Mail Belt"]=252590,["Skirmisher's Mail Boots"]=252564,["Skirmisher's Mail Bracers"]=252572,["Skirmisher's Mail Gauntlets"]=252586,
 ["Skirmisher's Mail Sabatons"]=252578,["Skirmisher's Mail Shoulders"]=252568,["Skulker's Leather Belt"]=252520,["Skulker's Leather Boots"]=252469,["Skulker's Leather Bracers"]=252540,["Skulker's Leather Gauntlets"]=252548,
 ["Skulker's Leather Gloves"]=252525,["Skulker's Leather Shoes"]=252531,["Skulker's Leather Shoulder"]=252535,["Skulker's Leather Waistguard"]=252474,["Skycaller's Leather Belt"]=252522,["Skycaller's Leather Boots"]=252471,
 ["Skycaller's Leather Bracers"]=252542,["Skycaller's Leather Gauntlets"]=252550,["Skycaller's Leather Gloves"]=252529,["Skycaller's Leather Shoes"]=252532,["Skycaller's Leather Shoulders"]=252537,["Skycaller's Leather Waistguard"]=252476,
 ["Skycaller's Mail Belt"]=252589,["Skycaller's Mail Boots"]=252563,["Skycaller's Mail Bracers"]=252571,["Skycaller's Mail Gauntlets"]=252585,["Skycaller's Mail Sabatons"]=252577,["Skycaller's Mail Shoulders"]=252567,
 ["Skywall Souffle"]=263509,["Slimy Smoothie"]=249872,["Slitherskin Mackerel"]=787,["Small Blue Rocket"]=21558,["Small Bronze Bomb"]=4374,["Small Green Rocket"]=21559,
 ["Small Leather Ammo Pouch"]=7279,["Small Purple Rocket"]=21560,["Small Red Rocket"]=21557,["Small Seaforium Charge"]=4367,["Small Silk Pack"]=4245,["Small White Rocket"]=21561,
 ["Small Yellow Rocket"]=21562,["Smoked Bear Meat"]=6890,["Smoked Desert Dumplings"]=20452,["Smoked Sagefish"]=21072,["Smoking Heart of the Mountain"]=11811,["Snake Burst Firework"]=19026,
 ["Sniper Scope"]=10548,["Snowmaster 9000"]=17716,["Soaring Pamplona"]=250066,["Soft-soled Linen Boots"]=4312,["Solid Blasting Powder"]=10505,["Solid Dynamite"]=10507,
 ["Solid Grinding Stone"]=7966,["Solid Iron Maul"]=3851,["Solid Sharpening Stone"]=7964,["Solid Weightstone"]=7965,["Soothing Turtle Bisque"]=3729,["Soul Pouch"]=21340,
 ["Soulstaff"]=249393,["Specklefin Feast"]=238641,["Spellblasting Potion"]=250934,["Spellpower Goggles Xtreme"]=10502,["Spellpower Goggles Xtreme Plus"]=15999,["Spiced Chili Crab"]=12216,
 ["Spiced Wolf Meat"]=2680,["Spicy Smoothie"]=249875,["Spider Belt"]=4328,["Spider Sausage"]=17222,["Spider Silk Slippers"]=4321,["Spidersilk Boots"]=4320,
 ["Spinefin Halibut"]=8957,["Spinning Wheel"]=279943,["Spiritcaller Boots"]=276541,["Spiritcaller Epaulets"]=273938,["Spiritcaller Gauntlets"]=273937,["Spiritcaller Gloves"]=276539,
 ["Spiritcaller Greaves"]=273939,["Spiritcaller Grips"]=273933,["Spiritcaller Kilt"]=276538,["Spiritcaller Leggings"]=273932,["Spiritcaller Mantle"]=276540,["Spiritcaller Pants"]=273936,
 ["Spiritcaller Spaulders"]=273934,["Spiritcaller Treads"]=273935,["Spitfire Bracers"]=20481,["Spitfire Breastplate"]=20479,["Spitfire Gauntlets"]=20480,["Spotted Yellowtail"]=6887,
 ["Stalker's Leather Belt"]=252521,["Stalker's Leather Gloves"]=252526,["Stalker's Mail Belt"]=252588,["Stalker's Mail Boots"]=252562,["Stalker's Mail Bracers"]=252570,["Stalker's Mail Gauntlets"]=252584,
 ["Stalker's Mail Sabatons"]=252576,["Stalker's Mail Shoulders"]=252566,["Stalwart Helm"]=250599,["Standard Scope"]=4406,["Star Belt"]=4329,["Steadfast Libram"]=279247,
 ["Stealthman 52"]=260827,["Steam Tonk Controller"]=22728,["Steaming Stag Steak"]=250071,["Steel Bar"]=3859,["Steel Breastplate"]=7963,["Steel Plate Helm"]=7922,
 ["Steel Spear"]=250605,["Steel Weapon Chain"]=6041,["Sterling Silver Boots"]=250483,["Sterling Silver Breastplate"]=250487,["Sterling Silver Gauntlet"]=250485,["Sterling Silver Leggings"]=250484,
 ["Sterling Silver Shoulders"]=250486,["Stonescale Oil"]=13423,["Storm Gauntlets"]=12632,["Stormcarver"]=250617,["Stormcloth Boots"]=10039,["Stormcloth Gloves"]=10011,
 ["Stormcloth Headband"]=10032,["Stormcloth Pants"]=10010,["Stormcloth Shoulders"]=10038,["Stormcloth Vest"]=10020,["Stormrider's Leather Armor"]=252492,["Stormrider's Leather Belt"]=252432,
 ["Stormrider's Leather Boots"]=252443,["Stormrider's Leather Gloves"]=252498,["Stormrider's Leather Helm"]=252514,["Stormrider's Leather Hood"]=252506,["Stormrider's Leather Kilt"]=252518,["Stormrider's Leather Pants"]=252502,
 ["Stormrider's Leather Tunic"]=252510,["Stormshroud Armor"]=15056,["Stormshroud Gloves"]=21278,["Stormshroud Pants"]=15057,["Stormshroud Shoulders"]=15058,["Strange Copper Boots"]=250621,
 ["Strider Stew"]=5477,["Strong Anti-Venom"]=6453,["Stronghold Gauntlets"]=12639,["Stuckbutton Goggles"]=280312,["Stylish Blue Shirt"]=6384,["Stylish Green Shirt"]=6385,
 ["Stylish Red Shirt"]=4330,["Succulent Pork Ribs"]=2685,["Sulfuric Acid"]=249410,["Sulfuron Hammer"]=17193,["Sunny Tea"]=249869,["Sunrise Omelette"]=238639,
 ["Superior Discolored Healing Potion"]=247242,["Superior Frenzy Potion"]=250942,["Superior Healing Potion"]=3928,["Superior Mana Potion"]=13443,["Superior Mender's Potion"]=250948,["Superior Poultice"]=255718,
 ["Superior Spellblasting Potion"]=250936,["Supple Scorpid Belt"]=252595,["Supple Scorpid Boots"]=252574,["Supple Scorpid Bracers"]=252582,["Supple Scorpid Helm"]=252597,["Supple Scorpid Leggings"]=252580,
 ["Supple Scorpid Sabatons"]=252601,["Supple Scorpid Shoulders"]=252592,["Supple Scorpid Vest"]=252599,["Surgical Tourniquet"]=255722,["Swarmtender's Cord"]=275608,["Swarmtender's Footpads"]=275609,
 ["Swarmtender's Gloves"]=275607,["Sweetpaw Jam"]=267341,["Swift Boots"]=7391,["Swift Flight Bracers"]=18508,["Swiftfeather Arrow"]=274387,["Swiftness Potion"]=2459,
 ["Swiftstrike Shot"]=274388,["Swiftstrike Steak"]=250072,["Swim Speed Potion"]=6372,["Sylvan Crown"]=22757,["Sylvan Shoulders"]=22758,["Sylvan Vest"]=22756,
 ["Talons of Wrath"]=249441,["Tanning Rack"]=279941,["Target Dummy"]=4366,["Tasty Lion Steak"]=3728,["Tasty Raptor Bites"]=250079,["Tender Wolf Steak"]=18045,
 ["Tenets of the Silver Hand"]=249397,["The Big One"]=10586,["The Shatterer"]=7954,["Thick Armor Kit"]=8173,["Thick Leather"]=4304,["Thick Leather Ammo Pouch"]=8218,
 ["Thick Murloc Armor"]=5782,["Thick Obsidian Breastplate"]=22196,["Thick War Axe"]=3489,["Thistle Tea"]=7676,["Thorium Armor"]=12405,["Thorium Bar"]=12359,
 ["Thorium Belt"]=12406,["Thorium Boots"]=12409,["Thorium Bracers"]=12408,["Thorium Cestus"]=250614,["Thorium Greatmace"]=250613,["Thorium Greatsword"]=12764,
 ["Thorium Grenade"]=15993,["Thorium Helm"]=12410,["Thorium Leggings"]=12414,["Thorium Poleaxe"]=250615,["Thorium Rifle"]=15995,["Thorium Shells"]=15997,
 ["Thorium Shield Spike"]=12645,["Thorium Tube"]=16000,["Thorium Widget"]=15994,["Timbermaw Brawlers"]=19049,["Timbermaw Tunic"]=252484,["Tin Bar"]=3576,
 ["Tinkerbox"]=238737,["Tinkerbox: Magnetic Displacement"]=238736,["Tinkerbox: Nitro Boosts"]=238735,["Tinkerbox: Teleport"]=238734,["Titanic Leggings"]=22385,["Tooled Leather Armor"]=252552,
 ["Tooled Leather Belt"]=252544,["Tooled Leather Boots"]=252545,["Tooled Leather Bracers"]=252557,["Tooled Leather Crown"]=252555,["Tooled Leather Epaulets"]=252558,["Tooled Leather Gauntlets"]=252553,
 ["Tooled Leather Pants"]=252560,["Torch of Light"]=279246,["Totem of Ancestral Protection"]=249443,["Totem of Thunder"]=228176,["Totem of Urgency"]=279249,["Totemic Leather Armor"]=252435,
 ["Totemic Leather Belt"]=252431,["Totemic Leather Boots"]=252442,["Totemic Leather Gloves"]=252497,["Totemic Leather Helm"]=252456,["Totemic Leather Hood"]=252448,["Totemic Leather Leggings"]=252458,
 ["Totemic Leather Pants"]=252446,["Totemic Leather Tunic"]=252451,["Tough Scorpid Boots"]=8209,["Tough Scorpid Bracers"]=8205,["Tough Scorpid Breastplate"]=8203,["Tough Scorpid Gloves"]=8204,
 ["Tough Scorpid Helm"]=8208,["Tough Scorpid Leggings"]=8206,["Tough Scorpid Shoulders"]=8207,["Toughened Leather Armor"]=2314,["Toughened Leather Gloves"]=4253,["Toxin Study"]=279940,
 ["Tranquil Mechanical Yeti"]=21277,["Tranquil Wristguards"]=279256,["Trapper's Leather Armor"]=252491,["Trapper's Leather Belt"]=252429,["Trapper's Leather Boots"]=252440,["Trapper's Leather Gloves"]=252495,
 ["Trapper's Leather Helm"]=252513,["Trapper's Leather Hood"]=252505,["Trapper's Leather Legguards"]=252517,["Trapper's Leather Pants"]=252501,["Trapper's Leather Tunic"]=252509,["Treads of Conviction"]=273923,
 ["Triage Tea"]=249868,["Troll's Blood Elixir"]=3826,["Tru-Trigger Frag Bomb"]=260809,["Truefaith Gloves"]=7049,["Truefaith Vestments"]=14154,["Truesilver Bar"]=6037,
 ["Truesilver Breastplate"]=7939,["Truesilver Champion"]=7960,["Truesilver Conduit"]=249455,["Truesilver Gauntlets"]=7938,["Truesilver Rod"]=11144,["Truesilver Skeleton Key"]=15871,
 ["Truesilver Transformer"]=18631,["Turtle Scale Bracers"]=8198,["Turtle Scale Breastplate"]=8189,["Turtle Scale Gloves"]=8187,["Turtle Scale Helm"]=8191,["Turtle Scale Leggings"]=8185,
 ["Tuxedo Jacket"]=10036,["Tuxedo Pants"]=10035,["Tuxedo Shirt"]=10034,["Twice-Spiced Raptor Slice"]=250077,["Twisted Nether Wand"]=249144,["Twisting Essence Jar"]=249456,
 ["Ultra-Flash Shadow Reflector"]=18639,["Ultralight Goblin Glider"]=260825,["Ultrasafe Rechargeable Battery"]=260822,["Ultrasafe Transporter: Gadgetzan"]=18986,["Undermine Clam Chowder"]=16766,["Unsanctified Grenade"]=284869,
 ["Unstable Trigger"]=10560,["Venomous Smoothie"]=249871,["Venomspew Cord"]=275605,["Venomspew Footpads"]=275606,["Venomspew Gloves"]=275604,["Veteran's Boots"]=250503,
 ["Veteran's Chain Belt"]=250513,["Veteran's Chain Helm"]=250498,["Veteran's Chain Leggings"]=250493,["Veteran's Chain Shirt"]=250488,["Veteran's Gloves"]=250508,["Veteran's Silvered Chain Helm"]=250528,
 ["Veteran's Silvered Chain Leggings"]=250523,["Veteran's Silvered Chain Shirt"]=250518,["Viridian Dye"]=249431,["Voice Amplification Modulator"]=16009,["Volcanic Breastplate"]=15053,["Volcanic Hammer"]=12792,
 ["Volcanic Leggings"]=15054,["Volcanic Shoulders"]=15055,["Warbear Harness"]=15064,["Warbear Helm"]=252485,["Warbear Woolies"]=15065,["Warden's Leather Belt"]=252460,
 ["Warden's Leather Boots"]=252470,["Warden's Leather Bracers"]=252541,["Warden's Leather Gauntlets"]=252549,["Warden's Leather Gloves"]=252527,["Warden's Leather Shoes"]=252466,["Warden's Leather Shoulders"]=252536,
 ["Warden's Leather Waistguard"]=252475,["Warder's Belt"]=250558,["Warder's Boots"]=20900,["Warder's Gauntlet"]=250568,["Warder's Gloves"]=250553,["Warder's Pauldrons"]=250578,
 ["Warder's Sabatons"]=250563,["Warder's Waistguard"]=250573,["Warder's Wristguards"]=250583,["Westfall Stew"]=733,["Whimsical Waistwrap"]=280306,["Whirring Bronze Gizmo"]=4375,
 ["White Bandit Mask"]=10008,["White Leather Jerkin"]=2311,["White Linen Robe"]=6241,["White Linen Shirt"]=2576,["White Rocket Cluster"]=21577,["White Swashbuckler's Shirt"]=6795,
 ["White Wedding Dress"]=10040,["White Woolen Dress"]=6787,["Whitesoul Helm"]=12633,["Wicked Leather Armor"]=15085,["Wicked Leather Belt"]=15088,["Wicked Leather Boots"]=252479,
 ["Wicked Leather Bracers"]=15084,["Wicked Leather Gauntlets"]=15083,["Wicked Leather Headband"]=15086,["Wicked Leather Pants"]=15087,["Wicked Leather Shoulders"]=252556,["Wicked Mithril Blade"]=7943,
 ["Wicked Smoothie"]=249876,["Wild Leather Armor Kit"]=279258,["Wild Leather Boots"]=8213,["Wild Leather Cloak"]=8215,["Wild Leather Helmet"]=8214,["Wild Leather Leggings"]=8212,
 ["Wild Leather Shoulders"]=8210,["Wild Leather Vest"]=8211,["Wildstalker's Gauntlets"]=273901,["Wildstalker's Greaves"]=273903,["Wildstalker's Legguards"]=273900,["Wildstalker's Spaulders"]=273902,
 ["Wildthorn Mail"]=12624,["Wildvine Potion"]=9144,["Winter Boots"]=34086,["Wisdom of the Timbermaw"]=19047,["Wisdom's Leather Armor"]=252493,["Wisdom's Leather Belt"]=252433,
 ["Wisdom's Leather Boots"]=252444,["Wisdom's Leather Gloves"]=252499,["Wisdom's Leather Helm"]=252515,["Wisdom's Leather Hood"]=252507,["Wisdom's Leather Leggings"]=252519,["Wisdom's Leather Pants"]=252503,
 ["Wisdom's Leather Tunic"]=252511,["Wizard Oil"]=20750,["Wizardweave Leggings"]=14132,["Wizardweave Robe"]=14128,["Wizardweave Turban"]=14130,["Wolfshead Helm"]=8345,
 ["Wool Bandage"]=3530,["Woolen Bag"]=4240,["Woolen Boots"]=2583,["Woolen Cape"]=2584,["Woolen Reagent Bag"]=253667,["Woolen Tourniquet"]=255720,
 ["World Enlarger"]=18660,["Yellow Rocket Cluster"]=21578,
}
-- Each profession's recipes, one per line: name~skill needed~source (T trainer, R recipe item, A automatic)~reagents.
ns.rec = {
 ["Alchemy"]=[==[
Elixir of Minor Force~10~A~765:1,3371:1
Minor Arcane Elixir~10~A~2447:1,3371:1
Elixir of Minor Spirit~15~R~2449:2,2447:1,3371:1
Elixir of Minor Strength~15~T~2449:1,765:1,3371:1
Minor Troll's Blood Elixir~15~T~2447:1,2449:2,3371:1
Mana Well~20~T~2447:1,3371:1
Minor Mageblood Elixir~25~R~785:2,3371:1
Minor Mana Potion~25~T~785:1,2447:1,3371:1
Minor Mender's Potion~30~R~785:2,2453:1,3371:1
Minor Spellblasting Potion~35~R~765:1,2447:1,3371:1
Cerulean Dye~40~T~249399:2,3371:1
Minor Frenzy Potion~40~R~2449:1,765:1,3371:1
Minor Rejuvenation Potion~40~T~785:2,2447:1,3371:1
Sulfuric Acid~40~T~249391:2,3371:1
Minor Cleric's Elixir~45~R~785:2,2453:1,3371:1
Elixir of Minor Agility~50~R~2452:1,765:1,3371:1
Elixir of Minor Fortitude~50~R~2449:2,2447:1,3371:1
Minor Discolored Healing Potion~50~R~3371:1,2447:1,730:1
Elixir of Minor Defense~55~A~765:1,2447:1,3371:1
Rage Potion~60~R~5635:1,2450:1,3371:1
Swiftness Potion~60~R~2452:1,2450:1,3371:1
Elixir of Lesser Spirit~65~R~3355:2,785:1,3371:1
Lesser Mageblood Elixir~75~R~3356:3,3371:1
Blackmouth Oil~80~T~6358:2,3371:1
Lesser Mender's Potion~80~R~3356:2,3357:2,3372:1
Lesser Discolored Healing Potion~85~T~3371:1,2450:1,730:1
Lesser Spellblasting Potion~85~R~785:1,765:2,3371:1
Draught of Water Breathing~90~T~3820:1,6370:2,3371:1
Elixir of Coalesced Regret~90~R~
Elixir of Giant Growth~90~R~6522:1,2449:1,3371:1
Elixir of Wisdom~90~T~785:1,2450:2,3371:1
Lesser Frenzy Potion~90~R~2450:1,2449:2,3371:1
Elixir of Lesser Intellect~95~R~3356:3,3372:1
Lesser Cleric's Elixir~95~R~3356:2,3357:2,3372:1
Draught of Tongues~100~R~2449:2,785:2,3371:1
Holy Protection Potion~100~R~2453:1,2452:1,3371:1
Swim Speed Potion~100~T~2452:1,6370:1,3371:1
Minor Magic Resistance Potion~110~R~785:3,3355:1,3371:1
Elixir of Spirit~115~R~3358:3,3356:1,3372:1
Lesser Arcane Elixir~120~R~3356:4,3372:1
Lesser Mana Potion~120~T~785:1,3820:1,3371:1
Magenta Dye~120~T~249424:2,3372:1
Potion of Poison Cleansing~120~R~1288:1,2453:1,3372:1
Lesser Troll's Blood Elixir~125~T~2453:2,2450:2,3372:1
Elixir of Lesser Defense~130~T~3355:1,3820:1,3372:1
Fire Oil~130~T~6359:2,3371:1
Mender's Potion~130~R~3819:2,4625:2,3372:1
Discolored Healing Potion~135~T~3372:1,2453:1,730:1
Elixir of Intellect~135~R~3358:3,3372:1
Shadow Protection Potion~135~R~3369:1,3356:1,3372:1
Spellblasting Potion~135~R~3355:1,3369:1,3371:1
Elixir of Fire Power~140~T~6371:2,3356:1,3372:1
Elixir of Lesser Agility~140~R~3355:1,2452:1,3372:1
Fermenter~140~R~3372:1,3356:1,2452:1
Frenzy Potion~140~R~3818:2,2450:2,3372:1
Cleric's Elixir~145~R~3819:2,4625:2,3372:1
Elixir of Fortitude~150~R~3821:4,3372:1
Elixir of Ogre Strength~150~R~2449:1,3356:1,3372:1
Elixir of Strength~150~R~3355:3,3821:1,3372:1
Free Action Potion~150~R~6370:2,3820:1,3372:1
Mana Potion~160~T~3820:1,3356:1,3372:1
Elixir of Greater Spirit~165~R~8836:3,8831:2,8925:1
Fire Protection Potion~165~R~4402:1,6371:1,3372:1
Lesser Invisibility Potion~165~T~3818:1,3355:1,3372:1
Shadow Oil~165~R~3818:4,3369:4,3372:1
Draught of Water Walking~175~R~
Elixir of Lesser Fortitude~175~R~3355:1,3821:1,3372:1
Great Rage Potion~175~R~5637:1,3356:1,3372:1
Greater Discolored Healing Potion~175~T~3372:1,3356:1,730:1
Greater Mageblood Elixir~175~R~8839:3,8836:2,8925:1
Greater Mender's Potion~180~R~8836:2,8831:1,8925:1
Troll's Blood Elixir~180~R~3357:1,2453:1,3372:1
Elixir of Agility~185~T~3820:1,3821:1,3372:1
Greater Spellblasting Potion~185~R~3356:2,3818:1,3372:1
Elixir of Frost Power~190~R~3819:2,3358:1,3372:1
Frost Protection Potion~190~R~3819:1,3821:1,3372:1
Greater Frenzy Potion~190~R~4625:3,3818:2,3372:1
Nature Protection Potion~190~R~3357:1,3820:1,3372:1
Draught of Detect Lesser Invisibility~195~R~3358:1,3818:1,3372:1
Elixir of Defense~195~T~3355:1,3821:1,3372:1
Greater Cleric's Elixir~195~R~8836:3,8831:1,8925:1
Potion of Predatory Senses~195~R~3818:2,3821:2,3372:1
Catseye Draught~200~T~3821:1,3818:1,3372:1
Elixir of Greater Fortitude~200~R~8838:4,8925:1
Frost Oil~200~R~3358:4,3819:2,3372:1
Insulating Gniodine~200~R~3372:1,213371:5
Greater Mana Potion~205~T~3358:1,3821:1,3372:1
Oil of Immolation~205~T~4625:1,3821:1,8925:1
Revealing Draught~205~R~3818:3,3358:1,3372:1
Goblin Rocket Fuel~210~R~4625:1,9260:1,3372:1
Magic Resistance Potion~210~R~3358:1,8831:1,8925:1
Draught of Greater Water Breathing~215~T~7972:1,8831:2,8925:1
Lesser Stoneshield Potion~215~R~3858:1,3821:1,3372:1
Viridian Dye~215~T~249274:2,8925:1
Gold Bar~225~R~
Mildly Irradiated Rejuvenation Potion~225~R~213371:1,2456:1,215430:3,8925:5
Philosopher's Stone~225~R~3575:4,9262:1,8831:4,4625:4
Restorative Potion~225~T~7067:1,3821:1,8925:1
Truesilver Bar~225~R~
Wildvine Potion~225~R~8153:1,8831:1,8925:1
Draught of Detect Undead~230~T~8836:1,8925:1
Dreamless Sleep Potion~230~T~8831:3,8925:1
Superior Discolored Healing Potion~230~T~8925:1,8838:1,730:1
Superior Mender's Potion~230~R~8838:2,8836:1,8925:1
Arcane Elixir~235~T~8839:1,3821:1,8925:1
Elixir of Greater Intellect~235~T~8839:1,3358:1,8925:1
Invisibility Potion~235~R~8845:1,8838:1,8925:1
Superior Spellblasting Potion~235~R~3819:2,3358:2,3372:1
Draught of Dream Vision~240~R~8831:3,8925:1
Elixir of Greater Agility~240~T~8838:1,3821:1,8925:1
Gift of Arthas~240~R~8836:1,8839:1,8925:1
Superior Frenzy Potion~240~R~8839:3,4625:2,8925:1
Dragonfire Potion~245~R~13465:2,4625:2,8925:1
Elixir of Greater Strength~245~R~8838:1,8846:1,8925:1
Ghost Dye~245~R~8845:2,4342:1,8925:1
Distilled Firewater~250~R~3819:4,8846:2,3372:1
Draught of Detect Demon~250~T~8846:2,8925:1
Elixir of Holy Power~250~R~6371:3,4625:3,8925:1
Elixir of Shadow Power~250~R~8845:3,8925:1
Elixir of the Phalanx~250~R~13464:2,8838:4,8925:1
Flask of Everlasting Nightmares~250~T~221021:10,220688:1,8925:1
Flask of Restless Dreams~250~T~221021:10,220688:1,8925:1
Jar of Nightmarish Mojo~250~T~221021:5,8925:1,221312:5
Limited Invulnerability Potion~250~R~8839:2,8845:1,8925:1
Major Discolored Healing Potion~250~R~8925:1,13466:1,730:1
Potion of Demon Slaying~250~R~8846:1,8845:1,8925:1
Stonescale Oil~250~T~13422:1,3372:1
Mighty Rage Potion~255~R~8846:3,8925:1
Superior Mana Potion~260~R~8838:2,8839:2,8925:1
Caustic Smog Potion~265~R~8845:2,3369:2,8925:1
Elixir of Greater Defense~265~R~13423:2,8838:1,8925:1
Elixir of the Sages~270~R~13463:1,13466:2,8925:1
Arcanite Bar~275~R~
Elixir of Brute Force~275~R~8846:2,13466:2,8925:1
Elixir of Cunning~275~R~13463:3,8846:2,8925:1
Elixir of Ferocity~275~R~8846:3,8845:1,8925:1
Elixir of Sages~275~R~13463:4,13464:2,18256:1
Elixir of the Whale~275~R~13463:3,8846:1,8925:1
Essence of Air~275~R~
Essence of Earth~275~R~
Essence of Fire~275~R~
Essence of Undeath~275~R~
Essence of Water~275~R~
Greater Dreamless Sleep Potion~275~R~13463:2,13464:1,8925:1
Legionite Bar~275~R~
Living Essence~275~R~
Mageblood Elixir~275~R~13463:1,13466:2,8925:1
Potion of Venomous Blood~275~R~8846:3,13466:2,8925:1
Elixir of the Mongoose~280~R~13465:2,13466:2,8925:1
Elixir of the Owl~280~R~13463:4,13465:2,18256:1
Greater Stoneshield Potion~280~R~13423:3,10620:1,8925:1
Major Mender's Potion~280~R~13463:3,8838:1,18256:1
Potion of Beast Slaying~280~R~8846:2,13466:2,18256:1
Potion of Elemental Purging~280~R~4625:2,3819:2,8925:1
Elixir of Nature Power~285~R~13464:4,8838:2,8925:1
Elixir of Wicked Regeneration~285~R~13464:3,13463:2,8925:1
Greater Arcane Elixir~285~R~13463:3,13465:1,8925:1
Living Action Potion~285~R~13467:2,13465:2,10286:2,8925:1
Major Spellblasting Potion~285~R~13463:2,13465:1,18256:1
Purification Potion~285~R~13467:2,13466:2,8925:1
Greater Arcane Protection Potion~290~R~11176:1,13463:1,8925:1
Greater Fire Protection Potion~290~R~7068:1,13463:1,8925:1
Greater Frost Protection Potion~290~R~7070:1,13463:1,8925:1
Greater Holy Protection Potion~290~R~
Greater Nature Protection Potion~290~R~7067:1,13463:1,8925:1
Greater Shadow Protection Potion~290~R~3824:1,13463:1,8925:1
Major Frenzy Potion~290~R~13466:3,8839:2,18256:1
Major Troll's Blood Elixir~290~R~8846:1,13466:2,8925:1
Major Mana Potion~295~R~13463:3,13467:2,8925:1
Alchemist's Stone~300~R~7078:8,7076:8,7082:8,7080:8,12803:8,9262:2,13468:4
Alchemy Laboratory~300~R~273125:1,8925:1,13463:2
Elemental Fire~300~R~
Elixir of Alacrity~300~R~
Elixir of the Grizzly~300~R~8846:3,8839:1,8925:1
Elixir of the Honey Badger~300~R~
Elixir of the Ironside~300~R~
Elixir of the Mage-Lord~300~R~
Flask of Ancient Knowledge~300~R~
Flask of Chromatic Resistance~300~R~13467:30,13465:10,13468:1,8925:1
Flask of Distilled Wisdom~300~R~13463:30,13467:10,13468:1,8925:1
Flask of Madness~300~R~
Flask of Natural Accuracy~300~R~248822:1,248821:12,13464:9,18256:1
Flask of Natural Aggression~300~R~248822:1,248821:18,13465:6,18256:1
Flask of Natural Precision~300~R~248822:1,248823:12,13463:9,18256:1
Flask of Natural Swiftness~300~R~248822:1,248823:18,13467:6,18256:1
Flask of Petrification~300~R~13423:30,13465:10,13468:1,8925:1
Flask of Supreme Power~300~R~13463:30,13465:10,13468:1,8925:1
Flask of Unyielding Sorrow~300~R~
Flask of the Old Gods~300~R~
Flask of the Titans~300~R~8846:30,13423:10,13468:1,8925:1
Major Rejuvenation Potion~300~R~10286:1,13464:4,13463:4,18256:1
Refined Scale of Onyxia~300~T~
Gurubashi Mojo Madness~315~T~12938:1,19943:1,12804:6,13468:1]==],
 ["Blacksmithing"]=[==[
Copper Rod~10~A~2840:1
Copper Chain Pants~15~T~2840:4
Copper Mace~15~T~2840:6,2880:1,2589:2
Rough Copper Vest~15~A~2840:4
Rough Sharpening Stone~15~A~2835:1
Rough Weightstone~15~A~2835:1
Copper Axe~20~T~2840:6,2880:1,2589:2
Copper Bracers~20~A~2840:2
Copper Chain Boots~20~T~2840:8
Sharpening Wheel~20~T~2835:1,2840:1
Copper Claymore~25~T~2840:10,2880:2,3470:1,2318:1
Copper Dagger~25~T~2840:6,2880:1,3470:1,2318:1
Copper Shortsword~25~T~2840:6,2880:1,2589:2
Rough Grinding Stone~25~T~2835:2
Copper Battle Axe~30~T~2840:12,2880:2,774:2,3470:2,2318:2
Copper Chain Belt~30~T~2840:6
Copper Chain Vest~30~R~2840:8,774:1,3470:2
Gemmed Copper Boots~35~R~2840:2,818:2,774:2,2318:4
Gemmed Copper Gauntlets~35~R~2840:8,818:1,774:1
Glowing Copper Boots~35~R~2840:2,10938:4,2318:2
Runed Copper Gauntlets~35~T~2840:8,3470:2
Runed Copper Pants~35~T~2840:8,2320:3,3470:3
Strange Copper Boots~35~R~2840:2,10940:4,2318:2
Coarse Sharpening Stone~40~T~2836:1
Coarse Weightstone~40~T~2836:1
Heavy Copper Maul~40~T~2840:12,2880:2,2318:2
Acolyte's Chain Belt~45~R~2840:12,3470:4,249427:2,10940:2
Crusader's Chain Belt~45~R~2840:12,3470:4,249427:2,10938:2
Guard's Chain Belt~45~R~2840:12,3470:4,249427:2,1210:2
Protector's Chain Belt~45~R~2840:12,3470:4,249427:2,818:2
Runed Copper Belt~45~T~2840:10
Thick War Axe~45~T~2840:10,2880:2,2842:2,3470:2,2318:2
Veteran's Chain Belt~45~R~2840:12,3470:4,249427:2,5498:2
Azure Skyforged Chain~50~R~2840:6
Azure Skyforged Wristguards~50~R~2840:5
Cloudy Skyforged Chain~50~R~2840:6
Cloudy Skyforged Wristguards~50~R~2840:5
Coarse Grinding Stone~50~T~2836:2
Rough Copper Chain Boots~50~R~2840:9
Azure Skyforged Gauntlets~55~R~2840:7
Azure Skyforged Greaves~55~R~2840:7
Cloudy Skyforged Gauntlets~55~R~2840:7
Cloudy Skyforged Greaves~55~R~2840:7
Azure Skyforged Chainmail~60~R~2840:8,2880:1
Azure Skyforged Legguards~60~R~2840:8,2880:1
Cloudy Skyforged Chainmail~60~R~2840:8,2880:1
Cloudy Skyforged Legguards~60~R~2840:8,2880:1
Ironforge Chain~60~R~
Runed Copper Bracers~65~T~2840:10,3470:3
Heavy Copper Broadsword~70~T~2840:14,2880:2,818:2,2319:2
Rough Bronze Boots~70~T~2841:6,3470:6
Silver Rod~75~T~2842:1,3470:2
Silver Skeleton Key~75~T~2842:1,3470:1
Acolyte's Chain Shirt~80~R~2841:4,3470:2,10940:2
Acolyte's Gloves~80~R~2841:10,3470:4,249410:2,10940:3
Big Bronze Knife~80~T~2841:6,2880:4,3470:2,818:1,2319:1
Blackfathom Sharpening Stone~80~R~
Brass Knuckles~80~R~2841:6,2880:4,3470:2,1210:2,2319:1
Crusader's Chain Shirt~80~R~2841:4,3470:2,10938:2
Crusader's Gloves~80~R~2841:10,3470:4,249410:2,10938:3
Guard's Chain Shirt~80~R~2841:4,3470:2,1210:2
Guard's Gloves~80~R~2841:10,3470:4,249410:2,1210:3
Protector's Chain Shirt~80~R~2841:4,3470:2,818:2
Protector's Gloves~80~R~2841:10,3470:4,249410:2,818:3
Rough Bronze Cuirass~80~T~2841:7
Rough Bronze Leggings~80~T~2841:6
Runed Copper Breastplate~80~R~2840:12,1210:1,3470:2
Veteran's Chain Shirt~80~R~2841:4,3470:2,5498:2
Veteran's Gloves~80~R~2841:10,3470:4,249410:2,5498:3
Acolyte's Boots~85~R~2841:12,3478:2,249427:4,10940:5
Bronze Mace~85~T~2841:6,2880:4,2319:1
Crusader's Boots~85~R~2841:12,3478:2,249427:4,10938:5
Guard's Boots~85~R~2841:12,3478:2,249427:4,1210:5
Pearl-handled Dagger~85~T~2841:6,3466:1,5498:2,3478:2
Protector's Boots~85~R~2841:12,3478:2,249427:4,818:5
Rough Bronze Shoulders~85~T~2841:5,1210:1,3478:1
Veteran's Boots~85~R~2841:12,3478:2,249427:4,5498:5
Bronze Axe~90~T~2841:7,2880:4,2319:1
Acolyte's Chain Leggings~95~R~2841:6,3478:2,10940:4
Acolyte's Silvered Chain Helm~95~R~2841:15,3478:6,2842:4,249427:4,10940:6
Bronze Dory~95~R~2841:8,2880:4,2319:1
Bronze Shortsword~95~T~2841:5,2880:4,2319:2
Crusader's Chain Leggings~95~R~2841:6,3478:2,10938:4
Crusader's Silvered Chain Helm~95~R~2841:15,3478:6,2842:4,249427:4,10938:6
Guard's Chain Leggings~95~R~2841:6,3478:2,1210:4
Guard's Silvered Chain Helm~95~R~2841:15,3478:6,2842:4,249427:4,1210:6
Patterned Bronze Bracers~95~T~2841:5,3478:2
Protector's Chain Leggings~95~R~2841:6,3478:2,818:4
Protector's Silvered Chain Helm~95~R~2841:15,3478:6,2842:4,249427:4,818:6
Rough Bronze Bracers~95~R~
Veteran's Chain Leggings~95~R~2841:6,3478:2,5498:4
Veteran's Silvered Chain Helm~95~R~2841:15,3478:6,2842:4,249427:4,5498:6
Bronze Warhammer~100~T~2841:8,3466:1,2319:1
Heavy Grinding Stone~100~T~2838:3
Heavy Sharpening Stone~100~T~2838:1
Heavy Weightstone~100~T~2838:1
Ironforge Breastplate~100~R~2840:16,818:2,3470:3
Sterling Silver Boots~100~R~2842:6,2840:2,3478:2,2319:2
Bronze Greatsword~105~T~2841:12,3466:2,2319:2
Heavy Bronze Mace~105~T~2841:8,3466:1,1206:1,1210:1,3478:2,2319:2
Silvered Bronze Boots~105~T~2841:6,2842:1,3478:2
Sterling Silver Gauntlet~105~R~2842:6,2840:2,3478:2
Sterling Silver Leggings~105~R~2842:10,2840:3,3478:3
Acolyte's Silvered Chain Shirt~110~R~2841:20,3478:6,2842:5,249427:6,10940:8
Bronze Battle Axe~110~T~2841:14,3466:1,2319:2
Cracked Blacksmith Hammer~110~R~2841:18,2842:2,818:1
Crusader's Silvered Chain Shirt~110~R~2841:20,3478:6,2842:5,249427:6,10938:8
Guard's Silvered Chain Shirt~110~R~2841:20,3478:6,2842:5,249427:6,1210:8
Protector's Silvered Chain Shirt~110~R~2841:20,3478:6,2842:5,249427:6,818:8
Silvered Bronze Gauntlets~110~T~2841:8,2842:1,3478:2
Sterling Silver Shoulders~110~R~2842:6,2840:2,3478:2
Veteran's Silvered Chain Shirt~110~R~2841:20,3478:6,2842:5,249427:6,5498:8
Ironforge Gauntlets~120~R~
Shining Silver Breastplate~120~T~2841:20,1206:2,1705:2,5500:2,2842:4
Acolyte's Chain Helm~125~R~2841:8,3478:2,10940:6
Acolyte's Silvered Chain Leggings~125~R~2841:20,3478:8,2842:6,249427:6,10940:8
Crusader's Chain Helm~125~R~2841:8,3478:2,10938:6
Crusader's Silvered Chain Leggings~125~R~2841:20,3478:8,2842:6,249427:6,10938:8
Deadly Bronze Poniard~125~R~2841:4,3466:1,2459:1,1210:2,3478:2,2319:2
Golden Rod~125~T~3577:1,3478:2
Golden Skeleton Key~125~T~3577:1,3486:1
Guard's Chain Helm~125~R~2841:8,3478:2,1210:6
Guard's Silvered Chain Leggings~125~R~2841:20,3478:8,2842:6,249427:6,1210:8
Iron Buckle~125~T~3575:1
Protector's Chain Helm~125~R~2841:8,3478:2,818:6
Protector's Silvered Chain Leggings~125~R~2841:20,3478:8,2842:6,249427:6,818:8
Silvered Bronze Shoulders~125~R~2841:8,2842:2,3478:2
Sterling Silver Breastplate~125~R~2842:12,2840:4,3478:3
Veteran's Chain Helm~125~R~2841:8,3478:2,5498:6
Veteran's Silvered Chain Leggings~125~R~2841:20,3478:8,2842:6,249427:6,5498:8
Green Iron Leggings~130~T~3575:8,3486:1,2605:1
Iron Fists~130~R~3575:6,3466:2,3486:1,2842:2,4234:2
Silvered Bronze Breastplate~130~R~2841:10,2842:2,3478:2,1705:1
Anvil~140~R~2841:5,3478:2,2319:2
Green Iron Bracers~140~T~3575:6,2605:1
Iridescent Hammer~140~R~2841:10,3466:1,5500:1,3478:2,2319:2
Green Iron Boots~145~R~3575:4,1705:2,3478:2,2605:1
Green Iron Helm~145~T~3575:12,3864:1,2605:1
Hard Gold Cuirass~145~R~3577:12,3859:3,3486:2
Mighty Iron Hammer~145~R~3575:6,3466:2,3391:1,1705:2,3478:2,2319:2
Green Iron Gauntlets~150~R~3575:4,5498:2,3478:2,2605:1
Hard Gold Boots~150~R~3577:6,3859:2,3486:2,4234:2
Iron Shield Spike~150~R~3575:6,3478:4
Justicar's Belt~150~R~3575:6,3486:2,7079:2
Mantle of the Second War~150~R~
Officer's Belt~150~R~3575:6,3486:2,1529:2
Prefect's Belt~150~R~3575:6,3486:2,13926:2
Sentinel's Belt~150~R~3575:6,3486:2,8831:2
Warder's Belt~150~R~3575:6,3486:2,7971:2
Glinting Steel Dagger~155~T~3859:10,3466:2,1206:1,7067:1,4234:1
Green Iron Hauberk~155~T~3575:20,3486:4,1529:2,1206:2,4255:1
Silvered Bronze Leggings~155~R~2841:12,2842:4,3478:2
Solid Iron Maul~155~R~3575:8,3466:2,3486:1,2842:4,4234:2
Barbaric Iron Breastplate~160~R~3575:20,3486:4
Barbaric Iron Shoulders~160~R~3575:8,5635:4,1210:2,3486:2
Golden Scale Bracers~160~T~3859:5,3486:2
Green Iron Shoulders~160~R~3575:7,3486:1,2605:1
Hard Gold Bracers~160~R~3577:6,3859:1,3486:2
Hardened Iron Shortsword~160~R~3575:6,3466:2,3486:1,1705:2,4234:3
Steel Spear~160~R~3859:10,3466:2,7069:1,3486:4,4234:1
Hard Gold Leggings~165~R~3577:10,3859:2,3486:2
Iron Counterweight~165~R~3575:4,3478:2,1705:1
Iron Morningstar~165~R~3575:14,3466:2,3486:2,3864:4,4234:2
Golden Iron Destroyer~170~R~3575:10,3577:4,1705:2,3466:2,4234:2,3486:2
Golden Scale Leggings~170~R~3575:10,3577:2,3486:1
Hard Gold Coif~170~R~3577:10,3859:2,3486:2
Azure Skyforged Helm~175~R~3575:18,3486:5,7909:1
Azure Skyforged Pauldrons~175~R~3575:14,3486:3,7909:1
Barbaric Iron Helm~175~R~3575:10,5637:2,5635:2
Cloudy Skyforged Helm~175~R~3575:18,3486:5,5498:1
Cloudy Skyforged Pauldrons~175~R~3575:14,3486:3,5498:1
Golden Scale Shoulders~175~R~3859:6,3577:2,3486:1
Hard Gold Gauntlet~175~R~3577:8,3859:2,3486:2
Hard Gold Pauldrons~175~R~3577:8,3859:2,3486:2
Jade Serpentblade~175~R~3575:8,3466:2,3486:2,1529:2,4234:3
Justicar's Gauntlet~175~R~3859:10,3486:4,249432:4,249410:2,7079:4
Officer's Gauntlet~175~R~3859:10,3486:4,249432:4,249410:2,1529:4
Prefect's Gauntlet~175~R~3859:10,3486:4,249432:4,249410:2,13926:4
Sentinel's Gauntlet~175~R~3859:10,3486:4,249432:4,249410:2,8831:4
Shifting Silver Breastplate~175~T~2870:1,211422:1
Solid Grinding Stone~175~T~7912:4
Solid Sharpening Stone~175~T~7912:1
Solid Weightstone~175~T~7912:1
Steel Breastplate~175~T~3859:16,3486:3
Truesilver Rod~175~T~6037:1,3486:1
Truesilver Skeleton Key~175~T~6037:1,7966:1
Warder's Gauntlet~175~R~3859:10,3486:4,249432:4,249410:2,7971:4
Barbaric Iron Boots~180~R~3575:12,5637:4,818:4,3486:2
Heavy Mithril Gauntlet~180~T~3860:6,4338:4
Heavy Mithril Shoulder~180~T~3860:8,4234:6
Mithril Shortsword~180~R~3860:8,3466:2,3486:2,1705:4,4234:2
Moonsteel Broadsword~180~R~3859:8,3466:2,3486:2,1705:3,4234:3
Barbaric Iron Gloves~185~R~3575:14,3486:3,5637:2
Heavy Mithril Axe~185~T~3860:12,3864:2,7966:1,4234:4
Massive Iron Axe~185~R~3575:14,3466:2,3486:2,3577:4,4234:2
Mithril Plate Pants~185~T~3860:12
Polished Steel Boots~185~R~3859:8,3864:1,1705:1,3486:2
Edge of Winter~190~R~3859:10,3829:1,7070:2,7069:2,4234:2
Golden Scale Coif~190~R~3859:8,3577:2,3486:2
Mithril Warhammer~190~R~3860:12,3864:2,7966:1,4234:4
Searing Golden Blade~190~R~3859:10,3577:4,7068:2,4234:2
Steel Plate Helm~190~T~3859:14,7966:1
Steel Weapon Chain~190~R~3859:8,3486:2,4234:4
Golden Scale Cuirass~195~R~3859:12,3577:2,3486:4,1529:2
Mithril Blacksmith Hammer~195~R~3860:10,3577:2,7910:1
Mithril Claws~195~R~3860:8,1529:1,7966:1,4234:2
Mithril Claymore~195~R~3860:16,3577:6,7966:2,4234:4
Mithril Plate Gloves~195~R~
Ornate Mithril Pants~195~R~3860:12,6037:1,7966:1,7909:1
Shining Mithril Breastplate~195~R~3860:8,6037:9,3486:2,7971:2
Shining Mithril Pauldrons~195~R~3860:6,6037:3,3486:2,4304:2
Frost Tiger Blade~200~R~3859:8,3466:2,3486:2,1529:2,3829:1,4234:4
Golden Scale Boots~200~R~3859:10,3577:4,3486:4,3864:1
Inlaid Mithril Cylinder~200~R~3860:5,3577:1,6037:1
Justicar's Boots~200~R~3859:4,3486:4,7079:4
Low-Background Truesilver Plates~200~R~6037:1,213373:5
Officer's Boots~200~R~3859:4,3486:4,1529:4
Prefect's Boots~200~R~3859:4,3486:4,13926:4
Sentinel's Boots~200~R~3859:4,3486:4,8831:4
Shadow Crescent Axe~200~R~3859:10,3466:2,3486:3,3864:2,3824:1,4234:3
Shining Mithril Boots~200~R~3860:4,6037:3,3486:2,4304:4
Truesilver Gauntlets~200~T~3860:10,6037:8,7909:3,3864:3,5966:1,7966:2
Warder's Boots~200~R~3859:4,3486:4,7971:4
Big Black Mace~205~T~3860:16,7971:1,1210:4,7966:1,4304:2
Golden Scale Gauntlets~205~R~3859:10,3577:4,3486:4,3864:1
Heavy Mithril Breastplate~205~T~3860:16
Mithril Coif~205~T~3860:10,4338:6
Heavy Mithril Boots~210~T~3860:14,4304:4
Heavy Mithril Pants~210~R~3860:10,1705:2
Justicar's Pauldrons~210~R~3860:20,7966:2,249432:6,249410:4,7079:8,11139:1
Mithril Stiletto~210~R~3860:16,1210:6,3577:2,7966:1
Officer's Pauldrons~210~R~3860:20,7966:2,249432:6,249410:4,1529:8,11139:1
Prefect's Pauldrons~210~R~3860:20,7966:2,249432:6,249410:4,13926:8,11139:1
Sentinel's Pauldrons~210~R~3860:20,7966:2,249432:6,249410:4,8831:8,11139:1
Warder's Pauldrons~210~R~3860:20,7966:2,249432:6,249410:4,7971:8,11139:1
Charged Mithril Battleaxe~215~R~3860:20,7082:6,7966:4,4234:4
Mithril Plate Bracers~215~R~3860:8,3864:2
Mithril Shield Spike~215~R~3860:4,6037:2,7966:4
Shining Mithril Helm~215~R~3860:8,6037:9,3486:2,7075:1
Blue Glittering Axe~220~R~3860:16,7909:2,7966:1,4304:4
Ornate Mithril Gloves~220~R~3860:10,4338:6,6037:1,7966:1
Shining Mithril Gauntlet~220~R~3860:5,6037:6,3486:2,7909:2
Shining Mithril Pants~220~R~3860:6,6037:9,3486:2,7075:1
Truesilver Breastplate~220~T~3860:12,6037:24,7910:4,7971:4,7966:2
Dense Grinding Stone~225~T~12365:4
Dense Sharpening Stone~225~T~12365:1
Dense Weightstone~225~T~12365:1
Justicar's Wristguards~225~R~12359:16,7966:2,249432:6,249410:4,7079:6,11139:1
Officer's Wristguards~225~R~12359:16,7966:2,249432:6,249410:4,1529:6,11139:1
Ornate Mithril Shoulders~225~R~3860:12,6037:1,4304:6
Prefect's Wristguards~225~R~12359:16,7966:2,249432:6,249410:4,13926:6,11139:1
Reflective Truesilver Braincage~225~R~3860:25,213376:4,213379:2,213383:1
Sentinel's Wristguards~225~R~12359:16,7966:2,249432:6,249410:4,8831:6,11139:1
Tempered Interference-Negating Helmet~225~R~3860:25,213376:4,213379:1,213369:2
Warder's Wristguards~225~R~12359:16,7966:2,249432:6,249410:4,7971:6,11139:1
Wicked Mithril Blade~225~R~3860:14,6037:4,7966:1,4304:2
Orcish War Leggings~230~T~3860:12,7067:1
Mithril Plate Shoulders~235~R~3860:14,4304:4,3864:4
Mithril Spurs~235~R~3860:4,7966:3
The Shatterer~235~T~3860:24,7075:4,6037:6,3864:5,1529:5,7966:4,4304:4
Blessed Plate Boots~240~R~12359:24,12361:1,8170:6
Blessed Plate Pauldrons~240~R~12359:20,12361:1,8170:6
Dazzling Mithril Rapier~240~R~3860:14,7909:1,1705:2,1206:2,7966:1,4338:2
Justicar's Sabatons~240~R~12359:20,7966:3,249432:4,249410:4,7079:6,249427:4
Officer's Sabatons~240~R~12359:20,7966:3,249432:4,249410:4,1529:6,249427:4
Ornate Mithril Breastplate~240~R~3860:16,6037:6,7077:1,7966:1
Prefect's Sabatons~240~R~12359:20,7966:3,249432:4,249410:4,13926:6,249427:4
Sentinel's Sabatons~240~R~12359:20,7966:3,249432:4,249410:4,8831:6,249427:4
Thorium Greatsword~240~T~
Warder's Sabatons~240~R~12359:20,7966:3,249432:4,249410:4,7971:6,249427:4
Blessed Plate Gauntlet~245~R~12359:20,12361:2
Heavy Mithril Helm~245~R~3860:14,7909:1
Ornate Mithril Boots~245~R~3860:14,6037:2,4304:4,7966:1,7909:1
Ornate Mithril Helm~245~R~3860:16,6037:2,7971:1,7966:1
Phantom Blade~245~T~3860:28,7081:6,6037:8,3823:2,7909:6,7966:4,4304:2
Runed Mithril Hammer~245~R~3860:18,7075:2,7966:1,4304:4
Arcanite Rod~250~T~12360:3,12644:1
Arcanite Skeleton Key~250~T~12360:1,12644:1
Baleful Pauldrons~250~T~221021:10,220688:1
Bleakwood Hew~250~T~
Blight~250~T~3860:28,7972:10,6037:10,7966:6,4304:6
Fearmonger's Shoulderguards~250~T~221021:10,220688:1
Inlaid Thorium Hammer~250~T~
Justicar's Gloves~250~R~12359:8,7966:4,7079:4
Justicar's Waistguard~250~R~12359:24,7966:4,249432:6,249410:6,7079:10
Officer's Gloves~250~R~12359:8,7966:4,1529:4
Officer's Waistguard~250~R~12359:24,7966:4,249432:6,249410:6,1529:10
Prefect's Gloves~250~R~12359:8,7966:4,13926:4
Prefect's Waistguard~250~R~12359:24,7966:4,249432:6,249410:6,13926:10
Scarlet Soldier's Protectors~250~R~
Scarlet Soldier's Waistguard~250~R~12811:1,12359:20
Sentinel's Gloves~250~R~12359:8,7966:4,8831:4
Sentinel's Waistguard~250~R~12359:24,7966:4,249432:6,249410:6,8831:10
Shoulderplates of Dread~250~T~221021:10,220688:1
Thorium Armor~250~R~12359:16,12361:1,11188:4
Thorium Belt~250~R~12359:12,11186:4
Thorium Cestus~250~R~12359:20,251291:8,7082:4,249726:10,12644:1
Thorium Greatmace~250~R~12359:30,251291:4,7076:4,249726:10,12644:2
Warder's Gloves~250~R~12359:8,7966:4,7971:4
Warder's Waistguard~250~R~12359:24,7966:4,249432:6,249410:6,7971:10
Blessed Plate Bracers~255~R~12359:16,12361:1
Ebon Shiv~255~R~3860:12,6037:6,7910:2,7966:1,4304:2
Imperial Plate Gauntlets~255~R~12359:24,7910:1
Thorium Bracers~255~R~12359:12,11184:4
Radiant Belt~260~R~12359:10,7077:2
Scarlet Soldier's Grips~260~R~12811:1,12359:20
Scarlet Soldier's Stompers~260~R~12811:1,12359:20
Thorium Poleaxe~260~R~12359:20,251291:6,249726:10,12803:4,8170:4
Truesilver Champion~260~T~3860:30,6037:16,7910:6,7081:4,7966:8,4304:6
Dark Iron Pulverizer~265~R~11371:18,7077:4
Imperial Plate Belt~265~R~12359:22,8170:6,7909:1
Imperial Plate Shoulders~265~R~12359:24,8170:6,3864:2
Rune Edge~265~R~
Arcanite Blacksmith Hammer~270~R~11371:4,12360:1,12361:1
Blessed Plate Belt~270~R~12359:18,12361:1,7071:1,8170:6
Blessed Plate Leggings~270~R~12359:40,12361:2
Bold Dirk~270~R~12359:30,7082:4,249726:10,8170:4
Dark Iron Mail~270~R~11371:10,7077:2
Imperial Plate Bracers~270~R~12359:20,7910:1
Radiant Breastplate~270~R~12359:18,7077:2,7910:1
Scarlet Soldier's Legplates~270~R~12938:1,12811:1,12359:20
Blessed Plate Helm~275~R~12359:30,12361:2
Dark Iron Sunderer~275~R~11371:26,7077:4
Dawn's Edge~275~R~12359:30,12655:4,7910:4,12361:4,12644:2,8170:4
Ornate Thorium Handaxe~275~R~12359:20,12799:2,12644:2,8170:4
Thorium Shield Spike~275~R~12359:4,12644:4,7076:2
Blazing Rapier~280~R~12655:10,7078:4,7077:4,12800:2,12644:2
Blessed Plate Chest~280~R~12359:36,12361:2
Dark Iron Shoulders~280~R~11371:6,7077:1
Enchanted Battlehammer~280~R~12359:20,12655:6,12364:2,12804:4,8170:4
Finely-Enchanted Battlehammer~280~R~
Huge Thorium Battleaxe~280~R~12359:40,12644:6,8170:6
Scarlet Soldier's Chestplate~280~R~
Scarlet Soldier's Helmet~280~R~
Scarlet Soldier's Spaulders~280~R~
Thorium Boots~280~R~12359:20,8170:8,11185:4
Thorium Helm~280~R~12359:24,7910:1,11188:4
Clutchlord's Grips~285~R~12359:7,12655:5,7076:3,18567:1
Dark Iron Plate~285~R~11371:20,7077:8
Demon Forged Breastplate~285~R~12359:40,12662:10,12361:4,7910:4
Goregasher Grips~285~R~12359:7,12655:5,7078:3,18567:1
Radiant Gloves~285~R~12359:18,7077:4
Serenity~285~R~12655:6,12360:2,12804:4,12799:2,12361:2,12364:1
Tempered Dark Iron Plate~285~R~
Clutchlord's Support~290~R~12359:11,12655:5,7076:3,18567:1
Corruption~290~R~12359:40,12360:2,12662:16,12808:8,12361:2,12644:2,8170:4
Dawnbringer Shoulders~290~R~12359:20,12360:4,12364:2,7080:2
Fiery Plate Gauntlets~290~R~12359:20,12655:6,7078:2,7910:4
Fiery Plate Gauntlets of the Hidden Technique~290~R~
Girdle of the Dawn~290~R~12359:8,6037:6,12811:1
Goregasher Support~290~R~12359:11,12655:5,7078:3,18567:1
Radiant Boots~290~R~12359:14,7077:4
Tranquility~290~T~
Volcanic Hammer~290~R~12359:30,7077:4,7910:4,8170:4
Clutchlord's Stompers~295~R~12359:9,12655:5,7076:3,18567:1
Dark Iron Bracers~295~R~11371:4,17010:2,17011:2
Desecration~295~T~
Fiery Chain Girdle~295~R~11371:6,17010:3,17011:3
Goregasher Stompers~295~R~12359:9,12655:5,7078:3,18567:1
Imperial Plate Boots~295~R~12359:34,7910:1,7909:1
Imperial Plate Helm~295~R~12359:34,7910:2
Obsidian Grinding Stone~295~R~
Radiant Circlet~295~R~12359:18,7077:4
Tempest Gauntlets~295~R~
Annihilator~300~R~12359:40,12360:12,12808:10,12364:8,12644:2,12810:4
Arcanite Champion~300~R~12360:15,12800:8,12811:1,12799:4,12810:8,12644:2
Arcanite Reaper~300~R~12360:20,12810:6,12644:2
Azerothium Legplates~300~R~274030:3,251290:1,251291:18
Bagh Nakh~300~R~251290:10,251291:10,249726:10,7910:4,12361:4
Black Amnesty~300~R~17011:3,17010:6,12360:12,11382:1,11371:4
Black Grasp of the Destroyer~300~R~22203:8,22202:24,12810:8,13512:1
Blackfury~300~R~17011:5,17010:2,12360:16,11371:6
Blackguard~300~R~17011:6,17010:6,12360:10,11371:6,12809:12
Bloodsoul Breastplate~300~R~12359:20,19774:10,19726:2,7910:2
Bloodsoul Gauntlets~300~R~12359:12,19774:6,19726:2,12810:4
Bloodsoul Shoulders~300~R~12359:16,19774:8,19726:2,7910:1
Breastplate of Salvation~300~R~251290:12,12359:80,12361:10,12800:4,12662:20
Champion's Legplates~300~R~251290:12,251291:20,7082:10,13512:2
Dark Iron Boots~300~R~17011:3,17010:3,17012:4,11371:6
Dark Iron Destroyer~300~R~11371:18,17011:12,11382:2,12810:2
Dark Iron Gauntlets~300~R~17011:3,17010:5,17012:4,11371:4,11382:2
Dark Iron Helm~300~R~17011:4,17010:2,11371:4
Dark Iron Leggings~300~R~11371:16,17010:4,17011:6
Dark Iron Reaver~300~R~11371:16,17010:12,11382:2,12810:2
Darkrune Breastplate~300~R~12359:20,20520:10,6037:10
Darkrune Gauntlets~300~R~12359:12,20520:6,6037:6,12810:2
Darkrune Helm~300~R~12359:16,20520:8,6037:8,11754:1
Darksoul Breastplate~300~R~12359:20,19774:14,12799:2
Darksoul Leggings~300~R~12359:18,19774:12,12799:2
Darksoul Shoulders~300~R~12359:16,19774:10,12799:1
Deadly Heartseeker~300~R~
Depleted Thorium Sabatons~300~R~274030:2,251290:1,251291:12
Dreamscale Visor~300~R~
Ebon Hand~300~R~17011:4,17010:7,12360:12,11371:8,12800:4
Elemental Sharpening Stone~300~R~7067:2,12365:3
Enchanted Thorium Breastplate~300~R~12360:8,12655:24,7076:4,7080:4,12364:2,12800:2
Enchanted Thorium Helm~300~R~12360:6,12655:16,7076:6,12799:2,12800:1
Enchanted Thorium Leggings~300~R~12360:10,12655:20,7080:6,12361:2,12364:1
Enriched Thorium Breastplate~300~R~251290:8,251291:24,7082:4,7078:4,249726:4
Enriched Thorium Helm~300~R~251290:6,251291:16,7078:6,249726:3
Enriched Thorium Leggings~300~R~251290:10,251291:20,7082:6,249726:3
Evergreen Shield~300~R~274030:2,251290:1,251291:10
Fiery Chain Shoulders~300~R~11371:16,17010:4,17011:5
Forest Defender's Axe~300~R~274030:4,251290:1,251291:20
Frostguard~300~R~12360:18,12361:8,12800:8,7080:4,12644:2,12810:4
Gauntlets of Glory~300~R~274030:3,12360:2,251291:12,18567:1
Gloves of the Dawn~300~R~12360:2,6037:10,12811:1
Greaves of Glory~300~R~274030:3,12360:2,251291:12,18567:1
Greenhammer~300~R~274030:2,251290:1,251291:16
Hammer of the Titans~300~R~12359:50,12360:15,12809:4,12810:6,7076:10
Handguards of Glory~300~R~274030:3,12360:2,251291:12,18567:1
Hardened Frostguard~300~R~
Heartseeker~300~R~12360:10,12655:10,12810:2,7910:6,12800:6,12799:6,12644:4
Heavy Obsidian Belt~300~R~22202:14,12655:4,7076:2
Heavy Thorium Gauntlets~300~R~274030:2,251290:1,251291:14
Icebane Bracers~300~T~22682:4,12359:12,12360:2,7080:2
Icebane Breastplate~300~T~22682:7,12359:16,12360:2,7080:4
Icebane Gauntlets~300~T~22682:5,12359:12,12360:2,7080:2
Imperial Plate Chest~300~R~12359:40,7910:2
Imperial Plate Leggings~300~R~12359:44,7910:2
Invincible Mail~300~R~
Ironvine Belt~300~R~12655:6,12803:2
Ironvine Breastplate~300~R~12655:12,19726:2,12360:2,12803:2
Ironvine Gloves~300~R~12655:8,19726:1,12803:2
Ironwood Blade~300~R~274030:2,251290:1,251291:14
Jagged Obsidian Shield~300~R~22203:8,22202:24,12655:8,7076:4
Justice Epaulets~300~R~274030:3,12360:2,251291:12,18567:1
Justice Gauntlets~300~R~274030:3,12360:2,251291:12,18567:1
Justice Gloves~300~R~274030:3,12360:2,251291:12,18567:1
Justice Greaves~300~R~274030:3,12360:2,251291:12,18567:1
Justice Handguards~300~R~274030:3,12360:2,251291:12,18567:1
Justice Leggings~300~R~274030:5,12360:4,251291:18,18567:1
Justice Legguards~300~R~274030:5,12360:4,251291:18,18567:1
Justice Legplates~300~R~274030:5,12360:4,251291:18,18567:1
Justice Pauldrons~300~R~274030:3,12360:2,251291:12,18567:1
Justice Sabatons~300~R~274030:3,12360:2,251291:12,18567:1
Justice Spaulders~300~R~274030:3,12360:2,251291:12,18567:1
Justice Treads~300~R~274030:3,12360:2,251291:12,18567:1
Legguards of Glory~300~R~274030:5,12360:4,251291:18,18567:1
Legionite Glaive~300~R~251290:15,251291:8,249726:10,248820:4,248822:1
Legplates of Glory~300~R~274030:5,12360:4,251291:18,18567:1
Light Obsidian Belt~300~R~22202:14,12810:4
Lionheart Helm~300~R~12359:80,12360:12,8146:40,12361:10,12800:4
Martyr's Legplates~300~R~251290:12,251291:20,7078:10,13511:2
Master Forge~300~R~273127:1,12359:5,8170:2
Masterwork Stormhammer~300~R~12655:20,12364:8,12799:8,7076:6,12810:4
Nightfall~300~R~17011:8,17010:5,12360:10,11371:12,12364:4
Obsidian Champion~300~R~
Obsidian Defender~300~R~
Obsidian Destroyer~300~R~
Obsidian Heartseeker~300~R~
Obsidian Mail Tunic~300~R~22203:15,22202:36,12810:12,12809:10,12800:4
Obsidian Reaver~300~R~
Obsidian Sageblade~300~R~
Obsidian Stormhammer~300~R~
Pauldrons of Glory~300~R~274030:3,12360:2,251291:12,18567:1
Persuader~300~R~12360:15,11371:10,12808:20,20520:20,15417:10,12753:2
Radiant Leggings~300~R~12359:20,7077:4
Razorspike Battleplate~300~R~
Razorspike Headcage~300~R~
Razorspike Shoulderplate~300~R~
Refined Arcanite Champion~300~R~
Refined Arcanite Reaper~300~R~
Refined Hammer of the Titans~300~R~
Runic Breastplate~300~R~12359:40,12360:2,7910:1
Runic Plate Boots~300~R~12359:20,12360:2,2842:10
Runic Plate Helm~300~R~12359:30,12360:2,6037:2,12364:1
Runic Plate Leggings~300~R~12359:40,12360:2,7910:1
Runic Plate Shoulders~300~R~12359:20,12360:2,3577:6
Sabatons of Glory~300~R~274030:3,12360:2,251291:12,18567:1
Sageblade~300~R~12360:12,20725:2,13512:2,12810:4
Sageblade of the Archmagus~300~R~
Shoulders of Glory~300~R~274030:3,12360:2,251291:12,18567:1
Skyrider's Masterwork Stormhammer~300~R~
Stalwart Helm~300~R~251290:12,12359:80,7910:10,12800:4,7971:20
Stormcarver~300~R~251290:20,249726:10,12644:2
Stronger-hold Gauntlets~300~R~
Stronghold Gauntlets~300~R~12360:15,12655:20,7076:10,12361:4,12799:4
Sulfuron Hammer~300~R~17203:8,11371:20,12360:50,7078:25,11382:10,17011:10,17010:10
Thick Obsidian Breastplate~300~R~22203:18,22202:40,12655:12,7076:10,12364:4
Thorium Leggings~300~R~12359:26,11186:4
Titanic Leggings~300~R~12360:12,12655:20,7076:10,13510:2
Warcrest of the Great Chief~300~R~
Whitesoul Helm~300~R~12359:20,12655:4,6037:6,3577:6,12800:2
Blood Talon~305~T~
Darkspear~305~T~]==],
 ["Cooking"]=[==[
Basic Campfire Kit~1~A~
Brilliant Smallfish~1~R~6291:1
Crispy Bat Wing~1~R~12223:1,2678:1
Gingerbread Cookie~1~R~6889:1,17194:1
Herb Baked Egg~1~R~6889:1,2678:1
Slitherskin Mackerel~1~R~6303:1
Kaldorei Spider Kabob~10~R~5465:1
Spiced Wolf Meat~10~T~2672:1,2678:1
Basic Campfire~20~A~4470:1
Scorpid Surprise~20~R~5466:1
Beer Basted Boar Ribs~25~R~2886:1,2894:1
Peace Tea~25~R~159:1,2447:2
Skywall Souffle~25~R~6889:2,10284:1
Tasty Raptor Bites~25~R~3685:1,2678:4
Venomous Smoothie~25~R~159:1,2678:1,1475:1
Egg Nog~35~R~6889:1,1179:1,17196:1,17194:1
Pincer Bites~35~R~2675:1,10284:1
Roasted Kodo Meat~35~R~5467:1,2678:1
Smoked Bear Meat~40~R~3173:1
Charred Wolf Meat~45~A~2672:1
Roasted Boar Meat~45~A~769:1
Boiled Clams~50~T~5503:1,159:1
Coyote Steak~50~T~2673:1
Fillet of Frenzy~50~R~5468:1,2678:1
Goretusk Liver Pie~50~R~723:1,2678:1
Loch Frenzy Delight~50~R~6317:1,2678:1
Longjaw Mud Snapper~50~R~6289:1
Rainbow Fin Albacore~50~R~6361:1
Strider Stew~50~R~5469:1,4536:1
Blood Sausage~60~R~3173:1,3172:1,3174:1
Thistle Tea~60~R~2452:1,159:1
Breakfast Omelette~75~R~6889:1,2678:4
Crab Cake~75~T~2674:1,2678:1
Twice-Spiced Raptor Slice~75~R~12184:1,2678:2
Westfall Stew~75~R~729:1,730:1,731:1
Critter Cookie~80~R~10284:5
Crocolisk Steak~80~R~2924:1,2678:1
Dry Pork Ribs~80~T~2677:1,2678:1
Smoked Sagefish~80~R~21071:1,2678:1
Cooked Crab Claw~85~R~2675:1,2678:1
Savory Deviate Delight~85~R~6522:1,2678:1
Savory Whimsyfin Delight~85~R~251524:1,2678:1
Clam Chowder~90~R~5503:1,1179:1,2678:1
Dig Rat Stew~90~R~5051:1
Journeyman Campfire Kit~90~R~
Murloc Fin Soup~90~R~1468:2,2692:1
Bristle Whisker Catfish~100~R~6308:1
Crispy Lizard Tail~100~R~5470:1,2692:1
Redridge Goulash~100~R~1081:1,1080:1
Royal Tea~100~R~1179:1,785:2
Seasoned Wolf Kabob~100~R~1015:2,2678:1
Slimy Smoothie~100~R~1179:1,2678:2,3174:1
Big Bear Steak~110~R~3730:1,2692:1
Gooey Spider Cake~110~R~2251:2,2692:1
Lean Venison~110~R~5471:1,2678:4
Succulent Pork Ribs~110~R~2677:2,2692:1
Crocolisk Gumbo~120~R~3667:1,2692:1
Goblin Deviled Clams~125~T~5504:1,2692:1
Hot Lion Chops~125~R~3731:1,2692:1
Lean Wolf Steak~125~R~1015:1,2678:1
Mrrggl Smrrthle~125~R~1205:1,2692:2,1468:1
Root Tea~125~R~1205:1,3357:2
Curiously Tasty Omelet~130~R~3685:1,2692:1
Cookie's Feast~140~R~12037:2,12204:1,3713:1
Heavy Crocolisk Stew~150~R~3667:2,3713:1
Tasty Lion Steak~150~R~3731:2,3713:1
Barbecued Buzzard Wing~175~R~3404:1,2692:1
Bear Brisket~175~R~3730:2,2692:3
Carrion Surprise~175~R~12037:1,2692:1
Giant Clam Scorcho~175~R~4655:1,2692:1
Giant Scrambled Eggs~175~R~12207:2,2692:4
Hot Wolf Ribs~175~R~12203:1,2692:1
Jungle Stew~175~R~12202:1,159:1,4536:2
Mithril Head Trout~175~R~
Mystery Stew~175~R~12037:1,2596:1
Roast Raptor~175~R~12184:1,2692:1
Rockscale Cod~175~R~6362:1
Sagefish Delight~175~R~21153:1,2692:1
Soothing Turtle Bisque~175~R~3712:1,3713:1
Calcified Smoothie~180~R~1708:1,2692:3,5637:1
Raging Raptor Ribs~180~R~12184:2,2692:3
Triage Tea~180~R~1708:1,3818:2
Plain Ol' Paletusk~185~R~769:2,2678:1
Briny Seafood Stew~200~R~730:2,12206:1,2692:1
Dragonbreath Chili~200~R~12037:1,4402:1,2692:1
Expert Campfire Kit~200~R~
Heavy Kodo Stew~200~R~12204:2,3713:1,159:1
Spicy Smoothie~200~R~1645:1,3713:3,4402:1
Spider Sausage~200~T~12205:2
Sunny Tea~200~R~1645:1,8838:2
Spinefin Halibut~210~T~8959:1
Goldthorn Tea~215~T~3821:1,159:1
Cooked Glossy Mightfish~225~R~13754:1,3713:1
Filet of Redgill~225~R~13758:1
Monster Omelet~225~R~12207:1,3713:2
Plated Armorfish~225~R~13890:1,3713:1
Raptor Rouladen~225~R~12184:2,2692:4
Savory Stag Sliders~225~R~5471:2,2692:3
Spiced Chili Crab~225~R~12206:1,2692:2
Spotted Yellowtail~225~R~4603:1
Tender Wolf Steak~225~R~12208:1,3713:1
Undermine Clam Chowder~225~R~7974:2,2692:1,1179:1
Grilled Squid~240~R~13755:1,3713:1
Hot Smoked Bass~240~R~13756:1,2692:2
Filet o' Flank~250~R~12203:2,239016:1
Nightfin Soup~250~R~13759:1,159:1
Poached Sunscale Salmon~250~R~13760:1
Prowler Steak~250~R~12202:2,239016:1
Sage's Tea~250~R~8766:1,13465:2
Sunrise Omelette~250~R~12207:2,239016:1
Wicked Smoothie~250~R~8766:1,3713:4,8146:1
Baked Salmon~275~R~13889:1,3713:1
Bat Hachee~275~R~12223:3,3713:2
Bear Bruscitti~275~R~3730:3,3713:3
Clam Linguine~275~R~7974:3,3713:4
Flank au Poivre~275~R~12203:3,3713:3
Lobster Stew~275~R~13888:1,159:1
Mightfish Steak~275~R~13893:1,2692:1,3713:1
Prehistoric Pulled Raptor~275~R~12184:3,3713:4
Runn Tum Tuber Surprise~275~R~18255:1,3713:1
Savory Turtle Stew~275~R~3712:3,3713:3
Soaring Pamplona~275~R~3404:3,3713:3
Steaming Stag Steak~275~R~5471:3,3713:4
Sweetpaw Jam~275~R~249796:3,3713:1
Swiftstrike Steak~275~R~12202:3,3713:2
Grand Lobster Banquet~280~R~13888:12,3712:4,3404:3,239017:1
Specklefin Feast~280~R~4603:12,12184:4,6362:3,239017:1
Darkclaw Bisque~300~R~
Dirge's Kickin' Chimaerok Chops~300~R~2692:1,9061:1,8150:1,21024:1
Iron Oven~300~R~10284:10,159:5,3713:4
Smoked Redgill~300~R~
Smoked Desert Dumplings~325~T~20424:1,3713:1]==],
 ["Enchanting"]=[==[
Mote of Magic~1~A~
Runed Copper Rod~5~A~6217:1,247786:1
Lesser Magic Wand~10~T~4470:1,10938:1
Novice's Practice Wand~10~A~4470:1,247786:1
Enchant Chest - Inferior Stamina~15~T~10940:1
Enchant Bracer - Inferior Stamina~20~A~247786:1
Enchant Chest - Minor Intellect~20~R~10938:1
Enchanted Lute~20~T~4470:1,10940:1
Enchant Chest - Minor Absorption~40~T~10938:1
Enchant Cloak - Minor Resistance~45~T~10940:1,10938:1
Minor Wizard Oil~45~R~10940:1,17034:1,3371:1
Enchant Bracer - Minor Stamina~50~T~10940:2
Enchant Bracer - Minor Spirit~60~R~10938:1
Enchant Chest - Lesser Stamina~60~T~10940:1,10938:1
Enchant Bracer - Minor Intellect~70~R~10938:1
Enchant Cloak - Minor Protection~70~R~10940:2
Greater Magic Wand~70~T~4470:1,10938:2
Blackfathom Mana Oil~80~R~
Enchant Bracer - Minor Agility~80~T~10940:1,10938:2
Enchant Bracer - Minor Deflect~80~A~10938:1
Enchant Bracer - Minor Strength~80~R~10940:3
Enchant Chest - Lesser Intellect~80~R~10938:2
Enchant Bracer - Minor Healing Power~90~R~10938:2
Enchant Weapon - Minor Beastslayer~90~R~10940:2,10939:1
Enchant Weapon - Minor Striking~90~T~10940:1,10938:1,10978:1
Enchant 2H Weapon - Lesser Intellect~100~R~10938:4
Enchant 2H Weapon - Minor Impact~100~T~10940:1,10978:1
Runed Silver Rod~100~T~6338:1,10940:3,10938:4,1210:1
Enchant Shield - Minor Stamina~105~T~10998:1,10940:1
Enchant 2H Weapon - Lesser Spirit~110~R~10998:1,10940:3
Enchant Cloak - Minor Agility~110~R~10998:1
Enchant Cloak - Lesser Protection~115~T~10940:3,10978:1
Enchant Shield - Lesser Protection~115~R~10940:1,10978:1
Enchant Bracer - Lesser Spirit~120~R~10998:1
Enchant Chest - Stamina~120~T~10940:2,10998:1
Scroll of Spatial Mending~120~R~4470:1,10940:4
Enchant Boots - Minor Agility~125~R~10940:3,10998:1
Enchant Boots - Minor Stamina~125~R~10940:4
Enchant Cloak - Lesser Fire Resistance~125~T~6371:1,10998:1
Enchant Bracer - Lesser Stamina~130~T~11083:1
Enchant Shield - Lesser Spirit~130~T~10998:1,10940:2
Mystic Mushroom~130~R~10978:1,10939:2,10940:5,4605:1
Polished Driftwood Icon~130~R~11084:1,10939:2,10940:3,4470:1
Tenets of the Silver Hand~130~R~11084:1,10939:1,10940:2,3013:5
Enchant Cloak - Lesser Shadow Resistance~135~R~10998:1,6048:1
Arcane Salvager~140~R~11137:2,11174:1
Enchant Bracer - Lesser Agility~140~R~11134:1
Enchant Bracer - Lesser Strength~140~R~11083:1
Enchant Chest - Lesser Absorption~140~T~10940:1,10998:1,11084:1
Enchant Weapon - Insight~140~R~10940:10,11084:4,11082:4,249391:4,249399:4
Enchant Weapon - Lesser Striking~140~T~11083:1,11084:1
Enchant Weapon - Recovery~140~R~11083:6,11084:4,11082:6,249391:4,2775:4
Enchant Weapon - Revelation~140~R~11083:8,11084:6,11082:2,249409:4,249410:4
Glimmering Staff~140~R~11084:4,10978:2,11291:4,11082:1,10940:5,249391:3
Orb of Mystic Insight~140~R~10978:2,11082:2,10940:5
Orb of Souls~140~R~10978:2,11082:2,11083:2
Soulstaff~140~R~11084:2,10978:1,11291:4,11082:1,11083:6,1210:2
Enchant 2H Weapon - Lesser Impact~145~T~11083:1,11084:1
Enchant Chest - Intellect~145~T~11082:1
Enchant Gloves - Fishing~145~R~11083:1,6370:1
Enchant Gloves - Herbalism~145~R~11083:1,3356:1
Enchant Gloves - Mining~145~R~11083:1,2772:1
Enchant Bracer - Lesser Intellect~150~T~11082:1
Enchant Chest - Minor Stats~150~T~10998:1,11083:1,11084:1
Minor Mana Oil~150~R~11083:1,17034:2,3372:1
Runed Golden Rod~150~T~11128:1,5500:1,11082:1,11083:1
Enchant Cloak - Defense~155~T~11138:1,11083:1
Enchant Shield - Lesser Stamina~155~T~11134:1
Lesser Mystic Wand~155~T~11291:1,11134:1
Enchant Boots - Lesser Agility~160~T~11083:1
Enchant Chest - Greater Stamina~160~T~11083:2
Enchant Bracer - Spirit~165~T~11134:1
Enchant Boots - Lesser Stamina~170~T~11083:2
Enchant Bracer - Lesser Deflection~170~R~11134:1,11083:1
Enchant Bracer - Stamina~170~T~11083:3
Enchant Cloak - Fire Resistance~175~T~11134:1,7068:1
Enchant Weapon - Lesser Beastslayer~175~R~5637:1,11138:1
Enchant Weapon - Lesser Elemental Slayer~175~R~7067:1,11138:1
Greater Mystic Wand~175~T~11291:1,11134:1,11137:1
Enchant Bracer - Strength~180~T~11137:1
Enchant Shield - Spirit~180~T~11134:1,11137:1
Enchant Chest - Greater Intellect~185~T~11134:1
Twisted Nether Wand~185~R~11174:1,11176:1,11291:1
Enchant Boots - Lesser Spirit~190~R~11134:2
Enchant Bracer - Agility~190~R~11137:1
Enchant Weapon - Winter's Might~190~R~11135:1,11137:1,11139:1,3819:1
Enchant Shield - Lesser Block~195~R~11135:1,11137:1,11139:1
Enchant Weapon - Striking~195~T~11135:1,11139:1
Enchant 2H Weapon - Impact~200~T~11137:2,11139:1
Enchant Chest - Lesser Stats~200~T~11135:1,11137:1,11139:1
Enchant Gloves - Skinning~200~R~11137:1,7392:1
Lesser Wizard Oil~200~R~11137:1,17035:2,3372:1
Runed Truesilver Rod~200~T~11144:1,7971:1,11135:1,11137:1
Enchant Bracer - Lesser Healing Power~205~R~11134:2
Enchant Cloak - Greater Defense~205~T~11137:1
Enchant Cloak - Resistance~205~T~11174:1
Enchant 2H Weapon - Lesser Agility~210~R~11137:2,11139:1,11174:1
Enchant Bracer - Intellect~210~T~11174:1
Enchant Gloves - Agility~210~T~11137:1
Enchant Necklace - Agility~210~R~11175:2,11178:8,11176:6,249410:4,249430:4
Enchant Necklace - Deflection~210~R~11175:8,11178:2,11176:2,249409:4,249430:4
Enchant Necklace - Healing Power~210~R~11175:3,11178:5,11176:4,249391:4,249424:4
Enchant Necklace - Spell Power~210~R~11175:5,11178:3,11176:8,249409:4,249430:4
Enchant Necklace - Strength~210~R~11175:4,11178:4,11176:10,249410:4,249425:4
Enchant Shield - Stamina~210~R~11137:2
Libram of Invocation~210~R~11178:3,11175:3,11176:4,249430:2,249409:1,2289:4
Talons of Wrath~210~R~11178:2,11175:4,11176:6,249430:2,249409:1,11291:1
Totem of Ancestral Protection~210~R~11178:4,11175:2,11176:2,249432:4,249410:2,11291:2
Dreambough Wand~215~R~11174:2,11137:1,11291:1
Enchant Boots - Stamina~215~T~11137:2
Enchant Gloves - Advanced Mining~215~R~11137:2,6037:1
Dreamstaff~220~R~11178:4,11177:4,11291:4,11175:6,11176:8,249409:2,249430:4
Enchant 2H Weapon - Lesser Strength~220~R~11137:1,11139:1,11174:2
Enchant Bracer - Greater Spirit~220~R~11174:1,11137:1
Enchant Chest - Absorption~220~R~11176:10,11175:4,11178:2
Enchant Chest - Superior Stamina~220~T~11137:3
Radiant Staff~220~R~11178:6,11177:2,11291:4,11175:4,11176:6,249409:2,249430:4
Truesilver Conduit~220~R~11178:3,11177:1,11291:2,11175:2,11176:3,249409:1,249430:2
Twisting Essence Jar~220~R~6037:4,11175:12,11135:12,249409:1,249430:2
Enchant Boots - Minor Speed~225~T~11177:1,7909:1,11174:1
Enchant Chest - Retricutioner~225~R~
Enchant Cloak - Lesser Agility~225~R~11174:1
Enchant Gloves - Advanced Herbalism~225~R~11137:2,8838:1
Enchant Gloves - Strength~225~T~11174:1,11137:2
Enchant Weapon - Dismantle~225~R~
Enchanted Sigil: Innovation~225~R~
Enchant Chest - Superior Intellect~230~T~11175:1
Enchant Shield - Greater Spirit~230~T~11174:2,11176:1
Enchant Weapon - Demonslaying~230~R~11177:1,11176:1,9224:1
Enchanted Thorium Bar~230~T~
Enchant Boots - Agility~235~T~11175:1
Enchant Bracer - Deflection~235~R~11174:2,11176:1
Enchant Shield - Frost Resistance~235~R~11178:1,3829:1
Enchant 2H Weapon - Greater Impact~240~T~11178:1,11176:1
Enchant Bracer - Greater Agility~240~R~11176:3,11174:1
Enchant Bracer - Greater Strength~240~T~11176:1,11174:2
Enchant Bracer - Greater Stamina~245~R~11176:3
Enchant Chest - Stats~245~T~11178:1,11176:1,11175:1
Enchant Weapon - Greater Striking~245~T~11178:1,11175:1
Lesser Eternal Wand~245~R~16202:1,11176:1,11291:1
Enchant Gloves - Advanced Skinning~250~R~11176:2,15407:1
Enchant Gloves - Minor Haste~250~T~11178:1,8153:1
Enchant Gloves - Riding Skill~250~R~11178:1,11176:2
Enchanted Leather~250~T~8170:1,16202:1
Lesser Mana Oil~250~R~11176:1,8831:1,8925:1
Sigil of Living Dreams~250~T~11176:5
Enchant Bracer - Greater Intellect~255~R~16202:2
Enchant Boots - Greater Stamina~260~R~11176:6
Dormant Heart of the Mountain~265~R~11382:1,7080:1,14343:3
Enchant Cloak - Greater Resistance~265~R~16202:1,7077:1,7075:1,7079:1,7081:1,7972:1
Enchant Shield - Greater Stamina~265~R~11176:6
Enchant Weapon - Fiery Weapon~265~R~11177:2,7078:1
Frozen Heart of the Mountain~265~R~11382:1,12808:1,14343:3
Molten Heart of the Mountain~265~R~11382:1,7076:1,14343:3
Smoking Heart of the Mountain~265~R~11382:1,7078:1,14343:3
Enchant Bracer - Superior Spirit~270~R~16202:2,11176:7
Enchant Gloves - Greater Agility~270~R~16202:2,16204:2
Brilliant Wand~275~R~16203:1,16204:3,14344:2,11291:1
Conductive Shield Coating~275~R~
Enchant Boots - Spirit~275~R~16203:2,16202:1
Enchant Chest - Major Stamina~275~R~16204:6,14343:1
Greater Eternal Wand~275~R~16203:2,16204:1,11291:1
Wizard Oil~275~R~16204:3,4625:2,8925:1
Enchant 2H Weapon - Grand Arcanist~280~R~
Enchant 2H Weapon - Grand Inquisitor~280~R~
Enchant Boots - Speed~280~R~11178:2,11176:8,11175:2,12361:1
Enchant Shield - Superior Spirit~280~R~16203:2,16204:4
Enchant Weapon - Grand Crusader~280~R~
Enchant Weapon - Grand Sorcerer~280~R~14344:6,12811:3,20725:2,12938:1
Enchant Cloak - Superior Defense~285~R~16204:8
Enchant Weapon - Icy Chill~285~R~14343:4,7080:1,7082:1,13467:1
Enchant 2H Weapon - Agility~290~R~14344:10,16203:6,16204:14,7082:4
Enchant 2H Weapon - Strength~290~R~14344:8,16203:10,16204:8,12363:4
Enchant Bracer - Mana Regeneration~290~R~16204:16,16203:4,7080:2
Enchant Chest - Major Intellect~290~R~16203:3,14343:1
Enchant Weapon - Agility~290~R~14344:6,16203:6,16204:4,7082:2
Enchant Weapon - Strength~290~R~14344:6,16203:6,16204:4,7076:2
Enchanted Sigil: Flowing Waters~290~R~
Runed Arcanite Rod~290~R~16206:1,13926:1,16204:10,16203:4,14343:4,14344:2
Enchant 2H Weapon - Superior Impact~295~R~14344:4,16204:10
Enchant Boots - Greater Agility~295~R~16203:8
Enchant Bracer - Superior Agility~295~R~16204:3,16203:3,14344:1
Enchant Bracer - Superior Strength~295~R~16204:6,16203:6
Enchant Gloves - Greater Strength~295~R~16203:4,16204:4
Enchant Gloves - Lotus Claw~295~R~248822:1,14343:2,16204:12,16202:4
Enchant Weapon - Unholy Weapon~295~R~14344:4,12808:4
Arcane Forge~300~R~273128:1,14344:2,16203:4
Brilliant Mana Oil~300~R~14344:2,8831:3,18256:1
Brilliant Wizard Oil~300~R~14344:2,4625:3,18256:1
Enchant 2H Weapon - Major Intellect~300~R~16203:12,14344:2
Enchant 2H Weapon - Major Spirit~300~R~16203:12,14344:2
Enchant 2H Weapon - Mighty Healing Power~300~R~248819:4,16203:6,249726:4,249274:4,20725:4,248820:4
Enchant 2H Weapon - Mighty Spell Power~300~R~248819:4,16203:6,7076:4,12808:4,20725:4,248820:2
Enchant 2H Weapon - Spellblasting~300~R~20725:3,16204:24,12938:1,8831:6
Enchant Bracer - Greater Spellpower~300~R~16203:3,16204:9,12808:12,8831:2
Enchant Bracer - Healing Power~300~R~14344:2,16204:20,16203:4,12803:6
Enchant Bracer - Superior Deflection~300~R~14344:3
Enchant Bracer - Superior Intellect~300~R~16203:10
Enchant Bracer - Superior Stamina~300~R~16204:15
Enchant Chest - Greater Stats~300~R~14344:4,16204:15,16203:10
Enchant Chest - Living Stats~300~R~
Enchant Cloak - Agility~300~R~16203:3,16204:9,7078:1
Enchant Cloak - Dodge~300~R~20725:3,14344:8,12809:8
Enchant Cloak - Greater Fire Resistance~300~R~20725:3,14344:8,7078:4
Enchant Cloak - Greater Nature Resistance~300~R~20725:2,14344:8,12803:4
Enchant Cloak - Stealth~300~R~20725:3,14344:8,13468:2
Enchant Cloak - Subtlety~300~R~20725:4,14344:6,11754:2
Enchant Gloves - Arcane Power~300~R~20725:2,14344:5,12753:2
Enchant Gloves - Fire Power~300~R~20725:2,14344:10,7078:4
Enchant Gloves - Frost Power~300~R~20725:3,14344:10,7080:4
Enchant Gloves - Healing Power~300~R~20725:3,14344:8,12811:1
Enchant Gloves - Holy Power~300~R~20725:2,14344:5,13180:5,12735:2
Enchant Gloves - Natural Power~300~R~20725:2,14344:5,248822:4
Enchant Gloves - Shadow Power~300~R~20725:3,14344:10,12808:6
Enchant Gloves - Superior Agility~300~R~20725:3,14344:8,7082:4
Enchant Gloves - Superior Strength~300~R~20725:4,16203:8,7076:4
Enchant Gloves - Threat~300~R~20725:4,14344:6,18512:8
Enchant Off-Hand - Excellent Spirit~300~R~20725:2,16204:18,7080:2
Enchant Off-Hand - Superior Intellect~300~R~20725:2,16204:18,7082:2
Enchant Off-Hand - Wisdom~300~R~14344:6,16204:18,7082:1,7080:1
Enchant Shield - Critical Strike~300~R~14344:5,16204:15,12938:1
Enchant Shield - Excellent Stamina~300~R~14344:6,16204:18,7076:2
Enchant Shield - Law of Nature~300~R~
Enchant Weapon - Crusader~300~R~14344:4,12811:2
Enchant Weapon - Healing Power~300~R~14344:4,16203:8,12803:6,7080:6,12811:1
Enchant Weapon - Lifestealing~300~R~14344:6,12808:6,12803:6
Enchant Weapon - Mighty Intellect~300~R~14344:15,16203:12,16204:20
Enchant Weapon - Mighty Spirit~300~R~14344:10,16203:8,16204:15
Enchant Weapon - Spell Power~300~R~14344:4,16203:12,7078:4,7080:4,7082:4,13926:2
Enchant Weapon - Superior Striking~300~R~14344:2,16203:10
Enchanted Mushroom~300~R~
Enchanted Prayer Tome~300~R~
Enchanted Repellent~300~R~
Enchanted Stopwatch~300~R~
Enchanted Totem~300~R~
Idol of Feline Ferocity~300~R~
Idol of Sidereal Wrath~300~R~
Idol of Swiftness~300~R~274030:1,20725:1,16203:2,16204:12
Idol of Ursin Power~300~R~
Idol of the Dream~300~R~14344:2,16203:4,16204:6,249431:8,249430:4,249409:2,11291:4
Idol of the Ursine Twins~300~R~274030:1,20725:1,16203:2,16204:12
Libram of Holy Alacrity~300~R~14344:4,16203:3,16204:4,249431:8,249430:4,249409:2,10308:4
Libram of Infusion~300~R~274030:1,20725:1,16203:2,16204:12
Libram of Righteousness~300~R~
Libram of Sanctity~300~R~
Libram of the Exorcist~300~R~
Lodestone of Retaliation~300~R~
Magnificent Trollshine~300~R~
Ruby-Encrusted Broach~300~R~
Scroll: Wrath of the Swarm~300~R~
Speedstone~300~R~
Steadfast Libram~300~R~274030:1,20725:1,16203:2,16204:12
Tear of the Dreamer~300~R~
Torch of Light~300~R~274030:2,20725:1,14344:6,16202:5
Totem of Flowing Magma~300~R~
Totem of Pyroclastic Thunder~300~R~
Totem of Thunder~300~R~14344:1,16203:8,16204:10,249431:8,249430:4,249409:2,11291:4
Totem of Thunderous Strikes~300~R~
Totem of Urgency~300~R~274030:1,20725:1,16203:2,16204:12
Enchant Bracer - Spell Power~320~R~14344:2,16204:20,16203:4,7080:2,7078:2,7082:2]==],
 ["Engineering"]=[==[
Reagent Bot~20~T~4359:1,4361:1
Rough Blasting Powder~20~A~2835:1
SAF-T Dynamite~25~R~4357:2,2589:1
SAF-T Tabs~25~R~2570:1,249409:1
Crafted Light Shot~30~A~4357:1,2840:1
Handful of Copper Bolts~30~T~2840:1
Rough Copper Bomb~30~T~2840:1,4359:1,4357:2,2589:1
Rough Dynamite~30~A~4357:1,2589:1
Arclight Spanner~50~T~2840:6
Copper Tube~50~T~2840:2,2880:1
Rough Boomstick~50~T~4361:1,4359:1,4399:1
SAF-T Copper Bomb~55~R~2840:1,4359:1,4357:2,2570:1,260784:2
Crude Scope~60~T~4361:1,774:1,4359:1
Copper Modulator~65~T~4359:2,2840:1,2589:2
Harvester Override Signalcaster~65~R~255007:4,4363:2,4405:1
Coarse Blasting Powder~75~T~2836:1
Coarse Dynamite~75~T~4364:3,2589:1
Crafted Heavy Shot~75~T~4364:1,2840:1
Mechanical Squirrel Box~75~R~
Satchel of Copper Bombs~85~R~4360:20,2318:6,4359:4
Target Dummy~85~T~4363:1,4359:2,2841:1,2592:1
Silver Contact~90~T~2842:1
EZ-Thro Dynamite~100~R~4364:3,2589:1,260794:1
EZ-Thro Wrap~100~R~2592:1,249410:1
Flying Tiger Goggles~100~T~2318:6,818:2
Practice Lock~100~T~2841:1,4359:2,2880:1
Small Seaforium Charge~100~R~4364:2,4363:1,2318:1,159:1
Bronze Tube~105~T~2841:2,2880:1
Deadly Blunderbuss~105~T~4361:2,4359:4,4399:1,2319:2
Large Copper Bomb~105~T~2840:3,4364:4,4404:1
Standard Scope~110~T~4371:1,1206:1
Lovingly Crafted Boomstick~120~R~4371:2,4359:2,4400:1,1206:3
Sandpaper~120~T~249425:2,2996:1
Shadow Goggles~120~R~2319:4,1210:2
Small Bronze Bomb~120~T~4364:4,2841:2,4404:1,2592:1
9-60 Battery Pack~125~R~249409:1,249391:1,3575:1
Crafted Solid Shot~125~T~4377:1,2841:1
Flame Deflector~125~R~4375:1,4402:1
Gnomish Universal Remote~125~R~2841:6,4375:1,814:2,818:1,774:1
Heavy Blasting Powder~125~T~2838:1
Heavy Dynamite~125~T~4377:2,2592:1
Small Blue Rocket~125~R~4364:1,2319:1
Small Green Rocket~125~R~4364:1,2319:1
Small Purple Rocket~125~R~4364:1,2319:1
Small Red Rocket~125~R~4364:1,2319:1
Small White Rocket~125~R~4364:1,2319:1
Small Yellow Rocket~125~R~4364:1,2319:1
Whirring Bronze Gizmo~125~T~2841:2,2592:1
EZ-Thro Copper Bomb XL~130~R~2840:3,4364:4,4404:1,260794:1
Silver-plated Shotgun~130~T~4371:2,4375:2,4400:1,2842:3
Ornate Spyglass~135~T~4371:2,4375:2,4363:1,1206:1
Shredder Autosalvage Unit~135~R~4382:1,4375:2,4234:1
Big Bronze Bomb~140~T~4377:2,2841:3,4404:1
Hoof-Shaped Foot Pedal~140~R~4387:3,4382:2,4389:1,10558:1,4234:4
Minor Recombobulator~140~R~4371:1,4375:2,2319:2,1206:1
Repair Bot~140~R~4375:2,4371:1,4234:1
Bronze Framework~145~T~2841:2,2319:1,2592:1
Moonsight Rifle~145~R~4371:3,4375:3,4400:1,1705:2
No Slip SAF-T Padding~145~R~4234:1,249430:1
SAF-T Bronze Bomb~145~R~4364:4,2841:2,4404:1,2592:1,260796:1
Aquadynamic Fish Attractor~150~T~2841:2,6530:1,4364:1
Blue Firework~150~R~4377:1,4234:1
Explosive Sheep~150~T~4382:1,4375:1,4377:2,2592:2
Gold Power Core~150~T~3577:1
Green Firework~150~R~4377:1,4234:1
Green Tinted Goggles~150~T~2319:4,1206:2,4368:1
Red Firework~150~R~4377:1,4234:1
SAF-T Jumbo Dynamite~150~R~4377:2,2592:1,260796:1
Ice Deflector~155~R~4375:1,3829:1
Discombobulator Ray~160~R~4375:3,4306:2,1529:1,4371:1
Iron Strut~160~T~3575:2
Goblin Jumper Cables~165~R~3575:6,4375:2,814:2,4306:2,1210:2,7191:1
Portable Bronze Mortar~165~R~4371:4,4387:1,4377:4,2319:4
Satchel of Bronze Bombs~165~R~4380:20,2319:6,4375:1
Gyrochronatom~170~T~3575:1,10558:1
Bright-Eye Goggles~175~R~4234:6,3864:2
Clanking Cord~175~R~4371:2,4363:1,2319:4
Compact Harvest Reaper Kit~175~T~4387:2,4382:1,4389:2,4234:4
Gizmo Girdle~175~R~4375:2,4382:1,2319:4
Gyromatic Micro-Adjustor~175~T~3859:4
Iron Grenade~175~T~3575:1,4377:1,4306:1
Large Blue Rocket~175~R~4377:1,4234:1
Large Green Rocket~175~R~4377:1,4234:1
Large Purple Rocket~175~R~4377:1,4234:1
Large Red Rocket~175~R~4377:1,4234:1
Large White Rocket~175~R~4377:1,4234:1
Large Yellow Rocket~175~R~4377:1,4234:1
SAF-T Bell~175~R~2841:2,249432:1
Serrated Strap~175~R~4363:2,4371:1,3575:1
Shafety Sheep~175~R~4382:1,4375:1,4377:2,2592:2,260799:1
Solid Blasting Powder~175~T~7912:2
Solid Dynamite~175~T~10505:1,4306:1
Whimsical Waistwrap~175~R~4382:2,4375:1,4305:2
Accurate Scope~180~R~4371:1,1529:1,3864:1
Advanced Target Dummy~185~T~4387:1,4382:1,4389:1,4234:4
Craftsman's Monocle~185~R~4234:6,3864:2
Flash Bomb~185~R~4611:1,4377:1,4306:1
Big Iron Bomb~190~T~3575:3,4377:3,4404:1
Centaur Banner Deployment Device~190~R~4387:6,4389:2,10558:4,4234:30
EZ-Thro Bronze Mortar~190~R~4371:4,4387:1,4377:4,2319:4,260801:1
EZ-Thro Fireproof Fuse~190~R~4404:1,249428:1
Snowmaster 9000~190~R~3860:8,4389:4,17202:4,3829:1
Goblin Land Mine~195~R~4377:3,3575:2,4389:1
Mithril Tube~195~T~3860:3
Bent Goggles~200~R~5507:1,4389:1,4234:8
Dented Goggles~200~R~5507:1,4389:1,3860:2
EZ-Thro Dynamite II~200~R~10505:1,4306:1,260801:1
EZ-Thro Grenade~200~R~3575:1,4377:1,4306:1,260801:1
Floppy Goggles~200~R~5507:1,4389:1,4339:4
Gnomish Cloaking Device~200~R~4389:4,1529:2,1705:2,3864:2,7191:1
Large Seaforium Charge~200~R~10505:2,4234:2,159:1
Mechanical Dragonling~200~R~4382:1,4387:4,4389:4,3864:2,7191:1
Mechanical Repair Kit~200~T~3860:1,4338:1,10505:1
Mobile Alarm~200~T~
Polished Truesilver Gears~200~R~6037:1,213381:5
Stuckbutton Goggles~200~R~5507:1,4389:1,4234:8
Unstable Trigger~200~T~3860:1,4338:1,10505:1
Explosive Arrow~205~T~
Fire Goggles~205~T~4385:1,3864:2,7068:2,4234:4
Gnomish Shrink Ray~205~T~10559:1,10560:1,3860:4,8151:4,1529:2
Goblin Construction Helmet~205~T~3860:8,3864:1,7068:4
Goblin Mining Helmet~205~R~3860:8,3864:1,7067:4
Goblin Mortar~205~T~10559:2,3860:4,10505:5,10558:1,7068:1
Goblin Sapper Charge~205~R~4338:1,10505:3,10560:1
Lil' Smoky~205~R~7075:1,4389:2,7191:1,3860:2,6037:1
Mithril Blunderbuss~205~T~10559:1,10560:1,4400:1,3860:4,7068:2
Pet Bombling~205~R~4394:1,7077:1,7191:1,3860:6
Soul Vessel~205~R~
Deadly Scope~210~R~10559:1,7909:2,4304:2
Gnomish Goggles~210~T~10500:1,10559:1,10558:2,8151:2,4234:2
Gnomish Net-o-Matic Projector~210~T~10559:1,10285:2,4337:4,10505:2,3860:4
Hi-Impact Mithril Slugs~210~T~3860:1,10505:1
Gnomish Harm Prevention Belt~215~T~7387:1,3860:4,6037:2,10560:1,7909:2
Mithril Casing~215~T~3860:3
Mithril Frag Bomb~215~T~10561:1,10560:1,10505:1
SAF-T Bomb~215~R~3575:3,4377:3,4404:1,260804:1
SAF-T Casing~215~R~10561:1,4234:1
Catseye Ultra Goggles~220~R~4304:4,7909:2,10592:1
Mithril Heavy-bore Rifle~220~R~10559:2,10560:1,4400:1,3860:6,3864:2
Blue Rocket Cluster~225~R~10505:1,4304:1
Compact Critter Carrier~225~R~4234:10,10559:10,11175:2,10558:1
EZ-Thro Radiation Bomb~225~R~10505:2,215430:1,3860:2
Emergency Field Cloak~225~R~4397:1,260804:1
Firework Launcher~225~R~9060:2,9061:2,10560:2,10561:1
Gnomish Rocket Boots~225~R~10026:1,10559:2,4234:4,10505:8,4389:4
Goblin Rocket Boots~225~R~10026:1,10559:2,4234:4,9061:2,10560:1
Green Rocket Cluster~225~R~10505:1,4304:1
High-Yield Radiation Bomb~225~R~10505:1,215430:1,3860:2
Hyperconductive Goldwap~225~R~213383:3,213379:3,213369:1,3577:10
Parachute Cloak~225~R~4339:4,10285:2,10560:1,10505:4
Purple Rocket Cluster~225~R~10505:1,4304:1
Red Rocket Cluster~225~R~10505:1,4304:1
Spellpower Goggles Xtreme~225~R~4304:4,7910:2
Whirling Truesilver Gearwall~225~R~213376:3,213383:5,213369:2,10561:2,4389:2,3860:15
White Rocket Cluster~225~R~10505:1,4304:1
Yellow Rocket Cluster~225~R~10505:1,4304:1
Deepdive Helmet~230~R~3860:8,10561:1,6037:1,818:4,774:4
Gnomish Battle Chicken~230~T~10561:1,6037:6,3860:6,9060:2,10558:1,1529:2
Goblin "Boom" Box~230~T~
Goblin Bomb Dispenser~230~T~10561:2,10505:4,6037:6,10560:1,4407:2
Rose Colored Goggles~230~T~4304:6,7910:2
Satchel of Iron Bombs~230~R~4394:20,4304:6,4389:1
Gnomish Ham Radio~235~T~
Gnomish Mind Control Cap~235~T~3860:10,6037:4,10558:1,7910:2,4338:4
Goblin Radio~235~T~
Hi-Explosive Bomb~235~T~10561:2,10560:1,10505:2
The Big One~235~R~10561:1,9061:1,10507:6,10560:1
EZ-Thro Tru-Trigger~240~R~6037:1,249431:1
Gnomish Death Ray~240~T~10559:2,10560:1,12808:1,7972:4,9060:1
Goblin Dragon Gun~240~T~10559:2,9061:4,3860:6,6037:6,10560:1
Sniper Scope~240~R~10559:1,7910:1,6037:2
Tru-Trigger Frag Bomb~240~R~10561:1,10560:1,10505:1,260808:1
Goblin Rocket Helmet~245~T~10543:1,9061:4,3860:4,10560:1
Green Lens~245~T~4304:8,1529:3,7909:3,10286:2,8153:2
Mithril Gyro-Shot~245~T~3860:2,10505:2
Creepy Censor Sensors~250~R~
Dense Blasting Powder~250~T~12365:2
Dense Dynamite~250~T~15992:2,14047:3
Gnomish Army Knife~250~R~10561:1,10558:1,15994:2
Mithril Mechanical Dragonling~250~R~3860:14,7077:4,6037:4,9060:2,9061:2,7910:2
Pop-Up Shrub~250~R~15994:1,10560:1,4382:1
SAF-T Disposable Parachute~250~R~10518:1,260804:1
Salt Shaker~250~T~10561:1,12359:6,10558:1,10560:4
Snake Burst Firework~250~R~15992:2,14047:2,8150:1
Tinkerbox~250~T~10561:1,10558:2
Void-Powered Invoker's Vambraces~250~T~221021:10,220688:1,220689:1,10558:2,15994:2
Void-Powered Protector's Vambraces~250~T~221021:10,220688:1,220689:1,10558:2,16000:2
Void-Powered Slayer's Vambraces~250~T~221021:10,220688:1,220689:1,15992:3,7910:2
Gyrofreeze Ice Reflector~260~R~15994:6,18631:2,12361:2,7078:4,3829:2,13467:4
Thorium Grenade~260~R~15994:1,12359:3,15992:3,14047:3
Thorium Rifle~260~R~10559:2,10561:2,15994:2,12359:4,10546:1
Thorium Widget~260~R~12359:3,14047:1
Tinkerbox: Magnetic Displacement~260~R~238737:1,10560:1,4387:2
Tinkerbox: Nitro Boosts~260~R~238737:1,10560:1,16000:1
Tinkerbox: Teleport~260~R~238737:1,10560:1,15994:1
Truesilver Transformer~260~R~6037:2,7067:2,7069:1
Unsanctified Grenade~260~R~18631:1,12655:2,15992:3,14047:2
World Enlarger~260~R~10561:1,15994:2,10558:1,10560:1,3864:1
Gnomish Alarm-O-Bot~265~R~
Goblin Jumper Cables XL~265~R~15994:2,18631:2,7191:2,14227:2,7910:2
Lifelike Mechanical Toad~265~R~12803:1,15994:4,10558:1,8170:1
Spellpower Goggles Xtreme Plus~270~R~10502:1,7910:4,12810:2,14047:8
Cluster Launcher~275~R~
Dark Iron Rifle~275~R~16000:2,11371:6,10546:2,12361:2,12799:2,8170:4
Large Blue Rocket Cluster~275~R~15992:1,8170:1
Large Green Rocket Cluster~275~R~15992:1,8170:1
Large Purple Rocket Cluster~275~R~15992:1,8170:1
Large Red Rocket Cluster~275~R~15992:1,8170:1
Large White Rocket Cluster~275~R~15992:1,8170:1
Large Yellow Rocket Cluster~275~R~15992:1,8170:1
Loot-A-Rang~275~R~12359:5,16203:5
Major Recombobulator~275~R~16000:2,18631:1,14047:2
Masterwork Target Dummy~275~R~10561:1,16000:1,15994:2,6037:1,8170:2,14047:4
Powerful Seaforium Charge~275~R~15994:2,15992:3,8170:2,159:1
SAF-T Clever Dynamite~275~R~15992:2,14047:3,260813:1
SAF-T Tube~275~R~12359:1,249726:1
Steam Tonk Controller~275~R~15994:2,10561:1,10558:1
Thorium Tube~275~R~12359:6
Tinker: Magnetic Displacement~280~R~238737:1,16006:1,4387:2
Tinker: Nitro Boosts~280~R~238737:1,16006:1,16000:1
Tinker: Teleport~280~R~238737:1,16006:1,15994:1
Ultrasafe Transporter: Gadgetzan~280~T~
Dark Iron Bomb~285~R~15994:2,11371:1,15992:3,14047:3
Delicate Arcanite Converter~285~R~12360:1,14227:1
Dimensional Ripper - Everlook~285~T~3860:10,18631:1,7077:4,7910:2,10586:1
EZ-Thro Shell~285~R~12359:2,249429:1
EZ-Thro Thorium Grenade~285~R~15994:1,12359:3,15992:3,14047:3,260815:1
Satchel of Dark Iron Bombs~285~R~16005:20,8170:6,10560:1
Thorium Shells~285~R~12359:2,15992:1
Hyper-Radiant Flame Reflector~290~R~11371:4,18631:3,7080:6,7910:4,12800:2
Master Engineer's Goggles~290~R~10500:1,12364:2,12810:4
Voice Amplification Modulator~290~R~16006:2,10558:1,15994:1,12799:1
Anarchist's Workbench~300~R~273129:1,15994:2
Arcane Bomb~300~R~16006:1,12359:3,14047:1
Arcanite Dragonling~300~R~10576:1,16006:8,12655:10,15994:6,10558:4,12810:6
Biznicks 247x128 Accurascope~300~R~17011:2,7076:2,16006:4,11371:6,16000:1
Bloodvine Goggles~300~R~19726:4,19774:5,16006:2,12804:8,12810:4
Bloodvine Lens~300~R~19726:5,19774:5,16006:1,12804:8,12810:4
Core Marksman Rifle~300~R~17010:4,17011:2,12360:6,16006:2,16000:2
Dimensional Transporter - Mt. Hyjal~300~R~3860:10,18631:1,7075:4,7082:4,251290:2
EZ and SAF Field Transporter: Mt. Hyjal~300~R~260823:1,260815:1,260813:1
EZ-Thro Dark Bomb~300~R~15994:2,11371:1,15992:3,14047:3,260815:1
EZ-Thro Field Transporter: Gadgetzan~300~R~18986:1,260815:1
EZ-Thro Magnetic Displacer~300~R~238788:1,260815:1
EZ-Thro Mana Bomb~300~R~16006:1,12359:3,14047:1,260815:1
Field Repair Bot 74A~300~R~12359:12,8170:4,7191:1,7067:2,7068:1
Flawless Arcanite Rifle~300~R~12360:10,16000:2,7078:2,7076:2,12800:2,12810:2
Force Reactive Disk~300~R~12360:6,16006:2,7082:8,12803:12,7076:8
Gnomish Poultryizer~300~R~16204:10,14344:2,249726:2,251290:2
Gnomish Weather Machine~300~R~7076:2,7078:2,7082:2,7080:2,248822:2
Hyper Deluxe Sniper Rifle Mk XVII~300~R~274030:4,251290:2,251291:10,12800:1
SAF-T Emergency Ripper: Everlook~300~R~18984:1,260813:2
SAF-T Nitro Boosts~300~R~238787:1,260813:2
SAF-T Teleport~300~R~238786:1,260813:2
SAF-T Ultra Precision Scope~300~R~251290:1,251291:12
Semisafe Transporter: New Avalon~300~R~16006:1,18631:2,10560:1,10561:2,10588:2,12811:1
Stealthman 52~300~R~7082:6,16204:6,248820:2,251290:2,248823:4
Swiftfeather Arrow~300~R~251291:8,17056:5,7069:1
Swiftstrike Shot~300~R~251291:8,12365:8,7067:1
Ultra-Flash Shadow Reflector~300~R~11371:8,18631:4,12803:6,12808:4,12800:2,12799:2
Ultralight Goblin Glider~300~R~249431:2,249726:2,249429:8,12359:8
Ultrasafe Rechargeable Battery~300~R~249410:2,249426:1,249431:1,12359:3,3860:1,248822:1
Arcane Megabomb~310~T~
G00 DV-1B3 Generator~310~R~
Obsidian Blasting Powder~310~R~
Obsidian Bomb~310~R~
The Fumigator~310~R~
Tuned Force Reactive Disk~310~R~
Fiery Core Sharpshooter Rifle~315~R~
Obsidian Scope~315~R~
Obsidian Shotgun~315~R~
Tranquil Mechanical Yeti~320~T~15407:1,15994:4,7079:2,18631:2,10558:1]==],
 ["First Aid"]=[==[
Minor Healing Potion~1~T~3371:1,2678:1,2447:1
First Aid Kit~20~T~1251:3,159:1
Linen Bandage~30~A~2589:1
Heavy Linen Bandage~40~T~2589:2
Lesser Healing Potion~55~T~3371:1,2678:2,2450:1
Anti-Venom~80~T~1475:1
Wool Bandage~80~T~2592:1
Simple Poultice~90~T~3174:1,2678:1,2723:1
Healing Potion~110~T~3372:1,2692:1,2453:1
Heavy Wool Bandage~115~T~2592:2
Woolen Tourniquet~120~T~2592:2,2321:2
Strong Anti-Venom~130~R~1288:1
Toxin Study~140~R~6452:1,8544:2,4470:2
Silk Bandage~150~T~4306:1
Clever Poultice~160~R~1468:1,3713:1,2686:1
Greater Healing Potion~175~R~3372:1,2692:3,3357:1
Heavy Silk Bandage~180~R~4306:2
Mageweave Bandage~210~R~4338:1
Leather Tourniquet~220~R~4304:2,4291:2
Superior Poultice~225~R~7070:1,2692:1,2596:1
Potent Anti-Venom~230~R~255645:1
Superior Healing Potion~230~R~8925:1,3713:1,8838:1
Heavy Mageweave Bandage~240~T~4338:2
Runecloth Bandage~260~T~14047:1
Surgical Tourniquet~280~R~8170:2,14047:2,8343:2
Crystal Infused Bandage~285~R~
Heavy Runecloth Bandage~290~T~14047:2
Major Healing Potion~290~R~8925:1,3713:3,13464:1
Powerful Poultice~295~R~7080:1,2692:1,2594:1
Dense Runecloth Bandage~300~R~
Plague Doctor's Laboratory~300~R~4470:2,6453:2,14530:5
Powerful Anti-Venom~300~R~19441:1]==],
 ["Leatherworking"]=[==[
Handstitched Leather Pants~15~T~2318:4,2320:1
Camp Tent~20~T~2318:5
Light Leather~20~A~2934:3
Handstitched Leather Belt~25~T~2318:6,2320:1
Light Leather Quiver~25~T~2318:4,2320:2
Small Leather Ammo Pouch~25~T~2318:3,2320:4
Cured Light Hide~30~T~783:1,4289:1
Light Armor Kit~30~A~2318:1
Light Leather Reagent Bag~30~R~2318:8,4231:1,2320:3
Rugged Leather Pants~30~R~2318:5,2320:5
Black Whelp Slippers~35~R~2318:12,4231:2,7286:2
Dark Leather Boots~35~R~2318:24,4231:2,4340:1
Embossed Leather Vest~35~T~2318:8,2320:4
Kodo Hide Bag~35~R~5082:3,2318:4,2320:1
Moonglow Boots~35~R~2318:12,4231:2,5498:1
Murloc Scale Shoes~35~R~2318:12,4231:2,5784:4
Embossed Leather Cloak~40~T~2318:5,2320:2
Embossed Leather Gloves~40~T~2318:3,2320:2
Handstitched Leather Boots~40~A~2318:2,2320:1
Handstitched Leather Bracers~40~A~2318:2,2320:3
Handstitched Leather Cloak~40~A~2318:2,2320:1
Handstitched Leather Vest~40~A~2318:3,2320:1
White Leather Jerkin~40~R~2318:8,2320:2,2324:1
Light Leather Bracers~45~T~2318:6,2320:4
Azure Gustwoven Belt~50~R~2318:5,2320:3
Azure Gustwoven Bracers~50~R~2318:4,2320:3
Azure Windraveled Armguards~50~R~2318:4,2320:3
Azure Windraveled Strap~50~R~2318:5,2320:3
Cloudy Gustwoven Belt~50~R~2318:5,2320:3
Cloudy Gustwoven Bracers~50~R~2318:4,2320:3
Cloudy Windraveled Armguards~50~R~2318:4,2320:3
Cloudy Windraveled Strap~50~R~2318:5,2320:3
Embossed Leather Boots~50~T~2318:8,2320:5
Embossed Leather Pants~50~T~4231:1,2318:6,2320:2
Fine Leather Cloak~50~T~2318:10,2321:2
Fine Leather Gloves~50~R~4231:1,2318:4,2320:2
Azure Gustwoven Boots~55~R~2318:6,2320:3
Azure Gustwoven Gloves~55~R~2318:6,2320:4
Azure Windraveled Footwraps~55~R~2318:6,2320:3
Azure Windraveled Mitts~55~R~2318:6,2320:4
Cloudy Gustwoven Boots~55~R~2318:6,2320:3
Cloudy Gustwoven Gloves~55~R~2318:6,2320:4
Cloudy Windraveled Footwraps~55~R~2318:6,2320:3
Cloudy Windraveled Mitts~55~R~2318:6,2320:4
Fine Leather Belt~55~T~2318:6,2320:2
Azure Gustwoven Harness~60~R~2318:7,4231:1,2320:2
Azure Gustwoven Trousers~60~R~2318:7,2320:2
Azure Windraveled Jerkin~60~R~2318:7,4231:1,2320:2
Azure Windraveled Pants~60~R~2318:7,2320:2
Brawler's Leather Belt~60~R~2318:10,4231:2,249427:2,2320:1,1210:1
Cloudy Gustwoven Harness~60~R~2318:7,4231:1,2320:2
Cloudy Gustwoven Trousers~60~R~2318:7,2320:2
Cloudy Windraveled Jerkin~60~R~2318:7,4231:1,2320:2
Cloudy Windraveled Pants~60~R~2318:7,2320:2
Defender's Leather Belt~60~R~2318:10,4231:2,249427:2,2320:1,2458:1
Fine Leather Tunic~60~T~4231:3,2318:6,2320:4
Stormrider's Leather Belt~60~R~2318:10,4231:2,249427:2,2320:1,249409:1
Totemic Leather Belt~60~R~2318:10,4231:2,249427:2,2320:1,249410:1
Trapper's Leather Belt~60~R~2318:10,4231:2,249427:2,2320:1,6470:1
Wisdom's Leather Belt~60~R~2318:10,4231:2,249427:2,2320:1,5498:1
Deviate Scale Cloak~65~R~6470:8,4231:1,2321:1
Fine Leather Boots~65~R~2318:7,2320:2
Moonglow Vest~65~R~2318:6,4231:1,2320:4,5498:1
Murloc Scale Belt~65~R~5784:8,2318:6,2321:1
Light Leather Pants~70~T~2318:10,4231:1,2321:1
Murloc Scale Breastplate~70~R~5784:12,4231:1,2318:8,2321:1
Black Whelp Cloak~75~R~7286:12,2319:4,2321:1
Black Whelp Tunic~75~R~2319:8,7286:8,4231:1,2321:2
Brawler's Leather Armor~75~R~2318:16,4231:2,1210:1
Brawler's Leather Gloves~75~R~2318:12,4231:3,249427:2,2321:1,1210:2
Cured Medium Hide~75~T~4232:1,4289:1
Dark Leather Tunic~75~R~2319:6,2321:1,4340:1
Defender's Leather Armor~75~R~2318:16,4231:2,2458:1
Defender's Leather Gloves~75~R~2318:12,4231:3,249427:2,2321:1,2458:2
Gray Leather Boots~75~T~2319:4,2321:2,4340:1
Hillman's Leather Vest~75~R~4243:1,4231:2,2320:2
Medium Armor Kit~75~T~2319:4,2320:1
Medium Leather~75~T~2318:4
Stormrider's Leather Armor~75~R~2318:16,4231:2,249409:1
Stormrider's Leather Gloves~75~R~2318:12,4231:3,249427:2,2321:1,249409:2
Totemic Leather Armor~75~R~2318:16,4231:2,249410:1
Totemic Leather Gloves~75~R~2318:12,4231:3,249427:2,2321:1,249410:2
Trapper's Leather Armor~75~R~2318:16,4231:2,6470:1
Trapper's Leather Gloves~75~R~2318:12,4231:3,249427:2,2321:1,6470:2
Wisdom's Leather Armor~75~R~2318:16,4231:2,5498:1
Wisdom's Leather Gloves~75~R~2318:12,4231:3,249427:2,2321:1,5498:2
Deviate Scale Gloves~80~R~6471:2,6470:6,2321:2
Fine Leather Pants~80~R~2319:8,2997:1,2321:1
Forceful Medium Armor Kit~80~R~2313:1,10940:2,2454:2
Mystic Medium Armor Kit~80~R~2313:1,10940:2,2455:2
Brawler's Leather Boots~85~R~2318:14,4231:4,249427:3,2321:1,1210:3
Dark Leather Cloak~85~T~2319:8,2321:1,4340:1
Defender's Leather Boots~85~R~2318:14,4231:4,249427:3,2321:1,2458:3
Stormrider's Leather Boots~85~R~2318:14,4231:4,249427:3,2321:1,249409:3
Totemic Leather Boots~85~R~2318:14,4231:4,249427:3,2321:1,249410:3
Trapper's Leather Boots~85~R~2318:14,4231:4,249427:3,2321:1,6470:3
Wisdom's Leather Boots~85~R~2318:14,4231:4,249427:3,2321:1,5498:3
Dark Leather Pants~90~T~2319:12,4340:1,2321:1
Deviate Scale Belt~90~R~6471:10,6470:10,2321:2
Dark Leather Gloves~95~R~2312:1,4233:1,2321:1,4340:1
Hillman's Belt~95~R~2319:8,3383:1,2321:2
Nimble Leather Gloves~95~T~2457:1,2319:6,2321:1
Red Whelp Gloves~95~R~7287:6,2319:4,2321:1
Toughened Leather Armor~95~T~2319:10,4231:2,2321:2
Brawler's Leather Hood~100~R~2319:8,4233:2,249427:4,2321:2,1210:4
Brawler's Leather Pants~100~R~2319:8,4231:4,1210:2
Dark Leather Belt~100~T~4246:1,4233:1,2321:2,4340:1
Defender's Leather Hood~100~R~2319:8,4233:2,249427:4,2321:2,2458:4
Defender's Leather Pants~100~R~2319:8,4231:4,2458:2
Fletcher's Gloves~100~T~2319:8,5116:4,2321:2
Stormrider's Leather Hood~100~R~2319:8,4233:2,249427:4,2321:2,249409:4
Stormrider's Leather Pants~100~R~2319:8,4231:4,249409:2
Totemic Leather Hood~100~R~2319:8,4233:2,249427:4,2321:2,249410:4
Totemic Leather Pants~100~R~2319:8,4231:4,249410:2
Trapper's Leather Hood~100~R~2319:8,4233:2,249427:4,2321:2,6470:4
Trapper's Leather Pants~100~R~2319:8,4231:4,6470:2
Wisdom's Leather Hood~100~R~2319:8,4233:2,249427:4,2321:2,5498:4
Wisdom's Leather Pants~100~R~2319:8,4231:4,5498:2
Hillman's Shoulders~105~T~4233:1,2319:4,2321:1
Brawler's Leather Tunic~110~R~2319:10,4233:3,249427:6,2321:3,1210:6
Defender's Leather Tunic~110~R~2319:10,4233:3,249427:6,2321:3,2458:6
Earthen Leather Shoulders~110~R~2319:6,7067:1,2321:2
Herbalist's Gloves~110~R~2319:8,3356:4,2321:2
Hillman's Leather Boots~110~R~4233:1,2319:6,2321:1
Stormrider's Leather Tunic~110~R~2319:10,4233:3,249427:6,2321:3,249409:6
Totemic Leather Tunic~110~R~2319:10,4233:3,249427:6,2321:3,249410:6
Toughened Leather Gloves~110~T~2319:4,4233:2,3389:2,3182:2,2321:2
Trapper's Leather Tunic~110~R~2319:10,4233:3,249427:6,2321:3,6470:6
Wisdom's Leather Tunic~110~R~2319:10,4233:3,249427:6,2321:3,5498:6
Dark Leather Shoulders~115~R~2319:12,3390:1,4340:1,2321:2
Pilferer's Gloves~115~R~2319:10,5373:2,2321:2
Heavy Earthen Gloves~120~R~2319:12,7067:2,2997:2,2321:2
Hillman's Leather Gloves~120~T~2319:14,2321:4
Barbaric Gloves~125~R~4234:6,5637:2,2321:1
Brawler's Leather Helm~125~R~2319:12,4233:2,1210:3
Brawler's Leather Legguards~125~R~2319:12,4233:4,249427:8,2321:3,1210:8
Cured Heavy Hide~125~T~4235:1,4289:3
Defender's Leather Helm~125~R~2319:12,4233:2,2458:3
Defender's Leather Kilt~125~R~2319:12,4233:4,249427:8,2321:3,2458:8
Heavy Armor Kit~125~T~4234:5,2321:1
Heavy Leather~125~T~2319:5
Heavy Leather Ammo Pouch~125~T~4234:8,2321:2
Heavy Quiver~125~T~4234:8,2321:2
Hillman's Cloak~125~T~4234:5,2321:2
Stormrider's Leather Helm~125~R~2319:12,4233:2,249409:3
Stormrider's Leather Kilt~125~R~2319:12,4233:4,249427:8,2321:3,249409:8
Tanning Rack~125~R~2319:5,2321:3,4470:2
Totemic Leather Helm~125~R~2319:12,4233:2,249410:3
Totemic Leather Leggings~125~R~2319:12,4233:4,249427:8,2321:3,249410:8
Trapper's Leather Helm~125~R~2319:12,4233:2,6470:3
Trapper's Leather Legguards~125~R~2319:12,4233:4,249427:8,2321:3,6470:8
Wisdom's Leather Helm~125~R~2319:12,4233:2,5498:3
Wisdom's Leather Leggings~125~R~2319:12,4233:4,249427:8,2321:3,5498:8
Barbaric Bracers~130~R~4234:8,4236:2,5498:4,4461:1,5637:4
Green Leather Armor~130~R~4234:9,2605:2,2321:4
Forceful Heavy Armor Kit~135~R~4265:1,11083:2,6662:2
Green Leather Belt~135~T~4236:1,4234:5,2321:1,2605:1,7071:1
Guardian Pants~135~T~4234:12,4305:2,2321:2
Mystic Heavy Armor Kit~135~R~4265:1,11083:2,3385:2
Dusky Leather Leggings~140~R~4234:10,2325:1,2321:2
Raptor Hide Belt~140~R~4461:4,4234:4,2321:2
Raptor Hide Harness~140~R~4461:6,4234:4,2321:2
Void-Touched Leather Gauntlets~140~T~
Void-Touched Leather Gloves~140~T~
Barbaric Leggings~145~R~4234:10,2321:2,1206:1
Guardian Belt~145~R~4236:2,4234:4,2321:1,7071:1
Thick Murloc Armor~145~R~5785:12,4236:1,4234:10,2321:3
Barbaric Shoulders~150~T~4234:8,4236:1,2321:2
Dusky Leather Armor~150~T~4234:10,3824:1,2321:2
Green Whelp Armor~150~R~7392:4,4234:10,2321:2
Guardian Armor~150~R~4236:2,4234:12,3824:1,2321:2
Heavy Leather Ball~150~R~4234:2,2321:1
Mender's Leather Belt~150~R~4234:8,4233:2,5500:1
Prowler's Leather Belt~150~R~4234:8,4233:2,1529:1
Skirmisher's Leather Belt~150~R~4234:8,4233:2,3864:1
Skulker's Leather Belt~150~R~4234:8,4233:2,3182:1
Skycaller's Leather Belt~150~R~4234:8,4233:2,7070:1
Stalker's Leather Belt~150~R~4234:8,4233:2,7069:1
Warden's Leather Belt~150~R~4234:8,4233:2,7067:1
Frost Leather Cloak~155~T~4234:6,7067:2,7070:2,2321:2
Green Leather Bracers~155~T~4236:2,4234:6,2605:1,2321:1
Dusky Bracers~160~T~4234:16,2325:1,4291:2
Gem-studded Leather Belt~160~R~4236:4,5500:2,1529:2,3864:1,2321:1
Guardian Cloak~160~R~4234:14,4305:2,4291:2
Barbaric Harness~165~T~4234:14,2321:2,7071:1
Gloves of the Greatfather~165~R~4234:8,7067:4,4291:1
Green Whelp Bracers~165~R~7392:6,4234:8,4291:2
Guardian Gloves~165~T~4234:4,4236:1,4291:1
Murloc Scale Bracers~165~T~5785:16,4236:1,4234:14,4291:1
Dusky Belt~170~T~4234:10,4305:2,2325:2,7071:1
Guardian Leather Bracers~170~R~4234:6,4236:2,4291:1
Azure Gustwoven Hood~175~R~4234:15,4236:3,8343:1,6260:4
Azure Gustwoven Spaulders~175~R~4234:12,4236:2,8343:1,6260:3
Azure Windraveled Cover~175~R~4234:15,4236:3,8343:1,6260:4
Azure Windraveled Drapes~175~R~4234:12,4236:2,8343:1,6260:3
Barbaric Belt~175~R~4234:6,4236:2,4096:2,5633:1,4291:1,7071:1
Cloudy Gustwoven Hood~175~R~4234:15,4236:3,8343:1,2324:8
Cloudy Gustwoven Spaulders~175~R~4234:12,4236:2,8343:1,2324:6
Cloudy Windraveled Cover~175~R~4234:15,4236:3,8343:1,2324:8
Cloudy Windraveled Drapes~175~R~4234:12,4236:2,8343:1,2324:6
Comfortable Leather Hat~175~R~4234:12,4236:2,4291:2
Cured Thick Hide~175~T~8169:1,8150:1
Dusky Boots~175~R~4234:8,7428:2,3824:1,4291:2
Mender's Leather Gloves~175~R~4234:16,4236:2,249428:2,4291:2,5500:2,249427:1
Prowler's Leather Gloves~175~R~4234:16,4236:2,249428:2,4291:2,1529:2,249427:1
Shadowskin Gloves~175~R~4304:6,7428:8,7971:2,4236:2,1210:4,8343:1
Skirmisher's Leather Gloves~175~R~4234:16,4236:2,249428:2,4291:2,3864:2,249427:1
Skulker's Leather Gloves~175~R~4234:16,4236:2,249428:2,4291:2,3182:2,249427:1
Skycaller's Leather Gloves~175~R~4234:16,4236:2,249428:2,4291:2,7070:2,249427:1
Stalker's Leather Gloves~175~R~4234:16,4236:2,249428:2,4291:2,7069:2,249427:1
Swift Boots~175~R~4234:10,2459:2,4337:2,4291:1
Thick Armor Kit~175~T~4304:5,4291:1
Thick Leather~175~T~4234:6
Warden's Leather Gloves~175~R~4234:16,4236:2,249428:2,4291:2,7067:2,249427:1
Nightscape Headband~180~T~4304:5,4291:2
Nightscape Tunic~180~T~4304:7,4291:2
Turtle Scale Gloves~180~R~4304:6,8167:8,8343:1
Forceful Thick Armor Kit~185~R~8173:1,11137:2,3391:2
Mystic Thick Armor Kit~185~R~8173:1,11137:2,3827:2
Nightscape Shoulders~185~R~4304:8,4338:6,4291:3
Turtle Scale Bracers~185~T~4304:8,8167:12,8343:1
Turtle Scale Breastplate~185~T~4304:6,8167:12,8343:1
Big Voodoo Robe~190~R~4304:10,8151:4,8343:1
Big Voodoo Mask~195~R~4304:8,8151:6,8343:1
Tough Scorpid Bracers~195~R~4304:10,8154:4,4291:2
Tough Scorpid Breastplate~195~R~4304:12,8154:12,4291:4
Wild Leather Shoulders~195~R~4304:10,8153:1,8172:1
Faintly Glowing Leather~200~R~
Mender's Leather Shoes~200~R~4234:8,4233:2,5500:2
Mender's Mail Boots~200~R~4234:8,4233:2,5500:2
Prowler's Leather Shoes~200~R~4234:8,4233:2,1529:2
Quickdraw Quiver~200~T~4304:12,8172:1,8949:1,4291:4
Skirmisher's Mail Boots~200~R~4234:8,4233:2,3864:2
Skulker's Leather Shoes~200~R~4234:8,4233:2,3182:2
Skycaller's Leather Shoes~200~R~4234:8,4233:2,7070:2
Skycaller's Mail Boots~200~R~4234:8,4233:2,7070:2
Stalker's Mail Boots~200~R~4234:8,4233:2,7069:2
Thick Leather Ammo Pouch~200~T~4304:10,8172:1,8951:1,4291:6
Tough Scorpid Gloves~200~R~4304:6,8154:8,4291:2
Warden's Leather Shoes~200~R~4234:8,4233:2,7067:2
Wild Leather Helmet~200~R~4304:10,8153:2,8172:1
Wild Leather Vest~200~R~4304:12,8153:2,8172:1
Wolfshead Helm~200~T~4304:18,8368:2,8146:8,8343:4,8172:2
Nightscape Cloak~205~R~
Nightscape Pants~205~T~4304:14,4291:4
Turtle Scale Helm~205~T~4304:14,8167:24,8343:1
Mender's Leather Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,5500:3,249427:2
Mender's Mail Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,5500:3,249427:2
Nightscape Boots~210~T~4304:16,8343:2
Prowler's Leather Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,1529:3,249427:2
Skirmisher's Mail Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,3864:3,249427:2
Skulker's Leather Shoulder~210~R~
Skycaller's Leather Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,7070:3,249427:2
Skycaller's Mail Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,7070:3,249427:2
Stalker's Mail Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,7069:3,249427:2
Tough Scorpid Boots~210~R~4304:12,8154:12,4291:6
Turtle Scale Leggings~210~T~4304:14,8167:28,8343:1
Warden's Leather Shoulders~210~R~4304:10,4236:3,249428:4,4291:2,7067:3,249427:2
Big Voodoo Cloak~215~R~4304:14,8152:4,8343:2
Big Voodoo Pants~215~R~4304:10,8152:6,8343:2
Tough Scorpid Shoulders~215~R~4304:12,8154:16,8343:2
Tough Scorpid Leggings~220~R~4304:14,8154:8,8343:2
Wild Leather Boots~220~R~4304:14,8153:4,8172:2
Cured Rugged Hide~225~T~8171:1,15409:1
Dragonscale Gauntlets~225~T~4304:24,8165:12,8343:4,8172:2
Feathered Breastplate~225~T~4304:40,8168:40,7971:2,8172:4,8343:4
Glowing Gneuro-Linked Cowl~225~R~
Glowing Hyperconductive Scale Coif~225~R~
Gneuro-Conductive Channeler's Hood~225~R~
Mender's Leather Bracers~225~R~4304:12,4236:4,249428:6,8343:2,5500:4,249427:3
Mender's Mail Bracers~225~R~4304:12,4236:4,249428:6,8343:2,5500:4,249427:3
Prowler's Leather Bracers~225~R~4304:12,4236:4,249428:6,8343:2,1529:4,249427:3
Rad-Resistant Scale Hood~225~R~
Rugged Armor Kit~225~T~8170:5
Rugged Leather~225~T~4304:6
Skirmisher's Mail Bracers~225~R~4304:12,4236:4,249428:6,8343:2,3864:4,249427:3
Skulker's Leather Bracers~225~R~4304:12,4236:4,249428:6,8343:2,3182:4,249427:3
Skycaller's Leather Bracers~225~R~4304:12,4236:4,249428:6,8343:2,7070:4,249427:3
Skycaller's Mail Bracers~225~R~4304:12,4236:4,249428:6,8343:2,7070:4,249427:3
Stalker's Mail Bracers~225~R~4304:12,4236:4,249428:6,8343:2,7069:4,249427:3
Tough Scorpid Helm~225~R~4304:10,8154:20,8343:2
Warden's Leather Bracers~225~R~4304:12,4236:4,249428:6,8343:2,7067:4,249427:3
Wild Leather Cloak~225~R~4304:16,8153:2,8172:2
Wild Leather Leggings~225~R~4304:16,8153:2,8172:2
Cacophonous Chain Shoulderguards~230~T~
Charged Scorpid Belt~230~R~8170:6,15408:6,14341:1
Gauntlets of the Sea~230~T~4304:20,7079:8,7075:2,8172:1,8343:4
Membrane of Dark Neurosis~230~T~
Paranoia Mantle~230~T~
Screaming Chain Pauldrons~230~T~
Shoulderpads of Obsession~230~T~
Shrieking Spaulders~230~T~
Supple Scorpid Boots~230~R~8170:12,15408:4,14341:1
Wailing Chain Mantle~230~T~
Blue Suede Shoes~235~R~8170:8,14341:1,6260:1
Forceful Rugged Armor Kit~235~R~15564:1,11176:2,9206:2,249429:1,248824:1
Green Dragonscale Breastplate~235~R~8170:20,15412:25,14341:2
Mender's Leather Boots~235~R~4304:16,8172:2,249428:8,8343:2,5500:6,249427:4
Mender's Mail Sabatons~235~R~4304:16,8172:2,249428:8,8343:2,5500:6,249427:4
Mystic Rugged Armor Kit~235~R~15564:1,11176:2,13444:2,249429:1,248824:1
Prowler's Leather Boots~235~R~4304:16,8172:2,249428:8,8343:2,1529:6,249427:4
Skirmisher's Mail Sabatons~235~R~4304:16,8172:2,249428:8,8343:2,3864:6,249427:4
Skulker's Leather Boots~235~R~4304:16,8172:2,249428:8,8343:2,3182:6,249427:4
Skycaller's Leather Boots~235~R~4304:16,8172:2,249428:8,8343:2,7070:6,249427:4
Skycaller's Mail Sabatons~235~R~4304:16,8172:2,249428:8,8343:2,7070:6,249427:4
Stalker's Mail Sabatons~235~R~4304:16,8172:2,249428:8,8343:2,7069:6,249427:4
Tooled Leather Belt~235~R~8170:8,14341:1,6261:1
Warden's Leather Boots~235~R~4304:16,8172:2,249428:8,8343:2,7067:6,249427:4
Wicked Leather Gauntlets~235~R~8170:8,2325:1,14341:1
Blue Suede Gloves~240~R~8170:8,14341:1,6260:1
Charged Scorpid Helm~240~R~8170:4,15408:6,14341:1,7069:2
Chimeric Gloves~240~R~8170:6,15423:6,14341:1
Heavy Scorpid Vest~240~R~8170:6,15408:6,14341:1
Supple Scorpid Leggings~240~R~8170:9,15408:4,14341:1
Tooled Leather Boots~240~R~8170:8,14341:1,6261:1
Wicked Leather Bracers~240~R~8170:8,2325:1,14341:1
Green Dragonscale Leggings~245~R~8170:20,15412:25,14341:1
Ironfeather Shoulders~245~R~8170:24,15420:80,1529:2,14341:1
Living Shoulders~245~R~8170:12,12803:4,14341:1
Runic Leather Gauntlets~245~R~8170:10,14047:6,14341:1
Volcanic Leggings~245~R~8170:6,7078:1,7075:1,14341:1
Charged Scorpid Shoulders~250~R~8170:4,15408:8,14341:1,7069:2
Chimeric Boots~250~R~8170:4,15423:8,14341:1
Frostsaber Boots~250~R~8170:4,15422:6,14341:1
Heavy Scorpid Gauntlet~250~R~
Helm of Fire~250~T~4304:40,7077:8,7075:4,8172:2,8343:4
Mender's Leather Gauntlets~250~R~4304:16,8172:2,5500:4
Mender's Leather Waistguard~250~R~8170:12,8172:4,249428:10,8343:2,5500:8,249427:5
Mender's Mail Belt~250~R~8170:12,8172:4,249428:10,8343:2,5500:8,249427:5
Mender's Mail Gauntlets~250~R~4304:16,8172:2,5500:4
Prowler's Leather Gauntlets~250~R~4304:16,8172:2,1529:4
Prowler's Leather Waistguard~250~R~8170:12,8172:4,249428:10,8343:2,1529:8,249427:5
Runic Leather Bracers~250~R~8170:6,7971:1,14047:6,14341:1
Scarlet Huntsman's Clasp~250~R~
Scarlet Huntsman's Wristguards~250~R~
Scarlet Infiltrator's Belt~250~R~
Scarlet Infiltrator's Bracers~250~R~
Skirmisher's Mail Belt~250~R~8170:12,8172:4,249428:10,8343:2,3864:8,249427:5
Skirmisher's Mail Gauntlets~250~R~4304:16,8172:2,3864:4
Skulker's Leather Gauntlets~250~R~4304:16,8172:2,3182:4
Skulker's Leather Waistguard~250~R~8170:12,8172:4,249428:10,8343:2,3182:8,249427:5
Skycaller's Leather Gauntlets~250~R~4304:16,8172:2,7070:4
Skycaller's Leather Waistguard~250~R~8170:12,8172:4,249428:10,8343:2,7070:8,249427:5
Skycaller's Mail Belt~250~R~8170:12,8172:4,249428:10,8343:2,7070:8,249427:5
Skycaller's Mail Gauntlets~250~R~4304:16,8172:2,7070:4
Stalker's Mail Belt~250~R~8170:12,8172:4,249428:10,8343:2,7069:8,249427:5
Stalker's Mail Gauntlets~250~R~4304:16,8172:2,7069:4
Stormshroud Pants~250~R~8170:16,7080:2,7082:2,14341:1
Supple Scorpid Bracers~250~R~8170:7,15408:2,14341:1
Warbear Harness~250~R~8170:28,15419:12,14341:1
Warden's Leather Gauntlets~250~R~4304:16,8172:2,7067:4
Warden's Leather Waistguard~250~R~8170:12,8172:4,249428:10,8343:2,7067:8,249427:5
Blue Suede Pants~255~R~8170:14,14341:1,6260:3,15407:1
Charged Scorpid Bracers~255~R~8170:2,15408:4,14341:1,7069:2
Charged Scorpid Gauntlets~255~R~8170:4,15408:8,14341:1,7069:2
Chimeric Leggings~255~R~8170:8,15423:8,14341:1
Dragonscale Breastplate~255~T~4304:40,8165:30,8343:4,8172:4
Heavy Scorpid Belt~255~T~8170:6,15408:8,14341:1
Heavy Scorpid Boots~255~R~8170:6,15408:8,14341:1
Heavy Scorpid Bracers~255~R~8170:4,15408:4,14341:1
Runic Leather Belt~255~R~8170:12,14047:10,14341:1
Supple Scorpid Belt~255~R~8170:9,15408:6,14341:1
Supple Scorpid Shoulders~255~R~8170:9,15408:6,14341:1
Tooled Leather Armor~255~R~8170:16,14341:1,6261:3,15407:2,13423:6
Wicked Leather Headband~255~R~8170:12,2325:1,14341:1
Blue Dragonscale Breastplate~260~R~8170:28,15415:30,15407:1,14341:1
Blue Suede Shoulders~260~R~8170:10,14341:1,6260:2
Charged Scorpid Vest~260~R~8170:6,15408:12,14341:1,7069:2
Frostsaber Leggings~260~R~8170:6,15422:8,14341:1
Heavy Scorpid Leggings~260~R~8170:8,15408:12,14341:1
Living Green Dragonscale Breastplate~260~R~
Living Leggings~260~R~8170:16,12803:6,15407:1,14341:1
Scarlet Huntsman's Boots~260~R~
Scarlet Huntsman's Handguards~260~R~
Scarlet Infiltrator's Gloves~260~R~
Scarlet Infiltrator's Shoes~260~R~
Stormshroud Armor~260~R~8170:16,7080:3,7082:3,15407:1,14341:1
Supple Scorpid Helm~260~R~8170:11,15408:10,14341:1
Tooled Leather Gauntlets~260~R~8170:10,14341:1,6261:1
Volcanic Breastplate~260~R~8170:8,7078:1,7076:1,14341:1
Warbear Woolies~260~R~8170:24,15419:14,14341:1
Wicked Leather Boots~260~R~8170:10,14341:1,2325:1
Black Dragonscale Breastplate~265~R~8170:40,15416:60,15407:1,14341:2
Blue Suede Armor~265~R~8170:14,15407:2,14341:2,6260:4,15415:6
Chimeric Vest~265~R~8170:10,15423:10,14341:1
Dawn Treaders~265~R~8170:30,12809:2,7080:4,15407:2,14341:2
Devilsaur Gauntlets~265~R~8170:30,15417:8,14341:1
Ironfeather Breastplate~265~R~8170:40,15420:120,1529:1,15407:1,14341:1
Might of the Timbermaw~265~R~8170:30,12804:2,12803:4,15407:2,14341:2
Runic Leather Headband~265~R~8170:14,14047:10,14341:1
Synthetic Gordok Ogre Suit~265~R~
Tooled Leather Crown~265~R~8170:14,14341:1,6261:1
Wicked Leather Pants~265~R~8170:16,15407:1,2325:3,14341:1
Black Dragonscale Shoulders~270~R~8170:44,15416:45,12810:2,15407:1,14341:1
Blue Dragonscale Shoulders~270~R~8170:28,15415:30,12810:2,15407:1,14341:1
Blue Suede Belt~270~R~8170:14,14341:1,6260:2
Charged Scorpid Leggings~270~R~8170:12,15408:14,14341:1,7069:2
Frostsaber Gloves~270~R~8170:6,15422:10,14341:1
Heavy Scorpid Helm~270~R~8170:8,15408:12,15407:1,14341:1
Living Green Dragonscale Gauntlets~270~R~
Living Green Dragonscale Leggings~270~R~
Masterwork Volcanic Leggings~270~R~
Scarlet Huntsman's Legguards~270~R~
Scarlet Infiltrator's Trousers~270~R~
Stormshroud Shoulders~270~R~8170:12,7080:3,7082:3,12810:2,14341:1
Supple Scorpid Vest~270~R~8170:20,15408:10,14341:1
Tooled Leather Bracers~270~R~8170:10,14341:1,6261:1
Wicked Leather Shoulders~270~R~8170:12,14341:1,2325:1,15407:1
Wildthorn Mail~270~R~8170:40,12810:2,12803:4,8153:4,12364:1,14341:1
Blue Suede Bracers~275~R~8170:10,14341:1,6260:1
Runic Leather Pants~275~R~8170:18,14047:12,12810:2,14341:1
Scarlet Ammo Pouch~275~R~
Scarlet Quiver~275~R~
Tooled Leather Epaulets~275~R~8170:12,14341:1,6261:1,15407:1
Wicked Leather Belt~275~R~8170:14,2325:2,14341:2
Blue Suede Hat~280~R~8170:16,14341:1,6260:4
Charged Scorpid Boots~280~R~8170:12,15408:14,14341:1,7069:2
Green Dragonscale Gauntlets~280~T~8170:20,15412:30,15407:1,14341:2
Heavy Scorpid Shoulders~280~R~8170:14,15408:14,15407:1,14341:2
Scarlet Huntsman's Chain~280~R~
Scarlet Huntsman's Coif~280~R~
Scarlet Huntsman's Pauldrons~280~R~
Scarlet Infiltrator's Bandana~280~R~
Scarlet Infiltrator's Shoulderpads~280~R~
Scarlet Infiltrator's Vest~280~R~
Supple Scorpid Sabatons~280~R~8170:20,15408:10,14341:1
Tooled Leather Pants~280~R~8170:18,14341:1,6261:1,15407:1
Volcanic Shoulders~280~R~8170:10,7078:1,7076:1,14341:2
Wicked Leather Armor~280~R~8170:20,15407:2,14256:6,2325:4,14341:2
Bileblister Claws~285~R~8170:12,12810:3,7082:3,14341:6
Broodwatcher's Clenchers~285~R~15408:5,12810:3,7080:3,14341:6
Gordok Ogre Suit~285~T~8170:4,14048:2,18240:1,14341:1
Hivethrasher's Claws~285~R~8170:12,12810:3,7076:3,14341:6
Honed Blue Dragonscale Breastplate~285~R~
Masterwork Volcanic Breastplate~285~R~
Runic Leather Armor~285~R~8170:22,12810:4,14047:16,15407:1,14341:2
Runic Leather Shoulders~285~R~8170:16,12810:4,14047:18,15407:1,14341:2
Scalegut Clenchers~285~R~15408:5,12810:3,7078:3,14341:6
Winter Boots~285~R~2840:1,2997:1,8170:4,14341:1
Bileblister Girdle~290~R~8170:18,12810:3,7082:3,14341:6
Black Dragonscale Leggings~290~R~8170:40,15416:60,12810:4,15407:1,14341:2
Broodwatcher's Belt~290~R~15408:7,12810:3,7080:3,14341:6
Devilcore Gauntlets~290~R~
Devilsaur Leggings~290~R~8170:30,15417:14,15407:1,14341:1
Frostsaber Tunic~290~R~8170:12,15422:12,15407:1,14341:2
Girdle of Insight~290~R~8170:12,12804:12,15407:2,14341:4
Hardened Black Dragonscale Breastplate~290~R~
Heavy Timbermaw Belt~290~R~8170:12,7076:3,12803:3,14341:1
Hivethrasher's Girdle~290~R~8170:18,12810:3,7076:3,14341:6
Living Breastplate~290~R~8170:16,12803:8,14342:2,15407:1,14341:2
Mongoose Boots~290~R~8170:12,7082:6,11754:4,15407:2,14341:4
Red Dragonscale Breastplate~290~R~8170:40,15414:30,14341:1
Scalegut Belt~290~R~15408:7,12810:3,7078:3,14341:6
Stormshroud Gloves~290~R~12810:6,7080:4,7082:4,15407:2,14227:2
Swift Flight Bracers~290~R~8170:12,18512:8,15420:60,15407:4,14341:4
Bileblister Boots~295~R~8170:15,12810:3,7082:3,14341:6
Broodwatcher's Treaders~295~R~15408:6,12810:3,7080:3,14341:6
Corehound Boots~295~R~17012:20,17010:6,17011:2,14341:2
Hivethrasher's Boots~295~R~8170:15,12810:3,7076:3,14341:6
Honed Blue Dragonscale Shoulders~295~R~
Scalegut Treaders~295~R~15408:6,12810:3,7078:3,14341:6
Storm Gauntlets~295~R~8170:20,12810:4,7080:4,12361:4,14341:1
Timbermaw Brawlers~295~R~12810:8,12804:6,12803:6,15407:2,14227:2
Black Dragonscale Boots~300~R~12810:6,15416:30,17010:4,17011:3,14341:2
Black Dragonscale Helm~300~R~8170:20,15416:40,12810:12,15407:4,249429:10,14341:2,248825:20
Blood Tiger Breastplate~300~R~19768:35,19726:2,15407:3,14341:3
Blood Tiger Shoulders~300~R~19768:25,19726:2,15407:3,14341:3
Blue Dragonscale Helm~300~R~8170:20,15415:40,12810:12,15407:6,249429:10,14341:2,248825:20
Blue Dragonscale Leggings~300~T~8170:28,15415:36,15407:2,14341:2
Brilliant Chromatic Cloak~300~R~
Chromatic Cloak~300~R~8170:30,12607:12,15416:30,15414:30,15407:5,14341:8
Chromatic Gauntlets~300~R~17010:5,17011:2,17012:4,12607:4,15407:4,14227:4
Core Armor Kit~300~R~17012:3,14341:2
Corehound Belt~300~R~17010:8,17012:12,12810:10,15407:4,14227:4
Dawn Armor~300~R~12810:6,12809:10,7080:20,249429:10,15407:4,14341:10,248825:20
Devilcore Leggings~300~R~
Dreamscale Kilt~300~R~
Elderwild Pants~300~R~274030:3,248824:2,248825:18
Elderwild Waistcord~300~R~274030:2,248824:1,248825:12
Eternity Pauldrons~300~R~274030:2,248824:1,248825:12
Girdle of Arcane Insight~300~R~
Glowing Chitin Armor Kit~300~R~
Golden Mantle of the Dawn~300~R~12810:8,12803:4,12809:4,15407:2,14341:2
Grimstitch Boots~300~R~274030:3,15407:2,248825:18,14341:8
Grimstitch Gloves~300~R~274030:3,15407:2,248825:18,14341:8
Grimstitch Pants~300~R~274030:5,15407:4,248825:24,14341:8
Grimstitch Spaulders~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Boots~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Gauntlets~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Grips~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Handguards~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Kilt~300~R~274030:5,15407:4,248825:24,14341:8
Grovekeeper Leggings~300~R~274030:5,15407:4,248825:24,14341:8
Grovekeeper Legguards~300~R~274030:5,15407:4,248825:24,14341:8
Grovekeeper Mantle~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Mitts~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Pauldrons~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Sandals~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Shoulderpads~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Spaulders~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Stompers~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Treads~300~R~274030:3,15407:2,248825:18,14341:8
Grovekeeper Trousers~300~R~274030:5,15407:4,248825:24,14341:8
Hardened Black Dragonscale Leggings~300~R~
Hardened Black Dragonscale Shoulders~300~R~
Heavy Timbermaw Boots~300~R~8170:20,7076:6,12803:6,14341:1
Helm of the Great Chief~300~R~8170:40,12810:4,8168:60,12799:6,12364:2,14341:1
Hide of the Wild~300~R~8170:30,12803:12,7080:10,18512:8,15407:3,14341:8
Honed Blue Dragonscale Leggings~300~T~
Invulnerable Mail~300~R~249427:20,12810:30,12364:6,12800:6,249429:10,14341:2
Ironfeather Leggings~300~R~8170:20,15420:120,1529:4,15407:2,14341:4,249429:10,248825:20
Lava Belt~300~R~17011:5,15407:4,14227:4
Living Crown~300~R~8170:20,12803:20,7080:20,249429:10,15407:4,14341:10,248825:20
Mastercrafted Shifting Cloak~300~R~
Masterwork Volcanic Shoulders~300~R~
Molten Belt~300~R~17010:2,17011:7,7076:6,15407:4,14227:4
Molten Helm~300~R~17012:15,17010:3,17011:6,14341:2
Mourning Handguards~300~R~274030:2,248824:1,248825:12
Onyxia Scale Breastplate~300~R~
Outlaw's Collar~300~R~274030:3,248824:2,248825:22
Primal Batskin Bracers~300~R~19767:8,15407:3,12803:4,14341:3
Primal Batskin Gloves~300~R~19767:10,15407:4,12803:4,14341:3
Primal Batskin Jerkin~300~R~19767:14,15407:5,12803:4,14341:4
Pristine Scorpid Leggings~300~R~8170:20,15408:40,12810:12,15407:4,249429:10,14341:2,248825:20
Razorbramble Cowl~300~R~
Razorbramble Leathers~300~R~
Razorbramble Shoulderpads~300~R~
Red Dragonscale Leggings~300~R~8170:20,15414:40,12810:12,15407:4,249429:10,14341:2,248825:20
Sewing Machine~300~R~273130:1,8170:5,14341:1
Sharpened Chitin Armor Kit~300~R~
Shifting Cloak~300~R~8170:30,7082:12,12753:4,12809:8,15407:4,14341:8
Spiritcaller Boots~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Epaulets~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Gauntlets~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Gloves~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Greaves~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Grips~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Kilt~300~R~274030:5,15407:4,248825:24,14341:8
Spiritcaller Leggings~300~R~274030:5,15407:4,248825:24,14341:8
Spiritcaller Mantle~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Pants~300~R~274030:5,15407:4,248825:24,14341:8
Spiritcaller Spaulders~300~R~274030:3,15407:2,248825:18,14341:8
Spiritcaller Treads~300~R~274030:3,15407:2,248825:18,14341:8
Swift Flight Vambraces~300~R~
Timbermaw Tunic~300~R~12810:6,12804:20,12803:20,249429:10,15407:4,14341:10,248825:20
Tranquil Wristguards~300~R~274030:1,248824:1,248825:10
Warbear Helm~300~R~8170:20,15419:20,14341:4,15407:2,249429:10,248825:20
Wild Leather Armor Kit~300~R~248825:22,14341:3
Wildstalker's Gauntlets~300~R~274030:3,15407:2,248825:18,14341:8
Wildstalker's Greaves~300~R~274030:3,15407:2,248825:18,14341:8
Wildstalker's Legguards~300~R~274030:5,15407:4,248825:24,14341:8
Wildstalker's Spaulders~300~R~274030:3,15407:2,248825:18,14341:8
Spitfire Gauntlets~305~R~20500:2,20498:30,7078:2,15407:1
Sandstalker Bracers~310~R~20501:1,20498:20,18512:2
Sandstalker Breastplate~310~R~20501:3,20498:40,18512:2,15407:2
Sandstalker Gauntlets~310~R~20501:2,20498:30,18512:2,15407:1
Spitfire Bracers~310~R~20500:1,20498:20,7078:2
Spitfire Breastplate~310~R~20500:3,20498:40,7078:2,15407:2
Bramblewood Belt~320~R~12810:4,12803:2,15407:1
Bramblewood Boots~320~R~12810:6,18512:2,12803:2,15407:2
Bramblewood Helm~320~R~12810:12,19726:2,12803:2,15407:2
Dreamscale Breastplate~320~R~12810:12,20381:6,12803:4,15407:4,14227:6
Icy Scale Bracers~320~T~22682:4,15408:16,7080:2,15407:2,14227:4
Icy Scale Breastplate~320~T~22682:7,15408:24,7080:2,15407:4,14227:4
Icy Scale Gauntlets~320~T~22682:5,15408:16,7080:2,15407:3,14227:4
Onyxia Scale Cloak~320~R~15410:1,14044:1,14341:1
Polar Bracers~320~T~22682:4,12810:12,7080:2,15407:2,14227:4
Polar Gloves~320~T~22682:5,12810:12,7080:2,15407:3,14227:4
Polar Tunic~320~T~22682:7,12810:16,7080:2,15407:4,14227:4]==],
 ["Mining"]=[==[
Lodestone~20~T~2835:1,2840:1
Copper Bar~25~A~2770:1
Bronze Bar~65~T~2840:1,3576:1
Tin Bar~65~T~2771:1
Silver Bar~75~T~2775:1
Iron Bar~125~T~2772:1
Rock Garden~140~R~2838:2,2772:1,2842:1
Gold Bar~155~T~2776:1
Steel Bar~165~T~3575:1,3857:1
Mithril Bar~175~T~3858:1
Dark Iron Bar~230~T~11370:8
Truesilver Bar~230~T~7911:1
Thorium Bar~250~T~10620:1
Azerothium Bar~275~T~249426:2,3857:1
Heavy Thorium Bar~300~T~248815:1
Molten Foundry~300~R~12359:5,12365:2,6037:1
Elementium Bar~310~T~18562:1,12360:10,17010:1,18567:3
Obsidian-Infused Thorium Bar~315~R~]==],
 ["Tailoring"]=[==[
White Linen Shirt~1~T~2996:1,2320:1,2324:1
Linen Bag~5~A~2996:3,2320:3
Linen Reagent Bag~5~R~2996:6,2320:6
Brown Linen Vest~10~T~2996:1,2320:1
Linen Belt~15~T~2996:1,2320:1
Faction Banner~20~T~2996:1,2320:1
Simple Linen Boots~20~T~2996:2,2318:1,2320:1
Blue Linen Shirt~25~T~2996:2,2320:1,6260:1
Bolt of Linen Cloth~25~A~2589:2
Brown Linen Pants~25~T~2996:2,2320:1
Brown Linen Robe~25~T~2996:3,2320:1
Heavy Linen Gloves~25~T~2996:2,2320:1
Red Linen Robe~25~R~2996:3,2320:2,2604:2
Red Linen Shirt~25~T~2996:2,2320:1,2604:1
Simple Dress~25~T~2996:2,2320:1,6260:1,2324:1
White Linen Robe~25~T~2996:3,2320:1,2324:1
Blue Linen Vest~35~R~2996:3,2320:1,6260:1
Brown Linen Shirt~35~A~2996:1,2320:1
Green Linen Bracers~35~T~2996:3,2320:2,2605:1
Linen Cloak~35~A~2996:1,2320:1
Novice Arcanist's Sash~35~R~2996:8,2321:2,2455:2
Novice Ardent's Sash~35~R~2996:12,2321:2,118:2
Red Linen Vest~35~R~2996:3,2320:1,2604:1
Reinforced Linen Cape~35~T~2996:2,2320:3
Barbaric Linen Vest~40~T~2996:4,2318:1,2321:1
Green Linen Shirt~40~T~2996:3,2321:1,2605:1
Linen Boots~40~T~2996:3,2320:1,2318:1
Simple Linen Pants~40~A~2996:1,2320:1
Blue Linen Robe~45~R~2996:4,2320:2,6260:2
Handstitched Linen Britches~45~T~2996:4,2321:2
Azure Stormsewn Cord~50~R~2996:3,2320:3
Azure Stormsewn Cuffs~50~R~2996:3,2320:3
Cloudy Stormsewn Cord~50~R~2996:3,2320:3
Cloudy Stormsewn Cuffs~50~R~2996:3,2320:3
Red Linen Bag~50~R~2996:4,2321:1,2604:1
Simple Kilt~50~T~2996:4,2321:1
Woolen Bag~50~T~2997:3,2321:1
Azure Stormsewn Handwraps~55~R~2996:4,2320:4
Azure Stormsewn Shoes~55~R~2996:4,2320:3
Bolt of Woolen Cloth~55~T~2592:3
Cloudy Stormsewn Handwraps~55~R~2996:4,2320:4
Cloudy Stormsewn Shoes~55~R~2996:4,2320:3
Soft-soled Linen Boots~55~T~2996:5,2318:2,2321:1
Woolen Cape~55~T~2997:1,2321:1
Azure Stormsewn Leggings~60~R~2996:5,2320:2
Azure Stormsewn Vest~60~R~2996:5,2320:2
Cloudy Stormsewn Leggings~60~R~2996:5,2320:2
Cloudy Stormsewn Vest~60~R~2996:5,2320:2
Flame Boots~60~R~2997:8,2321:2,249409:2,6371:1
Green Woolen Vest~60~T~2997:2,2321:2,2605:1
Heavy Woolen Gloves~60~T~2997:3,2321:1
Pearly Boots~60~R~2997:8,2321:2,249409:2,5498:1
Pristine Boots~60~R~2997:8,2321:2,249409:2,249427:1
Shadow Boots~60~R~2997:8,2321:2,249409:2,1210:1
Shining Boots~60~R~2997:8,2321:2,249409:2,249391:1
Silky Boots~60~R~2997:8,2321:2,249409:2,3182:1
Colorful Kilt~70~R~2997:5,2604:3,2321:1
Pearl-clasped Cloak~70~T~2997:3,2321:2,5498:1
Woolen Boots~70~T~2997:4,2321:2,2318:2
Woolen Reagent Bag~70~R~2997:3,2321:1,249409:1
Blue Overalls~75~R~2997:4,2321:2,6260:2
Filigreed Flame Gown~75~R~2997:8,2321:4,249409:2,6371:2
Filigreed Pearly Gown~75~R~2997:8,2321:4,249409:2,5498:2
Filigreed Pristine Gown~75~R~2997:8,2321:4,249409:2,249427:2
Filigreed Shadow Gown~75~R~2997:8,2321:4,249409:2,1210:2
Filigreed Shining Gown~75~R~2997:8,2321:4,249409:2,249391:2
Filigreed Silky Gown~75~R~2997:8,2321:4,249409:2,3182:2
Flame Gloves~75~R~2997:6,2321:4,249409:3,6371:2
Green Woolen Bag~75~R~2997:5,2605:1,2321:1
Green Woolen Robe~75~T~
Pearly Gloves~75~R~2997:6,2321:4,249409:3,5498:2
Pristine Gloves~75~R~2997:6,2321:4,249409:3,249427:2
Red Woolen Boots~75~R~2997:4,2318:2,2321:1,2604:2
Shadow Gloves~75~R~2997:6,2321:4,249409:3,1210:2
Shining Gloves~75~R~2997:6,2321:4,249409:3,249391:2
Silky Gloves~75~R~2997:6,2321:4,249409:3,3182:2
Gray Woolen Robe~80~R~2997:4,2321:3,4340:1
Gray Woolen Shirt~80~T~2997:2,2321:1,4340:1
Heavy Woolen Cloak~80~R~2997:3,2321:2,5498:2
Double-Stitched Woolen Shoulders~85~T~2997:3,2321:2
Flame Sash~85~R~4305:8,2321:4,249409:3,6371:3
Heavy Woolen Pants~85~T~2997:5,2321:4
Pearly Sash~85~R~4305:8,2321:4,249409:3,5498:3
Pristine Sash~85~R~4305:8,2321:4,249409:3,249427:3
Shadow Sash~85~R~4305:8,2321:4,249409:3,1210:3
Shining Sash~85~R~4305:8,2321:4,249409:3,249391:3
Silky Sash~85~R~4305:8,2321:4,249409:3,3182:3
Stylish Red Shirt~85~T~2997:3,2604:2,2321:1
White Woolen Dress~85~T~2997:3,2324:4,2321:1
Greater Adept's Robe~90~R~2997:5,2321:3,2604:3
Red Woolen Bag~90~R~2997:5,2604:1,2321:1
Reinforced Woolen Shoulders~95~R~2997:6,2319:2,2321:2
Stylish Blue Shirt~95~R~2997:4,6260:2,4340:1,2321:1
Stylish Green Shirt~95~R~2997:4,2605:2,4340:1,2321:1
Bolt of Silk Cloth~100~T~4306:4
Filigreed Flame Leggings~100~R~4305:8,2321:4,249409:2,6371:4
Filigreed Pearly Leggings~100~R~4305:8,2321:4,249409:2,5498:4
Filigreed Pristine Leggings~100~R~4305:8,2321:4,249409:2,249427:4
Filigreed Shadow Leggings~100~R~4305:8,2321:4,249409:2,1210:4
Filigreed Shining Leggings~100~R~4305:8,2321:4,249409:2,249391:4
Filigreed Silky Leggings~100~R~4305:8,2321:4,249409:2,3182:4
Flame Circlet~100~R~4305:10,4291:2,249409:4,6371:4,2842:1,11082:2
Pearly Circlet~100~R~4305:10,4291:2,249409:4,5498:4,2842:1,11082:2
Phoenix Gloves~100~R~2997:4,5500:1,2321:4,2324:2
Phoenix Pants~100~R~2997:6,5500:1,2321:3
Pristine Circlet~100~R~4305:10,4291:2,249409:4,249427:4,2842:1,11082:2
Shadow Circlet~100~R~4305:10,4291:2,249409:4,1210:4,2842:1,11082:2
Shining Circlet~100~R~4305:10,4291:2,249409:4,249391:4,2842:1,11082:2
Silky Circlet~100~R~4305:10,4291:2,249409:4,3182:4,2842:1,11082:2
Spidersilk Boots~100~T~4305:2,2319:4,3182:4,5500:1
Gloves of Meditation~105~T~2997:4,2321:3,3383:1
Bright Yellow Shirt~110~R~4305:1,4341:1,2321:1
Flame Gown~110~R~4305:12,4291:2,249409:6,6371:6,2842:2,11082:2
Lesser Wizard's Robe~110~T~4305:2,2321:2,3182:2
Pearly Gown~110~R~4305:12,4291:2,249409:6,5498:6,2842:2,11082:2
Pristine Gown~110~R~4305:12,4291:2,249409:6,249427:6,2842:2,11082:2
Shadow Gown~110~R~4305:12,4291:2,249409:6,1210:6,2842:2,11082:2
Shining Gown~110~R~4305:12,4291:2,249409:6,249391:6,2842:2,11082:2
Silky Gown~110~R~4305:12,4291:2,249409:6,3182:6,2842:2,11082:2
Azure Silk Pants~115~T~4305:4,6260:2,2321:3
Spider Silk Slippers~115~R~4305:3,3182:1,2321:2
Azure Silk Gloves~120~R~4305:3,4234:2,6260:2,2321:2
Azure Silk Hood~120~T~4305:2,6260:2,2321:1
Boots of Darkness~120~T~
Dark Silk Shirt~120~R~4305:2,4340:2,2321:1
Hands of Darkness~120~R~4305:3,4234:2,6048:2,2321:2
Azure Silk Vest~125~T~4305:5,6260:4
Filigreed Flame Circlet~125~R~4305:8,2321:4,249409:2,6371:6
Filigreed Pearly Circlet~125~R~4305:8,2321:4,249409:2,5498:6
Filigreed Pristine Circlet~125~R~4305:8,2321:4,249409:2,249427:6
Filigreed Shadow Circlet~125~R~4305:8,2321:4,249409:2,1210:6
Filigreed Shining Circlet~125~R~4305:8,2321:4,249409:2,249391:6
Filigreed Silky Circlet~125~R~4305:8,2321:4,249409:2,3182:6
Flame Leggings~125~R~4305:14,2321:3,249409:8,6371:8,2842:2,11082:3
Pearly Leggings~125~R~4305:14,2321:3,249409:8,5498:8,2842:2,11082:3
Phoenix Bindings~125~R~
Pristine Leggings~125~R~4305:14,2321:3,249409:8,249427:8,2842:2,11082:3
Robes of Arcana~125~R~4305:4,2321:2,3182:2
Shadow Leggings~125~R~4305:14,2321:3,249409:8,1210:8,2842:2,11082:3
Shining Leggings~125~R~4305:14,2321:3,249409:8,249391:8,2842:2,11082:3
Silk Headband~125~T~4305:3,2321:2
Silk Reagent Bag~125~R~4305:3,4234:2,2321:3,249409:3
Silky Leggings~125~R~4305:14,2321:3,249409:8,3182:8,2842:2,11082:3
Small Silk Pack~125~T~4305:3,4234:2,2321:3
Truefaith Gloves~125~R~4305:3,4234:2,929:4,2321:1
White Swashbuckler's Shirt~125~T~4305:3,2324:2,4291:1
Enchanter's Cowl~130~R~4305:3,2321:2,4337:2
Green Silk Armor~130~R~4305:5,2605:2,4291:1
Earthen Vest~135~T~4305:3,7067:1,2321:2
Extraplanar Spidersilk Boots~135~T~
Formal White Shirt~135~T~4305:3,2324:2,2321:1
Shadow Hood~135~R~4305:4,4291:1,3824:1
Azure Silk Belt~140~T~4305:4,7070:1,6260:2,2321:2,7071:1
Azure Silk Cloak~140~R~4305:3,6260:2,2321:2
Bolt of Mageweave~140~T~4338:5
Boots of the Enchanter~140~R~4305:4,4291:1,4337:2
Crimson Silk Belt~140~T~4305:4,7071:1,2604:2,4291:1
Earthen Leggings~140~R~4305:4,7067:1,2321:2
Green Silk Pack~140~R~4305:5,4234:3,2321:3,2605:1
Red Swashbuckler's Shirt~140~T~4305:3,2604:2,4291:1
Spinning Wheel~140~R~4470:2,4305:5,2321:3
Tuxedo Jacket~140~R~4339:5,8343:3
Tuxedo Pants~140~R~4339:4,8343:3
White Wedding Dress~140~R~4339:5,8343:3,2324:1
Crimson Silk Cloak~145~R~4305:5,2604:2,6371:2,4291:1
Earthen Silk Slippers~145~R~4305:4,7067:1,2321:2,4234:2
Green Silken Shoulders~145~T~4305:5,4291:2
Spider Belt~145~R~4305:4,4337:2,7071:1
Black Silk Pack~150~R~4305:6,2325:1,2321:4
Black Slippers~150~R~4339:8,8343:4,249430:2,249409:2,7971:2
Crimson Silk Vest~150~T~4305:4,2604:2,2321:2
Earthen Silk Hood~150~R~4305:4,7067:2,2321:2
Fiery Slippers~150~R~4339:8,8343:4,249430:2,249409:2,7077:2
Frothing Slippers~150~R~4339:8,8343:4,249430:2,249409:2,7079:2
Gilded Slippers~150~R~4339:8,8343:4,249430:2,249409:2,3577:2
Golden Slippers~150~R~4339:8,8343:4,249430:2,249409:2,13926:2
Invoker's Cord~150~R~
Invoker's Mantle~150~R~
Long Silken Cloak~150~T~4305:4,3827:1,4291:1
Radiant Slippers~150~R~4339:8,8343:4,249430:2,249409:2,11178:2
Rich Purple Silk Shirt~150~R~4305:4,4342:1,4291:1
Azure Shoulders~155~R~4305:6,7072:2,6260:2,4291:2
Crimson Silk Shoulders~155~R~4305:5,6371:2,2604:2,4291:2
Green Holiday Shirt~155~R~4305:5,2605:4,4291:1
Robe of Power~155~T~4339:2,7067:2,7070:2,7068:2,7069:2,4291:2
Crimson Silk Pantaloons~160~T~4305:4,2604:2,4291:2
Earthen Silk Belt~160~R~4305:5,7067:4,4234:4,7071:1,4291:2
Earthen Silk Gloves~160~R~4305:5,7067:2,4291:2
Black Handwraps~165~R~4339:12,8343:4,249430:2,249409:1,7971:4
Black Swashbuckler's Shirt~165~R~4305:5,2325:1,4291:1
Earthen Silk Cuffs~165~R~4305:4,7067:1,4291:1
Fiery Handwraps~165~R~4339:12,8343:4,249430:2,249409:1,7077:4
Frothing Handwraps~165~R~4339:12,8343:4,249430:2,249409:1,7079:4
Gilded Handwraps~165~R~4339:12,8343:4,249430:2,249409:1,3577:4
Golden Handwraps~165~R~4339:12,8343:4,249430:2,249409:1,13926:4
Icy Cloak~165~R~4339:3,4291:2,3829:1,4337:2
Radiant Handwraps~165~R~4339:12,8343:4,249430:2,249409:1,11178:4
Star Belt~165~R~4339:4,4234:4,3864:1,7071:1,4291:1
Black Mageweave Leggings~170~T~4339:2,4291:3
Black Mageweave Vest~170~T~4339:2,4291:3
Crimson Silk Robe~170~R~4305:8,7068:4,3827:2,2604:4,4291:1
Earthen Silk Shoulders~170~R~4305:6,7067:2,4291:3
Azure Stormsewn Cowl~175~R~4305:7,11134:2,8343:1,6260:4
Azure Stormsewn Epaulets~175~R~4305:5,11134:1,8343:1,6260:3
Black Mageweave Robe~175~T~4339:3,8343:1
Cloudy Stormsewn Cowl~175~R~4305:7,11134:2,8343:1,2324:8
Cloudy Stormsewn Epaulets~175~R~4305:5,11134:1,8343:1,2324:6
Crimson Silk Gloves~175~T~4305:6,7068:2,6371:2,4304:2,2604:4,4291:2
Shadoweave Pants~175~T~4339:3,10285:2,8343:1
Black Mageweave Gloves~180~T~4339:2,8343:2
Orange Mageweave Shirt~180~T~4339:1,6261:1,8343:1
Red Mageweave Pants~180~R~4339:3,2604:2,8343:1
Red Mageweave Vest~180~R~4339:3,2604:2,8343:1
Shadoweave Robe~180~T~4339:3,10285:2,8343:1
White Bandit Mask~180~R~4339:1,2324:1,8343:1
Orange Martial Shirt~185~R~4339:2,6261:2,8343:1
Stormcloth Gloves~185~R~
Stormcloth Pants~185~R~
Black Cord~190~R~4339:28,8343:4,249430:6,249409:4,7971:12
Black Mageweave Boots~190~T~4339:3,8343:2,4304:2
Black Mageweave Headband~190~T~4339:3,8343:2
Black Mageweave Shoulders~190~T~4339:3,8343:2
Cindercloth Robe~190~T~4339:5,7077:2,8343:2
Dreamweave Gloves~190~T~4339:4,8153:4,10286:2,8343:2
Dreamweave Vest~190~T~4339:6,8153:6,10286:2,8343:2
Enchanted Mageweave Pouch~190~R~4339:4,11137:4,8343:2
Fiery Cord~190~R~4339:28,8343:4,249430:6,249409:4,7077:12
Frothing Cord~190~R~4339:28,8343:4,249430:6,249409:4,7079:12
Gilded Cord~190~R~4339:28,8343:4,249430:6,249409:4,3577:12
Golden Cord~190~R~4339:28,8343:4,249430:6,249409:4,13926:12
Lavender Mageweave Shirt~190~R~4339:2,4342:2,8343:2
Mageweave Bag~190~T~4339:4,4291:2
Mageweave Reagent Bag~190~R~4339:4,8343:2,249430:1,249409:1
Radiant Cord~190~R~4339:28,8343:4,249430:6,249409:4,11178:12
Red Mageweave Gloves~190~R~4339:3,2604:2,8343:2
Shadoweave Gloves~190~T~4339:5,10285:5,8343:2
Stormcloth Vest~190~R~
Netherflame Shoulders~195~R~4339:16,8343:3,249430:4,249409:3,7077:8,11175:2
Netherfroth Shoulders~195~R~4339:16,8343:3,249430:4,249409:3,7079:8,11175:2
Nethergeld Shoulders~195~R~4339:16,8343:3,249430:4,249409:3,3577:8,11175:2
Netherlight Shoulders~195~R~4339:16,8343:3,249430:4,249409:3,11178:8,11175:2
Netherpearl Shoulders~195~R~4339:16,8343:3,249430:4,249409:3,7971:8,11175:2
Nethershine Shoulders~195~R~4339:16,8343:3,249430:4,249409:3,13926:8,11175:2
Pink Mageweave Shirt~195~R~4339:3,10290:1,8343:1
Red Mageweave Bag~195~T~4339:5,2604:2,8343:2
Red Mageweave Shoulders~195~R~4339:4,2604:2,8343:3
Shadoweave Shoulders~195~T~4339:5,10285:4,8343:2
Simple Black Dress~195~T~4339:3,2325:1,8343:1,2324:1
Cindercloth Boots~200~T~4339:5,7077:1,8343:3,4304:2
Hyperconductive Arcano-Filament~200~R~4339:2,213378:5,8343:5
Red Mageweave Headband~200~R~4339:4,2604:2,8343:2
Shadoweave Boots~200~T~4339:6,10285:6,8343:3,4304:2
Stormcloth Headband~200~R~
Stormcloth Shoulders~200~R~
Tuxedo Shirt~200~R~4339:4,8343:2
Bolt of Runecloth~205~T~14047:5
Dreamweave Circlet~205~T~4339:8,8153:4,10286:2,8343:3,6037:1,1529:1
Netherflame Cuffs~205~R~4339:18,8343:3,249430:6,249409:4,7077:10,11175:4
Netherfroth Cuffs~205~R~4339:18,8343:3,249430:6,249409:4,7079:10,11175:4
Nethergeld Cuffs~205~R~4339:18,8343:3,249430:6,249409:4,3577:10,11175:4
Netherlight Cuffs~205~R~4339:18,8343:3,249430:6,249409:4,11178:10,11175:4
Netherpearl Cuffs~205~R~4339:18,8343:3,249430:6,249409:4,7971:10,11175:4
Nethershine Cuffs~205~R~4339:18,8343:3,249430:6,249409:4,13926:10,11175:4
Stormcloth Boots~205~R~
Frostweave Robe~210~R~14048:5,7079:2,14341:1
Frostweave Tunic~210~R~14048:5,7079:2,14341:1
Runecloth Belt~210~T~14048:3,14341:1
Black Waistcord~215~R~14048:8,8343:4,249430:8,249409:5,7971:12
Cindercloth Vest~215~R~14048:5,7077:3,14341:1
Earthenweave Cord~215~R~14048:4,7076:2,14341:1
Earthenweave Gloves~215~R~14048:6,7076:1,14341:1
Fiery Waistcord~215~R~14048:8,8343:4,249430:8,249409:5,7077:12
Frostweave Gloves~215~R~14048:3,7080:1,14341:1
Frothing Waistcord~215~R~14048:8,8343:4,249430:8,249409:5,7079:12
Ghostweave Cord~215~R~14048:4,9210:1,14227:1,14341:1
Gilded Waistcord~215~R~14048:8,8343:4,249430:8,249409:5,3577:12
Golden Waistcord~215~R~14048:8,8343:4,249430:8,249409:5,13926:12
Radiant Waistcord~215~R~14048:8,8343:4,249430:8,249409:5,11178:12
Runecloth Bag~215~R~14048:5,8170:2,14341:1,249430:4,249409:2
Runecloth Reagent Bag~215~R~14048:5,8170:2,14341:1,249431:1
Runecloth Robe~215~R~14048:5,14227:1,14341:1
Runecloth Tunic~215~R~14048:5,14227:1,14341:1
Soul Pouch~215~R~14048:6,8170:4,7972:2,14341:1
Ghostweave Belt~220~R~14048:3,9210:2,14227:1,14341:1
Runecloth Cloak~220~R~14048:4,14227:1,14341:1
Brightcloth Gloves~225~R~14048:4,3577:2,14341:1
Brightcloth Robe~225~R~14048:5,3577:2,14341:1
Cindercloth Gloves~225~R~14048:4,7077:3,14341:1
Earthenweave Boots~225~R~14048:4,7076:2,8170:2,14341:1
Ghostweave Gloves~225~R~14048:4,9210:2,14227:1,14341:1
Ghostweave Vest~225~R~14048:6,9210:4,14227:1,14341:1
Gneuro-Linked Arcano-Filament Monocle~225~R~213379:5,213369:1,213372:1,11137:10,4339:10
Brightcloth Cloak~230~R~14048:4,3577:2,14341:1
Cenarion Herb Bag~230~R~14048:5,8831:10,11040:8,14341:2
Cindercloth Cloak~230~R~14048:5,7078:1,14341:1
Enchanted Runecloth Bag~230~R~14048:5,16203:2,14341:2
Felcloth Pants~230~R~14048:5,14256:4,14341:1
Mooncloth~230~R~14256:2
Runecloth Gloves~230~R~14048:4,8170:4,14341:1
Wizardweave Leggings~230~R~14048:6,11176:1,14341:1
Black Gloves~235~R~14048:8,8343:4,249430:4,249409:4,7971:4
Black Sandals~235~R~14048:10,8343:4,249430:10,249409:6,7971:14,249427:4
Cindercloth Pants~235~R~14048:6,7078:1,14341:1
Fiery Gloves~235~R~14048:8,8343:4,249430:4,249409:4,7077:4
Fiery Sandals~235~R~14048:10,8343:4,249430:10,249409:6,7077:14,249427:4
Frostweave Pants~235~R~14048:6,7080:1,14341:1
Frothing Gloves~235~R~14048:8,8343:4,249430:4,249409:4,7079:4
Frothing Sandals~235~R~14048:10,8343:4,249430:10,249409:6,7079:14,249427:4
Gilded Gloves~235~R~14048:8,8343:4,249430:4,249409:4,3577:4
Gilded Sandals~235~R~14048:10,8343:4,249430:10,249409:6,3577:14,249427:4
Golden Gloves~235~R~14048:8,8343:4,249430:4,249409:4,13926:4
Golden Sandals~235~R~14048:10,8343:4,249430:10,249409:6,13926:14,249427:4
Radiant Gloves~235~R~14048:8,8343:4,249430:4,249409:4,11178:4
Radiant Sandals~235~R~14048:10,8343:4,249430:10,249409:6,11178:14,249427:4
Runecloth Boots~235~R~14048:4,14227:2,8170:4,14341:1
Admiral's Hat~240~R~4339:3,4589:6,8343:2
Earthenweave Mantle~240~R~14048:6,7076:1,14341:1
Felcloth Boots~240~R~14048:6,14256:4,8170:4,14341:1
Runecloth Pants~240~R~14048:6,14227:2,14341:1
Brightcloth Pants~245~R~14048:6,3577:4,14227:1,14341:1
Earthenweave Leggings~245~R~14048:6,7076:2,14341:1
Felcloth Hood~245~R~14048:5,14256:4,14341:1
Ghostweave Pants~245~R~14048:6,9210:4,14341:1
Mooncloth Leggings~245~R~14048:6,14342:4,14341:1
Robe of Winter Night~245~R~14048:10,14256:12,12808:4,7080:4,14341:1
Shadoweave Mask~245~R~4339:2,10285:8,8343:2
Crusader's Knapsack~250~R~12811:1,14048:14,2604:8,14227:3
Earthenweave Vest~250~R~14048:8,7076:1,14341:1
Festival Dress~250~R~14048:4,4625:2,2604:2,14341:1
Festival Suit~250~R~14048:4,4625:2,2604:2,14341:1
Fractured Mind Pauldrons~250~T~221021:10,220688:1,14256:8,14048:8
Ghostweave Mantle~250~R~14048:5,9210:3,14227:1,14341:1
Green Winter Clothes~250~R~14048:4,2997:1,2605:2,14341:1
Mantle of Insanity~250~T~221021:10,220688:1,12803:4,14048:10
Red Winter Clothes~250~R~14048:4,2997:1,2604:2,14341:1
Runecloth Cuffs~250~R~14048:5,14227:1,14341:1
Runecloth Headband~250~R~14048:4,14227:2,14341:1
Scarlet Augur's Cuffs~250~R~
Scarlet Augur's Strap~250~R~
Shoulderpads of the Deranged~250~T~221021:10,220688:1,14256:6,7080:1,14048:3
Big Bag of Enchantment~255~R~14048:6,14344:4,12810:4,14227:4
Earthenweave Cuffs~255~R~14048:5,7076:1,14341:1
Ghostweave Boots~255~R~14048:4,9210:2,14227:1,8170:2,14341:1
Mooncloth Bag~255~R~14048:4,14342:1,14341:1,249431:10,249430:2,249409:4
Mooncloth Reagent Bag~255~R~14048:4,14342:1,14341:1,249431:10,249430:1,249409:1
Satchel of Cenarius~255~R~14048:6,14342:2,13468:1,14227:4
Wisdom of the Timbermaw~255~R~14048:8,7076:3,12803:3,14227:2
Wizardweave Robe~255~R~14048:8,11176:2,14341:1
Earthenweave Crown~260~R~14048:6,7076:3,14341:1
Felcloth Robe~260~R~14048:8,14256:8,12662:4,14341:2
Ghostweave Hood~260~R~14048:6,9210:3,14227:2,14341:1
Runecloth Shoulders~260~R~14048:7,14227:2,8170:4,14341:1
Scarlet Augur's Mitts~260~R~
Scarlet Augur's Soles~260~R~
Wizardweave Turban~260~R~14048:6,11176:4,7910:1,14341:1
Felcloth Shoulders~265~R~14048:7,14256:6,12662:4,8170:4,14341:2
Mooncloth Vest~270~R~14048:6,14342:4,14341:1
Scarlet Augur's Leggings~270~R~
Synthetic Gordok Ogre Suit~270~R~
Cloak of Fire~275~R~14048:6,7078:4,7077:4,7068:4,14341:1
Mooncloth Robe~275~R~14048:6,14342:4,13926:2,14341:2
Mooncloth Shoulders~275~R~14048:5,14342:5,14341:1
Cloak of Warding~280~R~14048:12,12809:4,12360:1,14341:2
Felcloth Gloves~280~R~14048:12,14256:20,12662:6,12808:8,14341:2
Inferno Gloves~280~R~14048:12,7078:10,7910:2,14341:2
Mooncloth Circlet~280~R~14048:4,14342:6,12800:1,12810:2,14341:2
Mooncloth Gloves~280~R~14048:12,14342:6,13926:2,14341:2
Scarlet Augur's Hood~280~R~
Scarlet Augur's Mantle~280~R~
Scarlet Augur's Vestments~280~R~12938:1,12811:1,14048:12
Felcloth Bag~285~R~14256:12,12810:6,20520:2,14227:4
Gordok Ogre Suit~285~T~14048:2,8170:4,18240:1,14341:1
Mooncloth Boots~285~T~14048:6,14342:4,7971:2,14341:1
Runed Stygian Belt~285~R~14048:2,20520:6,14256:2,12810:2,14227:2
Runed Stygian Boots~285~R~14048:4,20520:6,14256:4,12810:2,14227:2
Runed Stygian Leggings~285~R~14048:6,20520:8,14256:6,14227:2
Swarmtender's Gloves~285~R~14048:4,14343:1,7080:3,14341:6
Venomspew Gloves~285~R~14048:4,14343:1,7082:3,14341:6
Argent Boots~290~R~14048:6,12810:4,13926:2,12809:2,14227:2
Crimson Dawnwoven Bag~290~R~12938:1,14048:24,2604:4,12808:2,12811:2
Incandescent Mooncloth Leggings~290~R~
Mantle of the Timbermaw~290~R~14342:5,7076:5,12803:5,14227:2
Swarmtender's Cord~290~R~14048:6,14343:1,7080:3,14341:6
Venomspew Cord~290~R~14048:6,14343:1,7082:3,14341:6
Belt of the Archmage~295~R~14048:16,9210:8,14342:8,7080:10,7078:10,14344:4,14341:6,249431:10
Gloves of Spell Mastery~295~R~14048:10,14342:8,9210:8,13926:4,12364:4,12810:6,14341:2,249431:10
Robe of the Archmage~295~R~14048:12,7078:8,7082:8,7076:8,7080:8,14341:2,249431:10
Robe of the Void~295~R~14048:12,12662:20,14256:40,7078:8,12808:8,14341:2,249431:10
Swarmtender's Footpads~295~R~14048:5,14343:1,7080:3,14341:6
Truefaith Vestments~295~R~14048:12,14342:8,12811:2,13926:2,9210:8,14341:2,249431:10
Venomspew Footpads~295~R~14048:5,14343:1,7082:3,14341:6
Argent Shoulders~300~R~14342:5,12809:2,14227:2
Bloodvine Boots~300~R~14342:3,19726:3,12810:4,14048:4,14227:4
Bloodvine Leggings~300~R~14342:4,19726:4,12804:4,14048:4,14227:2
Bloodvine Vest~300~R~14342:3,19726:5,12804:4,14048:4,14227:2
Bolt of Qiraji Silk~300~R~
Boots of Conviction~300~R~274030:3,14342:2,14048:16,14341:8
Bottomless Bag~300~R~14048:8,14342:12,14344:2,249429:5,249428:5,249431:8,14341:2
Bottomless Reagent Bag~300~R~14048:8,14342:12,14344:2,249427:5,14341:2,249428:5,249429:5
Cloak of Earth and Sky~300~R~274030:1,14342:1,14048:5
Core Felcloth Bag~300~R~14256:20,17012:16,19726:8,7078:4,14227:4
Demonheart Boots~300~R~274030:3,14342:2,14048:16,14341:8
Demonheart Gloves~300~R~274030:3,14342:2,14048:16,14341:8
Demonheart Leggings~300~R~274030:5,14342:3,14048:22,14341:8
Demonheart Spaulders~300~R~274030:3,14342:2,14048:16,14341:8
Embroidered Belt of the Archmage~300~R~
Fel Cape~300~R~274030:1,14342:1,14048:5
Felblood Soul Bag~300~R~14256:8,14048:6
Flarecore Gloves~300~R~14048:8,17010:6,7078:4,12810:2,14341:2
Flarecore Leggings~300~R~14342:8,17010:5,17011:3,7078:10,14227:4
Flarecore Mantle~300~R~14048:12,17010:4,17011:4,12810:6,14341:2
Flarecore Robe~300~R~14342:10,17010:2,17011:3,7078:6,14227:4
Flarecore Wraps~300~R~14342:6,17010:8,7078:2,12810:6,14341:4
Frosty Gloves~300~T~
Frosty Vest~300~T~
Frosty Wrists~300~T~
Gaea's Embrace~300~R~19726:1,14342:2,12803:4,14227:4
Glacial Cloak~300~T~22682:5,14048:4,7080:2,14227:4
Glacial Gloves~300~T~22682:5,14048:4,7080:4,14227:4
Glacial Vest~300~T~22682:7,14048:8,7080:6,14227:8
Glacial Wrists~300~T~22682:4,14048:2,7080:2,14227:4
Gloves of Conviction~300~R~274030:3,14342:2,14048:16,14341:8
Handguards of Conviction~300~R~274030:3,14342:2,14048:16,14341:8
Incandescent Mooncloth Circlet~300~R~
Incandescent Mooncloth Robe~300~R~
Incandescent Mooncloth Vest~300~R~
Leather-Reinforced Runecloth Bag~300~R~
Leggings of Conviction~300~R~274030:5,14342:3,14048:22,14341:8
Loom~300~R~273131:1,14048:4,4470:4
Mana-infused Cord~300~R~274030:2,14342:2,14048:7
Manaflare Boots~300~R~274030:3,14342:2,14048:16,14341:8
Manaflare Gloves~300~R~274030:3,14342:2,14048:16,14341:8
Manaflare Mantle~300~R~274030:3,14342:2,14048:16,14341:8
Manaflare Pants~300~R~274030:5,14342:3,14048:22,14341:8
Mantle of Conviction~300~R~274030:3,14342:2,14048:16,14341:8
Pants of Conviction~300~R~274030:5,14342:3,14048:22,14341:8
Pauldrons of Conviction~300~R~274030:3,14342:2,14048:16,14341:8
Rime-encrusted Boots~300~R~274030:2,14342:2,14048:7
Robes of Fiery Devastation~300~R~274030:3,14342:3,14048:9
Sylvan Crown~300~R~14048:4,14342:2,12803:2,14227:2
Sylvan Shoulders~300~R~14048:2,12803:4,14227:2
Sylvan Vest~300~R~14048:4,19726:2,12803:2,14227:2
Treads of Conviction~300~R~274030:3,14342:2,14048:16,14341:8
Vampiric Cowl~300~R~
Vampiric Robe~300~R~
Vampiric Shawl~300~R~
Dreamscale Bracers~305~R~
Dreamscale Mitts~305~R~
Qiraji Silk Cape~305~R~
Qiraji Silk Cloak~305~R~
Qiraji Silk Drape~305~R~
Qiraji Silk Scarf~305~R~]==],
}
-- Reagent names by item id.
ns.rn = {
 [118]="Minor Healing Potion",[159]="Refreshing Spring Water",[723]="Goretusk Liver",[729]="Stringy Vulture Meat",[730]="Murloc Eye",
 [731]="Goretusk Snout",[765]="Silverleaf",[769]="Chunk of Boar Meat",[774]="Malachite",[783]="Light Hide",
 [785]="Mageroyal",[814]="Flask of Oil",[818]="Tigerseye",[929]="Healing Potion",[1015]="Lean Wolf Flank",
 [1080]="Tough Condor Meat",[1081]="Crisp Spider Meat",[1179]="Ice Cold Milk",[1205]="Melon Juice",[1206]="Moss Agate",
 [1210]="Shadowgem",[1251]="Linen Bandage",[1288]="Large Venom Sac",[1468]="Murloc Fin",[1475]="Small Venom Sac",
 [1529]="Jade",[1645]="Moonberry Juice",[1705]="Lesser Moonstone",[1708]="Sweet Nectar",[2251]="Gooey Spider Leg",
 [2289]="Scroll of Strength II",[2312]="Fine Leather Gloves",[2313]="Medium Armor Kit",[2318]="Light Leather",[2319]="Medium Leather",
 [2320]="Coarse Thread",[2321]="Fine Thread",[2324]="Bleach",[2325]="Black Dye",[2447]="Peacebloom",
 [2449]="Earthroot",[2450]="Briarthorn",[2452]="Swiftthistle",[2453]="Bruiseweed",[2454]="Elixir of Minor Strength",
 [2455]="Minor Mana Potion",[2456]="Minor Rejuvenation Potion",[2457]="Elixir of Minor Agility",[2458]="Elixir of Minor Fortitude",[2459]="Swiftness Potion",
 [2570]="Linen Cloak",[2589]="Linen Cloth",[2592]="Wool Cloth",[2594]="Flagon of Dwarven Honeymead",[2596]="Skin of Dwarven Stout",
 [2604]="Red Dye",[2605]="Green Dye",[2672]="Stringy Wolf Meat",[2673]="Coyote Meat",[2674]="Crawler Meat",
 [2675]="Crawler Claw",[2677]="Boar Ribs",[2678]="Mild Spices",[2686]="Thunder Ale",[2692]="Hot Spices",
 [2723]="Bottle of Dalaran Noir",[2770]="Copper Ore",[2771]="Tin Ore",[2772]="Iron Ore",[2775]="Silver Ore",
 [2776]="Gold Ore",[2835]="Rough Stone",[2836]="Coarse Stone",[2838]="Heavy Stone",[2840]="Copper Bar",
 [2841]="Bronze Bar",[2842]="Silver Bar",[2870]="Shining Silver Breastplate",[2880]="Weak Flux",[2886]="Crag Boar Rib",
 [2894]="Rhapsody Malt",[2924]="Crocolisk Meat",[2934]="Ruined Leather Scraps",[2996]="Bolt of Linen Cloth",[2997]="Bolt of Woolen Cloth",
 [3013]="Scroll of Protection",[3172]="Boar Intestines",[3173]="Bear Meat",[3174]="Spider Ichor",[3182]="Spider's Silk",
 [3355]="Wild Steelbloom",[3356]="Kingsblood",[3357]="Liferoot",[3358]="Khadgar's Whisker",[3369]="Grave Moss",
 [3371]="Empty Vial",[3372]="Leaded Vial",[3383]="Elixir of Wisdom",[3385]="Lesser Mana Potion",[3389]="Elixir of Lesser Defense",
 [3390]="Elixir of Lesser Agility",[3391]="Elixir of Ogre Strength",[3404]="Buzzard Wing",[3466]="Strong Flux",[3470]="Rough Grinding Stone",
 [3478]="Coarse Grinding Stone",[3486]="Heavy Grinding Stone",[3575]="Iron Bar",[3576]="Tin Bar",[3577]="Gold Bar",
 [3667]="Tender Crocolisk Meat",[3685]="Raptor Egg",[3712]="Turtle Meat",[3713]="Soothing Spices",[3730]="Big Bear Meat",
 [3731]="Lion Meat",[3818]="Fadeleaf",[3819]="Wintersbite",[3820]="Stranglekelp",[3821]="Goldthorn",
 [3823]="Lesser Invisibility Potion",[3824]="Shadow Oil",[3827]="Mana Potion",[3829]="Frost Oil",[3857]="Coal",
 [3858]="Mithril Ore",[3859]="Steel Bar",[3860]="Mithril Bar",[3864]="Citrine",[4096]="Coarse Gorilla Hair",
 [4231]="Cured Light Hide",[4232]="Medium Hide",[4233]="Cured Medium Hide",[4234]="Heavy Leather",[4235]="Heavy Hide",
 [4236]="Cured Heavy Hide",[4243]="Fine Leather Tunic",[4246]="Fine Leather Belt",[4255]="Green Leather Armor",[4265]="Heavy Armor Kit",
 [4289]="Salt",[4291]="Silken Thread",[4304]="Thick Leather",[4305]="Bolt of Silk Cloth",[4306]="Silk Cloth",
 [4337]="Thick Spider's Silk",[4338]="Mageweave Cloth",[4339]="Bolt of Mageweave",[4340]="Gray Dye",[4341]="Yellow Dye",
 [4342]="Purple Dye",[4357]="Rough Blasting Powder",[4359]="Handful of Copper Bolts",[4360]="Rough Copper Bomb",[4361]="Copper Tube",
 [4363]="Copper Modulator",[4364]="Coarse Blasting Powder",[4368]="Flying Tiger Goggles",[4371]="Bronze Tube",[4375]="Whirring Bronze Gizmo",
 [4377]="Heavy Blasting Powder",[4380]="Big Bronze Bomb",[4382]="Bronze Framework",[4385]="Green Tinted Goggles",[4387]="Iron Strut",
 [4389]="Gyrochronatom",[4394]="Big Iron Bomb",[4397]="Gnomish Cloaking Device",[4399]="Wooden Stock",[4400]="Heavy Stock",
 [4402]="Small Flame Sac",[4404]="Silver Contact",[4405]="Crude Scope",[4407]="Accurate Scope",[4461]="Raptor Hide",
 [4470]="Simple Wood",[4536]="Shiny Red Apple",[4589]="Long Elegant Feather",[4603]="Raw Spotted Yellowtail",[4605]="Red-speckled Mushroom",
 [4611]="Blue Pearl",[4625]="Firebloom",[4655]="Giant Clam Meat",[5051]="Dig Rat",[5082]="Thin Kodo Leather",
 [5116]="Long Tail Feather",[5373]="Lucky Charm",[5465]="Small Spider Leg",[5466]="Scorpid Stinger",[5467]="Kodo Meat",
 [5468]="Soft Frenzy Flesh",[5469]="Strider Meat",[5470]="Thunder Lizard Tail",[5471]="Stag Meat",[5498]="Small Lustrous Pearl",
 [5500]="Iridescent Pearl",[5503]="Clam Meat",[5504]="Tangy Clam Meat",[5507]="Ornate Spyglass",[5633]="Great Rage Potion",
 [5635]="Sharp Claw",[5637]="Large Fang",[5784]="Slimy Murloc Scale",[5785]="Thick Murloc Scale",[5966]="Guardian Gloves",
 [6037]="Truesilver Bar",[6048]="Shadow Protection Potion",[6217]="Copper Rod",[6260]="Blue Dye",[6261]="Orange Dye",
 [6289]="Raw Longjaw Mud Snapper",[6291]="Raw Brilliant Smallfish",[6303]="Raw Slitherskin Mackerel",[6308]="Raw Bristle Whisker Catfish",[6317]="Raw Loch Frenzy",
 [6338]="Silver Rod",[6358]="Oily Blackmouth",[6359]="Firefin Snapper",[6361]="Raw Rainbow Fin Albacore",[6362]="Raw Rockscale Cod",
 [6370]="Blackmouth Oil",[6371]="Fire Oil",[6452]="Anti-Venom",[6453]="Strong Anti-Venom",[6470]="Deviate Scale",
 [6471]="Perfect Deviate Scale",[6522]="Deviate Fish",[6530]="Nightcrawlers",[6662]="Elixir of Giant Growth",[6889]="Small Egg",
 [7067]="Elemental Earth",[7068]="Elemental Fire",[7069]="Elemental Air",[7070]="Elemental Water",[7071]="Iron Buckle",
 [7072]="Naga Scale",[7075]="Core of Earth",[7076]="Essence of Earth",[7077]="Heart of Fire",[7078]="Essence of Fire",
 [7079]="Globe of Water",[7080]="Essence of Water",[7081]="Breath of Wind",[7082]="Essence of Air",[7191]="Fused Wiring",
 [7286]="Black Whelp Scale",[7287]="Red Whelp Scale",[7387]="Dusky Belt",[7392]="Green Whelp Scale",[7428]="Shadowcat Hide",
 [7909]="Aquamarine",[7910]="Star Ruby",[7911]="Truesilver Ore",[7912]="Solid Stone",[7966]="Solid Grinding Stone",
 [7971]="Black Pearl",[7972]="Ichor of Undeath",[7974]="Zesty Clam Meat",[8146]="Wicked Claw",[8150]="Deeprock Salt",
 [8151]="Flask of Mojo",[8152]="Flask of Big Mojo",[8153]="Wildvine",[8154]="Scorpid Scale",[8165]="Worn Dragonscale",
 [8167]="Turtle Scale",[8168]="Jet Black Feather",[8169]="Thick Hide",[8170]="Rugged Leather",[8171]="Rugged Hide",
 [8172]="Cured Thick Hide",[8173]="Thick Armor Kit",[8343]="Heavy Silken Thread",[8368]="Thick Wolfhide",[8544]="Mageweave Bandage",
 [8766]="Morning Glory Dew",[8831]="Purple Lotus",[8836]="Arthas' Tears",[8838]="Sungrass",[8839]="Blindweed",
 [8845]="Ghost Mushroom",[8846]="Gromsblood",[8925]="Crystal Vial",[8949]="Elixir of Agility",[8951]="Elixir of Defense",
 [8959]="Raw Spinefin Halibut",[9060]="Inlaid Mithril Cylinder",[9061]="Goblin Rocket Fuel",[9206]="Elixir of Greater Strength",[9210]="Ghost Dye",
 [9224]="Potion of Demon Slaying",[9260]="Volatile Rum",[9262]="Black Vitriol",[10026]="Black Mageweave Boots",[10284]="Simple Flour",
 [10285]="Shadow Silk",[10286]="Heart of the Wild",[10290]="Pink Dye",[10308]="Scroll of Intellect IV",[10500]="Fire Goggles",
 [10502]="Spellpower Goggles Xtreme",[10505]="Solid Blasting Powder",[10507]="Solid Dynamite",[10518]="Parachute Cloak",[10543]="Goblin Construction Helmet",
 [10546]="Deadly Scope",[10558]="Gold Power Core",[10559]="Mithril Tube",[10560]="Unstable Trigger",[10561]="Mithril Casing",
 [10576]="Mithril Mechanical Dragonling",[10586]="The Big One",[10588]="Goblin Rocket Helmet",[10592]="Catseye Draught",[10620]="Thorium Ore",
 [10938]="Lesser Magic Essence",[10939]="Greater Magic Essence",[10940]="Strange Dust",[10978]="Small Glimmering Shard",[10998]="Lesser Astral Essence",
 [11040]="Morrowgrain",[11082]="Greater Astral Essence",[11083]="Soul Dust",[11084]="Large Glimmering Shard",[11128]="Golden Rod",
 [11134]="Lesser Mystic Essence",[11135]="Greater Mystic Essence",[11137]="Vision Dust",[11138]="Small Glowing Shard",[11139]="Large Glowing Shard",
 [11144]="Truesilver Rod",[11174]="Lesser Nether Essence",[11175]="Greater Nether Essence",[11176]="Dream Dust",[11177]="Small Radiant Shard",
 [11178]="Large Radiant Shard",[11184]="Blue Power Crystal",[11185]="Green Power Crystal",[11186]="Red Power Crystal",[11188]="Yellow Power Crystal",
 [11291]="Star Wood",[11370]="Dark Iron Ore",[11371]="Dark Iron Bar",[11382]="Blood of the Mountain",[11754]="Black Diamond",
 [12037]="Mystery Meat",[12184]="Raptor Flesh",[12202]="Tiger Meat",[12203]="Red Wolf Meat",[12204]="Heavy Kodo Meat",
 [12205]="White Spider Meat",[12206]="Tender Crab Meat",[12207]="Giant Egg",[12208]="Tender Wolf Meat",[12223]="Meaty Bat Wing",
 [12359]="Thorium Bar",[12360]="Arcanite Bar",[12361]="Blue Sapphire",[12363]="Arcane Crystal",[12364]="Huge Emerald",
 [12365]="Dense Stone",[12607]="Brilliant Chromatic Scale",[12644]="Dense Grinding Stone",[12655]="Enchanted Thorium Bar",[12662]="Demonic Rune",
 [12735]="Frayed Abomination Stitching",[12753]="Skin of Shadow",[12799]="Large Opal",[12800]="Azerothian Diamond",[12803]="Living Essence",
 [12804]="Powerful Mojo",[12808]="Essence of Undeath",[12809]="Guardian Stone",[12810]="Enchanted Leather",[12811]="Righteous Orb",
 [12938]="Blood of Heroes",[13180]="Stratholme Holy Water",[13422]="Stonescale Eel",[13423]="Stonescale Oil",[13444]="Major Mana Potion",
 [13463]="Dreamfoil",[13464]="Golden Sansam",[13465]="Mountain Silversage",[13466]="Plaguebloom",[13467]="Icecap",
 [13468]="Black Lotus",[13510]="Flask of the Titans",[13511]="Flask of Distilled Wisdom",[13512]="Flask of Supreme Power",[13754]="Raw Glossy Mightfish",
 [13755]="Raw Winter Squid",[13756]="Raw Summer Bass",[13758]="Raw Redgill",[13759]="Raw Nightfin Snapper",[13760]="Raw Sunscale Salmon",
 [13888]="Darkclaw Lobster",[13889]="Raw Whitescale Salmon",[13890]="Raw Plated Armorfish",[13893]="Large Raw Mightfish",[13926]="Golden Pearl",
 [14044]="Cindercloth Cloak",[14047]="Runecloth",[14048]="Bolt of Runecloth",[14227]="Ironweb Spider Silk",[14256]="Felcloth",
 [14341]="Rune Thread",[14342]="Mooncloth",[14343]="Small Brilliant Shard",[14344]="Large Brilliant Shard",[14530]="Heavy Runecloth Bandage",
 [15407]="Cured Rugged Hide",[15408]="Heavy Scorpid Scale",[15409]="Refined Deeprock Salt",[15410]="Scale of Onyxia",[15412]="Green Dragonscale",
 [15414]="Red Dragonscale",[15415]="Blue Dragonscale",[15416]="Black Dragonscale",[15417]="Devilsaur Leather",[15419]="Warbear Leather",
 [15420]="Ironfeather",[15422]="Frostsaber Leather",[15423]="Chimera Leather",[15564]="Rugged Armor Kit",[15992]="Dense Blasting Powder",
 [15994]="Thorium Widget",[16000]="Thorium Tube",[16005]="Dark Iron Bomb",[16006]="Delicate Arcanite Converter",[16202]="Lesser Eternal Essence",
 [16203]="Greater Eternal Essence",[16204]="Illusion Dust",[16206]="Arcanite Rod",[17010]="Fiery Core",[17011]="Lava Core",
 [17012]="Core Leather",[17034]="Maple Seed",[17035]="Stranglethorn Seed",[17056]="Light Feather",[17194]="Holiday Spices",
 [17196]="Holiday Spirits",[17202]="Snowball",[17203]="Sulfuron Ingot",[18240]="Ogre Tannin",[18255]="Runn Tum Tuber",
 [18256]="Imbued Vial",[18512]="Larval Acid",[18562]="Elementium Ore",[18567]="Elemental Flux",[18631]="Truesilver Transformer",
 [18984]="Dimensional Ripper - Everlook",[18986]="Ultrasafe Transporter: Gadgetzan",[19441]="Huge Venom Sac",[19726]="Bloodvine",[19767]="Primal Bat Leather",
 [19768]="Primal Tiger Leather",[19774]="Souldarite",[19943]="Massive Mojo",[20381]="Dreamscale",[20424]="Sandworm Meat",
 [20498]="Silithid Chitin",[20500]="Light Silithid Carapace",[20501]="Heavy Silithid Carapace",[20520]="Dark Rune",[20725]="Nexus Crystal",
 [21024]="Chimaerok Tenderloin",[21071]="Raw Sagefish",[21153]="Raw Greater Sagefish",[22202]="Small Obsidian Shard",[22203]="Large Obsidian Shard",
 [22682]="Frozen Rune",[211422]="",[213369]="Faintly Glowing Leather",[213371]="Crate of Tainted Gniodine Solution",[213372]="",
 [213373]="Reflective Scrapmetal",[213376]="Low-Background Truesilver Plates",[213378]="Unstable Microfilament",[213379]="Hyperconductive Arcano-Filament",[213381]="Pile of Tarnished Gears",
 [213383]="Polished Truesilver Gears",[215430]="Gnomeregan Fallout",[220688]="",[220689]="",[221021]="",
 [221312]="",[238737]="Tinkerbox",[238786]="Schematic: Tinker: Teleport",[238787]="Schematic: Tinker: Nitro Boosts",[238788]="Schematic: Tinker: Magnetic Displacement",
 [239016]="Holy Salts",[239017]="Exquisite Spices",[247786]="Mote of Magic",[248815]="Heavy Thorium Ore",[248819]="Fel Crystal",
 [248820]="Torbernite",[248821]="Demonsage",[248822]="Death Lotus",[248823]="Marefoil",[248824]="Fel Hide",
 [248825]="Fel Leather",[249274]="Stranglevine",[249391]="Pyrite",[249399]="Frilled Lichen",[249409]="Cerulean Dye",
 [249410]="Sulfuric Acid",[249424]="Rosecap",[249425]="Bauxite",[249426]="Pitchblende",[249427]="Pristine Leather",
 [249428]="Pristine Hide",[249429]="Pristine Scale",[249430]="Magenta Dye",[249431]="Viridian Dye",[249432]="Sandpaper",
 [249726]="Azerothium Bar",[249796]="Hyjal Berries",[251290]="Legionite Bar",[251291]="Heavy Thorium Bar",[251524]="Whimsyfin",
 [255007]="Golem Isospring",[255645]="Swollen Venom Sac",[260784]="SAF-T Tabs",[260794]="EZ-Thro Wrap",[260796]="No Slip SAF-T Padding",
 [260799]="SAF-T Bell",[260801]="EZ-Thro Fireproof Fuse",[260804]="SAF-T Casing",[260808]="EZ-Thro Tru-Trigger",[260813]="SAF-T Tube",
 [260815]="EZ-Thro Shell",[260823]="Dimensional Transporter - Mt. Hyjal",[273125]="Lich's Index Finger",[273127]="Golem Heart",[273128]="Maker's Spark",
 [273129]="Essence of Anarchy",[273130]="Undeath Engine",[273131]="Bottled Screams",[274030]="Malleable Essence of Nature",
}
