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
from datetime import datetime, timedelta
from typing import Union
###############################
########## INIT ###############
###############################

debugLoggerName = "actionDebugLogger"
debugLogger = logging.getLogger(debugLoggerName)
fileHandler = logging.FileHandler("debugLog.txt")
debugLogger.addHandler(fileHandler)

with open("./data/opening_hours.json") as file:
    openingHoursData:dict = json.load(file)["items"]

with open("./data/menu.json") as file:
    menuData:dict = json.load(file)








#######################
##### Helpers #########
#######################
def extractEntity(tracker: Tracker, entityName:str) -> Union[dict[str,str],None]:
    entities = tracker.latest_message["entities"]
    for entity in entities:
        name = entity["entity"]
        debugLogger.info(f"{name} {entityName}")
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
            dayOfTheWeekEntity = extractEntity(tracker,"day_of_the_week")
            if dayOfTheWeekEntity is None:
                dispatcher.utter_message("I'm sorry I don't know what you mean. Can you be more specific")
                return []
            dayOfTheWeek = dayOfTheWeekEntity["value"].lower()
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
        global listOfOrders
        debugLogger.info("Ordering meal")
        try:
            mealEntity = extractEntity(tracker, "meal_name")
            additionalInfoEntity = extractEntity(tracker,"additional_info")

            if mealEntity is None:
                dispatcher.utter_message(text="Sorry I don't know what you mean")
                return []
            
            mealName = mealEntity["value"]
            if not mealName.lower() in menuData.keys():
                dispatcher.utter_message(text=f"Sorry there is no {mealName} in the menu")
                return []
            additionalInfoValue = None
            if additionalInfoEntity is not None:
                additionalInfoValue = additionalInfoEntity["value"]
            newOrder = Order(mealName, "temp", additionalInfoValue)
            listOfOrders.addOrder(newOrder)
            dispatcher.utter_message(text=f"Order added\n{newOrder}")

        except Exception as e:
            debugLogger.error(e)
            dispatcher.utter_message(text="ActionOrderMeal Error occured. Check logs")
        return []
    
class ActionGetOrder(Action):
    def name(self) -> Text:
        return "action_get_order"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        global listOfOrders
        try:
            orders = listOfOrders.getOrders("temp")
            dispatcher.utter_message(text=f"{orders}")

        except Exception as e:
            debugLogger.error(e)
            dispatcher.utter_message(text="ActionOrderMeal Error occured. Check logs")
        return []
    

class Order:
    def __init__(self, dishName:str, customerName:str, additionalInfo: Union[str,None]) -> None:
        self.dishName = dishName
        self.price = menuData[dishName]["price"]
        self.customerName = customerName
        self.additionalInfo = additionalInfo
        self.orderTime = datetime.now() 
        prepTime = timedelta(hours=menuData[dishName]["preparation_time"])
        self.readyTime = self.orderTime + prepTime
        debugLogger.info(prepTime)

    def __str__(self) -> str:
        returnStr = f"{self.dishName}\n"
        returnStr += f"Additional information: {self.additionalInfo}\n"
        returnStr += f"Price: {self.price:.2f} USD\n"
        returnStr += f"Ready at {self.readyTime}" 
        return returnStr
    
class Orders:
    def __init__(self) -> None:
        self.orders:dict[str,list[Order]] = {}

    def addOrder(self, order:Order) -> None:
        if order.customerName in self.orders.keys():
            self.orders[order.customerName].append(order)
        else:
            self.orders[order.customerName] = [order]

    def getOrders(self, customerName:str) -> str:
        if not customerName in self.orders.keys():
            return "You have not ordered anything yet"
        else:
            message = "Your orders: \n"
            for order in self.orders[customerName]:
                message += str(order) + "\n"
            return message
        
listOfOrders = Orders()