-- ============================================================
-- HR Analytics — Employee Attrition SQL Analysis
-- Database: hr_project | Table: hr_data (1470 rows)
-- ============================================================

-- Q1: Which departments have the highest attrition?
SELECT Department,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_data
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- Q2: Does salary affect attrition?
SELECT Attrition, ROUND(AVG(MonthlyIncome), 2) AS avg_monthly_income
FROM hr_data
GROUP BY Attrition;

-- Q3: Does overtime increase employee turnover?
SELECT OverTime,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_data
GROUP BY OverTime;

-- Q4: Which age groups leave most often?
SELECT
  CASE
    WHEN Age BETWEEN 18 AND 25 THEN '18-25'
    WHEN Age BETWEEN 26 AND 35 THEN '26-35'
    WHEN Age BETWEEN 36 AND 45 THEN '36-45'
    WHEN Age BETWEEN 46 AND 55 THEN '46-55'
    ELSE '56-65'
  END AS age_group,
  ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_data
GROUP BY age_group
ORDER BY age_group;

-- Bonus (shows advanced SQL — CTE + subquery):
-- Departments with above-average attrition
WITH dept_attrition AS (
    SELECT Department,
           ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
    FROM hr_data
    GROUP BY Department
)
SELECT *
FROM dept_attrition
WHERE attrition_rate > (SELECT AVG(attrition_rate) FROM dept_attrition);
SELECT
    Department,
    JobRole,
    MonthlyIncome,
    RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS income_rank_in_dept
FROM hr_data
ORDER BY Department, income_rank_in_dept
LIMIT 15;