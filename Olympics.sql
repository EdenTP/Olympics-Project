with teams as (
  SELECT 
    DISTINCT team, 
    noc, 
    noc_region, 
    NOC_notes 
  FROM 
    staging
) 
SELECT 
  ROW_NUMBER() OVER(
    ORDER BY 
      team
  ) as team_id, 
  team, 
  noc, 
  noc_region, 
  NOC_notes 
FROM 
  teams;
SELECT 
  MAX(
    LENGTH(name)
  ), 
  MAX(
    LENGTH(sex)
  ), 
  MAX(
    LENGTH(team)
  ), 
  MAX(
    LENGTH(noc)
  ), 
  MAX(
    LENGTH(noc_region)
  ), 
  MAX(
    LENGTH(NOC_notes)
  ), 
  MAX(
    LENGTH(event)
  ), 
  MAX(
    LENGTH(city)
  ), 
  MAX(
    LENGTH(season)
  ), 
  MAX(
    LENGTH(sport)
  ), 
  MAX(
    LENGTH(games)
  ), 
  MAX(
    LENGTH(medal)
  ) 
FROM 
  olympics.staging;
create table athletes as 
select 
  distinct id as athleteid, 
  sex, 
  nullif(height, '') as height, 
  nullif(weight, '') as weight 
from 
  staging;
select 
  * 
from 
  athletes;
create table games with games as (
  select 
    distinct games, 
    season, 
    city, 
    year 
  from 
    staging
) 
select 
  row_number() over(
    order by 
      year
  ) as gameid, 
  games, 
  season, 
  city, 
  year 
from 
  games;
create table teams with teams as(
  select 
    distinct team, 
    NOC, 
    noc_region, 
    noc_notes 
  from 
    staging
) 
select 
  row_number() over(
    order by 
      team
  ) as teamid, 
  team, 
  NOC, 
  noc_region, 
  noc_notes 
from 
  teams;
select 
  event, 
  count(distinct sport) as count 
from 
  staging 
group by 
  event 
having 
  count > 1;
create table events with events as (
  select 
    distinct event, 
    sport 
  from 
    staging
) 
select 
  row_number() over(
    order by 
      event
  ) as eventid, 
  event, 
  sport 
from 
  events;
create table results with results as(
  select 
    a.athleteid, 
    e.eventid, 
    t.teamid, 
    gameid, 
    medal, 
    age 
  from 
    staging as s 
    left join teams as t on s.noc = t.noc 
    and s.team = t.team 
    and s.noc_region = t.noc_region 
    and s.noc_notes = t.noc_notes 
    left join games as g on g.games = s.games 
    and g.season = s.season 
    and g.city = s.city 
    left join athletes as a on a.athleteid = s.id 
    left join events as e on e.event = s.event 
    and e.sport = s.sport
) 
select 
  row_number() over(
    order by 
      e.eventid, 
      a.athleteid
  ) as resultid, 
  athleteid, 
  eventid, 
  teamid, 
  gameid, 
  medal, 
  age 
from 
  results;
select 
  * 
from 
  results
