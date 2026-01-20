-- ==============================================================
-- 근무유형 기준관리
-- ==============================================================
-- 근무유형 등록 (요구사항 코드 : WORK_TYPE_001)
INSERT INTO work_type (work_type_code, work_type_name, start_time, end_time, use_yn)
VALUES
('REG_0900_1800', '정규근무(09:00-18:00)', '09:00:00', '18:00:00', 'Y'),
('REMOTE', '재택근무(09:00-18:00)', '09:00:00', '18:00:00', 'Y'),
('BIZ_TRIP', '외근/출장(09:00-18:00)', '09:00:00', '18:00:00', 'Y'),
('SHORT', '단축근무', NULL, NULL, 'Y');

SELECT * FROM work_type;

-- 근무유형 수정 (요구사항 코드 : WORK_TYPE_002)
-- work_type_id=1 근유형명 수정 예시
UPDATE work_type
SET work_type_name = '정규근무(09:00-18:00)_수정',
    updated_at = NOW()
WHERE work_type_id = 1;

SELECT * FROM work_type WHERE work_type_id = 1;

-- 근무유형 활성/비활성 (요구사항 코드 : WORK_TYPE_003)
UPDATE work_type
SET use_yn = 'N',
    updated_at = NOW()
WHERE work_type_id = 4; -- 예: SHORT 비활성

SELECT * FROM work_type WHERE work_type_id = 4;

-- 근무유형 조회 (요구사항 코드 : WORK_TYPE_004)
-- 비활성 포함 전체 조회
SELECT
    work_type_id, work_type_code, work_type_name, start_time, end_time, use_yn, created_at, updated_at
FROM work_type;



-- 근태상태코드 등록 (요구사항 코드: WORK_CON_001)
INSERT INTO attendance_status (status_code, status_name, use_yn)
VALUES
('NORMAL', '정상', 'Y'),
('LATE',   '지각', 'Y'),
('EARLY',  '조퇴', 'Y'),
('ABSENT', '결석', 'Y'),
('LEAVE',  '휴가', 'Y');



-- 근태상태코드 수정 (요구사항 코드 : WORK_CON_002)
DELIMITER $$
CREATE PROCEDURE attendance_status_name_update (
    IN p_status_code VARCHAR(30),
    IN p_status_name VARCHAR(100)
)
BEGIN
    UPDATE attendance_status
    SET status_name = p_status_name,
        updated_at = CURRENT_TIMESTAMP
    WHERE status_code = p_status_code;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '근태 상태코드 수정 실패: 대상 상태코드를 찾을 수 없습니다.';
    END IF;
END$$
DELIMITER ;

CALL attendance_status_name_update('LATE', '지각');


-- 근태상태코드 활성/비활성 (요구사항 코드 : WORK_CON_003)
DELIMITER $$
CREATE PROCEDURE attendance_status_toggle_use (
    IN p_status_code VARCHAR(30),
    IN p_use_yn CHAR(1)
)
BEGIN
    IF p_use_yn NOT IN ('Y', 'N') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '근태 상태코드 활성/비활성(WORK_CON_003) 실패: use_yn 값은 Y 또는 N 이어야 합니다.';
    END IF;

    UPDATE attendance_status
    SET use_yn = p_use_yn,
        updated_at = CURRENT_TIMESTAMP
    WHERE status_code = p_status_code;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '근태 상태코드 활성/비활성(WORK_CON_003) 실패: 대상 상태코드를 찾을 수 없습니다.';
    END IF;
END$$
DELIMITER ;

CALL attendance_status_toggle_use('EARLY', 'Y');


-- 근태상태코드 조회 (요구사항 코드 : WORK_CON_004)
SELECT
    status_id, status_code, status_name, use_yn, created_at, updated_at
FROM attendance_status;



-- 휴가기준 등록 (요구사항 코드: VAC_001)
INSERT INTO leave_type (leave_type_name, annual_max_days, use_yn)
VALUES
('연차', NULL, 'Y'),
('병가', 24, 'Y'),
('경조', 5, 'Y'),
('공가', 5, 'Y');

INSERT INTO leave_annual_policy (leave_type_id, min_years, max_years, annual_max_days, use_yn)
VALUES
(1, 0, 0, 9, 'Y'), 
(1, 1, 3, 15, 'Y'), 
(1, 4, 9, 24, 'Y'), 
(1, 10, 100, 30, 'Y'); 



