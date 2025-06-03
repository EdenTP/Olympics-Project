# Olympic Results Star Schema (MySQL)

## 📊 Project Overview

This project focuses on transforming a large, flat Olympic results dataset into a structured format suitable for analysis. Below is a description of each column found in the original staging table:

| Column Name   | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| ID            | Unique identifier for each athlete record.                            |
| Name          | Full name of the athlete.                                                    |
| Sex           | Gender of the athlete (`M` for male, `F` for female).                        |
| Age           | Age of the athlete at the time of the event (may contain nulls).            |
| Height        | Height of the athlete in centimeters (may contain nulls).                   |
| Weight        | Weight of the athlete in kilograms (may contain nulls).                     |
| Team          | Name of the country or team the athlete represents.                         |
| NOC           | National Olympic Committee code (three-letter abbreviation, e.g., `USA`).   |
| Games         | Combination of year and season (e.g., `2000 Summer`).                       |
| Year          | Year in which the Olympic Games took place.                                 |
| Season        | Season of the Olympic Games (`Summer` or `Winter`).                         |
| City          | Host city for the Olympic Games.                                            |
| Sport         | General category of the event (e.g., `Athletics`, `Swimming`).              |
| Event         | Specific event competed in (e.g., `100m Freestyle`, `Basketball Men’s Team`).|
| Medal         | Medal won by the athlete (`Gold`, `Silver`, `Bronze`, or null if none).     |
| NOC_Region    | Full region or country name associated with the `NOC` code.                 |
| NOC_notes     | Additional notes or clarifications about the NOC (optional/nullable).       |

This staging table was used as the starting point for normalization into a star schema for analytics purposes.


# 🧾 SQL Query Breakdown

Below is a breakdown of the key SQL queries used to transform and normalize the Olympic staging dataset into dimension and fact tables.

---

## 1. Checking id is unique to each athlete

```sql
select 
  id, 
  count(distinct name) as counts 
from 
  staging 
group by 
  id 
having 
  counts > 1;
```

**Purpose**: Counts the number of athlete names that can be attributed to each `id`.

---

## 2. Check Maximum Field Lengths

```sql
SELECT 
  MAX(LENGTH(name)),
  MAX(LENGTH(sex)),
  MAX(LENGTH(team)),
  MAX(LENGTH(noc)),
  MAX(LENGTH(noc_region)),
  MAX(LENGTH(NOC_notes)),
  MAX(LENGTH(event)),
  MAX(LENGTH(city)),
  MAX(LENGTH(season)),
  MAX(LENGTH(sport)),
  MAX(LENGTH(games)),
  MAX(LENGTH(medal))
FROM olympics.staging;
```

**Purpose**: Analyzes maximum lengths of fields to inform appropriate column sizes when creating dimension tables.

---

## 3. Create `athletes` Table

```sql
CREATE TABLE athletes AS
SELECT DISTINCT 
  id AS athleteid,
  sex,
  NULLIF(height, '') AS height,
  NULLIF(weight, '') AS weight
FROM staging;
```

**Purpose**: Generates a dimension table `athletes` by selecting distinct athlete IDs along with demographic info, treating empty strings as `NULL`.

---

## 4. View `athletes` Table

```sql
SELECT * FROM athletes;
```

**Purpose**: Simple check to verify the contents of the newly created `athletes` table.

---

## 5. Create `games` Table

```sql
CREATE TABLE games AS
WITH games AS (
  SELECT DISTINCT games, season, city, year FROM staging
)
SELECT 
  ROW_NUMBER() OVER(ORDER BY year) AS gameid,
  games, season, city, year
FROM games;
```

**Purpose**: Creates a `games` dimension table with unique Olympic game editions and assigns a surrogate `gameid`.

---

## 6. Create `teams` Table

```sql
CREATE TABLE teams AS
WITH teams AS (
  SELECT DISTINCT team, NOC, noc_region, noc_notes FROM staging
)
SELECT 
  ROW_NUMBER() OVER(ORDER BY team) AS teamid,
  team, NOC, noc_region, noc_notes
FROM teams;
```

**Purpose**: Builds the `teams` dimension table with unique team info and a generated `teamid`.

---

## 7. Validate Event Uniqueness

```sql
SELECT 
  event,
  COUNT(DISTINCT sport) AS count
FROM staging
GROUP BY event
HAVING count > 1;
```

**Purpose**: Detects data quality issues where a single event name is linked to multiple sports.

---

## 8. Create `events` Table

```sql
CREATE TABLE events AS
WITH events AS (
  SELECT DISTINCT event, sport FROM staging
)
SELECT 
  ROW_NUMBER() OVER(ORDER BY event) AS eventid,
  event, sport
FROM events;
```

**Purpose**: Constructs the `events` dimension table, ensuring each unique event-sport pair has a surrogate `eventid`.

---

## 9. Create `results` Fact Table

```sql
CREATE TABLE results AS
WITH results AS (
  SELECT 
    a.athleteid,
    e.eventid,
    t.teamid,
    gameid,
    medal,
    age
  FROM staging AS s
  LEFT JOIN teams AS t ON s.noc = t.noc AND s.team = t.team 
                        AND s.noc_region = t.noc_region AND s.noc_notes = t.noc_notes
  LEFT JOIN games AS g ON g.games = s.games AND g.season = s.season AND g.city = s.city
  LEFT JOIN athletes AS a ON a.athleteid = s.id
  LEFT JOIN events AS e ON e.event = s.event AND e.sport = s.sport
)
SELECT 
  ROW_NUMBER() OVER(ORDER BY e.eventid, a.athleteid) AS resultid,
  athleteid, eventid, teamid, gameid, medal, age
FROM results;
```

**Purpose**: Builds the central `fact_results` table by joining all dimensions and assigning a unique `resultid` to each athlete-event occurrence.

---

## 10. View `results` Table

```sql
SELECT * FROM results;
```

**Purpose**: Quick check to confirm the data has been inserted into the fact table as expected.

