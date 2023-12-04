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


DROP TABLE IF EXISTS the_office_episodes CASCADE;
CREATE TABLE the_office_episodes (
	id SERIAL PRIMARY KEY,
    season NUMERIC(1) NOT NULL,
    episode_in_season NUMERIC(2) NOT NULL,
    episode_overall NUMERIC(3) NOT NULL UNIQUE,
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    prod_code NUMERIC(4),
    us_viewers INT,
	CONSTRAINT UC_the_office_episodes UNIQUE (season, episode_in_season)
);

ALTER TABLE f23_group2.the_office_episodes OWNER TO f23_group2;
INSERT INTO the_office_episodes (season, episode_in_season, episode_overall, title, director, writer, air_date, prod_code, us_viewers) SELECT season, episode_in_season, episode_overall, title, director, writer, air_date, prod_code, CAST(us_viewers AS INT) FROM the_office_episodes_raw;
DROP TABLE the_office_episodes_raw;

--Separate writers into own table (multi-valued)
DROP TABLE IF EXISTS the_office_episode_writers CASCADE;
CREATE TABLE the_office_episode_writers (
	name TEXT,
	episode_id SERIAL,
	CONSTRAINT FK_the_office_episode_writers FOREIGN KEY (episode_id) REFERENCES the_office_episodes(id)
);
INSERT INTO the_office_episode_writers SELECT regexp_split_to_table(the_office_episodes.writer,E' and | & '), the_office_episodes.id FROM the_office_episodes;
ALTER TABLE the_office_episodes DROP COLUMN writer;
ALTER TABLE f23_group2.the_office_episode_writers OWNER TO f23_group2;


--IMDB ratings
DROP TABLE IF EXISTS the_office_ratings_raw CASCADE;
CREATE TABLE the_office_ratings_raw (
   season NUMERIC(1) NOT NULL,
   episode_in_season NUMERIC(2) NOT NULL,
   CONSTRAINT UC_the_office_ratings_raw UNIQUE (season, episode_in_season),
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

\COPY the_office_ratings_raw FROM './data/office_imdb.csv' WITH CSV HEADER;
DROP TABLE IF EXISTS the_office_ratings CASCADE;
CREATE TABLE the_office_ratings (
   episode_id SERIAL PRIMARY KEY,
   CONSTRAINT FK_the_office_ratings FOREIGN KEY (episode_id) REFERENCES the_office_episodes(id),
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

INSERT INTO the_office_ratings SELECT eps.id, rat.rating, rat.total_votes, rat.description FROM the_office_ratings_raw AS rat JOIN the_office_episodes AS eps ON rat.season = eps.season AND rat.episode_in_season = eps.episode_in_season;
ALTER TABLE f23_group2.the_office_ratings OWNER TO f23_group2;
DROP TABLE the_office_ratings_raw;

--Then parks and rec
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

DROP TABLE IF EXISTS parks_and_recreation_episodes CASCADE;
CREATE TABLE parks_and_recreation_episodes (
	id SERIAL PRIMARY KEY,
    season NUMERIC(1) NOT NULL,
    episode_in_season NUMERIC(2) NOT NULL,
    episode_overall NUMERIC(3) NOT NULL UNIQUE,
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
	prod_code TEXT,
    us_viewers INT,
	CONSTRAINT UC_parks_and_recreation_episodes UNIQUE (season, episode_in_season)
);

INSERT INTO parks_and_recreation_episodes (season, episode_in_season, episode_overall, title, director, writer, air_date, us_viewers) SELECT season, episode_in_season, episode_overall, title, director, writer, air_date, CAST(us_viewers AS INT) FROM parks_and_recreation_episodes_raw;
ALTER TABLE f23_group2.parks_and_recreation_episodes OWNER TO f23_group2;
DROP TABLE parks_and_recreation_episodes_raw;

--Separate writers into own table (multi-valued)
DROP TABLE IF EXISTS parks_and_recreation_episode_writers CASCADE;
CREATE TABLE parks_and_recreation_episode_writers (
	name TEXT,
	episode_id SERIAL
);
INSERT INTO parks_and_recreation_episode_writers SELECT regexp_split_to_table(parks_and_recreation_episodes.writer,E' and | & '), parks_and_recreation_episodes.id FROM parks_and_recreation_episodes;
ALTER TABLE parks_and_recreation_episodes DROP COLUMN writer;
ALTER TABLE f23_group2.parks_and_recreation_episode_writers OWNER TO f23_group2;

--IMDB ratings
DROP TABLE IF EXISTS parks_and_recreation_ratings_raw CASCADE;
CREATE TABLE parks_and_recreation_ratings_raw (
   season NUMERIC(1) NOT NULL,
   episode_in_season NUMERIC(2) NOT NULL,
   CONSTRAINT UC_parks_and_recreation_ratings_raw UNIQUE (season, episode_in_season),
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

\COPY parks_and_recreation_ratings_raw FROM './data/parks_and_rec_imdb.csv' WITH CSV HEADER;

DROP TABLE IF EXISTS parks_and_recreation_ratings CASCADE;
CREATE TABLE parks_and_recreation_ratings (
   episode_id SERIAL PRIMARY KEY,
   CONSTRAINT FK_parks_and_recreation_ratings FOREIGN KEY (episode_id) REFERENCES parks_and_recreation_episodes(id),
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

ALTER TABLE f23_group2.parks_and_recreation_ratings OWNER TO f23_group2;
INSERT INTO parks_and_recreation_ratings SELECT eps.id, rat.rating, rat.total_votes, rat.description FROM parks_and_recreation_ratings_raw AS rat JOIN parks_and_recreation_episodes AS eps ON rat.season = eps.season AND rat.episode_in_season = eps.episode_in_season;
DROP TABLE parks_and_recreation_ratings_raw;
