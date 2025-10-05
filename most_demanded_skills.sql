/* This SQL query retrieves the top 10 most demanded skills in the Indian job market.*/



SELECT skills,COUNT(skills_job_dim.job_id) as demand_count
FROM indian_job_market
INNER JOIN skills_job_dim ON indian_job_market.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 10;

/* This SQL query retrieves the top 10 most demanded skills specifically for the job title 'Data Analyst' in the Indian job market.*/   

SELECT skills,COUNT(skills_job_dim.job_id) as demand_count
FROM indian_job_market
INNER JOIN skills_job_dim ON indian_job_market.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst'
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 10;


