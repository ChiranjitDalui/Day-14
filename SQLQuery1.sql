-- Create Students table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    email VARCHAR(50),
    major VARCHAR(50),
    enrollment_year INT
);

-- Create Courses table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50),
    credit_hours INT,
    department VARCHAR(50)
);

-- Create StudentCourses table for enrollment
CREATE TABLE StudentCourses (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
GO -- End of table creation batch

-- Insert sample data
INSERT INTO Students VALUES 
(1, 'John Doe', 'john@example.com', 'Computer Science', 2020),
(2, 'Jane Smith', 'jane@example.com', 'Mathematics', 2021),
(3, 'Mike Johnson', 'mike@example.com', 'Physics', 2020);

INSERT INTO Courses VALUES
(101, 'Database Systems', 3, 'CS'),
(102, 'Calculus II', 4, 'MATH'),
(103, 'Quantum Physics', 4, 'PHYSICS');

INSERT INTO StudentCourses VALUES
(1, 1, 101, 'Fall 2023', 'A'),
(2, 1, 102, 'Spring 2024', 'B'),
(3, 2, 102, 'Fall 2023', 'A'),
(4, 3, 103, 'Spring 2024', 'B+');
GO -- End of insertion batch

Select * FROM Students, Courses, StudentCourses;

UPDATE Students
    SET email= 'John_doe_university.edu'
    Where student_id = 1;
GO

-- Simple view
CREATE VIEW CS_Students AS
SELECT student_id, student_name, email
FROM Students
Where major = 'Computer Science';
GO -- Isolate the CREATE VIEW statement

Select * FROM CS_Students;
GO

-- Complex View (From multiple tables with Joins)
Create VIEW dbo.StudentEnrollments AS
SELECT s.student_name, c.course_name, sc.semester, sc.grade
FROM dbo.Students s
Inner JOIN dbo.StudentCourses sc on s.student_id = sc.student_id
Inner JOIN dbo.Courses c on sc.course_id = c.course_id;
GO -- Isolate the CREATE VIEW statement

Select * FROM dbo.StudentEnrollments;
GO

-- Query and modify View
Select TOP 3 * FROM dbo.StudentEnrollments;
SELECT * FROM dbo.StudentEnrollments Where grade='A';
GO

-- Updating data through a view
BEGIN TRANSACTION;
    UPDATE CS_Students -- Note: I corrected the view name from CS_Sudents to CS_Students
    SET email= 'John_doe_university.edu'
    Where student_id = 1;

-- verifying the update operation
SELECT  * FROM CS_Students Where student_id = 1;
ROLLBACK TRANSACTION -- Undoing the changes
GO

-- Attempting to update a complex view Using error handling
BEGIN TRY
    BEGIN TRANSACTION;
        UPDATE dbo.StudentEnrollments
        SET Grade = 'A+'
        WHERE student_name ='John Doe' AND course_name = 'Database Systems';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT 'ERROR occurred...!! ' + ERROR_MESSAGE();
END CATCH;
GO

-- Altering a view
IF EXISTS (SELECT * FROM sys.views WHERE name= 'CS_Students' AND schema_ID = SCHEMA_ID('dbo'))
    DROP VIEW dbo.CS_Students;
GO

-- Recreate the view with a new definition
CREATE VIEW dbo.CS_Students_New AS
SELECT student_id, student_name, email, enrollment_year
FROM dbo.Students
Where major = 'Computer Science';
GO -- Isolate the CREATE VIEW statement

Select * FROM dbo.CS_Students_New;
GO

-- View Metadata in MS SQL
-- Get view definition
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.CS_Students_New')) AS ViewDefinition;

-- List all views in the database
SELECT name AS ViewName, create_Date, modify_date
FROM sys.views
WHERE is_ms_shipped = 0
ORDER BY name;
GO