drop database assignment1;
CREATE DATABASE assignment1;
USE assignment1;
SELECT * FROM netflix_originals;

-- change data type of Premiere_Date
alter table netflix_originals add column premier date;
update netflix_originals set premier = str_to_date(Premiere_Date, '%d-%m-%Y') limit 584;
alter table netflix_originals drop column Premiere_Date;
alter table netflix_originals rename column premier to Premiere_Date;

-- Task1: Retrieve all Netflix Originals with an IMDb score greater than 7, runtime greater than 100 minutes, and the language is either English or Spanish.

SELECT * FROM netflix_originals
WHERE IMDBScore>7 AND Runtime>100 
AND Language IN ('English','Spanish');

-- Task2: Find the total number of Netflix Originals in each language, but only show those languages that have more than 5 titles.

SELECT Language,COUNT(Title) AS total_titles FROM netflix_originals
GROUP BY Language
HAVING total_titles>5;

-- Task3:  Get the top 3 longest-running movies in Hindi language sorted by IMDb score in descending order.

SELECT * FROM netflix_originals 
WHERE Language='Hindi' 
ORDER BY Runtime DESC, IMDBScore DESC 
LIMIT 3;

-- Task 4:Retrieve all titles that contain the word "House" in their name and have an IMDb score greater than 6.

SELECT * FROM netflix_originals 
WHERE Title LIKE '%House%'
AND IMDBScore > 6;

-- Task 5: Find all Netflix Originals released between the years 2018 and 2020 that are in either English, Spanish, or Hindi.

SELECT * FROM netflix_originals 
WHERE YEAR(Premiere_Date) BETWEEN 2018 AND 2020
AND Language IN ('English','Spanish','Hindi');

-- Task 6: Find all movies that either have a runtime less than 60 minutes or an IMDb score less than 5, sorted byPremiere Date

SELECT * FROM netflix_originals 
WHERE Runtime < 60 OR IMDBScore < 5 
ORDER BY Premiere_Date DESC;

-- Task 7: Get the average IMDb score for each genre where the genre has at least 10 movies.

SELECT GenreID,AVG(IMDBScore) AS avg_IMDB_score,COUNT(*) AS movies FROM netflix_originals
GROUP BY GenreID
HAVING movies >= 10;

-- Task 8:  Retrieve the top 5 most common runtimes for Netflix Originals.

SELECT Runtime,COUNT(*) AS occurrence FROM netflix_originals 
GROUP BY Runtime
ORDER BY occurrence DESC
LIMIT 5;

-- Task 9: List all Netflix Originals that were released in 2020, grouped by language, and show the total count of titles for each language

SELECT Language,COUNT(*) AS total_titles FROM netflix_originals
WHERE YEAR(Premiere_date) = 2020
GROUP BY Language;

-- Task 10: Create a new table that enforces a constraint on the IMDb score to be between 0 and 10 and the runtime to be greater than 30 minutes.

CREATE TABLE netflix_original (
    Title VARCHAR(255),
    GenreID VARCHAR(100),
    Runtime INT CHECK (Runtime > 30),
    IMDBScore DECIMAL(3 , 1) CHECK (IMDBScore BETWEEN 0 AND 10),
    Language VARCHAR(100),
    Premiere_Date DATE
);