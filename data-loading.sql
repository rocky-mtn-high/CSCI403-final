SET search_path TO f23_group2;

--The office first
--Episodes
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
    us_viewers FLOAT
);
ALTER TABLE office_episodes ADD PRIMARY KEY(prod_code); 
ALTER TABLE f23_group2.office_episodes OWNER TO f23_group2;
\COPY office_episodes FROM 'data/office_episodes.csv' WITH CSV HEADER;

--IMDB ratings
DROP TABLE IF EXISTS office_ratings CASCADE;
CREATE TABLE office_ratings (
   season NUMERIC(1),
   episode_in_season NUMERIC(2), 
   title TEXT,
   air_date DATE,
   rating NUMERIC(2, 1),
   total_votes NUMERIC(5),
   description TEXT
);
ALTER TABLE office_ratings ADD PRIMARY KEY(season, episode_in_season); 
ALTER TABLE f23_group2.office_ratings OWNER TO f23_group2;


\COPY office_ratings FROM 'data/office_imdb.csv' WITH CSV HEADER

DROP TABLE IF EXISTS imdb_ratings CASCADE;
CREATE TABLE imdb_ratings (
    imdb_rating_id SERIAL PRIMARY KEY,
    episode_id INT,
    rating FLOAT,
    total_votes INT,
    description TEXT,
    air_date DATE
);
INSERT INTO imdb_ratings (episode_id, rating, total_votes, description, air_date)
SELECT e.episode_id, r.rating, r.total_votes, r.description, r.air_date
FROM episodes e
JOIN office_ratings r ON e.season = r.season AND e.episode_in_season = r.episode_in_season;

--Then parks and rec
DROP TABLE IF EXISTS parks_and_rec_episodes CASCADE;
CREATE TABLE parks_and_rec_episodes (
    season NUMERIC(1),
    episode_num_in_season NUMERIC(2),
    episode_num_overall NUMERIC(3),
    title TEXT,
    directed_by TEXT,
    written_by TEXT,
    original_air_date DATE,
    us_viewers FLOAT
);
ALTER TABLE parks_and_rec_episodes ADD PRIMARY KEY(episode_num_overall); 
ALTER TABLE f23_group2.parks_and_rec_episodes OWNER TO f23_group2;
\COPY parks_and_rec_episodes FROM 'data/parks_and_rec_episodes.csv' WITH CSV HEADER;

--IMDB ratings
DROP TABLE IF EXISTS parks_and_rec_ratings CASCADE;
CREATE TABLE parks_and_rec_ratings (
   season NUMERIC(1),
   episode_in_season NUMERIC(2), 
   title TEXT,
   air_date DATE,
   rating NUMERIC(2, 1),
   total_votes NUMERIC(5),
   description TEXT
);
ALTER TABLE parks_and_rec_ratings ADD PRIMARY KEY(season, episode_in_season); 
ALTER TABLE f23_group2.parks_and_rec_ratings OWNER TO f23_group2;

\COPY parks_and_rec_ratings FROM 'data/parks_and_rec_imdb.csv' WITH CSV HEADER;

DROP TABLE IF EXISTS episodes CASCADE;
CREATE TABLE episodes (
    episode_id SERIAL PRIMARY KEY,
	show TEXT,
    season NUMERIC(1),
    episode_in_season NUMERIC(2),
    episode_overall NUMERIC(3),
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    prod_code NUMERIC(4),
    us_viewers INT,
	rating NUMERIC(2, 1),
	total_votes NUMERIC(5),
    description TEXT
);
INSERT INTO episodes (show, season, episode_in_season, episode_overall, title, director, writer, air_date, prod_code, us_viewers, rating, total_votes, description)
SELECT 'The Office', e.season, e.episode_in_season, e.episode_overall, e.title, e.director, e.writer, e.air_date, e.prod_code, e.us_viewers, r.rating, r.total_votes, r.description
FROM office_episodes AS e, office_ratings AS r
WHERE e.season = r.season AND e.episode_in_season = r.episode_in_season;
INSERT INTO episodes (show, season, episode_in_season, episode_overall, title, director, writer, air_date, us_viewers, rating, total_votes, description)
SELECT 'Parks and Rec', e.season, e.episode_num_in_season, e.episode_num_overall, e.title, e.directed_by, e.written_by, e.original_air_date, e.us_viewers, r.rating, r.total_votes, r.description
FROM parks_and_rec_episodes AS e, parks_and_rec_ratings AS r
WHERE e.season = r.season AND e.episode_num_in_season = r.episode_in_season;
