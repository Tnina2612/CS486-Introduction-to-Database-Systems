USE master;
GO

ALTER DATABASE University
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE IF EXISTS University;

CREATE DATABASE University;
GO
USE University;
GO

CREATE TABLE Instructor (
	instructor_id VARCHAR(9) PRIMARY KEY,
	instructor_name NVARCHAR(50) NOT NULL,
	phone NVARCHAR(9) NOT NULL,
	department_id VARCHAR(5),
	salary INT CHECK(salary > 0)
);

CREATE TABLE Department (
	department_id VARCHAR(5) PRIMARY KEY,
	department_name NVARCHAR(50) NOT NULL,
	office VARCHAR(5),
	department_head VARCHAR(9),
	FOREIGN KEY(department_head) REFERENCES Instructor(instructor_id)
);

ALTER TABLE Instructor
ADD CONSTRAINT FK_Instructor
FOREIGN KEY (department_id) REFERENCES Department(department_id);

CREATE TABLE Student (
	student_id VARCHAR(9) PRIMARY KEY,
	student_name NVARCHAR(50) NOT NULL,
	gender CHAR(1) CHECK(gender IN ('F', 'M', 'O')),
	birthdate DATETIME,
	class VARCHAR(5),
	department_id VARCHAR(5) NOT NULL,
	FOREIGN KEY(department_id) REFERENCES Department(department_id)
);

CREATE TABLE Course (
	course_id VARCHAR(9) PRIMARY KEY,
	course_name NVARCHAR(50) NOT NULL UNIQUE,
	credit INT CHECK(credit > 0),
	department_id VARCHAR(5) NOT NULL,
	FOREIGN KEY(department_id) REFERENCES Department(department_id)
);

CREATE TABLE Section (
	section_id INT PRIMARY KEY,
	course_id VARCHAR(9) NOT NULL,
	FOREIGN KEY(course_id) REFERENCES Course(course_id),
	semester VARCHAR(9) NOT NULL,
	year INT NOT NULL,
	capacity INT CHECK(capacity > 0),
	CONSTRAINT UQ_Section UNIQUE (course_id, semester, year)
);

CREATE TABLE Teaching (
	section_id INT NOT NULL,
	FOREIGN KEY(section_id) REFERENCES Section(section_id),
	instructor_id VARCHAR(9) NOT NULL,
	FOREIGN KEY(instructor_id) REFERENCES Instructor(instructor_id),
	role VARCHAR(9) CHECK(role IN ('Lecturer', 'TA')),
	PRIMARY KEY (section_id, instructor_id)
);

CREATE TABLE GradeReport (
	section_id INT NOT NULL,
	FOREIGN KEY(section_id) REFERENCES Section(section_id),
	student_id VARCHAR(9) NOT NULL,
	FOREIGN KEY(student_id) REFERENCES Student(student_id),
	grade_100 INT CHECK(grade_100 >= 0),
	grade_ABC CHAR(1) CHECK(grade_ABC IN ('A', 'B', 'C', 'D', 'E', 'F')),
	PRIMARY KEY (section_id, student_id)
);

CREATE TABLE Prerequisite (
	course_id VARCHAR(9) NOT NULL,
	FOREIGN KEY(course_id) REFERENCES Course(course_id),
	prerequisite_id VARCHAR(9) NOT NULL,
	FOREIGN KEY(prerequisite_id) REFERENCES Course(course_id),
	PRIMARY KEY (course_id, prerequisite_id)
);

INSERT INTO Instructor(instructor_id, instructor_name, phone, department_id, salary) VALUES
('I001', 'Dang Huynh Bao Khanh',  '080913213', NULL, 1000),
('I002', 'Alex Grant',            '082412613', NULL, 2000),
('I003', 'Tran Hoang Lan',        '080921234', NULL, 1500),
('I004', 'Nguyen Ngoc Khanh',     '090245613', NULL, 1500),
('I005', 'James Cobb',            '092193213', NULL, 2000),
('I006', 'Le Khanh',              '090799131', NULL, 2200),
('I007', 'Vu Ngoc Bao',           '090511342', NULL, 2100),
('I008', 'Tran Hong An',          '099912353', NULL, 1900),
('I009', 'Nguyen Hai Lam',        '080911234', NULL, 1500),
('I010', 'Dang Hoang Phong',      '090233451', NULL, 2300);

INSERT INTO Department(department_id, department_name, office, department_head) VALUES
('AI', 'Artificial Intelligence',  'I86', 'I009'),
('CS', 'Computer Science',         'I81', 'I001'),
('IS', 'Information System',       'I84', 'I004'),
('NW', 'Network',                  'I87', NULL),
('SE', 'Software Engineering',     'I82', 'I003');

