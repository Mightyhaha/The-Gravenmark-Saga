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

local Quest = NewQuest("quest_barrow_field", "The Restless Field", 36, nil,
	"You've a blade and you're still breathing, so you'll do. I'm Edda. I bury Dunmarrow's dead, and I've done it forty years. This spring they stopped staying buried. The old Harrow house down the road had its own little plot of graves, and now the yard is full of them, walking the rows. Put eight of them back in the ground for me. Aim for the head. It's quicker for both of you.",
	"Eight. I heard every one of them fall from here. You get used to the sound. Don't let anyone tell you that you shouldn't.")
Quest.Kill = {undead_plaguedead = 8}
Quest.GainedExp = GM:GetQuestExp(36, "side")
Quest.GainedItems = {money = GM:GetQuestMoney(36, "side"), item_healthkit = 2}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_runners", "Runners in the Rows", 40, "quest_barrow_field",
	"Some of the newer dead are quick. Too quick. They were young when they went into the ground, and they still run like it. Two of the chapel boys were caught on the road last week. Kill six of the runners, and I'll give you a good pair of boots off my shelf. You'll want to be quicker than they are next time.",
	"Six. Good. Here, the boots. They belonged to my husband. He'd have liked that they're being used for this.")
Quest.Kill = {undead_runner = 6}
Quest.GainedExp = GM:GetQuestExp(40, "side")
Quest.GainedItems = {[GM:GetQuestGear("slot_boots", 40)] = 1, money = GM:GetQuestMoney(40, "side")}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_tokens", "Grave-Tokens", 44, "quest_barrow_runners",
	"Every soul in that yard went down with a lead token, pressed with their family's mark. The dead still carry them. Bring me six, and I'll know which families have to be told. Someone should hear it from a person and not from a corpse at the door.",
	"Harrow, Tull, Aldermoor... I knew the Tull girl. I'll go to her mother tonight. Thank you for bringing them back whole.")
Quest.ObtainItems = {ud_grave_token = 6}
Quest.GainedExp = GM:GetQuestExp(44, "side")
Quest.GainedItems = {[GM:GetQuestGear("slot_helm", 44)] = 1, money = GM:GetQuestMoney(44, "side")}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_bloated", "The Swollen Dead", 48, "quest_barrow_tokens",
	"Now there are swollen ones too, fat with whatever rots inside them. They spit, and what they spit burns. Kill three of them, and six of the others while you're out there. When you come back, I'll tell you what I found inside the house.",
	"You smell like the yard. Sit down, I'll tell you. The Harrows kept their dead in the cellar, the old way, and the cellar door's been opened from the inside. There's bone walking in there now. Old bone. Rest a while first. You'll need it.")
Quest.Kill = {undead_bloated = 3, undead_plaguedead = 6}
Quest.GainedExp = GM:GetQuestExp(48, "side")
Quest.GainedItems = {ring_reward_oath = 1, money = GM:GetQuestMoney(48, "side")}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_gravehouse", "The Harrow Cellar", 52, "quest_barrow_bloated",
	"The dead in the Harrow cellar aren't Harrows. They're barrow-folk, buried before Dunmarrow had a name, with nothing left on them but bone. Somebody carried them there. Go in, break ten of them, and look for anything that tells me who.",
	"Chalk marks on the cellar walls, pointing north. Toward the old chapel graveyard and the catacombs under it. I was afraid of that. My grandmother said the catacombs were sealed for a reason.")
Quest.Kill = {undead_risen = 10}
Quest.GainedExp = GM:GetQuestExp(52, "side")
Quest.GainedItems = {money = GM:GetQuestMoney(52, "side"), item_healthkit = 4}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_spears", "The Old Watch", 57, "quest_barrow_gravehouse",
	"Whoever moved them sent a guard along. Spearmen and shield-bearers, still keeping a watch over nothing in the Harrow house. Kill six of the spearmen and four of the guards, and the house is ours again.",
	"They still stood in rank? Even now? Whoever they served must have been something to see. Take this spear. The house is quiet. The catacombs won't be. Don't go near them until you've a great deal more steel in you than you have now. I'll be here.")
Quest.Kill = {undead_gravespear = 6, undead_barrowguard = 4}
Quest.GainedExp = GM:GetQuestExp(57, "side")
Quest.GainedItems = {[GM:GetQuestGear("spear", 57)] = 1}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_lord", "The Barrow Lord", 92, "quest_barrow_spears",
	"You've grown. Good. The catacombs under the chapel are open, and there's a lord down there. The barrow-folk buried him in his armour with his sword across his chest, and he's got up wearing both. The rest of them answer to him. Kill him, and six of his guard, and the deep crypts will be open to you.",
	"The Barrow Lord, gone back to sleep. I'd say he earned the rest, but I don't think he chose to wake.")
Quest.Kill = {undead_bonelord = 1, undead_barrowguard = 6}
Quest.GainedExp = GM:GetQuestExp(92, "side")
Quest.GainedItems = {[GM:GetQuestGear("slot_chest", 92)] = 1, money = GM:GetQuestMoney(92, "side")}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_ledger", "The Ledger of Names", 100, "quest_barrow_lord",
	"The skeletons in the catacombs are carrying pages. Someone has written down every grave in Dunmarrow: who lies there, when they went in, and which ones have been called up. That's not the dead's doing. That's a living hand. Bring me five of those pages.",
	"The hand's the same on every page. He signs them at the bottom, like a clerk: 'Raised, and gladly.' He's in the deepest crypt. He has been all along. And whatever he is now, he's strong. Very strong. Don't go down to him until you're far stronger than you are today.")
Quest.ObtainItems = {ud_ledger_page = 5}
Quest.GainedExp = GM:GetQuestExp(100, "side")
Quest.GainedItems = {money = GM:GetQuestMoney(100, "side")}
Register.Quest(Quest)

local Quest = NewQuest("quest_barrow_necromancer", "Who Wakes the Barrows", 125, "quest_barrow_ledger",
	"It's time. The Necromancer sits in the deepest crypt, and three of his first dead stand guard around him: the oldest ones, and the strongest. He'll raise more while you fight him, so kill him quickly, and the bones he's raised will fall with him. Then bring me his staff. I want to see it burn.",
	"His staff. It's colder than ice and it hums. No, keep it. I've changed my mind. Someone should carry it who'll use it against his kind. And take this ring. It was my mother's. She'd want it on the hand that ended this.")
Quest.Kill = {undead_necromancer = 1}
Quest.GainedExp = GM:GetQuestExp(125, "main")
Quest.GainedItems = {unique_gravecaller = 1, ring_reward_ashenvow = 1, money = GM:GetQuestMoney(125, "main")}
Register.Quest(Quest)
