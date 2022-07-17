--# 1. Which work(s) of Shakespeare were written in 1604? 
SELECT title
FROM shakespeare.work
WHERE year = 1604; 

--# 2. Return the entire text of the unique paragraphs that contain between 1 and 4 text characters inclusive (letters, numbers, punctuation, etc., in a text string). HINT: Use the DISTINCT keyword. Do not use the GROUP BY clause.
SELECT DISTINCT plaintext
FROM shakespeare.paragraph
WHERE charcount BETWEEN 1 AND 4;

--# 3. List the long title and year of work(s) from 1595, 1607 and 1609. Sort the results by year, then by title.
SELECT longtitle, year
FROM shakespeare.work
where year = 1595 or year = 1607 or year = 1609
order by year, title;

--# 4. Show all the attributes for chapters with chapter number of 15
SELECT *
FROM shakespeare.chapter
where chapter = 15;

--# 5  List all the characters whose names have an “r” as the second position, end in either an “o” or “a”, do not start with an “F” or “G”, and do not contain a space
SELECT charname
FROM shakespeare.character
where charname like '_r%' 
  and (charname like '%o' or charname like '%a')
  and charname not like 'F%' 
  and charname not like 'G%'
  and charname not like '% %';
 
 --# 6  Which characters have a speech count greater than 250?
SELECT charname
FROM shakespeare.character
where speechcount > 250;

--# 7 Often we can only half-remember a line from a poem or a play. A famous line from Shakespeare is “A rose by any other name would smell as sweet”. But who says it in what play? The line is contained in one cell of the plaintext column in the paragraph table, but because of line breaks and capitalization differences, you cannot search for the string in its complete form. Construct a query that returns the name of the work (workid), character (charid), and number of words in the paragraph.
SELECT workid, charid, wordcount, plaintext
FROM shakespeare.paragraph
where plaintext ilike '%A%rose%by%any%other%name%would%smell%as%sweet%';

--# 8 What is the title and year of Shakespeare’s first work?
SELECT title, year
FROM shakespeare.work
order by "year"
limit 1;

########

-- Question 1
select SUM(totalwords) as allwords_shakespeare_Works
from shakespeare.work;

-- Question 2
select source, count(*)
from shakespeare.work
group by source;

--Question 3
select MAX(source)
from shakespeare.work;

--Question 4
select genretype, count(genretype), MAX(year) as latest, min(year) as earliest
from shakespeare.work
group by genretype
order by genretype;

--Question 5
select genretype, year, AVG(totalwords)
from shakespeare.work
where genretype = 'c'
group by genretype, year
order by year;

--Question 6
select charid, Count(workid) as num_char_appear
from shakespeare.character_work
group by charid
having count(workid) > 1
order by count(workid) desc, charid;

--Question 7
select distinct workid, sum(chapter) as Chapter_count
from shakespeare.chapter
where workid <> 'sonnets'
group by workid
having sum(chapter) > 25;

--Question 8
select year, Count(genretype) as num_genres
from shakespeare.work
group by year, genretype
having count(genretype) > 1;


--Quiz 2 ---

select workid, count(charid)
from shakespeare.character_work
group by workid
order by count(charid) desc
limit 5;
--- purpose of agg functions is to compare groups of related records. 

--Display the genre type, number of works, and average number of words for each genre in the `work` table.
--Restrict your results to those genres in which Shakespeare published more than one work.

select genretype, COUNT(workid), avg(totalwords)
from shakespeare.work
group by genretype
having COUNT(workid) > 1;



--Quiz question:List the genre type and number of works in each genre for those works published from 1600 to 1610, inclusive.Expected result: 5 rows. There should be 8 tragedies (genretype 't').Answer:

select genretype, count(*)
from shakespeare.work
where year between 1600 and 1610
group by genretype;


######

--1 What are the titles of all the plays with a scene that happens in a “churchyard”?
select title
from shakespeare.work w
join (select description, workid
from shakespeare.chapter
where description ilike '%churchyard%') c 
on w.workid = c.workid;

--2 What are the character names, play titles and full text 
-- for any line where a character mentions the word “university”. 

select title, charid, plaintext
from shakespeare.work w
join 
   (
   select plaintext, charid, workid
    from shakespeare.paragraph
     join 
          (
             select workid 
               from shakespeare.chapter		
                  where chapter ilike '%AHHHH%'
                  ) b
                  on b.workid = c.work.id
    where plaintext ilike '%university%'
    ) c 
on w.workid = c.workid;

--3 Which plays have 60 or more characters? 
-- Give the play name and the number of characters; 
-- sort the results from highest to lowest.

select distinct workid as plays, count(charid) as chars
from shakespeare.character_work
group by plays
having count(charid) > 60
order by chars desc;


--4 Some characters have no lines.
-- a. Confirm that some characters have no lines by returning a list of the names of characters with a speech count of 0. (This is a single table query.)
select charid, speechcount
from shakespeare.character
where speechcount = 0 ;

-- b. Return a list of names of characters that do not appear in the paragraph table (and therefore have no lines).
select charname
from shakespeare.character c
left join (
       select charid
       from shakespeare.paragraph 
) p
on c.charid = p.charid
where p.charid is NULL;

