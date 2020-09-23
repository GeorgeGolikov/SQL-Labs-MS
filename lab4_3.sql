USE Session;

--3.1 �������� �����������, � ������� ���� ��������, ������� ����� �������� (����� ���� �� �� ������ ��������)
SELECT DISTINCT Title FROM
	Directions
		JOIN Groups ON Directions.NumDir = Groups.NumDir
			JOIN Students ON Groups.NumGroup = Students.NumGroup
				JOIN Balls ON Students.NumSt = Balls.NumSt;

--3.1 �������� �����������, � ������� ���� ��������, ������� ����� �������� (����� ��� ��������)
SELECT Title FROM Directions JOIN (SELECT NumSt, NumDir, COUNT(Ball) AS Number_of_exams
	FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc
	GROUP BY NumSt, NumDir
		HAVING COUNT(Ball)=(SELECT COUNT(*) FROM Uplans u WHERE
		Uplans.NumDir=u.NumDir)) AS StudentsAllExams ON Directions.NumDir = StudentsAllExams.NumDir;

--3.2 �������� ������������ ��������� ������� ��������
SELECT DISTINCT Name FROM Disciplines JOIN Uplans ON Disciplines.NumDisc = Uplans.NumDisc WHERE Semestr = 1;

--3.3 �������� ������ �����, � ������� ���� ��������, ������� ���� �� ���� �������
SELECT DISTINCT NumGroup FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt;

--3.4 �������� ������������ ��������� � ��������� �������������� ��������, ���� �� ���� �������
SELECT NumSt, Name FROM
	Balls
		JOIN Uplans ON Balls.IdDisc = Uplans.IdDisc 
			JOIN Disciplines ON Uplans.NumDisc = Disciplines.NumDisc
ORDER BY NumSt;

--3.5 �������� ������ �����, � ������� ���� ��������� �����
SELECT DISTINCT Groups.NumGroup FROM
	Groups
		JOIN Students ON Groups.NumGroup = Students.NumGroup
			WHERE Quantity > (SELECT COUNT(Fio) FROM Students s WHERE Students.NumGroup = s.NumGroup);

--3.6 �������� ������ �����, � ������� ���� ��������, ������� ������ ������ ��������, ������� � ��� ������ �����, � ������� ���� ��������, ������� ������ �� �����

-- ��������, ������� ������ ������ ��������
SELECT Fio, COUNT(Ball) FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt
GROUP BY Fio
	HAVING COUNT(Ball) > 1;

-- ������ �����, � ������� ���� ��������, ������� ������ ������ ��������
SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT Fio, COUNT(Ball) AS NumberOfExamsPassed FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt
			  GROUP BY Fio
				  HAVING COUNT(Ball) > 1) AS st ON Students.Fio = st.Fio;

-- ��������, ������� ������ �� �����
SELECT NumSt FROM Students
EXCEPT
SELECT NumSt FROM Balls

-- ������ �����, � ������� ���� ��������, ������� ������ �� �����
SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT NumSt FROM Students
			  EXCEPT
			  SELECT NumSt FROM Balls) AS st ON Students.NumSt = st.NumSt;

-- ����������� (����)
(SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT Fio, COUNT(Ball) AS NumberOfExamsPassed FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt
			  GROUP BY Fio
				  HAVING COUNT(Ball) > 1) AS st ON Students.Fio = st.Fio)
UNION
(SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT NumSt FROM Students
			  EXCEPT
			  SELECT NumSt FROM Balls) AS st ON Students.NumSt = st.NumSt);

--3.7 �������� ����������, ������� ���� � � ������ � �� ������ ��������
SELECT Name FROM Disciplines JOIN Uplans ON Disciplines.NumDisc = Uplans.NumDisc WHERE Semestr = 1
INTERSECT
SELECT Name FROM Disciplines JOIN Uplans ON Disciplines.NumDisc = Uplans.NumDisc WHERE Semestr = 2;

--3.8. ���������� ������, ������� ���������� �������� ���������� �� �����������
-- ������ � �� ���� ��������� �����
SELECT * FROM Groups
JOIN Directions ON Groups.Quantity < Directions.Quantity;

--3.9. ���������� ������, ������� ���������� �������� �������� ���������� ������, �������������� ���������� �������� ������.
-- �������� � ��������, ������� ��� �������
SELECT DISTINCT FIO, Ball, DateEx, IdDisc FROM Balls
RIGHT JOIN Students ON Balls.NumSt = Students.NumSt

--3.10 ���������� ������ � ������������ � ����������� ���������� ������
-- ������� ���������, ������� ����� ��� �������� �� ��� ��������(c ������ ����, ��� ����� ���� ���������)
SELECT NumSt, NumDir, COUNT(DISTINCT Balls.IdDisc) AS Number_of_exams
	FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc
	GROUP BY NumSt, NumDir
		HAVING COUNT(DISTINCT Balls.IdDisc)=(SELECT COUNT(*) FROM Uplans u WHERE
		Uplans.NumDir=u.NumDir);


-- ������� ���������, ������� ����� ��� �������� 1 ��������
SELECT NumSt, NumDir, COUNT(Ball) AS Number_of_exams
	FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc WHERE Semestr=1
	GROUP BY NumSt, NumDir
		HAVING COUNT(Ball)=(SELECT COUNT(*) FROM Uplans u WHERE
		Uplans.NumDir=u.NumDir and semestr=1);

