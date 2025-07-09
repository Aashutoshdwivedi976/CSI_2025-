CREATE TABLE BU_Financials (
    bu_name VARCHAR(100),
    month_year DATE,          -- any date in the month, used for grouping
    cost FLOAT,
    revenue FLOAT
);


INSERT INTO BU_Financials (bu_name, month_year, cost, revenue) VALUES
('Sales', '2024-01-01', 20000, 50000),
('Sales', '2024-02-01', 25000, 60000),
('Sales', '2024-03-01', 30000, 70000),
('Tech', '2024-01-01', 50000, 120000),
('Tech', '2024-02-01', 60000, 140000),
('Tech', '2024-03-01', 55000, 130000);


SELECT 
    bu_name,
    FORMAT(month_year, 'yyyy-MM') AS month,
    SUM(cost) AS total_cost,
    SUM(revenue) AS total_revenue,
    ROUND(SUM(cost) * 1.0 / NULLIF(SUM(revenue), 0), 2) AS cost_to_revenue_ratio
FROM BU_Financials
GROUP BY bu_name, FORMAT(month_year, 'yyyy-MM')
ORDER BY bu_name, month;
