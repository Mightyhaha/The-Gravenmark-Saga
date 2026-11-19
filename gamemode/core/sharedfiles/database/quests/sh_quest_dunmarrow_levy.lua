local function NewQuest(Name, PrintName, Level, QuestNeeded, Story, TurnInStory)
	local Quest = {}
	Quest.Name = Name
	Quest.PrintName = PrintName
	Quest.Level = Level
	Quest.QuestNeeded = QuestNeeded
	Quest.Story = Story
	Quest.TurnInStory = TurnInStory
	return Quest
end

local Quest = NewQuest("quest_dm_muster", "Answer the Muster", 1, nil,
	"Another one walked in out of the pines, eh? Good. Dunmarrow needs every arm that can hold a blade. I'm Sergeant Varne, and until Lord Ulric says otherwise, you're mine. Here's a padded gambeson from the stores. Put it on before you go anywhere: open your pack and wear it. Then come back and tell me you're ready.",
	"Better. You almost look like a soldier. Almost.")
Quest.StartingItems = {armor_chest_gambeson = 1}
Quest.GainedExp = GM:GetQuestExp(1, "starter")
Quest.GainedItems = {money = GM:GetQuestMoney(1, "starter")}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_greensteel", "Green Steel", 2, "quest_dm_muster",
	"Morvaine sends its fresh levies into these woods to learn the paths. Boys, mostly, with rusted swords and red cloaks too big for them. They are still the enemy. Kill four Morvaine recruits. Keep your feet moving, and don't let them circle you.",
	"Four. You'll remember the first one longer than you'd like. Good. That means you're still a person.")
Quest.Kill = {morvaine_recruit = 4}
Quest.GainedExp = GM:GetQuestExp(2, "starter")
Quest.GainedItems = {money = GM:GetQuestMoney(2, "starter")}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_rations", "What the Dead Leave Behind", 4, "quest_dm_greensteel",
	"Morvaine feeds its levies better than Dunmarrow feeds its lords. When they fall, they drop what they carried: walk up to it and use it to pick it up. Bring me four packs of their marching rations. The camp is hungry, and I won't let good salt pork rot in the ferns.",
	"Salt pork and hard bread. Tonight the levy eats like the enemy.")
Quest.ObtainItems = {dm_morvaine_rations = 4}
Quest.GainedExp = GM:GetQuestExp(4, "starter")
Quest.GainedItems = {item_healthkit = 2}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_caches", "The Old Caches", 6, "quest_dm_rations",
	"Before Morvaine came, the old levy hid supplies all over this forest, in chests, lockers, anything with a lid. Most were looted years ago, but not all. Search the old chests you find: use one and wait while you dig through it. Bring me two of our levy caches, one per chest. Anything else you find in there, keep.",
	"Flints, arrowheads, a little coin, and my old quilted belt, of all things. Take it. It never fit me anyway.")
Quest.ObtainItems = {dm_levy_cache = 2}
Quest.GainedExp = GM:GetQuestExp(6, "starter")
Quest.GainedItems = {[GM:GetQuestGear("slot_waist", 6)] = 1, money = GM:GetQuestMoney(6, "starter")}
Register.Quest(Quest)

local Quest = NewQuest("quest_trifecta_banners", "Wardens on the Road", 8, "quest_dm_caches",
	"Casimir's wardens walk our roads as if they were born here, taking tolls in Dunmarrow's name and sending the coin to Hallowgate. They're better armed than the recruits, and they don't run. Thin their numbers: five wardens. Lord Ulric wants Casimir lying awake, wondering which of his loyal neighbours is helping us.",
	"Good. Let them count their dead for once. Take this buckler. It's a small shield, but it will turn a blade if you're quick with it.")
Quest.Kill = {morvaine_warden = 5}
Quest.GainedExp = GM:GetQuestExp(8, "starter")
Quest.GainedItems = {[GM:GetQuestGear("slot_offhand", 8)] = 1, money = GM:GetQuestMoney(8, "starter")}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_turncloaks", "Turncloaks in the Pines", 10, "quest_trifecta_banners",
	"When Casimir calls his banners, Kaelmoor and Vestergrim have to march against us, whether their hearts are in it or not. Some of their levymen would rather rob than fight their own kin, so they desert and turn bandit. I don't blame them for running. I blame them for robbing our supply runners. Kill six banner deserters.",
	"A sad business. They were farmers once, like half this camp. Here, a proper blade. That rusty thing is an insult to your arm.")
