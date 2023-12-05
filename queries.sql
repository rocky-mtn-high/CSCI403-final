--Interesting Queries

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
