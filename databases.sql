--�������� �������
CREATE DATABASE BeautySaloon
CONTAINMENT = NONE
ON PRIMARY ( --��������� ���� 
NAME = N'Beauty Saloon', --���������� ��� ����� ��
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\BeautySaloon_log.mdf', 
SIZE = 8192KB,
FILEGROWTH = 65536KB 
)
LOG ON ( --���� ��������� ����� �������� 
NAME = N'Beauty_Saloon_log', --���������� ��� ����� �������
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\BeautySaloon_log.ldf', 
SIZE = 8192KB,
FILEGROWTH = 65536KB ); 

--�������� ������� �������������
USE BeautySaloon 
CREATE TABLE Specials(
idSpecials int identity primary key,
specialsName varchar(50) NOT NULL
);
--�������� ������� ��������
USE BeautySaloon 
CREATE TABLE Employee(
idEmployee int identity primary key,
firstName varchar(50) NOT NULL,
lastName varchar(50) NOT NULL,
telNumber varchar(11) NOT NULL,
idSpecials int NOT NULL REFERENCES Specials(idSpecials)
);

--�������� ������� ������
USE BeautySaloon 
CREATE TABLE Client(
idClient int identity primary key,
firstName varchar(50) NOT NULL,
lastName varchar(50) NOT NULL,
telNumber varchar(11) NOT NULL,
);

--�������� ������� ������
USE BeautySaloon
CREATE TABLE Appointment(
idAppointment int identity primary key,
price int NOT NULL,
dataTime datetime,
nameService varchar(50),
idClient int NOT NULL REFERENCES Client (idClient),
idEmployee int NOT NULL REFERENCES Employee (idEmployee),
);

--���������� ������� ������� ���������������
USE BeautySaloon 
INSERT INTO Specials
VALUES
('������ ��������'),
('����������');

--���������� ������� ������� ���������
USE BeautySaloon 
INSERT INTO Employee
VALUES
	('���������','�������','+7962417820','1'),
	('�������','��������','+7034528642','1'),
	('�����','��������','+7954652585','2'),
	('������','��������','+7954200214','2'),
	('�����','���������','+7936304078','2');

--���������� ������� ������� �������
USE BeautySaloon 
INSERT INTO Client
VALUES
	('���������','��������','+7965627820'),
	('������','��������','+7034857842'),
	('�����','��������','+7954965285'),
	('������','���������','+7953021214'),
	('������','��������','+7936698548'); 

--���������� ������� ������� �������
USE BeautySaloon
INSERT INTO Appointment
VALUES
	('2000','2022-12-15T15:00:00','������� � ���������','1','1'),
	('3000','2022-12-15T12:00:00','������� � ����������� �����','2','2'),
	('4000','2022-12-21T15:00:00','�����������','1','3'),
	('2000','2022-12-21T17:00:00', '������� ���� �������','4','4'),
	('2000','2022-12-15T10:00:00','������� � ���������','3','1'),
	('2500','2022-12-19T19:00:00','������� ���� �������','5','5'),
	('6000','2022-12-24T13:00:00','�����������','2','3'); 

--��������� AddClient
CREATE PROCEDURE AddClient 
@FirstName nvarchar(50),
@LastName nvarchar(50), 	
@TelNumber nvarchar(11)
AS BEGIN 
INSERT INTO Client (
	firstName,
	lastName,
	telNumber
) 
VALUES (
	@FirstName,
	@LastName,
	@TelNumber)
END;

--��������� AddSpecial
CREATE PROCEDURE AddSpecial
@SpecialsName nvarchar(50)
AS BEGIN
INSERT INTO Specials (
	specialsName
) 
VALUES (
	@SpecialsName)
END; 

