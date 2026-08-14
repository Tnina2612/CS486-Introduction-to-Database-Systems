-- 24125076
-- Tran Thien Phuc

-- Write a Stored Procedure to Get Department Payroll Summary
CREATE OR ALTER PROCEDURE sp_get_department_payroll_summary (
	@department_id VARCHAR(5)
) AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	
	BEGIN TRANSACTION;
	BEGIN TRY
		SELECT department_name, COUNT(i.instructor_id) AS NumberOfInstructors, SUM(i.salary) AS TotalSalary
		FROM Department d
		JOIN Instructor i ON d.department_id = i.department_id AND d.department_id = @department_id
		GROUP BY d.department_name
		
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW 50000, 'Cannot get department payroll summary.', 1
	END CATCH;
END;

-- Write a Stored Procedure to Adjust Instructor Salary
CREATE OR ALTER PROCEDURE sp_adjust_instructor_salary (
	@instructor_id VARCHAR(9),
	@new_salary INT
) AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	
	BEGIN TRANSACTION;
	BEGIN TRY
		IF NOT EXISTS (
			SELECT 1
			FROM Instructor
			WHERE instructor_id = @instructor_id
		)
		BEGIN
			RAISERROR ('Instructor ID does not exist.', 16, 1)
			ROLLBACK;
			RETURN;
		END
		
		UPDATE Instructor
		SET salary = @new_salary
		WHERE instructor_id = @instructor_id
		
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW 50000, 'Cannot adjust instructor salary.', 1
	END CATCH;
END;

-- Write Stored Procedure to Add New Instructor
CREATE OR ALTER PROCEDURE sp_add_new_instructor (
	@instructor_id VARCHAR(9),
	@instructor_name NVARCHAR(50),
	@phone NVARCHAR(9),
	@department_id VARCHAR(5),
	@salary INT
) AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	
	BEGIN TRANSACTION;
	BEGIN TRY
		IF EXISTS (
			SELECT 1
			FROM Instructor
			WHERE instructor_id = @instructor_id
		)
		BEGIN
			RAISERROR ('Instructor ID has already existed.', 16, 1)
			ROLLBACK;
			RETURN;
		END
		
		INSERT INTO Instructor (instructor_id, instructor_name, phone, department_id, salary)
		VALUES (@instructor_id, @instructor_name, @phone, @department_id, @salary)
		
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW 50000, 'Cannot add new instructor.', 1
	END CATCH;
END;

-- Scenerio 1: Non-repeatable Read
CREATE OR ALTER PROCEDURE sp_get_department_payroll_summary_with_delay (
	@department_id VARCHAR(5)
) AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		SELECT department_name, COUNT(i.instructor_id) AS NumberOfInstructors, SUM(i.salary) AS TotalSalary
		FROM Department d
		JOIN Instructor i ON d.department_id = i.department_id AND d.department_id = @department_id
		GROUP BY d.department_name
		
		PRINT 'Waiting for 3 seconds.';
		WAITFOR DELAY '00:00:03';
		PRINT 'Delay finished.';
		
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW 50000, 'Cannot get department payroll summary.', 1
	END CATCH;
END;

EXEC sp_get_department_payroll_summary_with_delay 'AI';
EXEC sp_adjust_instructor_salary 'I009', 2000;
EXEC sp_get_department_payroll_summary_with_delay 'AI';

-- Scenerio 2: Phantom Read
EXEC sp_get_department_payroll_summary_with_delay 'AI';
EXEC sp_add_new_instructor 'I013', 'Tran Thien Phuc', '0123456789', 'AI', 20000;
EXEC sp_get_department_payroll_summary_with_delay 'AI';