# database.py
from pymongo import MongoClient
from pymongo.server_api import ServerApi
import os
from dotenv import load_dotenv

load_dotenv()

class MongoDBConnection:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(MongoDBConnection, cls).__new__(cls)
            cls._instance._initialize_connection()
        return cls._instance
    
    def _initialize_connection(self):
        
        uri = os.getenv("MONGODB_URI")
        self.client = MongoClient(
            uri,
            server_api=ServerApi('1'),
            connectTimeoutMS=30000,
            socketTimeoutMS=30000,
            maxPoolSize=50
        )
        try:
            # Test the connection
            self.client.admin.command('ping')
            print("Successfully connected to MongoDB Atlas!")
        except Exception as e:
            print(f"Failed to connect to MongoDB: {e}")
            raise
    
    def get_database(self, db_name: str):
        return self.client[db_name]
    
    def close_connection(self):
        if self.client:
            self.client.close()
            self._instance = None

mongodb_connection = MongoDBConnection()