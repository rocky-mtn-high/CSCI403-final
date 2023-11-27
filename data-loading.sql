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
ALTER TABLE office_episodes ADD id SERIAL;
ALTER TABLE office_episodes ADD PRIMARY KEY(id); 
INSERT INTO office_episodes (season, episode_in_season, episode_overall, title, director, writer, air_date, prod_code, us_viewers) SELECT season, episode_in_season, episode_overall, title, director, writer, air_date, prod_code, CAST(us_viewers AS INT) FROM office_episodes_raw;
DROP TABLE office_episodes_raw;



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
   episode_id SERIAL,
   CONSTRAINT FK_office_ratings FOREIGN KEY (episode_id) REFERENCES office_episodes(id),
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);
ALTER TABLE office_ratings ADD PRIMARY KEY (episode_id);
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
    season NUMERIC(1),
    episode_in_season NUMERIC(2),
    episode_overall NUMERIC(3),
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    us_viewers INT
);


ALTER TABLE parks_and_rec_episodes ADD id SERIAL;
ALTER TABLE parks_and_rec_episodes ADD PRIMARY KEY(id); 
INSERT INTO parks_and_rec_episodes (season, episode_in_season, episode_overall, title, director, writer, air_date, us_viewers) SELECT season, episode_in_season, episode_overall, title, director, writer, air_date, CAST(us_viewers AS INT) FROM parks_and_rec_episodes_raw;
DROP TABLE parks_and_rec_episodes_raw;
ALTER TABLE f23_group2.parks_and_rec_episodes OWNER TO f23_group2;


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
   episode_id SERIAL,
   CONSTRAINT FK_parks_and_rec_ratings FOREIGN KEY (episode_id) REFERENCES parks_and_rec_episodes(id),
   rating FLOAT,
   total_votes NUMERIC(5),
   description TEXT
);
ALTER TABLE f23_group2.parks_and_rec_ratings OWNER TO f23_group2;
ALTER TABLE parks_and_rec_ratings ADD PRIMARY KEY (episode_id);
INSERT INTO parks_and_rec_ratings SELECT eps.id, rat.rating, rat.total_votes, rat.description FROM parks_and_rec_ratings_raw AS rat JOIN parks_and_rec_episodes AS eps ON rat.title = eps.title AND rat.air_date = eps.air_date;
--DROP TABLE parks_and_rec_ratings_raw;


