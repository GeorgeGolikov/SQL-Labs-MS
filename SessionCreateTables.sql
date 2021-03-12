USE Session;

CREATE TABLE Directions (
	NumDir int PRIMARY KEY,
	Title varchar(70) NOT NULL,
	Quantity tinyint CHECK (Quantity BETWEEN 0 AND 20)
)

DROP TABLE Groups;
--NumGroup varchar(10) PRIMARY KEY
CREATE TABLE Groups (
	NumGroup int IDENTITY(1,1) PRIMARY KEY,
	NumDir int FOREIGN KEY REFERENCES Directions
	ON UPDATE CASCADE,
	--NumSt int FOREIGN KEY REFERENCES Students
	--ON DELETE SET NULL,
	Quantity tinyint CHECK (Quantity BETWEEN 0 AND 20)
)

CREATE TABLE Students (
	NumSt int IDENTITY (1,1) PRIMARY KEY,
	Fio varchar(50) NOT NULL,
	NumGroup int FOREIGN KEY REFERENCES Groups --NumGroup varchar(10)
	ON DELETE SET NULL
	ON UPDATE CASCADE
)

ALTER TABLE Groups
	ADD fk_NumSt int FOREIGN KEY
	REFERENCES Students (NumSt);

CREATE TABLE Disciplines (
	NumDisc int IDENTITY (1,1) PRIMARY KEY,
	Name varchar(70) NOT NULL
)

CREATE TABLE Uplans (
	IdDisc int IDENTITY (1,1) PRIMARY KEY,
	NumDir int FOREIGN KEY REFERENCES Directions
	ON UPDATE CASCADE,
	NumDisc int FOREIGN KEY REFERENCES Disciplines,
	Semestr tinyint CHECK (Semestr BETWEEN 1 AND 12)
)

CREATE TABLE Balls (
	IdBall int IDENTITY (1,1) PRIMARY KEY,
	IdDisc int FOREIGN KEY REFERENCES Uplans
	ON DELETE SET NULL
	ON UPDATE CASCADE,
	NumSt int FOREIGN KEY REFERENCES Students,
	Ball tinyint CHECK (Ball BETWEEN 2 AND 5),
	DateEx date NOT NULL
)
