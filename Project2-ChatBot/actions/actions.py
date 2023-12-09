# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import json

class ActionHelloWorld(Action):

    def name(self) -> Text:
        return "action_hello_world"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        dispatcher.utter_message(text="Hello World!")

        return []

class ActionShowOpeningHours(Action):
    def name(self) -> Text:
        return 'action_show_opening_hours'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        data = open('jsondata/opening_hours.json')
        opening_hours_data = json.load(data)
        opening_hours_items = opening_hours_data['items']

        list_items_opening_hours = []
        for day, hours in opening_hours_items.items():
            if hours['open'] == 0 and hours['close'] == 0:
                list_items_opening_hours.append(f"{day.capitalize()}: Closed")
            else:
                list_items_opening_hours.append(f"{day.capitalize()}: {hours['open']} - {hours['close']}")

        show_items_opening_hours = "\n".join(list_items_opening_hours)
        opening_hours_message = "Our restaurant is ready to welcome you with the following operating hours:\n" + show_items_opening_hours

        dispatcher.utter_message(text=opening_hours_message)
        data.close()
        return []

class ActionShowMenu(Action):
    def name(self) -> Text:
        return 'action_show_menu'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        data = open('jsondata/menu.json')
        menu_data = json.load(data)
        menu_items = menu_data['items']

        list_items_menu = ["{0} - {1}zl".format(menu_item.get('name'), menu_item.get('price'))
                           for menu_item in menu_items]
        show_items_menu = "\n".join(list_items_menu)
        menu_message = "Below you will find our current menu along with prices:\n" + show_items_menu

        dispatcher.utter_message(text=menu_message)
        data.close()
        return []