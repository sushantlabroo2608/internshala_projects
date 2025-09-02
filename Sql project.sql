CREATE DATABASE projectsql;
USE projectsql;
SELECT * FROM walmartsales;

-- chage the datatype for Date column from string to date type
ALTER TABLE walmartsales ADD COLUMN Date_sale date;
UPDATE walmartsales SET Date_sale = STR_TO_DATE(Date, '%d-%m-%Y') LIMIT 1000;
ALTER TABLE walmartsales DROP COLUMN Date;
ALTER TABLE walmartsales RENAME COLUMN Date_sale to Date;

-- Task 1 : Identifying the Top Branch by Sales Growth Rate (6 Marks)
-- 			Walmart wants to identify which branch has exhibited the highest sales growth over time. Analyze the total sales
-- 			for each branch and compare the growth rate across months to find the top performer.

-- using window function we created a table with data of branch and total sales per month in that branch
WITH Monthly_Sales AS (
  SELECT Branch, MONTHNAME(Date) AS Month, SUM(Total) AS Sales
  FROM walmartsales
  GROUP BY Branch, Month
),
-- then we add new column as Prev_sales using LAG function which provides us with the data for the prevoius month
Growth_Calculator AS (
  SELECT Branch, Month, Sales,
  LAG(Sales) OVER (PARTITION BY Branch ORDER BY Month) AS Prev_Sales
  FROM Monthly_Sales
)
-- select * from Growth_Calc;
-- then we wanted the output as the percentage increase from the previous month has the maximun
SELECT Branch,Month,
       ROUND(((Sales - Prev_Sales) / Prev_Sales) * 100, 2) AS Percent_Growth_Rate
FROM Growth_Calculator
WHERE Prev_Sales IS NOT NULL
GROUP BY Branch,Month
ORDER BY Percent_Growth_Rate DESC
LIMIT 1;


-- Task 2 : Finding the Most Profitable Product Line for Each Branch (6 Marks)
-- 			Walmart needs to determine which product line contributes the highest profit to each branch.The profit margin
-- 			should be calculated based on the difference between the gross income and cost of goods sold.
-- started with getting a table where I grouped each bracnh and respective productline to get total profit from each branch
WITH Profits AS (
  SELECT Branch, `Product line`, SUM(`gross income`) AS Total_Profit
  FROM walmartsales
  GROUP BY Branch, `Product line`
),
-- then I ranked them in order inside each branch and product line by keeping highest at top and so on
Profit_Ranking AS (
  SELECT *, RANK() OVER (PARTITION BY Branch ORDER BY Total_Profit DESC) AS profit_rank
  FROM Profits
)
-- select * from Profit_Ranking;
-- then got the output only for those things which are at the top or rank = 1
SELECT Branch,`Product line`,Total_Profit
FROM Profit_Ranking
WHERE profit_rank = 1;


-- Task 3 : Analyzing Customer Segmentation Based on Spending (6 Marks)
-- 			Walmart wants to segment customers based on their average spending behavior. Classify customers into three
-- 			tiers: High, Medium, and Low spenders based on their total purchase amounts.
SELECT `Customer ID`,round(sum(Total),2) AS Total_sales,
	CASE
	WHEN round(sum(Total),2) > 23000 THEN 'High'
	WHEN round(sum(Total),2) BETWEEN 21000 AND 23000 THEN 'Medium'
	ELSE 'Low'
	END AS spenders_category
FROM walmartsales
group by `Customer ID`;

-- Task 4 : Detecting Anomalies in Sales Transactions (6 Marks)
-- 			Walmart suspects that some transactions have unusually high or low sales compared to the average for the
-- 			product line. Identify these anomalies.
WITH productdata AS (
SELECT `Product line`,round(AVG(Total),2) AS avg_total,round(stddev(Total),2) AS std_total
FROM walmartsales
GROUP BY `Product line`),
-- SELECT * FROM productdata;
annomalities AS (
SELECT w.`Product line`, pd.avg_total,pd.std_total 
FROM productdata pd JOIN walmartsales w ON w.`Product line` = pd.`Product line`
WHERE w.Total > pd.avg_total + 2 * pd.std_total OR w.total < pd.avg_total - 2 * pd.std_total
)
SELECT * , avg_total + 2 * std_total AS high_threshold , avg_total - 2 * std_total AS low_threshold 
FROM annomalities;

-- Task 5 : Most Popular Payment Method by City (6 Marks)
-- 			Walmart needs to determine the most popular payment method in each city to tailor marketing strategies.
SELECT City, Payment
FROM (
	SELECT City, Payment, 
    RANK() OVER (PARTITION BY City ORDER BY COUNT(*) DESC) AS payment_rank
	FROM walmartsales
	GROUP BY City, Payment
) popular_payment
WHERE payment_rank = 1;


-- Task 6 : Monthly Sales Distribution by Gender (6 Marks)
-- 			Walmart wants to understand the sales distribution between male and female customers on a monthly basis.
SELECT MONTHNAME(Date) AS month, Gender, SUM(Total) AS Total_sales
FROM walmartsales
GROUP BY month , Gender
ORDER BY month , Gender;


-- Task 7 : Best Product Line by Customer Type (6 Marks)
-- 			Walmart wants to know which product lines are preferred by different customer types(Member vs. Normal).
WITH Customer_Product AS (
  SELECT `Customer type`, `Product line`, SUM(Total) AS Revenue
  FROM walmartsales
  GROUP BY `Customer type`, `Product line`
),
Ranked_Product AS (
  SELECT *, RANK() OVER (PARTITION BY `Customer type` ORDER BY Revenue DESC) AS ranking
  FROM Customer_Product
)
SELECT `Customer type`, `Product line`, Revenue
FROM Ranked_Product
WHERE ranking = 1;


-- Task 8 : Identifying Repeat Customers (6 Marks)
-- 			Walmart needs to identify customers who made repeat purchases within a specific time frame (e.g., within 30 Days)
SELECT DISTINCT `Customer ID`
FROM (
    SELECT `Customer ID`, Date,
           LAG(Date) OVER (PARTITION BY `Customer ID` ORDER BY Date) AS prev_date
    FROM walmartsales
) AS sub
WHERE DATEDIFF(Date, prev_date) <= 30;


-- Task 9 : Finding Top 5 Customers by Sales Volume (6 Marks)
-- 			Walmart wants to reward its top 5 customers who have generated the most sales Revenue.
SELECT `Customer ID` , ROUND(SUM(Total), 2) AS Total_sales
FROM walmartsales
GROUP BY `Customer ID`
ORDER BY Total_sales DESC
LIMIT 5;


-- Task 10 : Analyzing Sales Trends by Day of the Week (6 Marks)
-- 			 Walmart wants to analyze the sales patterns to determine which day of the week
-- 			 brings the highest sales
SELECT DAYNAME(Date) AS Day_of_week , ROUND(SUM(Total), 2) AS Total_sales
FROM walmartsales
GROUP BY Day_of_week
ORDER BY Total_sales DESC;
