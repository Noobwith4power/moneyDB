USE master;
GO

DROP DATABASE IF EXISTS FinanceManagementDB;
GO

CREATE DATABASE FinanceManagementDB;
GO

USE FinanceManagementDB;
GO

-- 1. Создание таблиц узлов

CREATE TABLE Client (
    ClientID INT IDENTITY NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Client PRIMARY KEY (ClientID),
    CONSTRAINT UQ_ClientEmail UNIQUE (Email)
) AS NODE;
GO

CREATE TABLE Account (
    AccountID INT IDENTITY NOT NULL,
    AccountNumber NVARCHAR(20) NOT NULL,
    Balance DECIMAL(18, 2) NOT NULL,
    AccountType NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Account PRIMARY KEY (AccountID),
    CONSTRAINT CK_BalanceNonNegative CHECK (Balance >= 0),
    CONSTRAINT UQ_AccountNumber UNIQUE (AccountNumber)
) AS NODE;
GO

CREATE TABLE Transactions (
    TransactionID INT IDENTITY(1,1) NOT NULL,
    TransactionDate DATETIME NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Transaction PRIMARY KEY (TransactionID),
    CONSTRAINT CK_AmountNonNegative CHECK (Amount >= 0)
) AS NODE;
GO

-- 2. Создание таблиц ребер

CREATE TABLE ClientAccount AS EDGE;
GO

CREATE TABLE AccountTransaction AS EDGE;
GO

CREATE TABLE ClientTransaction AS EDGE;
GO

CREATE TABLE Look AS EDGE;
GO

-- 3. Заполнение таблиц узлов

INSERT INTO Client (FirstName, LastName, Email)
VALUES
  ('John', 'Smith', 'john.smith@example.com'),
  ('Jane', 'Doe', 'jane.doe@example.com'),
  ('Michael', 'Johnson', 'michael.johnson@example.com'),
  ('Emily', 'Davis', 'emily.davis@example.com'),
  ('David', 'Wilson', 'david.wilson@example.com'),
  ('Sarah', 'Thompson', 'sarah.thompson@example.com')
;
GO

INSERT INTO Account (AccountNumber, Balance, AccountType)
VALUES
  ('ACC123456', 5000.00, 'Checking'),
  ('ACC654321', 12000.00, 'Savings'),
  ('ACC789012', 7500.00, 'Checking'),
  ('ACC210987', 4500.00, 'Savings'),
  ('ACC345678', 8000.00, 'Investment'),
  ('ACC876543', 15000.00, 'Investment')
;
GO

INSERT INTO Transactions (TransactionDate, Amount, TransactionType)
VALUES
  (CONVERT(DATETIME, '2024-01-01', 120), 200.00, 'Deposit'),
  (CONVERT(DATETIME, '2024-01-05', 120), 150.00, 'Withdrawal'),
  (CONVERT(DATETIME, '2024-02-01', 120), 500.00, 'Deposit'),
  (CONVERT(DATETIME, '2024-02-15', 120), 100.00, 'Withdrawal'),
  (CONVERT(DATETIME, '2024-03-01', 120), 300.00, 'Deposit'),
  (CONVERT(DATETIME, '2024-03-10', 120), 50.00, 'Withdrawal')
;
GO


-- 4. Заполнение таблиц ребер

INSERT INTO ClientAccount ($from_id, $to_id)
VALUES 
	(
		(SELECT $node_id FROM Client WHERE ClientID = 1), -- John Smith
		(SELECT $node_id FROM Account WHERE AccountID = 1) -- Checking Account
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 2), -- Jane Doe
		(SELECT $node_id FROM Account WHERE AccountID = 2) -- Savings Account
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 3), -- Michael Johnson
		(SELECT $node_id FROM Account WHERE AccountID = 3) -- Checking Account
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 4), -- Emily Davis
		(SELECT $node_id FROM Account WHERE AccountID = 4) -- Savings Account
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 5), -- David Wilson
		(SELECT $node_id FROM Account WHERE AccountID = 5) -- Investment Account
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 6), -- Sarah Thompson
		(SELECT $node_id FROM Account WHERE AccountID = 6) -- Investment Account
	)
;
GO

INSERT INTO Look ($from_id, $to_id)
VALUES
	(
		(SELECT $node_id FROM Client WHERE ClientID = 3), -- Michael
		(SELECT $node_id FROM Client WHERE ClientID = 2) -- Jane
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 1), -- John
		(SELECT $node_id FROM Client WHERE ClientID = 3) -- Michael
	),	
	(
		(SELECT $node_id FROM Client WHERE ClientID = 4), --  Emily
		(SELECT $node_id FROM Client WHERE ClientID = 2) -- Jane
	),	
	(
		(SELECT $node_id FROM Client WHERE ClientID = 6), -- Sarah
		(SELECT $node_id FROM Client WHERE ClientID = 4) -- Michael
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 5), -- David
		(SELECT $node_id FROM Client WHERE ClientID = 3) -- Michael
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 2), -- Jane
		(SELECT $node_id FROM Client WHERE ClientID = 6) -- Sarah
	)
