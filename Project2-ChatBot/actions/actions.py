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

class ActionIsOpen(Action):
    def name(self) -> Text:
        return "action_is_open"

    def run(self, dispatcher: CollectingDispatcher,
                        tracker: Tracker,
                        domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        request_day = ([blob['value'] for blob in tracker.latest_message['entities'] if blob['entity'] == 'day'] or ('',))[0]
        request_hour = ([blob['value'] for blob in tracker.latest_message['entities'] if blob['entity'] == 'hour'] or ('',))[0]

        data = open('jsondata/opening_hours.json')
        opening_data = json.load(data)
        opening_items = opening_data['items']

        hours = opening_items.get(request_day.capitalize())

        if hours is None:
            dispatcher.utter_message(text="Sorry, you entered incorrect data")
            data.close()
            return []

        if request_hour is '':
            if int(hours['open']) == 0 and int(hours['close']) == 0:
                dispatcher.utter_message(text=f"Unfortunately restaurant is close on {request_day}")
                data.close()
                return []

            dispatcher.utter_message(text=f"Yes, restaurant is open between {hours['open']} and {hours['close']} on {request_day}")
            data.close()
            return []

        if request_hour is not '':
            if int(request_hour) < 0 or int(request_hour) > 24:
                dispatcher.utter_message(text="Sorry, you entered incorrect hour")
                data.close()
                return []

            if hours['close'] > int(request_hour) > hours['open']:
                dispatcher.utter_message(text=f"Yes, our restaurant is open on {request_day} at {request_hour}")
                data.close()
                return []
            else:
                dispatcher.utter_message(text=f"No, our restaurant is close on {request_day} at {request_hour}")
                data.close()
                return []
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

class ActionPlaceOrder(Action):
    def name(self) -> Text:
        return 'action_place_order'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        menu_items_entities = tracker.get_latest_entity_values("dish")

        if not menu_items_entities:
            dispatcher.utter_message(text="I'm sorry, but it seems like you didn't specify any items you want to order.")
            return []

        menu_data = load_menu_data()
        total_price = 0

        for menu_item_entity in menu_items_entities:
            menu_item = menu_item_entity.lower()

            if menu_item in menu_data:
                price_per_item = menu_data[menu_item]['price']
                preparation_time = menu_data[menu_item]['preparation_time'] * 60

                dispatcher.utter_message(
                    text=f"{menu_item_entity} which costs {price_per_item}zl has been added to your order.\nYour {menu_item} will be ready in {preparation_time} minutes.\n\n"
                )

                total_price += price_per_item
            else:
                dispatcher.utter_message(
                    text=f"I'm sorry, but it seems like {menu_item} is not on our menu. Please choose from the available options."
                )

        dispatcher.utter_message(
            text=f"The total amount for your order is {total_price}zl."
        )

        return []

class ActionAskForAddress(Action):
    def name(self) -> Text:
        return 'action_ask_for_address'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        dispatcher.utter_message(
            text="To confirm your order, please provide your delivery address.")
        return []


class ActionConfirmOrder(Action):
    def name(self) -> Text:
        return 'action_confirm_order'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        # Assuming 'address' is an entity extracted from the user's response
        delivery_address = tracker.get_latest_entity_values("address")

        if not delivery_address:
            dispatcher.utter_message(
                text="I'm sorry, but it seems like you didn't provide a valid address. Please try again.")
            return []

        dispatcher.utter_message(
            text=f"Great! Your order will be delivered to {', '.join(delivery_address)}. Thank you for ordering!"
        )

        return []

def load_menu_data():
    with open('jsondata/menu.json', 'r') as file:
        menu_data = json.load(file)
    return {item['name'].lower(): item for item in menu_data['items']}