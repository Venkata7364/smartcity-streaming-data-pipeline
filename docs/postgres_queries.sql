SELECT COUNT(*) FROM iot_events;

SELECT COUNT(*) FROM vehicle_events;

SELECT COUNT(*) FROM gps_events;

SELECT COUNT(*) FROM traffic_events;

SELECT COUNT(*) FROM weather_events;

SELECT COUNT(*) FROM emergency_events;

SELECT type, COUNT(*) AS total_events
FROM iot_events
GROUP BY type
ORDER BY total_events DESC;

SELECT *
FROM iot_events
ORDER BY event_time DESC
LIMIT 10;

SELECT *
FROM vehicle_events
WHERE speed_status = 'overspeeding'
ORDER BY event_time DESC
LIMIT 10;

SELECT *
FROM emergency_events
WHERE priority = 'critical'
ORDER BY event_time DESC
LIMIT 10;
