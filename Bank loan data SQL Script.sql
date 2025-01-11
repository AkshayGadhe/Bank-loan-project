SELECT * FROM LOAN;

-- CALCULATE ALL COUNT OF APPLICATIONS (38576)
SELECT COUNT(*) 
FROM loan;

-- ADD DUPLICATE COLUMN FOR CONVERTING ISSUE DATE COLUMN IN PROPER FORMAT
ALTER TABLE loan
ADD COLUMN con_issue_date DATE;

-- CONVERTING ISSUE_DATE COLUMN IN PROPER DATE FORMAT
UPDATE loan 
SET con_issue_date = 
    CASE
        WHEN issue_date LIKE '__/__/____' THEN STR_TO_DATE(issue_date, '%d/%m/%Y')
        WHEN issue_date LIKE '__-__-____' THEN STR_TO_DATE(issue_date, '%d-%m-%Y')
        WHEN issue_date LIKE '____-__-__' THEN STR_TO_DATE(issue_date, '%Y-%m-%d')
        ELSE NULL
    END;

-- DROP THE ORIGINAL COLUMN
ALTER TABLE loan
DROP COLUMN issue_date;

-- RENAME DUPLICATE COLUMN AS ORIGINAL
ALTER TABLE LOAN
CHANGE COLUMN con_issue_date issue_date DATE;

-- THESE ABOVE STEPS ARE DONE FOR EVERY DATE COLUMN
-- CONVERTING LAST-CREDIT_PULL_DATE COLUMN IN PROPER DATE FORMAT 
ALTER TABLE loan
ADD COLUMN con_last_credit_pull_date DATE;

UPDATE loan 
SET 
    con_last_credit_pull_date = CASE
        WHEN last_credit_pull_date LIKE '__/__/____' THEN STR_TO_DATE(last_credit_pull_date, '%d/%m/%Y')
        WHEN last_credit_pull_date LIKE '__-__-____' THEN STR_TO_DATE(last_credit_pull_date, '%d-%m-%Y')
        WHEN last_credit_pull_date LIKE '____-__-__' THEN STR_TO_DATE(last_credit_pull_date, '%Y-%m-%d')
        ELSE NULL
    END;

ALTER TABLE loan
DROP COLUMN last_credit_pull_date;

ALTER TABLE loan
CHANGE COLUMN con_last_credit_pull_date last_credit_pull_date DATE;

-- CONVERTING LAST-PAYMENT_DATE COLUMN IN PROPER DATE FORMAT
ALTER TABLE loan
ADD COLUMN con_last_payment_date DATE;

UPDATE loan 
SET 
    con_last_payment_date = CASE
        WHEN last_payment_date LIKE '__/__/____' THEN STR_TO_DATE(last_payment_date, '%d/%m/%Y')
        WHEN last_payment_date LIKE '__-__-____' THEN STR_TO_DATE(last_payment_date, '%d-%m-%Y')
        WHEN last_payment_date LIKE '____-__-__' THEN STR_TO_DATE(last_payment_date, '%Y-%m%-%d')
        ELSE NULL
    END;

ALTER TABLE loan
DROP COLUMN last_payment_date;

ALTER TABLE loan
CHANGE COLUMN con_last_payment_date last_payment_date DATE;

-- CONVERTING NEXT-PAYMENT_DATE COLUMN IN PROPER DATE FORMAT
ALTER TABLE loan
ADD COLUMN con_next_payment_date DATE;

UPDATE loan 
SET 
    con_next_payment_date = CASE
        WHEN next_payment_date LIKE '__/__/____' THEN STR_TO_DATE(next_payment_date, '%d/%m/%Y')
        WHEN next_payment_date LIKE '__-__-____' THEN STR_TO_DATE(next_payment_date, '%d-%m-%Y')
        WHEN next_payment_date LIKE '____-__-__' THEN STR_TO_DATE(next_payment_date, '%Y-%m-%d')
        ELSE NULL
    END;

ALTER TABLE loan
DROP COLUMN next_payment_date;

ALTER TABLE loan
CHANGE COLUMN con_next_payment_date next_payment_date DATE;

-- CALCULATE MTD TOTAL LOAN APPLICATIONS (4314)
SELECT COUNT(*) AS mtd_toal_applcatons
FROM loan
WHERE MONTH(issue_date) = 12
AND YEAR(issue_date) = 2021;

-- CALCULATE PMTD TOTAL LOAN APPLICATIONS (4035)
SELECT COUNT(*) AS pmtd_total_applicatios
FROM loan
WHERE MONTH(issue_date) = 11
AND YEAR(issue_date) = 2021;

-- CALCULATE MONTHLY CUSTOMERS
select monthname(issue_date)as month,COUNT(*) as monthly_customers from loan
group by month
order by monthly_customers desc;

