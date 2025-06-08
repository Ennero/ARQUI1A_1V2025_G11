const mqtt = require('mqtt');

const host = "broker.emqx.io";
const port = "1883";
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;
const connectUrl = `mqtt://${host}:${port}`;

const topic = "fiusac/arqui1/g11";

const client = mqtt.connect(connectUrl, {
    clientId,
    clean: true,
    connectTimeout: 4000,
    username: "emqx",
    password: "public",
    reconnectPeriod: 1000,
});

client.on('connect', () => {
    console.log("Connected");
    client.subscribe([topic], () => {
        console.log(`Subscribed to topic '${topic}'`);
        client.publish(
            topic,
            "Probando mqtt desde Node.js",
            { qos: 0, retain: false },
            (error) => {
                if (error) {
                    console.error(error);
                }
            }
        );
    });
});

client.on('message', (topic, payload) => {
    console.log(`Received message on topic '${topic}': ${payload.toString()}`);
});