-- STEP 1: Create Tables

-- StudentDetails Table
CREATE TABLE StudentDetails (
    StudentId VARCHAR(20) PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA FLOAT,
    Branch VARCHAR(20),
    Section VARCHAR(10)
);

-- SubjectDetails Table
CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(20) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);

-- StudentPreference Table
CREATE TABLE StudentPreference (
    StudentId VARCHAR(20),
    SubjectId VARCHAR(20),
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);

-- Allotments Table
CREATE TABLE Allotments (
    SubjectId VARCHAR(20),
    StudentId VARCHAR(20),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- UnallotedStudents Table
CREATE TABLE UnallotedStudents (
    StudentId VARCHAR(20),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- STEP 2: Insert Sample Data

-- Insert into StudentDetails
INSERT INTO StudentDetails VALUES
('159103036', 'Mohit Agarwal', 8.9, 'CCE', 'A'),
('159103037', 'Rohit Agarwal', 5.2, 'CCE', 'A'),
('159103038', 'Shohit Garg', 7.1, 'CCE', 'B'),
('159103039', 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
('159103040', 'Meheret Singh', 5.6, 'CCE', 'A'),
('159103041', 'Arjun Tehlan', 9.2, 'CCE', 'B');

-- Insert into SubjectDetails
INSERT INTO SubjectDetails VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco Philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

-- Insert into StudentPreference
-- (Example preferences for Mohit, add others similarly if required)
INSERT INTO StudentPreference VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 2),
('159103036', 'PO1493', 3),
('159103036', 'PO1494', 4),
('159103036', 'PO1495', 5);
-- Add similar preferences for other students as needed

-- STEP 3: Stored Procedure to Allot Subjects

CREATE PROCEDURE AllocateSubjects
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear previous allotments
    DELETE FROM Allotments;
    DELETE FROM UnallotedStudents;

    DECLARE @StudentId VARCHAR(20), @SubjectId VARCHAR(20), @RemainingSeats INT;
    DECLARE @Preference INT;

    -- Cursor for students in descending GPA
    DECLARE student_cursor CURSOR FOR
    SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @Allotted BIT = 0;
        SET @Preference = 1;

        WHILE @Preference <= 5 AND @Allotted = 0
        BEGIN
            SELECT @SubjectId = SubjectId
            FROM StudentPreference
            WHERE StudentId = @StudentId AND Preference = @Preference;

            IF @SubjectId IS NOT NULL
            BEGIN
                SELECT @RemainingSeats = RemainingSeats
                FROM SubjectDetails
                WHERE SubjectId = @SubjectId;

                IF @RemainingSeats > 0
                BEGIN
                    -- Allot the subject
                    INSERT INTO Allotments (SubjectId, StudentId)
                    VALUES (@SubjectId, @StudentId);

                    -- Decrease remaining seat count
                    UPDATE SubjectDetails
                    SET RemainingSeats = RemainingSeats - 1
                    WHERE SubjectId = @SubjectId;

                    SET @Allotted = 1;
                END
            END

            SET @Preference = @Preference + 1;
        END

        -- If not allotted
        IF @Allotted = 0
        BEGIN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM student_cursor INTO @StudentId;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;

---step-4 --------
EXEC AllocateSubjects;

-- check results 

SELECT * FROM Allotments;
SELECT * FROM UnallotedStudents;

--BONUS — Join to See Full Allocation Info

SELECT 
    s.StudentId, s.StudentName, s.GPA, a.SubjectId, sd.SubjectName
FROM Allotments a
JOIN StudentDetails s ON a.StudentId = s.StudentId
JOIN SubjectDetails sd ON a.SubjectId = sd.SubjectId
ORDER BY s.GPA DESC;

