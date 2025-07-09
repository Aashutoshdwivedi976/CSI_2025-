CREATE TABLE JobCosts (
    job_family VARCHAR(100),
    location VARCHAR(20),  -- 'India' or 'International'
    cost FLOAT
);


INSERT INTO JobCosts (job_family, location, cost) VALUES
('Engineering', 'India', 50000),
('Engineering', 'International', 120000),
('Marketing', 'India', 30000),
('Marketing', 'International', 90000),
('HR', 'India', 20000),
('HR', 'International', 50000);


SELECT 
    job_family,
    
    ROUND(100.0 * SUM(CASE WHEN location = 'India' THEN cost ELSE 0 END) /
         SUM(cost), 2) AS India_Percentage,
         
    ROUND(100.0 * SUM(CASE WHEN location = 'International' THEN cost ELSE 0 END) /
         SUM(cost), 2) AS International_Percentage
         
FROM JobCosts
GROUP BY job_family;
