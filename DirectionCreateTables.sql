USE Direction;

DROP TABLE IF EXISTS Sex
CREATE TABLE Sex (
	SexID int PRIMARY KEY NOT NULL,
	Naming varchar(10) NOT NULL
)

DROP TABLE IF EXISTS Groups
CREATE TABLE Groups (
	GroupID int PRIMARY KEY NOT NULL,
	Naming varchar(20) NOT NULL
	--ElderID int FOREIGN KEY REFERENCES Students
	--ON DELETE SET NULL
)

DROP TABLE IF EXISTS ScholarshipOrders
CREATE TABLE ScholarshipOrders (
	ScholOrderID int PRIMARY KEY NOT NULL,
	Naming varchar(30) NOT NULL,
	Summ int NOT NULL,
	DateStarted date,
	OrderName varchar(20) NOT NULL
)

DROP TABLE IF EXISTS Students
CREATE TABLE Students (
	StudentID int PRIMARY KEY NOT NULL,
	FIO varchar(70) NOT NULL,
	Birthday date,
	SexID int FOREIGN KEY REFERENCES Sex
		ON UPDATE CASCADE,
	GroupID int FOREIGN KEY REFERENCES Groups
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ScholarshipOrderID int FOREIGN KEY REFERENCES ScholarshipOrders
		ON DELETE SET NULL
		ON UPDATE CASCADE
)

ALTER TABLE Groups
	ADD ElderID int FOREIGN KEY
	REFERENCES Students (StudentID);



CREATE TABLE Methodists (
	MethodistID int PRIMARY KEY NOT NULL,
	FIO varchar(70) NOT NULL,
	Birthday date,
	SexID int FOREIGN KEY REFERENCES Sex
		ON UPDATE CASCADE,
	Salary int
)


CREATE TABLE Disciplines (
	DisciplineID int PRIMARY KEY NOT NULL,
	Naming varchar(50) NOT NULL
)

DROP TABLE IF EXISTS ClassesTypes
CREATE TABLE ClassesTypes (
	TypeID int PRIMARY KEY NOT NULL,
	Naming varchar(20) NOT NULL
)

DROP TABLE IF EXISTS Dayss
CREATE TABLE Dayss (
	DayID int PRIMARY KEY NOT NULL,
	DayNaming varchar(15) NOT NULL
)

DROP TABLE IF EXISTS Schedule
CREATE TABLE Schedule (
	ItemID int PRIMARY KEY NOT NULL,
	DayOfWeekID int FOREIGN KEY REFERENCES Dayss
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	DisciplineID int FOREIGN KEY REFERENCES Disciplines
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	TimeLine varchar(20),
	GroupID int FOREIGN KEY REFERENCES Groups
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	Room int,
	TypeID int FOREIGN KEY REFERENCES ClassesTypes
		ON DELETE SET NULL
		ON UPDATE CASCADE
)


CREATE TABLE Statuses (
	StatusID int PRIMARY KEY NOT NULL,
	Naming varchar(10) NOT NULL
)

CREATE TABLE DirectorInstructions (
	InstructionID int PRIMARY KEY NOT NULL,
	MethodistID int FOREIGN KEY REFERENCES Methodists
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	StudentID int FOREIGN KEY REFERENCES Students,
	Summ int NOT NULL,
	Cause varchar(100),
	DateIssued date NOT NULL,
	DateCompleted date,
	StatusID int FOREIGN KEY REFERENCES Statuses
		ON DELETE SET NULL
		ON UPDATE CASCADE
)

CREATE TABLE RequestsScholarship (
	RequestID int PRIMARY KEY NOT NULL,
	StudentID int FOREIGN KEY REFERENCES Students
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	Summ int NOT NULL,
	Cause varchar(100),
	DateIssued date NOT NULL,
	DateAcceptedOrRejected date,
	StatusID int FOREIGN KEY REFERENCES Statuses
		ON DELETE SET NULL
		ON UPDATE CASCADE
)

CREATE TABLE RequestsScholarshipM (
	RequestID int PRIMARY KEY NOT NULL,
	MethodistID int FOREIGN KEY REFERENCES Methodists
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	StudentID int FOREIGN KEY REFERENCES Students,
	Summ int NOT NULL,
	Cause varchar(100),
	DateIssued date NOT NULL,
	DateAcceptedOrRejected date,
	StatusID int FOREIGN KEY REFERENCES Statuses
		ON DELETE SET NULL
		ON UPDATE CASCADE
)

CREATE TABLE RequestsDropOut (
	RequestID int PRIMARY KEY NOT NULL,
	StudentID int FOREIGN KEY REFERENCES Students
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	Cause varchar(100),
	DateIssued date NOT NULL,
	DateAcceptedOrRejected date,
	StatusID int FOREIGN KEY REFERENCES Statuses
		ON DELETE SET NULL
		ON UPDATE CASCADE
)

CREATE TABLE RequestsGroupChange (
	RequestID int PRIMARY KEY NOT NULL,
	StudentID int FOREIGN KEY REFERENCES Students,
	OldGroupID int FOREIGN KEY REFERENCES Groups,
	NewGroupID int FOREIGN KEY REFERENCES Groups,
	Cause varchar(100),
	DateIssued date NOT NULL,
	DateAcceptedOrRejected date,
	StatusID int FOREIGN KEY REFERENCES Statuses
		ON DELETE SET NULL
		ON UPDATE CASCADE
)

DROP TABLE IF EXISTS Grades
CREATE TABLE Grades (
	GradeID int PRIMARY KEY NOT NULL,
	DisciplineID int NOT NULL FOREIGN KEY REFERENCES Disciplines,
	StudentID int NOT NULL FOREIGN KEY REFERENCES Students,
	Valuee float NOT NULL 
)