# Joins

JOIN

```SQL
SELECT *
FROM district_2020 JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;
```

INNER JOIN

```SQL
SELECT *
FROM district_2020 INNER JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;
```

JOIN with USING

```SQL
SELECT *
FROM district_2020 JOIN district_2035
USING (id)
ORDER BY district_2020.id;
```

LEFT JOIN

```SQL
SELECT *
FROM district_2020 LEFT JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;
```

RIGHT JOIN

```SQL
SELECT *
FROM district_2020 RIGHT JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2035.id;
```

FULL OUTER JOIN

```SQL
SELECT *
FROM district_2020 FULL OUTER JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;
```

CROSS JOIN

```SQL
SELECT *
FROM district_2020 CROSS JOIN district_2035
ORDER BY district_2020.id, district_2035.id;

-- Alternately, a CROSS JOIN can be written with a comma-join syntax:
SELECT *
FROM district_2020, district_2035
ORDER BY district_2020.id, district_2035.id;

-- Or it can be written as a JOIN with true in the ON clause:
SELECT *
FROM district_2020 JOIN district_2035 ON true
ORDER BY district_2020.id, district_2035.id;
```

Filtering

```SQL
SELECT *
FROM district_2020 LEFT JOIN district_2035
ON district_2020.id = district_2035.id
WHERE district_2035.id IS NULL;

-- alternately, with a RIGHT JOIN
SELECT *
FROM district_2020 RIGHT JOIN district_2035
ON district_2020.id = district_2035.id
WHERE district_2020.id IS NULL;
```

Joining multiple tables

```SQL
SELECT  d20.id,
        d20.school_2020,
        en.enrollment,
        gr.grades
FROM district_2020 AS d20 JOIN district_2020_enrollment AS en
ON d20.id = en.id
JOIN district_2020_grades AS gr
ON d20.id = gr.id
ORDER BY d20.id;
```

UNION

```SQL
-- Combining query results with UNION

SELECT _ FROM district_2020
UNION
SELECT _ FROM district_2035
ORDER BY id;

-- Combining query results with UNION ALL

SELECT _ FROM district_2020
UNION ALL
SELECT _ FROM district_2035
ORDER BY id;

-- Customizing a UNION query

SELECT '2020' AS year,
school_2020 AS school
FROM district_2020

UNION ALL

SELECT '2035' AS year,
school_2035
FROM district_2035
ORDER BY school, year;
```

Combining query results with INTERSECT and EXCEPT

```SQL
SELECT _ FROM district_2020
INTERSECT
SELECT _ FROM district_2035
ORDER BY id;

SELECT _ FROM district_2020
EXCEPT
SELECT _ FROM district_2035
ORDER BY id;
```

Performing math on joined Census population estimates tables

```SQL
CREATE TABLE us_counties_pop_est_2010 (
  state_fips text, -- State FIPS code
  county_fips text, -- County FIPS code
  region smallint, -- Region
  state_name text, -- State name
  county_name text, -- County name
  estimates_base_2010 integer, -- 4/1/2010 resident total population estimates base
  CONSTRAINT counties_2010_key PRIMARY KEY (state_fips, county_fips)
);

COPY us_counties_pop_est_2010
FROM 'C:\YourDirectory\us_counties_pop_est_2010.csv'
WITH (FORMAT CSV, HEADER);

SELECT  c2019.county_name,
        c2019.state_name,
        c2019.pop_est_2019 AS pop_2019,
        c2010.estimates_base_2010 AS pop_2010,
        c2019.pop_est_2019 - c2010.estimates_base_2010 AS raw_change,
        round( (c2019.pop_est_2019::numeric - c2010.estimates_base_2010)
        / c2010.estimates_base_2010 \* 100, 1 ) AS pct_change
FROM us_counties_pop_est_2019 AS c2019
JOIN us_counties_pop_est_2010 AS c2010
ON c2019.state_fips = c2010.state_fips
AND c2019.county_fips = c2010.county_fips
ORDER BY pct_change DESC;
```
