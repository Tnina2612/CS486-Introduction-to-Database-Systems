--1
SELECT *
FROM Student
WHERE birthdate >= '2000/01/01' AND birthdate < '2006/01/01';

--2
SELECT *
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
JOIN Section sec ON gr.section_id = sec.section_id
WHERE sec.course_id = 'CS07' AND sec.semester = 'Fall' AND sec.school_year = 2022;

--3
SELECT instructor_name, salary * 1.1 AS new_salary
FROM Instructor ins
JOIN Teaching tc ON ins.instructor_id = tc.instructor_id
JOIN Section sec ON tc.section_id = sec.section_id
WHERE sec.course_id = 'CS07';

--4
SELECT cou.course_id, cou.course_name, pre_course.course_name AS prerequisite_name
FROM Course cou
LEFT JOIN Prerequisite pre ON cou.course_id = pre.course_id
LEFT JOIN Course pre_course ON pre.prerequisite_id = pre_course.course_id
WHERE cou.department_id = 'IS';

--5
SELECT *
FROM Instructor ins
JOIN Department dep ON ins.department_id = dep.department_id
WHERE dep.department_name = 'Computer Science' AND ins.salary >= 2000 AND ins.salary <= 3000;

--6
SELECT ins.instructor_name, dep.department_name, cou.course_name, tc.teaching_role
FROM Instructor ins
JOIN Teaching tc ON ins.instructor_id = tc.instructor_id
JOIN Section sec ON tc.section_id = sec.section_id
JOIN Course cou ON sec.course_id = cou.course_id
JOIN Department dep ON cou.department_id = dep.department_id
WHERE tc.teaching_role = 'Lecturer'
ORDER BY dep.department_name, ins.instructor_name;

--7
SELECT course_id, course_name
FROM Course
WHERE course_id NOT IN (
	SELECT DISTINCT course_id
	FROM Section sec
	JOIN Teaching tc ON sec.section_id = tc.section_id
	WHERE tc.instructor_id = 'I002'
);

--8
SELECT instructor_id FROM Teaching WHERE teaching_role = 'Lecturer'
INTERSECT
SELECT instructor_id FROM Teaching WHERE teaching_role = 'TA';

--9
SELECT s.student_id, student_name
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
JOIN Section sec ON gr.section_id = sec.section_id
WHERE sec.course_id = 'CS03' AND gr.grade_ABC <> 'F'
INTERSECT
SELECT s.student_id, student_name
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
JOIN Section sec ON gr.section_id = sec.section_id
WHERE sec.course_id = 'CS04' AND sec.semester = 'Fall' AND sec.school_year = 2022 AND gr.grade_ABC = 'F';	

--10
SELECT s.student_id, s.student_name
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
JOIN Section sec ON gr.section_id = sec.section_id
WHERE gr.grade_ABC <> 'F'
GROUP BY s.student_id, s.student_name
HAVING COUNT(DISTINCT sec.course_id) > 2;

--11
SELECT school_year, semester, COUNT(DISTINCT course_id) as nb_courses
FROM Section
GROUP BY school_year, semester;

--12.1
SELECT cou.course_id, cou.course_name, COUNT(DISTINCT tc.instructor_id) as nb_instructors
FROM course cou
JOIN Section sec ON cou.course_id = sec.course_id
JOIN Teaching tc ON sec.section_id = tc.section_id
GROUP BY cou.course_id, cou.course_name
HAVING COUNT(DISTINCT tc.instructor_id) = (
	SELECT MAX(nb_instructors)
	FROM (
		SELECT COUNT(DISTINCT tc2.instructor_id) AS nb_instructors
		FROM Teaching tc2
		JOIN Section sec2 ON tc2.section_id = sec2.section_id
		GROUP BY sec2.course_id
	) AS course_counts
);

