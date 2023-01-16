extends Node

export(String) var quest_name = "Collect all screentones"

export(String) var required_item = "Screentone"
export(int) var required_amount = 10
export(String) var reward_item = "Blue ink"
export(int) var reward_amount = 1

export(String, MULTILINE) var initial_text = "Hello, nice to meet you. My name is Ika and I need your help to collect some screentones to prettify this world.. would you please help me? I will give you a reward in exchange for your hard labor, of course. "
export(String, MULTILINE) var pending_text = "Please dont forget to collect the screentones"
export(String, MULTILINE) var delivered_text = "Thank you! This is your ink."

func process() -> String:
	var quest_status = Quest.get_status(quest_name)
	match quest_status:
		Quest.STATUS.NONEXISTENT:
			Quest.accept_quest(quest_name)
			return initial_text
		Quest.STATUS.STARTED:
			if Inventory.get_item(required_item) >= required_amount:
				Inventory.remove_item(required_item, required_amount)
				Quest.change_status(quest_name, Quest.STATUS.COMPLETE)
				Inventory.add_item(reward_item, reward_amount)
				return delivered_text
			else:
				return pending_text
		_:
			return ""
