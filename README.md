# Smart City Real-Time Streaming Data Pipeline

This project is an end-to-end real-time data engineering pipeline for a smart city use case. It simulates IoT source systems, streams events through Kafka, processes them with Spark Structured Streaming, stores processed data in PostgreSQL and AWS S3, catalogs the S3 data with AWS Glue, and queries it with Athena.

## Project Idea

In a real smart city, data is generated continuously from many systems:

- vehicles sending speed information
- GPS devices sending latitude and longitude
- traffic systems sending congestion levels
- weather sensors sending temperature and humidity
- emergency systems sending fire, accident, or medical alerts

Because this project does not use physical IoT devices, Python scripts simulate those source systems. These scripts continuously generate JSON events and publish them to Kafka.

## Full Architecture

```text
IoT Source Simulation
-> Python Producers
-> Kafka topic: iot-topic
-> Spark Structured Streaming
-> JSON parsing and transformations
-> Data quality checks
-> PostgreSQL using JDBC
-> Streamlit dashboard
-> AWS S3 data lake
-> AWS Glue Data Catalog
-> Athena SQL analytics
```

## What Was Built

The project includes:

- five Python IoT producers
- Docker Compose infrastructure for Kafka, Zookeeper, Spark, and PostgreSQL
- Spark Structured Streaming pipeline
- JSON parsing from semi-structured events into structured columns
- transformation logic for vehicle, traffic, and emergency events
- data quality checks before storage
- PostgreSQL storage through JDBC
- Streamlit dashboard from PostgreSQL
- S3 Parquet data lake output
- Glue crawler and Data Catalog setup
- Athena SQL queries over S3

## Repository Structure

```text
.
├── Producers/
│   ├── emergency_producer.py
│   ├── gps_producer.py
│   ├── traffic_producer.py
│   ├── vehicle_producer.py
│   ├── weather_producer.py
│   └── README.md
├── spark/
│   ├── spark_stream.py
│   └── README.md
├── docs/
│   ├── ATHENA_GLUE_README.md
│   ├── DASHBOARD_README.md
│   ├── DOCKER_KAFKA_POSTGRES_README.md
│   ├── athena_queries.sql
│   └── postgres_queries.sql
├── screenshots/
├── dashboard.py
├── docker-compose.yml
├── requirements.txt
└── README.md
```

## Data Flow

1. Python producers simulate real-time IoT events.
2. Producers publish JSON messages to Kafka topic `iot-topic`.
3. Spark reads the Kafka stream.
4. Spark parses JSON into structured columns.
5. Spark adds transformation columns such as `speed_status`, `priority`, and `event_time`.
6. Spark applies data quality rules.
7. Spark writes clean data into PostgreSQL tables.
8. Spark writes clean data into S3 as Parquet files.
9. Glue crawls S3 and creates metadata tables.
10. Athena runs SQL queries on the S3 data.
11. Streamlit reads PostgreSQL and displays dashboard metrics.

## Event Types

The pipeline supports these event types:

```text
vehicle
gps
traffic
weather
emergency
```

Example vehicle event:

```json
{
  "type": "vehicle",
  "vehicle_id": 47,
  "speed": 60,
  "timestamp": 1778801132.84
}
```

Example emergency event:

```json
{
  "type": "emergency",
  "event": "medical",
  "severity": "high",
  "timestamp": 1778801133.54
}
```

## Spark Transformations

Spark creates useful business columns from raw events:

```text
vehicle speed > 100       -> speed_status = overspeeding
vehicle speed <= 100      -> speed_status = normal
emergency severity = high -> priority = critical
emergency other severity  -> priority = standard
traffic level = high      -> priority = attention
timestamp                 -> event_time
```

## Data Quality Checks

Before storage, Spark filters records using these rules:

- `timestamp` must not be null
- `type` must be one of the valid event types
- vehicle speed must not be null or negative
- GPS latitude must be between `-90` and `90`
- GPS longitude must be between `-180` and `180`
- emergency severity must be `low`, `medium`, or `high`

## PostgreSQL Storage

Spark writes processed records to PostgreSQL using JDBC.

Tables:

```text
iot_events
vehicle_events
gps_events
traffic_events
weather_events
emergency_events
```

