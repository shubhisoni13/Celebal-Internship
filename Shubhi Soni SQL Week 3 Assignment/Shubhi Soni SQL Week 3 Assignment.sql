--Shubhi Soni
--CT_CSI_SQ_366


-- Task 1
CREATE TABLE Projects (
    Task_ID INT PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE
);

INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2022-01-01', '2022-01-10'),
(2, '2022-01-05', '2022-01-15'),
(3, '2022-01-12', '2022-01-20');

WITH ProjectGroups AS (
    SELECT Task_ID, 
           Start_Date, 
           End_Date,
           ROW_NUMBER() OVER (ORDER BY Start_Date) - ROW_NUMBER() OVER (PARTITION BY Start_Date ORDER BY Task_ID) AS grp
    FROM Projects
)
SELECT MIN(Start_Date) AS Project_Start, 
       MAX(End_Date) AS Project_End
FROM ProjectGroups
GROUP BY grp
ORDER BY DATEDIFF(day, MIN(Start_Date), MAX(End_Date)), MIN(Start_Date);
GO



-- Task 2
CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name VARCHAR(100)
);

CREATE TABLE Friends (
    ID INT,
    Friend_ID INT,
    PRIMARY KEY (ID, Friend_ID)
);

CREATE TABLE Packages (
    ID INT PRIMARY KEY,
    Salary DECIMAL(10, 2)
);

INSERT INTO Students (ID, Name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(1, 3),
(2, 3);

INSERT INTO Packages (ID, Salary) VALUES
(1, 50000),
(2, 60000),
(3, 55000);

SELECT S1.Name
FROM Students S1
JOIN Friends F ON S1.ID = F.ID
JOIN Packages P1 ON S1.ID = P1.ID
JOIN Packages P2 ON F.Friend_ID = P2.ID
WHERE P2.Salary > P1.Salary
ORDER BY P2.Salary;
GO



-- Task 3
CREATE TABLE Functions (
    X INT,
    Y INT
);

INSERT INTO Functions (X, Y) VALUES
(1, 2),
(2, 1),
(3, 4),
(4, 5),
(5, 3);

SELECT DISTINCT 
    CASE WHEN F1.X < F1.Y THEN F1.X ELSE F1.Y END AS X,
    CASE WHEN F1.X > F1.Y THEN F1.X ELSE F1.Y END AS Y
FROM Functions F1
JOIN Functions F2 ON F1.X = F2.Y AND F1.Y = F2.X
WHERE F1.X < F1.Y  -- To avoid duplicates like (1,2) and (2,1)
ORDER BY X, Y;



-- Task 4
CREATE TABLE Contests (
    contest_id INT PRIMARY KEY,
    hacker_id INT,
    name VARCHAR(100)
);

CREATE TABLE Challenges (
    challenge_id INT PRIMARY KEY,
    contest_id INT
);

CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT
);

CREATE TABLE Submission_Stats (
    challenge_id INT,
    total_submissions INT,
    total_accepted_submissions INT
);

INSERT INTO Contests (contest_id, hacker_id, name) VALUES
(1, 1, 'Contest1'),
(2, 2, 'Contest2');

INSERT INTO Challenges (challenge_id, contest_id) VALUES
(1, 1),
(2, 1),
(3, 2);

INSERT INTO View_Stats (challenge_id, total_views, total_unique_views) VALUES
(1, 100, 90),
(2, 200, 180);

INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions) VALUES
(1, 50, 30),
(3, 40, 20);
WITH ContestStats AS (
    SELECT C.contest_id, 
           C.hacker_id, 
           C.name,
           COALESCE(SUM(V.total_views), 0) AS total_views,
           COALESCE(SUM(V.total_unique_views), 0) AS total_unique_views,
           COALESCE(SUM(S.total_submissions), 0) AS total_submissions,
           COALESCE(SUM(S.total_accepted_submissions), 0) AS total_accepted_submissions
    FROM Contests C
    LEFT JOIN Challenges H ON C.contest_id = H.contest_id
    LEFT JOIN View_Stats V ON H.challenge_id = V.challenge_id
    LEFT JOIN Submission_Stats S ON H.challenge_id = S.challenge_id
    GROUP BY C.contest_id, C.hacker_id, C.name
)
SELECT contest_id, hacker_id, name, total_views, total_unique_views, total_submissions, total_accepted_submissions
FROM ContestStats
WHERE total_views != 0 OR total_unique_views != 0 OR total_submissions != 0 OR total_accepted_submissions != 0
ORDER BY contest_id;
GO



