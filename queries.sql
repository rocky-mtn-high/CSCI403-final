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