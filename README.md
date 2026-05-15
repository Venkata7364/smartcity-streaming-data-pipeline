# Smart City Streaming Data Pipeline

An end-to-end real-time data engineering project that simulates smart city IoT data, streams it through Kafka, processes it with Spark Structured Streaming, stores it in PostgreSQL and AWS S3, catalogs it with AWS Glue, and queries it with Athena.

## Architecture

```text
IoT Source Simulation
→ Python Producers
→ Kafka topic: iot-topic
→ Spark Structured Streaming
→ JSON parsing, transformations, and data quality checks
→ PostgreSQL using JDBC
→ Streamlit dashboard
→ AWS S3 data lake
→ AWS Glue Data Catalog
→ Athena SQL analytics
```

## What This Project Demonstrates

- Real-time IoT event simulation using Python producers
- Kafka-based streaming ingestion
- Spark Structured Streaming from Kafka
- Semi-structured JSON parsing into structured columns
- Real-time transformation rules
- Basic data quality validation
- PostgreSQL storage using JDBC
- Streamlit dashboard from PostgreSQL
- S3 data lake storage using Parquet
- Glue crawler and Data Catalog setup
- Athena SQL queries on S3 data

## Event Sources

The `Producers/` folder contains five simulated source systems:

```text
vehicle_producer.py
gps_producer.py
traffic_producer.py
weather_producer.py
emergency_producer.py
```

Each producer sends JSON events to Kafka topic `iot-topic`.

## Spark Processing

Spark reads from Kafka and performs:

- JSON parsing with a defined schema
- Timestamp conversion into `event_time`
- Vehicle speed status:
  - `speed > 100` → `overspeeding`
  - otherwise → `normal`
- Emergency priority:
  - `severity = high` → `critical`
  - otherwise → `standard`
- Traffic priority:
  - `level = high` → `attention`
- Data quality checks:
  - valid event type
  - non-null timestamp
  - non-negative vehicle speed
  - valid GPS latitude and longitude
  - valid emergency severity

## PostgreSQL Tables

Spark writes processed records to PostgreSQL tables:

```text
iot_events
vehicle_events
gps_events
traffic_events
weather_events
emergency_events
```

## S3 Data Lake Layout

Spark writes Parquet files to S3:

```text
s3://smartcity-data-lake-laksh/processed/iot_events/
s3://smartcity-data-lake-laksh/processed/vehicle_events/
s3://smartcity-data-lake-laksh/processed/gps_events/
s3://smartcity-data-lake-laksh/processed/traffic_events/
s3://smartcity-data-lake-laksh/processed/weather_events/
s3://smartcity-data-lake-laksh/processed/emergency_events/
```

Do not commit AWS access keys. Pass credentials only through the Spark submit command or a secure environment configuration.

## Run Locally

Start Docker services:

```powershell
docker compose up -d
```

Create the Kafka topic if needed:

```powershell
docker exec smartcity-broker kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic iot-topic --partitions 1 --replication-factor 1
```

Run Spark with Kafka, PostgreSQL, and S3 packages:

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

Run the Streamlit dashboard:

```powershell
streamlit run dashboard.py
```

## Verify PostgreSQL

Open PostgreSQL:

```powershell
docker exec -it smartcity-postgres psql -U admin -d smartcity
```

Example queries:

```sql
SELECT COUNT(*) FROM iot_events;
SELECT type, COUNT(*) FROM iot_events GROUP BY type;
SELECT * FROM vehicle_events WHERE speed_status = 'overspeeding' LIMIT 10;
SELECT * FROM emergency_events WHERE priority = 'critical' LIMIT 10;
```

## AWS Glue And Athena

Glue setup:

1. Create Glue database `smartcity_db`.
2. Create a Glue crawler.
3. Point it to `s3://smartcity-data-lake-laksh/processed/`.
4. Run the crawler.
5. Confirm Glue creates a Parquet table such as `processed`.

Athena setup:

1. Use data source `AwsDataCatalog`.
2. Select database `smartcity_db`.
3. Set query result location, for example:

```text
s3://smartcity-data-lake-laksh/athena-results/
```

4. Query the Glue table from Athena.

Sample Athena queries are in `docs/athena_queries.sql`.

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
- Add schema evolution handling
- Add alerting for critical events
- Add partitioned S3 writes by event date and type