;
GO

INSERT INTO AccountTransaction ($from_id, $to_id)
VALUES
	(
		(SELECT $node_id FROM Account WHERE AccountID = 1), -- Checking Account
		(SELECT $node_id FROM Transactions WHERE TransactionID = 1) -- Deposit
	),
	(
		(SELECT $node_id FROM Account WHERE AccountID = 2), -- Savings Account
		(SELECT $node_id FROM Transactions WHERE TransactionID = 2) -- Withdrawal
	),
	(
		(SELECT $node_id FROM Account WHERE AccountID = 3), -- Checking Account
		(SELECT $node_id FROM Transactions WHERE TransactionID = 3) -- Deposit
	),
	(
		(SELECT $node_id FROM Account WHERE AccountID = 4), -- Savings Account
		(SELECT $node_id FROM Transactions WHERE TransactionID = 4) -- Withdrawal
	),
	(
		(SELECT $node_id FROM Account WHERE AccountID = 5), -- Investment Account
		(SELECT $node_id FROM Transactions WHERE TransactionID = 5) -- Deposit
	),
	(
		(SELECT $node_id FROM Account WHERE AccountID = 6), -- Investment Account
		(SELECT $node_id FROM Transactions WHERE TransactionID = 6) -- Withdrawal
	)
;
GO

INSERT INTO ClientTransaction ($from_id, $to_id)
VALUES
	(
		(SELECT $node_id FROM Client WHERE ClientID = 1), -- John Smith
		(SELECT $node_id FROM Transactions WHERE TransactionID = 1) -- Deposit
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 2), -- Jane Doe
		(SELECT $node_id FROM Transactions WHERE TransactionID = 2) -- Withdrawal
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 3), -- Michael Johnson
		(SELECT $node_id FROM Transactions WHERE TransactionID = 3) -- Deposit
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 4), -- Emily Davis
		(SELECT $node_id FROM Transactions WHERE TransactionID = 4) -- Withdrawal
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 5), -- David Wilson
		(SELECT $node_id FROM Transactions WHERE TransactionID = 5) -- Deposit
	),
	(
		(SELECT $node_id FROM Client WHERE ClientID = 6), -- Sarah Thompson
		(SELECT $node_id FROM Transactions WHERE TransactionID = 6) -- Withdrawal
	)
;
GO

-- 5. Запросы с функцией MATCH

-- 1. Баланс клиента "John Smith"
Select A.Balance from Account as A,
ClientAccount as CL,
Client as C
Where MATCH (C-(CL)->A) and C.FirstName = 'John' and C.LastName = 'Smith'

-- 2. Все транзакции по счету с номером 'ACC123456'
Select T.TransactionDate, T.Amount, T.TransactionType from Transactions as T,
AccountTransaction as [AT],
Account as A
Where MATCH(A-([AT])->T) and A.AccountNumber = 'ACC123456'

-- 3. Вся информация о клиенте "Jane Doe" 
Select C.Firstname, C.LastName, C.Email from Client as C,
ClientAccount as [CA],
Account as A
Where MATCH(C-([CA])->A) and C.FirstName= 'Jane' and C.LastName = 'Doe'

-- 4. Вся информация о человеке с транзакцией в 500$
Select C.Firstname, C.LastName, C.Email from Client as C,
ClientTransaction as [CT],
Transactions as T
Where MATCH(C-([CT])->T) and T.Amount = 500

-- 5. Номера аккаунтов с типом транзакций "Вывод"
Select A.AccountNumber from Account as A,
AccountTransaction as [AT],
Transactions as T
Where MATCH(A-([AT])->T) and T.TransactionType = 'Withdrawal'

-- 6. Запросы с функцией SHORTEST_PATH

SELECT 
    C1.FirstName AS Client1Name,
    STRING_AGG(C2.FirstName, '->') WITHIN GROUP (GRAPH PATH) AS ClientPath
FROM 
    Client AS C1,
	Client FOR PATH AS C2, 
	Look FOR PATH AS Look
WHERE MATCH(SHORTEST_PATH(C1(-(Look)->C2)+))
	and C1.FirstName = 'John';


SELECT 
    C1.FirstName AS Client1Name,
    STRING_AGG(C2.FirstName, '->') WITHIN GROUP (GRAPH PATH) AS ClientPath
FROM 
    Client AS C1,
	Client FOR PATH AS C2, 
	Look FOR PATH AS Look
WHERE MATCH(SHORTEST_PATH(C1(-(Look)->C2){1,2}))
	and C1.FirstName = 'John';

