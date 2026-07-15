import urllib
import http.client
import os
from dotenv import load_dotenv


# **********************************************************************************
# pushover stuff (for notifications to phone when script has finished)
# read .env
load_dotenv()

def pushover_message(message):

    # sets user token from .env
    user_token = os.environ["PUSHOVER_USER_TOKEN"]
    api_token = os.environ["PUSHOVER_API_TOKEN"]

    conn = http.client.HTTPSConnection("api.pushover.net:443")

    conn.request("POST", "/1/messages.json",
                urllib.parse.urlencode({
                    "token": api_token,
                    "user": user_token,

                    # message to phone
                    "message": message,
                    }), { "Content-type": "application/x-www-form-urlencoded" })

    conn.getresponse()
# **********************************************************************************

pushover_message("why are you reading this script?")