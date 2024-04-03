import discord
import requests
import json 

intents = discord.Intents.default()
intents.message_content = True

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')

@client.event
async def on_message(message:discord.Message):
    if message.author == client.user:
        return
    rasaUrl = "http://localhost:5005/webhooks/rest/webhook"
    messegeContent = message.content
    
    messageToSend = {
        "sender": "test",
        "message": messegeContent
    }
    header = {
        "content-type": "application/json"
    }
    req = requests.post(url=rasaUrl, data=json.dumps(messageToSend), headers=header, timeout=10)
    response = req.json()[0]["text"]

    await message.channel.send(f'{response}')


key = ""
client.run(key)