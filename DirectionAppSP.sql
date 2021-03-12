USE Direction;

-- вывести стипендию студента по его ID
SELECT Naming, Summ, DateStarted, OrderName, ScholOrderID FROM
	ScholarshipOrders
	JOIN Students
	ON ScholarshipOrders.ScholOrderID = Students.ScholarshipOrderID
WHERE 
	StudentID = 1

-- список группы по её номеру
SELECT * FROM Students WHERE GroupID = 1;

-- расписание группы
SELECT DayNaming AS День, Disciplines.Naming AS Предмет, TimeLine AS Время,
	   Room AS Ауд, ClassesTypes.Naming AS Тип FROM
	Schedule
	JOIN Dayss ON Schedule.DayOfWeekID = Dayss.DayID
	JOIN Disciplines ON Schedule.DisciplineID = Disciplines.DisciplineID
	JOIN ClassesTypes ON Schedule.TypeID = ClassesTypes.TypeID
WHERE
	Schedule.GroupID = 1
	
-- оценки определенного студента по его ID
SELECT Naming AS Предмет, Valuee AS Оценка FROM
	Grades
	JOIN Disciplines ON Grades.GradeID = Disciplines.DisciplineID
WHERE Grades.StudentID = 1

-- для конкретной группы кол-во мальчиков и девочек
SELECT
	Naming,
	SUM(case when Students.SexID=1 then 1 else 0 end) AS Boys,
	SUM(case when Students.SexID=2 then 1 else 0 end) AS Girls
FROM Groups, Students
WHERE Groups.GroupID = Students.GroupID AND Students.GroupID = 1
GROUP BY(Naming)

-- для конкретного студента вывести список его заявок на стипендию
SELECT
	Summ AS Сумма, Cause AS Причина, DateIssued AS Дата_заявлено,
	DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
FROM
	RequestsScholarship
	JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
	WHERE StudentID = 1;

-- заявки на смену группы для студента
SELECT
	Groups.Naming AS Группа, Cause AS Причина, DateIssued AS Дата_заявлено,
	DateAcceptedOrRejected AS Дата_результат, Statuses.Naming AS Статус
FROM
	RequestsGroupChange
	JOIN Groups ON RequestsGroupChange.OldGroupID = Groups.GroupID
	JOIN Statuses ON RequestsGroupChange.StatusID = Statuses.StatusID
	WHERE RequestsGroupChange.StudentID = 1;

-- заявки на отчисление для студента
SELECT
	Cause AS Причина, DateIssued AS Дата_заявлено,
	DateAcceptedOrRejected AS Дата_результат, Statuses.Naming AS Статус
FROM
	RequestsDropOut
	JOIN Statuses ON RequestsDropOut.StatusID = Statuses.StatusID
	WHERE RequestsDropOut.StudentID = 1;

-- задания декана
SELECT
	MethodistID, FIO, Summ, Cause, DateIssued, DateCompleted, Naming
FROM
	DirectorInstructions
	JOIN Students ON DirectorInstructions.StudentID = Students.StudentID
	JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID


-- ТРИГГЕР
-- 1) При вставке заявки, устанавливать ей статус "В процессе"
GO
CREATE TRIGGER setReqInProcess
ON RequestsScholarship
AFTER INSERT
AS
UPDATE RequestsScholarship
SET StatusID = 1
WHERE RequestID = (SELECT RequestID FROM inserted)
GO
ENABLE TRIGGER setReqInProcess ON RequestsScholarship

GO
CREATE TRIGGER setReqCGInProcess
ON RequestsGroupChange
AFTER INSERT
AS
UPDATE RequestsGroupChange
SET StatusID = 1
WHERE RequestID = (SELECT RequestID FROM inserted)
GO
ENABLE TRIGGER setReqCGInProcess ON RequestsGroupChange

GO
CREATE TRIGGER setReqDropInProcess
ON RequestsDropOut
AFTER INSERT
AS
UPDATE RequestsDropOut
SET StatusID = 1
WHERE RequestID = (SELECT RequestID FROM inserted)
GO
ENABLE TRIGGER setReqDropInProcess ON RequestsDropOut

-- ХРАНИМЫЕ ПРОЦЕДУРЫ
-- 1) Отправить заявку на стипендию от студента и отобразить в таблице заявок
GO
CREATE PROCEDURE sp_loadReqFromStudent
	@StudentID AS INT,
	@Sum AS INT,
	@Cause AS VARCHAR(100),
	@DateIssued AS DATE
