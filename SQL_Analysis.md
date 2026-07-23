# SQL Analysis — HR Attrition

Database: `hr_project.hr_data` (1,470 rows), MySQL Workbench

---

## Q1: Which departments have the highest attrition?

```sql
SELECT Department,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_data
GROUP BY Department
ORDER BY attrition_rate_pct DESC;
```

| Department | Attrition Rate % |
|---|---|
| Sales | 20.63 |
| Human Resources | 19.05 |
| Research & Development | 13.84 |

**Insight:** Sales and HR have the highest attrition, both above the company average.

---

## Q2: Does salary affect attrition?

```sql
SELECT Attrition, ROUND(AVG(MonthlyIncome), 2) AS avg_monthly_income
FROM hr_data
GROUP BY Attrition;
```

| Attrition | Avg Monthly Income |
|---|---|
| Yes | 4787.09 |
| No | 6832.74 |

**Insight:** Employees who left earned ~30% less on average.

---

## Q3: Does overtime increase turnover?

```sql
SELECT OverTime,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_data
GROUP BY OverTime;
```

| OverTime | Attrition Rate % |
|---|---|
| Yes | 30.53 |
| No | 10.44 |

**Insight:** Overtime workers have nearly 3x higher attrition.

---

## Q4: Which age groups leave most often?

```sql
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
```

| Age Group | Attrition Rate % |
|---|---|
| 18-25 | 35.77 |
| 26-35 | 19.14 |
| 36-45 | 9.19 |
| 46-55 | 11.50 |
| 56-65 | 17.02 |

**Insight:** 18-25 has by far the highest attrition, dropping sharply with age.

---

## Bonus: Departments above average attrition (CTE + Subquery)

```sql
WITH dept_attrition AS (
    SELECT Department,
           ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
    FROM hr_data
    GROUP BY Department
)
SELECT *
FROM dept_attrition
WHERE attrition_rate > (SELECT AVG(attrition_rate) FROM dept_attrition);
```

| Department | Attrition Rate % |
|---|---|
| Sales | 20.63 |
| Human Resources | 19.05 |

**Insight:** Demonstrates use of a CTE combined with a correlated subquery to dynamically filter against a computed average.

---

## Bonus: Income ranking within department (Window Function)

```sql
SELECT
    Department,
    JobRole,
    MonthlyIncome,
    RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS income_rank_in_dept
FROM hr_data
ORDER BY Department, income_rank_in_dept
LIMIT 15;
```

**Insight:** Uses `RANK() OVER (PARTITION BY ...)` to rank employees by income within their own department — a common real-world window function pattern.
