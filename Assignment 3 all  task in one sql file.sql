CREATE DATABASE assignment3;
USE assignment3;
SELECT * FROM titanic;

-- Task 1: Write a query to find the name and age of the oldest passenger who survived
SELECT first_name, last_name, age
FROM titanic
WHERE survived = 1
ORDER BY age DESC
LIMIT 1;

-- Task 2: Create a view to display passenger survival status, class, age, and fare.
CREATE VIEW passenger_details AS
SELECT survived, class, age, fare
FROM titanic;
-- to check output of view
SELECT *
FROM passenger_details;

-- Task 3: Create a stored procedure to retrieve passengers based on a given age range
Delimiter //
CREATE PROCEDURE retrieve_passenger_details(IN min_age INT , IN max_age INT)
BEGIN
SELECT * FROM titanic WHERE age BETWEEN min_age AND max_age;
END //
delimiter ;
-- use stored procedure
CALL retrieve_passenger_details(20,30);

-- Task 4: Write a query to categorize passengers based on the fare they paid: 'Low', 'Medium', or 'High'.
SELECT first_name,last_name,fare,
CASE
WHEN fare < 35000 THEN 'Low'
WHEN fare BETWEEN 35000 and 50000 THEN 'Medium'
ELSE 'High'
END AS fare_category
FROM titanic;

-- Task 5: Show each passenger's fare and the fare of the next passenger
SELECT first_name,last_name,fare,
LEAD(fare) OVER (ORDER BY fare) AS next_passenger_fare 
FROM titanic;

-- Task 6: Show the age of each passenger and the age of the previous passenger
SELECT first_name,last_name,age,
LAG(age) OVER (ORDER BY age) AS previous_passenger_age 
FROM titanic;

-- Task 7: Write a query to rank passengers based on their fare, displaying rank for each passenger.
SELECT first_name,last_name,fare,
RANK() OVER ( ORDER BY fare DESC) AS ranking_by_fare 
FROM titanic;

-- Task 8: Write a query to rank passengers based on their fare, ensuring no gaps in rank
SELECT first_name,last_name,fare,
DENSE_RANK() OVER ( ORDER BY fare DESC) AS dense_fare_rank 
FROM titanic;

-- Task 9: Assign row numbers to passengers based on the order of their fares.
SELECT first_name,last_name,fare,
ROW_NUMBER() OVER ( ORDER BY fare DESC) AS fare_row_num 
FROM titanic;

-- Task 10: Use a CTE to calculate the average fare and find passengers who paid more than the average
WITH cte_average_fare AS
(SELECT AVG(fare) AS avg_fare FROM titanic)
SELECT t.first_name,t.last_name,t.fare FROM titanic t 
JOIN cte_average_fare c 
ON t.fare > c.avg_fare;
