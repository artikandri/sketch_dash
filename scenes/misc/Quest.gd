extends Node

export(String) var quest_name = ""

export(String) var required_item = ""
export(int) var required_amount = 0
export(String) var reward_item = ""
export(int) var reward_amount = 0

export(String, MULTILINE) var initial_text = ""
export(String, MULTILINE) var pending_text = ""
export(String, MULTILINE) var delivered_text = ""

func process() -> String:
	var quest_status = Quest.get_status(quest_name)
	match quest_status:
		Quest.STATUS.NONEXISTENT:
			Quest.accept_quest(quest_name)
			return initial_text
		Quest.STATUS.STARTED:
			if required_item != "":
				if Inventory.get_item(required_item) >= required_amount:
					Inventory.remove_item(required_item, required_amount)
					Quest.change_status(quest_name, Quest.STATUS.COMPLETE)
					Inventory.add_item(reward_item, reward_amount)
					return delivered_text
				else:
					return pending_text
			else:
				Quest.change_status(quest_name, Quest.STATUS.COMPLETE)
				Inventory.add_item(reward_item, reward_amount)
				return delivered_text
		_:
			return ""
