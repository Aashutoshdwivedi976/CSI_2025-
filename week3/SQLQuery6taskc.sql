-- Create temporary table for demonstration
CREATE TABLE #STATION (
    ID INT,
    CITY VARCHAR(21),
    STATE VARCHAR(2),
    LAT_N DECIMAL(10,6),
    LONG_W DECIMAL(10,6)
);

-- Insert sample data
INSERT INTO #STATION VALUES 
(1, 'New York', 'NY', 40.7128, 74.0060),
(2, 'Los Angeles', 'CA', 34.0522, 118.2437),
(3, 'Chicago', 'IL', 41.8781, 87.6298),
(4, 'Houston', 'TX', 29.7604, 95.3698),
(5, 'Miami', 'FL', 25.7617, 80.1918);

-- Calculate Manhattan Distance
SELECT 
    ROUND(
        ABS(MAX(LAT_N) - MIN(LAT_N)) + 
        ABS(MAX(LONG_W) - MIN(LONG_W)), 
        4
    ) AS manhattan_distance
FROM #STATION;

-- Clean up
DROP TABLE #STATION;