-- Task 5
CREATE TABLE Submissions (
    submission_id INT PRIMARY KEY,
    submission_date DATE,
    hacker_id INT
);

CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO Submissions (submission_id, submission_date, hacker_id) VALUES
(1, '2022-01-01', 1),
(2, '2022-01-01', 2),
(3, '2022-01-02', 1),
(4, '2022-01-02', 3),
(5, '2022-01-03', 2);

INSERT INTO Hackers (hacker_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

WITH DailySubmissions AS (
    SELECT submission_date, 
           hacker_id, 
           COUNT(submission_id) AS submission_count,
           ROW_NUMBER() OVER (PARTITION BY submission_date ORDER BY COUNT(submission_id) DESC, hacker_id) AS rn
    FROM Submissions
    GROUP BY submission_date, hacker_id
),
DailyUniqueHackers AS (
    SELECT submission_date, 
           COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM Submissions
    GROUP BY submission_date
)
SELECT D1.submission_date, 
       D2.unique_hackers, 
       D1.hacker_id, 
       H.name
FROM DailySubmissions D1
JOIN Hackers H ON D1.hacker_id = H.hacker_id
JOIN DailyUniqueHackers D2 ON D1.submission_date = D2.submission_date
WHERE D1.rn = 1
ORDER BY D1.submission_date;
GO




-- Task 6
CREATE TABLE STATION (
    ID INT PRIMARY KEY,
    LAT_N DECIMAL(8, 4),
    LONG_W DECIMAL(8, 4)
);

INSERT INTO STATION (ID, LAT_N, LONG_W) VALUES
(1, 39.8974, 116.3858),
(2, 34.0522, 118.2437);
SELECT ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4) AS Manhattan_Distance
FROM STATION;
GO




--Task 7
WITH PrimeNumbers AS (
    SELECT 2 AS num
    UNION ALL
    SELECT num + 1
    FROM PrimeNumbers
    WHERE num + 1 <= 1000
),
PrimeFilter AS (
    SELECT num
    FROM PrimeNumbers pn1
    WHERE NOT EXISTS (
        SELECT 1
        FROM PrimeNumbers pn2
        WHERE pn2.num < pn1.num AND pn1.num % pn2.num = 0
    )
)
SELECT STRING_AGG(CAST(num AS VARCHAR), '&') AS primes
FROM PrimeFilter
OPTION (MAXRECURSION 0);
GO



-- Task 8
CREATE TABLE Occupations (
    Name VARCHAR(100),
    Occupation VARCHAR(100)
);

INSERT INTO Occupations (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Professor'),
('Maria', 'Singer'),
('Scarlett', 'Actor'),
('James', 'Doctor'),
('John', 'Professor'),
('Edward', 'Singer'),
('Robert', 'Actor');
SELECT 
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name ELSE NULL END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name ELSE NULL END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name ELSE NULL END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name ELSE NULL END) AS Actor
FROM (
    SELECT Name, Occupation, ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM Occupations
) AS Piv
GROUP BY RowNum
ORDER BY RowNum;
GO



-- Task 9
CREATE TABLE BST (
    N INT PRIMARY KEY,
    P INT
);

