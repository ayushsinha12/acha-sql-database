
USE hockey_db;

DROP PROCEDURE IF EXISTS start_season;

delimiter //
CREATE PROCEDURE start_season
(
	IN year_start_var YEAR
)
BEGIN
    DECLARE new_season_id_var INT;
    DECLARE prev_season_id_var INT;
    
    SELECT season_id INTO prev_season_id_var
    FROM season
    where year_end = year_start_var;
    
   IF EXISTS (SELECT 1 FROM season WHERE year_start = year_start_var) THEN
        SIGNAL SQLSTATE 'HY000'
            SET MESSAGE_TEXT = 'This season already exists';
    END IF;
	
    -- Create season

    INSERT INTO season (year_start, year_end, season_name) 
    VALUES (
        year_start_var, 
        year_start_var + 1, 
        CONCAT(year_start_var, '-', year_start_var + 1)
    );

    SET new_season_id_var = LAST_INSERT_ID();
    
    -- Initialize new rosters for upcoming season (if no prev season, won't do anything)
    
    INSERT INTO roster (player_id, season_id, team_id)
    SELECT
		r.player_id,
        new_season_id_var,
        r.team_id
	FROM roster r join player p
		ON r.player_id = p.player_id
	WHERE r.season_id = prev_season_id_var AND
		p.years_eligibility > 0;
    
    
    -- Initialize new season of standings
    
    INSERT INTO standings (team_id, league_id, season_id)
    SELECT 
		t.team_id,
        t.league_id,
        new_season_id_var
	FROM team t join standings s
		ON s.team_id = t.team_id AND s.season_id = prev_season_id_var;


END //
delimiter ;


DROP PROCEDURE IF EXISTS finish_season;

delimiter //
CREATE PROCEDURE finish_season()
BEGIN

	DECLARE player_id_var INT;
    DECLARE years_eligibility_var INT;
	DECLARE row_not_found TINYINT DEFAULT FALSE;
    DECLARE start_year_var INT;


	DECLARE update_eligibility_cursor CURSOR FOR
		SELECT player_id, years_eligibility FROM player;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET row_not_found = TRUE;
        
	SELECT year_end INTO start_year_var
    FROM season
    ORDER BY year_end DESC;

	-- Update eligibility
    
	OPEN update_eligibility_cursor;

	FETCH update_eligibility_cursor INTO player_id_var, years_eligibility_var;
	WHILE row_not_found = FALSE DO
		UPDATE player
        SET years_eligibility = years_eligibility_var - 1
        WHERE player_id = player_id_var AND years_eligibility > 0;
		
		FETCH update_eligibility_cursor INTO player_id_var, years_eligibility_var;
	END WHILE;
    
    CLOSE update_eligibility_cursor;
    
    
	-- Initialize new season
    CALL start_season(start_year_var);


END //
delimiter ;


DROP PROCEDURE IF EXISTS schedule_game;

delimiter //
CREATE PROCEDURE schedule_game
(
	IN season_id INT,
	IN date_var DATE,
    IN time_var TIME,
    IN home_team_id INT,
    IN away_team_id INT,
    IN venue VARCHAR(45),
    IN game_type VARCHAR(45)

)
BEGIN

	IF home_team_id = away_team_id THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Home and away teams must be diferent';
	END IF;
    
    IF home_team_id NOT IN (SELECT team_id FROM team) OR 
		away_team_id NOT IN (SELECT team_id FROM team) THEN
			SIGNAL SQLSTATE 'HY000'
            SET MESSAGE_TEXT = 'One of the inputted teams does not exist in the team table';
	END IF;
    
    INSERT INTO game (game_date, game_time, home_team_id, away_team_id, season_id, venue, game_type)
		VALUES (date_var, time_var, home_team_id, away_team_id, season_id, venue, game_type);

END //
delimiter ;


DROP PROCEDURE IF EXISTS finalize_game;

delimiter //
CREATE PROCEDURE finalize_game
(
	IN game_id_var INT,
    IN home_score_var INT,
    IN away_score_var INT
)
BEGIN
    DECLARE home_team_id_var INT;
    DECLARE away_team_id_var INT;
    DECLARE season_id_var INT;
    DECLARE home_league_id INT;
    DECLARE away_league_id INT;


	IF home_score_var < 0 or away_score_var < 0 THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Both scores must be positive values';
	END IF;
    
    IF (SELECT game_id FROM game WHERE game_id = game_id_var != 1) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Game does not existo';
	END IF;
    
	SELECT home_team_id, away_team_id, season_id
    INTO home_team_id_var, away_team_id_var, season_id_var
    FROM game
    WHERE game_id = game_id_var;
    
	SELECT league_id INTO home_league_id
    FROM team WHERE team_id = home_team_id_var;
    
    SELECT league_id INTO away_league_id
    FROM team WHERE team_id = away_team_id_var;

	
    -- update game
	UPDATE game
	SET home_score = home_score_var, away_score = away_score_var
	WHERE game_id = game_id_var;
    
    
    -- update standings
    
    -- home win
	IF home_score_var > away_score_var THEN
        UPDATE standings
        SET games_played = games_played + 1,
            wins = wins + 1,
            goals_for = goals_for + home_score_var,
            goals_against = goals_against + away_score_var,
            points = points + 3
        WHERE team_id = home_team_id_var 
          AND season_id = season_id_var
          AND league_id = home_league_id;
          
        UPDATE standings
        SET games_played = games_played + 1,
            losses = losses + 1,
            goals_for = goals_for + away_score_var,
            goals_against = goals_against + home_score_var
        WHERE team_id = away_team_id_var 
          AND season_id = season_id_var
          AND league_id = away_league_id;
          
	-- away win
    ELSEIF home_score_var < away_score_var THEN
        UPDATE standings
        SET games_played = games_played + 1,
            losses = losses + 1,
            goals_for = goals_for + home_score_var,
            goals_against = goals_against + away_score_var
        WHERE team_id = home_team_id_var 
          AND season_id = season_id_var
          AND league_id = home_league_id;
          
        UPDATE standings
        SET games_played = games_played + 1,
            wins = wins + 1,
            goals_for = goals_for + away_score_var,
            goals_against = goals_against + home_score_var
        WHERE team_id = away_team_id_var 
          AND season_id = season_id_var
          AND league_id = away_league_id;
          
	-- tie
    ELSE
        UPDATE standings
        SET games_played = games_played + 1,
			ties = ties + 1,
            goals_for = goals_for + home_score_var,
            goals_against = goals_against + away_score_var,
            points = points + 1
        WHERE team_id = home_team_id_var 
          AND season_id = season_id_var
          AND league_id = home_league_id;
          
        UPDATE standings
        SET games_played = games_played + 1,
			ties = ties + 1,
            goals_for = goals_for + away_score_var,
            goals_against = goals_against + home_score_var,
            points = points + 1
        WHERE team_id = away_team_id_var 
          AND season_id = season_id_var
          AND league_id = away_league_id;
    END IF;
    


END//
delimiter ;


DROP PROCEDURE IF EXISTS record_game_stats;

delimiter //
CREATE PROCEDURE record_game_stats
(
	IN player_id_var INT,
    IN game_id_var INT,
    IN goals_var INT,
    IN assists_var INT,
    IN plus_minus_var INT,
    IN pims_var INT,
    IN toi_var TIME,
    IN sog_var INT
)
BEGIN
    DECLARE team_id_var INT;
    DECLARE opponent_team_id_var INT;
    DECLARE season_id_var INT;
    DECLARE is_home_var TINYINT(1);
    DECLARE points_var INT;


	IF goals_var < 0 OR assists_var < 0 OR pims_var < 0 
		OR sog_var < 0 OR toi_var < 0 THEN
			SIGNAL SQLSTATE 'HY000'
            SET MESSAGE_TEXT = 'One of the inputted stats is invalid';
	END IF;
    
    IF player_id_var NOT IN (SELECT player_id FROM player) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Inputted player does not exist';
	END IF;
    
    IF game_id_var NOT IN (SELECT game_id FROM game) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Inputted game does not exist';
	END IF;
    
	SET points_var = goals_var + assists_var;
	
    -- determining season_id, team_id, is_home, and opponent_id
    SELECT 
        g.season_id,
        r.team_id,
        CASE 
            WHEN r.team_id = g.home_team_id THEN 1
            ELSE 0
        END AS is_home,
        CASE 
            WHEN r.team_id = g.home_team_id THEN g.away_team_id
            ELSE g.home_team_id
        END AS opponent_team_id
    INTO season_id_var, team_id_var, is_home_var, opponent_team_id_var
    FROM game g
    JOIN roster r ON r.season_id = g.season_id AND r.player_id = player_id_var
    WHERE g.game_id = game_id_var;


	-- insert stats
    INSERT INTO game_stats (player_id, game_id, team_id, opponent_team_id, 
							is_home, goals, assists, points, plus_minus, pims, 
							sog, toi)
    VALUES (
        player_id_var,
        game_id_var,
        team_id_var,
        opponent_team_id_var,
        is_home_var,
        goals_var,
        assists_var,
        points_var,
        plus_minus_var,
        pims_var,
        sog_var,
        toi_var
    );

END//
delimiter ;


DROP TRIGGER IF EXISTS stats_aggregation;

delimiter //

CREATE TRIGGER stats_aggregation
AFTER INSERT ON game_stats
FOR EACH ROW
BEGIN


    UPDATE career_stats
    SET 
        career_gp = career_gp + 1,
        career_goals = career_goals + NEW.goals,
        career_assists = career_assists + NEW.assists,
        career_points = career_points + NEW.points,
        career_plus_minus = career_plus_minus + NEW.plus_minus,
        career_pims = career_pims + NEW.pims,
        career_sog = career_sog + NEW.sog,
        career_avg_toi = SEC_TO_TIME(
            (TIME_TO_SEC(IFNULL(career_avg_toi, '00:00:00')) * (career_gp - 1) + TIME_TO_SEC(NEW.toi)) / career_gp
        )
    WHERE player_id = NEW.player_id;
    
END//
delimiter ;



DROP TRIGGER IF EXISTS eligibility_check;

delimiter //

CREATE TRIGGER eligibility_check
BEFORE INSERT ON game_stats
FOR EACH ROW
BEGIN
	DECLARE gpa_var DECIMAL(3,2);
    DECLARE years_eligibility_var INT;

	SELECT gpa, years_eligibility INTO gpa_var, years_eligibility_var
    FROM player
    WHERE player_id = NEW.player_id;
    
    
    IF years_eligibility_var <= 0 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Player has exceded the amount of years eligible to play';
	END IF;
    
    
    IF gpa_var < 2.0 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Player ineligible to play due to low gpa';
	END IF;
    
    
END //

delimiter ;








