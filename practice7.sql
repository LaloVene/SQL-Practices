-- Import Table from CSV file
CREATE TABLE meat_poultry_egg_establishments (
establishment_number text CONSTRAINT est_number_key PRIMARY KEY,
company text,
street text,
city text,
st text,
zip text,
phone text,
grant_date date,
activities text,
dbas text
);

COPY meat_poultry_egg_establishments
FROM '/tmp/MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX company_idx ON meat_poultry_egg_establishments (company);

Select count(\*) from meat_poultry_egg_establishments;

-- Group By those Establishments what appear more than once
SELECT company,
street,
city,
st,
count(_) AS address_count
FROM meat_poultry_egg_establishments
GROUP BY company, street, city, st
HAVING count(_) > 1
ORDER BY company, street, city, st;

SELECT st,
count(\*) AS st_count
FROM meat_poultry_egg_establishments
GROUP BY st
ORDER BY st;

SELECT establishment_number,
company,
city,
st,
zip
FROM meat_poultry_egg_establishments
WHERE st IS NULL;

SELECT company,
count(\*) AS company_count
FROM meat_poultry_egg_establishments
GROUP BY company
ORDER BY company ASC;

SELECT length(zip),
count(\*) AS length_count
FROM meat_poultry_egg_establishments
GROUP BY length(zip)
ORDER BY length(zip) ASC;

SELECT st,
count(\*) AS st_count
FROM meat_poultry_egg_establishments
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;

-- Create Backup table
CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT \* FROM meat_poultry_egg_establishments;

-- Comparing Original vs Backup table
SELECT
(SELECT count(_) FROM meat_poultry_egg_establishments) AS original,
(SELECT count(_) FROM meat_poultry_egg_establishments_backup) AS backup;
-- Adding new column and copying information from another column into it
ALTER TABLE meat_poultry_egg_establishments ADD COLUMN st_copy text;
UPDATE meat_poultry_egg_establishments
SET st_copy = st;

-- There are no registers because the columns are the same
SELECT st,
st_copy
FROM meat_poultry_egg_establishments
WHERE st IS DISTINCT FROM st_copy
ORDER BY st;

-- Update establishment_number from all registers with st = MN
UPDATE meat_poultry_egg_establishments
SET st = 'MN'
WHERE establishment_number = 'V18677A';

UPDATE meat_poultry_egg_establishments
SET st = 'AL'
WHERE establishment_number = 'M45319+P45319';

-- Update establishments with establishment number M263A+P263A+V263A
-- And doing a Select (Returning) query
UPDATE meat_poultry_egg_establishments
SET st = 'WI'
WHERE establishment_number = 'M263A+P263A+V263A'
RETURNING establishment_number, company, city, st, zip;

-- Restore st column with backup column
UPDATE meat_poultry_egg_establishments
SET st = st_copy;

-- Restoring Original table from Backup table
UPDATE meat_poultry_egg_establishments original
SET st = backup.st
FROM meat_poultry_egg_establishments_backup backup
WHERE original.establishment_number = backup.establishment_number;

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN company_standard text;

UPDATE meat_poultry_egg_establishments
SET company_standard = company;

UPDATE meat_poultry_egg_establishments
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%'
RETURNING company, company_standard;

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN zip_copy text;

UPDATE meat_poultry_egg_establishments
SET zip_copy = zip;

-- Concatenating '00' to those zip codes with length 3
UPDATE meat_poultry_egg_establishments
SET zip = '00' || zip
WHERE st IN('PR','VI') AND length(zip) = 3;

-- Concatenating '0' to those zip codes with length 4
UPDATE meat_poultry_egg_establishments
SET zip = '0' || zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND length(zip) = 4;

Select activities from meat_poultry_egg_establishments
where activities like '%Meat Processing%'

Alter table meat_poultry_egg_establishments
ADD COLUMN meat_processing boolean

UPDATE meat_poultry_egg_establishments
SET meat_processing = 'true'
WHERE activities like '%Meat Processing%'

SELECT meat_processing, activities
from meat_poultry_egg_establishments

-- TRANSACTIONS
CREATE TABLE state_regions (
st text CONSTRAINT st_key PRIMARY KEY,
region text NOT NULL
);

COPY state_regions
FROM '/tmp/state_regions.csv'
WITH (FORMAT CSV, HEADER);

-- Adding Column to Poultry Table
ALTER TABLE meat_poultry_egg_establishments
ADD COLUMN inspection_deadline timestamp with time zone;

-- Updating new Column
UPDATE meat_poultry_egg_establishments establishments
SET inspection_deadline = '2022-12-01 00:00 EST'
WHERE EXISTS (SELECT state_regions.region
FROM state_regions
WHERE establishments.st = state_regions.st
AND state_regions.region = 'New England');
SELECT st, inspection_deadline
FROM meat_poultry_egg_establishments
GROUP BY st, inspection_deadline
ORDER BY st;

-- Delete matching rows
DELETE FROM meat_poultry_egg_establishments
WHERE st IN('AS','GU','MP','PR','VI');

-- Delete column
ALTER TABLE meat_poultry_egg_establishments DROP COLUMN zip_copy;

DROP TABLE meat_poultry_egg_establishments_backup;

-- Create Transaction
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchantss Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

-- view changes
SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

-- Revert changes
ROLLBACK;

-- See restored state
SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

-- Alternately, commit changes at the end:
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchants Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

COMMIT;

-- Create Backup Table
CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT \*,
'2023-02-14 00:00 EST'::timestamp with time zone AS reviewed_date
FROM meat_poultry_egg_establishments;

-- Replacing Table Names
ALTER TABLE meat_poultry_egg_establishments
RENAME TO meat_poultry_egg_establishments_temp;
ALTER TABLE meat_poultry_egg_establishments_backup
RENAME TO meat_poultry_egg_establishments;
ALTER TABLE meat_poultry_egg_establishments_temp
RENAME TO meat_poultry_egg_establishments_backup;
