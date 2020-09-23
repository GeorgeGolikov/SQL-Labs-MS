USE Session;

--3.1 �������� ��� ����������� ����������, �� ������� ��������� ��������
SELECT NumDir, Title FROM Directions;

--3.2 �������� ��� ������ ����� �� ���� ������������ ����������
SELECT * FROM Directions;

--3.3 �������� ��� ���� ���������
SELECT Fio FROM Students;

--3.4 �������� �������������� ���� ���������, ������� �������� ������
SELECT NumSt FROM Balls;

-- �������� ������ ����������� ���������� ������������, ������� �������� � ������� ����.
-- �������� ��� �������� �������: ��� DISTINCT � � �������������� DISTINCT
--3.5.1 (��� DISTINCT)
SELECT NumDir FROM Uplans;

--3.5.2 (� DISTINCT)
SELECT DISTINCT NumDir FROM Uplans;

--3.6 �������� ������ ��������� �� ������� Uplans, ������ ��������� �����
SELECT DISTINCT Semestr FROM Uplans;

--3.7 �������� ���� ��������� ������ 13504/1
SELECT Fio FROM Students WHERE NumGroup = 1;

--3.8 �������� ���������� ������� �������� ��� ����������� 230100
SELECT * FROM Uplans WHERE Semestr = 1 AND NumDir = 23001;

--3.9 �������� ������ ����� � ��������� ���������� ��������� � ������ ������
SELECT NumGroup, COUNT(Fio) FROM Students GROUP BY NumGroup;

--3.10 �������� ��� ������ ������ ���������� ���������, ��������� ���� �� ���� �������
SELECT NumGroup, COUNT(Fio) FROM Students, Balls WHERE Students.NumSt = Balls.NumSt GROUP BY NumGroup;

--3.11 �������� ��� ������ ������ ���������� ���������, ������� ����� ������ �������� ????????????????
SELECT NumGroup, COUNT(Fio) FROM Students, Balls WHERE Balls.NumSt = Students.NumSt GROUP BY NumGroup HAVING COUNT(Balls.NumSt) > 1;




--4.1 �������� ��� ���������, ������� ����� ��������
SELECT DISTINCT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.Ball > 2;

--4.2 �������� �������� ���������, �� ������� �������� ������� ��������
SELECT DISTINCT Name FROM Disciplines, Balls, Uplans WHERE Uplans.IdDisc = Balls.IdDisc AND Uplans.NumDisc = Disciplines.NumDisc;

--4.3 �������� �������� ��������� �� ����������� 230100
SELECT DISTINCT Name FROM Disciplines, Uplans WHERE Disciplines.NumDisc = Uplans.NumDisc AND Uplans.NumDir = 230100;

--4.4 �������� ��� ���������, ������� ����� ����� ������ ��������
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt GROUP BY Fio HAVING COUNT(Balls.Ball) > 1;

--4.5 �������� ��� ���������, ���������� ����������� ����
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.Ball = (SELECT Min(Ball) FROM Balls);

--4.6 �������� ��� ���������, ���������� ������������ ����
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt AND Balls.Ball = (SELECT Max(Ball) FROM Balls);

--4.7 �������� ������ �����, � ������� ���� ����� ������ ��������, �������� ������� �� ������ � 1 �������� ????????????????
SELECT NumGroup FROM Students, Balls, Disciplines, Uplans WHERE Balls.IdDisc = Uplans.IdDisc AND Uplans.NumDisc = 1 HAVING COUNT(Students.NumSt) > 1;

--4.8 �������� ��� ���������, ���������� �� ����� �������� ����� ���������� ������ �� ���� ��������� ����� 9
SELECT Fio FROM Students, Balls WHERE Students.NumSt = Balls.NumSt GROUP BY Fio HAVING SUM(Balls.Ball) > 9;

--4.9 �������� ��������, �� ������� ���������� ������� ��������� ����� ������ ????????????????
SELECT Semestr FROM Uplans, Balls WHERE Uplans.idDisc = Balls.idDisc GROUP BY Semestr HAVING COUNT(Balls.Ball) > 1;