Quest.Kill = {bandit_deserter = 6}
Quest.GainedExp = GM:GetQuestExp(10, "starter")
Quest.GainedItems = {[GM:GetQuestGear("sword", 10)] = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_coinpurses", "Blood Money", 12, "quest_dm_turncloaks",
	"The deserters and the forest brigands rob everyone who walks these roads, our people included. Bring back three of the coin purses they've stolen. Half goes back to the villages. The other half pays for arrows.",
	"Mostly copper, and a few Morvaine crowns. Hallowgate stamps the king's face on every one, so even our coin reminds us who's winning. Here's your share.")
Quest.ObtainItems = {dm_stolen_purse = 3}
Quest.GainedExp = GM:GetQuestExp(12, "side")
Quest.GainedItems = {money = GM:GetQuestMoney(12, "side")}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_ironforthelevy", "Iron for the Levy", 13, "quest_dm_turncloaks",
	"Morvaine's footsoldiers carry better steel than we do, and their kit is worth more than ours. Kill six soldiers and we'll strip every scrap of iron and leather we can use. I'll see you get a share, and any smith in camp will show you how to work it.",
	"Here: iron, hide and linen, and three sets of notes Brother Aldwin copied out for the recruits. Read them, then find a forge, a tanner's bench or a tailor's table and learn the work. A soldier who can mend his own kit lives longer.")
Quest.Kill = {morvaine_soldier = 6}
Quest.GainedExp = GM:GetQuestExp(13, "starter")
Quest.GainedItems = {mat_ingot_scrap = 10, mat_leather_1 = 4, mat_cloth_1 = 4, money = GM:GetQuestMoney(13, "starter"), recipe_scroll_weapon_melee_sword = 1, recipe_scroll_weapon_ranged_huntingbow = 1, recipe_scroll_armor_chest_gambeson = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_blackjory", "Black Jory", 16, "quest_dm_ironforthelevy",
	"The brigands have a chief now: Black Jory, a Vestergrim deserter who's done well enough to buy himself a shield. Kill him, and thin out his forest brigands while you're at it. Five brigands, and Jory.",
	"Jory's dead? Vestergrim won't miss him, and neither will I. Take this hand axe. It's better than anything he was carrying.")
Quest.Kill = {bandit_brigand = 5, bandit_jory = 1}
Quest.GainedExp = GM:GetQuestExp(16, "main")
Quest.GainedItems = {[GM:GetQuestGear("axe", 16)] = 1, money = GM:GetQuestMoney(16, "main")}
Register.Quest(Quest)

local Quest = NewQuest("quest_dm_sealedletter", "A Letter for the Lord", 19, "quest_dm_blackjory",
	"You've done more for this camp than most who come through here. Lord Ulric wants fighters he can trust with harder work than mine. Take this letter to him, and don't break the seal. He's the last of the three brothers who ruled the Trifecta, so mind your manners. He keeps his camp behind the hills past the old lighthouse. Morvaine holds the lighthouse, so don't walk up to it. Just before it, there's a cave in the rocks by the path, with an iron gate inside. Go through. The tunnel comes out in the mine at Lord Ulric's camp, and nobody on the lighthouse will see you go.",
	"Varne writes that you are stubborn, reckless, and the best recruit he's had since the war. From Varne, that is practically a knighthood. You came through the tunnel? Good. Smugglers dug it, back when this was their mine. Use it whenever you need to go back to the levy. It's quicker than the road, and safer. Sit down. We have a great deal to discuss.")
Quest.StartingItems = {dm_sealed_letter = 1}
Quest.ObtainItems = {dm_sealed_letter = 1}
Quest.TurnInNPC = "quest_ulric"
Quest.GainedExp = GM:GetQuestExp(19, "main")
Quest.GainedItems = {money = GM:GetQuestMoney(19, "main")}
Register.Quest(Quest)
