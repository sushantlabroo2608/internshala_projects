CREATE DATABASE assignment2;
USE assignment2;
SELECT * FROM games;
SELECT * FROM game_sales;

-- Change datatype of ReleaseDate
ALTER TABLE games MODIFY ReleaseDate DATE;

-- Task 1: Insert a new game with the title "Future Racing", genre "Racing", release date "2024-10-01", and developer "Speed Studios".
INSERT INTO games(GameTitle,Genre,ReleaseDate,Developer) 
VALUES ('Future Racing','Racing','2024-10-01','Speed Studios');

-- Task 2: Update the price of the game with GameID 2 on the PlayStation platform to 60.
UPDATE game_sales SET price = 60
WHERE GameID = 2 AND Platform = 'Playstation' 
LIMIT 1;

-- Task 3: Delete the record of the game with GameID 5 from the Game Sales table
DELETE FROM game_sales 
WHERE GameID = 5 
LIMIT 1;

-- Task 4: Calculate the total number of units sold for each game across all platforms and regions
SELECT 
	gs.platform,
    gs.SalesRegion,
    g.gameTitle,
    SUM(gs.UnitsSold) AS TotalUnitsSold
FROM
    games g
        JOIN
    game_sales gs ON g.GameID = gs.GameID
GROUP BY gs.Platform , gs.SalesRegion,g.gameTitle;

-- Task 5: Identify the game with the highest number of units sold in North America.
SELECT 
    g.GameTitle
FROM
    games g
        JOIN
    game_sales gs ON g.GameID = gs.GameID
WHERE
    gs.SalesRegion = 'North America'
GROUP BY g.GameTitle
ORDER BY MAX(gs.UnitsSold)
LIMIT 1;

-- Task 6: Get the game titles, platforms, and sales regions along with the units sold for each game.
SELECT g.GameTitle, gs.Platform, gs.SalesRegion, gs.unitsSold
FROM game_sales gs
JOIN games g ON gs.GameID = g.GameID;

-- Task 7: Find all games, including those that have no sales data in the Game Sales table
SELECT g.GameID,g.GameTitle,gs.Platform,gs.SalesRegion,gs.UnitsSold
FROM games g
LEFT JOIN game_sales gs ON g.GameID = gs.GameID;

-- Task 8: Retrieve sales records where the game details are missing in the Games table.
SELECT gs.*
FROM game_sales gs
LEFT JOIN games g ON gs.GameID = g.GameID
WHERE g.GameID IS NULL;

-- Task 9: Retrieve game sales data for North America and Europe removing duplicate records
SELECT DISTINCT *
FROM game_sales
WHERE SalesRegion IN ('North America' , 'Europe');

-- Task 10: Retrieve all game sales data from North America and Europe without removing duplicate records.
SELECT *
FROM game_sales
WHERE SalesRegion IN ('North America' , 'Europe');




