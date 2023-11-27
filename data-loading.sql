SET search_path TO f23_group2;

--The office first
--Episodes
DROP TABLE IF EXISTS office_episodes_raw CASCADE;
CREATE TABLE office_episodes_raw (
    season NUMERIC(1),
    episode_in_season NUMERIC(2),
    episode_overall NUMERIC(3),
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    prod_code NUMERIC(4),
    us_viewers FLOAT
);

\COPY office_episodes_raw FROM './data/office_episodes.csv' WITH CSV HEADER;


DROP TABLE IF EXISTS office_episodes CASCADE;
CREATE TABLE office_episodes (
	id SERIAL PRIMARY KEY,
    season NUMERIC(1),
    episode_in_season NUMERIC(2),
    episode_overall NUMERIC(3),
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    prod_code NUMERIC(4),
    us_viewers INT
);

ALTER TABLE f23_group2.office_episodes OWNER TO f23_group2;
INSERT INTO office_episodes (season, episode_in_season, episode_overall, title, director, writer, air_date, prod_code, us_viewers) SELECT season, episode_in_season, episode_overall, title, director, writer, air_date, prod_code, CAST(us_viewers AS INT) FROM office_episodes_raw;
DROP TABLE office_episodes_raw;

--Separate writers into own table (multi-valued)
DROP TABLE IF EXISTS office_episode_writers CASCADE;
CREATE TABLE office_episode_writers (
	name TEXT,
	episode_id SERIAL
);
INSERT INTO office_episode_writers SELECT regexp_split_to_table(office_episodes.writer,E' and | & '), office_episodes.id FROM office_episodes;
ALTER TABLE office_episodes DROP COLUMN writer;


--IMDB ratings
DROP TABLE IF EXISTS office_ratings_raw CASCADE;
CREATE TABLE office_ratings_raw (
   season NUMERIC(1),
   episode_in_season NUMERIC(2), 
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

\COPY office_ratings_raw FROM './data/office_imdb.csv' WITH CSV HEADER;
DROP TABLE IF EXISTS office_ratings CASCADE;
CREATE TABLE office_ratings (
   episode_id SERIAL PRIMARY KEY,
   CONSTRAINT FK_office_ratings FOREIGN KEY (episode_id) REFERENCES office_episodes(id),
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

INSERT INTO office_ratings SELECT off.id, rat.rating, rat.total_votes, rat.description FROM office_ratings_raw AS rat JOIN office_episodes AS off ON rat.title = off.title;
ALTER TABLE f23_group2.office_ratings OWNER TO f23_group2;
DROP TABLE office_ratings_raw;

--Then parks and rec
DROP TABLE IF EXISTS parks_and_rec_episodes_raw CASCADE;
CREATE TABLE parks_and_rec_episodes_raw (
    season NUMERIC(1),
    episode_in_season NUMERIC(2),
    episode_overall NUMERIC(3),
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    us_viewers FLOAT
);

\COPY parks_and_rec_episodes_raw FROM './data/parks_and_rec_episodes.csv' WITH CSV HEADER;

DROP TABLE IF EXISTS parks_and_rec_episodes CASCADE;
CREATE TABLE parks_and_rec_episodes (
	id SERIAL PRIMARY KEY,
    season NUMERIC(1),
    episode_in_season NUMERIC(2),
    episode_overall NUMERIC(3),
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    us_viewers INT
);

INSERT INTO parks_and_rec_episodes (season, episode_in_season, episode_overall, title, director, writer, air_date, us_viewers) SELECT season, episode_in_season, episode_overall, title, director, writer, air_date, CAST(us_viewers AS INT) FROM parks_and_rec_episodes_raw;
ALTER TABLE f23_group2.parks_and_rec_episodes OWNER TO f23_group2;
DROP TABLE parks_and_rec_episodes_raw;

--Separate writers into own table (multi-valued)
DROP TABLE IF EXISTS parks_and_rec_episode_writers CASCADE;
CREATE TABLE parks_and_rec_episode_writers (
	name TEXT,
	episode_id SERIAL
);
INSERT INTO parks_and_rec_episode_writers SELECT regexp_split_to_table(parks_and_rec_episodes.writer,E' and | & '), parks_and_rec_episodes.id FROM parks_and_rec_episodes;
ALTER TABLE parks_and_rec_episodes DROP COLUMN writer;


--IMDB ratings
DROP TABLE IF EXISTS parks_and_rec_ratings_raw CASCADE;
CREATE TABLE parks_and_rec_ratings_raw (
   season NUMERIC(1),
   episode_in_season NUMERIC(2), 
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

\COPY parks_and_rec_ratings_raw FROM './data/parks_and_rec_imdb.csv' WITH CSV HEADER;

DROP TABLE IF EXISTS parks_and_rec_ratings CASCADE;
CREATE TABLE parks_and_rec_ratings (
   episode_id SERIAL PRIMARY KEY,
   CONSTRAINT FK_parks_and_rec_ratings FOREIGN KEY (episode_id) REFERENCES parks_and_rec_episodes(id),
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);

ALTER TABLE f23_group2.parks_and_rec_ratings OWNER TO f23_group2;
INSERT INTO parks_and_rec_ratings SELECT eps.id, rat.rating, rat.total_votes, rat.description FROM parks_and_rec_ratings_raw AS rat JOIN parks_and_rec_episodes AS eps ON rat.title = eps.title AND rat.air_date = eps.air_date; --Episodes cannot be uniquely identified by title alone
DROP TABLE parks_and_rec_ratings_raw;