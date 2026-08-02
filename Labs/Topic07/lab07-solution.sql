--1
-- SCOPE: Teaching (INSERT, UPDATE)
CREATE OR ALTER TRIGGER trg_max_instructors_per_section ON Teaching
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Teaching
		WHERE section_id IN (SELECT section_id FROM Inserted)
		GROUP BY section_id
		HAVING COUNT(DISTINCT instructor_id) > 4
	)
	BEGIN
		RAISERROR('A section cannot have more than 4 teaching staff', 16, 1)
		ROLLBACK;
	END
END;

--2
-- SCOPE: Department (INSERT, UPDATE)
CREATE OR ALTER TRIGGER trg_department_head_belongs_1 ON Department
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Inserted d
		JOIN Instructor i ON d.department_head = i.instructor_id
		WHERE i.department_id <> d.department_id
	)
	BEGIN
		RAISERROR('The department head must belong to the department', 16, 1)
		ROLLBACK;
	END
END;

-- SCOPE: Instructor (UPDATE)
CREATE OR ALTER TRIGGER trg_department_head_belongs_2 ON Instructor
FOR UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Inserted i
		JOIN Department d ON i.instructor_id = d.department_head
		WHERE i.department_id <> d.department_id
	)
	BEGIN
		RAISERROR('The department head must belong to the department', 16, 1)
		ROLLBACK;
	END
END;

--3
-- SCOPE: GradeReport (INSERT, UPDATE)
CREATE TRIGGER trg_max_courses_per_semester_1 ON GradeReport
FOR INSERT, UPDATE
AS BEGIN
	IF EXISTS (
		SELECT 1
		FROM GradeReport gr
		JOIN Section sec ON gr.section_id = sec.section_id
		JOIN (
			SELECT DISTINCT i.student_id, s.semester
			FROM Inserted i
			JOIN Section s ON i.section_id = s.section_id		
		) modified ON gr.student_id = modified.student_id AND sec.semester = modified.semester 
		GROUP BY gr.student_id, sec.semester
		HAVING COUNT(DISTINCT sec.course_id) > 4
	)
	BEGIN
		RAISERROR('Student cannot take more than 4 subjects in one semester', 16, 1)
		ROLLBACK;
	END
END;

-- SCOPE: Section (UPDATE)
CREATE TRIGGER trg_max_courses_per_semester_2 ON Section
FOR UPDATE
AS BEGIN
	IF EXISTS (
		SELECT 1
		FROM GradeReport gr
		JOIN Section sec ON gr.section_id = sec.section_id
		JOIN (
			SELECT DISTINCT s.student_id, i.semester
			FROM Inserted i
			JOIN GradeReport s ON i.section_id = s.section_id		
		) modified ON gr.student_id = modified.student_id AND sec.semester = modified.semester 
		GROUP BY gr.student_id, sec.semester
		HAVING COUNT(DISTINCT sec.course_id) > 4
	)
	BEGIN
		RAISERROR('Student cannot take more than 4 subjects in one semester', 16, 1)
		ROLLBACK;
	END
END;

--4
-- SCOPE: GradeReport (INSERT, UPDATE)
CREATE OR ALTER TRIGGER trg_enrol_condition ON GradeReport
FOR INSERT, UPDATE
AS BEGIN
	IF EXISTS (
		SELECT 1
		FROM Inserted i
		JOIN Section sec ON i.section_id = sec.section_id
		JOIN Course c ON sec.course_id = c.course_id
		JOIN Prerequisite pre ON c.course_id = pre.course_id
		WHERE NOT EXISTS (
			SELECT 1
			FROM GradeReport gr2
			JOIN Section sec2 ON gr2.section_id = sec2.section_id
			WHERE gr2.student_id = i.student_id
				AND sec2.course_id = pre.prerequisite_id
				AND gr2.grade_ABC <> 'F'
		)
	)
	BEGIN
		RAISERROR('Student has not passed all prerequisites for this course', 16, 1)
		ROLLBACK;
	END
END;

--5
-- SCOPE: Teaching (INSERT, UPDATE)
CREATE OR ALTER TRIGGER trg_max_taught_sections_per_year_1 ON Teaching
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Teaching t
		JOIN Section s ON t.section_id = s.section_id
		JOIN (
			SELECT DISTINCT i.instructor_id, sec.semester, sec.school_year
			FROM Inserted i
			JOIN Section sec ON i.section_id = sec.section_id
		) modified
		ON t.instructor_id = modified.instructor_id
			AND s.semester = modified.semester
			AND s.school_year = modified.school_year
		GROUP BY t.instructor_id, s.semester, s.school_year
		HAVING COUNT(DISTINCT s.section_id) > 3
	)
	BEGIN
		RAISERROR('Instructor cannot teach more than 3 sections in a semester', 16, 1)
		ROLLBACK;
	END
END;

-- SCOPE: Section (Update)
CREATE TRIGGER trg_max_taught_sections_per_year_2 ON Section
FOR UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Teaching t
		JOIN Section s ON t.section_id = s.section_id
		JOIN (
			SELECT DISTINCT t.instructor_id, i.semester, i.school_year
			FROM Inserted i
			JOIN Teaching t ON i.section_id = t.section_id
		) modified
		ON t.instructor_id = modified.instructor_id
			AND s.semester = modified.semester
			AND s.school_year = modified.school_year
		GROUP BY t.instructor_id, s.semester, s.school_year
		HAVING COUNT(DISTINCT s.section_id) > 3
	)
	BEGIN
		RAISERROR('Instructor cannot teach more than 3 sections in a semester', 16, 1)
		ROLLBACK;
	END
END;

--6
-- SCOPE (INSERT, UPDATE)
CREATE OR ALTER TRIGGER trg_department_head_2 ON Department
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Department
		WHERE department_head IN (SELECT department_head FROM Inserted)
		GROUP BY department_head
		HAVING COUNT(DISTINCT department_id) > 1
	)
	BEGIN
		RAISERROR('An instructor cannot be head of more than one department', 16, 1)
		ROLLBACK;
	END
END;

--7
-- SCOPE: Prerequisite (INSERT, UPDATE)
CREATE OR ALTER TRIGGER trg_course_cycle ON Prerequisite
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @cycle_exists BIT = 0;

	WITH PrerequisiteChain AS (
		-- Base case: Start from the newly inserted/updated rows
		SELECT
			course_id,
			prerequisite_id,
			0 AS is_cycle,
			CAST(course_id AS VARCHAR(MAX)) + '->' + CAST(prerequisite_id AS VARCHAR(MAX)) AS PathStr
		FROM Inserted
		
		UNION ALL
		
		SELECT
			pc.course_id,
			p.prerequisite_id,
			CASE WHEN pc.PathStr LIKE '%' + CAST(p.prerequisite_id AS VARCHAR(MAX)) + '%' THEN 1 ELSE 0 END AS is_cycle,
			pc.PathStr + '->' + CAST(p.prerequisite_id AS VARCHAR(MAX))
		FROM Prerequisite p
		JOIN PrerequisiteChain pc ON p.course_id = pc.prerequisite_id
		WHERE pc.is_cycle = 0
	)

	SELECT TOP 1 @cycle_exists = 1
	FROM PrerequisiteChain
	WHERE is_cycle = 1;

	IF @cycle_exists = 1
	BEGIN
		RAISERROR('Prerequisite relationship contains a cycle', 16, 1)
		ROLLBACK;
	END
END;