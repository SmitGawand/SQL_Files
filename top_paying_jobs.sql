/* This SQL query retrieves the top paying jobs in the Indian job market, including job title, company name, location, schedule type, average salary, posting date, and work from home option.
*/


SELECT 
    job_id,
    job_title,
    name as company_name,
    job_location,
    job_schedule_type,     
    salary_year_avg,
    job_posted_date::date,
    job_work_from_home
FROM indian_job_market
LEFT JOIN company_dim ON company_dim.company_id = indian_job_market.company_id
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC


/*
Highest paying roles likely include titles like "Machine Learning Engineer", "Data Scientist", "AI Researcher", etc.
*/