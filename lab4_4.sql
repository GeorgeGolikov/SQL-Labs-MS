 --1. Пример создания и использования представления для выборки  названий дисциплин, 
 --по которым хотя бы одним студентом была получена оценка 
USE Session;
GO
CREATE VIEW Disciplines_with_balls AS
	SELECT Distinct Name FROM Disciplines INNER JOIN Uplans ON Disciplines.NumDisc=Uplans.NumDisc
										  INNER JOIN Balls ON Uplans.IdDisc=Balls.IdDisc;
GO
SELECT * FROM Disciplines_with_balls;

--2. Пример создания и использования представления c использованием реляционных операций для выборки студентов,
-- которые получили пятерки и которые вообще ничего не сдали
GO
CREATE VIEW Students_top_and_last (Fio, Complete) AS 
(SELECT A.Stud, 'NO' FROM (SELECT NumSt AS Stud  FROM Students EXCEPT Select Distinct NumSt AS Stud FROM Balls)AS A)
UNION
 (SELECT NumSt, 'Five'  FROM Balls WHERE Ball=5);
GO
SELECT * FROM Students_top_and_last;

--3. Пример создания и использования представления с использованием агрегатных функций, 
-- группировки и подзапросов для вывода студентов, которые сдали все экзамены первого семестра
GO
CREATE VIEW Students_complete (Fio, Direction, Numer_of_balls) AS 
	SELECT NumSt, NumDir, COUNT(Ball) FROM Balls 
	JOIN Uplans ON Balls.IdDisc=Uplans.IdDisc WHERE Semestr=1 
	GROUP BY NumSt, NumDir HAVING Count(Ball)=(SELECT COUNT( *) FROM Uplans u WHERE Uplans.NumDir=u.NumDir and semestr=1);
GO
SELECT * FROM Students_complete;

--4 Пример создания и использования представления с использованием 
-- предиката NOT EXISTS для вывода номеров студентов,которые сдали все экзамены своего курса 
GO
CREATE VIEW Students_complete_2 AS
	SELECT Students.NumSt FROM Students JOIN Groups ON Groups.NumGroup = Students.NumGroup
		WHERE NOT EXISTS (SELECT * FROM Uplans WHERE (Semestr=CONVERT(int, LEFT(Students.NumGroup,1))*2-1 OR
			Semestr=CONVERT(int, LEFT(Students.NumGroup,1))*2) AND
			Groups.NumDir=Uplans.NumDir AND NOT EXISTS (SELECT * FROM Balls
			WHERE Balls.IdDisc=Uplans.IdDisc and Students.NumSt=Balls.NumSt) );
GO
SELECT * FROM Students_complete_2; 

-- 1. Пример создания процедуры без параметров. Создаем процедуру для подсчета общего количества студентов
GO
CREATE PROCEDURE Count_Students AS
SELECT COUNT(*) FROM Students

Count_Students;

-- 2. Пример создания процедуры c входным параметром.
-- Создаем процедуру для подсчета студентов, сдавших хотя бы один экзамен в заданном семестре
GO
CREATE PROCEDURE Count_Students_Sem @Count_sem AS INT
AS
SELECT COUNT(Distinct NumSt) FROM Balls JOIN Uplans ON Uplans.IdDisc=Balls.IdDisc WHERE Semestr=@Count_sem;
GO 

DECLARE @kol int;
SET @kol=2;
EXEC Count_Students_Sem @kol;

--3. Пример создания процедуры c несколькими входными параметрами.

--3.1. Создаем процедуру для получения списка студентов указанного направления, сдавших экзамен по  указанной дисциплине
GO
CREATE PROCEDURE List_Students_Dir (@Dir AS INT, @Disc AS VARCHAR(30))
AS
SELECT Distinct Students.FIO FROM Groups 
	JOIN Students ON Groups.NumGroup=Students.NumGroup 
	JOIN Balls ON Students.NumSt=Balls.NumSt 
	JOIN Uplans ON Uplans.IdDisc=Balls.IdDisc
	WHERE Groups.NumDir=@Dir AND NumDisc=(SELECT NumDisc FROM Disciplines WHERE Name=@Disc);
GO

DECLARE @dir int, @title VARCHAR(30);
SET @dir=230100;
SET @title ='Физика'
EXEC List_Students_Dir @dir,@title; 

