# AWS S3, Glue, And Athena Setup

This document explains the cloud analytics layer.

## Cloud Architecture

```text
Spark Structured Streaming
-> AWS S3 Data Lake
-> AWS Glue Data Catalog
-> Athena SQL Queries
```

## Why S3 Is Used

S3 stores historical processed data as a data lake.

PostgreSQL is useful for local dashboard and operational queries, but S3 is better for long-term storage and large-scale analytics.

Spark writes Parquet files to:

```text
s3://smartcity-data-lake-laksh/processed/
```

## Why Parquet Is Used

Parquet is:

- columnar
- compressed
- efficient for analytics
- compatible with Glue and Athena

## IAM Permissions For Spark S3 Write

Spark needs permission to write objects to S3.

For a demo project, an IAM user can be created with:

```text
AmazonS3FullAccess
```

A safer least-privilege policy should allow access only to:

```text
arn:aws:s3:::smartcity-data-lake-laksh
arn:aws:s3:::smartcity-data-lake-laksh/*
```

Needed S3 actions include:

```text
s3:ListBucket
s3:GetObject
s3:PutObject
s3:DeleteObject
s3:AbortMultipartUpload
s3:ListBucketMultipartUploads
s3:ListMultipartUploadParts
```

AWS access keys must not be committed to GitHub. They should be passed through the Spark submit command or environment variables.

## Spark S3 Submit Settings

Spark uses:

```text
spark.hadoop.fs.s3a.access.key
spark.hadoop.fs.s3a.secret.key
spark.hadoop.fs.s3a.endpoint=s3.amazonaws.com
```

Required packages:

```text
org.apache.hadoop:hadoop-aws:3.3.4
com.amazonaws:aws-java-sdk-bundle:1.12.262
```

## Why Glue Is Used

S3 stores files, but SQL engines need metadata to understand those files.

Glue Data Catalog stores:

- table names
- column names
- data types
- S3 locations
- file format information

## Glue Setup Steps

1. Open AWS Glue in `us-east-1`.
2. Create database:

```text
smartcity_db
```

3. Create an IAM role for Glue.
4. Attach permissions:

```text
AWSGlueServiceRole
AmazonS3ReadOnlyAccess
```

For production, use a bucket-specific read policy instead of full S3 read access.

5. Create crawler:

```text
smartcity-s3-crawler
```

6. Set S3 source:

```text
s3://smartcity-data-lake-laksh/processed/
```

7. Choose target database:

```text
smartcity_db
```

8. Run crawler.
9. Confirm table appears in Glue, such as:

```text
processed
```

Classification should show:

```text
Parquet
```

## Why Athena Is Used

Athena lets us run SQL directly on S3 data without loading it into a database.

Athena uses Glue Data Catalog metadata to understand the S3 files.

## Athena Setup Steps

1. Open Athena in `us-east-1`.
2. Choose:

```text
Data source: AwsDataCatalog
Database: smartcity_db
```

3. Set query result location:

```text
s3://smartcity-data-lake-laksh/athena-results/
```

4. Run:

```sql
SHOW TABLES;
```

5. Query the table:

```sql
SELECT COUNT(*) FROM processed;
```

## Example Athena Queries

Events by type:

```sql
SELECT type, COUNT(*) AS total_events
FROM processed
GROUP BY type
ORDER BY total_events DESC;
```

Overspeeding vehicles:

```sql
SELECT vehicle_id, speed, event_time, speed_status
FROM processed
WHERE speed_status = 'overspeeding'
ORDER BY event_time DESC
LIMIT 20;
```

Critical emergencies:

```sql
SELECT event, severity, priority, event_time
FROM processed
WHERE priority = 'critical'
ORDER BY event_time DESC
LIMIT 20;
```

## BI Dashboard Note

QuickSight can connect to Athena for a managed BI dashboard, but it may require activating QuickSight and can involve billing after a trial.

For this project, Streamlit is used as the dashboard and Athena is used for SQL analytics over the S3 data lake.
