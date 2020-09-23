USE Session;

--3.1 Выберите направления, в которых есть студенты, которые сдали экзамены (сдали хотя бы по одному экзамену)
SELECT DISTINCT Title FROM
	Directions
		JOIN Groups ON Directions.NumDir = Groups.NumDir
			JOIN Students ON Groups.NumGroup = Students.NumGroup
				JOIN Balls ON Students.NumSt = Balls.NumSt;

--3.1 Выберите направления, в которых есть студенты, которые сдали экзамены (сдали все экзамены)
SELECT Title FROM Directions JOIN (SELECT NumSt, NumDir, COUNT(Ball) AS Number_of_exams
	FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc
	GROUP BY NumSt, NumDir
		HAVING COUNT(Ball)=(SELECT COUNT(*) FROM Uplans u WHERE
		Uplans.NumDir=u.NumDir)) AS StudentsAllExams ON Directions.NumDir = StudentsAllExams.NumDir;

--3.2 Выберите наименования дисциплин первого семестра
SELECT DISTINCT Name FROM Disciplines JOIN Uplans ON Disciplines.NumDisc = Uplans.NumDisc WHERE Semestr = 1;

--3.3 Выберите номера групп, в которых есть студенты, сдавшие хотя бы один экзамен
SELECT DISTINCT NumGroup FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt;

--3.4 Выведите наименования дисциплин с указанием идентификатора студента, если он сдал экзамен
SELECT NumSt, Name FROM
	Balls
		JOIN Uplans ON Balls.IdDisc = Uplans.IdDisc 
			JOIN Disciplines ON Uplans.NumDisc = Disciplines.NumDisc
ORDER BY NumSt;

--3.5 Выберите номера групп, в которых есть свободные места
SELECT DISTINCT Groups.NumGroup FROM
	Groups
		JOIN Students ON Groups.NumGroup = Students.NumGroup
			WHERE Quantity > (SELECT COUNT(Fio) FROM Students s WHERE Students.NumGroup = s.NumGroup);

--3.6 Выберите номера групп, в которых есть студенты, сдавшие больше одного экзамена, добавив к ним номера групп, в которых есть студенты, которые ничего не сдали

-- студенты, сдавшие больше одного экзамена
SELECT Fio, COUNT(Ball) FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt
GROUP BY Fio
	HAVING COUNT(Ball) > 1;

-- номера групп, в которых есть студенты, сдавшие больше одного экзамена
SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT Fio, COUNT(Ball) AS NumberOfExamsPassed FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt
			  GROUP BY Fio
				  HAVING COUNT(Ball) > 1) AS st ON Students.Fio = st.Fio;

-- студенты, которые ничего не сдали
SELECT NumSt FROM Students
EXCEPT
SELECT NumSt FROM Balls

-- номера групп, в которых есть студенты, которые ничего не сдали
SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT NumSt FROM Students
			  EXCEPT
			  SELECT NumSt FROM Balls) AS st ON Students.NumSt = st.NumSt;

-- объединение (ИТОГ)
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

--3.7 Выберите дисциплины, которые есть и в первом и во втором семестре
SELECT Name FROM Disciplines JOIN Uplans ON Disciplines.NumDisc = Uplans.NumDisc WHERE Semestr = 1
INTERSECT
SELECT Name FROM Disciplines JOIN Uplans ON Disciplines.NumDisc = Uplans.NumDisc WHERE Semestr = 2;

--3.8. Придумайте запрос, который использует операцию соединения по неравенству
-- группы в кт есть свободные места
SELECT * FROM Groups
JOIN Directions ON Groups.Quantity < Directions.Quantity;

--3.9. Придумайте запрос, который использует операцию внешнего соединения справа, предварительно подготовив тестовые данные.
-- студенты и экзамены, которые они сдавали
SELECT DISTINCT FIO, Ball, DateEx, IdDisc FROM Balls
RIGHT JOIN Students ON Balls.NumSt = Students.NumSt

--3.10 Придумайте запрос с группировкой и соединением нескольких таблиц
-- вывести студентов, которые сдали все экзамены за все семестры(c учетом того, что могли быть пересдачи)
SELECT NumSt, NumDir, COUNT(DISTINCT Balls.IdDisc) AS Number_of_exams
	FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc
	GROUP BY NumSt, NumDir
		HAVING COUNT(DISTINCT Balls.IdDisc)=(SELECT COUNT(*) FROM Uplans u WHERE
		Uplans.NumDir=u.NumDir);


-- вывести студентов, которые сдали все экзамены 1 семестра
SELECT NumSt, NumDir, COUNT(Ball) AS Number_of_exams
	FROM Balls JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc WHERE Semestr=1
	GROUP BY NumSt, NumDir
		HAVING COUNT(Ball)=(SELECT COUNT(*) FROM Uplans u WHERE
		Uplans.NumDir=u.NumDir and semestr=1);

