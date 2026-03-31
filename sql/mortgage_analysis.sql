-- =========================================
-- Mortgage Loan Analysis Project (MySQL)
-- =========================================
-- Author: Trent Edwards

USE mortgage_project;

-- =========================================
-- 1. Create Clean Table
-- =========================================

DROP TABLE IF EXISTS mortgage_loans_clean;

CREATE TABLE mortgage_loans_clean AS
SELECT *
FROM mortgage_loans_raw;


-- =========================================
-- 2. Clean Loan_Status
-- =========================================

SET SQL_SAFE_UPDATES = 0;

UPDATE mortgage_loans_clean
SET Loan_Status = LOWER(TRIM(Loan_Status));

UPDATE mortgage_loans_clean
SET Loan_Status = 'Approved'
WHERE Loan_Status = 'approved';

UPDATE mortgage_loans_clean
SET Loan_Status = 'Denied'
WHERE Loan_Status = 'denied';

UPDATE mortgage_loans_clean
SET Loan_Status = 'Pending'
WHERE Loan_Status = 'pending';

SET SQL_SAFE_UPDATES = 1;


-- =========================================
-- 3. Clean Employment_Status
-- =========================================

SET SQL_SAFE_UPDATES = 0;

UPDATE mortgage_loans_clean
SET Employment_Status = LOWER(TRIM(Employment_Status));

UPDATE mortgage_loans_clean
SET Employment_Status = 'Full-Time'
WHERE Employment_Status IN ('full time', 'full-time');

UPDATE mortgage_loans_clean
SET Employment_Status = 'Part-Time'
WHERE Employment_Status IN ('part time', 'part-time');

UPDATE mortgage_loans_clean
SET Employment_Status = 'Self-Employed'
WHERE Employment_Status IN ('self employed', 'self-employed');

SET SQL_SAFE_UPDATES = 1;


-- =========================================
-- 4. Clean State
-- =========================================

SET SQL_SAFE_UPDATES = 0;

UPDATE mortgage_loans_clean
SET State = UPPER(TRIM(State));

UPDATE mortgage_loans_clean SET State = 'CA' WHERE State = 'CALIFORNIA';
UPDATE mortgage_loans_clean SET State = 'FL' WHERE State = 'FLORIDA';
UPDATE mortgage_loans_clean SET State = 'GA' WHERE State = 'GEORGIA';
UPDATE mortgage_loans_clean SET State = 'TX' WHERE State = 'TEXAS';
UPDATE mortgage_loans_clean SET State = 'WA' WHERE State = 'WASHINGTON';
UPDATE mortgage_loans_clean SET State = 'NY' WHERE State = 'NEW YORK';
UPDATE mortgage_loans_clean SET State = 'IL' WHERE State = 'ILLINOIS';
UPDATE mortgage_loans_clean SET State = 'OH' WHERE State = 'OHIO';
UPDATE mortgage_loans_clean SET State = 'AZ' WHERE State = 'ARIZONA';
UPDATE mortgage_loans_clean SET State = 'PA' WHERE State = 'PENNSYLVANIA';

SET SQL_SAFE_UPDATES = 1;


-- =========================================
-- 5. Analysis Queries
-- =========================================

-- Loan Status Distribution
SELECT
    Loan_Status,
    COUNT(*) AS loan_count
FROM
    mortgage_loans_clean
GROUP BY
    Loan_Status
ORDER BY
    Loan_Status;

-- Total Loans by State
SELECT
    State,
    COUNT(*) AS total_loans
FROM
    mortgage_loans_clean
GROUP BY
    State
ORDER BY
    total_loans DESC;

-- Average Loan Amount by State
SELECT
    State,
    ROUND(AVG(Loan_Amount), 2) AS avg_loan_amount
FROM
    mortgage_loans_clean
GROUP BY
    State
ORDER BY
    avg_loan_amount DESC;

-- Approval Rate by State
SELECT
    State,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN Loan_Status = 'Approved' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*) * 100.0,
        2
    ) AS approval_rate_pct
FROM
    mortgage_loans_clean
GROUP BY
    State
ORDER BY
    approval_rate_pct DESC;


-- =========================================
-- 6. Insight Queries
-- =========================================

-- Loan size vs approval rate
SELECT
    State,
    ROUND(AVG(Loan_Amount), 0) AS avg_loan_amount,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*) * 100.0,
        2
    ) AS approval_rate_pct
FROM
    mortgage_loans_clean
GROUP BY
    State
ORDER BY
    avg_loan_amount DESC;

-- Loan amount band analysis
SELECT
    CASE
        WHEN Loan_Amount < 250000 THEN 'Under 250K'
        WHEN Loan_Amount < 400000 THEN '250K-399K'
        WHEN Loan_Amount < 550000 THEN '400K-549K'
        ELSE '550K+'
    END AS loan_amount_band,
    COUNT(*) AS total_loans,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*) * 100.0,
        2
    ) AS approval_rate_pct
FROM
    mortgage_loans_clean
GROUP BY
    loan_amount_band
ORDER BY
    approval_rate_pct DESC;


-- =========================================
-- 7. Tableau View
-- =========================================

CREATE OR REPLACE VIEW vw_state_loan_insights AS
SELECT
    State,
    COUNT(*) AS total_loans,
    ROUND(AVG(Loan_Amount), 0) AS avg_loan_amount,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*) * 100.0,
        2
    ) AS approval_rate_pct
FROM
    mortgage_loans_clean
GROUP BY
    State;
