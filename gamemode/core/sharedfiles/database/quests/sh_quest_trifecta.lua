local Quest = {}
Quest.Name = "quest_trifecta_banners"
Quest.PrintName = "Banners Over Dunmarrow"
Quest.Story = "Morvaine calls it peace. I call it a boot on our necks. Casimir's wardens walk our roads as if they were born here. Thin their numbers, and I will know you stand with Dunmarrow."
Quest.TurnInStory = "Good. Let them count their dead for once. Casimir will hear of this, and he will wonder which of my neighbours helped."
Quest.Level = 1
Quest.Kill = {}
Quest.Kill["morvaine_warden"] = 5
Quest.GainedExp = 60
Quest.GainedItems = {}
Quest.GainedItems["money"] = 80
Register.Quest(Quest)

local Quest = {}
Quest.Name = "quest_trifecta_quietgift"
Quest.PrintName = "A Quiet Gift from Kaelmoor"
Quest.QuestNeeded = "quest_trifecta_banners"
Quest.Story = "My nephew Aldric marches with Casimir's banners, as he must. Yet crates go missing from Kaelmoor's levy wagons and somehow find their way to us. Morvaine's patrols have started seizing them. Take them back."
Quest.TurnInStory = "Aldric's hand, unmistakably. He plays the loyal lord well. Better than his father ever did."
Quest.Level = 2
Quest.ObtainItems = {}
Quest.ObtainItems["trifecta_supplycrate"] = 3
Quest.GainedExp = 90
Quest.GainedItems = {}
Quest.GainedItems["money"] = 120
Quest.GainedItems["item_healthkit"] = 2
Register.Quest(Quest)

local Quest = {}
Quest.Name = "quest_trifecta_council"
Quest.PrintName = "The Threefold Council"
Quest.QuestNeeded = "quest_trifecta_quietgift"
Quest.Story = "I mean to call the Threefold Council: chosen men of Dunmarrow, Kaelmoor and Vestergrim, sitting as equals beside their lords. Grell will come, though his pride worries me. But no council meets while Morvaine holds the crossing. Break the garrison and bring down its captain."
Quest.TurnInStory = "The crossing is ours, for now. Send word to Kaelmoor and Vestergrim. Quietly."
Quest.Level = 3
Quest.Kill = {}
Quest.Kill["morvaine_soldier"] = 6
Quest.Kill["morvaine_captain"] = 1
Quest.GainedExp = 200
Quest.GainedItems = {}
Quest.GainedItems["money"] = 250
Register.Quest(Quest)
