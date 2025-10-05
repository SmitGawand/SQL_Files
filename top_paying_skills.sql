/* This SQL query retrieves the top paying skills in the Indian job market, including job title, company name, location, schedule type, average salary, posting date, and work from home option.
*/



WITH top_paying_jobs AS (
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
)
SELECT top_paying_jobs.*,skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER by salary_year_avg DESC


