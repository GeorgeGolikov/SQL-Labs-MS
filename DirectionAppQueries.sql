USE Direction;

--������ ���������
select * from Students;

--������
select * from Grades;

--������� ���� ��������
select avg(Valuee) from Grades where StudentID=1


-- 1
-- �������� ������, � ������� ���� ��������, ���������� ���������� ���������
SELECT DISTINCT Groups.Naming FROM
	Groups
		JOIN Students ON Students.GroupID = Groups.GroupID
			JOIN ScholarshipOrders ON Students.ScholarshipOrderID = ScholarshipOrders.ScholOrderID
				WHERE ScholarshipOrders.Naming = '����������';

-- 2
-- �������� ����������, ������� �� ��������� �� ������ ������� ������
SELECT * FROM Methodists WHERE NOT EXISTS (
	SELECT * FROM DirectorInstructions
		JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
			WHERE Methodists.MethodistID = DirectorInstructions.MethodistID AND Statuses.Naming = '��������'
)

-- 3
-- �������� ������, � ������� ���� ������ ��������� ��� ���������
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
-- ������� ���������, ������� �� ��������� ������� ���� ���������
SELECT FIO FROM Students 
	JOIN RequestsScholarship ON Students.StudentID = RequestsScholarship.StudentID
		JOIN Statuses ON RequestsScholarship.StatusID = Statuses.StatusID
			WHERE Statuses.Naming = '�������';

-- 5
-- �������� ���������, ������� �������� ������ ���� ������� ������
SELECT FIO FROM Methodists JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
GROUP BY Methodists.FIO
	HAVING COUNT(DirectorInstructions.MethodistID) = (
		SELECT MAX(number) FROM (SELECT COUNT(DirectorInstructions.MethodistID) AS number, Methodists.FIO FROM Methodists
								 JOIN DirectorInstructions ON Methodists.MethodistID = DirectorInstructions.MethodistID
								 JOIN Statuses ON DirectorInstructions.StatusID = Statuses.StatusID
								 WHERE Statuses.Naming = '��������'
								 GROUP BY Methodists.FIO)
								 AS A
	);

-- 6
-- � ����� ������� ���� ��������, ������� ����� ������� � ������ ������
SELECT * FROM Groups WHERE EXISTS (
	SELECT * FROM Students, RequestsGroupChange
		WHERE Students.StudentID = RequestsGroupChange.StudentID
			AND Students.GroupID = Groups.GroupID
);

-- 7
-- �������� ������, � ���������� ������� ������ 2 ��������� ����
SELECT DISTINCT Groups.Naming FROM Groups
	JOIN Schedule ON Groups.GroupID = Schedule.GroupID
		GROUP BY(Groups.Naming)
		HAVING COUNT(DISTINCT Schedule.DayOfWeekID) < 5;

-- 8
-- � ����� ������ ��������� ���������� ���������, �������� �����������
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
-- �������� ��������� �� ���� ������ �� ��������� ��� ���������, �� ����������
SELECT * FROM RequestsScholarship
	JOIN Students ON Students.StudentID = RequestsScholarship.StudentID
		WHERE  RequestsScholarship.DateIssued = (
			SELECT MAX(DateIssued) FROM RequestsScholarship WHERE Students.StudentID = RequestsScholarship.StudentID
		);

-- 10
-- ��� ������ ������ ������� ���������� ��������� � ���������� ������� � ������
SELECT
	Naming,
	SUM(case when Students.SexID=1 then 1 else 0 end) AS Boys,
	SUM(case when Students.SexID=2 then 1 else 0 end) AS Girls
FROM Groups, Students
WHERE Groups.GroupID = Students.GroupID
GROUP BY(Naming)

-- 11 UNION
-- ������� ������, ��� ������� ���������� ��� ������ ����������� � ���������� ������ 1 ����
SELECT Groups.Naming FROM Groups
	JOIN Schedule ON Groups.GroupID = Schedule.GroupID
		JOIN Disciplines ON Schedule.DisciplineID = Disciplines.DisciplineID
			WHERE Disciplines.Naming = '����������'
			GROUP BY(Groups.Naming)
				HAVING COUNT(Disciplines.Naming) > 1
UNION
SELECT Groups.Naming FROM Groups
	JOIN Schedule ON Groups.GroupID = Schedule.GroupID
		JOIN Disciplines ON Schedule.DisciplineID = Disciplines.DisciplineID
			WHERE Disciplines.Naming = '������'
			GROUP BY(Groups.Naming)
				HAVING COUNT(Disciplines.Naming) > 1

-- 12 IN
-- �������� ��� ������ ���������� ������, ��������� ������� - �������
SELECT * 
FROM RequestsScholarshipM
WHERE MethodistID IN (
	SELECT MethodistID
	FROM Methodists
	JOIN Sex ON Methodists.SexID = Sex.SexID
	WHERE Sex.Naming = '�������'
)

-- 13 LEFT JOIN
-- �������� ���� ��������� � ����� �� ������� �� ���������, ���� ��� ����
SELECT *
FROM Students
LEFT JOIN ScholarshipOrders ON Students.ScholarshipOrderID = ScholarshipOrders.ScholOrderID

-- 14 EXCEPT
-- �������� �������� � �� ������ "3", ����� ���, ������� �������� �� ����������
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
WHERE Disciplines.Naming = '����������'