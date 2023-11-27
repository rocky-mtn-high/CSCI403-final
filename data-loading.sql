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
\COPY office_episodes FROM './CSCI403/final_project/data/office_episodes.csv' WITH CSV HEADER;

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


\COPY office_ratings FROM './CSCI403/final_project/data/office_imdb.csv' WITH CSV HEADER;



--Then parks and rec
DROP TABLE IF EXISTS parks_and_rec_episodes CASCADE;
CREATE TABLE parks_and_rec_episodes (
    season NUMERIC(1),
    episode_num_in_season NUMERIC(2),
    episode_num_overall NUMERIC(3),
    title TEXT,
    directed_by TEXT,
    writen_by TEXT,
    original_air_date DATE,
    us_viewers FLOAT
);
ALTER TABLE parks_and_rec_episodes ADD PRIMARY KEY(episode_num_overall); 
ALTER TABLE f23_group2.parks_and_rec_episodes OWNER TO f23_group2;
\COPY parks_and_rec_episodes FROM './CSCI403/final_project/data/parks_and_rec_episodes.csv' WITH CSV HEADER;

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


\COPY office_ratings FROM './CSCI403/final_project/data/parks_and_rec_imdb.csv' WITH CSV HEADER;
