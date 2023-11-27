SET search_path TO f23_group2;

--The office first
--Episodes
DROP TABLE IF EXISTS office_episodes CASCADE;
CREATE TABLE office_episodes (
    season INT,
    episode_in_season INT,
    episode_overall INT,
    title TEXT,
    director TEXT,
    writer TEXT,
    air_date DATE,
    prod_code INT,
    us_viewers FLOAT
);
ALTER TABLE office_episodes ADD PRIMARY KEY(prod_code); 
ALTER TABLE f23_group2.office_episodes OWNER TO f23_group2;
\COPY office_episodes FROM './CSCI403/final_project/data/office_episodes.csv' WITH CSV HEADER;

--IMDB ratings
DROP TABLE IF EXISTS office_ratings CASCADE;
CREATE TABLE office_ratings (
   season INT,
   episode_in_season INT, 
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes INT,
   description TEXT
);
ALTER TABLE office_ratings ADD PRIMARY KEY(season, episode_in_season); 
ALTER TABLE f23_group2.office_ratings OWNER TO f23_group2;


\COPY office_ratings FROM './CSCI403/final_project/data/office_imdb.csv' WITH CSV HEADER;



--Then parks and rec
DROP TABLE IF EXISTS parks_and_rec_episodes CASCADE;
CREATE TABLE parks_and_rec_episodes (
    season INT,
    episode_num_in_season INT,
    episode_num_overall INT,
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
   season INT,
   episode_in_season INT, 
   title TEXT,
   air_date DATE,
   rating FLOAT,
   total_votes INT,
   description TEXT
);
ALTER TABLE parks_and_rec_ratings ADD PRIMARY KEY(season, episode_in_season); 
ALTER TABLE f23_group2.parks_and_rec_ratings OWNER TO f23_group2;


\COPY office_ratings FROM './CSCI403/final_project/data/parks_and_rec_imdb.csv' WITH CSV HEADER;