-- ������� ���������, ������� ����� ��� �������� 1 �������� � �������������� NOT EXISTS
SELECT NumSt, Fio, Groups.NumGroup
	FROM Students JOIN Groups ON Groups.NumGroup=Students.NumGroup
	WHERE NOT EXISTS (SELECT * FROM Uplans WHERE Semestr=1 AND Groups.NumDir=Uplans.NumDir
	AND NOT EXISTS (SELECT * FROM Balls WHERE Balls.IdDisc=Uplans.IdDisc
	AND Students.NumSt=Balls.NumSt));



--4.1 �������� ���������, ������� ����� ������ ���� ����������(�������)
-- ��������, ������� ���� ��� ������ ���������
SELECT * FROM Students WHERE NOT EXISTS (
	SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
	HAVING COUNT(Ball) > 1
)
INTERSECT
-- ��������, ������� ����� ���� �� ���� �������
SELECT * FROM Students WHERE EXISTS (
	SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
);

SELECT * FROM Students WHERE EXISTS ( -- OK
	SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
	HAVING COUNT(Ball) = 1
);

SELECT * FROM Students WHERE EXISTS ( -- ????
	SELECT * FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc
	WHERE Students.NumSt = Balls.NumSt
	HAVING COUNT(Ball) = (SELECT COUNT(NumDisc) FROM Uplans u WHERE
		Uplans.NumDir=u.NumDir)
);

SELECT * FROM Students WHERE EXISTS ( -- ????
	SELECT Ball FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc
	WHERE Students.NumSt = Balls.NumSt
	GROUP BY Ball, Uplans.NumDir
		HAVING COUNT(Ball) = (SELECT COUNT(NumDisc) FROM Uplans u WHERE
								Uplans.NumDir=u.NumDir)
);

--4.2 ������� ���������, ������� �� ����� �� ������ ��������
SELECT * FROM Students WHERE NOT EXISTS (
	SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
);

--4.3 �������� ������, � ������� ���� ��������, ������� ��� �������� 1 ��������
SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT NumSt
				FROM Students JOIN Groups ON Groups.NumGroup=Students.NumGroup
				WHERE NOT EXISTS (SELECT * FROM Uplans WHERE Semestr=1 AND Groups.NumDir=Uplans.NumDir
				AND NOT EXISTS (SELECT * FROM Balls WHERE Balls.IdDisc=Uplans.IdDisc AND Students.NumSt=Balls.NumSt)))
		AS st ON Students.NumSt = st.NumSt;

--4.4 �������� ������, � ������� ���� ��������, ������� �� ����� �� ����� ����������
-- ��� �� ��� �� ���� ������ �� ������ ��������
SELECT DISTINCT Students.NumGroup FROM
	Students
		JOIN (SELECT * FROM Students WHERE NOT EXISTS (
				SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
				))
		AS st ON Students.NumSt = st.NumSt;
-- � ��� ���������� ���, ��� ���� ������ ����� ����������(1 �������)

--4.5 ������� ����������, ������� �� ������ � ������� ���� ����������� 231000
SELECT * FROM Disciplines
WHERE NOT EXISTS (SELECT * FROM Uplans WHERE Uplans.NumDisc = Disciplines.NumDisc AND NumDir = 231000)

--4.6 ������� ����������, ������� �� ����� ��� �������� ����������� 231000
SELECT * FROM Disciplines
JOIN Uplans ON Uplans.NumDisc = Disciplines.NumDisc AND Uplans.NumDir = 231000
WHERE NOT EXISTS (
	SELECT * FROM Balls
	JOIN Students ON Students.NumSt = Balls.NumSt
	JOIN Groups ON Groups.NumGroup = Students.NumGroup AND Groups.NumDir = 231000
)

--4.7 ������� ������, � ������� ��� �������� ����� ������
-- ��������, ������� ������� ������
SELECT * FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND (Balls.IdDisc = 1 OR Balls.IdDisc = 2 OR Balls.IdDisc = 7 OR Balls.IdDisc = 10)

-- ������� ������, � ������� ��� �������� ����� ������
SELECT NumGroup FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.IdDisc IN (SELECT IdDisc FROM Uplans WHERE NumDisc = 1)
GROUP BY Students.NumGroup
HAVING COUNT(Fio) = (SELECT Quantity FROM Groups WHERE NumGroup = Students.NumGroup)

--4.8 ������� ������, � ������� ��� �������� ����� ��� ���������� 1 ��������
SELECT NumGroup FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.IdDisc IN (SELECT IdDisc FROM Uplans WHERE Semestr = 1)
GROUP BY Students.NumGroup
HAVING COUNT(DISTINCT Fio) = (SELECT Quantity FROM Groups WHERE NumGroup = Students.NumGroup)

--4.9 ������� ���������, ������� ����� ��� �������� �� ������ � �������
SELECT * FROM Students
WHERE NOT EXISTS (SELECT Ball FROM Balls WHERE Students.NumSt = Balls.NumSt AND Ball <= 3) AND
EXISTS (SELECT Ball FROM Balls WHERE Students.NumSt = Balls.NumSt)

--4.10 ������� ���������, ������� ����� ���������� ���������� ���������
SELECT FIO FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt
GROUP BY Students.FIO
	HAVING COUNT(Ball) = (
		SELECT MAX(number) FROM (SELECT COUNT(Balls.Ball) AS number, Students.FIO FROM Students
								 JOIN Balls ON Balls.NumSt = Students.NumSt
								 GROUP BY Students.FIO)
								 AS A
	);