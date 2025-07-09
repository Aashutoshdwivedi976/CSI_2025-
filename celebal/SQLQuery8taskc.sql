-- 1. Create the OCCUPATIONS table
CREATE TABLE OCCUPATIONS (
    Name VARCHAR(50),
    Occupation VARCHAR(50)
);

-- 2. Insert the sample data
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashely', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');

-- 3. Main query using PIVOT operator
WITH NumberedOccupations AS (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM OCCUPATIONS
)

SELECT 
    Doctor, Professor, Singer, Actor
FROM (
    SELECT RowNum, Name, Occupation 
    FROM NumberedOccupations
) AS SourceTable
PIVOT (
    MAX(Name) FOR Occupation IN (Doctor, Professor, Singer, Actor)
) AS PivotTable
ORDER BY RowNum;