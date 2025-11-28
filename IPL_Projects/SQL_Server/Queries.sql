USE IPL;
SELECT * FROM IPLPlayers;

-- Distinct values
SELECT DISTINCT Team FROM IPLPlayers;
SELECT DISTINCT Role FROM IPLPlayers;
SELECT DISTINCT type FROM IPLPlayers;
SELECT DISTINCT Acquisition FROM IPLPlayers;

--------------------------------------------------------------------------------
-- Q1: Find the total spending on players for each team
SELECT 
    Team,
    SUM(Price_in_cr) AS Total_Spending
FROM IPLPlayers
GROUP BY Team
ORDER BY Total_Spending DESC;

--------------------------------------------------------------------------------
-- Q2: Find the top 3 highest-paid 'All-rounders' across all teams
SELECT TOP 3 
    Player,
    SUM(Price_in_cr) AS highest_paid
FROM IPLPlayers
WHERE role = 'All-rounder'
GROUP BY Player
ORDER BY highest_paid DESC;

--------------------------------------------------------------------------------
-- Q3: Find the highest-priced player in each team
SELECT Team, Player, Max_price
FROM (
    SELECT 
        Team,
        Player,
        Price_in_cr,
        MAX(Price_in_cr) OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Max_price,
        RANK() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Rank
    FROM IPLPlayers
) t
WHERE Rank = 1;

--------------------------------------------------------------------------------
-- Q4: Rank players by their price within each team and list the top 2
SELECT *
FROM (
    SELECT 
        Team,
        Player,
        Price_in_cr,
        MAX(Price_in_cr) OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Max_price,
        RANK() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Rank
    FROM IPLPlayers
) t
WHERE Rank <= 2;

--------------------------------------------------------------------------------
-- Q5: Most expensive player and second-most expensive per team
WITH top2 AS (
    SELECT 
        Team,
        Player,
        Price_in_cr,
        ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS rn
    FROM IPLPlayers
)
SELECT 
    Team,
    MAX(CASE WHEN rn = 1 THEN Player END) AS player1,
    MAX(CASE WHEN rn = 1 THEN Price_in_cr END) AS price1,
    MAX(CASE WHEN rn = 2 THEN Player END) AS player2,
    MAX(CASE WHEN rn = 2 THEN Price_in_cr END) AS price2
FROM top2
GROUP BY Team;

--------------------------------------------------------------------------------
-- Q6: Percentage contribution of each player's price to their team's total spending
SELECT 
    Team,
    Player,
    CAST(Price_in_cr / SUM(Price_in_cr) OVER (PARTITION BY Team) * 100 AS DECIMAL(10,2)) AS Percentage
FROM IPLPlayers;

--------------------------------------------------------------------------------
-- Q7: Classify players as High/Medium/Low priced and count
SELECT 
    cat,
    COUNT(cat)
FROM (
    SELECT 
        Player,
        Price_in_cr,
        CASE 
            WHEN Price_in_cr > 15 THEN 'High'
            WHEN Price_in_cr >= 5 AND Price_in_cr < 15 THEN 'Medium'
            WHEN Price_in_cr < 5 THEN 'Low'
        END AS cat
    FROM IPLPlayers
) t
GROUP BY cat;

--------------------------------------------------------------------------------
-- Q8: Average price of Indian vs Overseas players
SELECT DISTINCT type FROM IPLPlayers;

SELECT 
    newtype,
    AVG(p)
FROM (
    SELECT 
        type,
        Price_in_cr AS p,
        REPLACE(LEFT(type, CHARINDEX('(', type) - 1), 'Indian ', 'India') AS newtype
    FROM IPLPlayers
) t
GROUP BY newtype;

--------------------------------------------------------------------------------
-- Q9: Players earning more than their team's average
WITH cte1 AS (
    SELECT Team AS a, AVG(Price_in_cr) AS avgbyteam
    FROM IPLPlayers
    GROUP BY Team
),
cte2 AS (
    SELECT 
        tt.Team,
        tt.Player,
        tt.Price_in_cr,
        cte1.avgbyteam
    FROM IPLPlayers tt
    LEFT JOIN cte1 ON tt.Team = cte1.a
)
SELECT *
FROM cte2
WHERE Price_in_cr > avgbyteam;

--------------------------------------------------------------------------------
-- Q10: Most expensive player per role
SELECT *
FROM (
    SELECT 
        Player,
        Role,
        Price_in_cr,
        ROW_NUMBER() OVER (PARTITION BY Role ORDER BY Price_in_cr DESC) AS rn
    FROM IPLPlayers
) t
WHERE rn = 1;