-- c. Confirm that these two resultsets are the same.
select *
from 
(select charid, speechcount, charname
from shakespeare.character
where speechcount = 0 ) x
full join
(select charname
from shakespeare.character c
left join (
       select charid
       from shakespeare.paragraph 
) p
on c.charid = p.charid
where p.charid is NULL) y
on x.charname = y.charname
where y.charname = x.charname;

--5 List the character, act number (section) and number of lines (rows in paragraph table) 
--for any character who has 30 lines or more in any single act of 12th Night. 
--Do not include the character “(stage directions)” in your result. 
--Sort the results by act then by number of lines.
select section, lines, charname, workid
from shakespeare.character r

join (select charid, section, workid, count(plaintext) as lines
from shakespeare.paragraph
where workid = '12night' 
group by charid, section, workid
having count(plaintext) >= 30) t

on r.charid = t.charid
where charname <> '(stage directions)'
order by section, lines;


--6 You will notice that the work table contains columns for totalwords and totalparagraphs. 
   --But can’t we derive those values from the entries in the paragraph table?
--a. Write a query which returns title, totalwords and totalparagraphs columns from the work table 
   --and the same values calculated from the paragraph table using aggregate functions. HINT: This will require a GROUP BY clause.
   select title, totalwords, totalparagraphs
   from shakespeare.work;
  
  select workid as title, sum(wordcount) as totalwords, count(distinct paragraphnum) as totalparagraphs
   from shakespeare.paragraph
  group by workid;
  

--b. Eyeballing the resultset should suggest that the stored and calculated values are the same. 
   --Confirm that by writing a query which returns only those rows where the stored and calculated values are not equal, for either word count or paragraph count. 
   --HINT: This will require a HAVING clause.
 select *
 from 
  (select title, totalwords, totalparagraphs, workid
   from shakespeare.work) A
full outer join
  (select workid, sum(wordcount) as totalwords2, count(distinct paragraphnum) as totalparagraphs2
   from shakespeare.paragraph group by workid) B
   on  A.workid = B.workid
   group by title, totalwords, totalparagraphs, a.workid, b.workid, b.totalwords2, b.totalparagraphs2
   having totalwords <> totalwords2;

  
  
  ---SQL exercise
  
  -- 6. Select fields
SELECT c.code, name, region, e.year, fertility_rate, unemployment_rate
  -- 1. From countries (alias as c)
  FROM countries AS c
  -- 2. Join to populations (as p)
  INNER JOIN populations AS p
    -- 3. Match on country code
    ON c.code = p.country_code
  -- 4. Join to economies (as e)
  INNER JOIN economies AS e
    -- 5. Match on country code and year
    ON e.code = p.country_code AND e.year = p.year;

   
   -- 5. Select fields with aliases
SELECT p1.country_code,
       p1.size AS size2010,
       p2.size AS size2015
-- 1. From populations (alias as p1)
FROM populations as p1
  -- 2. Join to itself (alias as p2)
   JOIN populations as p2
    -- 3. Match on country code
    ON p1.country_code = p2.country_code
        -- 4. and year (with calculation)
        AND p1.year = (p2.year - 5);
       
       
       -- select country, average budget, average gross
SELECT country, avg(budget) AS avg_budget, avg(gross) AS avg_gross
-- from the films table
FROM films
-- group by country 
group by country
-- where the country has more than 10 titles
Having Count(country) > 10
-- order by country
order by country
-- limit to only show 5 results
limit 5

--List the genre type and the average number of characters in works of that genre.
--Hint: As this is an aggregate of an aggregate, you will have to use a nested query for your answer.
--Expected result: 5 rows, with one of the rows being "h";47.0833…


select genretype, avg(ccharid)
FROM shakespeare.work a
join ( select workid, count(charid) as ccharid
     from shakespeare.paragraph 
     where charid <> 'xxx' AND charid NOT ilike '%-%'
     group by workid
     ) b
on a.workid = b.workid
group by genretype;


select distinct charid
from shakespeare.paragraph;


-- List the genretype and number of works in each genre for those works in 1600 and 1610 

select genretype, count(workid)
from shakespeare.work
where year BETWEEN 1600 and 1610
group by genretype;



CREATE TABLE reviewer (
  reviewerid serial PRIMARY KEY,
  reviewid serial foreign key,
  name text
);

CREATE TABLE newspaper (
  newspaperid serial PRIMARY KEY,
  reviewid serial foreign key,
  name text
);

create table review (
  workid text primary key, foreign key
  reviewrid serial primary key, foreign key, 
  newspaperid serial foreign key,
  review text,
  publication date,
  rating int
  );

#####
--Exercise: Spatial Reference Systems
--1 Create a query which measures the area of all the neighborhoods in the nyc_neighborhoods table. 
--Write one query which displays the neighborhood name, area as calculated in UTM 18N (which the data is stored in), 
--New York State Plane Long Island (look up the appropriate SRID), and on the WGS 84 spheroid by casting to the geography type. 
--Make sure to pay attention to the units, and convert all the outputs to the same units.

select name, ST_Area(geom) as UTM18N_area
from boundless.nyc_neighborhoods;

