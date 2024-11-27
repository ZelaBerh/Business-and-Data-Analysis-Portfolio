-- Data taken from:-  https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- EXPLORATORY DATA ANALYSIS in SQL by Zelalem B. Bogale

-- I have explored and analysed the dataset to identify trends, patterns, anomalies, outliers and other interesting insights.

SELECT 
    *
FROM
    world_layoffs.layoffs_staging2;


-- Identify the maximum number of employees laid off in a single record.
SELECT 
    MAX(total_laid_off)
FROM
    world_layoffs.layoffs_staging2;


-- Analyze Layoff Percentages
SELECT 
    MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM
    world_layoffs.layoffs_staging2
WHERE
    percentage_laid_off IS NOT NULL;

-- Identify companies that laid off 100% of their workforce (percentage_laid_off = 1).
SELECT 
    *
FROM
    world_layoffs.layoffs_staging2
WHERE
    percentage_laid_off = 1;
-- Observations: These are predominantly startups that went out of business during the analysis period.

SELECT 
    *
FROM
    world_layoffs.layoffs_staging2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt appears to be an EV company had been impacted the most; 
-- Quibi, despite raising nearly $2 billion, also went under.



SELECT 
    company, total_laid_off
FROM
    world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;
-- Note: This query focuses on layoffs reported in a single event or record.

SELECT 
    company, SUM(total_laid_off)
FROM
    world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;


-- Analyze layoffs by location.
SELECT 
    location, SUM(total_laid_off)
FROM
    world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;


-- Assess layoffs by country over the dataset's entire timespan.
SELECT 
    country, SUM(total_laid_off)
FROM
    world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- View annual trends in layoffs by year.
SELECT 
    YEAR(date), SUM(total_laid_off)
FROM
    world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;


-- Analyze layoffs by industry.
SELECT 
    industry, SUM(total_laid_off)
FROM
    world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


-- Analyze layoffs by funding stage of the companies.
SELECT 
    stage, SUM(total_laid_off)
FROM
    world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;




-- Advanced Analysis: Yearly Trends and Rolling Totals

-- Identify top 3 companies with the highest layoffs for each year.
WITH Company_Year AS 
(
  SELECT 
	   company, 
       YEAR(date) AS years, 
       SUM(total_laid_off) AS total_laid_off
  FROM 
	   layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT 
	   company, years, total_laid_off, 
       DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM 
	   Company_Year
)
SELECT 
	   company, years, total_laid_off, ranking
FROM 
	   Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;



-- Compute a rolling total of layoffs by month.
SELECT 
    SUBSTRING(date, 1, 7) AS dates,
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;


-- Use a Common Table Expression (CTE) to calculate cumulative layoffs over time.
WITH DATE_CTE AS 
(
SELECT 
	SUBSTRING(date,1,7) as dates, 
    SUM(total_laid_off) AS total_laid_off
FROM 
	layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT 
	dates, 
    SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM 
	DATE_CTE
ORDER BY dates ASC;