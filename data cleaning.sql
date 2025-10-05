-- DATA CLEANING 

SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;

-- STEPS FOR DATA CLEANING 
-- 1. REMOVING THE DUPLICATES
-- 2. STANDARDIZE THE DATA 
-- 3. NULL AND BLANK VALUES 
-- 4. REMOVING THE IRRELEVENT COLUMNS 

-- 1. REMOVING DUPLICATES 

CREATE TABLE layoffs_staging
LIKE layoffs;


INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country, funds_raised_millions) row_num
FROM layoffs_staging;


WITH DUPLICATE_CTE AS 
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country, funds_raised_millions) row_num
FROM layoffs_staging
)
SELECT *
FROM DUPLICATE_CTE
WHERE company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country, funds_raised_millions) row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

select distinct industry
from layoffs_staging2
order by 1;

select distinct country
from layoffs_staging2
order by 1;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';


SELECT *
FROM layoffs_staging2
WHERE company= 'AIRBNB';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company
WHERE (T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL; 

SELECT T1.industry, T2.industry
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company
WHERE (T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL; 


UPDATE layoffs_staging2 T1 
 JOIN layoffs_staging2 T2
	ON T1.company = T2.company
SET T1.INDUSTRY = T2.INDUSTRY
WHERE (T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