-- COUNT AND PERCENTAGE APPLICATION RECEIVED MOM (6.9145%)
WITH mtd AS 
(SELECT count(*) AS mtd_toal_applcatons 
FROM loan 
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021),
pmtd AS 
(SELECT count(*) AS pmtd_toal_applcatons 
FROM loan 
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021)
SELECT((mtd.mtd_toal_applcatons-pmtd.pmtd_toal_applcatons)/pmtd.pmtd_toal_applcatons*100) AS mom_percent
FROM mtd,pmtd;

-- calculate mom applications in another way
SELECT COUNT(CASE WHEN MONTH(issue_date) = 12 AND YEAR(issue_date) THEN id END) AS mtd,COUNT(CASE WHEN MONTH(issue_date) = 11 AND YEAR(issue_date)THEN id END) AS pmtd,
(COUNT(CASE WHEN MONTH(issue_date) = 12 AND YEAR(issue_date) THEN id END) - COUNT(CASE WHEN MONTH(issue_date) = 11 AND YEAR(issue_date) THEN id END)) / 
COUNT(CASE WHEN MONTH(issue_date) = 11 AND YEAR(issue_date) THEN id END) * 100 AS mom
FROM loan data;

-- TOTAL FUNDED AMOUNT 435757075
SELECT SUM(loan_amount)
FROM loan;

--  CALCULATE MONTHLY LOAN AMOUNT FOR EACH MONTH
SELECT MONTHNAME(issue_date) AS month,SUM(loan_amount) AS monthly_disbursed_amount
FROM loan
GROUP BY month ORDER BY monthly_disbursed_amount DESC;

-- TOTAL FUNDED AMOUNT IN 'MTD' (DEC) 53981425
SELECT SUM(loan_amount) AS loan_amount_mtd
FROM loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- TOTAL FUNDED AMOUNT IN PMTD (NOV) 47754825
SELECT SUM(loan_amount) AS loan_amount_pmtd
FROM loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021;

-- CALCULATE THE MONTH-OVER-MONTH (MOM) DIFFERENCE FOR LOAN_AMOUNT 
SELECT MONTHNAME(issue_date) AS month,
SUM(loan_amount) AS monthly_disbursed_amount,
LAG(SUM(loan_amount)) OVER (ORDER BY MIN(issue_date)) AS prev_month_disbursed_amount,
ROUND((SUM(loan_amount) - LAG(SUM(loan_amount)) OVER (ORDER BY MIN(issue_date))) / LAG(SUM(loan_amount)) OVER (ORDER BY MIN(issue_date)) * 100, 2) AS mom_percentage
FROM loan
GROUP BY month
ORDER BY monthly_disbursed_amount DESC;

-- TOTAL MOM TOTAL LOAN AMOUNT (13.04%) 
WITH mtd AS 
(SELECT SUM(loan_amount) AS mtd_loan_amount FROM loan WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021),
pmtd AS 
(SELECT sum(loan_amount) AS pmtd_loan_amount FROM loan WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021)
SELECT ROUND(((mtd.mtd_loan_amount-pmtd.pmtd_loan_amount)/pmtd.pmtd_loan_amount*100),2)AS mom_loan_amount
FROM mtd,pmtd;

-- CALCULATE TOTAL AMOUNT RECEIVED (473070933)
SELECT SUM(total_payment)
FROM loan;

-- CALCULATE MTD TOTAL AMOUNT RECEIVED (58074380)
SELECT SUM(total_payment)
FROM loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- CALCULATE PMTD TOTAL AMOUNT RECEIVED (50132030)
SELECT SUM(total_payment)
FROM loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021;

-- CALCULATE MONTH OVER MONTH OF TOTAL PAYMENT (15.8429%)
WITH mtd_payment AS 
(SELECT sum(total_payment) AS mtd_total_payment 
FROM loan 
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021),
pmtd_payment AS 
(SELECT sum(total_payment) AS pmtd_total_payment 
FROM loan 
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021)
SELECT (mtd_payment.mtd_total_payment-pmtd_payment.pmtd_total_payment)/pmtd_payment.pmtd_total_payment*100 as mom_total_payment 
FROM mtd_payment,pmtd_payment;

-- CALCULATE AVG INTREST RATE (12.05)
SELECT ROUND(AVG(int_rate) * 100, 2) AS avarage_intrest_rate
FROM loan;

-- CALCULTE MTD AVG INTEREST RATE (12.36)
SELECT ROUND(AVG(int_rate) * 100, 2) AS mtd_int_rate
FROM loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- CALCULTE PMTD AVG INTEREST RATE (11.94)
SELECT ROUND(AVG(int_rate) * 100, 2) AS pmtd_int_rate
FROM loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021;

