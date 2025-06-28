require('dotenv').config();
const { MongoClient } = require('mongodb');

const client = new MongoClient(process.env.MONGODB_URI);
let db;

const connectDB = async() => {
    try {
        await client.connect();
        console.log('Connected to MongoDB');
        db = client.db(process.env.DB_NAME);
    } catch (error) {
        console.error('Error while connecting to MongoDB', error);
        process.exit(1);
    }
}

const getDB = () => {
  if (!db) throw new Error('Something went wrong, DB not connected');
  return db;
}

module.exports = { connectDB, getDB };