--��������� AddEmployee
CREATE PROCEDURE AddEmployee
@FirstName nvarchar(50),
@LastName nvarchar(50), 	
@TelNumber nvarchar(11),
@IdSpecials int
AS BEGIN 
IF (NOT EXISTS (SELECT * FROM Specials
where idSpecials = @IdSpecials))
THROW 51000, 'No specialization found with such ID!', 1;
INSERT INTO Employee (
	firstName,
	lastName,
	telNumber,
	idSpecials
) 
VALUES (
	@FirstName,
	@LastName,
	@TelNumber,
	@IdSpecials)
END;

--��������� AddAppointment
CREATE PROCEDURE AddAppointment
@Price int,
@DataTime datetime,
@NameService varchar(50),
@IdClient int,
@IdEmployee int
AS BEGIN
IF (NOT EXISTS (SELECT * FROM Employee
where idEmployee = @IdEmployee))
THROW 51000, 'No employee found with such ID!', 1;
IF (NOT EXISTS (SELECT * FROM Client
where idClient = @IdClient))
THROW 51000, 'No client found with such ID!', 1;
INSERT INTO Appointment (
	price,
	dataTime,
	nameService,
	idClient,
	idEmployee
) 
VALUES (
	@Price,
	@DataTime,
	@NameService,
	@IdClient,
	@IdEmployee)
END;

--������� ServicesByEmployee
CREATE FUNCTION dbo.ServicesByEmployee(@IdEmployee int)
RETURNS TABLE
AS 
RETURN (
SELECT CONCAT(Client.firstName,' ', Client.lastName) AS Client_FIO,
Appointment.dataTime, Appointment.nameService 
FROM Appointment JOIN Employee ON 
Appointment.idEmployee=Employee.idEmployee 
JOIN Client ON 
Appointment.idClient=Client.idClient 
WHERE Appointment.idEmployee=@IdEmployee
);

--������� ServicesOfClient
CREATE FUNCTION dbo.ServicesOfClient(@IdClient int)
RETURNS TABLE
AS 
RETURN (
SELECT CONCAT(Client.firstName,' ', Client.lastName) AS Client_FIO,
CONCAT(Employee.firstName,' ', Employee.lastName) AS Employee_FIO,
Appointment.dataTime,
Appointment.nameService,
Appointment.price
FROM Appointment JOIN Client ON 
Appointment.idClient=Client.idClient 
JOIN Employee ON 
Appointment.idEmployee=Employee.idEmployee 
WHERE Appointment.idClient=@IdClient
);

--������������� Bookings
CREATE VIEW Bookings AS
SELECT CONCAT(Client.firstName,' ', Client.lastName) AS Client_FIO,
	   CONCAT(Employee.firstName,' ', Employee.lastName) AS Employee_FIO,
	   Client.telNumber,
	   Appointment.nameService,
	   Appointment.dataTime,
	   Appointment.price
FROM Client JOIN Appointment ON
	Client.idClient=Appointment.idClient JOIN
	Employee ON Employee.idEmployee=Appointment.idEmployee;

--��������� RemoveClient
CREATE PROC RemoveClient
@IdClient int
AS BEGIN
IF (NOT EXISTS (SELECT * FROM Client where
idClient = @IdClient))
THROW 51000, 'No client found with such ID!', 1;
DELETE FROM Appointment
WHERE idClient = @IdClient;
DELETE FROM Client
WHERE idClient = @IdClient;
END;

--��������� RemoveEmployee
CREATE PROC RemoveEmployee
@IdEmployee int
AS BEGIN
IF (NOT EXISTS (SELECT * FROM Employee where
idEmployee = @IdEmployee))
THROW 51000, 'No employee found with such ID!', 1;
DELETE FROM Appointment
WHERE idEmployee = @IdEmployee;
DELETE FROM Employee
WHERE idEmployee = @IdEmployee;
END;

--��������� RemoveAppointment
CREATE PROC RemoveAppointment
@IdAppointment int
AS BEGIN
IF (NOT EXISTS (SELECT * FROM Appointment where
idAppointment = @IdAppointment))
THROW 51000, 'No appointment found with such ID!', 1;
DELETE FROM Appointment
WHERE idAppointment = @IdAppointment;
END;

--