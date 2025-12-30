-- 1. League Admins - Player Eligibility: 
-- Which players across all programs are at risk of becoming ineligible next season due to having 
-- only one year of eligibility left?
SELECT
    p.first_name,
    p.last_name,
    pr.university_name,
    t.team_name,
    COUNT(DISTINCT s.season_id) AS seasons_played,
    4 - COUNT(DISTINCT s.season_id) AS years_left
FROM player p
JOIN roster r ON p.player_id = r.player_id AND p.years_eligibility = 1
JOIN team t ON r.team_id = t.team_id
JOIN program pr ON t.program_id = pr.program_id
JOIN season s ON r.season_id = s.season_id
GROUP BY
    p.player_id,
    pr.university_name,
    t.team_name,
    p.first_name,
    p.last_name
ORDER BY
    pr.university_name,
    p.last_name;

-- 2. League Admins - Playoff Implications: 
-- Which teams are currently leading their leagues by points in the standings?
SELECT
    l.league_name,
    t.team_name,
    st.points,
    st.wins,
    st.losses
FROM standings st
JOIN team t 
    ON st.team_id = t.team_id
JOIN league l 
    ON t.league_id = l.league_id
ORDER BY l.league_name, st.points DESC;



-- 3. Teams/Coaches - Player Development Path Success
-- Which development backgrounds (high school, prep, juniors) produce the highest-scoring ACHA players?
SELECT
    d.last_level AS development_background,
    ROUND(AVG(cs.career_points * 1.0 / cs.career_gp), 2) AS avg_ppg
FROM player AS p
JOIN development AS d ON p.development_id = d.development_id
JOIN career_stats AS cs ON p.player_id = cs.player_id
WHERE cs.career_gp >= 5   -- only accouting for players with reasonable sample size
GROUP BY d.last_level
ORDER BY avg_ppg DESC;

-- 4. Teams/Coaches - Recruiting Target Programs
-- Which programs have produced the most high-impact ACHA players(top 20 in points-per-game)
WITH top_players AS (
    SELECT
        p.player_id,
        (cs.career_points / cs.career_gp) AS ppg
    FROM player p
    JOIN career_stats cs 
          ON p.player_id = cs.player_id
    WHERE cs.career_gp >= 5
    ORDER BY ppg DESC
    LIMIT 20
)
SELECT
    pr.university_name,
    COUNT(*) AS num_elite_players
FROM top_players tp
JOIN player p 
      ON tp.player_id = p.player_id
JOIN roster r 
      ON p.player_id = r.player_id
JOIN team t 
      ON r.team_id = t.team_id
JOIN program pr 
      ON t.program_id = pr.program_id
GROUP BY pr.university_name
ORDER BY num_elite_players DESC;

-- 5. Teams/Coaches - Best Two-Way Forwards
-- Which forwards are both offensively productive and defensively responsible?
SELECT 
    p.first_name,
    p.last_name,
    pr.university_name,
    cs.career_points,
    cs.career_plus_minus,
    cs.career_gp,
    ROUND(cs.career_points / cs.career_gp, 2) AS ppg,
    ROUND(cs.career_plus_minus / cs.career_gp, 2) AS plus_minus_per_game
FROM player p
JOIN career_stats cs ON p.player_id = cs.player_id
JOIN roster r ON p.player_id = r.player_id
JOIN team t ON r.team_id = t.team_id
JOIN program pr ON t.program_id = pr.program_id
WHERE p.position = 'F'
  AND cs.career_gp >= 3
  AND cs.career_points / cs.career_gp > 0.4  -- Offensively productive
  AND cs.career_plus_minus > 0  -- Positive overall impact
ORDER BY (cs.career_points / cs.career_gp) + (cs.career_plus_minus / cs.career_gp * 0.5) DESC
LIMIT 20;

-- 6. Current/Prospective Players - Performance Trend:
-- Am I improving over time from season to season by seeing all their stats from each season?
SELECT 
    s.season_name,
    COUNT(gs.stats_id) AS games_played,
    SUM(gs.goals) AS goals,
    SUM(gs.assists) AS assists,
    SUM(gs.points) AS points,
    ROUND(SUM(gs.points) / COUNT(gs.stats_id), 2) AS ppg,
    SUM(gs.plus_minus) AS plus_minus
FROM game_stats gs
JOIN game g ON gs.game_id = g.game_id
JOIN season s ON g.season_id = s.season_id
WHERE gs.player_id = 50 -- Insert your player_id here
GROUP BY s.season_id, s.season_name
ORDER BY s.year_start;

