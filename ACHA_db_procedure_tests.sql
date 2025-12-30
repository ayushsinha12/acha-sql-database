
-- Hockey Database Schema

DROP DATABASE IF EXISTS hockey_db;
CREATE DATABASE IF NOT EXISTS hockey_db;
USE hockey_db;

-- DIVISION

DROP TABLE IF EXISTS division;
CREATE TABLE division (
    division_id INT PRIMARY KEY AUTO_INCREMENT,
    division_name VARCHAR(100) NOT NULL
);

-- PROGRAM

DROP TABLE IF EXISTS program;
CREATE TABLE program (
    program_id INT PRIMARY KEY AUTO_INCREMENT,
    university_name VARCHAR(125) NOT NULL
);

-- SEASON

DROP TABLE IF EXISTS season;
CREATE TABLE season (
    season_id INT PRIMARY KEY AUTO_INCREMENT,
    year_start INT NOT NULL,
    year_end INT NOT NULL,
    season_name VARCHAR(25) NOT NULL
);

-- DEVELOPMENT

DROP TABLE IF EXISTS development;
CREATE TABLE development (
    development_id INT PRIMARY KEY AUTO_INCREMENT,
    last_level VARCHAR(100) NOT NULL
);

-- LEAGUE

DROP TABLE IF EXISTS league;
CREATE TABLE league (
    league_id INT PRIMARY KEY AUTO_INCREMENT,
    league_name VARCHAR(100) NOT NULL,
    abbreviation VARCHAR(8) DEFAULT NULL,
    division_id INT NOT NULL,
    CONSTRAINT fk_league_division FOREIGN KEY (division_id) REFERENCES division(division_id)
);

-- TEAM

DROP TABLE IF EXISTS team;
CREATE TABLE team (
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    league_id INT NOT NULL,
    program_id INT NOT NULL,
    CONSTRAINT fk_team_league FOREIGN KEY (league_id) REFERENCES league(league_id),
    CONSTRAINT fk_team_program FOREIGN KEY (program_id) REFERENCES program(program_id)
);

-- PLAYER
DROP TABLE IF EXISTS player;
CREATE TABLE player (
    player_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(45) DEFAULT NULL,
    phone_number CHAR(10) DEFAULT NULL,
    birthday DATE DEFAULT NULL,
    position ENUM('F', 'D', 'G') DEFAULT NULL,
    shoots ENUM('L', 'R') DEFAULT NULL,
    height VARCHAR(5) DEFAULT NULL,
    weight_lbs DECIMAL(5,1) DEFAULT NULL,
    jersey_num VARCHAR(2) DEFAULT NULL,
    gender CHAR(1) DEFAULT NULL,
    gpa DECIMAL(3,2) NOT NULL,
	years_eligibility INT DEFAULT 5,
    development_id INT DEFAULT NULL,
    CONSTRAINT fk_player_development FOREIGN KEY (development_id) REFERENCES development(development_id)
);

-- GAME

DROP TABLE IF EXISTS game;
CREATE TABLE game (
    game_id INT PRIMARY KEY AUTO_INCREMENT,
    game_date DATE NOT NULL,
    game_time TIME DEFAULT NULL,
    home_score INT DEFAULT NULL,
    away_score INT DEFAULT NULL,
    venue VARCHAR(100) DEFAULT NULL,
    game_type VARCHAR(45) DEFAULT NULL,
    season_id INT NOT NULL,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    CONSTRAINT fk_game_season FOREIGN KEY (season_id) REFERENCES season(season_id),
    CONSTRAINT fk_game_home_team FOREIGN KEY (home_team_id) REFERENCES team(team_id),
    CONSTRAINT fk_game_away_team FOREIGN KEY (away_team_id) REFERENCES team(team_id),
    UNIQUE KEY unique_game_season (game_date, game_time, home_team_id, away_team_id, season_id)
);

-- STANDINGS

DROP TABLE IF EXISTS standings;
CREATE TABLE standings (
    standing_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    league_id INT NOT NULL,
    season_id INT NOT NULL,
    games_played INT DEFAULT 0,
    wins INT DEFAULT 0,
    losses INT DEFAULT 0,
    ties INT DEFAULT 0, 
    goals_for INT DEFAULT 0,
    goals_against INT DEFAULT 0,
    points INT DEFAULT 0,
    CONSTRAINT fk_standings_team FOREIGN KEY (team_id) REFERENCES team(team_id),
    CONSTRAINT fk_standings_league FOREIGN KEY (league_id) REFERENCES league(league_id),
    CONSTRAINT fk_standings_season FOREIGN KEY (season_id) REFERENCES season(season_id),
    UNIQUE KEY unique_team_season (team_id, season_id)
);

-- ROSTER

DROP TABLE IF EXISTS roster;
CREATE TABLE roster (
    roster_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    season_id INT NOT NULL,
    team_id INT NOT NULL,
    CONSTRAINT fk_roster_player FOREIGN KEY (player_id) REFERENCES player(player_id),
    CONSTRAINT fk_roster_season FOREIGN KEY (season_id) REFERENCES season(season_id),
    CONSTRAINT fk_roster_team FOREIGN KEY (team_id) REFERENCES team(team_id),
    UNIQUE KEY unique_player_season (player_id, season_id)
);

-- GAME_STATS

