-- Netflix project
DROP TABLE IF EXISTS netflix;
CREATE  TABLE netflix
(
   show_id VARCHAR(6),
   type    VARCHAR(10),
   title   VARCHAR(150),
   director VARCHAR(208),
   casts     VARCHAR(1000),
   country  VARCHAR(150),
   date_added VARCHAR(50),
   release_year INT,
   rating      VARCHAR(10),
   duration    VARCHAR(15),
   listed_in   VARCHAR(100),
   description VARCHAR(250)
)

SELECT *FROM netflix;

SELECT 
    COUNT(*) as tool_content --this should use for hoe man
FROM netflix;	

SELECT
   *
FROM netflix;   --differnt typr of content for use this like tv shoe,adds ,movies like

--1.count the numbers of movies vs tv shows
SELECT 
    type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type

-- find the most common rating for movies and tv shows
SELECT
   type,
   rating
FROM
(
    SELECT
       type,
	   rating,
	   COUNT(*),
	   RANK() over(PARTITION BY type ORDER BY COUNT(*) DESC)as ranking
   FROM	netflix
   GROUP BY 1,2
)as t1
WHERE
    ranking=1

--3.list all movies release in a specific year(eg:20)
--filter 202
--movies

SELECT * FROM netflix
WHERE
   type='Movie'
   AND
   release_Year=2020

--4. find the top5 countries with most content on Netflix

SELECT
    UNNEST(STRING_TO_ARRAY(country,','))as new_country,
	COUNT(show_id)as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--5.identify the longest movie?
SELECT * FROM netflix
WHERE
   type='Movie'
   AND
   duration=(SELECT MAX(duration)FROM netflix)

--6.find content added in the last 5 years

SELECT
    *
FROM netflix
WHERE
    TO_DATE(date_added,'Month DD,YYYY')>=CURRENT_DATE-INTERVAL '5 years'

 --7.Find all the movies/tv shows by director 'Rajiv Chilaka'!

 SELECT * FROM netflix
 WHERE director ILIKE '%Rajiv Chilaka%'

 --8.list all tv shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type ILIKE 'tv show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;

 
SELECT
 SPLIT_PART('Apple Banna Cherry',' ',1)

--9.count thenumbers of content items in each genre.
SELECT 
  UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
  COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

--10.Find each year and the average numbers of content in india on netflix,
--return top 5 year with highest avg content release
SELECT
  release_year,
  COUNT(*) AS yearly_content,
  ROUND( (COUNT(*)::numeric / 12.0)::numeric, 2) AS avg_per_month
FROM netflix
WHERE release_year IS NOT NULL
  AND country ILIKE '%India%'         -- use ILIKE + % for contains (case-insensitive)
GROUP BY release_year
ORDER BY avg_per_month DESC
LIMIT 5;

--11.list all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries'

--12.find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

--13. find how many movies actor 'salman khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE
   casts ILIKE '%salman Khan%'
   AND
   release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10

--14.find the top 10 actors who have appreared in the highest number of movies produced in India.

SELECT
UNNEST(STRING_TO_ARRAY(Casts,','))as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15.categorixa the content on the presence of the
--keywords 'kill' and 'violence' in the description field.
--label content  containing these keywords as 'bad' and all
--other content as 'good'.count how many items fall into each category

WITH new_table
AS
(
SELECT
*,
  CASE
  WHEN
     description ILIKE '%kill%' OR
	 description ILIKE '%violence%' THEN 'Bad_Content'
	 ELSE 'Good Content'
	END category
FROM netflix	
)
SELECT 
   category,
   COUNT(*) as total_content
FROM new_table
GROUP BY 1

--16.find the month in which netflix added the most content.
SELECT
  TO_CHAR(TO_DATE(date_added,'Month DD,YYYY'),'Month')as month_name,
  COUNT(*) as total_added
FROM netflix
GROUP BY month_name
ORDER BY total_added DESC;

--17 find the tpo 10 most common words used in titles.
SELECT word,COUNT(*) as frequency
FROM(
   SELECT UNNEST(STRING_TO_ARRAY(LOWER(title),''))as word
   FROM netflix
)as words
GROUP BY word
ORDER BY frequency DESC
LIMIT 10;

--18.which diector has created the maximum numbers of movies and tv shows combined?
SELECT
    director,
	COUNT(*)as total_content
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_content DESC
LIMIT 1
	
--19.count how many movies each country has produced(top 10)
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country,',')))as country_name,
	COUNT(*) as total_movies
FROM netflix
WHERE type ='Movie'
GROUP BY country_name
ORDER BY total_movies DESC
LIMIT 10;

--20 Find shows available in exactly 3 genres.
SELECT *
FROM netflix
WHERE ARRAY_LENGTH(STRING_TO_ARRAY(listed_in, ','), 1)=3;

--21.for ecah year ,hind how many new directors appeared for the first time.
SELECT
    release_year,
	COUNT(DISTINCT director)as new_directors
FROM netflix
WHERE director IS NOT NULL
GROUP BY release_year
ORDER BY release_year;

--22.find the percentage of movies vs tv shows.
SELECT
    type,
	ROUND(COUNT(*) * 100.0/(SELECT COUNT(*) FROM netflix),2) as percentage
FROM netflix
GROUP BY type;

--23.identify content where description contains emotional keywords like 'love','family','frined'.
SELECT *
FROM netflix
WHERE description ILIKE '%love'
   OR description ILIKE '%family'
   OR description ILIKE '%frined';

--24.find all pairs of actors who have appered together in a title.
SELECT title,STRING_TO_ARRAY(casts,',')as actors
FROM netflix
WHERE casts IS NOT NULL;

--25.find directors who have worked in more in more than on country.
SELECT 
    director,
    COUNT(DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))) AS country_count
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
HAVING COUNT(DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))) > 1;

--26.find the oldest(earliest) movie and tv show available.
SELECT *
FROM netflix
WHERE release_year=(SELECT MIN(release_year)FROM netflix);

--27.what % of indian content is movies vs tv shows
SELECT 
    type,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%'), 2) AS percent
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY type;

--28.find the top 5 genres with the highest average release year.
SELECT
    genre,
	ROUND(AVG(release_year),2)as avg_release_year
FROM(
    SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,','))as genre,
	release_year
 FROM netflix	
)t
GROUP BY genre
ORDER BY avg_release_year DESC
LIMIT 5;

--29.identify movies longer than the average movie duration.
SELECT *
FROM netflix
WHERE type='Movie'
  AND CAST(SPLIT_PART(duration,' ',1) AS INT) >
      (SELECT AVG(CAST(SPLIT_PART(duration,' ',1) AS INT)) 
       FROM netflix WHERE type='Movie');

--30.find the most frequent actor in tv shows only.
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS count
FROM netflix
WHERE type = 'TV Show'
GROUP BY actor
ORDER BY count DESC
LIMIT 1;

   























 