AS
	INSERT INTO RequestsScholarship (StudentID, Summ, Cause, DateIssued)
	VALUES(@StudentID, @Sum, @Cause, @DateIssued)
	
	SELECT
		Summ AS Сумма, Cause AS Причина, DateIssued AS Дата_заявлено,
		DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	FROM
		RequestsScholarship
		JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
	WHERE
		StudentID = @StudentID
GO

DECLARE @StudentID int, @Sum int, @Cause VARCHAR(100), @DateIssued DATE;
SET @StudentID=2;
SET @Sum = 2000;
SET @Cause='Учеба';
SET @DateIssued = '2020-12-12';
EXEC sp_loadReqFromStudent @StudentID, @Sum, @Cause, @DateIssued; 

DROP PROCEDURE sp_loadReqFromStudent;
	
-- 2) Отправить заявку на смену группы от студента и отобразить в таблице заявок
GO
CREATE PROCEDURE sp_loadReqCGFromStudent
	@StudentID AS INT,
	@OldGroupID AS INT,
	@NewGroupID AS INT,
	@Cause AS VARCHAR(100),
	@DateIssued AS DATE
AS
	INSERT INTO RequestsGroupChange (StudentID, OldGroupID, NewGroupID, Cause, DateIssued)
	VALUES(@StudentID, @OldGroupID, @NewGroupID, @Cause, @DateIssued)
	
	SELECT 
		Groups.Naming AS Группа, Cause AS Причина, DateIssued AS Дата_заявлено,
        DateAcceptedOrRejected AS Дата_результат, Statuses.Naming AS Статус
    FROM
		RequestsGroupChange
		JOIN Groups ON RequestsGroupChange.OldGroupID = Groups.GroupID
        JOIN Statuses ON RequestsGroupChange.StatusID = Statuses.StatusID
    WHERE
		RequestsGroupChange.StudentID = @StudentID
GO

-- 3) Отправить заявку на отчисление от студента и отобразить в таблице заявок
GO
CREATE PROCEDURE sp_loadReqDropFromStudent
	@StudentID AS INT,
	@Cause AS VARCHAR(100),
	@DateIssued AS DATE
AS
	INSERT INTO RequestsDropOut (StudentID, Cause, DateIssued)
	VALUES(@StudentID, @Cause, @DateIssued)
	
	SELECT
		Cause AS Причина, DateIssued AS Дата_заявлено,
		DateAcceptedOrRejected AS Дата_результат, Statuses.Naming AS Статус
	FROM
		RequestsDropOut
		JOIN Statuses ON RequestsDropOut.StatusID = Statuses.StatusID
	WHERE RequestsDropOut.StudentID = @StudentID;
GO

-- 4) Отправить заявку на стипендию от методиста и отобразить в таблице заявок
GO
CREATE PROCEDURE sp_loadReqFromMeth
	@MethodistID AS INT,
	@StudentID AS INT,
	@Sum AS INT,
	@Cause AS VARCHAR(100),
	@DateIssued AS DATE
AS
	INSERT INTO RequestsScholarshipM(MethodistID, StudentID, Summ, Cause, DateIssued, StatusID)
	VALUES(@MethodistID, @StudentID, @Sum, @Cause, @DateIssued, 1)
	
	SELECT
		FIO, Summ AS Сумма, Cause AS Причина, DateIssued AS Дата_заявлено,
		DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	FROM
		RequestsScholarshipM
		JOIN Statuses ON RequestsScholarshipM.StatusID = Statuses.StatusID
		JOIN Students ON RequestsScholarshipM.StudentID = Students.StudentID 
	WHERE
		MethodistID = @MethodistID
GO

-- 10) Методисты разных типов
GO
CREATE PROCEDURE sp_loadMethodists
	@Type AS VARCHAR(100)
AS
	IF		@Type = 'Все'

       SELECT
			FIO AS ФИО, Birthday AS Дата_рожд, Sex.Naming AS Пол, Salary AS ЗП
	   FROM
			Methodists
			JOIN Sex ON Methodists.SexID = Sex.SexID

	ELSE IF @Type = 'Выполнивший больше всех заданий'

       SELECT
			FIO AS ФИО, Birthday AS Дата_рожд, Sex.Naming AS Пол, Salary AS ЗП
	   FROM
			Methodists
			JOIN Sex ON Methodists.SexID = Sex.SexID
			JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