INSERT INTO BST (N, P) VALUES
(1, NULL),
(2, 1),
(3, 1),
(4, 2),
(5, 2);
WITH NodeTypes AS (
    SELECT N, 
           P, 
           CASE 
               WHEN P IS NULL THEN 'Root'
               WHEN N NOT IN (SELECT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
               ELSE 'Inner'
           END AS NodeType
    FROM BST
)
SELECT N, NodeType
FROM NodeTypes
ORDER BY N;
GO





-- Task 10
CREATE TABLE Company (
    company_code INT PRIMARY KEY,
    founder VARCHAR(100)
);

CREATE TABLE Lead_Manager (
    company_code INT,
    lead_manager_code INT
);

CREATE TABLE Senior_Manager (
    company_code INT,
    senior_manager_code INT
);

CREATE TABLE Manager (
    company_code INT,
    manager_code INT
);

CREATE TABLE Employee (
    company_code INT,
    employee_code INT
);

INSERT INTO Company (company_code, founder) VALUES
(1, 'Alice'),
(2, 'Bob');

INSERT INTO Lead_Manager (company_code, lead_manager_code) VALUES
(1, 101),
(2, 102);

INSERT INTO Senior_Manager (company_code, senior_manager_code) VALUES
(1, 201),
(2, 202);

INSERT INTO Manager (company_code, manager_code) VALUES
(1, 301),
(2, 302);

INSERT INTO Employee (company_code, employee_code) VALUES
(1, 401),
(2, 402);
WITH LeadManagerCount AS (
    SELECT company_code, COUNT(DISTINCT lead_manager_code) AS total_lead_managers
    FROM Lead_Manager
    GROUP BY company_code
),
SeniorManagerCount AS (
    SELECT company_code, COUNT(DISTINCT senior_manager_code) AS total_senior_managers
    FROM Senior_Manager
    GROUP BY company_code
),
ManagerCount AS (
    SELECT company_code, COUNT(DISTINCT manager_code) AS total_managers
    FROM Manager
    GROUP BY company_code
),
EmployeeCount AS (
    SELECT company_code, COUNT(DISTINCT employee_code) AS total_employees
    FROM Employee
    GROUP BY company_code
)
SELECT C.company_code, 
       C.founder, 
       COALESCE(LM.total_lead_managers, 0) AS total_lead_managers,
       COALESCE(SM.total_senior_managers, 0) AS total_senior_managers,
       COALESCE(M.total_managers, 0) AS total_managers,
       COALESCE(E.total_employees, 0) AS total_employees
FROM Company C
LEFT JOIN LeadManagerCount LM ON C.company_code = LM.company_code
LEFT JOIN SeniorManagerCount SM ON C.company_code = SM.company_code
LEFT JOIN ManagerCount M ON C.company_code = M.company_code
LEFT JOIN EmployeeCount E ON C.company_code = E.company_code
ORDER BY C.company_code;
GO





-- Task 11
SELECT S1.Name
FROM Students S1
JOIN Friends F ON S1.ID = F.ID
JOIN Packages P1 ON S1.ID = P1.ID
JOIN Packages P2 ON F.Friend_ID = P2.ID
WHERE P2.Salary > P1.Salary
ORDER BY P2.Salary;
GO



-- Task 12 
CREATE TABLE simulation (
    EmployeeID INT PRIMARY KEY,
    JobFamily VARCHAR(50),
    Country VARCHAR(50),
    BU VARCHAR(50),
    MONTH VARCHAR(20),
    Cost FLOAT,
    Revenue FLOAT,
    SubBand VARCHAR(20)
);

INSERT INTO simulation (EmployeeID, JobFamily, Country, BU, MONTH, Cost, Revenue, SubBand) VALUES
(1, 'IT', 'India', 'Tech', 'January', 50000, 120000, 'B1'),
(2, 'IT', 'International', 'Tech', 'January', 60000, 130000, 'B2'),
(3, 'HR', 'India', 'HR', 'February', 30000, 80000, 'B1'),
(4, 'HR', 'International', 'HR', 'February', 40000, 90000, 'B3'),
(5, 'Finance', 'India', 'Finance', 'January', 55000, 110000, 'B2'),
(6, 'Finance', 'International', 'Finance', 'February', 45000, 100000, 'B1');

SELECT
    JobFamily,
    SUM(CASE WHEN Country = 'India' THEN Cost ELSE 0 END) AS India_Cost,
    SUM(CASE WHEN Country = 'International' THEN Cost ELSE 0 END) AS International_Cost,
    (SUM(CASE WHEN Country = 'India' THEN Cost ELSE 0 END) / NULLIF(SUM(Cost), 0)) * 100 AS India_Percentage,
    (SUM(CASE WHEN Country = 'International' THEN Cost ELSE 0 END) / NULLIF(SUM(Cost), 0)) * 100 AS International_Percentage
FROM simulation
GROUP BY JobFamily;
GO





-- Task 13
SELECT BU, 
       MONTH, 
       SUM(Cost) AS Total_Cost, 
       SUM(Revenue) AS Total_Revenue, 
       SUM(Cost) / NULLIF(SUM(Revenue), 0) AS Cost_Revenue_Ratio
FROM simulation
GROUP BY BU, MONTH;
GO





-- Task 14
SELECT SubBand, 
       COUNT(EmployeeID) AS Headcount, 
       (COUNT(EmployeeID) / (SELECT COUNT(*) FROM simulation)) * 100 AS Percentage_Headcount
FROM simulation
GROUP BY SubBand;
GO




-- Task 15
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Salary DECIMAL(10, 2)
);

