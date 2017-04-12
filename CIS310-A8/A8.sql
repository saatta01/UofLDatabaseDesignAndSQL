-- Sara Attarzadeh
-- Page 314

-- Question 72
SELECT Movie_Title, Movie_Year, Movie_Genre 
FROM MOVIE

-- Question 73
SELECT Movie_year, Movie_Title, Movie_Cost
FROM MOVIE
ORDER BY Movie_Year DESC

-- Question 74
SELECT Movie_Title, Movie_Year, Movie_Genre
FROM MOVIE
ORDER BY Movie_Genre ASC, Movie_Year DESC

-- Question 75
SELECT Movie_Num, Movie_Title, Price_Code
FROM MOVIE
WHERE Movie_Title LIKE 'R%'

-- Question 76
SELECT Movie_Title, Movie_Year, Movie_Cost
FROM MOVIE
WHERE Movie_Title LIKE '%hope%'
ORDER BY Movie_Title  ASC

-- QUESTION 77
SELECT Movie_Title, Movie_Year, Movie_Genre
FROM MOVIE
WHERE Movie_Genre = 'ACTION'

-- QUESTION 78
SELECT Movie_Num, Movie_Title, Movie_Cost 
FROM MOVIE
WHERE Movie_Cost > 40

-- QUESTION 79
SELECT Movie_Num, Movie_Title, Movie_Cost, Movie_Genre
FROM MOVIE
WHERE (Movie_Genre= 'ACTION' OR Movie_Genre = 'COMEDY') 
AND  Movie_Cost < 50
ORDER BY Movie_Genre ASC 

-- QUESTION 80
SELECT Movie_Num, CONCAT (Movie_Title, ' (' , Movie_Year , ') ' , Movie_Genre) AS 'Movie Description'
FROM MOVIE

-- QUESTION 81
SELECT Movie_Genre, COUNT(*) AS 'Number of Movies'
FROM MOVIE
GROUP BY Movie_Genre

-- QUESTION 82
SELECT AVG(Movie_Cost) AS 'Average Movie Cost'
FROM MOVIE

-- QUESTION 83
SELECT Movie_Genre, AVG(Movie_Cost) AS 'Average Cost'
FROM MOVIE
GROUP BY Movie_Genre

-- QUESTION 84
SELECT Movie_Title, Movie_Genre, Price_Description, Price_RentFee
FROM  MOVIE, PRICE
WHERE MOVIE.Price_Code = PRICE.Price_Code

-- QUESTION 84 W/ INNER JOIN
SELECT M.Movie_Title, M.Movie_Genre, P.Price_Description, P.Price_RentFee
FROM Movie M INNER JOIN Price P
	 ON M.Price_Code = P.Price_Code

-- QUESTION 85
SELECT Movie_Genre, AVG(Price_RentFee) AS 'Average Rental Fee'
FROM MOVIE, PRICE
WHERE MOVIE.Price_Code = PRICE.Price_Code
GROUP BY Movie_Genre

-- QUESTION 85 W/ INNER JOIN
SELECT  M.Movie_Genre, AVG(P.Price_RentFee) AS 'Average Rental Fee'
FROM Movie M INNER JOIN Price P
	 ON M.Price_Code = P.Price_Code
GROUP BY M.Movie_Genre

-- QUESTION 86
SELECT M.Movie_Title, M.Movie_Year, (M.Movie_Cost/P.Price_RentFee) AS 'Breakeven Rentals'
FROM MOVIE M INNER JOIN PRICE P
	 ON M.Price_Code = P.Price_Code

-- QUESTION 87
SELECT Movie_Title, Movie_Year
FROM MOVIE
WHERE Price_Code IS NOT NULL

-- QUESTION 88
SELECT Movie_Title, Movie_Year, Movie_Cost
FROM MOVIE
WHERE Movie_Cost BETWEEN 44.99 AND 49.99

-- QUESTION 89
SELECT M.Movie_Title, M.Movie_Year, P.Price_Description, P.Price_RentFee, M.Movie_Genre
FROM MOVIE M INNER JOIN PRICE P
	  ON M.Price_Code = P.Price_Code
