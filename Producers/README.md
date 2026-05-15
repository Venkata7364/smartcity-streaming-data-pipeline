# Producers

This folder contains five Python producer scripts that simulate smart city IoT source systems.

## Why Producers Are Used

In a real smart city, events come from physical devices and systems. Examples include vehicle sensors, GPS devices, traffic systems, weather sensors, and emergency alert systems.

For this project, Python producers simulate those real-world systems. Each producer continuously generates JSON events and sends them to Kafka.

## Producer Files

```text
vehicle_producer.py   -> sends vehicle speed events
gps_producer.py       -> sends latitude and longitude events
traffic_producer.py   -> sends traffic level events
weather_producer.py   -> sends temperature and humidity events
emergency_producer.py -> sends accident, fire, and medical events
```

## Kafka Topic

All producers send data to the same Kafka topic:

```text
iot-topic
```

Using one topic works because every event contains a `type` field. Spark later uses this field to identify whether the record is a vehicle, GPS, traffic, weather, or emergency event.

## How Producers Connect To Kafka

The producers run on the local machine, so they connect to Kafka using:

```python
bootstrap_servers="localhost:9092"
```

Kafka runs in Docker, but port `9092` is exposed to the local machine.

## How To Run

Start Docker first:

```powershell
docker compose up -d
```

Then run each producer in a separate terminal:

```powershell
python Producers\vehicle_producer.py
python Producers\gps_producer.py
python Producers\traffic_producer.py
python Producers\weather_producer.py
python Producers\emergency_producer.py
```

## What The Producer Does

Each producer follows this process:

```text
generate fake IoT event
convert event to JSON
send JSON message to Kafka topic iot-topic
wait a few seconds
repeat continuously
```

## Example Events

Vehicle:

```json
{
  "type": "vehicle",
  "vehicle_id": 52,
  "speed": 87,
  "timestamp": 1778783353.43
}
```

Traffic:

```json
{
  "type": "traffic",
  "level": "high",
  "timestamp": 1778783364.68
}
```

Emergency:

```json
{
  "type": "emergency",
  "event": "medical",
  "severity": "high",
  "timestamp": 1778783364.93
}
```

## Why This Matters

This layer proves that the pipeline can handle multiple real-time source systems sending different types of semi-structured data.
