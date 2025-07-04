-- Drop existing tables if they exist (for reset/testing)

--- Step - 01   
IF OBJECT_ID('SubjectAllotments', 'U') IS NOT NULL
    DROP TABLE SubjectAllotments;

IF OBJECT_ID('SubjectRequest', 'U') IS NOT NULL
    DROP TABLE SubjectRequest;

-- Create SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentId VARCHAR(50),
    SubjectId VARCHAR(50),
    Is_Valid BIT
);

-- Create SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentId VARCHAR(50),
    SubjectId VARCHAR(50)
);

---- step --- 2  

-- Insert sample allotments (with one active subject)
INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

-- Insert subject request
INSERT INTO SubjectRequest (StudentId, SubjectId) VALUES
('159103036', 'PO1496');  -- New subject request

-------Step --- 3

-- Drop procedure if it already exists
IF OBJECT_ID('UpdateSubjectAllotment', 'P') IS NOT NULL
    DROP PROCEDURE UpdateSubjectAllotment;
GO

-- Create the procedure
CREATE PROCEDURE UpdateSubjectAllotment
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentId VARCHAR(50);
    DECLARE @NewSubjectId VARCHAR(50);
    DECLARE @CurrentSubjectId VARCHAR(50);

    DECLARE request_cursor CURSOR FOR
        SELECT StudentId, SubjectId FROM SubjectRequest;

    OPEN request_cursor;
    FETCH NEXT FROM request_cursor INTO @StudentId, @NewSubjectId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Get currently valid subject
        SELECT @CurrentSubjectId = SubjectId
        FROM SubjectAllotments
        WHERE StudentId = @StudentId AND Is_Valid = 1;

        -- Check if the requested subject exists in SubjectAllotments
        IF EXISTS (
            SELECT 1 FROM SubjectAllotments
            WHERE StudentId = @StudentId AND SubjectId = @NewSubjectId
        )
        BEGIN
            -- If it's different from current, update
            IF @CurrentSubjectId <> @NewSubjectId
            BEGIN
                -- Set current valid subject to invalid
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentId = @StudentId AND Is_Valid = 1;

                -- Make the requested subject valid
                UPDATE SubjectAllotments
                SET Is_Valid = 1
                WHERE StudentId = @StudentId AND SubjectId = @NewSubjectId;
            END
        END
        ELSE
        BEGIN
            -- Invalidate current subject
            UPDATE SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentId = @StudentId AND Is_Valid = 1;

            -- Insert new valid subject
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentId, @NewSubjectId, 1);
        END

        FETCH NEXT FROM request_cursor INTO @StudentId, @NewSubjectId;
    END

    CLOSE request_cursor;
    DEALLOCATE request_cursor;
END;
GO

---step ---4 
EXEC UpdateSubjectAllotment;

--step --5 
SELECT * FROM SubjectAllotments WHERE StudentId = '159103036';

