CREATE TABLE Employee_Costs (
    emp_id INT,
    emp_name VARCHAR(100),
    month_year DATE,
    cost FLOAT,
    fte FLOAT  -- this is our weight
);


INSERT INTO Employee_Costs VALUES
(1, 'Aashutosh', '2024-01-01', 40000, 1.0),
(2, 'Neha', '2024-01-01', 30000, 0.5),
(3, 'Raj', '2024-01-01', 20000, 0.25),
(1, 'Aashutosh', '2024-02-01', 42000, 1.0),
(2, 'Neha', '2024-02-01', 31000, 0.5),
(3, 'Raj', '2024-02-01', 21000, 0.25);


SELECT 
    FORMAT(month_year, 'yyyy-MM') AS month,
    ROUND(SUM(cost * fte) / NULLIF(SUM(fte), 0), 2) AS weighted_avg_cost
FROM Employee_Costs
GROUP BY FORMAT(month_year, 'yyyy-MM')
ORDER BY month;
