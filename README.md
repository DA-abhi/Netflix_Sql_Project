# Netflix Movies and TV Shows Data Analysis using SQL

![Netflix Logo](https://github.com/DA-abhi/Netflix_Sql_Project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
* Analyze the distribution of content types (movies vs TV shows).
* Identify the most common ratings for movies and TV shows.
* List and analyze content based on release years, countries, and durations.
* Explore and categorize content based on specific criteria and keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:
* **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)
## Schema
```sql
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    types         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```
## Business Problems and Solutions
### 1. Count the Number of Movies vs TV Shows
```Sql
SELECT types    AS Types,
       Count(*) AS Total_content
FROM   netflix
GROUP  BY types;
```

### 2. Find the most common rating for movies and TV shows
```Sql
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
```
### 3. List all movies released in a specific year (e.g., 2020)
```Sql
SELECT *
FROM   netflix
WHERE  types = 'movie'
       AND release_year = 2020; 
```
### 4. Find the top 5 countries with the most content on Netflix.
```Sql
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
```
-- 5. Identify the longest movie.
```Sql
SELECT *
FROM   netflix
WHERE  types = 'movie'
       AND duration = (SELECT Max(duration)
                       FROM   netflix); 
```
### 6. Find content added in the last 5 years.
```Sql
SELECT *
FROM   netflix
WHERE  Cast(date_added AS DATE) >= Dateadd(year, -5, Getdate()); 
```

### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
```Sql
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
```
### 8. List all TV shows with more than 5 seasons.
```Sql
SELECT *
FROM   netflix
WHERE  types = 'TV show'
       AND Cast(LEFT(duration, Charindex(' ', duration) - 1)AS INT) > 5; 
```
### 9. Count the number of content items in each genre.
```Sql
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
```
### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
```Sql
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
```
### 11. List all movies that are documentaries.
```Sql
SELECT *,
       Trim(value) AS listed_in
FROM   netflix
       CROSS apply String_split(listed_in, ',')
WHERE  types = 'movie'
       AND Trim(value) = 'Documentaries'; 
```
### 12. Find all content without a director.
```Sql
SELECT *
FROM   netflix
WHERE  director IS NULL; 
```
### 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
```Sql
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
```

### 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
```Sql
SELECT TOP 10 Ltrim(Rtrim(value)) AS casts,
              Count(*)            AS total_content
FROM   netflix
       CROSS apply String_split(casts, ',')
WHERE  country = 'india'
GROUP  BY Ltrim(Rtrim(value))
ORDER  BY total_content DESC; 
```
### 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
```Sql
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
```
