# Streamlit Dashboard

This project uses Streamlit as the dashboard layer.

## Why Streamlit Is Used

Streamlit is simple and fast for building Python dashboards. It reads from PostgreSQL and displays metrics, charts, and tables.

In this project, Streamlit acts as the BI/dashboard layer for the local operational database.

## Dashboard Source

The dashboard reads from PostgreSQL table:

```text
iot_events
```

Connection:

```text
host: localhost
database: smartcity
user: admin
password: admin
```

The dashboard uses `localhost` because Streamlit runs on the local machine and PostgreSQL port `5432` is exposed from Docker.

## Metrics Shown

The dashboard displays:

```text
total events
average vehicle speed
overspeeding vehicle count
critical emergency count
latest temperature
latest humidity
events by type
traffic level counts
latest events table
overspeeding vehicle records
critical emergency records
```

## Run Dashboard

Start Docker, Spark, and producers first.

Then run:

```powershell
streamlit run dashboard.py
```

Open:

```text
http://localhost:8501
```

## Why PostgreSQL Is Used For Dashboard

PostgreSQL is used for the dashboard because it is easy to query recent processed events and works well with Streamlit.

S3 and Athena are used for cloud analytics and historical data lake querying.