DROP TABLE IF EXISTS game_stats;
CREATE TABLE game_stats (
    stats_id INT PRIMARY KEY AUTO_INCREMENT,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    points INT DEFAULT 0,
    plus_minus INT DEFAULT 0,
    pims INT DEFAULT 0,
    sog INT DEFAULT 0,
    toi TIME DEFAULT NULL,
    player_id INT NOT NULL,
    game_id INT NOT NULL,
    team_id INT NOT NULL,
    is_home TINYINT(1) DEFAULT 0,
    opponent_team_id INT NOT NULL,
    CONSTRAINT fk_stats_player FOREIGN KEY (player_id) REFERENCES player(player_id),
    CONSTRAINT fk_stats_game FOREIGN KEY (game_id) REFERENCES game(game_id),
    CONSTRAINT fk_stats_team FOREIGN KEY (team_id) REFERENCES team(team_id),
    CONSTRAINT fk_stats_opponent FOREIGN KEY (opponent_team_id) REFERENCES team(team_id),
    UNIQUE KEY unique_game_stats (player_id, game_id)
);

-- CAREER_STATS

DROP TABLE IF EXISTS career_stats;
CREATE TABLE career_stats (
    career_stats_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    career_gp INT DEFAULT 0,
    career_goals INT DEFAULT 0,
    career_assists INT DEFAULT 0,
    career_points INT DEFAULT 0,
    career_plus_minus INT DEFAULT 0,
    career_pims INT DEFAULT 0,
    career_avg_toi TIME DEFAULT NULL,
    career_sog INT DEFAULT 0,
    CONSTRAINT fk_career_stats_player FOREIGN KEY (player_id) REFERENCES player(player_id),
    UNIQUE KEY unique_player (player_id)
);

-- Procedure testing insertions

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE career_stats;
TRUNCATE TABLE game_stats;
TRUNCATE TABLE roster;
TRUNCATE TABLE standings;
TRUNCATE TABLE game;
TRUNCATE TABLE player;
TRUNCATE TABLE team;
TRUNCATE TABLE league;
TRUNCATE TABLE program;
TRUNCATE TABLE season;
TRUNCATE TABLE development;
TRUNCATE TABLE division;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO division (division_id, division_name) VALUES (1, 'Division I');

INSERT INTO program (program_id, university_name) VALUES
(1, 'Adrian College'),
(2, 'Hope College');

INSERT INTO season (season_id, year_start, year_end, season_name) VALUES
(1, 2022, 2023, '2022-2023');

INSERT INTO development (development_id, last_level) VALUES (1, 'High School');

INSERT INTO league (league_id, league_name, abbreviation, division_id) VALUES
(1, 'Great Lakes Six', 'GL6', 1);

INSERT INTO team (team_id, team_name, league_id, program_id) VALUES
(1, 'Adrian Bulldogs', 1, 1),
(2, 'Hope Flying Dutchmen', 1, 2);

INSERT INTO player (player_id, first_name, last_name, position, gpa, years_eligibility, development_id) VALUES
(1, 'John', 'Smith', 'F', 3.50, 4, 1),
(2, 'Mike', 'Johnson', 'D', 3.20, 3, 1),
(3, 'Tom', 'Davis', 'G', 3.65, 5, 1),

(4, 'Kevin', 'Miller', 'F', 3.90, 4, 1),

-- 0 years eligibility
(5, 'Steve', 'Taylor', 'D', 3.40, 0, 1),

-- Below 2.0 GPA
(6, 'Paul', 'Anderson', 'G', 1.75, 1, 1);

INSERT INTO roster (player_id, season_id, team_id) VALUES
(1, 1, 1), (2, 1, 1), (3, 1, 1),
(4, 1, 2), (5, 1, 2), (6, 1, 2);

INSERT INTO career_stats (player_id) VALUES
(1), (2), (3), (4), (5), (6);

INSERT INTO standings (team_id, league_id, season_id) VALUES
(1, 1, 1),
(2, 1, 1);

-- Testing

select * from division;
select * from program;
select * from season;
select * from development;
select * from league;
select * from team;
select * from player;
select * from roster;
select * from career_stats;
select * from standings;

select * from game;

CALL schedule_game(1, '2022-11-11', '21:00:00', 1, 2, 'Adrian Arena', 'Regular');

select * from game;

CALL finalize_game(1,3,1);

select * from game;
select * from standings;

select * from player;
select * from roster;
select * from game_stats;
select * from career_stats;

CALL record_game_stats(1,1, 2, 0, 2, 2, '20:00:00', 5);
CALL record_game_stats(2,1, 1, 1, 3, 0, '20:30:00', 2);
CALL record_game_stats(3,1, 0, 2, 2, 4, '15:00:00', 3);
CALL record_game_stats(4,1, 0, 0, -2, 4, '22:00:00', 3);

-- Should error (exceded eligibility)
CALL record_game_stats(5,1, 1, 0, 0, 2, '18:00:00', 2);

-- Should error (low GPA)
CALL record_game_stats(6,1, 0, 1, 1, 0, '19:30:00', 1);

select * from game_stats;
select * from career_stats;

select * from player;

CALL finish_season();

select * from player;

select * from standings;
select * from roster;
select * from season;

-- Duplicate season should error
CALL start_season(2022);

-- No prev seasons so should just add to season table
CALL start_season(2035);
CALL start_season(1980);

select * from standings;
select * from roster;
select * from season;










