SET search_path TO f23_group2;

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

\COPY office_ratings FROM './CSCI403/final_project/data/office_imdb.csv' WITH CSV HEADER;
