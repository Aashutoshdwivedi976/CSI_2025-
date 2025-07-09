CREATE TABLE Employees (
    emp_id INT,
    emp_name VARCHAR(100),
    salary INT
);


INSERT INTO Employees VALUES
(1, 'Aashutosh', 70000),
(2, 'Neha', 85000),
(3, 'Raj', 60000),
(4, 'Simran', 95000),
(5, 'Vikram', 72000),
(6, 'Ritu', 90000),
(7, 'Aman', 65000);


WITH SalaryRanks AS (
    SELECT emp_id, emp_name, salary,
           DENSE_RANK() OVER (PARTITION BY 1 ORDER BY salary DESC) AS rnk
    FROM Employees
)
SELECT emp_id, emp_name, salary
FROM SalaryRanks
WHERE rnk <= 5;
