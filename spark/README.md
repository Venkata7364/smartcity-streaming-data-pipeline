# Spark Structured Streaming

This folder contains the main Spark streaming job:

```text
spark_stream.py
```

## Why Spark Is Used

Kafka stores and streams the incoming events, but Kafka does not transform the data. Spark Structured Streaming is used to process the real-time data.

Spark performs:

- reading from Kafka
- parsing JSON
- converting semi-structured data into structured columns
- applying transformations
- applying data quality checks
- writing data to PostgreSQL
- writing data to AWS S3

## Kafka Connection

Spark runs inside Docker, so it connects to Kafka using Docker networking:

```text
broker:29092
```

This is different from the producers, which use:

```text
localhost:9092
```

## JSON Parsing

Kafka messages arrive as raw strings. Spark uses a schema to parse them into columns:

```text
type
vehicle_id
speed
latitude
longitude
level
temperature
humidity
city
event
severity
timestamp
```

After parsing, Spark creates:

```text
event_time
speed_status
priority
```

## Transformations

Spark applies business logic:

```text
vehicle speed > 100       -> speed_status = overspeeding
vehicle speed <= 100      -> speed_status = normal
emergency severity = high -> priority = critical
emergency other severity  -> priority = standard
traffic level = high      -> priority = attention
```

## Data Quality Checks

Spark filters out invalid records before writing:

```text
timestamp is not null
type is valid
vehicle speed is not negative
GPS latitude is between -90 and 90
GPS longitude is between -180 and 180
emergency severity is low, medium, or high
```

## PostgreSQL Output

Spark writes processed data using JDBC to:

```text
iot_events
vehicle_events
gps_events
traffic_events
weather_events
emergency_events
```

PostgreSQL connection from Spark:

```text
jdbc:postgresql://postgres:5432/smartcity
```

`postgres` is the Docker service name.

## S3 Output

Spark writes Parquet files to:

```text
s3a://smartcity-data-lake-laksh/processed/
```

The `s3a://` protocol is used by Spark/Hadoop to write to AWS S3.

## Why foreachBatch Is Used

PostgreSQL and S3 are written from streaming data using `foreachBatch`.

This lets Spark process one micro-batch at a time:

```text
batch 1 -> PostgreSQL and S3
batch 2 -> PostgreSQL and S3
batch 3 -> PostgreSQL and S3
```

## Required Spark Packages

The Spark submit command includes:

```text
spark-sql-kafka-0-10_2.12:3.5.0
postgresql:42.7.3
hadoop-aws:3.3.4
aws-java-sdk-bundle:1.12.262
```

Why:

- Kafka package lets Spark read Kafka topics.
- PostgreSQL package lets Spark write using JDBC.
- Hadoop AWS and AWS SDK packages let Spark write to S3.

## Run Command

Do not put AWS keys in code. Pass them at runtime:

```powershell
docker exec smartcity-spark /opt/spark/bin/spark-submit --conf spark.jars.ivy=/tmp/.ivy2 --conf spark.hadoop.fs.s3a.access.key=YOUR_ACCESS_KEY_ID --conf spark.hadoop.fs.s3a.secret.key=YOUR_SECRET_ACCESS_KEY --conf spark.hadoop.fs.s3a.endpoint=s3.amazonaws.com --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0,org.postgresql:postgresql:42.7.3,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 /app/spark/spark_stream.py
```

## Expected Success Message

```text
Step 1: Starting script
Step 2: Spark session created
Step 3: Connected to Kafka
Step 4: Streaming started and writing to PostgreSQL and S3
```