--3.2. Создаем процедуру для ввода информации о новом студенте
GO
CREATE PROCEDURE Enter_Students (@Fio AS VARCHAR(30), @Group AS VARCHAR(10))  AS
INSERT INTO Students (FIO, NumGroup) VALUES (@Fio, @Group);
GO

DECLARE @Stud VARCHAR(30), @Group VARCHAR(10);
SET @Stud='Новая Наталья';
SET @Group ='13504/3';
EXEC Enter_Students  @Stud, @Group;

DECLARE @Stud VARCHAR(30), @Group VARCHAR(10);
SET @Stud='Светлова Вероника';
SET @Group ='13504/3';
EXEC Enter_Students  @Stud, @Group;

--4. Пример создания процедуры с входными параметрами и значениями по умолчанию. ?????????????????
--Создать процедуру для перевода студентов указанной группы на следующий курс
--Добавьте в таблицу Groups новые записи с группами 23504/3 и 23504/1
GO
CREATE PROCEDURE Next_Course (@Group AS VARCHAR(10)='13504/1')
AS
UPDATE Students SET NumGroup=CONVERT(char(1),CONVERT(int, LEFT(NumGroup,1))+1)+ SUBSTRING(NumGroup,2,LEN(NumGroup)-1)
 WHERE NumGroup=@Group;
GO

--Для обращения к процедуре можно использовать команды:
DECLARE @Group VARCHAR(10);
 SET @Group='13504/3';
 EXEC Next_Course @Group;
 GO

--Для использования значений по умолчанию:
EXEC Next_Course;
 GO

--!!! Напишите процедуру, которая будет возвращать старые номера групп обратно
GO
CREATE PROCEDURE Back_Course (@Group AS VARCHAR(10)='23504/1')
AS
UPDATE Students SET NumGroup=CONVERT(char(1),CONVERT(int, LEFT(NumGroup,1))-1)+ SUBSTRING(NumGroup,2,LEN(NumGroup)-1)
 WHERE NumGroup=@Group;
GO

--Для обращения к процедуре можно использовать команды:
DECLARE @Group VARCHAR(10);
 SET @Group='23504/3';
 EXEC Back_Course @Group;
 GO

--Для использования значений по умолчанию:
EXEC Back_Course;
 GO

--5. Пример создания процедуры с входными и выходными параметрами.
-- Создать процедуру для определения количества групп по указанному направлению.
CREATE PROCEDURE Number_Groups (@Dir AS int, @Number AS int OUTPUT)
AS
SELECT @Number =COUNT(NumGroup) FROM Groups WHERE NumDir=@Dir;
GO
--Получить и посмотреть результат можно следующим образом:
DECLARE @Group int;
EXEC Number_Groups 230100, @Group OUTPUT;
SELECT @Group;
 GO

-- 6. Пример создания процедуры, использующей вложенные хранимые процедуры.
-- Создать улучшенную процедуру для перевода студентов указанной группы на следующий курс.

-- Установите для ограничения внешнего ключа таблиц Balls и Students тактику каскадного удаления и обновления записей ???????

-- Создадим хранимую процедуру для сохранения данных о закончивших обучение студентах в архиве
-- и удаления информации о них из основной таблицы студентов.
CREATE PROCEDURE Delete_Students_Complete
AS
INSERT INTO ArchiveStudents SELECT YEAR(GETDATE()), NumSt, FIO, NumGroup FROM Students WHERE LEFT(NumGroup,1)=6;
DELETE FROM Students WHERE LEFT(NumGroup,1)=6;
GO

-- Создадим хранимую процедуру для перевода студентов на следующий курс
-- и удаления из базы данных информации о закончивших обучение студентах.
-- Students_complete_2 - это представление студентов, сдавших все экзамены своего курса
CREATE PROCEDURE Next_Course_2
AS
EXEC Delete_Students_Complete;
UPDATE Students SET NumGroup=CONVERT(char(1),CONVERT(int, LEFT(NumGroup,1))+1)+ SUBSTRING(NumGroup,2,LEN(NumGroup)-1)
WHERE NumSt IN (SELECT NumSt FROM Students_complete_2);
GO

-- Для обращения к процедуре можно использовать команду:
EXEC Next_Course_2;
GO

-- Напишите обратную процедуру восстановления студентов из архивной таблицы в основную
CREATE PROCEDURE Return_Students_Complete
AS
INSERT INTO Students SELECT FIO, NumGroup FROM ArchiveStudents;
DELETE FROM ArchiveStudents;
GO

EXEC Return_Students_Complete;
GO