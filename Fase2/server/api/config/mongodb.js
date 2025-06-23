// db.js
require('dotenv').config();
const { MongoClient } = require('mongodb');

const client = new MongoClient(process.env.MONGODB_URI);
let db;

const connectDB = async() => {
    try {
        await client.connect();
        console.log('Conectado a MongoDB');
        db = client.db(process.env.DB_NAME);
    } catch (error) {
        console.error('Error al conectar a MongoDB:', error);
        process.exit(1);
    }
}

const getDB = () => {
  if (!db) throw new Error('❌ La base de datos no está conectada');
  return db;
}

module.exports = { connectDB, getDB };
