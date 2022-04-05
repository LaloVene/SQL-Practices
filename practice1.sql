-- 1
SELECT school, first_name FROM teachers ORDER BY school, first_name ASC;

-- 2
SELECT * FROM teachers WHERE first_name LIKE 'S%' AND salary >= 40000;

-- 3
SELECT * FROM teachers WHERE hire_date >= '2010-01-01' ORDER BY salary ASC;
