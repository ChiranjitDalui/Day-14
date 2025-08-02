USE CollegeDB;
GO

-- Initial query (can be slow on large tables without indexes)
SELECT * FROM Students, Courses, StudentCourses;
GO

-- Indexing on above table for Faster lookups
PRINT 'Creating Indexes...';
GO

-- Index on student Email
CREATE NONCLUSTERED INDEX IX_STUDENT_EMAIL ON Students(email);
GO

-- Composite non-clustered index on major and enrollment year
CREATE NONCLUSTERED INDEX IX_StudentMajor_Year ON Students(major, enrollment_year);
GO

-- Creating a Unique Index on email to prevent duplicates
-- NOTE: This will fail if a non-unique index on the same column already exists.
-- You would typically choose either a unique or non-unique index.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_Students_Email' AND object_id = OBJECT_ID('Students'))
BEGIN
    CREATE UNIQUE INDEX UQ_Students_Email ON Students(email) WHERE email IS NOT NULL;
END
GO

-- Create a non-clustered Index on StudentCourses for common query patterns
CREATE NONCLUSTERED INDEX IX_StudentCourses_Grade ON StudentCourses(semester, grade);
GO

---

## Analysis and Demonstration

-- Analysing Index usage
-- Checking existing indexes in the database
PRINT 'Listing existing indexes...';
SELECT
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.is_ms_shipped = 0 AND i.name IS NOT NULL
ORDER BY t.name, i.name;
GO

-- Sample Queries based on indexing
PRINT 'Running sample queries that use indexes...';
SELECT * FROM Students WHERE email = 'John_doe_university.edu';
GO

-- Using composite index
SELECT * FROM Students WHERE major = 'Computer Science' AND enrollment_year = 2020;
GO

-- Listing all the tables in the database
PRINT 'Listing tables and schemas...';
SELECT * FROM sys.tables;
GO
SELECT * FROM sys.schemas;
GO

---

## Demonstrating Non-Updatable Views

-- View with DISTINCT (not updatable)
PRINT 'Creating DISTINCT view...';
GO

CREATE VIEW UniqueMajors AS
SELECT DISTINCT major FROM Students;
GO

SELECT * FROM UniqueMajors;
GO

-- Below operation will fail because DISTINCT creates a derived result set
-- and SQL SERVER can't map updates back to the base table.
BEGIN TRY
    PRINT 'Attempting to update DISTINCT view...';
    UPDATE UniqueMajors
    SET major = 'Computer Sciences'
    WHERE Major = 'Computer Science';
END TRY
BEGIN CATCH
    PRINT 'Update failed (as expected).';
    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH;
GO

-- View with computed column (non-updatable)
PRINT 'Creating view with a computed column...';
GO

CREATE VIEW StudentNameLengths1 AS
SELECT student_id, student_name, LEN(student_name) AS name_length
FROM Students;
GO

SELECT * FROM StudentNameLengths1;
GO

-- This will fail because it contains a derived column (name_length)
-- and SQL Server can't update a calculated value directly.
BEGIN TRY
    PRINT 'Attempting to update view with a computed column...';
    UPDATE StudentNameLengths1
    SET student_name = 'John Travolta'
    WHERE name_length = 6;
END TRY
BEGIN CATCH
    PRINT 'Update failed (as expected).';
    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH;
GO