-- CALCULATE MOM AVG INTEREST RATE (3.52)
WITH mtd AS
(SELECT round(AVG(int_rate)*100,2) AS mtd_int_rate FROM loan WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021),
pmtd AS 
(SELECT round(AVG(int_rate)*100,2) AS pmtd_int_rate FROM loan WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021)
SELECT 
ROUND((mtd.mtd_int_rate-pmtd.pmtd_int_rate)/pmtd.pmtd_int_rate*100,2) AS mom_avg_int_rate 
FROM mtd,pmtd;

-- CALCULATE AVRAGE DEBT TO INCOME (DTI) (13.33)
SELECT ROUND(AVG(dti) * 100, 2) AS avg_dti
FROM loan;

                               
							-- GOOD LOAN AND BAD LOAN KPIS -----
                            
-- CALCULATE THE GOOD LOAN COUNT (33243)
SELECT COUNT(*)
FROM loan
WHERE loan_status IN ('Fully paid' , 'Current');

-- CALCULATE PERCENT OF GOOD LOAN (86.18)
SELECT ROUND(COUNT(CASE
        WHEN loan_status = 'Fully paid'OR loan_status = 'Current' THEN id END) * 100 / COUNT(*),2) AS paid_percentage
FROM loan;

-- ANOTHER WAY TO SOLVE THIS QUESTION
WITH cte AS (SELECT COUNT(*) FROM loan WHERE loan_status IN ('Fully paid','Current')),
cte2 AS (SELECT COUNT(*) AS all_count FROM loan)
SELECT (cte.count/cte2.all_count)*100 AS percent FROM cte,cte2;

-- CALCULATING THE GOOD LOAN FUNDING AMOUNT AND RECEIVED AMOUNT
SELECT SUM(loan_amount) AS funded, SUM(total_payment) AS received
FROM loan
WHERE loan_status IN ('Fully paid' , 'Current');

-- CALCUALTE THE PROFIT BY SUBTRACTING LOAN AMOUNT FROM TOTAL PAYMNET RECEIVED
SELECT SUM(total_payment - loan_amount) AS profit
FROM loan
WHERE loan_status IN ('Fully paid' , 'Current');

-- CALULATE EACH MONTHS PROFIT FROM GOOD CUSTOMERS 
SELECT MONTHNAME(issue_date) AS month, SUM(total_payment - loan_amount) AS monthly_profit
FROM loan
WHERE loan_status IN ('Fully paid' , 'Current')
GROUP BY month
ORDER BY monthly_profit;

-- CALCULATING MONTH-TO-DATE GOOD LOAN FUNDING AMOUNT AND RECEIVED AMOUNT
SELECT SUM(loan_amount) AS funded, SUM(total_payment) AS received
FROM loan
WHERE loan_status IN ('Fully paid' , 'Current') AND MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- CALCULATE PROFIT FOR MTD 7501519
SELECT sum(total_payment-loan_amount) as mtd_profit
FROM loan 
WHERE 
loan_status in ('Fully paid','Current')
AND MONTH(issue_date) = 12 
AND YEAR(issue_date) = 2021;

-- CALCULATING MTD GOOD LOAN FUNDING AMOUNT AND RECEIVED AMOUNT 
SELECT SUM(loan_amount) AS funding, SUM(total_payment) AS Received
FROM loan
WHERE loan_status IN ('Fully paid' , 'Current') AND MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021;

-- CALCULATING PROFIT FOR PMTD 5894315
SELECT SUM(total_payment - loan_amount) AS pmtd_profit
FROM loan
WHERE loan_status IN ('Fully paid' , 'Current') AND MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021;

-- CALCULATE MONTH OVER MONTH PROFIT (27.26)
WITH cte AS 
(SELECT sum(total_payment-loan_amount) AS mtd_profit FROM loan WHERE loan_status IN ('Fully paid','Current') AND MONTH(issue_date)=12 AND YEAR(issue_date)=2021),
cte2 AS 
(SELECT sum(total_payment-loan_amount) AS pmtd_profit FROM loan WHERE loan_status IN ('Fully paid','Current') AND MONTH(issue_date)=11 AND YEAR(issue_date)=2021)
SELECT ((cte.mtd_profit-cte2.pmtd_profit)/cte2.pmtd_profit)*100 AS mom_profit FROM cte,cte2;

-- EVALUATION FOR BAD LOAN CUSTOMERS
-- CALCULATE BAD LOAN CUSTMERS COUNT
SELECT COUNT(*) AS fraud
FROM loan
WHERE loan_status = 'Charged off';

-- CALCULATE PERCENTAGE OF FRAUD CUSTOMERS (13.82%)
SELECT CONCAT(ROUND(COUNT(CASE WHEN loan_status = 'Charged off' THEN id END) * 100 / COUNT(*),2),'%') AS fraud_percentage
FROM loan;

