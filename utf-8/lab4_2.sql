USE Session;

--3.1 Выберите все направления подготовки, по которым обучаются студенты
SELECT NumDir, Title FROM Directions;

--3.2 Выберите все номера групп по всем направлениям подготовки
SELECT * FROM Directions;

--3.3 Выберите ФИО всех студентов
SELECT Fio FROM Students;

--3.4 Выберите идентификаторы всех студентов, которые получили оценки
SELECT NumSt FROM Balls;

-- Выберите номера направлений подготовки специалистов, которые включены в учебный план.
-- Напишите два варианта запроса: без DISTINCT и с использованием DISTINCT
--3.5.1 (без DISTINCT)
SELECT NumDir FROM Uplans;

--3.5.2 (с DISTINCT)
SELECT DISTINCT NumDir FROM Uplans;

--3.6 Выберите номера семестров из таблицы Uplans, удалив дубликаты строк
SELECT DISTINCT Semestr FROM Uplans;

--3.7 Выберите всех студентов группы 13504/1
SELECT Fio FROM Students WHERE NumGroup = '13504/1';

--3.8 Выберите дисциплины первого семестра для направления 230100
SELECT * FROM Uplans WHERE Semestr = 1 AND NumDir = 230100;

--3.9 Выведите номера групп с указанием количества студентов в каждой группе
SELECT NumGroup, COUNT(Fio) FROM Students GROUP BY NumGroup;

--3.10 Выведите для каждой группы количество студентов, сдававших хотя бы один экзамен
SELECT NumGroup, COUNT(Fio) FROM Students, Balls WHERE Students.NumSt = Balls.NumSt GROUP BY NumGroup;

--3.11 Выведите для каждой группы количество студентов, сдавших более одного экзамена ????????????????
SELECT NumGroup, COUNT(Fio) FROM Students, Balls WHERE Balls.NumSt = Students.NumSt GROUP BY NumGroup HAVING COUNT(Balls.NumSt) > 1;




--4.1 Выберите ФИО студентов, которые сдали экзамены
SELECT DISTINCT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.Ball > 2;

--4.2 Выберите названия дисциплин, по которым студенты сдавали экзамены
SELECT DISTINCT Name FROM Disciplines, Balls, Uplans WHERE Uplans.IdDisc = Balls.IdDisc AND Uplans.NumDisc = Disciplines.NumDisc;

--4.3 Выведите названия дисциплин по направлению 230100
SELECT DISTINCT Name FROM Disciplines, Uplans WHERE Disciplines.NumDisc = Uplans.NumDisc AND Uplans.NumDir = 230100;

--4.4 Выведите ФИО студентов, которые сдали более одного экзамена
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt GROUP BY Fio HAVING COUNT(Balls.Ball) > 1;

--4.5 Выведите ФИО студентов, получивших минимальный балл
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.Ball = (SELECT Min(Ball) FROM Balls);

--4.6 Выведите ФИО студентов, получивших максимальный балл
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.Ball = (SELECT Max(Ball) FROM Balls);

--4.7 Выведите номера групп, в которые есть более одного студента, сдавшего экзамен по Физике в 1 семестре ????????????????
SELECT NumGroup FROM Students, Balls, Disciplines, Uplans WHERE Balls.IdDisc = Uplans.IdDisc AND Uplans.NumDisc = 1 HAVING COUNT(Students.NumSt) > 1;

--4.8 Выведите ФИО студентов, получивших за время обучения общее количество баллов по всем предметам более 9
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt GROUP BY Fio HAVING SUM(Balls.Ball) > 9;

--4.9 Выведите семестры, по которым количество сдавших студентов более одного ????????????????
SELECT Semestr FROM Uplans, Balls WHERE Uplans.idDisc = Balls.idDisc GROUP BY Semestr HAVING COUNT(Balls.Ball) > 1;