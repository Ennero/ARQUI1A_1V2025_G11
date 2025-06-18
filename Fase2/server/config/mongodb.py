from pymongo import MongoClient
from pymongo.server_api import ServerApi
import os
from dotenv import load_dotenv

load_dotenv()

uri = os.getenv("MONGODB_URI")

client = MongoClient(
    uri,
    server_api=ServerApi('1'),
    connectTimeoutMS=30000,  # 30 seconds
    socketTimeoutMS=30000,   # 30 seconds
    maxPoolSize=50          # Maximum number of connections
)

try:
    # Try connection
    client.admin.command('ping')
    print("You successfully connected to MongoDB Atlas!")
    
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    # Close the connection when done
    client.close()