--12.2
SELECT cou.course_id, cou.course_name, COUNT(DISTINCT tc.instructor_id) as nb_instructors
FROM course cou
JOIN Section sec ON cou.course_id = sec.course_id
JOIN Teaching tc ON sec.section_id = tc.section_id
GROUP BY cou.course_id, cou.course_name
HAVING COUNT(DISTINCT tc.instructor_id) >= ALL (
	SELECT COUNT(DISTINCT tc2.instructor_id) AS nb_instructors
	FROM Teaching tc2
	JOIN Section sec2 ON tc2.section_id = sec2.section_id
	GROUP BY sec2.course_id
);

--12.3
SELECT TOP (1) WITH TIES cou.course_id, cou.course_name, COUNT(DISTINCT tc.instructor_id) as nb_instructors
FROM course cou
JOIN Section sec ON cou.course_id = sec.course_id
JOIN Teaching tc ON sec.section_id = tc.section_id
GROUP BY cou.course_id, cou.course_name
ORDER BY nb_instructors DESC;

--13.1
SELECT i.instructor_id, instructor_name
FROM Instructor i
JOIN Teaching t ON i.instructor_id = t.instructor_id
WHERE i.instructor_id NOT IN (
    SELECT DISTINCT ins.instructor_id
    FROM Instructor ins
    JOIN Teaching tc ON ins.instructor_id = tc.instructor_id
    JOIN Section sec ON tc.section_id = sec.section_id
    JOIN Course cou ON sec.course_id = cou.course_id
    WHERE cou.department_id <> ins.department_id
)
AND EXISTS ( -- Ensure the instructor teach at least 1 section
    SELECT 1 FROM Teaching tc WHERE t.instructor_id = tc.instructor_id
);

--13.2
SELECT i.instructor_id, instructor_name
FROM Instructor i
JOIN Teaching t ON i.instructor_id = t.instructor_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Instructor ins
    JOIN Teaching tc ON ins.instructor_id = tc.instructor_id
    JOIN Section sec ON tc.section_id = sec.section_id
    JOIN Course cou ON sec.course_id = cou.course_id
    WHERE i.instructor_id = ins.instructor_id
        AND cou.department_id <> ins.department_id
)
AND EXISTS ( -- Ensure the instructor teach at least 1 section
    SELECT 1 FROM Teaching tc WHERE t.instructor_id = tc.instructor_id
);

--14.1
SELECT s.student_id, student_name, COUNT(DISTINCT cou.course_id) AS nb_courses
FROM Student s
LEFT JOIN GradeReport gr ON s.student_id = gr.student_id
LEFT JOIN Section sec ON gr.section_id = sec.section_id
LEFT JOIN Course cou ON sec.course_id = cou.course_id AND cou.department_id = s.department_id
GROUP BY s.student_id, student_name

--14.2
SELECT s.student_id, student_name, dep.department_id, department_name, COUNT(DISTINCT cou.course_id) AS nb_courses
FROM Student s
LEFT JOIN GradeReport gr ON s.student_id = gr.student_id
LEFT JOIN Section sec ON gr.section_id = sec.section_id
LEFT JOIN Course cou ON sec.course_id = cou.course_id
LEFT JOIN Department dep ON cou.department_id = dep.department_id
GROUP BY s.student_id, student_name, dep.department_id, department_name
ORDER BY s.student_id, dep.department_id;

--15.1
SELECT s.student_id, s.student_name, m.section_id
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
JOIN (
    SELECT section_id, MAX(grade_100) AS max_grade
    FROM GradeReport
    GROUP BY section_id
) m 
    ON gr.section_id = m.section_id AND gr.grade_100 = m.max_grade;

--15.2
SELECT s.student_id, s.student_name, gr.section_id
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
WHERE s.student_id IN (
    SELECT TOP (1) WITH TIES  gr2.student_id
    FROM GradeReport gr2
    WHERE gr2.section_id = gr.section_id
    ORDER BY grade_100 DESC
);