WHERE M.Movie_Genre IN ('FAMILY', 'COMEDY', 'DRAMA')

-- QUESTION 90
SELECT Movie_Num, Movie_Title, Movie_Year
FROM MOVIE
WHERE MOVIE_NUM NOT IN (SELECT MOVIE_NUM
						FROM VIDEO)
-- QUESTION 91
SELECT Mem_Num, Mem_FName, Mem_LName, Mem_Balance
FROM MEMBERSHIP
WHERE Mem_Num IN (SELECT Mem_Num
					FROM RENTAL)

-- QUESTION 92 
SELECT MIN(Mem_Balance) AS 'Minimum Balance', MAX(Mem_Balance) AS 'Maximum Balance', AVG(Mem_Balance) AS 'Average Balance'
FROM MEMBERSHIP 
WHERE Mem_Num IN (SELECT Mem_Num
					FROM RENTAL)

-- QUESTION 93
SELECT CONCAT(Mem_FName, ' ' , Mem_LName) AS 'Membership Name', 
		CONCAT(Mem_Street, ', ', Mem_City, ', ', Mem_State, ' ', Mem_Zip) AS 'Membership Address'
FROM MEMBERSHIP

-- QUESTION 94
SELECT R.Rent_Num, R.Rent_Date, V.Vid_Num, M.Movie_Title, D.Detail_DueDate, D.Detail_ReturnDate
FROM RENTAL R INNER JOIN DETAILRENTAL D ON R.Rent_Num = D.Rent_Num
	 INNER JOIN VIDEO V ON D.Vid_Num = V.Vid_Num
	 INNER JOIN MOVIE M ON V.Movie_Num = M.Movie_Num
WHERE D.Detail_ReturnDate > D.Detail_DueDate
ORDER BY R.Rent_Num, M.Movie_Title

-- QUESTION 95
SELECT R.Rent_Num, R.Rent_Date, V.Vid_Num, M.Movie_Title, D.Detail_DueDate, D.Detail_ReturnDate, D.Detail_Fee, CAST(D.Detail_ReturnDate-D.Detail_DueDate AS INT) AS 'Days Past Due' 
FROM RENTAL R INNER JOIN DETAILRENTAL D ON R.Rent_Num = D.Rent_Num
	 INNER JOIN VIDEO V ON D.Vid_Num = V.Vid_Num
	 INNER JOIN MOVIE M ON V.Movie_Num = M.Movie_Num
WHERE D.Detail_ReturnDate > D.Detail_DueDate
ORDER BY R.Rent_Num, M.Movie_Title

-- QUESTION 96
SELECT R.Rent_Num, R.Rent_Date, M.Movie_Title, D.Detail_Fee
FROM RENTAL R INNER JOIN DETAILRENTAL D ON R.Rent_Num = D.Rent_Num
	 INNER JOIN VIDEO V ON D.Vid_Num = V.Vid_Num
	 INNER JOIN MOVIE M ON V.Movie_Num = M.Movie_Num
WHERE D.Detail_ReturnDate <= D.Detail_DueDate
ORDER BY R.Rent_Num, M.Movie_Title


-- QUESTION 97 
SELECT DISTINCT M.MEM_NUM, M.MEM_LNAME, M.MEM_FNAME, SUM(DETAIL_FEE) AS 'Rental Fee Revenue'
FROM MEMBERSHIP M INNER JOIN RENTAL R ON M.Mem_Num=R.Mem_Num
	 INNER JOIN DETAILRENTAL D ON R.RENT_NUM=D.Rent_Num
GROUP BY M.Mem_Num, M.MEM_LNAME, M.MEM_FNAME

-- QUESTION 98
SELECT Movie_Num, Movie_Genre, AVG(Movie_Cost) OVER (partition BY Movie_Genre) AS 'Average Cost',
	   Movie_Cost, ((Movie_Cost - AVG(Movie_Cost) OVER (partition BY Movie_Genre))/AVG(Movie_Cost) OVER (partition BY Movie_Genre)) * 100 AS 'Percent Difference'	  
FROM MOVIE
ORDER BY Movie_Num



