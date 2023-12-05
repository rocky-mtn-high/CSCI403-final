--Interesting Queries

--Query 1
--What are the average ratings/viewers/votes of directors/writers who worked on both shows for each show?
SELECT ew.name, e.show, AVG(e.rating) AS avg_rating, AVG(e.us_viewers) AS avg_us_viewers, AVG(e.total_votes) AS avg_total_votes
FROM episode_writer as ew, episode AS e
WHERE e.show = ew.episode_show AND e.season = ew.episode_season AND e.episode_in_season = ew.episode_episode_in_season AND ew.name IN (
	SELECT ew.name 
	FROM episode_writer as ew, episode AS e
	WHERE e.show = ew.episode_show AND e.season = ew.episode_season AND e.episode_in_season = ew.episode_episode_in_season AND e.show = 'The Office'
) AND ew.name IN (
	SELECT ew.name 
	FROM episode_writer as ew, episode AS e
	WHERE e.show = ew.episode_show AND e.season = ew.episode_season AND e.episode_in_season = ew.episode_episode_in_season AND e.show = 'Parks and Recreation'
)
GROUP BY ew.name, e.show;

--Query 2
--What words were used most commonly in the episode descriptions
SELECT word, COUNT(*) AS word_count 
FROM ( 
SELECT regexp_split_to_table(description, E'\\s+') AS word 
FROM episode 
WHERE description IS NOT NULL 
) AS words 
WHERE word NOT IN ('the', 'and', 'is', 'in', 'of', 'it', 'to', 'a', 'for', 'with', 'on', 'as', 'at', 'by', 'an', 'from', 'but', 'or', 'was', 'were', 'are', 'you', 'we', 'they', 'he', 'she', 'it', 'that', 'this', 'his', 'her', 'its', 'their', 'our', 'be', 'have', 'has', 'do', 'did', 'does', 'not', 'what', 'when', 'where', 'how', 'why', 'who', 'which', 'there', 'then', 'if', 'else', 'for', 'while', 'when', 'about', 'into', 'out', 'up', 'down', 'over', 'under', 'between', 'through', 'after', 'before', 'during', 'with', 'without', 'within', 'among', 'between') 
GROUP BY word 
ORDER BY word_count DESC 
LIMIT 20; 

--Query 3
--For those who directed both shows, which show outperformed the other for episodes they directed?
WITH DirectorStats AS ( 
    SELECT 
        director, 
        show, 
        COUNT(DISTINCT description) AS total_episodes, 
        AVG(rating) AS average_rating 
    FROM 
        episode 
    WHERE 
        director IN ( 
            SELECT DISTINCT director 
            FROM episode 
            GROUP BY director 
            HAVING COUNT(DISTINCT show) > 1 
        ) 
    GROUP BY 
        director, show 
) 
SELECT 
    ds.director, 
    SUM(ds.total_episodes) AS total_episodes, 
    SUM(CASE WHEN ds.show = 'Parks and Recreation' THEN ds.total_episodes ELSE 0 END) AS parks_episodes, 
    AVG(CASE WHEN ds.show = 'Parks and Recreation' THEN ds.average_rating END) AS parks_avg_rating, 
    SUM(CASE WHEN ds.show = 'The Office' THEN ds.total_episodes ELSE 0 END) AS office_episodes, 
    AVG(CASE WHEN ds.show = 'The Office' THEN ds.average_rating END) AS office_avg_rating, 
    CASE WHEN MAX(CASE WHEN ds.show = 'Parks and Recreation' THEN ds.average_rating END) > 
                  MAX(CASE WHEN ds.show = 'The Office' THEN ds.average_rating END) 
         THEN 'Parks and Recreation' 
         ELSE 'The Office' 
    END AS higher_rated_show 
FROM 
    DirectorStats ds 
GROUP BY 
    ds.director 
ORDER BY 
    total_episodes DESC; 

--Query 4
--What is the value of having more writers in terms of ratings, votes, and views?
WITH writer_counts AS ( 
	SELECT COUNT(*) AS writer_count, AVG(e.rating) AS rating, AVG(e.us_viewers) AS views, AVG(e.total_votes) AS votes 
	FROM episode AS e, episode_writer AS ew 
	WHERE e.show = ew.episode_show AND e.season = ew.episode_season AND e.episode_in_season = ew.episode_episode_in_season 
	GROUP BY e.show, e.season, e.episode_in_season 
) 
SELECT writer_count, AVG(rating) AS avg_rating, AVG(views) AS avg_views, AVG(votes) AS avg_votes 
FROM writer_counts 
GROUP BY writer_count 
ORDER BY writer_count; 

--Query 5
--What are the top five contributing writers across both shows in terms of total episodes written, and what are their average ratings and viewership for the episodes they wrote for each show?
SELECT
    ew.name,
    COUNT(*) AS total_episodes_written,
    COUNT(CASE WHEN ew.episode_show = 'The Office' THEN 1 END) AS office_episodes,
    ROUND(AVG(CASE WHEN ew.episode_show = 'The Office' THEN e.rating END), 3) AS office_avg_rating,
    ROUND(AVG(CASE WHEN ew.episode_show = 'The Office' THEN e.us_viewers END), 3) AS office_avg_views,
    COUNT(CASE WHEN ew.episode_show = 'Parks and Recreation' THEN 1 END) AS parks_episodes,
    ROUND(AVG(CASE WHEN ew.episode_show = 'Parks and Recreation' THEN e.rating END), 3) AS parks_avg_rating,
    ROUND(AVG(CASE WHEN ew.episode_show = 'Parks and Recreation' THEN e.us_viewers END), 3) AS parks_avg_views
FROM
    episode_writer ew
JOIN
    episode e ON ew.episode_show = e.show 
        AND ew.episode_season = e.season 
        AND ew.episode_episode_in_season = e.episode_in_season
GROUP BY
    ew.name
ORDER BY
    total_episodes_written DESC
LIMIT 5
   
--Bonus Query
--For episodes airing on the same date, which show performed better?
WITH air_date_comparison AS (
    SELECT
        show,
        air_date,
        title,
        us_viewers,
        ROW_NUMBER() OVER (PARTITION BY air_date, show ORDER BY us_viewers DESC) AS rank
    FROM
        episode
    WHERE
        show IN ('The Office', 'Parks and Recreation')
)
SELECT
    a.air_date,
    a.title AS office_episode,
    a.us_viewers AS office_viewers,
    b.title AS parks_episode,
    b.us_viewers AS parks_viewers,
    CASE
        WHEN a.us_viewers > b.us_viewers THEN 'The Office'
        WHEN a.us_viewers < b.us_viewers THEN 'Parks and Recreation'
        ELSE 'Tie'
    END AS higher_viewers,
    CASE
        WHEN a.us_viewers > b.us_viewers THEN (a.us_viewers - b.us_viewers) / b.us_viewers * 100
        WHEN a.us_viewers < b.us_viewers THEN (b.us_viewers - a.us_viewers) / a.us_viewers * 100
        ELSE 0
    END AS percentage_more_viewers
FROM
    air_date_comparison a
JOIN
    air_date_comparison b ON a.air_date = b.air_date AND a.rank = b.rank
WHERE
    a.show = 'The Office'
    AND b.show = 'Parks and Recreation';
