INSERT INTO department (dept_code, dept_name, size)
VALUES
('DEV', '개발팀', 40),
('HR', '인사팀', 10),
('SALES', '영업팀', 25),
('FIN', '재무팀', 15),
('OPS', '운영팀', 20),
('QA', '품질관리팀', 10);

INSERT INTO `job_position` (position_name, base_salary) VALUES
('사원', 3000000),
('대리', 3500000),
('과장', 4200000),
('차장', 5000000),
('부장', 6000000);

INSERT INTO attendance_status (status_code, status_name)
VALUES
('NORMAL', '정상근무'),
('LATE', '지각'),
('EARLY', '조퇴'),
('ABSENT', '결근'),
('LEAVE', '휴가');

INSERT INTO work_type (work_type_code, work_type_name, start_time, end_time)
VALUES
('NORMAL', '정규근무', '09:00:00', '18:00:00'),
('REMOTE', '재택근무', '09:00:00', '18:00:00'),
('OVERTIME', '초과근무', NULL, NULL),
('OUTSIDE', '외근·출장', NULL, NULL),
('SHORT', '단축근무', '10:00:00', '16:00:00');


INSERT INTO pay_item (pay_item_code, pay_item_name, item_type, calc_type, calc_value)
VALUES
('BASE', '기본급', 'EARN', 'FIX', NULL),
('MEAL', '식대', 'EARN', 'FIX', 100000),
('TRANS', '교통비', 'EARN', 'FIX', 50000),
('OT', '연장근무수당', 'EARN', 'RATE', NULL),
('NP', '국민연금', 'DEDUCT', 'RATE', 0.045),
('HI', '건강보험', 'DEDUCT', 'RATE', 0.035),
('EI', '고용보험', 'DEDUCT', 'RATE', 0.009),
('TAX', '소득세', 'DEDUCT', 'RATE', NULL);

--
CREATE TABLE seq_120 (
    n INT PRIMARY KEY
);

INSERT INTO seq_120 (n)
SELECT a.n + b.n * 10 + 1
FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
CROSS JOIN
     (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
      UNION ALL SELECT 10 UNION ALL SELECT 11) b
LIMIT 120;



--
INSERT INTO employee (
    dept_id,
    position_id,
    email,
    name,
    tel,
    hire_date,
    status
)
SELECT
    (n % 6) + 1,
    CASE
        WHEN hire_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR) THEN 1  -- 사원
        WHEN hire_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR) THEN 2  -- 대리
        WHEN hire_date >= DATE_SUB(CURDATE(), INTERVAL 8 YEAR) THEN 3  -- 과장
        WHEN hire_date >= DATE_SUB(CURDATE(), INTERVAL 12 YEAR) THEN 4 -- 차장
        ELSE 5                                                         -- 부장
    END AS position_id,
    CONCAT('emp', n, '@company.com'),
    CONCAT('사원', LPAD(n, 3, '0')),
    CONCAT('010-1000-', LPAD(n, 4, '0')),
    hire_date,
    '재직'
FROM (
    SELECT
        n,
        DATE_SUB(CURDATE(), INTERVAL (n % 15) YEAR) AS hire_date
    FROM seq_120
) t;


--
SET @BASE_DATE := '2026-01-01';
CREATE TEMPORARY TABLE work_calendar (
    work_date DATE PRIMARY KEY
);

INSERT INTO work_calendar (work_date)
SELECT DATE_SUB(@BASE_DATE, INTERVAL n DAY)
FROM (
    SELECT @row := @row + 1 AS n
    FROM information_schema.columns, (SELECT @row := -1) r
    LIMIT 90
) t
WHERE DAYOFWEEK(DATE_SUB(@BASE_DATE, INTERVAL n DAY)) NOT IN (1,7);


--
INSERT INTO attendance_record (
    emp_id,
    work_type_id,
    status_id,
    work_date,
    check_in_time,
    check_out_time
)
SELECT
    e.emp_id,
    1 AS work_type_id,     -- DAY 근무
    1 AS status_id,        -- NORMAL
    c.work_date,
    CONCAT(c.work_date, ' 09:00:00'),
    CONCAT(c.work_date, ' 18:00:00')
FROM employee e
CROSS JOIN work_calendar c
WHERE e.hire_date <= c.work_date;

--
INSERT INTO payslip (
    emp_id,
    pay_year,
    pay_month,
    created_at
)
SELECT
    e.emp_id,
    y,
    m,
    NOW()
FROM employee e
CROSS JOIN (
    SELECT 2025 y, 1 m UNION ALL
    SELECT 2025, 2 UNION ALL
    SELECT 2025, 3
) p
WHERE e.hire_date <= LAST_DAY(CONCAT(y, '-', m, '-01'));

--
INSERT INTO payslip_item (
    payslip_id,
    pay_item_id,
    amount
)
SELECT
    p.payslip_id,
    pi.pay_item_id,
    ROUND(pos.base_salary / 30 * COUNT(a.work_date))
FROM payslip p
JOIN employee e ON p.emp_id = e.emp_id
JOIN `job_position` pos ON e.position_id = pos.position_id
JOIN attendance_record a
  ON a.emp_id = e.emp_id
 AND a.work_date BETWEEN
     STR_TO_DATE(CONCAT(p.pay_year, '-01'), '%Y-%m-%d')
 AND LAST_DAY(STR_TO_DATE(CONCAT(p.pay_year, '-01'), '%Y-%m-%d'))
JOIN pay_item pi
  ON pi.pay_item_name = '기본급'
GROUP BY
    p.payslip_id,
    pi.pay_item_id;