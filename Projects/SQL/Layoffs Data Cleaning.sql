-- Data taken from:-  https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- DATA CLEANING in SQL by Zelalem B. Bogale

-- Retrieve all records from the raw layoffs data.
SELECT * 
FROM world_layoffs.layoffs;



-- Create a staging table to preserve the original data while allowing data cleaning and transformations.
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- Populate the staging table with a copy of the raw data.
INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;


-- Data cleaning process typically involves:
-- 1. Identifying and removing duplicate records.
-- 2. Standardizing data and correcting errors.
-- 3. Handling null values appropriately.
-- 4. Removing unnecessary columns or rows for efficient analysis.




-- Step 1: Check for duplicates in the dataset.


-- Display all records from the staging table for reference.
SELECT *
FROM world_layoffs.layoffs_staging
;

-- Identify potential duplicates by assigning a row number to each record based on key columns.
SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		world_layoffs.layoffs_staging;


-- Extract only the duplicate records by filtering rows with row numbers greater than one.
SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
-- Verify specific examples of potential duplicates to ensure data integrity.
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda'
;
 
-- Perform a more granular duplicate check using additional columns for accuracy.
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;


-- Remove duplicate records by filtering rows with row numbers greater than one.


-- Create a common table expression (CTE) to identify duplicates for deletion.
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE
;


WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;


-- An alternative approach: Add a row number column, delete duplicates, and then remove the column.


-- Add a new column to the staging table for row numbers.
ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;

-- Verify the table structure after adding the new column.
SELECT *
FROM world_layoffs.layoffs_staging
;


-- Create a new table with the updated structure including the row number column.
CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
`row_num` INT
);



-- Populate the new staging table with data and assign row numbers for duplicate identification.
INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;


-- Delete duplicate rows based on row numbers greater than or equal to 2.
DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;





-- Step 2: Standardize data and address inconsistencies.


-- Retrieve all records from the updated staging table for review.
SELECT * 
FROM world_layoffs.layoffs_staging2;

-- Identify unique values in the "industry" column to spot inconsistencies.
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


-- Identify rows where the "industry" column is null or blank for further inspection.
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Review records with specific company names for validation.
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';


-- Replace empty strings in the "industry" column with NULL values for consistency.
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- Populate null values in the "industry" column by referencing other rows with the same company name.
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- ---------------------------------------------------

-- Crypto has multiple different variations, which need to be standardized.
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


-- Standardize variations of "Crypto" into a single term.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- --------------------------------------------------

-- Identify and resolve inconsistencies in the "country" column, such as trailing periods.
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

-- Remove trailing periods from values in the "country" column.
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- Standardize the format of the "date" column using the STR_TO_DATE function.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Convert the "date" column to the appropriate DATE data type.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;




-- Step 3: Handle null values appropriately for analysis.


-- Review rows with null values in critical columns such as "total_laid_off" and "percentage_laid_off."
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;

-- Identify rows where both "total_laid_off" and "percentage_laid_off" are null.
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove rows with null values in critical columns that cannot be used for analysis.
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- Step 4: Remove unnecessary columns for a cleaner dataset.

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- Drop the "row_num" column after cleaning duplicates.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- Final review of the cleaned data.
SELECT * 
FROM world_layoffs.layoffs_staging2;