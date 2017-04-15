--Sara Attarzadeh
--A11
-- 1: List the products with a list price greater than the average list price of all products.
SELECT ItemID, Description, ListPrice
FROM PET..Merchandise 
WHERE ListPrice > (SELECT AVG(ListPrice) FROM PET..Merchandise)

--2: Which merchandise items have an average sale price more than 50 percent higher than their average purchase cost? Go back and fix into one view.
CREATE VIEW AVGSALEPRICE AS 
	SELECT ItemID, AVG(SalePrice) AS [Average Sale Price]
	FROM PET..SaleItem
	GROUP BY ItemID

CREATE VIEW AVGCOST AS
	SELECT ItemID, AVG(COST) AS [Average Purchase Cost]
	FROM PET..OrderItem
	GROUP BY ItemID

SELECT P.ItemID, [Average Sale Price]
FROM AVGSALEPRICE P INNER JOIN AVGCOST C
	ON P.ItemID = C.ItemID
WHERE [Average Sale Price] > [Average Purchase Cost]*1.5

--3: List the employees and their total merchandise sales expressed as a percentage of total merchandise sales for all employees.
CREATE VIEW PERSONALTOTALSALES AS
	SELECT EmployeeID, SUM(SalePrice*Quantity) AS [Personal Employee Sales]
	FROM PET..Sale S INNER JOIN PET..SaleItem I
		ON S.SaleID = I.SaleID
	GROUP BY EmployeeID

CREATE VIEW TOTALEMPSALES AS
	SELECT SUM(SalePrice*Quantity) AS [Total Employee Sales]
	FROM PET..SaleItem

SELECT E.EmployeeID, E.LastName, E.FirstName, ([Personal Employee Sales]/[Total Employee Sales])*100 AS [Percentage of Total Sales]
FROM TOTALEMPSALES T, PET..Employee E INNER JOIN PERSONALTOTALSALES P
	ON E.EmployeeID = P.EmployeeID

--4: On average, which supplier charges the highest shipping cost as a percent of the merchandise order total?
CREATE VIEW SHIPPINGPERCENTORDER AS
	SELECT SupplierID, M.PONumber, (ShippingCost/SUM((Cost*Quantity)+ ShippingCost))*100 AS [Shipping Percentage of Cost]
	FROM PET..MerchandiseOrder M INNER JOIN PET..OrderItem O
		ON M.PONumber = O.PONumber
	GROUP BY SupplierID, M.PONumber, ShippingCost

CREATE VIEW AVERAGESHIPPING AS
	SELECT SupplierID, AVG([Shipping Percentage of Cost]) AS [Average Shipping Cost]
	FROM SHIPPINGPERCENTORDER
	GROUP BY SupplierID

SELECT TOP 1 S.SupplierID, Name, ROUND([Average Shipping Cost],1) AS [Shipping Percent of Order Total]
FROM PET..Supplier S INNER JOIN AVERAGESHIPPING A 
	ON S.SupplierID = A.SupplierID
ORDER BY [Shipping Percent of Order Total] DESC

--5: Which customer has given us the most total money for animals and merchandise?
CREATE VIEW TOTALANIMALMONEY AS
	SELECT S.CustomerID, SUM(A.SalePrice) AS [Total Animal Money]
	FROM PET..Sale S INNER JOIN PET..SaleAnimal A
		ON S.SaleID = A.SaleID
	GROUP BY S.CustomerID


CREATE VIEW TOTALMERCHANDISEMONEY AS
	SELECT S.CUSTOMERID, SUM(I.SalePrice*I.Quantity) AS [Total Merchandise Money]
	FROM PET..SALE S INNER JOIN PET..SaleItem I
		ON S.SaleID = I.SaleID
	GROUP BY S.CustomerID


SELECT TOP 1 C.CustomerID, C.LastName, C.FirstName, (A.[Total Animal Money]+M.[Total Merchandise Money]) AS [Total Money Spent]
FROM PET..CUSTOMER C INNER JOIN TOTALANIMALMONEY A ON C.CustomerID = A.CustomerID
	INNER JOIN TOTALMERCHANDISEMONEY M ON A.CustomerID = M.CUSTOMERID
ORDER BY [Total Money Spent] DESC

--6: Which customers who bought more than $100 in merchandise in May also spent more than $50 on merchandise in October?
CREATE VIEW MORETHAN100 AS
	SELECT S.CustomerID, SUM(I.SalePrice * I.Quantity) AS [Total Spent May] 
	FROM PET..SALE S INNER JOIN PET..SaleItem I
		ON S.SaleID = I.SaleID
	WHERE MONTH(S.SaleDate) = 5
	GROUP BY S.CUSTOMERID
	HAVING SUM(I.SalePrice * I.Quantity) > 100

CREATE VIEW MORETHAN50 AS
	SELECT S.CustomerID, SUM(I.SalePrice * I.Quantity) AS [Total Spent October] 
	FROM PET..SALE S INNER JOIN PET..SaleItem I
		ON S.SaleID = I.SaleID
	WHERE MONTH(S.SaleDate) = 10
	GROUP BY S.CUSTOMERID
	HAVING SUM(I.SalePrice * I.Quantity) > 50

SELECT C.CustomerID, C.LastName, C.FirstName,O.[Total Spent May], F.[Total Spent October] 
FROM PET..Customer C INNER JOIN MORETHAN100 O
	ON C.CustomerID = O.CustomerID INNER JOIN MORETHAN50 F
	ON O.CustomerID = F.CustomerID 

