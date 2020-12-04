USE Direction;

--список студентов
select * from Students;

--оценки
select * from Grades;

--средний балл студента
select avg(Valuee) from Grades where StudentID=1


-- 1
-- Выберите группы, в которых есть студенты, получающие повышенную стипендию
SELECT DISTINCT Groups.Naming FROM
	Groups
		JOIN Students ON Students.GroupID = Groups.GroupID
			JOIN ScholarshipOrders ON Students.ScholarshipOrderID = ScholarshipOrders.ScholOrderID
				WHERE ScholarshipOrders.Naming = 'повышенная';

-- 2
-- Выберите методистов, которые не выполнили ни одного задания декана
SELECT * FROM Methodists WHERE NOT EXISTS (
	SELECT * FROM DirectorInstructions
		JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
			WHERE Methodists.MethodistID = DirectorInstructions.MethodistID AND Statuses.Naming = 'Выполнен'
)

-- 3
-- Выберите группы, в которых есть только отличники или хорошисты
SELECT * FROM Groups WHERE EXISTS (
	SELECT * FROM Students
		JOIN Grades ON Students.StudentID = Grades.StudentID 
			WHERE Groups.GroupID = Students.GroupID AND (Grades.Valuee = 5 OR Grades.Valuee = 4)
)
INTERSECT
SELECT * FROM Groups WHERE NOT EXISTS (
	SELECT * FROM Students
		JOIN Grades ON Students.StudentID = Grades.StudentID
			WHERE Groups.GroupID = Students.GroupID AND (Grades.Valuee = 3  OR Grades.Valuee = 2)
)

-- 4
-- Вывести студентов, запросы на стипендию которых были отклонены
SELECT FIO FROM Students 
	JOIN RequestsScholarship ON Students.StudentID = RequestsScholarship.StudentID
		JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
			WHERE Statuses.Naming = 'Отклонён';

-- 5
-- Выберите методиста, который выполнил больше всех заданий декана
SELECT FIO FROM Methodists JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
GROUP BY Methodists.FIO
	HAVING COUNT(DirectorInstructions.MethodistID) = (
		SELECT MAX(number) FROM (SELECT COUNT(DirectorInstructions.MethodistID) AS number, Methodists.FIO FROM Methodists
								 JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
								 JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
								 WHERE Statuses.Naming = 'Выполнен'
								 GROUP BY Methodists.FIO)
								 AS A
	);

-- 6
-- В каких группах есть студенты, которые хотят перейти в другую группу
SELECT * FROM Groups WHERE EXISTS (
	SELECT * FROM Students, RequestsGroupChange
		WHERE Students.StudentID = RequestsGroupChange.StudentID
			AND Students.GroupID = Groups.GroupID
);

-- 7
-- Выберите группы, в расписании которых больше 2 свободных дней
SELECT DISTINCT Groups.Naming FROM Groups
	JOIN Schedule ON Groups.GroupID = Schedule.GroupID
		GROUP BY(Groups.Naming)
		HAVING COUNT(DISTINCT Schedule.DayOfWeekID) < 5;

-- 8
-- В какой группе наибольше количество студентов, желающих отчислиться
SELECT Groups.Naming FROM Groups
	JOIN Students ON Students.GroupID = Groups.GroupID
		JOIN RequestsDropOut ON RequestsDropOut.StudentID = Students.StudentID
GROUP BY Groups.Naming
	HAVING COUNT(RequestsDropOut.StudentID) = (
		SELECT MAX(number) FROM (SELECT COUNT(RequestsDropOut.StudentID) AS number, Groups.Naming FROM Groups
								 JOIN Students ON Students.GroupID = Groups.GroupID
								 JOIN RequestsDropOut ON RequestsDropOut.StudentID = Students.StudentID
								 GROUP BY Groups.Naming)
								 AS A
	);

-- 9
-- Получить последние по дате заявки на стипендию для студентов, их подававших
SELECT * FROM RequestsScholarship
	JOIN Students ON Students.StudentID = RequestsScholarship.StudentID
		WHERE  RequestsScholarship.DateIssued = (
			SELECT MAX(DateIssued) FROM RequestsScholarship WHERE Students.StudentID = RequestsScholarship.StudentID
		);

-- 10
-- Для каждой группы вывести количество мальчиков и количество девочек в группе
SELECT
	Naming,
	SUM(case when Students.SexID=1 then 1 else 0 end) AS Boys,
	SUM(case when Students.SexID=2 then 1 else 0 end) AS Girls
FROM Groups, Students
WHERE Groups.GroupID = Students.GroupID
GROUP BY(Naming)