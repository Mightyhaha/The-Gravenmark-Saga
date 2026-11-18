
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

local function QuestExp(intLevel)
	return math.Round(ExpToNextLevel(intLevel) * 0.25)
end

local Quest = NewQuest("quest_rebellion_1", "Start of the Rebellion", 100, "quest_ulric_writ",
	"Before the Council, before any of this, there was a levy soldier in Dunmarrow who drew an iron sword on a Morvaine tax-collector, and the rest of us followed. The sword hangs in my hall. It deserves better than a wall. Bring me ebony and leather enough to rebind it, and it is yours to carry.",
	"There. The same blade, the same nicks. Carry it well, and it will become more than it is. That is what the rebellion did to all of us.")
Quest.ObtainItems = {mat_ingot_ebony = 6, mat_leather_6 = 4}
Quest.GainedExp = QuestExp(100)
Quest.GainedItems = {legendary_rebellion_1 = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_rebellion_2", "Voice of the Rebellion", 110, "quest_rebellion_1",
	"They are talking about the sword in Kaelmoor now. Let them see why. Bring it back with ebony for a new edge and cloth for the grip.",
	"Listen to it ring. A rumour becomes a voice when enough people repeat it.")
Quest.ObtainItems = {legendary_rebellion_1 = 1, mat_ingot_ebony = 8, mat_cloth_6 = 4}
Quest.GainedExp = QuestExp(110)
Quest.GainedItems = {legendary_rebellion_2 = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_rebellion_3", "Banner of the Rebellion", 120, "quest_rebellion_2",
	"A banner needs something to rally around. Bring the sword and Gravensteel to silver it. And take this: the Council had three rings made from one, for those who carried us furthest. One of them is yours.",
	"Now they will see it from across a battlefield. Wear the signet. Three seats and no throne, remember.")
Quest.ObtainItems = {legendary_rebellion_2 = 1, mat_ingot_graven = 6, mat_leather_7 = 4}
Quest.GainedExp = QuestExp(120)
Quest.GainedItems = {legendary_rebellion_3 = 1, legendary_trifecta_signet = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_rebellion_4", "Fire of the Rebellion", 130, "quest_rebellion_3",
	"The border is burning, and the sword should burn with it. Fold Gravensteel into the blade. Bring me the metal and cloth for the wrap.",
	"It runs hot now. Good. So does everything else.")
Quest.ObtainItems = {legendary_rebellion_3 = 1, mat_ingot_graven = 10, mat_cloth_7 = 4}
Quest.GainedExp = QuestExp(130)
Quest.GainedItems = {legendary_rebellion_4 = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_rebellion_5", "Fury of the Rebellion", 140, "quest_rebellion_4",
	"Dreadforged iron, and leather that will not burn. The last steps are the hardest. And take this ember from the first fire we lit in Dunmarrow. It has kept me alive. It is your turn.",
	"Black as the night we started it. Keep the ember close. It burns brightest when you need it.")
Quest.ObtainItems = {legendary_rebellion_4 = 1, mat_ingot_dread = 6, mat_leather_8 = 4}
Quest.GainedExp = QuestExp(140)
Quest.GainedItems = {legendary_rebellion_5 = 1, legendary_ember_dunmarrow = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_rebellion_6", "Rebellion", 150, "quest_rebellion_5",
	"One last forging. After this it will not be a sword the rebellion carries. It will be the rebellion. Bring Dreadforged iron and the finest cloth there is.",
	"It has no other name now. It never needed one.")
Quest.ObtainItems = {legendary_rebellion_5 = 1, mat_ingot_dread = 10, mat_cloth_8 = 6}
Quest.GainedExp = QuestExp(150)
Quest.GainedItems = {legendary_rebellion_6 = 1}
Register.Quest(Quest)
