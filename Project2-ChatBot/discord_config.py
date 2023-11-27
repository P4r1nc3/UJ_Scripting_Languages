import discord
import requests
import json

SERVER_ADDRESS = 'http://localhost:5005/webhooks/rest/webhook'
DISCORD_TOKEN = 'MTE3ODQ0NjUwMDgxNzI4NTEyMA.G5C0a7.L7GfWZpL9s7rHQxIPWJ1ZcawtVm10-Wa-NVr3g'

intents = discord.Intents.default()
intents.message_content = True

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print('Discord bot is ready to use!')

@client.event
async def on_message(message):
    if message.author != client.user:
        request = send_request(message)
        message_for_user = " \n ".join(request)
        log_messages(message, message_for_user)
        await message.channel.send(message_for_user)

def log_messages(message, message_for_user):
    print(message.author, ':', message.content)
    print(client.user, ':', message_for_user)

def send_request(message):
    author = str(message.author)

    header = {'Content-Type': 'application/json'}
    data = '{"sender": "' + author + '","message": "' + message.content + '","metadata": {}}'

    response = requests.post(SERVER_ADDRESS, headers=header, data=data)
    messages = json.loads(response.content)
    return [message['text'] for message in messages]

client.run(DISCORD_TOKEN)