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

local Quest = NewQuest("quest_maren_wagons", "Spilled Wagons", 8, nil,
	"You're Varne's new blade? Good. I move goods out of Kaelmoor for people who'd rather not be named. Morvaine's outriders keep stopping my wagons on the north road and taking whatever they like. Bring back five crates of my cargo and I'll pay you for your trouble. Don't ask what's in them.",
	"All five, and none of them opened. You'd be surprised how rare that is.")
Quest.ObtainItems = {dm_seized_cargo = 5}
Quest.GainedExp = 240
Quest.GainedItems = {money = 150, item_healthkit = 2}
Register.Quest(Quest)

local Quest = NewQuest("quest_maren_wat", "A Loose Tongue", 11, "quest_maren_wagons",
	"Someone is selling my routes to Morvaine, and I've found him: Wat the Weasel, a Gallows Company sellsword who drinks in two camps and lies in both. Kill him, and kill the sellswords he runs with. Four should make the point.",
	"Quieter already. Take the coif. It fell off a Morvaine wagon. Several things did.")
Quest.Kill = {bandit_wat = 1, bandit_sellsword = 4}
Quest.GainedExp = 420
Quest.GainedItems = {armor_helm_paddedcoif = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_maren_tolls", "Toll-Silver", 15, "quest_maren_wat",
	"The Gallows Company charges a toll on every road it holds, paid in silver with a gallows stamped over the old face. Bring me five of their toll-coins. If I know whose mint struck them, I'll know who's paying the company.",
	"Morvaine silver, restamped. Or Ossmere silver made to look like it. The weight is wrong for either. Somebody is working very hard to stay hidden. I'll keep digging.")
Quest.ObtainItems = {dm_company_toll = 5}
Quest.GainedExp = 600
Quest.GainedItems = {armor_shield_round = 1, money = 200}
Register.Quest(Quest)

local Quest = NewQuest("quest_maren_nightcrossing", "Night Crossing", 19, "quest_maren_tolls",
	"Lord Aldric is sending a whole season's grain across the river tonight, hidden in Kaelmoor's levy train. Morvaine knights ride the far bank. If the grain is seen, Aldric hangs. Clear the knights from the crossing: six of them.",
	"The grain is across. Dunmarrow eats this winter, and Lord Aldric will tell Casimir he lost it to rebels. In a sense, he did.")
Quest.Kill = {morvaine_knight = 6}
Quest.GainedExp = 950
Quest.GainedItems = {money = 450, item_healthkit = 4}
Register.Quest(Quest)

local Quest = NewQuest("quest_halvard_proof", "Trophies for Vestergrim", 20, "quest_ulric_grellspride",
	"Lord Grell is a loyal son of the old Trifecta, and he likes to see loyalty proved. Bring me four Morvaine banners, taken from their knights or the Hallowgate Guard. He will hang them in his hall at Vestergrim, where his guests can count them.",
	"Four banners. Lord Grell will be pleased, and when he is pleased he is generous. When he isn't, the whole Trifecta hears about it.")
Quest.ObtainItems = {dm_morvaine_banner = 4}
Quest.GainedExp = 1000
Quest.GainedItems = {money = 400}
Register.Quest(Quest)

local Quest = NewQuest("quest_halvard_honour", "Grell's Honour", 24, "quest_halvard_proof",
	"Knights of the Gallows Company burned a Vestergrim village on the border and hanged its reeve from his own gate. Lord Grell takes it as an insult to himself, more than to the village. Kill five Gallows Company knights, and make sure they know it is Vestergrim that sends you.",
	"Lord Grell thanks you. He will tell the story at the Council, and in his telling it will have been his idea.")
Quest.Kill = {bandit_footknight = 5}
Quest.GainedExp = 1300
Quest.GainedItems = {money = 600, armor_belt_swordbelt = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_halvard_seal", "The Marshal's Seal", 27, "quest_halvard_honour",
	"Lord Grell will sit at no council that cannot prove it has beaten Morvaine in the field. Lord-Marshal Vane wears the seal of the crossing on his belt. Bring it to me, and Lord Grell will lay it on the council table himself.",
	"The Marshal's seal, still bloody. Lord Grell will be very proud of himself. Lord Ulric will be proud of you. Try to make sure only one of them hears about it.")
Quest.ObtainItems = {dm_marshal_seal = 1}
Quest.GainedExp = 3100
Quest.GainedItems = {money = 900}
Register.Quest(Quest)