UPDATE Instructor SET department_id = 'AI' WHERE instructor_id IN ('I009', 'I010');
UPDATE Instructor SET department_id = 'CS' WHERE instructor_id IN ('I001', 'I002');
UPDATE Instructor SET department_id = 'IS' WHERE instructor_id IN ('I004', 'I006');
UPDATE Instructor SET department_id = 'NW' WHERE instructor_id = 'I008';
UPDATE Instructor SET department_id = 'SE' WHERE instructor_id IN ('I003', 'I005', 'I007');

INSERT INTO Student (student_id, student_name, gender, birthdate, class, department_id) VALUES
('ST001', 'Nguyen Ai Linh', 'F', '2002-12-01 00:00:00', NULL, 'CS'),
('ST002', 'Tran Thanh Sang', 'M', '2003-09-02 00:00:00', NULL, 'CS'),
('ST003', 'Huynh Thanh Phong', 'M', '2001-05-03 00:00:00', NULL, 'SE'),
('ST004', 'Hoang Nhat Linh', 'F', '2002-05-10 00:00:00', NULL, 'SE'),
('ST005', 'Le Ba Khanh', 'M', '2001-11-12 00:00:00', NULL, 'SE'),
('ST006', 'Ly Quoc Phong', 'M', '2000-08-12 00:00:00', NULL, 'SE'),
('ST007', 'Tran Thanh An', 'F', '2000-11-09 00:00:00', NULL, 'IS'),
('ST008', 'Le Nha Thu', 'F', '2002-08-09 00:00:00', NULL, 'IS'),
('ST009', 'Ho Ngoc Anh', 'F', '2003-11-01 00:00:00', NULL, 'AI'),
('ST010', 'Nguyen Thanh Son', 'M', '2003-12-05 00:00:00', NULL, 'NW');

INSERT INTO Course (course_id, course_name, credit, department_id) VALUES
('CS01', 'Databases', 4, 'IS'),
('CS02', 'Database Management System', 4, 'IS'),
('CS03', 'Introduction to Programming', 4, 'SE'),
('CS04', 'Object-Oriented Programming', 4, 'SE'),
('CS05', 'Basic Network', 4, 'NW'),
('CS06', 'Advanced Network', 4, 'NW'),
('CS07', 'Introduction to Artificial Intelligence', 4, 'AI'),
('CS08', 'Introduction to Machine Learning', 4, 'CS'),
('CS09', 'Computer Vision', 4, 'CS'),
('CS10', 'Robotics', 4, 'AI');

INSERT INTO Prerequisite (course_id, prerequisite_id) VALUES
('CS02', 'CS01'),
('CS04', 'CS03'),
('CS06', 'CS05'),
('CS08', 'CS07'),
('CS09', 'CS07'),
('CS10', 'CS07');

INSERT INTO Section (section_id, course_id, semester, year, capacity) VALUES
(1, 'CS01', 'Fall', 2022, 30),
(2, 'CS02', 'Fall', 2022, 30),
(3, 'CS03', 'Fall', 2022, 30),
(4, 'CS04', 'Fall', 2022, 30),
(5, 'CS01', 'Spring', 2022, 20),
(6, 'CS02', 'Spring', 2022, 20),
(7, 'CS03', 'Spring', 2022, 20),
(8, 'CS05', 'Spring', 2022, 20),
(9, 'CS05', 'Fall', 2023, 12),
(10, 'CS06', 'Fall', 2023, 12),
(11, 'CS07', 'Fall', 2023, 12);

INSERT INTO Teaching (section_id, instructor_id, role) VALUES
(1, 'I004', 'Lecturer'),
(1, 'I006', 'TA'),
(2, 'I004', 'Lecturer'),
(2, 'I007', 'TA'),
(3, 'I003', 'TA'),
(3, 'I005', 'Lecturer'),
(4, 'I005', 'Lecturer'),
(4, 'I009', 'TA'),
(5, 'I004', 'Lecturer'),
(5, 'I006', 'TA'),
(6, 'I004', 'Lecturer'),
(7, 'I005', 'Lecturer'),
(8, 'I008', 'Lecturer');

INSERT INTO GradeReport (section_id, student_id, grade_100, grade_ABC) VALUES
(1, 'ST001', 80, 'B'),
(1, 'ST002', 82, 'B'),
(1, 'ST003', 35, 'F'),
(1, 'ST004', 60, 'F'),
(1, 'ST005', 100, 'A'),
(1, 'ST006', 100, 'A'),
(1, 'ST007', 90, 'A'),
(1, 'ST008', 52, 'F'),
(1, 'ST009', 36, 'F'),
(1, 'ST010', 99, 'A'),
(2, 'ST001', 77, 'C'),
(2, 'ST002', 84, 'B'),
(2, 'ST003', 60, 'F'),
(2, 'ST004', 53, 'F'),
(2, 'ST005', 99, 'A'),
(2, 'ST006', 93, 'A'),
(2, 'ST007', 82, 'B'),
(2, 'ST008', 63, 'F'),
(2, 'ST009', 62, 'F'),
(2, 'ST010', 88, 'B');