GROUP BY Methodists.FIO, Birthday, Sex.Naming, Salary
	HAVING COUNT(DirectorInstructions.MethodistID) = (
		SELECT MAX(number) FROM (SELECT COUNT(DirectorInstructions.MethodistID) AS number, Methodists.FIO FROM Methodists
								 JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
								 JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
								 WHERE Statuses.Naming = 'Выполнен'
								 GROUP BY Methodists.FIO)
								 AS A
	);

	ELSE IF @Type = 'Не выполнившие ни одного задания'

		SELECT
			FIO AS ФИО, Birthday AS Дата_рожд, Sex.Naming AS Пол, Salary AS ЗП
		FROM
			Methodists
			JOIN Sex ON Methodists.SexID = Sex.SexID
		WHERE NOT EXISTS (
			SELECT * FROM DirectorInstructions
			JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
			WHERE Methodists.MethodistID = DirectorInstructions.MethodistID AND Statuses.Naming = 'Выполнен'
		)
GO

-- 11) заявки декану разных типов с изменением
GO
CREATE PROCEDURE sp_loadReqDirectorWithChange
	@Type AS VARCHAR(100),
	@RequestID INT,
	@StatusID INT,
	@DateAcRej date
AS
	IF		@Type = 'Студент-стипендия'
	BEGIN
	   UPDATE RequestsScholarship
			SET
				StatusID = @StatusID,
				DateAcceptedOrRejected = @DateAcRej
	   WHERE RequestID = @RequestID

       SELECT
			RequestID AS ID_заявки, FIO AS Студент, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	   FROM
			RequestsScholarship
			JOIN Students ON RequestsScholarship.StudentID = Students.StudentID
			JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
	END
	ELSE IF @Type = 'Студент-стипендия-последние'
	BEGIN
	   UPDATE RequestsScholarship
			SET
				StatusID = @StatusID,
				DateAcceptedOrRejected = @DateAcRej
	   WHERE RequestID = @RequestID

       SELECT
			RequestID AS ID_заявки, FIO AS Студент, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	   FROM
			RequestsScholarship
			JOIN Students ON Students.StudentID = RequestsScholarship.StudentID
			JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
	   WHERE
			RequestsScholarship.DateIssued = (
				SELECT
					MAX(DateIssued)
				FROM
					RequestsScholarship
				WHERE
					Students.StudentID = RequestsScholarship.StudentID
			);
	END
	ELSE IF @Type = 'Студент-стипендия-отклонён'
	BEGIN
		UPDATE RequestsScholarship
			SET
				StatusID = @StatusID,
				DateAcceptedOrRejected = @DateAcRej
	    WHERE RequestID = @RequestID

		SELECT
			RequestID AS ID_заявки, FIO AS Студент, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
		FROM
			RequestsScholarship 
			JOIN Students ON Students.StudentID = RequestsScholarship.StudentID
			JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
		WHERE
			Statuses.Naming = 'Отклонён';
	END
	ELSE IF @Type = 'Студент-смена группы'
	BEGIN
		UPDATE RequestsGroupChange
			SET
				StatusID = @StatusID,
				DateAcceptedOrRejected = @DateAcRej
	    WHERE RequestID = @RequestID

		SELECT
			RequestID AS ID_заявки, FIO AS Студент, Groups.Naming AS Желаемая_гр,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Statuses.Naming AS Статус
		FROM
			RequestsGroupChange
			JOIN Groups ON RequestsGroupChange.NewGroupID = Groups.GroupID
			JOIN Students ON RequestsGroupChange.StudentID = Students.StudentID
			JOIN Statuses ON RequestsGroupChange.StatusID = Statuses.StatusID;
	END
	ELSE IF @Type = 'Студент-отчисление'
	BEGIN
		UPDATE RequestsDropOut
			SET
				StatusID = @StatusID,
				DateAcceptedOrRejected = @DateAcRej
	    WHERE RequestID = @RequestID

		SELECT
			RequestID AS ID_заявки, FIO AS Студент,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
		FROM
			RequestsDropOut
			JOIN Students ON RequestsDropOut.StudentID = Students.StudentID
			JOIN Statuses ON RequestsDropOut.StatusID = Statuses.StatusID;
	END
	ELSE IF @Type = 'Методист-стипендия'
	BEGIN
		UPDATE RequestsScholarshipM
			SET
				StatusID = @StatusID,
				DateAcceptedOrRejected = @DateAcRej
	    WHERE RequestID = @RequestID

		SELECT
			RequestID AS ID_заявки, Students.FIO AS Студент,
			Methodists.FIO AS Методист, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	   FROM
			RequestsScholarshipM
			JOIN Methodists ON RequestsScholarshipM.MethodistID = Methodists.MethodistID
			JOIN Students ON RequestsScholarshipM.StudentID = Students.StudentID
			JOIN Statuses ON RequestsScholarshipM.StatusID = Statuses.StatusID;
	END
	ELSE IF @Type = 'Методист-стипендия-мужчина'
	BEGIN
		UPDATE RequestsScholarshipM
			SET
				StatusID = @StatusID,
				DateAcceptedOrRejected = @DateAcRej
	    WHERE RequestID = @RequestID
		
		SELECT
			RequestID AS ID_заявки, Students.FIO AS Студент,
			Methodists.FIO AS Методист, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
		FROM
			RequestsScholarshipM
			JOIN Methodists ON RequestsScholarshipM.MethodistID = Methodists.MethodistID
			JOIN Students ON RequestsScholarshipM.StudentID = Students.StudentID
			JOIN Statuses ON RequestsScholarshipM.StatusID = Statuses.StatusID
		WHERE
			RequestsScholarshipM.MethodistID IN (
				SELECT MethodistID
				FROM
					Methodists
					JOIN Sex ON Methodists.SexID = Sex.SexID
				WHERE
					Sex.Naming = 'мужской'
			)
	END
