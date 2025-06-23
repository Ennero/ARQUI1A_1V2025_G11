// index.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB, getDB } = require('./config/mongodb');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json()); // Para JSON en peticiones POST

// Rutas
app.get('/siepa/measurements/:measurement', async (req, res) => {
    try {
        const db = getDB();
        const { measurement } = req.params;
        const { c = "sensor_readings", limit = 30 } = req.query;


        const recordsRaw = await db.collection(c).find(
            {},
            { projection: { _id: 0, [measurement]: 1, timestamp: 1 } }
        )
        .sort({ timestamp: -1 }) // -1 = newest first
        .limit(parseInt(limit))
        .toArray();

        // Apply better format to timestamp
        const records = recordsRaw.map((record) => {
            const date = new Date(record.timestamp);

            const yyyy = date.getFullYear();
            const mm = String(date.getMonth() + 1).padStart(2, '0');
            const dd = String(date.getDate()).padStart(2, '0');
            const hh = String(date.getHours()).padStart(2, '0');
            const mi = String(date.getMinutes()).padStart(2, '0');
            const ss = String(date.getSeconds()).padStart(2, '0');

            return {
                ...record,
                timestamp: `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`
            };
        });

        res.json({ data: records });
    } catch (err) {
        console.error('❌ Error al obtener items:', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// Iniciar servidor
connectDB().then(() => {
    app.listen(PORT, () => {
        console.log(`Servidor corriendo en http://localhost:${PORT}`);
    });
});
