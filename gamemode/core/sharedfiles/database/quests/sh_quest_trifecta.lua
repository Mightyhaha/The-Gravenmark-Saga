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

local Quest = NewQuest("quest_trifecta_quietgift", "A Quiet Gift from Kaelmoor", 22, "quest_dm_sealedletter",
	"My nephew Aldric marches under Casimir's banners, as he must. Yet crates go missing from Kaelmoor's levy wagons, and somehow they find their way to us. Morvaine's patrols have started seizing them on the roads. Take them back: three bundles, from the wardens, soldiers and outriders who carry them.",
	"Aldric's hand, unmistakably. He plays the loyal lord well. Better than his father ever did.")
Quest.ObtainItems = {trifecta_supplycrate = 3}
Quest.GainedExp = GM:GetQuestExp(22, "main")
Quest.GainedItems = {money = GM:GetQuestMoney(22, "main"), item_healthkit = 3}
Register.Quest(Quest)

local Quest = NewQuest("quest_ulric_ashbeads", "Beads of Ash", 28, "quest_trifecta_quietgift",
	"Sellswords have come into my forest calling themselves the Gallows Company. They rob Morvaine and Dunmarrow alike, and nobody knows who pays them. My scouts swear their dead carry strings of ash-beads, the prayer beads of Ossmere's faith. The same beads Lucan Valcrest found on his murdered guards, the beads that set the whole continent burning. Bring me four strings. I want to see them with my own eyes.",
	"Real beads, or good copies. Either Ossmere wants a second war, or someone wants Casimir to believe it does. Or wants me to. Proof of nothing, and that is the most dangerous kind of proof. Keep this between us.")
Quest.ObtainItems = {dm_ashbeads = 4}
Quest.GainedExp = GM:GetQuestExp(28, "main")
Quest.GainedItems = {money = GM:GetQuestMoney(28, "main")}
Register.Quest(Quest)

local Quest = NewQuest("quest_trifecta_council", "The Threefold Council", 35, "quest_ulric_ashbeads",
	"I mean to call the Threefold Council: chosen men of Dunmarrow, Kaelmoor and Vestergrim, sitting as equals beside their lords. Grell will come, though his pride worries me. But no council meets while Morvaine holds the river crossing. Break the garrison: six soldiers, and bring down its captain.",
	"The crossing is ours, for now. Send word to Kaelmoor and Vestergrim. Quietly.")
Quest.Kill = {morvaine_soldier = 6, morvaine_captain = 1}
Quest.GainedExp = GM:GetQuestExp(35, "main")
Quest.GainedItems = {[GM:GetQuestGear("axe", 35)] = 1, money = GM:GetQuestMoney(35, "main")}
Register.Quest(Quest)

local Quest = NewQuest("quest_ulric_grellspride", "Grell's Pride", 42, "quest_trifecta_council",
	"Lord Grell has sent an envoy to watch us: Halvard Grey. Grell wants proof that Dunmarrow can do more than hide in the trees before he risks Vestergrim's neck. Pride, of course. But I can't afford to lose him. Morvaine has sent knights to retake the crossing. Kill five of them, where Halvard can see it.",
	"Halvard watched every blow and wrote it all down. Grell will read about you before he reads about me. Let him.")
Quest.Kill = {morvaine_knight = 5}
Quest.GainedExp = GM:GetQuestExp(42, "main")
Quest.GainedItems = {[GM:GetQuestGear("slot_shoulder", 42)] = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_ulric_ambush", "The Nephew's Warning", 50, "quest_ulric_grellspride",
	"A message from Kaelmoor, in Aldric's own cipher. Casimir has ordered a column of Hallowgate Guards to escort Kaelmoor's levy into Dunmarrow, and Aldric is to march at its head. He cannot refuse. But if the column never arrives, nobody can blame him for it. Break the escort: four Hallowgate Guards and six soldiers.",
	"Aldric's levy has turned back to Kaelmoor, delayed by rebel raids. Casimir will be cold to him for it. Aldric has survived Casimir's coldness before. He learned it from him.")
Quest.Kill = {morvaine_royalguard = 4, morvaine_soldier = 6}
Quest.GainedExp = GM:GetQuestExp(50, "main")
Quest.GainedItems = {[GM:GetQuestGear("spear", 50)] = 1, money = GM:GetQuestMoney(50, "main")}
Register.Quest(Quest)

local Quest = NewQuest("quest_ulric_robberknight", "The Robber Knight", 58, "quest_ulric_ambush",
	"The Gallows Company has a master: Sir Gaspard Thorne, a robber knight who sells his sword to anyone, and keeps it for himself when that pays better. His hedge knights have been killing my council messengers on the forest roads, and I have letters for Kaelmoor and Vestergrim that must get through. Kill four of his hedge knights, and Thorne himself.",
	"Thorne carried a purse of Morvaine crowns and a string of ash-beads. Paid by one, praying with the other, or neither. We will never know which, and I suspect that was the point.")
Quest.Kill = {bandit_hedgeknight = 4, bandit_raubritter = 1}
Quest.GainedExp = GM:GetQuestExp(58, "main")
Quest.GainedItems = {[GM:GetQuestGear("slot_helm", 58)] = 1, money = GM:GetQuestMoney(58, "main")}
Register.Quest(Quest)

local Quest = NewQuest("quest_ulric_marshal", "The Marshal of the Crossing", 67, "quest_ulric_robberknight",
	"Casimir has stopped sending captains. He has sent Lord-Marshal Edric Vane, who held the Pale Sea coast through the whole war. Vane means to take the crossing back and hang every rebel he finds, and he commands from the front. Kill four of his knights, and then Vane himself.",
	"Vane is dead, and Casimir will feel it. He is a fair king. He will be just as fair about avenging him. We have a season, perhaps two, before Hallowgate answers.")
Quest.Kill = {morvaine_knight = 4, morvaine_marshal = 1}
Quest.GainedExp = GM:GetQuestExp(67, "main")
Quest.GainedItems = {[GM:GetQuestGear("sword", 67)] = 1, money = GM:GetQuestMoney(67, "main")}
Register.Quest(Quest)

local Quest = NewQuest("quest_ulric_writ", "The First Sitting", 75, "quest_ulric_marshal",
	"It's time. Take this writ to Halvard Grey, Grell's envoy. It names the day and place of the Threefold Council's first sitting: Dunmarrow, Kaelmoor and Vestergrim, three seats and no throne. If Grell signs it, the Trifecta stands as one for the first time since my brothers died.",
	"Lord Grell will sit. He asks me to tell Lord Ulric that he does it for the glory of the old Trifecta, not for Dunmarrow. He will also want the seat nearest the fire.")
Quest.StartingItems = {dm_council_writ = 1}
Quest.ObtainItems = {dm_council_writ = 1}
Quest.TurnInNPC = "quest_halvard"
Quest.GainedExp = GM:GetQuestExp(75, "main")
Quest.GainedItems = {money = GM:GetQuestMoney(75, "main")}
Register.Quest(Quest)
