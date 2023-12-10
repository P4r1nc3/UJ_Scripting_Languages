# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet
import pymysql
import sys
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

        personal_details_entities = tracker.get_latest_entity_values("personal_details")
        quantity_entities = tracker.get_latest_entity_values("quantity")
        menu_item_entities = tracker.get_latest_entity_values("dish")
        special_request_entities = tracker.get_latest_entity_values("special_request")

        if not personal_details_entities:
            dispatcher.utter_message(text="I'm sorry, but it seems like you didn't introduced yourself. Please firstly introduce yourself, to place an order.")
            return []

        if not menu_item_entities:
            dispatcher.utter_message(text="I'm sorry, but it seems like you didn't specify any item you want to order.")
            return []

        quantity = int(next(quantity_entities))
        personal_details = next(personal_details_entities)
        menu_item = next(menu_item_entities).lower()
        special_request = next(special_request_entities).lower()

        menu_data = load_menu_data()

        if menu_item in menu_data:
            price_per_item = menu_data[menu_item]['price']
            # I assumed that quantity if the menu item do not affect the preparation time
            preparation_time = menu_data[menu_item]['preparation_time'] * 60

            dispatcher.utter_message(
                text=f"Hi, {personal_details}!\n"
                     f"{menu_item.capitalize()} costs {price_per_item}zl "
                     f"and has been added to your order.\n"
                     f"Your {menu_item} {special_request} will be ready in {preparation_time} minutes."
            )

            total_price = price_per_item * quantity

        else:
            dispatcher.utter_message(
                text=f"I'm sorry, but it seems like {menu_item} is not on our menu. Please choose from the available options."
            )
            return []

        dispatcher.utter_message(
            text=f"The total amount for your order is {total_price}zl.\n"
                 f"To confirm your order, please provide your delivery address."
        )

        sqlConnection = pymysql.connect(host="localhost", user="root", password="admin12345", database="rasa_bot")
        cursor = sqlConnection.cursor()

        cursor.execute(
            "INSERT INTO orders (menu_item, quantity, preparation_time, special_request, total_price, personal_details) VALUES (%s, %s, %s, %s, %s, %s)",
            (menu_item, quantity, preparation_time, special_request, total_price, personal_details))

        cursor.execute("SELECT LAST_INSERT_ID()")
        order_id = cursor.fetchone()[0]

        sqlConnection.commit()
        sqlConnection.close()

        return [SlotSet("order_id", order_id)]

class ActionConfirmOrder(Action):
    def name(self) -> Text:
        return 'action_confirm_order'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        delivery_address = tracker.get_latest_entity_values("address")

        if not delivery_address:
            dispatcher.utter_message(
                text="I'm sorry, but it seems like you didn't provide a valid address. Please try again.")
            return []

        order_id = tracker.get_slot("order_id")

        sqlConnection = pymysql.connect(host="localhost", user="root", password="admin12345", database="rasa_bot")
        cursor = sqlConnection.cursor()

        cursor.execute(
            "UPDATE orders SET delivery_address = %s WHERE order_id = %s",
            (', '.join(delivery_address), order_id))

        sqlConnection.commit()
        sqlConnection.close()

        dispatcher.utter_message(
            text=f"Great! Your order will be delivered. Thank you for ordering!"
        )

        return []

def load_menu_data():
    with open('jsondata/menu.json', 'r') as file:
        menu_data = json.load(file)
    return {item['name'].lower(): item for item in menu_data['items']}