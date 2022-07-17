# SQL_scripts
SQL exercises

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
join (select plaintext, charid, workid
from shakespeare.paragraph
where plaintext ilike '%university%') c
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