-- 휴가기준 수정 (요구사항 코드: VAC_002)
DELIMITER $$
CREATE OR REPLACE PROCEDURE update_leave_type(
    IN p_leave_type_id BIGINT,
    IN p_leave_type_name VARCHAR(50),
    IN p_annual_max_days INT,
    IN p_use_yn CHAR(1)
)
BEGIN
    UPDATE leave_type
    SET leave_type_name = p_leave_type_name,
        annual_max_days = p_annual_max_days,
        use_yn = p_use_yn,
        updated_at = CURRENT_TIMESTAMP
    WHERE leave_type_id = p_leave_type_id;
END $$
DELIMITER ;

CALL update_leave_type(3, '경조사', 5, 'Y');

--
DELIMITER $$
CREATE OR REPLACE PROCEDURE update_leave_annual_policy(
    IN p_leave_type_id BIGINT,
    IN p_min_years INT,
    IN p_max_years INT,
    IN p_annual_max_days INT,
    IN p_use_yn CHAR(1)
)
BEGIN
    UPDATE leave_annual_policy
    SET annual_max_days = p_annual_max_days,
        use_yn = p_use_yn,
        updated_at = CURRENT_TIMESTAMP
    WHERE leave_type_id = p_leave_type_id
      AND min_years = p_min_years
      AND max_years = p_max_years;
END $$
DELIMITER ;

CALL update_leave_annual_policy(1, 4, 9, 24, 'Y');

-- 휴가기준 조회 (요구사항 코드 : VAC_003)
SELECT 
    lt.leave_type_id,
    lt.leave_type_name,
    lt.annual_max_days AS type_max_days,
    lap.min_years,
    lap.max_years,
    lap.annual_max_days AS policy_max_days,
    lap.use_yn AS policy_use_yn
FROM leave_type lt
LEFT JOIN leave_annual_policy lap
    ON lt.leave_type_id = lap.leave_type_id;



-- 출퇴근 기록 등록 (요구사항 코드: INOUT_001)
DELIMITER $$
CREATE OR REPLACE PROCEDURE check_in (
    IN p_emp_id BIGINT,
    IN p_work_type_id BIGINT,
    IN p_work_date DATE,
    IN p_check_in_time DATETIME
)
BEGIN
    DECLARE v_start_time TIME;
    DECLARE v_status_check_in_id BIGINT;

    DECLARE v_sqlstate CHAR(5) DEFAULT '00000';
    DECLARE v_errmsg TEXT DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 
            v_sqlstate = RETURNED_SQLSTATE, 
            v_errmsg = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_errmsg; 
    END;
    
    START TRANSACTION;
    
    -- 근무 유형 기준 출근 시간 조회
    SELECT start_time
      INTO v_start_time
      FROM work_type
     WHERE work_type_id = p_work_type_id;

    -- 출근 상태 판정
    IF v_start_time IS NULL THEN
        SELECT status_id INTO v_status_check_in_id
          FROM attendance_status
         WHERE status_code = 'NORMAL';
    ELSEIF TIME(p_check_in_time) > v_start_time THEN
        SELECT status_id INTO v_status_check_in_id
          FROM attendance_status
         WHERE status_code = 'LATE';
    ELSE
        SELECT status_id INTO v_status_check_in_id
          FROM attendance_status
         WHERE status_code = 'NORMAL';
    END IF;

    -- 출근 기록 삽입 (출근 상태만 기록)
    INSERT INTO attendance_record (
        emp_id, work_type_id, status_check_in, work_date, check_in_time
    ) VALUES (
        p_emp_id, p_work_type_id, v_status_check_in_id, p_work_date, p_check_in_time
    );
    COMMIT;
END$$
DELIMITER ;

CALL check_in(2, 1, '2026-01-20', '2026-01-20 08:50:00');
CALL check_in(3, 1, '2026-01-20', '2026-01-20 09:10:00');

   