-- CALCULATE TOTAL LOAN AMOUNT AND RECEIVED AMOUNT FROM DEFAULT CUSTOMERS
SELECT SUM(loan_amount) AS default_amount,SUM(total_payment) AS recover_amount
FROM loan
WHERE loan_status = 'Charged off';

-- CALCULATE DIFFERENCE BET LOAN AMOUNT AND RECEIVED AMOUNT FORM DEFAULT CUSTOMERS
SELECT SUM(total_payment - loan_amount) AS LOSS
FROM loan
WHERE loan_status = 'Charged off';


-- CALCULATE MONTHLY LOSS FORM DEFAULT CUSTOMERS
SELECT MONTHNAME(ISSUE_DATE) AS month,SUM(total_payment - loan_amount) AS monthly_loss
FROM loan
WHERE loan_status = 'Charged off'
GROUP BY month
ORDER BY monthly_loss;

SELECT MONTHNAME(issue_date) AS month,((SUM(loan_amount)-sum(total_payment))/sum(loan_amount))*100 AS recovery_pending_percentage
FROM loan
WHERE loan_status = 'Charged off'
GROUP BY month
ORDER BY recovery_pending_percentage desc;

-- CALCULATE MTD COUNT OF DEFAULER CUSTOMERS 649
SELECT COUNT(*) AS mtd_fraud_count
FROM loan
WHERE loan_status = 'Charged off' AND MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- CALCULATE PMTD COUNT OF DEFAULTER CUSTOMERS 561
SELECT COUNT(*) AS pmtd_fraud_count
FROM loan
WHERE loan_status = 'Charged off' AND MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021;


-- CALCULATE DEFAULER CUSTMERS ON THE BASIS OF PURPOSE OF LOAN
SELECT purpose, COUNT(*) AS count
FROM loan
WHERE loan_status = 'Charged off'
GROUP BY purpose
ORDER BY count DESC;

-- CALCULATE LOAN_AMOUNT AND RECOVERY AMOUNT BY PURPOSE BY THE DEFAULTER CUSTOMERS
SELECT purpose,SUM(loan_amount) AS loan_disbursed,SUM(total_payment) Loan_recover,SUM(loan_amount) - SUM(total_payment) AS outstanding
FROM loan
WHERE loan_status = 'Charged off'
GROUP BY purpose
ORDER BY outstanding DESC;

-- CALCULATE LOAN RECOVERY PERCENTAGE FOR EACH PURPOSE
SELECT purpose,SUM(loan_amount) AS loan_disbursed,SUM(total_payment) Loan_recover,((SUM(loan_amount) - SUM(total_payment)) / SUM(loan_amount)) * 100 AS percent_recovery
FROM loan
WHERE loan_status = 'Charged off'
GROUP BY purpose
ORDER BY percent_recovery DESC;

-- CALCULATE THE DEFAULTER CUSTOMERS IN EACH STATE
SELECT address_state, COUNT(*) AS count
FROM loan
WHERE loan_status = 'Charged off'
GROUP BY address_state
ORDER BY count DESC;

-- CALCULATING THE LOAN APPLICATION COUNT,TOTAL AMOUNT RECEIVED ,TOTAL AMOUNT FUNDED,INTEREST RATE AND DTI ON THE BASIS OF LOAN STATUS
SELECT loan_status,COUNT(*) AS count,SUM(total_payment) AS total_received_amount,
SUM(loan_amount) total_borrowed_amount,ROUND(AVG(int_rate) * 100, 2) AS interrest_rest,ROUND(AVG(dti) * 100, 2) AS DTI
FROM loan
GROUP BY loan_status;



-- BANK LOAN APPLIATION ON THE BASIS OF TERM
SELECT 
    term,
    COUNT(*) AS count,
    SUM(total_payment) AS total_received_amount,
    SUM(loan_amount) total_borrowed_amount,
    ROUND(AVG(int_rate) * 100, 2) AS interrest_rest,
    ROUND(AVG(dti) * 100, 2) AS DTI
FROM loan
GROUP BY term;

-- BANK LOAN APPLIATION ON THE BASIS OF EMP_LENGTH
SELECT 
    emp_length,
    COUNT(*) AS count,
    SUM(total_payment) AS total_received_amount,
    SUM(loan_amount) total_borrowed_amount,
    ROUND(AVG(int_rate) * 100, 2) AS interrest_rest,
    ROUND(AVG(dti) * 100, 2) AS DTI
FROM loan
GROUP BY emp_length;

-- BANK LOAN APPLIATION ON THE BASIS OF HOME OWNERSHIP
SELECT 
    home_ownership,
    COUNT(*) AS count,
    SUM(total_payment) AS total_received_amount,
    SUM(loan_amount) total_borrowed_amount,
    ROUND(AVG(int_rate) * 100, 2) AS interrest_rest,
    ROUND(AVG(dti) * 100, 2) AS DTI
FROM loan
GROUP BY home_ownership;