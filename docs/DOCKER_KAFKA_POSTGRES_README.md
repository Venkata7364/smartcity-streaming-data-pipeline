# Docker, Kafka, Spark, And PostgreSQL Setup

This document explains the local infrastructure used by the project.

## Why Docker Is Used

Docker is used to run infrastructure services without installing each tool manually on the laptop.

The Docker Compose file starts:

```text
Zookeeper
Kafka broker
PostgreSQL
Spark
```

## Services

### Zookeeper

Kafka uses Zookeeper in this setup for broker coordination.

Container:

```text
smartcity-zookeeper
```

Port:

```text
2181
```

### Kafka Broker

Kafka receives messages from producers and allows Spark to consume them.

Container:

```text
smartcity-broker
```

Ports:

```text
9092  -> local machine producers
29092 -> Spark container
```

Why two listeners are used:

```text
localhost:9092 is used by Python producers running on the laptop.
broker:29092 is used by Spark running inside Docker.
```

### PostgreSQL

PostgreSQL stores processed streaming data.

Container:

```text
smartcity-postgres
```

Database:

```text
smartcity
```

User:

```text
admin
```

Password:

```text
admin
```

Port:

```text
5432
```

### Spark

Spark runs the Structured Streaming job.

Container:

```text
smartcity-spark
```

The local `spark/` folder is mounted into the container at:

```text
/app/spark
```

## Start Services

```powershell
docker compose up -d
```

## Check Services

```powershell
docker ps
```

Expected containers:

```text
smartcity-zookeeper
smartcity-broker
smartcity-postgres
smartcity-spark
```

## Create Kafka Topic

```powershell
docker exec smartcity-broker kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic iot-topic --partitions 1 --replication-factor 1
```

## Check PostgreSQL

```powershell
docker exec -it smartcity-postgres psql -U admin -d smartcity
```

Example SQL:

```sql
SELECT COUNT(*) FROM iot_events;
```

## Stop Services

```powershell
docker compose down
```

Use this when the project is not running.
