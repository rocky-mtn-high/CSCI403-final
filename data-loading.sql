SET search_path TO f23_group2;

--The Office first
--Episodes
DROP TABLE IF EXISTS the_office_episodes_raw CASCADE;
CREATE TABLE the_office_episodes_raw (
    season NUMERIC(1) NOT NULL,
    episode_in_season NUMERIC(2) NOT NULL,
    episode_overall NUMERIC(3) NOT NULL UNIQUE,
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    prod_code NUMERIC(4),
    us_viewers FLOAT,
	CONSTRAINT UC_the_office_episodes_raw UNIQUE (season, episode_in_season)
);

\COPY the_office_episodes_raw FROM './data/office_episodes.csv' WITH CSV HEADER;

--IMDB ratings
DROP TABLE IF EXISTS the_office_ratings_raw CASCADE;
CREATE TABLE the_office_ratings_raw (
   season NUMERIC(1) NOT NULL,
   episode_in_season NUMERIC(2) NOT NULL,
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT,
   CONSTRAINT UC_the_office_ratings_raw UNIQUE (season, episode_in_season)
);

\COPY the_office_ratings_raw FROM './data/office_imdb.csv' WITH CSV HEADER;

--Then parks and rec
--Episodes
DROP TABLE IF EXISTS parks_and_recreation_episodes_raw CASCADE;
CREATE TABLE parks_and_recreation_episodes_raw (
    season NUMERIC(1) NOT NULL,
    episode_in_season NUMERIC(2) NOT NULL,
    episode_overall NUMERIC(3) NOT NULL UNIQUE,
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    us_viewers FLOAT,
	CONSTRAINT UC_parks_and_recreation_episodes_raw UNIQUE (season, episode_in_season)
);

\COPY parks_and_recreation_episodes_raw FROM './data/parks_and_rec_episodes.csv' WITH CSV HEADER;

--IMDB ratings
DROP TABLE IF EXISTS parks_and_recreation_ratings_raw CASCADE;
CREATE TABLE parks_and_recreation_ratings_raw (
   season NUMERIC(1) NOT NULL,
   episode_in_season NUMERIC(2) NOT NULL,
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT,
   CONSTRAINT UC_parks_and_recreation_ratings_raw UNIQUE (season, episode_in_season)
);

\COPY parks_and_recreation_ratings_raw FROM './data/parks_and_rec_imdb.csv' WITH CSV HEADER;

--Episodes table
DROP TABLE IF EXISTS episode CASCADE;
CREATE TABLE episode (
	show TEXT,
    season NUMERIC(1),
    episode_in_season NUMERIC(2),
    title TEXT,
    director TEXT,
    air_date DATE,
    us_viewers INT,
	rating NUMERIC(2, 1),
	total_votes NUMERIC(5),
    description TEXT,
	PRIMARY KEY (show, season, episode_in_season)
);
ALTER TABLE f23_group2.episode OWNER TO f23_group2;

INSERT INTO episode (show, season, episode_in_season, title, director, air_date, us_viewers)
SELECT 'The Office', season, episode_in_season, title, director, air_date, us_viewers
FROM the_office_episodes_raw;

UPDATE episode
SET rating = r.rating, total_votes = r.total_votes, description = r.description
FROM the_office_ratings_raw AS r
WHERE episode.show = 'The Office' AND episode.season = r.season AND episode.episode_in_season = r.episode_in_season;

INSERT INTO episode (show, season, episode_in_season, title, director, air_date, us_viewers)
SELECT 'Parks and Recreation', season, episode_in_season, title, director, air_date, us_viewers
FROM parks_and_recreation_episodes_raw;

UPDATE episode
SET rating = r.rating, total_votes = r.total_votes, description = r.description
FROM parks_and_recreation_ratings_raw AS r
WHERE episode.show = 'Parks and Recreation' AND episode.season = r.season AND episode.episode_in_season = r.episode_in_season;

--Separate writers into own table (multi-valued)
DROP TABLE IF EXISTS episode_writer CASCADE;
CREATE TABLE episode_writer (
	name TEXT,
	episode_show TEXT,
	episode_season NUMERIC(1),
	episode_episode_in_season NUMERIC(2),
	CONSTRAINT FK_episode_writers FOREIGN KEY (episode_show, episode_season, episode_episode_in_season) REFERENCES episode(show, season, episode_in_season)
);
ALTER TABLE f23_group2.episode_writer OWNER TO f23_group2;

INSERT INTO episode_writer SELECT regexp_split_to_table(writer,E' and | & '), 'The Office', season, episode_in_season FROM the_office_episodes_raw;
INSERT INTO episode_writer SELECT regexp_split_to_table(writer,E' and | & '), 'Parks and Recreation', season, episode_in_season FROM parks_and_recreation_episodes_raw;

--Cleanup
DROP TABLE the_office_episodes_raw;
DROP TABLE the_office_ratings_raw;
DROP TABLE parks_and_recreation_episodes_raw;
DROP TABLE parks_and_recreation_ratings_raw;

--Test statements
--SELECT show, COUNT(*), AVG(rating) FROM episode GROUP BY show;
--SELECT * FROM episode WHERE rating IS NOT NULL ORDER BY rating DESC LIMIT 1;
--SELECT name, COUNT(*) FROM episode_writer GROUP BY name ORDER BY COUNT(*) DESC LIMIT 1;