select name, ST_Area(geom) as UTM18_area,
ST_Area(ST_Transform(geom, 2831)) as NY_long_area,
st_Area(st_transform(geom, 4326)::geography) as WGS84_area
from boundless.nyc_neighborhoods;

SELECT STGeometryType("geom")
from boundless.nyc_neighborhoods;


--2 Create a query which calculates the distance from 4/5/6 Grand Central Station stop to 
--every neighborhood in nyc_neighborhoods. Show the neighborhood name and calculate the distance
-- using UTM 18N (which the data is stored in), New York State Plane Long Island,
-- and on the WGS 84 spheroid by casting to the geography type.

select c.long_name, d.name, ST_Distance(c.geom, d.geom) as UTM18_N_distance, 
  ST_Distance(st_transform(c.geom, 2831), st_transform(d.geom,2831)) as NY_Long_distance,
  ST_Distance(ST_transform(c.geom, 4326)::geography,
    ST_Transform(d.geom, 4326)::geography) as WGS84_distance
from boundless.nyc_subway_stations c
join
  boundless.nyc_neighborhoods d
on c.borough = d.boroname
where c.long_name ilike '%Grand Central%(4,5,6)%'
group by c.long_name, d.name, c.geom, d.geom
order by name;

-- 3 Create a query which calculates distances among the five most populous cities 
--(natural_earth_cultural.ne_110m_populated_places). The query should show one row for each pair of cities, and:
--a. the distance in Web Mercator (which will be useless)
--b. the distance calculated using ST_DistanceSpheroid (or ST_Distance_Spheroid in PostGIS versions prior to 2.2.0)
--c. the distance using a geography cast

-- ST_Distance_Spheroid commented out, because of following error which I could not resolve: SQL Error [XX000]: ERROR: SPHEROID parser - couldnt parse the spheroid
select a.name as a_name, a.gn_pop, b.name, ST_Distance(a.geom, b.geom) as UTM18_N_distance,
ST_Distance(st_transform(a.geom, 3857), st_transform(b.geom, 3857)) as Web_Mercator_distance,
ST_Distance(ST_transform(a.geom, 4326)::geography,
ST_Transform(b.geom, 4326)::geography) as WGS84_Cast_distance --,
--ST_Distance_Spheroid(a.geom, b.geom, 'SPHEROID ["WGS 84",6378137,298.257223563]')
from (
  select name, gn_pop, fid, geom
  from natural_earth.ne_110m_populated_places 
  order by gn_pop desc
  limit 5
) a
join 
(select name, gn_pop, fid, geom
  from natural_earth.ne_110m_populated_places 
  order by gn_pop desc
  limit 5) b
on (a.fid < b.fid);



-- Quiz Question Spatial references 

/*Calculate the great circle distance in meters between New York and Tokyo.
Use table `ne_110m_populated_places`. Use the `name` column to restrict the
distance calculation to New York and Tokyo. */

select a.name, b.name, ST_Distance_Spheroid(a.geom, b.geom, 'SPHEROID["WGS 84", 6378137,298.257223563]')
from 
( select name, geom, gid
  from natural_earth.ne_110m_populated_places
) a 
 join
( select name, geom, gid
   from natural_earth.ne_110m_populated_places
) b 
on (a.gid < b.gid)
where a.name ilike 'New York' and b.name ilike 'Tokyo';

####

--Exercise Spatial Relationships
--Question 1
--Write a query to return a list of subway stations (gid and name)
--that are within 500 meters of another subway station. 
--Hint: This will require a “self-join”, where the nyc_subway_stations table will have to be 
--listed twice (and aliased) in the FROM clause of the query

select a.gid, a.name as a_subway_stations, b.name as b_subway_stations, st_dwithin(a.geom,b.geom, 500)
from boundless.nyc_subway_stations a 
join 
 boundless.nyc_subway_stations b 
on st_dwithin(a.geom, b.geom, 500)
where a.name <> b.name;

-- Question 2
--Write an aggregate query that returns the total length of all street segments that intersect a 500m buffer of the 
--7 train stop (check the routes column) at Grand Central station. Do not clip the street segments (i.e., do not use the ST_Intersection function).
--If a street segment is partially in the boundary, count its entire length.
select  sum(st_length(b.geom)) as total_length
from boundless.nyc_subway_stations as a
join
boundless.nyc_streets as b
on st_dwithin (a.geom, b.geom, 500)
where a.name like '%Grand%Central%' and routes like '7';




--Question 3
--Write a query that determines whether any census blocks are in more than one neighborhood.
-- Make sure to use a function or functions that do not count the block as “in” if it only shares a boundary with the neighborhood. 
--HINT: Previewing the data in QGIS or ArcGIS will help you know whether your query results make sense.
select blkid, count(b.name) as neighborhood
from boundless.nyc_census_blocks a 
join 
 boundless.nyc_neighborhoods b 
on st_intersects(a.geom,b.geom)
group by blkid
having count(b.name) > 1;

--Question 4

