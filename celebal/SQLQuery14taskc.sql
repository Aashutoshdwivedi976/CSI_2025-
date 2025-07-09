CREATE TABLE Employees (
    emp_id INT,
    emp_name VARCHAR(100),
    subband VARCHAR(10)
);


INSERT INTO Employees VALUES
(1, 'Aashutosh', 'A1'),
(2, 'Neha', 'A1'),
(3, 'Ravi', 'A2'),
(4, 'Simran', 'A1'),
(5, 'Vikram', 'A3'),
(6, 'Anita', 'A2'),
(7, 'Rohan', 'A3'),
(8, 'Deepa', 'A2');


SELECT 
    subband,
    COUNT(*) AS headcount,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS percentage
FROM Employes
GROUP BY subband;
