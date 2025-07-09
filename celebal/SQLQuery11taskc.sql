-- Create tables
CREATE TABLE Students (
    ID INT,
    Name VARCHAR(50)
);

CREATE TABLE Friends (
    ID INT,
    Friend_ID INT
);

CREATE TABLE Packages (
    ID INT,
    Salary FLOAT
);

-- Insert sample data
INSERT INTO Students VALUES 
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends VALUES 
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO Packages VALUES 
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

-- Main query to find students with higher-paid best friends
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID  -- Student's salary
JOIN Packages p2 ON f.Friend_ID = p2.ID  -- Friend's salary
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;