--Write a query that returns the population of the Astoria-Long Island City neighborhood. 
--The population data is in nyc_census_blocks. Assume that any block which partially shares area with the neighborhood is “in”. 
--Based on the answer to the previous question, is this answer exact, or might it include some census blocks which extend beyond the neighborhood boundary?
  -- >>> **This answer might include some census blocks which extend beyond the neighborhood boundary. **
  
select name, sum(popn_total) as total_pop
from boundless.nyc_neighborhoods a 
join 
 boundless.nyc_census_blocks b 
 on st_intersects(a.geom, b.geom)
where name = 'Astoria-Long Island City'
group by name;


---Postgis_in_action

select *
from postgis_in_action.land;

select name, iso_country, iso_region
from postgis_in_action.airports
where ST_DWithin(
geog, ST_point(-75.0664, 40.2003)::geography, 100000); 


-- geography is spherical and geometry is planer


select  sum(st_length(b.geom)) as total_length
from boundless.nyc_subway_stations as a
join
boundless.nyc_streets as b
on st_dwithin (a.geom, b.geom, 500)
where a.name like '%Grand%Central%' and routes like '7';


select a.geom, b.geom, a.name
from boundless.nyc_subway_stations a 
join 
boundless.nyc_subway_stations b
on st_distance(a.geom, b.geom);


---- HW exercise

--Using a KNN operator and a correlated subquery, create a query which lists -
--the names of all subway stations and the nearest other subway station. 
--CHALLENGE: Also display the distance between the station. 
--Since a correlated subquery can only return a single column, 
--you would have to construct a “compound” column, either using string concatenation
--(easiest) or the array constructor (harder).