--7: What was the net change in quantity on hand for premium canned dog food between January 1 and July 1?	 
CREATE VIEW QUANTITYRECEIVED AS 
	SELECT M.ItemID, M.Description, SUM(OI.Quantity) AS [Quantity Received]
	FROM PET..Merchandise M INNER JOIN PET..OrderItem OI 
		ON M.ItemID = OI.ItemID INNER JOIN PET..MerchandiseOrder MO
		ON OI.PONumber = MO.PONumber
	WHERE (MONTH(MO.ReceiveDate) > 1 AND MONTH(MO.ReceiveDate) < 7)
		AND (DESCRIPTION LIKE '%DOG%' AND DESCRIPTION LIKE '%FOOD%' AND DESCRIPTION LIKE '%CAN%' AND DESCRIPTION LIKE '%PREMIUM%')
	GROUP BY M.ItemID, M.Description  

CREATE VIEW QUANTITYSOLD AS 
	SELECT M.ItemID, M.Description, SUM (SI.Quantity) AS [Quantity Sold]
	FROM PET..Merchandise M INNER JOIN PET..SaleItem SI
		ON M.ItemID = SI.ItemID INNER JOIN PET..Sale S
		ON SI.SaleID = S.SaleID
	WHERE (MONTH(S.SaleDate) > 1 AND MONTH(S.SaleDate) < 7)
		AND (DESCRIPTION LIKE '%DOG%' AND DESCRIPTION LIKE '%FOOD%' AND DESCRIPTION LIKE '%CAN%' AND DESCRIPTION LIKE '%PREMIUM%')
	GROUP BY M.ItemID, M.Description  

SELECT M.ItemID, M.Description, (QR.[Quantity Received]-QS.[Quantity Sold]) AS [Net Change in Quantity]
	FROM PET..Merchandise M INNER JOIN QUANTITYRECEIVED QR
		ON M.ItemID = QR.ItemID INNER JOIN QUANTITYSOLD QS
		ON QR.ItemID = QS.ItemID

--Q8: Which merchandise items with a list price of more than $50 hand no sales July?
SELECT M.ItemID, M.Description, M.ListPrice 
FROM  PET..Merchandise M INNER JOIN PET..SaleItem SI
	ON M.ItemID = SI.ItemID INNER JOIN PET..Sale S
	ON SI.SaleID = S.SaleID
WHERE M.ListPrice > 50 AND M.ItemID NOT IN(SELECT SI.ItemID 
											FROM PET..SaleItem SI INNER JOIN PET..Sale S ON SI.SaleID = S.SaleID
										 WHERE MONTH(S.SaleDate) = 7)

--Q9: Which merchandise items with more than 100 units on hand have not been ordered in 2004? Use an outer join to answer the question.
 SELECT M.ItemID, M.Description, M.QuantityOnHand
 FROM PET..Merchandise M FULL OUTER JOIN PET..OrderItem O
	ON M.ItemID= O.ItemID FULL OUTER JOIN PET..MerchandiseOrder MO
	ON O.PONumber = MO.PONumber
WHERE QuantityOnHand > 100 
	AND M.ItemID NOT IN (SELECT M.ItemID
						FROM PET..Merchandise M FULL OUTER JOIN PET..OrderItem O
							ON M.ItemID= O.ItemID FULL OUTER JOIN PET..MerchandiseOrder MO
							ON O.PONumber = MO.PONumber
						WHERE YEAR(OrderDate) = 2004)
--Q10:Write SQL code to create and populate the following table.
CREATE TABLE CATEGORY
(Category VARCHAR(15) Primary KEY, 
Low INT,
High INT)

INSERT INTO CATEGORY
VALUES
('Weak', 0 , 200);

INSERT INTO CATEGORY
VALUES
('Good', 200 , 800);

INSERT INTO CATEGORY
VALUES
('Best', 800 , 10000);



--Q11: Generate the following results using the Category table you created in 10 and the results in Exercise 5 of total amount of money spent by each customer. 
CREATE VIEW ADDCATEGORIES AS
	SELECT C.CustomerID, C.LastName, C.FirstName, (A.[Total Animal Money]+M.[Total Merchandise Money]) AS [Total Money Spent] 
	FROM PET..CUSTOMER C INNER JOIN TOTALANIMALMONEY A ON C.CustomerID = A.CustomerID
		INNER JOIN TOTALMERCHANDISEMONEY M ON A.CustomerID = M.CUSTOMERID

SELECT A.CustomerId, LastName, FirstName, [Total Money Spent], Category
FROM ADDCATEGORIES A INNER JOIN CATEGORY C
	ON A.[Total Money Spent] >= C.Low AND A.[Total Money Spent]<= C.High

--Q12: List all suppliers (animals and merchandise) who sold us items in June. Identify whether they sold use animals or merchandise.
SELECT S.SupplierID, Name, 'Animal' AS [Type of Sale]
FROM PET..Supplier S INNER JOIN PET..AnimalOrder A
	ON S.SupplierID = A.SupplierID
UNION ALL
SELECT S.SupplierID, Name, 'Merchandise' AS [Type of Sale]
FROM PET..Supplier S INNER JOIN PET..MerchandiseOrder M
	ON S.SupplierID = M.SupplierID


