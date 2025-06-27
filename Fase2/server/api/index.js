require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB, getDB } = require('./config/mongodb');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get('/siepa/collections/:collection', async (req, res) => {
    try {
        const db = getDB();
        const { collection } = req.params;
        const { attr = "temperature", measurement, limit = 30 } = req.query;

        const limitInt = parseInt(limit);

        if (!collection) {
            return res.status(400).json({ error: "Collection parameter is required." });
        }

        let query = {};
        let projection = {};
        let sort = { timestamp: -1 };

        if (collection === "sensor_readings") {
            if (attr !== "all") {
                projection = { _id: 0, [attr]: 1, timestamp: 1 };
            }
        } else if (collection === "alerts") {
            if (attr !== "all") {
                projection = { _id: 0, value: 1, timestamp: 1 };
            }
        } else if (collection === "statistics") {
            if (!measurement) {
                return res.status(400).json({ error: "Measurement parameter is required for statistics collection." });
            }
            query.measurement = measurement;
        } else {
            return res.status(404).json({ error: "Unsupported collection." });
        }

        console.log(`Fetching records from ${collection} collection with attr: ${attr}, measurement: ${measurement}, limit: ${limitInt}`);

        const recordsRaw = await db.collection(collection)
            .find(query, attr !== "all" ? { projection } : {})
            .sort(sort)
            .limit(limitInt)
            .toArray();

        let id = 0;

        console.log(`Retrieved ${recordsRaw.length} records from ${collection} collection.`);

        const records = recordsRaw.map(record => {
            id++;
            const dateObj = new Date(record.timestamp);

            const date = dateObj.toISOString().split("T")[0];
            const time = dateObj.toTimeString().split(" ")[0];

            let value = null;

            if (collection === "sensor_readings" && attr !== "all") {
                const raw = record[attr];
                value = (typeof raw === 'number') ? Math.trunc(raw) : raw;
            } else if (collection === "alerts") {
                const raw = record.value;
                value = (typeof raw === 'number') ? Math.trunc(raw) : raw;
            }

            if(attr === "all" && collection === "sensor_readings") {
                record = {
                    ...record,
                    temperature: (typeof record.temperature === 'number') ? Math.trunc(record.temperature) : record.temperature,
                    humidity: (typeof record.humidity === 'number') ? Math.trunc(record.humidity) : record.humidity,
                    pressure: (typeof record.pressure === 'number') ? Math.trunc(record.pressure) : record.pressure,
                    air_quality: (typeof record.air_quality === 'number') ? Math.trunc(record.air_quality) : record.air_quality,
                    luminosity: (typeof record.luminosity === 'number') ? Math.trunc(record.luminosity) : record.luminosity,
                    proximity: (typeof record.proximity === 'number') ? Math.trunc(record.proximity) : record.proximity,
                }
                // value = (typeof raw === 'number') ? Math.trunc(raw) : raw;
            } else if (attr === "all" && collection === "alerts") {
                record = {
                    ...record,
                    type: record.measurement,
                    value: (typeof record.value === 'number') ? Math.trunc(record.value) : record.value,
                }
            } else if (collection === "statistics") {
                record = {
                    ...record,
                    type_data: record.measurement,
                }
            }
            return {
                id,
                ...record,
                _value: value,
                date,
                time
            };
        });

        console.log(`Processed ${records.length} records for response.`);
        console.log(`Response data:`, records);

        res.json({ data: records });

    } catch (err) {
        console.error('Error retrieving the records:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});


// Iniciar servidor
connectDB().then(() => {
    app.listen(PORT, () => {
        console.log(`Server running at http://localhost:${PORT}`);
    });
});
