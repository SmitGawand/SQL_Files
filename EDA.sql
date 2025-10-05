-- EXPLORATORY DATA ANALYSIS


SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY 4 DESC;

SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT industry,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT substring(`DATE`,1,7) `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`DATE`,1,7) IS NOT NULL
GROUP BY `MONTH` 
ORDER BY 1;

WITH Rolling_Total_CTE AS
( SELECT substring(`DATE`,1,7) `MONTH`,  country, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`DATE`,1,7) IS NOT NULL
GROUP BY `MONTH`, country 
ORDER BY 1
)
SELECT `MONTH`, country , total_off,SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_Total
FROM Rolling_Total_CTE;


SELECT company, YEAR(`DATE`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`DATE`)
ORDER BY 3 DESC;


WITH Company_Year(Company,Years, Total_Laid_Off)AS 
(SELECT company, YEAR(`DATE`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`DATE`)
), Company_Rank_Year AS
(
SELECT *,  DENSE_RANK() OVER (PARTITION BY Years ORDER BY Total_Laid_Off DESC) As Ranking 
FROM Company_Year
WHERE Years IS NOT NULL
ORDER BY 4
)
SELECT * 
FROM Company_Rank_Year
WHERE Ranking <=5
ORDER BY Years;