-- 퇴근 기록 등록 (요구사항 코드: INOUT_001 - 퇴근 처리)
DELIMITER $$
CREATE OR REPLACE PROCEDURE check_out (
    IN p_emp_id BIGINT,
    IN p_work_date DATE,
    IN p_check_out_time DATETIME
)
BEGIN
    -- 변수 선언은 BEGIN 직후
    DECLARE v_attendance_id BIGINT;
    DECLARE v_work_type_id BIGINT;
    DECLARE v_end_time TIME;
    DECLARE v_status_normal_id BIGINT;
    DECLARE v_status_early_id BIGINT;
    DECLARE v_check_out_status BIGINT;

    DECLARE v_sqlstate CHAR(5) DEFAULT '00000';
    DECLARE v_errmsg TEXT DEFAULT '';

    -- 에러 핸들러
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_errmsg   = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_errmsg;
    END;

    START TRANSACTION;

    -- 출근 기록 확인
    SELECT attendance_id, work_type_id INTO v_attendance_id, v_work_type_id
    FROM attendance_record
    WHERE emp_id = p_emp_id
      AND work_date = p_work_date
    LIMIT 1;

    IF v_attendance_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '퇴근 등록 실패: 출근 기록이 없습니다.';
    END IF;

    -- 퇴근 기준 시간 조회
    SELECT end_time INTO v_end_time
    FROM work_type
    WHERE work_type_id = v_work_type_id;

    -- 상태코드 조회
    SELECT status_id INTO v_status_normal_id
    FROM attendance_status
    WHERE status_code = 'NORMAL';

    SELECT status_id INTO v_status_early_id
    FROM attendance_status
    WHERE status_code = 'EARLY';

    -- 퇴근 상태 결정
    IF v_end_time IS NOT NULL AND TIME(p_check_out_time) < v_end_time THEN
        SET v_check_out_status = v_status_early_id;
    ELSE
        SET v_check_out_status = v_status_normal_id;
    END IF;

    -- 퇴근 기록 업데이트
    UPDATE attendance_record
    SET check_out_time = p_check_out_time,
        status_check_out = v_check_out_status,
        updated_at = NOW()
    WHERE attendance_id = v_attendance_id;
    COMMIT;
END$$
DELIMITER ;

CALL check_out(2, '2026-01-20', '2026-01-20 18:20:00');    
CALL check_out(3, '2026-01-20', '2026-01-20 18:00:00');    



-- 결근 기록
DELIMITER $$
CREATE OR REPLACE PROCEDURE attendance_finalize_daily (
    IN p_work_date DATE
)
BEGIN
    DECLARE v_absent_status_id BIGINT;

    DECLARE v_sqlstate CHAR(5);
    DECLARE v_errmsg TEXT;

    -- 공통 에러 핸들러
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_errmsg   = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = v_errmsg;
    END;

    START TRANSACTION;

    -- 결근 상태 ID
    SELECT status_id
      INTO v_absent_status_id
      FROM attendance_status
     WHERE status_code = 'ABSENT'
       AND use_yn = 'Y';

    -- 결근 처리
    INSERT INTO attendance_record (
        emp_id,
        work_date,
        status_check_in,
        created_at,
        updated_at
    )
    SELECT
        e.emp_id,
        p_work_date,
        v_absent_status_id,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    FROM employee e
    LEFT JOIN attendance_record ar
      ON ar.emp_id = e.emp_id
     AND ar.work_date = p_work_date
    WHERE ar.attendance_id IS NULL;
    COMMIT;
END$$
DELIMITER ;

CALL attendance_finalize_daily('2026-01-25');