INSERT INTO Employees (EmployeeID, Salary) VALUES
(1, 50000),
(2, 60000),
(3, 55000),
(4, 70000),
(5, 45000),
(6, 80000);

SELECT TOP 5 *
FROM Employees
ORDER BY Salary DESC;
GO



-- Task 16
CREATE TABLE TableName (
    ColumnA INT,
    ColumnB INT
);

INSERT INTO TableName (ColumnA, ColumnB) VALUES
(5, 3),
(7, 2),
(4, 8);

UPDATE TableName
SET ColumnA = ColumnA + ColumnB,
    ColumnB = ColumnA - ColumnB,
    ColumnA = ColumnA - ColumnB;
    GO



-- Task 17
CREATE LOGIN new_user WITH PASSWORD = 'password';
CREATE USER new_user FOR LOGIN new_user;
EXEC sp_addrolemember 'db_owner', 'new_user';
GO



-- Task 18
CREATE TABLE Employees1 (
    BU VARCHAR(100),
    Cost DECIMAL(10, 2),
    Weight DECIMAL(10, 2)
);

INSERT INTO Employees1 (BU, Cost, Weight) VALUES
('HR', 1000, 1.2),
('Finance', 2000, 1.5),
('IT', 1500, 1.3),
('HR', 1200, 1.4),
('Finance', 2200, 1.6);

SELECT BU, 
       AVG(Cost * Weight) / SUM(Weight) AS WeightedAvgCost
FROM Employees1
GROUP BY BU;
GO




-- Task 19
WITH Actual AS (
    SELECT AVG(Salary * 1.0) AS ActualAvgSalary
    FROM Employees
),
Miscalculated AS (
    SELECT AVG(CAST(REPLACE(CAST(Salary AS VARCHAR), '0', '') AS FLOAT)) AS MiscalculatedAvgSalary
    FROM Employees
)
SELECT CEILING(Actual.ActualAvgSalary - Miscalculated.MiscalculatedAvgSalary) AS ErrorAmount
FROM Actual, Miscalculated;
GO




-- Task 20
CREATE TABLE SourceTable (
    KeyColumn INT PRIMARY KEY,
    Column1 VARCHAR(100),
    Column2 VARCHAR(100)
);

CREATE TABLE TargetTable (
    KeyColumn INT PRIMARY KEY,
    Column1 VARCHAR(100),
    Column2 VARCHAR(100)
);

INSERT INTO SourceTable (KeyColumn, Column1, Column2) VALUES
(1, 'A', 'B'),
(2, 'C', 'D'),
(3, 'E', 'F');

INSERT INTO TargetTable (KeyColumn, Column1, Column2) VALUES
(1, 'A', 'B');
INSERT INTO TargetTable (KeyColumn, Column1, Column2)

SELECT KeyColumn, Column1, Column2
FROM SourceTable
WHERE NOT EXISTS (
    SELECT 1
    FROM TargetTable
    WHERE TargetTable.KeyColumn = SourceTable.KeyColumn
);
