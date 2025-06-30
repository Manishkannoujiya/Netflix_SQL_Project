--- Netflix

CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
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
select * from netflix;

----- ----------------- Problems---------------------

---------- Queston 1. count the number of movies vs TVshows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;


----------- Question 2. Find the most common rating for movies and TV shows
With RatingCounts As(
select type,
rating,
 count(*) as rating_count
 from netflix
 group by type , rating
),
RankedRatings as(
select type ,
rating,
rating_count,
rank() over(partition by type order by rating_count desc) as rank_
from RatingCounts
)

select 
type,
rating as most_frequent_rating
from RankedRatings
where rank_ = 1 ;

---------- Question3. List of all movies released in Specific year(e.g.2021)
Select * from 
netflix
where release_year = 2021;


----------Question 4. Find the top 10 countries with hte most content on Netflix

select *
from(
select
      UNNEST(string_to_array(country , ',')) as country,
	  count(*) as total_content
from netflix
group by 1
) as t1
where country is not null
order by total_content desc
limit 10;


-------- Question 5. identify the longest movie

select * from netflix
where type = 'Movie'
order by split_part(duration, ' ', 1) :: int desc;


------------- Question 6. Find content added in the last 5 years
select * from netflix
where to_date(date_added, 'Month DD , YYYY') >= current_date - interval '5 years' ;




-------------question 7. find all the movies/tv shows by director 'Rajiv Chilaka'
 select * from  netflix
 where director Ilike '%Rajiv Chilaka%'


-----------Question 8. List all the TV shows with more than 5 seasons

select * 
from netflix
where 
type = 'TV Show'
and
split_part(duration, ' ',1)::numeric > 5


---------- question 9. Count the number of content items in each genre

select 
unnest(string_to_array(listed_in, ',')) as genre,
count(show_id) as total_content

from netflix
group by 1


---------- Question10 Find Each year and the average number of content release by india on netflix
select 
     extract(year from to_date(date_added, 'Month DD, YYYY'))as year,
	 count(*) as yearly_content,
	 round(
	 count(*):: numeric/(select Count(*) from netflix where country = 'India')::numeric*100,4)
	 as avg_content_per_year
from netflix
where country = 'India'
group by 1


------------ Question 11. List all Movies that are Documentries
select * from netflix
where 
listed_in Ilike '%documentaries%'




----------- Question12. Find all the content without a director

select * from netflix
where director is null


----------- Question 13. Find how many movies actors '' appered in last 10 years
select * from netflix
where 
casts Ilike '%Shah Rukh Khan%'
and
release_year > extract(year from current_date) - 15



-----------Question 14. Find the top ten actors who have appeared in the highest number of movies produced in India

select 
UNNEST(string_to_array(casts , ',')) as actors,
count(*) as total_content
from netflix
where country Ilike '%India'
group by 1
order by 2 desc
limit 10;


---------- Question15. Cateroize the content based on the presence of the Keywords 'kill' abd 'violence' in
--------------------   the description field. Label comtent containing these keywords as 'Bad' and all other
--------------------   content as 'good'. Count how many items fall into each category.
with new_table
as(
select *,
case
when  description Ilike '%kills%' or
      description Ilike '%violence%' then 'Bad_Content'
	  else 'Good_content'
	  end category
from netflix
)

select 
      category,
	  count(*) as total_content
	  from new_table
	  group by 1
	  