-- вывести студентов, которые сдали все экзамены 1 семестра с использованием NOT EXISTS
SELECT NumSt, Fio, Groups.NumGroup
	FROM Students JOIN Groups ON Groups.NumGroup=Students.NumGroup
	WHERE NOT EXISTS (SELECT * FROM Uplans WHERE Semestr=1 AND Groups.NumDir=Uplans.NumDir
	AND NOT EXISTS (SELECT * FROM Balls WHERE Balls.IdDisc=Uplans.IdDisc
	AND Students.NumSt=Balls.NumSt));



--4.1 Выберите студентов, которые сдали только одну дисциплину(экзамен)
-- студенты, сдавшие один или меньше экзаменов
SELECT * FROM Students WHERE NOT EXISTS (
	SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
	HAVING COUNT(Ball) > 1
)
INTERSECT
-- студенты, которые сдали хотя бы один экзамен
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

--4.2 Выбрать студентов, которые не сдали ни одного экзамена
SELECT * FROM Students WHERE NOT EXISTS (
	SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
);

--4.3 Выберите группы, в которых есть студенты, сдавшие все экзамены 1 семестра
SELECT DISTINCT NumGroup FROM
	Students
		JOIN (SELECT NumSt
				FROM Students JOIN Groups ON Groups.NumGroup=Students.NumGroup
				WHERE NOT EXISTS (SELECT * FROM Uplans WHERE Semestr=1 AND Groups.NumDir=Uplans.NumDir
				AND NOT EXISTS (SELECT * FROM Balls WHERE Balls.IdDisc=Uplans.IdDisc AND Students.NumSt=Balls.NumSt)))
		AS st ON Students.NumSt = st.NumSt;

--4.4 Выберите группы, в которых есть студенты, которые не сдали ни одной дисциплины
-- это те кто не сдал вообще ни одного экзамена
SELECT DISTINCT Students.NumGroup FROM
	Students
		JOIN (SELECT * FROM Students WHERE NOT EXISTS (
				SELECT * FROM Balls WHERE Students.NumSt = Balls.NumSt
				))
		AS st ON Students.NumSt = st.NumSt;
-- к ним прибавляем тех, кто сдал только часть дисциплины(1 семестр)

--4.5 Выбрать дисциплины, которые не попали в учебный план направления 231000
SELECT * FROM Disciplines
WHERE NOT EXISTS (SELECT * FROM Uplans WHERE Uplans.NumDisc = Disciplines.NumDisc AND NumDir = 231000)

--4.6 Выбрать дисциплины, которые не сдали все студенты направления 231000
SELECT * FROM Disciplines
JOIN Uplans ON Uplans.NumDisc = Disciplines.NumDisc AND Uplans.NumDir = 231000
WHERE NOT EXISTS (
	SELECT * FROM Balls
	JOIN Students ON Students.NumSt = Balls.NumSt
	JOIN Groups ON Groups.NumGroup = Students.NumGroup AND Groups.NumDir = 231000
)

--4.7 Выбрать группы, в которых все студенты сдали физику
-- студенты, которые сдавали физику
SELECT * FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND (Balls.IdDisc = 1 OR Balls.IdDisc = 2 OR Balls.IdDisc = 7 OR Balls.IdDisc = 10)

-- Выбрать группы, в которых все студенты сдали физику
SELECT NumGroup FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.IdDisc IN (SELECT IdDisc FROM Uplans WHERE NumDisc = 1)
GROUP BY Students.NumGroup
HAVING COUNT(Fio) = (SELECT Quantity FROM Groups WHERE NumGroup = Students.NumGroup)

--4.8 Выбрать группы, в которых все студенты сдали все дисциплины 1 семестра
SELECT NumGroup FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.IdDisc IN (SELECT IdDisc FROM Uplans WHERE Semestr = 1)
GROUP BY Students.NumGroup
HAVING COUNT(DISTINCT Fio) = (SELECT Quantity FROM Groups WHERE NumGroup = Students.NumGroup)

--4.9 Выбрать студентов, которые сдали все экзамены на хорошо и отлично
SELECT * FROM Students
WHERE NOT EXISTS (SELECT Ball FROM Balls WHERE Students.NumSt = Balls.NumSt AND Ball <= 3) AND
EXISTS (SELECT Ball FROM Balls WHERE Students.NumSt = Balls.NumSt)

--4.10 Выбрать студентов, которые сдали наибольшее количество экзаменов
SELECT FIO FROM Students JOIN Balls ON Students.NumSt = Balls.NumSt
GROUP BY Students.FIO
	HAVING COUNT(Ball) = (
		SELECT MAX(number) FROM (SELECT COUNT(Balls.Ball) AS number, Students.FIO FROM Students
								 JOIN Balls ON Balls.NumSt = Students.NumSt
								 GROUP BY Students.FIO)
								 AS A
	);