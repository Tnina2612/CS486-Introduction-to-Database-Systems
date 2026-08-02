--1
CREATE FUNCTION fn_CountInstructors(@section_id int)
RETURNS int
AS
BEGIN
	RETURN (
		SELECT COUNT(DISTINCT instructor_id)
		FROM Teaching
		WHERE section_id = @section_id
	)
END;

--2
CREATE FUNCTION fn_CountStudents(@section_id int)
RETURNS int
AS
BEGIN
	RETURN (
		SELECT COUNT(DISTINCT student_id)
		FROM GradeReport
		WHERE section_id = @section_id
	)
END;

--3
CREATE OR ALTER PROCEDURE sp_RetrieveInformation
	@section_id int
AS
BEGIN
	SELECT
		s.section_id,
		c.course_name,
		s.semester,
		s.school_year,
		dbo.fn_CountInstructors(@section_id) AS nb_instructors,
		dbo.fn_CountStudents(@section_id) AS nb_students
	FROM Section s
	JOIN Course c ON s.course_id = c.course_id
	WHERE s.section_id = @section_id
END;

--4
CREATE OR ALTER PROCEDURE sp_GetStudentsEnrolledInAllCoursesFrom
	@department_name varchar(50)
AS
BEGIN
	SELECT 
		st.student_id, 
		st.student_name
	FROM Student st
	JOIN GradeReport gr ON st.student_id = gr.student_id
	JOIN Section s ON gr.section_id = s.section_id
	JOIN Course c ON s.course_id = c.course_id
	JOIN Department d ON c.department_id = d.department_id
	WHERE d.department_name = @department_name
	GROUP BY st.student_id, st.student_name
	HAVING COUNT(DISTINCT c.course_id) = (
		-- Subquery to get the total number of courses offered by the given department
		SELECT COUNT(course_id)
		FROM Course c2
		JOIN Department d2 ON c2.department_id = d2.department_id
		WHERE d2.department_name = @department_name
	)
END;

--5
CREATE OR ALTER PROCEDURE sp_RetrieveFromYearAndSemester
	@year int,
	@semester int
AS
BEGIN
	SELECT
		t.instructor_id,
		s.school_year,
		s.semester,
		COUNT(DISTINCT s.section_id) AS nb_taught_classes
	FROM Section s
	JOIN Teaching t ON s.section_id = t.section_id
	WHERE s.school_year = @year AND s.semester = @semester
	GROUP BY t.instructor_id, s.school_year, s.semester
END;

--6
CREATE FUNCTION fn_GetNumberOfCredits(@student_id varchar(9), @year int, @semester int)
RETURNS int
AS
BEGIN
	RETURN (
		SELECT SUM(credit)
		FROM Course c
		JOIN Section s ON c.course_id = s.course_id
		JOIN GradeReport gr ON s.section_id = gr.section_id
		WHERE gr.student_id = @student_id
			AND s.school_year = @year
			AND s.semester = @semester
	)
END;