-- 출퇴근 기록 조회 (요구사항 코드 : INOUT_002)
DELIMITER $$
CREATE OR REPLACE PROCEDURE attendance_record_select(
    IN p_emp_id BIGINT,
    IN p_dept_id BIGINT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    IF p_emp_id IS NOT NULL THEN
        SELECT *
        FROM attendance_record
        WHERE emp_id = p_emp_id
          AND work_date BETWEEN p_start_date AND p_end_date
        ORDER BY work_date;
    ELSEIF p_dept_id IS NOT NULL THEN
        SELECT ar.*
        FROM attendance_record ar
        JOIN employee e ON ar.emp_id = e.emp_id
        WHERE e.dept_id = p_dept_id
          AND ar.work_date BETWEEN p_start_date AND p_end_date
        ORDER BY ar.work_date;
    ELSE
        SELECT *
        FROM attendance_record
        WHERE work_date BETWEEN p_start_date AND p_end_date
        ORDER BY work_date;
    END IF;
END$$
DELIMITER ;

-- 개인 조회
CALL attendance_record_select(2, NULL, '2026-01-01', '2026-01-31');
-- 부서 조회
CALL attendance_record_select(NULL, 3, '2026-01-01', '2026-01-31');
-- 기간 조회
CALL attendance_record_select(NULL, NULL, '2026-01-01', '2026-01-31');



-- 초과근무 기록 등록 (요구사항 코드 : INOUT_003)
DELIMITER $$
CREATE PROCEDURE overtime_record_create (
    IN p_emp_id BIGINT,
    IN p_work_date DATE,
    IN p_overtime_minutes INT,
    IN p_overtime_type VARCHAR(20) 
)
BEGIN
    INSERT INTO overtime_record (
        emp_id,
        work_date,
        overtime_minutes,
        approval_status,
        overtime_type,
        created_at,
        updated_at
    ) VALUES (
        p_emp_id,
        p_work_date,
        p_overtime_minutes,
        'PENDING',
        p_overtime_type,
        NOW(),
        NOW()
    );
END$$
DELIMITER ;

CALL overtime_record_create(1, '2026-01-19', 120, 'EXTEND');



-- 초과근무 승인/반려 (요구사항 코드 : INOUT_003)
DELIMITER $$
CREATE OR REPLACE PROCEDURE overtime_record_decide (
    IN p_overtime_id BIGINT,
    IN p_decision VARCHAR(10) -- APPROVED / REJECTED
)
BEGIN
    -- 상태값 검증
    IF p_decision NOT IN ('APPROVED', 'REJECTED') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid approval status';
    END IF;

    UPDATE overtime_record
    SET approval_status = p_decision,
        approved_at = NOW(),
        updated_at = NOW()
    WHERE overtime_id = p_overtime_id;

    -- 대상 없음 → 에러
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Overtime record not found';
    END IF;
END$$
DELIMITER ;

-- 승인
CALL overtime_record_decide(2, 'APPROVED');
-- 반려
CALL overtime_record_decide(3, 'REJECTED');



-- 휴가 신청 등록 (요구사항 코드 : INOUT_004)
DELIMITER $$
CREATE PROCEDURE leave_request_create (
    IN p_emp_id BIGINT,
    IN p_leave_type_id BIGINT,
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_reason VARCHAR(255),
    IN p_use_days DECIMAL(3,1)
)
BEGIN
    INSERT INTO leave_request (
        emp_id,
        leave_type_id,
        start_date,
        end_date,
        reason,
        use_days,
        approval_status,
        created_at,
        updated_at
    ) VALUES (
        p_emp_id,
        p_leave_type_id,
        p_start_date,
        p_end_date,
        p_reason,
        p_use_days,
        'PENDING',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
END$$
DELIMITER ;

CALL leave_request_create(2, 1, '2026-02-03', '2026-02-03', '개인사유', 1.0);
CALL leave_request_create(3, 1, '2026-02-03', '2026-02-03', '개인사유', 0.5);
CALL leave_request_create(3, 4, '2026-02-05', '2026-02-07', '예비군', 3);
CALL leave_request_create(3, 4, '2026-02-06', '2026-02-08', '예비군', 3);
CALL leave_request_create(2, 1, '2026-01-25', '2026-01-26', '개인사유', 2);

-- 휴가신청 취소
-- 승인 전(PENDING)일 때만 취소 가능
DELIMITER $$
CREATE PROCEDURE leave_request_cancel (
    IN p_leave_request_id BIGINT
)
BEGIN
    UPDATE leave_request
    SET approval_status = 'CANCELED',
        updated_at = CURRENT_TIMESTAMP
    WHERE leave_request_id = p_leave_request_id
      AND approval_status = 'PENDING';

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            '휴가 취소(INOUT_004) 실패: PENDING 상태인 요청만 취소할 수 있습니다.';
    END IF;
END$$
DELIMITER ;

CALL leave_request_cancel(3);

-- 휴가 승인
DELIMITER $$
CREATE PROCEDURE leave_request_approve (
    IN p_leave_request_id BIGINT
)
BEGIN
    DECLARE v_use_days DECIMAL(3,1);
    DECLARE v_errmsg TEXT;

    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            '휴가 승인(INOUT_004) 실패: 해당 휴가 신청을 찾을 수 없습니다.';
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_errmsg = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = v_errmsg;
    END;

    START TRANSACTION;

    SELECT use_days
    INTO v_use_days
    FROM leave_request
    WHERE leave_request_id = p_leave_request_id;

    UPDATE leave_request
    SET approval_status = 'APPROVED',
        updated_at = CURRENT_TIMESTAMP
    WHERE leave_request_id = p_leave_request_id
      AND approval_status = 'PENDING';

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            '휴가 승인(INOUT_004) 실패: PENDING 상태인 요청만 승인할 수 있습니다.';
    END IF;

    INSERT INTO leave_history (leave_request_id, use_days)
    VALUES (p_leave_request_id, v_use_days);
    COMMIT;
END$$
DELIMITER ;

CALL leave_request_approve(4);
CALL leave_request_approve(1);



-- 근태 기록 수정 (요구사항 코드 : INOUT_005)
DELIMITER $$
CREATE OR REPLACE PROCEDURE attendance_record_update (
    IN p_attendance_id BIGINT,
    IN p_check_in_status_code  VARCHAR(30),
    IN p_check_out_status_code VARCHAR(30)
)
BEGIN
    DECLARE v_check_in_status_id  BIGINT;
    DECLARE v_check_out_status_id BIGINT;

    IF p_check_in_status_code IS NULL
       AND p_check_out_status_code IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '근태 수정 실패: 변경할 상태가 없습니다.';
    END IF;

    IF p_check_in_status_code IS NOT NULL THEN
        SELECT status_id
        INTO v_check_in_status_id
        FROM attendance_status
        WHERE status_code = p_check_in_status_code;
    END IF;

    IF p_check_out_status_code IS NOT NULL THEN
        SELECT status_id
        INTO v_check_out_status_id
        FROM attendance_status
        WHERE status_code = p_check_out_status_code;
    END IF;

    UPDATE attendance_record
    SET
        status_check_in  = COALESCE(v_check_in_status_id,  status_check_in),
        status_check_out = COALESCE(v_check_out_status_id, status_check_out),
        updated_at = CURRENT_TIMESTAMP
    WHERE attendance_id = p_attendance_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '근태 수정 실패: 해당 근태 기록을 찾을 수 없습니다.';
    END IF;
END$$
DELIMITER ;

CALL attendance_record_update(8, 'LATE', NULL);



-- 개인 근태 이력 조회 (요구사항 코드 : CHECK_001)
DELIMITER $$
CREATE PROCEDURE attendance_record_find_by_emp (
    IN p_emp_id BIGINT
)
BEGIN
    SELECT
        e.emp_id,
        e.`name`,
        ar.work_date,
        wt.work_type_name,
        s_in.status_name  AS check_in_status,
        ar.check_in_time,
        s_out.status_name AS check_out_status,
        ar.check_out_time
    FROM attendance_record ar
    JOIN employee e
      ON ar.emp_id = e.emp_id
    JOIN work_type wt
      ON ar.work_type_id = wt.work_type_id
    LEFT JOIN attendance_status s_in
      ON ar.status_check_in = s_in.status_id
    LEFT JOIN attendance_status s_out
      ON ar.status_check_out = s_out.status_id
    WHERE ar.emp_id = p_emp_id
    ORDER BY ar.work_date;
END$$
DELIMITER ;

CALL attendance_record_find_by_emp(3);



-- 특정 부서 사원들의  N 월 근태 기록 조회
DELIMITER $$
CREATE PROCEDURE attendance_record_find_by_dept_period (
    IN p_dept_id BIGINT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        d.dept_name,
        e.emp_id,
        e.`name`,
        ar.work_date,
        s_in.status_name AS check_in_status
    FROM attendance_record ar
    JOIN employee e
      ON ar.emp_id = e.emp_id
    LEFT JOIN department d
      ON e.dept_id = d.dept_id
    LEFT JOIN attendance_status s_in
      ON ar.status_check_in = s_in.status_id
    WHERE e.dept_id = p_dept_id
      AND ar.work_date BETWEEN p_start_date AND p_end_date
    ORDER BY e.emp_id, ar.work_date;
END$$
DELIMITER ;

CALL attendance_record_find_by_dept_period(3, '2026-01-01', '2026-01-31');



-- 부서 근태 통계
DELIMITER $$
CREATE PROCEDURE attendance_stats_by_dept (
    IN p_start_date DATE,
    IN p_end_date   DATE
)
BEGIN
    SELECT
        d.dept_name,
        
        /* 출근 기준 */
        SUM(CASE WHEN s_in.status_code = 'NORMAL' THEN 1 ELSE 0 END) AS 정상출근,
        SUM(CASE WHEN s_in.status_code = 'LATE'   THEN 1 ELSE 0 END) AS 지각,
        SUM(CASE WHEN s_in.status_code = 'ABSENT' THEN 1 ELSE 0 END) AS 결근,

        /* 퇴근 기준 */
        SUM(CASE WHEN s_out.status_code = 'NORMAL' THEN 1 ELSE 0 END) AS 정상퇴근,
        SUM(CASE WHEN s_out.status_code = 'EARLY'  THEN 1 ELSE 0 END) AS 조퇴,
        SUM(CASE WHEN ar.status_check_out IS NULL  THEN 1 ELSE 0 END) AS 퇴근미기록,

        COUNT(*) AS 총근태일수
    FROM attendance_record ar
    JOIN employee e ON ar.emp_id = e.emp_id
    LEFT JOIN department d ON e.dept_id = d.dept_id
    LEFT JOIN attendance_status s_in
           ON ar.status_check_in = s_in.status_id
    LEFT JOIN attendance_status s_out
           ON ar.status_check_out = s_out.status_id
    WHERE ar.work_date BETWEEN p_start_date AND p_end_date
    GROUP BY d.dept_id, d.dept_name
    ORDER BY d.dept_name;
END$$
DELIMITER ;

CALL attendance_stats_by_dept('2026-01-01', '2026-01-31');

