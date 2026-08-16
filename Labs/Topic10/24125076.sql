-- 1. Find the names of all courses that have at least one prerequisite, but none of their prerequisite courses have any prerequisites themselves.
SELECT DISTINCT c.course_name 
FROM Course c
JOIN Prerequisite p ON c.course_id = p.course_id

EXCEPT

SELECT DISTINCT c.course_name
FROM Course c
JOIN Prerequisite p1 ON c.course_id = p1.course_id
JOIN Prerequisite p2 ON p1.prerequisite_id = p2.course_id;
GO;

-- 2. Identify all instructors who are teaching a course in the same semester and year as the department head of their own department.
SELECT DISTINCT i.instructor_id , i.instructor_name 
FROM Instructor i
JOIN Teaching t ON i.instructor_id = t.instructor_id
JOIN Section s ON t.section_id = s.section_id
JOIN Department d ON i.department_id = d.department_id
WHERE EXISTS (
	SELECT 1
	FROM Instructor i1
	JOIN Teaching t1 ON i1.instructor_id = t1.instructor_id
	JOIN Section s1 ON t1.section_id = s1.section_id
	WHERE i1.instructor_id = d.department_head
		AND s1.semester = s.semester
		AND s1.school_year = s.school_year
);
GO;

-- 3. Find all students who have taken and passed at least one course from every department in the university.
SELECT s.student_id, s.student_name
FROM Student s
WHERE NOT EXISTS (
	SELECT 1
	FROM Department d
	WHERE NOT EXISTS (
		SELECT 1
		FROM GradeReport gr
		JOIN Section sec ON gr.section_id = sec.section_id
		JOIN Course c ON sec.course_id = c.course_id 
		WHERE gr.student_id = s.student_id
			AND c.department_id = d.department_id
			AND gr.grade_ABC <> 'F'		
	)
);
GO;

-- 4. Find the department(s) with the highest average salary for their instructors.
WITH AverageSalary AS (
	SELECT d.department_id, AVG(i.salary) AS avg_salary
	FROM Department d
	JOIN Instructor i ON d.department_id = i.department_id
	GROUP BY d.department_id
)
SELECT d1.department_id, d1.department_name
FROM Department d1
JOIN AverageSalary avg1 ON d1.department_id = avg1.department_id 
WHERE NOT EXISTS (
	SELECT 1
	FROM Department d2
	JOIN AverageSalary avg2 ON d2.department_id = avg2.department_id
	WHERE avg2.avg_salary > avg1.avg_salary
);
GO;

-- 5. Identify the students who are currently enrolled in a course but have not yet passed any of its prerequisite courses.
SELECT DISTINCT s.student_id, s.student_name
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
JOIN Section sec ON gr.section_id = sec.section_id
JOIN Course c ON sec.course_id = c.course_id
WHERE EXISTS (
	SELECT 1 FROM Prerequisite p WHERE p.course_id = c.course_id
)
AND NOT EXISTS (
	SELECT 1
	FROM Prerequisite p
	JOIN Section sec2 ON p.prerequisite_id = sec2.course_id
	JOIN GradeReport gr2 ON sec2.section_id = gr2.section_id
	WHERE gr2.student_id = s.student_id
		AND p.course_id = c.course_id
		AND gr2.grade_ABC <> 'F'
);
GO;

-- 6. (CTE allowed) For each department, find the lecturer with the highest number of unique courses taught.
WITH CoursesTaught AS (
	SELECT i.instructor_id, COUNT(DISTINCT s.course_id) AS nb_courses_taught
	FROM Instructor i
	JOIN Teaching t ON i.instructor_id = t.instructor_id
	JOIN Section s ON t.section_id = s.section_id
	GROUP BY i.instructor_id
)
SELECT d.department_id, d.department_name, i1.instructor_id , i1.instructor_name
FROM Department d
JOIN Instructor i1 ON d.department_id = i1.department_id
JOIN CoursesTaught c1 ON i1.instructor_id = c1.instructor_id
WHERE NOT EXISTS (
	SELECT 1
	FROM Instructor i2
	JOIN CoursesTaught c2 ON i2.instructor_id = c2.instructor_id
	WHERE i2.department_id = d.department_id
	AND c2.nb_courses_taught > c1.nb_courses_taught
);
GO;

