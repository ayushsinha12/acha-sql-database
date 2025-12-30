
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
    CONSTRAINT fk_stats_opponent FOREIGN KEY (opponent_team_id) REFERENCES team(team_id)
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

-- END OF TABLE CREATION

-- DATA IMPORT

-- =============================================================================
-- INSTRUCTIONS: 
-- 1. Find and Replace the path below with your own:
--    Find:    /Users/kylewilson/Desktop/academics/CS3200/Final Project/Data
--    Replace: /your/path/here
-- =============================================================================

SET GLOBAL local_infile = 1;


USE hockey_db;

-- Load each table
-- Start with tables that have no dependencies

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/division.csv'
INTO TABLE division
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/program.csv'
INTO TABLE program
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/season.csv'
INTO TABLE season
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/development.csv'
INTO TABLE development
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/league.csv'
INTO TABLE league
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/team.csv'
INTO TABLE team
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/player.csv'
INTO TABLE player
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/game.csv'
INTO TABLE game
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/standings.csv'
INTO TABLE standings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/roster.csv'
INTO TABLE roster
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/game_stats.csv'
INTO TABLE game_stats
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/kylewilson/Desktop/academics/CS3200/Final Project/Data/career_stats.csv'
INTO TABLE career_stats
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
