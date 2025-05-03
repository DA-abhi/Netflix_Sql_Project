-- 15 Business Problems & Solutions

/*1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

-- Solutions

SELECT *
FROM netflix;

-- 1. Count the number of Movies vs TV Shows.

SELECT types    AS Types,
       Count(*) AS Total_content
FROM   netflix
GROUP  BY types; 

-- 2. Find the most common rating for movies and TV shows
SELECT types,
       rating
FROM   (SELECT types,
               rating,
               Count(*)                    AS counts,
               Rank()
                 OVER(
                   partition BY types
                   ORDER BY Count(*) DESC) AS ranking
        FROM   netflix
        GROUP  BY types,
                  rating) t1
WHERE  ranking = 1; 

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM   netflix
WHERE  types = 'movie'
       AND release_year = 2020; 

-- 4. Find the top 5 countries with the most content on Netflix.

WITH countries_most_content
     AS (SELECT Trim(value) AS Country
         FROM   netflix
                CROSS apply String_split(country, ',')
         WHERE  country IS NOT NULL)
SELECT TOP 5 country,
             Count(*) AS Total_content
FROM   countries_most_content
GROUP  BY country
ORDER  BY total_content DESC; 

-- 5. Identify the longest movie.

SELECT *
FROM   netflix
WHERE  types = 'movie'
       AND duration = (SELECT Max(duration)
                       FROM   netflix); 

-- 6. Find content added in the last 5 years.

SELECT *
FROM   netflix
WHERE  Cast(date_added AS DATE) >= Dateadd(year, -5, Getdate()); 


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

WITH director
     AS (SELECT Trim(value) AS director,
                title
         FROM   netflix
                CROSS apply String_split(director, ','))
SELECT director,
       title
FROM   director
WHERE  director = 'Rajiv Chilaka'; 

-- OR -- 
SELECT *
FROM   netflix
WHERE  director LIKE '%Rajiv Chilaka%'; 

-- 8. List all TV shows with more than 5 seasons.

SELECT *
FROM   netflix
WHERE  types = 'TV show'
       AND Cast(LEFT(duration, Charindex(' ', duration) - 1)AS INT) > 5; 

-- 9. Count the number of content items in each genre.

SELECT Trim(value)   AS Genre,
       Count(show_id)AS total_content
FROM   netflix
       CROSS apply String_split(listed_in, ',')
GROUP  BY Trim(value)
ORDER  BY counts DESC;

-- OR --

SELECT DISTINCT Trim(value)                   AS Genre,
                Count(*)
                  OVER(
                    partition BY Trim(value)) AS total_content
FROM   netflix
       CROSS apply String_split(listed_in, ',')
ORDER  BY total_content DESC;

/* 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/ 

SELECT TOP 5 Year(Cast(date_added AS DATE))
             AS year,
             Count(*)
             AS Yearly_content,
             Round(Cast(Count(*) AS FLOAT) / (SELECT Cast(Count(*) AS FLOAT)
                                              FROM   netflix
                                              WHERE  country = 'India') * 100, 2
             ) AS
             'Avg_content_per_year'
FROM   netflix
WHERE  country = 'india'
GROUP  BY Year(Cast(date_added AS DATE))
ORDER  BY avg_content_per_year DESC; 

-- 11. List all movies that are documentaries.
SELECT *,
       Trim(value) AS listed_in
FROM   netflix
       CROSS apply String_split(listed_in, ',')
WHERE  types = 'movie'
       AND Trim(value) = 'Documentaries'; 

-- 12. Find all content without a director.
SELECT *
FROM   netflix
WHERE  director IS NULL; 

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *,
       Trim(value) AS casts
FROM   netflix
       CROSS apply String_split(casts, ',')
WHERE  Trim(value) = 'Salman khan'
       AND release_year >= Year(Getdate()) - 10;

-- OR--
SELECT *
FROM   netflix
WHERE  casts LIKE '%Salman Khan%'
       AND release_year >= Year(Getdate()) - 10; 


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TOP 10 Ltrim(Rtrim(value)) AS casts,
              Count(*)            AS total_content
FROM   netflix
       CROSS apply String_split(casts, ',')
WHERE  country = 'india'
GROUP  BY Ltrim(Rtrim(value))
ORDER  BY total_content DESC; 

/* 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

WITH new_table
     AS (SELECT *,
                CASE
                  WHEN description LIKE '%kill%'
                        OR description LIKE '%Violence%' THEN 'Bad_content'
                  ELSE 'Good_content'
                END AS Category
         FROM   netflix)
SELECT category,
       Count(*) AS Total_Content
FROM   new_table
GROUP  BY category
ORDER  BY total_content DESC; 