-- 7.Current / Prospective Players — Workload and Opportunity
-- Which teams give rookies (first-year eligible players) the most ice-time opportunity 
-- which can be measured by average points and minutes per freshman?
WITH first_season AS (
    SELECT
        r.player_id,
        MIN(r.season_id) AS first_season_id
    FROM roster r
    GROUP BY r.player_id
),
freshmen AS (
    SELECT
        fs.player_id,
        fs.first_season_id,
        r.team_id,
        SUM(gs.points) AS rookie_points,
        SEC_TO_TIME(SUM(TIME_TO_SEC(gs.toi))) AS rookie_minutes
    FROM first_season fs
    JOIN roster r 
        ON r.player_id = fs.player_id
       AND r.season_id = fs.first_season_id
    JOIN game_stats gs 
        ON gs.player_id = fs.player_id
    JOIN game g 
        ON g.game_id = gs.game_id
       AND g.season_id = fs.first_season_id
    GROUP BY fs.player_id, fs.first_season_id, r.team_id
)
SELECT
    t.team_name,
    ROUND(AVG(f.rookie_points), 2) AS avg_freshman_points,
    SEC_TO_TIME(AVG(TIME_TO_SEC(f.rookie_minutes))) AS avg_freshman_minutes
FROM freshmen f
JOIN team t 
    ON t.team_id = f.team_id
GROUP BY t.team_id
ORDER BY avg_freshman_points DESC;

-- 8. Parent/Fan - Analyze favorite/child player
-- Player spotlight: How does my favorite player’s (or any player) career look like?
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS player_name,
    p.position,
    p.shoots AS shooting_hand,
    p.height,
    p.weight_lbs,
    pr.university_name AS school,
    l.league_name,
    d.division_name,
    dev.last_level AS came_from,
    cs.career_gp AS games_played,
    cs.career_goals AS goals,
    cs.career_assists AS assists,
    cs.career_points AS points,
    ROUND(cs.career_points / cs.career_gp, 2) AS points_per_game,
    cs.career_plus_minus AS plus_minus,
    pos_rank.rank_in_position
FROM player p
JOIN career_stats cs ON p.player_id = cs.player_id
JOIN roster r ON p.player_id = r.player_id
JOIN team t ON r.team_id = t.team_id
JOIN program pr ON t.program_id = pr.program_id
JOIN league l ON t.league_id = l.league_id
JOIN division d ON l.division_id = d.division_id
LEFT JOIN development dev ON p.development_id = dev.development_id
JOIN (
    SELECT 
        p2.player_id,
        RANK() OVER (PARTITION BY p2.position ORDER BY cs2.career_points DESC) AS rank_in_position
    FROM player p2
    JOIN career_stats cs2 ON p2.player_id = cs2.player_id
) pos_rank ON p.player_id = pos_rank.player_id
WHERE p.player_id = 15 -- Set the number to the player_id of whichever player you are looking for
  AND r.season_id = (SELECT MAX(season_id) FROM season);
  
-- 9. Parent/Fan use case - Analyze teamates of child
-- Which teammates are graduating with my child? How did they do?
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS graduating_player,
    p.position,
    dev.last_level AS development_background,
    cs.career_gp AS games_played,
    cs.career_goals AS goals,
    cs.career_assists AS assists,
    cs.career_points AS points,
    CASE 
        WHEN cs.career_points >= 15 THEN 'Star Player'
        WHEN cs.career_points >= 9 THEN 'Key Contributor'
        ELSE 'Role Player'
    END AS team_role
FROM player p
JOIN roster r ON p.player_id = r.player_id
JOIN team t ON r.team_id = t.team_id
JOIN program pr ON t.program_id = pr.program_id
LEFT JOIN development dev ON p.development_id = dev.development_id
LEFT JOIN career_stats cs ON p.player_id = cs.player_id
WHERE pr.university_name LIKE CONCAT('%', 'Northeastern', '%') -- Use the team you're interested in here
  AND r.season_id = (SELECT MAX(season_id) FROM season)
  AND (
      SELECT COUNT(DISTINCT r2.season_id) 
      FROM roster r2 
      WHERE r2.player_id = p.player_id
  ) >= p.years_eligibility - 1
ORDER BY cs.career_points DESC;

-- 10. Parent/Fan use case - Rivalries
-- Which pair of teams produced the closest average score margins this season, indicating a true rivalry?
SELECT
    LEAST(t1.team_name, t2.team_name) AS team_a,
    GREATEST(t1.team_name, t2.team_name) AS team_b,
    ROUND(AVG(ABS(g.home_score - g.away_score)), 2) AS avg_margin
FROM game AS g
JOIN team AS t1 ON g.home_team_id = t1.team_id
JOIN team AS t2 ON g.away_team_id = t2.team_id
GROUP BY team_a, team_b
HAVING COUNT(*) >= 2
ORDER BY avg_margin ASC
LIMIT 10;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 