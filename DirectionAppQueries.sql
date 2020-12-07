USE Direction;

--оценки
select * from Grades;

--список студентов
-- ROLES: методисты, декан, студенты
select * from Students;

--средний балл студента
-- ROLES: методисты, декан, студенты
select avg(Valuee) as AverageGrade from Grades where StudentID=1


-- 1
-- ¬ыберите группы, в которых есть студенты, получающие повышенную стипендию
-- ROLES: методисты, декан
SELECT DISTINCT Groups.Naming FROM
	Groups
		JOIN Students ON Students.GroupID = Groups.GroupID
			JOIN ScholarshipOrders ON Students.ScholarshipOrderID = ScholarshipOrders.ScholOrderID
				WHERE ScholarshipOrders.Naming = 'повышенна€';

-- 2
-- ¬ыберите методистов, которые не выполнили ни одного задани€ декана
-- ROLES: декан
SELECT * FROM Methodists WHERE NOT EXISTS (
	SELECT * FROM DirectorInstructions
		JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
			WHERE Methodists.MethodistID = DirectorInstructions.MethodistID AND Statuses.Naming = '¬ыполнен'
)

-- 3
-- ¬ыберите группы, в которых есть только отличники или хорошисты
-- ROLES: методисты, декан
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
-- ¬ывести студентов, запросы на стипендию которых были отклонены
-- ROLES: декан
SELECT FIO FROM Students 
	JOIN RequestsScholarship ON Students.StudentID = RequestsScholarship.StudentID
		JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
			WHERE Statuses.Naming = 'ќтклонЄн';

-- 5
-- ¬ыберите методиста, который выполнил больше всех заданий декана
-- ROLES: декан
SELECT FIO FROM Methodists JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
GROUP BY Methodists.FIO
	HAVING COUNT(DirectorInstructions.MethodistID) = (
		SELECT MAX(number) FROM (SELECT COUNT(DirectorInstructions.MethodistID) AS number, Methodists.FIO FROM Methodists
								 JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
								 JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
								 WHERE Statuses.Naming = '¬ыполнен'
								 GROUP BY Methodists.FIO)
								 AS A
	);

-- 6
-- ¬ каких группах есть студенты, которые хот€т перейти в другую группу
-- ROLES: методисты, декан
SELECT * FROM Groups WHERE EXISTS (
	SELECT * FROM Students, RequestsGroupChange
		WHERE Students.StudentID = RequestsGroupChange.StudentID
			AND Students.GroupID = Groups.GroupID
);

-- 7
-- ¬ыберите группы, в расписании которых больше 2 свободных дней
-- ROLES: методисты, декан
SELECT DISTINCT Groups.Naming FROM Groups
	JOIN Schedule ON Groups.GroupID = Schedule.GroupID
		GROUP BY(Groups.Naming)
		HAVING COUNT(DISTINCT Schedule.DayOfWeekID) < 5;

-- 8
-- ¬ какой группе наибольше количество студентов, желающих отчислитьс€
-- ROLES: методисты, декан
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
-- ѕолучить последние по дате за€вки на стипендию дл€ студентов, их подававших
-- ROLES: декан
SELECT * FROM RequestsScholarship
	JOIN Students ON Students.StudentID = RequestsScholarship.StudentID
		WHERE  RequestsScholarship.DateIssued = (
			SELECT MAX(DateIssued) FROM RequestsScholarship WHERE Students.StudentID = RequestsScholarship.StudentID
		);

-- 10
-- ƒл€ каждой группы вывести количество мальчиков и количество девочек в группе
-- ROLES: методисты, декан, студенты
SELECT
	Naming,
	SUM(case when Students.SexID=1 then 1 else 0 end) AS Boys,
	SUM(case when Students.SexID=2 then 1 else 0 end) AS Girls
FROM Groups, Students
WHERE Groups.GroupID = Students.GroupID
GROUP BY(Naming)

-- 11 UNION
-- ¬ывести группы, дл€ которых математика или физика встречаетс€ в расписании больше 1 раза
-- ROLES: методисты, декан, студенты
SELECT Groups.Naming FROM Groups
	JOIN Schedule ON Groups.GroupID = Schedule.GroupID
		JOIN Disciplines ON Schedule.DisciplineID = Disciplines.DisciplineID
			WHERE Disciplines.Naming = 'ћатематика'
			GROUP BY(Groups.Naming)
				HAVING COUNT(Disciplines.Naming) > 1
UNION
SELECT Groups.Naming FROM Groups
	JOIN Schedule ON Groups.GroupID = Schedule.GroupID
		JOIN Disciplines ON Schedule.DisciplineID = Disciplines.DisciplineID
			WHERE Disciplines.Naming = '‘изика'
			GROUP BY(Groups.Naming)
				HAVING COUNT(Disciplines.Naming) > 1

-- 12 IN
-- ¬ыберите все за€вки методистов декану, методисты которых - мужчины
-- ROLES: декан
SELECT * 
FROM RequestsScholarshipM
WHERE MethodistID IN (
	SELECT MethodistID
	FROM Methodists
	JOIN Sex ON Methodists.SexID = Sex.SexID
	WHERE Sex.Naming = 'мужской'
)

-- 13 LEFT JOIN
-- ¬ыберите всех студентов и соотв им приказы на стипендию, если они есть
-- ROLES: методисты, декан
SELECT *
FROM Students
LEFT JOIN ScholarshipOrders ON Students.ScholarshipOrderID = ScholarshipOrders.ScholOrderID

-- 14 EXCEPT
-- ¬ыберите студентов и их оценки "3", кроме тех, которые получены по математике
-- ROLES: методисты, декан
SELECT FIO, Birthday, Groups.Naming AS GroupNum, Disciplines.Naming AS SubjectN, Valuee AS Grade
FROM Students
JOIN Groups ON Students.GroupID = Groups.GroupID
JOIN Grades ON Students.StudentID = Grades.StudentID
JOIN Disciplines ON Grades.DisciplineID = Disciplines.DisciplineID
WHERE Grades.Valuee = 3
EXCEPT
SELECT FIO, Birthday, Groups.Naming AS GroupNum, Disciplines.Naming AS SubjectN, Valuee AS Grade
FROM Students
JOIN Groups ON Students.GroupID = Groups.GroupID
JOIN Grades ON Students.StudentID = Grades.StudentID
JOIN Disciplines ON Grades.DisciplineID = Disciplines.DisciplineID
WHERE Disciplines.Naming = 'ћатематика'