`iot_events` stores all events together. The other tables are curated event-specific tables.

## S3 Data Lake

Spark also writes Parquet files to S3:

```text
s3://smartcity-data-lake-laksh/processed/iot_events/
s3://smartcity-data-lake-laksh/processed/vehicle_events/
s3://smartcity-data-lake-laksh/processed/gps_events/
s3://smartcity-data-lake-laksh/processed/traffic_events/
s3://smartcity-data-lake-laksh/processed/weather_events/
s3://smartcity-data-lake-laksh/processed/emergency_events/
```

Parquet is used because it is columnar, compressed, and efficient for Athena queries.

## Permissions Used

For local Docker services, no cloud permissions are required.

For Spark to write to S3, an IAM user/access key was created with S3 permissions. For a learning/demo project, `AmazonS3FullAccess` can work. A safer production approach is a least-privilege policy limited to only the project bucket.

For Glue, an IAM role was created with permissions to:

- run AWS Glue crawler operations
- read objects from the S3 bucket
- create/update Data Catalog metadata

For Athena, a query result location was configured in S3:

```text
s3://smartcity-data-lake-laksh/athena-results/
```

Do not commit AWS access keys, secret keys, `.env` files, or local AWS credential folders.

## Run The Project

Install Python dependencies:

```powershell
pip install -r requirements.txt
```

Start Docker services:

```powershell
docker compose up -d
```

Create Kafka topic if needed:

```powershell
docker exec smartcity-broker kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic iot-topic --partitions 1 --replication-factor 1
```

Run Spark:

```powershell
docker exec smartcity-spark /opt/spark/bin/spark-submit --conf spark.jars.ivy=/tmp/.ivy2 --conf spark.hadoop.fs.s3a.access.key=YOUR_ACCESS_KEY_ID --conf spark.hadoop.fs.s3a.secret.key=YOUR_SECRET_ACCESS_KEY --conf spark.hadoop.fs.s3a.endpoint=s3.amazonaws.com --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0,org.postgresql:postgresql:42.7.3,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 /app/spark/spark_stream.py
```

Run producers in separate terminals:

```powershell
python Producers\vehicle_producer.py
python Producers\gps_producer.py
python Producers\traffic_producer.py
python Producers\weather_producer.py
python Producers\emergency_producer.py
```

Run dashboard:

```powershell
streamlit run dashboard.py
```

## Verification

Check PostgreSQL:

```powershell
docker exec -it smartcity-postgres psql -U admin -d smartcity
```

Example SQL:

```sql
SELECT COUNT(*) FROM iot_events;
SELECT type, COUNT(*) FROM iot_events GROUP BY type;
SELECT * FROM vehicle_events WHERE speed_status = 'overspeeding' LIMIT 10;
SELECT * FROM emergency_events WHERE priority = 'critical' LIMIT 10;
```

Check S3:

```text
AWS Console -> S3 -> smartcity-data-lake-laksh -> processed/
```

Check Glue:

```text
AWS Glue -> Data Catalog -> Databases -> smartcity_db -> Tables
```

Check Athena:

```sql
SELECT COUNT(*) FROM processed;
SELECT type, COUNT(*) FROM processed GROUP BY type;
```

## Demo Explanation

This project simulates a smart city streaming architecture. Python producers act as IoT source systems and continuously generate JSON events. Kafka receives those events in a topic and works as the real-time message broker. Spark Structured Streaming consumes the Kafka topic, parses JSON into structured columns, applies transformations and data quality checks, and writes clean data into PostgreSQL and S3. PostgreSQL supports local dashboarding and operational SQL queries. S3 stores historical Parquet data as a data lake. Glue catalogs the S3 data, and Athena queries it using SQL.

## Current Status

Completed:

```text
Python IoT producers
Kafka streaming
Spark Structured Streaming
JSON parsing and transformations
Data quality checks
PostgreSQL JDBC writes
Streamlit dashboard
S3 Parquet data lake writes
Glue crawler and Data Catalog
Athena SQL queries
```

Future improvements:

- Add QuickSight or Power BI dashboard from Athena
- Add Airflow orchestration
- Add S3 partitioning by event date and event type
- Add dead-letter storage for rejected/bad records
- Add schema registry support
