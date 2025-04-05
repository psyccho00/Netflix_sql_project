CREATE DATABASE netflix;
USE netflix;

CREATE TABLE IF NOT EXISTS netflix_titles
(
	show_id	VARCHAR(10) PRIMARY KEY,
	typess	VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);



SELECT * FROM netflix_titles;
SELECT COUNT(*) FROM netflix_titles;



-- 1. Count the number of Movies vs TV Shows
SELECT 
typess,COUNT(*)
FROM netflix_titles
GROUP BY 1;



-- 2. Find the most common rating for movies and TV shows
SELECT 
typess,rating
FROM (
SELECT
typess,rating, count(*),
RANK () OVER(PARTITION BY typess ORDER BY count(*) desc) as ranking
FROM netflix_titles
GROUP BY 1,2
ORDER BY 1
) AS T1
WHERE ranking = 1;



-- 3. List all movies released in a specific year (e.g., 2020)
SELECT 
title, casts, director 
FROM netflix_titles 
WHERE 
typess = 'Movie' AND  release_year = 2020;



-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(*) as total_content
FROM netflix_titles
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;



-- 5. Identify the longest movie
SELECT 
	*
FROM netflix_titles
WHERE typess = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;



-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix_titles 
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix_titles
WHERE director ilike 'Rajiv Chilaka'

-- OR 

SELECT 
*
FROM(
SELECT
UNNEST(STRING_TO_ARRAY(director, ',')) as new_director, *
FROM netflix_titles
) WHERE new_director = 'Rajiv Chilaka';



-- 8. List all TV shows with more than 5 seasons
SELECT 
* 
FROM netflix_titles 
WHERE typess = 'TV Show'
AND SPLIT_PART(duration, ' ', 1):: int > 5



-- 9. Count the number of content items in each genre
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
count(*)
FROM netflix_titles
GROUP BY 1
ORDER BY 2 desc;



-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix_titles WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix_titles
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5;



-- 11. List all movies that are documentaries
SELECT * 
FROM (
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in,',')) as listed,
*
FROM netflix_titles
) as t1
WHERE listed = 'Documentaries';



-- 12. Find all content without a director
SELECT
*
FROM netflix_titles
WHERE director IS NULL;



-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT
*
FROM (
SELECT
UNNEST (STRING_TO_ARRAY(casts,',')) as actors, *
FROM netflix_titles
) WHERE actors = 'Salman Khan'
	AND
	release_year >= (EXTRACT(YEAR FROM CURRENT_DATE) -10);

-- OR

SELECT * FROM netflix_titles
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
UNNEST (STRING_TO_ARRAY(casts,',')) as actors,count(*)
FROM netflix_titles
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 desc
LIMIT 10;



/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
*, 
	CASE
	WHEN description ILIKE '%kill%'
		OR
		description ILIKE '%violence%' THEN 'Bad_Content'
	ELSE 'Good_Content'
	END category
FROM netflix_titles;
		