GO

-- 11) заявки декану разных типов
GO
CREATE PROCEDURE sp_loadReqDirector
	@Type AS VARCHAR(100)
AS
	IF		@Type = 'Студент-стипендия'

       SELECT
			RequestID AS ID_заявки, FIO AS Студент, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	   FROM
			RequestsScholarship
			JOIN Students ON RequestsScholarship.StudentID = Students.StudentID
			JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID;

	ELSE IF @Type = 'Студент-стипендия-последние'

       SELECT
			RequestID AS ID_заявки, FIO AS Студент, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	   FROM
			RequestsScholarship
			JOIN Students ON Students.StudentID = RequestsScholarship.StudentID
			JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
	   WHERE
			RequestsScholarship.DateIssued = (
				SELECT
					MAX(DateIssued)
				FROM
					RequestsScholarship
				WHERE
					Students.StudentID = RequestsScholarship.StudentID
			);

	ELSE IF @Type = 'Студент-стипендия-отклонён'

		SELECT
			RequestID AS ID_заявки, FIO AS Студент, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
		FROM
			RequestsScholarship 
			JOIN Students ON Students.StudentID = RequestsScholarship.StudentID
			JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
		WHERE
			Statuses.Naming = 'Отклонён';

	ELSE IF @Type = 'Студент-смена группы'

		SELECT
			RequestID AS ID_заявки, FIO AS Студент, Groups.Naming AS Желаемая_гр,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Statuses.Naming AS Статус
		FROM
			RequestsGroupChange
			JOIN Groups ON RequestsGroupChange.NewGroupID = Groups.GroupID
			JOIN Students ON RequestsGroupChange.StudentID = Students.StudentID
			JOIN Statuses ON RequestsGroupChange.StatusID = Statuses.StatusID;

	ELSE IF @Type = 'Студент-отчисление'

		SELECT
			RequestID AS ID_заявки, FIO AS Студент,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
		FROM
			RequestsDropOut
			JOIN Students ON RequestsDropOut.StudentID = Students.StudentID
			JOIN Statuses ON RequestsDropOut.StatusID = Statuses.StatusID;

	ELSE IF @Type = 'Методист-стипендия'

		SELECT
			RequestID AS ID_заявки, Students.FIO AS Студент,
			Methodists.FIO AS Методист, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
	   FROM
			RequestsScholarshipM
			JOIN Methodists ON RequestsScholarshipM.MethodistID = Methodists.MethodistID
			JOIN Students ON RequestsScholarshipM.StudentID = Students.StudentID
			JOIN Statuses ON RequestsScholarshipM.StatusID = Statuses.StatusID;

	ELSE IF @Type = 'Методист-стипендия-мужчина'
		
		SELECT
			RequestID AS ID_заявки, Students.FIO AS Студент,
			Methodists.FIO AS Методист, Summ AS Сумма,
			Cause AS Причина, DateIssued AS Дата_заявлено,
			DateAcceptedOrRejected AS Дата_результат, Naming AS Статус
		FROM
			RequestsScholarshipM
			JOIN Methodists ON RequestsScholarshipM.MethodistID = Methodists.MethodistID
			JOIN Students ON RequestsScholarshipM.StudentID = Students.StudentID
			JOIN Statuses ON RequestsScholarshipM.StatusID = Statuses.StatusID
		WHERE
			RequestsScholarshipM.MethodistID IN (
				SELECT MethodistID
				FROM
					Methodists
					JOIN Sex ON Methodists.SexID = Sex.SexID
				WHERE
					Sex.Naming = 'мужской'
			)
GO