-- 7. Identify the table of influence and write at least one trigger to ensure the BR1: There are no two courses within the same department having the same name.
-- SCOPE: Course (INSERT, UPDATE)
CREATE OR ALTER TRIGGER trg_courses_within_the_same_department ON Course
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Inserted i
		JOIN Course c ON i.course_name = c.course_name AND i.course_id <> c.course_id
		WHERE i.department_id = c.department_id
	)
	BEGIN
		RAISERROR('Two courses within the same department must not have the same name', 16, 1)
		ROLLBACK;
	END
END;
GO;

-- 8. Write a trigger to perform a cascading delete for a department.
CREATE OR ALTER TRIGGER trg_delete_department ON Department
INSTEAD OF DELETE
AS
BEGIN
	DELETE FROM Student
	WHERE department_id IN (
		SELECT department_id
		FROM Deleted d
	)
	
	DELETE FROM Course
	WHERE department_id IN (
		SELECT department_id
		FROM Deleted d
	)
	
	DELETE FROM Instructor
	WHERE department_id IN (
		SELECT department_id
		FROM Deleted d
	)
	
	DELETE FROM Department
	WHERE department_id IN (
		SELECT department_id
		FROM Deleted d
	)
END;
GO;

-- 9. Create a stored procedure to do the following steps with the given <student_id> and <section_id>.
CREATE OR ALTER PROCEDURE sp_read_grade_with_delay (
	@student_id VARCHAR(9),
	@section_id INT
) AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		SELECT gr.grade_100
		FROM Student s
		JOIN GradeReport gr ON s.student_id = gr.student_id
		WHERE s.student_id = @student_id
			AND gr.section_id = @section_id
			
		PRINT 'Waiting for 10 seconds';
		WAITFOR DELAY '00:00:10';
		PRINT 'Delay finished';
		
		SELECT gr.grade_100
		FROM Student s
		JOIN GradeReport gr ON s.student_id = gr.student_id
		WHERE s.student_id = @student_id
			AND gr.section_id = @section_id
		
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW 50000, 'Cannot read grade of the student', 1
	END CATCH;
END;
GO;

-- 10. Create a stored procedure to delete a student grade given student_ID and section_ID.
CREATE OR ALTER PROCEDURE sp_delete_grade (
	@student_id VARCHAR(9),
	@section_id INT
) AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		IF NOT EXISTS (
			SELECT 1
			FROM Student
			WHERE student_id = @student_id
		)
		BEGIN
			RAISERROR('Student ID does not exist', 16, 1)
			ROLLBACK;
			RETURN;
		END
		
		IF NOT EXISTS (
			SELECT 1
			FROM Section
			WHERE section_id = @section_id
		)
		BEGIN
			RAISERROR('Section ID does not exist', 16, 1)
			ROLLBACK;
			RETURN;
		END
		
		DELETE FROM GradeReport
		WHERE student_id = @student_id
			AND section_id = @section_id
		
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW 50000, 'Cannot delete grade of the student', 1
	END CATCH;
END;
GO;

-- 11. Create a stored procedure to multiply a student grade by 1.1 given student_ID, section_ID (new_score = old_score * 1.1).
CREATE OR ALTER PROCEDURE sp_multiply_grade (
	@student_id VARCHAR(9),
	@section_id INT
) AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		IF NOT EXISTS (
			SELECT 1
			FROM Student
			WHERE student_id = @student_id
		)
		BEGIN
			RAISERROR('Student ID does not exists', 16, 1)
			ROLLBACK;
			RETURN;
		END
		
		IF NOT EXISTS (
			SELECT 1
			FROM Section
			WHERE section_id = @section_id
		)
		BEGIN
			RAISERROR('Section ID does not exists', 16, 1)
			ROLLBACK;
			RETURN;
		END
		
		UPDATE GradeReport
		SET grade_100 = grade_100 * 1.1
		WHERE student_id = @student_id
			AND section_id = @section_id
			
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW 50000, 'Cannot multiply grade of the student', 1
	END CATCH;
END;
GO;

-- 12. Use transactions to ensure that the stored procedures work as required.
-- Non-repeatable Read
EXEC sp_read_grade_with_delay 'ST004', 1;
EXEC sp_multiply_grade 'ST004', 1;
GO;
-- Phantom Read
EXEC sp_read_grade_with_delay 'ST004', 1;
EXEC sp_delete_grade 'ST004', 1;
GO;
-- Solution: Add `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;` before `BEGIN TRANSACTION;`.
