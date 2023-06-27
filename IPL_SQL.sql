USE ipl;
GO

--Q1
SELECT TOP(5) player_of_match , COUNT(*) as awards_count
FROM matches 
GROUP BY player_of_match 
ORDER BY awards_count DESC 

--Q2
SELECT season , winner as team , 
	   COUNT(*) as matches_won 
FROM matches 
GROUP BY season, winner 
ORDER By 1

--Q3
WITH batsman_stats as ( 
	SELECT batsman , 
			(SUM(total_runs) / COUNT(ball)) *100.0 as strike_rate 
	FROM deliveries 
	GROUP BY batsman )
SELECT AVG(strike_rate) as average_stirke_rate 
FROM batsman_stats

--Q4
WITH batting_first_name as(
	SELECT CASE WHEN win_by_runs > 0 then team1
	else team2
	END as batting_first
	FROM matches 
	WHERE winner!= 'Tie')
SELECT batting_first , COUNT(*) as matches_win 
FROM batting_first_name 
GROUP BY batting_first 

--Q5
SELECT TOP(1) batsman, ( SUM(batsman_runs) *100.0 /COUNT(*)) as strike_rate 
FROM deliveries 
GROUP BY batsman 
HAVING SUM(batsman_runs) >= 200 
ORDER BY strike_rate DESC 

--Q6

SELECT batsman, COUNT(*) as total_dismissals
FROM deliveries 
WHERE bowler = 'SL Malinga'
GROUP BY batsman

--Q7

SELECT batsman, AVG(CAST(CASE WHEN batsman_runs = 4 OR batsman_runs = 6 THEN 1 ELSE 0 END AS float))*100.0  AS average_boundaries
FROM deliveries
GROUP BY batsman
ORDER BY average_boundaries DESC
 
--Q8 
SELECT season ,batting_team, 
		AVG(fours+sixes) as avg_boundaries
FROM(
	SELECT season, match_id, batting_team, 
		SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) as fours,
		SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) as sixes
	FROM deliveries 
	INNER JOIN matches 
	ON deliveries.match_id = matches.id 
	GROUP BY season, match_id, batting_team) as team_bounsaries
GROUP BY season, batting_team

--Q9
SELECT season, batting_team, MAX(total_runs) as highest_partnership
FROM (
    SELECT season, batting_team, partnership, SUM(total_runs) as total_runs
    FROM (
        SELECT season, match_id, batting_team, over_no, 
            SUM(batsman_runs) as partnership,
            SUM(batsman_runs) + SUM(extra_runs) as total_runs
        FROM deliveries
        INNER JOIN matches ON deliveries.match_id = matches.id
        GROUP BY season, match_id, batting_team, over_no
    ) as team_scores
    GROUP BY season, batting_team, partnership
) as highest_partnership
GROUP BY season, batting_team

--Q10 
SELECT m.id as match_no , d.bowling_team, 
SUM(d.extra_runs) as extras
FROM matches as m
JOIN deliveries as d 
ON d.match_id = m.id
WHERE extra_runs > 0 
GROUP BY m.id ,d.bowling_team

--Q11
SELECT TOP(1) m.id as match_no, d.bowler, COUNT(*) as wickets_taken
FROM matches as m 
JOIN deliveries as d on d.match_id=m.id 
WHERE d.player_dismissed is not null 
GROUP BY m.id, d.bowler
ORDER BY wickets_taken DESC 

--Q12
SELECT city, winning_team, COUNT(*) AS wins
FROM (
    SELECT m.city,
        CASE
            WHEN m.team1 = m.winner THEN m.team1
            WHEN m.team2 = m.winner THEN m.team2
            ELSE 'draw'
        END AS winning_team
    FROM matches AS m
    JOIN deliveries AS d ON d.match_id = m.id
    WHERE m.result != 'Tie'
) AS subquery
GROUP BY city, winning_team
	