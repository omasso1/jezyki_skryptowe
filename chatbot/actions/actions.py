# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

# from typing import Any, Text, Dict, List
#
# from rasa_sdk import Action, Tracker
# from rasa_sdk.executor import CollectingDispatcher
#
#
# class ActionHelloWorld(Action):
#
#     def name(self) -> Text:
#         return "action_hello_world"
#
#     def run(self, dispatcher: CollectingDispatcher,
#             tracker: Tracker,
#             domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
#
#         dispatcher.utter_message(text="Hello World!")
#
#         return []


from typing import Text, Dict, Any, List
from rasa_sdk.events import SlotSet

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher

import json
import os
import logging


###############################
########## INIT ###############
###############################

debugLoggerName = "actionDebugLogger"
debugLogger = logging.getLogger(debugLoggerName)
fileHandler = logging.FileHandler("debugLog.txt")
debugLogger.addHandler(fileHandler)

with open("./data/opening_hours.json") as file:
    openingHoursData = json.load(file)["items"]

with open("./data/menu.json") as file:
    menuData = json.load(file)







#######################
##### Helpers #########
#######################
def extractEntity(tracker: Tracker, entityName:str) -> dict[str,str]:
    entities = tracker.latest_message["entities"]
    for entity in entities:
        name = entity["entity"]
        if entityName == name:
            return entity
    return None
 



############################
########## ACTIONS #########
############################
class ActionOpeningHours(Action):
    def name(self) -> Text:
        return "action_opening_hours"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        try:
            dayOfTheWeek = extractEntity(tracker,"day_of_the_week")["value"].lower()
            if dayOfTheWeek is None:
                dispatcher.utter_message("I'm sorry I don't know what you mean. Can you be more specific")
                return []
            
            openTime = openingHoursData[dayOfTheWeek]["open"]
            closeTime = openingHoursData[dayOfTheWeek]["close"]
            message = f"Restaurant is open from {openTime} to {closeTime}"
            dispatcher.utter_message(text=message)
        except Exception as e:
            debugLogger.error(e)
            dispatcher.utter_message(text="ActionOpeningHours Error occured. Check logs")
        return []


class ActionListMenu(Action):
    def name(self) -> Text:
        return "action_list_menu"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        try:
            message = "Menu\n"
            for name in menuData:
                name = name
                price = menuData[name]["price"]
                message += f"{name} for {price:.2f} USD\n"
            dispatcher.utter_message(text=message)
        except Exception as e:
            debugLogger.error(e)
            dispatcher.utter_message(text="ActionListMenu Error occured. Check logs")
        return []
    
    
class ActionOrderMeal(Action):
    def name(self) -> Text:
        return "action_order_meal"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        try:
            dispatcher.utter_message(text="hello dzialam")
            meal_name = extractEntity(tracker, "meal_name")
            additional_info = extractEntity(tracker,"additional_info")
            message=f"Extracted data: {meal_name} {additional_info}"

            dispatcher.utter_message(text=message)
        except Exception as e:
            debugLogger.error(e)
            dispatcher.utter_message(text="ActionOrderMeal Error occured. Check logs")
        return []