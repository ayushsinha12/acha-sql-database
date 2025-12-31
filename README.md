# ACHA(American Collegiate Hockey Association) Database

## Project Overview
This project implements a normalized relational database for the American Collegiate Hockey Association(ACHA), a collegiate club hockey league, to centralize information that is often fragmented across teams and leagues. The database supports league operations and analytics by storing divisions, leagues, programs, teams, seasons, games, rosters, and player statistics in a queryable MySQL schema. In addition to standard relational design, the project includes stored procedures and triggers to automate common administrative workflows and enforce data integrity.

## Stakeholders & Example Use Cases
**League Administrators**
- Identify players approaching eligibility limits and validate eligibility constraints.
- Track standings and determine league leaders by season.

**Teams & Coaches**
- Analyze player performance and efficiency (e.g., points-per-game with meaningful game thresholds).
- Evaluate how development background relates to scoring efficiency and impact.
- Identify high-impact programs producing top performers.

**Current & Prospective Players**
- View season-by-season performance trends and usage (e.g., TOI-based opportunity).
- Compare rookie contributions and opportunities across teams.

**Fans & Families**
- Pull a player’s career overview and context (program/league/division) with key stats.
- Explore rivalry-style matchups using repeated close score margins.

## Motivation
The NCAA governs varsity college athletics, and among its sports is ice hockey. Across Men's
and Women's programs, the NCAA oversees ~200 teams. Meanwhile, the American Collegiate
Hockey Association (ACHA) governs club hockey and oversees ~530 teams across 3 Men's and
2 Women's divisions. Given the nature of club hockey, there is limited coverage and funding
available despite the vast number of teams and participants. Often this leads to confusion about
players, teams, schedules, and even results, across such a vast and complex web of games.
Creating a centralized and queryable database that is open to all would allow teams, coaches,
family members, and even fans (of which there are few) to better understand the landscape of
club hockey and where they stand at a given point. This database could track players, teams,
leagues, divisions, statistics, and results all in one place, allowing users to quickly determine
important information, rather than having to ask around or wait for data that may be out of date
to be released.

## Goal
The goal of this project is to create a queryable database that allows users to upload and access real-time data about game results and player information in the ACHA. By democratizing access to
this information, the hope is that collegiate club hockey can gain transparency and a higher
degree of professionalism. In doing so, the experience for players, coaches, and families can be
improved.

This app is intended to provide the ACHA with a similar level of data accessibility
compared to NCAA and professional hockey, despite the organization's unique challenges (more
players, less funding, more schools, etc.). By creating a queryable database and augmenting it with stored procedures and triggers, non-administrators can find information that is pertinent to
them.

## Database Design
The database structure was created in MySQL Workbench, with a focus on:
1. Designing normalized tables with appropriate relationships
2. Establishing entity-relationship models
3. Creating stored procedures and triggers to automate and simplify common application operations such as eligibility notifications and season/game rollover
4. Developing a data model that allows for future scaling and feature expansion

Below is the ER diagram that shows the entire database design:
<div align="center">
  <img src="bloggingFeed.png" width="666" height="383">
</div>
<p align="center">
  Above is an example home page.
</p>