select b.name,
  ( select a.name
    from boundless.nyc_subway_stations a 
    where a.name <> b.name 
    order by a.geom <#> b.geom limit 1)
 as nearest_subway_station
 from boundless.nyc_subway_stations b;

--Using a KNN operator and a lateral join, create a query which calculates the
--distance from every subway station to the nearest five other subway stations.
--List the station names and the distances in the output.

select a.name, c.name, ST_Distance(a.geom, c.geom)
from boundless.nyc_subway_stations as a 
cross join lateral 
  ( select b.name, b.geom
    from boundless.nyc_subway_stations as b 
    order by b.geom <#> a.geom limit 5) as c; 
   
   
   
  --Create three queries which calculate the average nearest distance 
  --from NYC census blocks to subway stations for those blocks
  --which are (a) 45% or greater African-American, (b) 45% or greater White,
  --and (c) 45% or greater Asian. That is, your result should be one average
  --nearest distance for each set of census blocks meeting the given demographic criteria. 
   
   --(a) 45% or greater African-American
   select c.blkid as census_block, a.name as sub_station, perc_black, avg(st_distance(a.geom, c.geom)) as avg_distance
   from boundless.nyc_subway_stations as a 
   cross join lateral
   ( select b.blkid, ((popn_black / popn_total)*100) as perc_black,  b.geom
   from boundless.nyc_census_blocks  as b
   where popn_black <> 0
    order by b.geom <#> a.geom) as c
   where perc_black >= 45
  group by c.blkid, a.name, perc_black;
  
  --(a) 45% or greater White
   select c.blkid as census_block, a.name as sub_station, perc_white, avg(st_distance(a.geom, c.geom)) as avg_distance
   from boundless.nyc_subway_stations as a 
   cross join lateral
   ( select b.blkid, ((popn_white / popn_total)*100) as perc_white,  b.geom
   from boundless.nyc_census_blocks  as b
   where popn_white <> 0
    order by b.geom <#> a.geom) as c
   where perc_white >= 45
     group by c.blkid, a.name, perc_white;
  
   --(a) 45% or greater Asian
   select c.blkid as census_block, a.name as sub_station, perc_asian, avg(st_distance(a.geom, c.geom)) as avg_distance
   from boundless.nyc_subway_stations as a 
   cross join lateral
   ( select b.blkid, ((popn_asian / popn_total)*100) as perc_asian,  b.geom
   from boundless.nyc_census_blocks  as b
   where popn_asian <> 0
    order by b.geom <#> a.geom) as c
   where perc_asian >= 45
     group by c.blkid, a.name, perc_asian;
   
 --1 part 2 Create a query which calculates distances from each city
 --in the United States in the ne_110m_populated_places layer 
 --to its five nearest cities in any country. List the cities 
 --and distances in the output.

  select a.name as US_city, c.name, ST_Distance(a.geom, c.geom)
  from natural_earth.ne_110m_populated_places as a
  cross join lateral
   ( select b.name, b.geom 
     from natural_earth.ne_110m_populated_places as b 
     order by b.geom <#> a.geom limit 5) as c
  where sov0name ilike 'United%States';
 
 ###

-- install postgis tiger geocoder --
-- <start id="code_install_postgis_tiger_geocoder" > --
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis_tiger_geocoder; -- <co id="co_install_postgis_tiger_geocoder_1" /> --
CREATE EXTENSION address_standardizer;

GRANT USAGE ON SCHEMA tiger TO PUBLIC; -- <co id="co_install_postgis_tiger_geocoder_2" /> --
GRANT USAGE ON SCHEMA tiger_data TO PUBLIC;
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES 
 IN SCHEMA tiger TO PUBLIC;
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES 
 IN SCHEMA tiger_data TO PUBLIC;
GRANT EXECUTE ON ALL FUNCTIONS 
 IN SCHEMA tiger TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA tiger_data -- <co id="co_install_postgis_tiger_geocoder_3" /> --
    GRANT SELECT,  REFERENCES ON TABLES TO PUBLIC;
-- <end id="code_install_postgis_tiger_geocoder" > --
-- [1] install the extension
-- [2] Grant read and execute rights to all users of db
-- [3] future table permissions

-- Create dummy records to batch geocode
-- <start id="code_geocode_batch_create" > --
DROP TABLE IF EXISTS addr_to_geocode;
CREATE TABLE addr_to_geocode(addid serial NOT NULL PRIMARY KEY, 
	rating integer, 
	address text, 
	norm_address text, pt geometry);
INSERT INTO addr_to_geocode(address)
	VALUES ('1000 Huntington Street, DC'),
		('4758 Reno Road, DC 20017'),
		('1021 New Hampshare Avenue, Washington, DC 20010'),
		('1731 New Hampshire Avenue Northwest, Washington, DC 20010'),
		('1 Palisades, Denver, CO');
-- <end id="code_geocode_batch_create" > --

-- Listing PAGC standardizer
-- Listing calling standardize address --
-- <start id="code_standardize_address" > --
SELECT (std).house_num, (std).name, (std).suftype, (std).sufdir
  FROM (SELECT standardize_address('pagc_lex'  -- <co id="co_code_standardize_address_1" /> --
       , 'pagc_gaz'  -- <co id="co_code_standardize_address_2" /> --
       , 'pagc_rules'  -- <co id="co_code_standardize_address_3" /> --
  , address  -- <co id="co_code_standardize_address_4" /> --
  ) As std  -- <co id="co_code_standardize_address_5" /> --;
   FROM addr_to_geocode) AS s ;
-- <end id="code_standardize_address" /> --

-- <start id="code_standardize_pagc_normalize" /> --
SELECT 
   address As hnum, streetname 
   , streettypeabbrev, postdirabbrev AS postdir
   , internal As num, stateabbrev As st 
FROM 
 pagc_normalize_address('1731 New Hampshire Avenue Northwest
   , Washington, DC 20010') As addy;
-- <end id="code_standardize_pagc_normalize" /> --

-- Listing bUILT-IN standardizer
-- <start id="code_standardize_normalize" /> --
SELECT 
   address As hnum, streetname 
   , streettypeabbrev, postdirabbrev AS postdir
   , internal As num, stateabbrev As st 
FROM 
 normalize_address('1731 New Hampshire Avenue Northwest
  , Washington, DC 20010') As addy;
-- <end id="code_standardize_normalize" /> --

-- Listing 8.1 Example of geocode function -
-- <start id="code_geocode_basic" > --
SELECT 
   g.rating As r, -- <co id="co_code_geocode_basic_1" /> --
	ST_X(geomout) As lon, -- <co id="co_code_geocode_basic_2" /> --
	ST_Y(geomout) As lat, 
  pprint_addy(addy) As paddress   -- <co id="co_code_geocode_basic_3" /> --
FROM 
  geocode('1731 New Hampshire Avenue Northwest, Washington, DC 20010') 
    As g;
-- <end id="code_geocode_basic" > --
-- 1 output rating
-- 2 output longitude and latitude from postgis point
-- 3 output all properties of normalize return address

-- Listing 8.2 Listing specific elements of addy in geocode results
-- <start id="code_geocode_specific_addy" > --
SELECT g.rating As r, 
	ST_X(g.geomout)::numeric(10,5) As lon, -- <co id="co_code_geocode_specific_addy_1_l1" /> --
	ST_Y(g.geomout)::numeric(10,5) As lat, -- <co id="co_code_geocode_specific_addy_1_l2" /> --
	(g.addy).address As snum,          -- <co id="co_code_geocode_specific_addy_2_l1" /> --
	(g.addy).streetname || ' '   -- <co id="co_code_geocode_specific_addy_2_l2" /> --
	  || (g.addy).streettypeabbrev As street,
	(g.addy).zip  -- <co id="co_code_geocode_specific_addy_2_l3" /> --
FROM geocode('1021 New Hampshare Avenue   
   , Washington, DC 20009',1) As g; -- <co id="co_code_geocode_specific_addy_3_l1" /> --
-- <end id="code_geocode_specific_addy" > --

-- Listing Listing using pagc_normalize_address
-- <start id="code_geocode_pagc" > --
SELECT 
   g.rating As r, 
	ST_X(geomout) As lon,
	ST_Y(geomout) As lat, 
  pprint_addy(addy) As paddress 
FROM 
  geocode(
    pagc_normalize_address('1731 New Hampshire Avenue Northwest
     , Washington, DC 20010')
    ) 
    As g;
-- <end id="code_geocode_pagc" > --


-- <start id="code_geocode_batch_basic_pre93" > --
UPDATE addr_to_geocode
	SET  (rating, norm_address, pt)  -- <co id="co_code_geocode_batch_basic_pre93_1_l1" /> --
	    = ( COALESCE( (g).rating,-1 ), -- <co id="co_code_geocode_batch_basic_pre93_2_l1" /> --
			pprint_addy( (g).addy ),
			(g).geomout  )
FROM  (SELECT *
  FROM addr_to_geocode 
  WHERE rating IS NULL 
   LIMIT 100 -- <co id="co_code_geocode_batch_basic_pre93_3_l1" /> -- 
   ) AS a 
  LEFT JOIN (SELECT addid,  geocode(address, 1) As g
 FROM addr_to_geocode As ag
    WHERE rating IS NULL
	 ) As g1 ON a.addid = g1.addid
WHERE a.addid = addr_to_geocode.addid ;
-- <end id="code_geocode_batch_basic_pre93" > --
-- [1] multi-column update
-- [2] select output from geocoder result
-- [3] batches of 100

-- <start id="code_geocode_batch_basic_93" > --
UPDATE addr_to_geocode
	SET  (rating, norm_address, pt)  -- <co id="co_code_geocode_batch_basic_93_1_l1" /> --
	    = ( COALESCE( (g).rating,-1 ), 
                   pprint_addy( (g).addy ),
			(g).geomout  )
FROM (SELECT * FROM addr_to_geocode 
  WHERE rating IS NULL LIMIT 100) As a -- <co id="co_code_geocode_batch_basic_93_2_l1" /> --
  LEFT JOIN LATERAL geocode(a.address, 1)  As g  -- <co id="co_code_geocode_batch_basic_93_3_l1" /> --
    ON ( (g).rating < 22) -- <co id="co_code_geocode_batch_basic_93_4_l1" /> --
WHERE a.addid = addr_to_geocode.addid ;
-- <end id="code_geocode_batch_basic_93" > --
-- [1] multi-column update
-- [2] batch in 100s
-- [3] left lateral


/** General comment  - NOT to run **/
-- note this is the ANSI standard way supported by Oracle, but sadly PostgreSQL does not support a SELECT multicolumn construct use subsekect
UPDATE addr_to_geocode
	SET (rating, norm_address, pt) 
		= (SELECT g.rating, 
				(g.addy).address 
				  || COALESCE(' ' || (g.addy).predirabbrev, '') 
					|| ' ' || (g.addy).streetname 
					|| ' ' || (g.addy).streettypeabbrev,
				ST_SnapToGrid(g.geomout, 0.000001)
				FROM geocode(addr_to_geocode.address,1) As g
					);
/** End General comment **/


-- Reverse geocoding --
-- <start id="code_reverse_geocode_batch" > --
SELECT address, pprint_addy((rc).addy[1]) As padd_1,  -- <co id="co_code_reverse_geocode_batch_1_l1" /> --
  (rc).street[1] As cstreet_1 -- <co id="co_code_reverse_geocode_batch_2_l1" /> --
FROM (
SELECT address, reverse_geocode(pt) AS rc
FROM addr_to_geocode
WHERE  rating > -1 ) AS ag;
-- <end id="code_reverse_geocode_batch" > --



select





select ("40. 5.1 - fugitive air" + "41. 5.2 - stack air") as combo_air, "30. chemical"
from tri_pa_2017.tri_2017_pa_laundered;



select sum("40. 5.1 - fugitive air") as air_emissions, "7. county"
from tri_pa_2017.tri_2017_pa_laundered
where "7. county" ilike 'philadelphia' OR "7. county" ilike 'allegheny' and "37. carcinogen" = 'YES'
group by "7. county"
order by air_emissions desc;

###





CREATE TABLE researcher (
  researcherid serial PRIMARY KEY,
  name text
);

create table notes (
    notes text,
notes_id serial primary key,
researcherid int references researcher (researcherid),
paragraph int references paragraph (paragraphid)
);

create table publish (
publishid serial primary key,
paragraph int references paragraph (paragraphid),
researcherid int references researcher (researcherid),
notes text
);



####


-- Geocode a single address.
select g.rating as r,
pprint_addy(g.addy),
st_x(g.geomout) ::numeric (10,5) as Lon,
st_y(g.geomout) ::numeric (10,5) as Lat,
g.geomout
from geocode('800 N French St, Wilmington, DE 19801',1) as g;


-- Parse and normalize addresses
select *
from
pagc_normalize_address
('three Henry Ave, Philadelphia, PA 19129');

select *
from
normalize_address
('three Henry Ave, Philadelphia, PA 19129');


--- Preparing a batch geocoder ----
drop table if exists addr_to_geocode;

--- Create a batch geocoding table
create table addr_to_geocode (
	addid serial not null primary key,
	rating integer,
	address text,
	norm_address text,
	pt geometry
	);


-- insert yo addresses to the new table 
insert into addr_to_geocode (address)
values
	('4001 Baring street apt#5, Philadelphia, PA, 19104'),
	('7816 Brous Avenue, Philadelphia, PA 19152'),
	('126 Gwynmont Drive, North Wales, PA 19454'),
	('800 N French St, Wilmington, DE 19801');

-- Batch your addresses
update addr_to_geocode
set 
	(rating, norm_address, pt) =
	   (coalesce((g).rating, -1), pprint_addy ((g).addy), (g).geomout)
from
	(select * from addr_to_geocode
		where rating is null limit 10) as a
	left join
	(select addid, geocode(address, 1) as g
from addr_to_geocode as ag
	where rating is null) as g1 on a.addid =g1.addid
where a.addid = addr_to_geocode.addid;


--View the coordinates!
select *
from addr_to_geocode;


--- REVERSE GEOCODING-----

--- Preparing a batch geocoder ----
drop table if exists addr_to_geocode;

--- Create a batch geocoding table
create table addr_to_geocode (
	addid serial not null primary key,
--	rating integer,
	address text,
--	norm_address text,
	pt geometry
	);


--insert coordinates for reverse geocoding
insert into addr_to_geocode (pt)
values 
   ('POINT (-76.1339 40.007637)'),
   ('POINT (-74.9605 40.149619)'),
   ('POINT (-75.546853 39.742872)'),
   ('POINT (-75.202373 39.960547)'),
   ('POINT (-76.295016 40.015822)'),
   ( 'POINT (-75.202321 39.960432)');

-- Reverse Geocode
select x.addid identifier, 
pprint_addy((rc).addy[1])::varchar(100) as primary_address,
(rc).street[1]::varchar(12) as cross_street
from (
  select addid, address, reverse_geocode(pt) as rc 
  from addr_to_geocode
  ) as x;
 
####

--Homework: ETL Street Poles
-- Tom McKeon

-- (1 points) Create the ogr2ogr command to import Street_Poles.csv into PostGIS.

-- ogr2ogr -f PostgreSQL PG:"host=localhost port=5433 dbname=gis user=docker password=docker" 
-- -lco SCHEMA=import_street_poles -nlt PROMOTE_TO_MULTI Street_Poles.csv -lco PRECISION=NO -oo EMPTY_STRING_AS_NULL=YES


-- checking tables
select * from pole_type;
select * from street_pole; 
select * from import_street_pole;
select * from pole_owner;
select * from alley_pole;
select * from pole_light_info;

alter table import_street_poles.street_poles rename to import_street_pole;
set search_path to import_street_poles, public;

--(0 points) Create a pole_owner lookup table.
drop table if exists pole_owner cascade;
create table pole_owner (
  pole_owner_id serial primary key,
  pole_owner varchar 
  );
 
 
insert into pole_owner (pole_owner)
select distinct owner from import_street_pole;


--(1 point) Create a pole_type lookup table.

drop table if exists pole_type cascade;
create table pole_type (
   pole_type varchar primary key,
   description varchar  
   );
  
insert into pole_type (pole_type, description) values 
('AAMP', 'avenue of the arts mast arm pole'),
('AAPT', 'avenue of the arts street light pole'),
('AEL', 'alley pole'),
('C13', 'traffic c post 13'),
('C20', 'traffic c post 20'),
('CCP', 'centery city pedestrian pole'),
('CCR', 'center city roadway pole'),
('CHP', 'chestnut hill street light pole'),
('D30', 'traffic d pole'),
('FLP', 'franklin light pole'),
('MAP', 'traffic mast arm pole'),
('MAPT', 'traffic mast arm pole (twin light)'),
('MLP', 'millenium light pole'),
('MLPT', 'millenium light pole (twin light)'),
('OTHT', 'other (twin light)'),
('PDT', 'penndot pole'),
('PDTT', 'pendot pole (twin light)'),
('PKY', 'parkway street light pole'),
('PKYT', 'parkway street light pole (twin pole)'),
('PTA', 'post top pole (aluminum)'),
('PTC', 'post top pole (concrete)'),
('PTF', 'post top pole (fiberglass)'),
('PVT', 'private pole'),
('PVTT', 'private pole (twin light)'),
('RP', 'radar traffic pole'),
('SLA', 'street light aluminum'),
('SLAT', 'street light aluminum (twin light)'),
('SLF', 'street ligt fiberglass'),
('SLFT', 'street light fiberglass (twin light)'),
('SM', 'structure mounted'),
('SMP', 'strawberry mansion bridge pole'),
('SNP', 'sign pole'),
('SWP', 'span wire pole'),
('TP', 'trolley pole'),
('WP', 'wood pole'),
('WPT', 'wood pole (twin light)'),
('CTP', 'chinatown pole'),
('SSP', 'south street tower pole'),
('SMB', 'septa millennia bridge pole'),
('JMB', 'jfk blvd millennia bridge pole'),
('MMB', 'market st millennia bridge pole'),
('CMB', 'chestnut st millenia bridge pole'),
('WMB', 'walnut st millenia bridge pole'),
('SMAB', 'strawberry mansion arch bridge pole'),
('FB', 'falls bridge pole'),
('RLP', 'red light camera pole'),
('TCB', 'traffic control box'),
('AASP', 'avenue of the arts signal pole'),
('CP', 'carrier pole'),
('MBC', 'unknown'),
('OTH', 'other');
 
--(2 point) Create the main street_pole table.
drop table if exists street_pole cascade;
create table street_pole (
	gid serial primary key,
	pole_owner_id int references pole_owner(pole_owner_id),
	pole_type varchar references pole_type(pole_type),
	pole_numcolumn int,
	pole_date date,
	geom geometry(POINT, 2272),
	tap_id int
);

--(1 points) Create related tables for the lighting info and the alley pole info. 

drop table if exists pole_light_info cascade;
create table pole_light_info (
   gid int primary key,
   nlumin int,
   lumin_size int,
   height int
);


drop table if exists alley_pole cascade;
create table alley_pole (
   gid int primary key,
   block varchar,
   plate varchar
);

--(3 points) Transform and insert the data into street_pole.
insert into street_pole (gid, pole_type, pole_numcolumn, pole_date, geom, tap_id, pole_owner_id)
select 
objectid :: int, 
type :: varchar,
pole_num :: int,
pole_date :: date,
ST_Transform(ST_SetSRID(ST_Point(x:: double precision, y:: double precision ), 4326), 2272),
tap_id :: int,
  (select pole_owner_id
      from pole_owner as b
         where b.pole_owner = a.owner)
from import_street_pole as a;

select *
from pole_owner;


--(1 point) Insert related data into pole_light_info and alley_pole.
insert into alley_pole (gid, block, plate)
select 
objectid :: int,
block :: varchar,
plate :: varchar
from import_street_pole
 where not (block is null or plate is null);

insert into pole_light_info (gid, nlumin, lumin_size, height)
select
objectid :: int,
nlumin :: int,
lum_size :: int,
height :: int
from import_street_pole
 where not (nlumin is null or lum_size is null);
####

---- HW exercise

--Using a KNN operator and a correlated subquery, create a query which lists -
--the names of all subway stations and the nearest other subway station. 
--CHALLENGE: Also display the distance between the station. 
--Since a correlated subquery can only return a single column, 
--you would have to construct a “compound” column, either using string concatenation
--(easiest) or the array constructor (harder).

select *
from boundless.nyc_subway_stations;

select b.name,
  ( select a.name
    from boundless.nyc_subway_stations a 
    where a.name <> b.name 
    order by a.geom <#> b.geom limit 1)
 as nearest_subway_station
 from boundless.nyc_subway_stations b;

--Using a KNN operator and a lateral join, create a query which calculates the
--distance from every subway station to the nearest five other subway stations.
--List the station names and the distances in the output.

select a.name, c.name, ST_Distance(a.geom, c.geom)
from boundless.nyc_subway_stations as a 
cross join lateral 
  ( select b.name, b.geom
    from boundless.nyc_subway_stations as b 
    order by b.geom <#> a.geom limit 5) as c; 
   
   
   
  --Create three queries which calculate the average nearest distance 
  --from NYC census blocks to subway stations for those blocks
  --which are (a) 45% or greater African-American, (b) 45% or greater White,
  --and (c) 45% or greater Asian. That is, your result should be one average
  --nearest distance for each set of census blocks meeting the given demographic criteria. 
   
   --(a) 45% or greater African-American
   select c.blkid as census_block, a.name as sub_station, perc_black, avg(st_distance(a.geom, c.geom)) as avg_distance
   from boundless.nyc_subway_stations as a 
   cross join lateral
   ( select b.blkid, ((popn_black / popn_total)*100) as perc_black,  b.geom
   from boundless.nyc_census_blocks  as b
   where popn_black <> 0
    order by b.geom <#> a.geom) as c
   where perc_black >= 45
  group by c.blkid, a.name, perc_black;
  
  --(a) 45% or greater White
   select c.blkid as census_block, a.name as sub_station, perc_white, avg(st_distance(a.geom, c.geom)) as avg_distance
   from boundless.nyc_subway_stations as a 
   cross join lateral
   ( select b.blkid, ((popn_white / popn_total)*100) as perc_white,  b.geom
   from boundless.nyc_census_blocks  as b
   where popn_white <> 0
    order by b.geom <#> a.geom) as c
   where perc_white >= 45
     group by c.blkid, a.name, perc_white;
  
   --(a) 45% or greater Asian
   select c.blkid as census_block, a.name as sub_station, perc_asian, avg(st_distance(a.geom, c.geom)) as avg_distance
   from boundless.nyc_subway_stations as a 
   cross join lateral
   ( select b.blkid, ((popn_asian / popn_total)*100) as perc_asian,  b.geom
   from boundless.nyc_census_blocks  as b
   where popn_asian <> 0
    order by b.geom <#> a.geom) as c
   where perc_asian >= 45
     group by c.blkid, a.name, perc_asian;
    
    select blkid, popn_total, popn_asian
    from boundless.nyc_census_blocks
    where blkid = '360050060001016';
   
 --1 part 2 Create a query which calculates distances from each city
 --in the United States in the ne_110m_populated_places layer 
 --to its five nearest cities in any country. List the cities 
 --and distances in the output.

  select a.name as US_city, c.name, ST_Distance(a.geom, c.geom)
  from natural_earth.ne_110m_populated_places as a
  cross join lateral
   ( select b.name, b.geom 
     from natural_earth.ne_110m_populated_places as b 
     order by b.geom <#> a.geom limit 5) as c
  where sov0name ilike 'United%States';
 ####