--1.1
WITH StudentAverage AS (
    SELECT student_id, AVG(grade_100) AS avg_grade
    FROM GradeReport
    GROUP BY student_id 
)
SELECT 
    s1.department_id, 
    s1.student_id, 
    s1.student_name, 
    sa1.avg_grade
FROM Student s1
JOIN StudentAverage sa1 ON s1.student_id = sa1.student_id
LEFT JOIN (
    Student s2
    JOIN StudentAverage sa2 ON s2.student_id = sa2.student_id
) ON s1.department_id = s2.department_id AND sa1.avg_grade < sa2.avg_grade
GROUP BY s1.department_id, s1.student_id, s1.student_name, sa1.avg_grade
HAVING COUNT(DISTINCT sa2.avg_grade) < 2;

--1.2
WITH StudentAverage AS (
    SELECT student_id, AVG(grade_100) AS avg_grade
    FROM GradeReport
    GROUP BY student_id
)
SELECT
    s1.department_id, 
    s1.student_id, 
    s1.student_name, 
    sa1.avg_grade
FROM Student s1
JOIN StudentAverage sa1 ON s1.student_id = sa1.student_id
WHERE (
    SELECT COUNT(DISTINCT sa2.avg_grade)
    FROM Student s2
    JOIN StudentAverage sa2 ON s2.student_id = sa2.student_id
    WHERE s1.department_id = s2.department_id AND sa1.avg_grade < sa2.avg_grade
) < 2;

--2
WITH PrerequisiteChain AS (
    SELECT course_id, prerequisite_id
    FROM Prerequisite
    WHERE course_id = 'CS07'

    UNION ALL

    SELECT p.course_id, p.prerequisite_id
    FROM Prerequisite p
    JOIN PrerequisiteChain pc ON p.course_id = pc.prerequisite_id
)
SELECT DISTINCT
     c.course_id  AS  target_course, 
     c.course_name  AS  target_course_name, 
     pc.prerequisite_id, 
     cp.course_name  AS  prerequisite_name
FROM PrerequisiteChain pc
JOIN Course c ON c.course_id = 'CS07'
JOIN Course cp ON cp.course_id = pc.prerequisite_id;

--3
DROP TABLE IF EXISTS TeachingCapacity;

CREATE TABLE TeachingCapacity (
    instructor_id VARCHAR(9) NOT NULL,
    course_id VARCHAR(9) NOT NULL,
    nb_year INT CHECK (nb_year > 0)

    PRIMARY KEY (instructor_id, course_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

--4
INSERT INTO TeachingCapacity(instructor_id, course_id, nb_year)
SELECT t.instructor_id, sec.course_id, COUNT(DISTINCT sec.school_year) as nb_year
FROM Teaching t
JOIN Section sec ON t.section_id = sec.section_id
GROUP BY t.instructor_id, sec.course_id
HAVING COUNT(DISTINCT sec.school_year) > 0;

--5
UPDATE gr
SET gr.grade_ABC = CASE
    WHEN gr.grade_100 >= 90 THEN 'A'
    WHEN gr.grade_100 >= 80 THEN 'B'
    WHEN gr.grade_100 >= 70 THEN 'C'
    WHEN gr.grade_100 >= 65 THEN 'D'
    WHEN gr.grade_100 >= 50 THEN 'E'
    ELSE 'F'
END
FROM GradeReport gr
WHERE gr.grade_100 IS NOT NULL;

--6
SELECT s.student_id, s.student_name, AVG(gr.grade_100) AS avg_passed_grade
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
WHERE grade_100 >= 50
GROUP BY s.student_id, s.student_name;

--7
SELECT s.student_id, s.student_name, COUNT(DISTINCT sec.course_id) AS nb_passed_course
FROM Student s
LEFT JOIN GradeReport gr ON s.student_id = gr.student_id AND gr.grade_100 >= 50
LEFT JOIN Section sec ON gr.section_id = sec.section_id
GROUP BY s.student_id, s.student_name;

--8
WITH StudentAverage AS (
    SELECT student_id, AVG(grade_100) AS avg_grade
    FROM GradeReport
    GROUP BY student_id 
)
SELECT
    s1.department_id,
    d.department_name,
    s1.student_id, 
    s1.student_name, 
    sa1.avg_grade
FROM Student s1
JOIN Department d ON s1.department_id = d.department_id
JOIN StudentAverage sa1 ON s1.student_id = sa1.student_id
WHERE (
    SELECT COUNT(*)
    FROM Student s2
    JOIN StudentAverage sa2 ON s2.student_id = sa2.student_id
    WHERE s1.department_id = s2.department_id AND sa1.avg_grade < sa2.avg_grade
) = 0;

--9
WITH DepartmentAverage AS (
    SELECT s.department_id, AVG(gr.grade_100) AS avg_grade
    FROM Student s
    JOIN GradeReport gr ON s.student_id = gr.student_id
    GROUP BY s.department_id
),
StudentAverage AS (
    SELECT student_id, AVG(grade_100) AS avg_grade
    FROM GradeReport
    GROUP BY student_id
)
SELECT s.student_id, s.student_name
FROM Student s
JOIN StudentAverage sa ON s.student_id = sa.student_id
JOIN DepartmentAverage da ON s.department_id = da.department_id
WHERE sa.avg_grade > da.avg_grade;

--10
DROP TABLE IF EXISTS StudentStatistics;

CREATE TABLE StudentStatistics (
    student_id VARCHAR(9),
    student_name NVARCHAR(50),
    school_year INT,
    semester VARCHAR(9),
    nb_credits INT,

    PRIMARY KEY (student_id, school_year, semester),
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
);

INSERT INTO StudentStatistics(student_id, student_name, school_year, semester, nb_credits)
SELECT s.student_id, s.student_name, sec.school_year, sec.semester, SUM(c.credit)
FROM Student s
JOIN GradeReport gr ON s.student_id = gr.student_id
JOIN Section sec ON gr.section_id = sec.section_id
JOIN Course c ON sec.course_id = c.course_id
GROUP BY s.student_id, s.student_name, sec.school_year, sec.semester;
