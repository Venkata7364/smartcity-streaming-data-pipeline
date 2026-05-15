SHOW TABLES;

SELECT COUNT(*) AS total_records
FROM processed;

SELECT *
FROM processed
LIMIT 10;

SELECT type, COUNT(*) AS total_events
FROM processed
GROUP BY type
ORDER BY total_events DESC;

SELECT *
FROM processed
ORDER BY event_time DESC
LIMIT 20;

SELECT AVG(speed) AS avg_vehicle_speed
FROM processed
WHERE type = 'vehicle';

SELECT vehicle_id, speed, event_time, speed_status
FROM processed
WHERE speed_status = 'overspeeding'
ORDER BY event_time DESC
LIMIT 20;

SELECT level, COUNT(*) AS total
FROM processed
WHERE type = 'traffic'
GROUP BY level
ORDER BY total DESC;

SELECT event, severity, priority, event_time
FROM processed
WHERE priority = 'critical'
ORDER BY event_time DESC
LIMIT 20;

SELECT city,
       AVG(temperature) AS avg_temperature,
       AVG(humidity) AS avg_humidity
FROM processed
WHERE type = 'weather'
GROUP BY city;
