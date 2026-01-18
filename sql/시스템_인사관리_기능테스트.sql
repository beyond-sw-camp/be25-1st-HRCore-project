-- 사용자 계정 생성 (요구사항 코드: adm_001)
INSERT INTO `user` (
    username,
    `password`,
    `role`
) VALUES (
    'super_admin@partner.com',
    'TEMP_PASS_1234',
    'SUPER_ADMIN'
);

-- 확인
SELECT * FROM `user`;


-- 사용자 계정 조회 (요구사항 코드: adm_002)
-- 1. 모든 사용자 계정 조회
SELECT *
FROM `user`;

-- 2. 외부 관리자 계정 조회
SELECT *
FROM `user`
WHERE `role` = 'EXTERNAL_ADMIN'; 


-- 사용자 계정 수정 (요구사항 코드: adm_003)
-- user_id = 2 인 계정의 비밀번호 초기화
UPDATE `user`
SET `password` = 'TEMP_PASS_5678',
	 updated_at = CURRENT_TIMESTAMP
WHERE user_id = 2; 

SELECT * FROM `user` WHERE user_id = 2;



-- 사용자 계정 비활성화 (요구사항 코드: adm_004)
UPDATE `user`
SET use_yn = 'Y'
WHERE user_id = 2;

SELECT * FROM `user` WHERE user_id = 2; 



-- 사용자 계정 역할 변경 (요구사항 코드: adm_005)
UPDATE `user`
SET `role` = 'ADMIN'
WHERE user_id = 3;

SELECT * FROM `user` WHERE user_id = 3; 



-- 사용자 계정 권한 조회 (요구사항 코드: adm_006)
SELECT username,
		 `role`
FROM `user`; 



-- 사원 등록 및 사용자 계정 생성 (요구사항 코드: emp_001 + adm_001 + adm_008)
DELIMITER $$
CREATE PROCEDURE register_employee_with_user(
    IN p_email        VARCHAR(50),
    IN p_name         VARCHAR(20),
    IN p_tel          VARCHAR(20),
    IN p_jumin        VARCHAR(20),
    IN p_bank_name    VARCHAR(20),
    IN p_bank_account VARCHAR(30),
    IN p_hire_date    DATE
)
BEGIN
    DECLARE v_emp_id BIGINT;

    -- 예외 발생 시 전체 롤백
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '사원 등록 트랜잭션 처리 중 오류가 발생했습니다.';
    END;

    START TRANSACTION;
    -- 1. 사원 등록
    INSERT INTO employee (
        email,
        `name`,
        tel,
        jumin,
        bank_name,
        bank_account,
        hire_date
    ) VALUES (
        p_email,
        p_name,
        p_tel,
        p_jumin,
        p_bank_name,
        p_bank_account,
        p_hire_date
    );
    -- 2. 생성된 emp_id 확보
    SET v_emp_id = LAST_INSERT_ID();

    -- 3. 사용자 계정 생성
    INSERT INTO `user` (
        emp_id,
        username,
        `password`
    ) VALUES (
        v_emp_id,
        p_email,
        'TEMP_PASS_1234'  -- 임시 비밀번호 (추후 해시 처리)
    );
    COMMIT;
END$$
DELIMITER ;

CALL register_employee_with_user(
    'admin01.dev@company.com',
    '인사담당자01',
    '010-2345-5678',
    '850814-1358901',
    '신한',
    '317-6688-415622',
    '2021-02-05'
);

-- 확인
SELECT * FROM employee;
SELECT * FROM `user`;

-- 사원 정보 수정 (요구사항 코드: emp_002)
DELIMITER $$
CREATE PROCEDURE update_employee_info(
    IN p_emp_id BIGINT,
    IN p_new_email VARCHAR(50),
    IN p_new_name VARCHAR(20),
    IN p_tel VARCHAR(20),
    IN p_jumin VARCHAR(20),
    IN p_hire_date DATE,
    IN p_bank_name VARCHAR(20),
    IN p_bank_account VARCHAR(30)
)
BEGIN
    DECLARE v_old_email VARCHAR(50);
    
    -- 예외 발생 시 롤백
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN
		 ROLLBACK;
		 SIGNAL SQLSTATE '45000'
		 SET MESSAGE_TEXT = '사원 정보(이메일) 수정 중 오류가 발생했습니다.';
	 END;
    
    -- 현재 이메일 조회
    SELECT email
    INTO v_old_email
    FROM employee
    WHERE emp_id = p_emp_id;

    -- 이메일 변경 여부 판단
    IF p_new_email IS NOT NULL AND p_new_email <> v_old_email THEN
        START TRANSACTION;
        -- 1. 사원 정보 수정
        UPDATE employee
        SET
            email        = p_new_email,
            `name`       = COALESCE(p_new_name, `name`),
            tel          = COALESCE(p_tel, tel),
            jumin        = COALESCE(p_jumin, jumin),
            hire_date    = COALESCE(p_hire_date, hire_date),
            bank_name    = COALESCE(p_bank_name, bank_name),
            bank_account = COALESCE(p_bank_account, bank_account),
            updated_at   = CURRENT_TIMESTAMP
        WHERE emp_id = p_emp_id;

        -- 2. 사용자 로그인 ID 수정
        UPDATE `user`
        SET
            username   = p_new_email,
            updated_at = CURRENT_TIMESTAMP
        WHERE emp_id = p_emp_id;
        COMMIT;
    ELSE
        -- 이메일 변경 없음 → employee 단독 수정
        UPDATE employee
        SET
            `name`         = COALESCE(p_new_name, `name`),
            tel          = COALESCE(p_tel, tel),
            jumin        = COALESCE(p_jumin, jumin),
            hire_date    = COALESCE(p_hire_date, hire_date),
            bank_name    = COALESCE(p_bank_name, bank_name),
            bank_account = COALESCE(p_bank_account, bank_account),
            updated_at   = CURRENT_TIMESTAMP
        WHERE emp_id = p_emp_id;
    END IF;
END$$
DELIMITER ;

-- 1. 사원의 이메일이 변경될 시 (트랜잭션 발생) 
CALL update_employee_info(
    1,
    'test01_update.dev@company.com',
    '이메일변경',
    '010-1234-5678',
    NULL,
    NULL,
    NULL,
    NULL
);

-- 2. 사원의 연락처 + 계좌만 변경될 시 (트랜잭션 미발생)
CALL update_employee_info(
    2,
    NULL,
    NULL,
    '010-9999-8888',
    NULL,
    NULL,
    '국민은행',
    '123-456-789012'
);



-- 사원 정보 조회 (요구사항 코드: emp_003)
-- 1. 조회 조건 없는 전체 사원 조회 (인사 담당자용)
SELECT
    e.emp_id,
    e.email,
    e.`name`,
    e.jumin,
    e.tel,
    e.hire_date,
    e.resign_date,
    e.`status`,
	 IFNULL(d.dept_name, '미배정')      AS dept_name,
    IFNULL(p.position_name, '미배정') AS position_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
LEFT JOIN job_position p ON e.position_id = p.position_id;

-- 2. 이메일로 특정 사원 조회 (검색 조건)
SELECT
    e.emp_id,
    e.email,
    e.`name`,
    e.jumin,
    e.tel,
    e.hire_date,
    e.resign_date,
    e.`status`,
    IFNULL(d.dept_name, '미배정')      AS dept_name,
    IFNULL(p.position_name, '미배정') AS position_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
LEFT JOIN job_position p ON e.position_id = p.position_id
WHERE e.email = 'jung.qa@company.com';



-- 휴직 처리 (요구사항 코드: emp_status_001) 
DELIMITER $$
CREATE PROCEDURE emp_leave (
    IN p_emp_id   BIGINT,
    IN p_admin_id BIGINT,
    IN p_reason   TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '사원 휴직 처리 중 오류가 발생했습니다.';
    END;

    START TRANSACTION;
    -- 1. 사원 상태 변경 (휴직)
    UPDATE employee
    SET
        status = '휴직',
        updated_at = CURRENT_TIMESTAMP
    WHERE emp_id = p_emp_id;

    -- 2. 상태 변경 이력 기록
    INSERT INTO emp_status_history (
        emp_id,
        admin_id,
        change_status,
        reason
    ) VALUES (
        p_emp_id,
        p_admin_id,
        '휴직',
        p_reason
    );
    COMMIT;
END$$
DELIMITER ;

CALL emp_leave(
    1,
    3,
    '개인 사유로 인한 휴직'
);

SELECT * FROM employee;
SELECT * FROM emp_status_history;



-- 복직 처리 (요구사항 코드: emp_status_002) 
DELIMITER $$
CREATE PROCEDURE emp_return (
    IN p_emp_id   BIGINT,
    IN p_admin_id BIGINT,
    IN p_reason   TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '사원 복직 처리 중 오류가 발생했습니다.';
    END;

    START TRANSACTION;
    -- 1. 사원 상태 변경 (재직)
    UPDATE employee
    SET
        status = '재직',
        updated_at = CURRENT_TIMESTAMP
    WHERE emp_id = p_emp_id;

    -- 2. 상태 변경 이력 기록
    INSERT INTO emp_status_history (
        emp_id,
        admin_id,
        change_status,
        reason
    ) VALUES (
        p_emp_id,
        p_admin_id,
        '재직',
        p_reason
    );
    COMMIT;
END$$
DELIMITER ;

CALL emp_return(
    1,
    3,
    '휴직 종료 및 복직'
);

SELECT * FROM employee;
SELECT * FROM emp_status_history;



-- 퇴사 처리 (요구사항 코드: emp_status_003) 
DELIMITER $$
CREATE PROCEDURE emp_retire (
    IN p_emp_id   BIGINT,
    IN p_admin_id BIGINT,
    IN p_reason   TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '사원 퇴직 처리 중 오류가 발생했습니다.';
    END;

    START TRANSACTION;
    -- 1. 사원 상태 변경 (퇴직)
    UPDATE employeeemployee
    SET
        status = '퇴직',
        resign_date = CURRENT_DATE,
        updated_at = CURRENT_TIMESTAMP
    WHERE emp_id = p_emp_id;

    -- 2. 사용자 계정 비활성화
    UPDATE `user`
    SET
        use_yn = 'N',
        updated_at = CURRENT_TIMESTAMP
    WHERE emp_id = p_emp_id;

    -- 3. 상태 변경 이력 기록
    INSERT INTO emp_status_history (
        emp_id,
        admin_id,
        change_status,
        reason
    ) VALUES (
        p_emp_id,
        p_admin_id,
        '퇴직',
        p_reason
    );
    COMMIT;
END$$
DELIMITER ;

CALL emp_retire(
    1,
    3,
    '정년 퇴직'
);

SELECT * FROM employee;
SELECT * FROM `user`;
SELECT * FROM emp_status_history;



-- 재직 상태 변경 이력 조회 (요구사항 코드: emp_status_004)
-- 1. 모든 사원의 재직 상태 변경 이력
SELECT *
FROM emp_status_history;

-- 2. emp_id = 1 인 사원의 재직 상태 변경 이력
SELECT *
FROM emp_status_history;


-- 부서 생성 (요구사항 코드: dept-001)
INSERT INTO department (dept_code, dept_name, size)
VALUES
('HR', '인사팀', 10),
('FIN', '재무회계팀', 15),
('SALES', '영업팀', 15),
('DEV', '개발팀', 30),
('OPS', '기획팀', 15),
('QA', '고객지원팀', 15);

SELECT * FROM department;



-- 부서 정보 수정 (요구사항 코드: dept-002)
-- 1. 부서 코드와 부서명 수정
UPDATE department
SET dept_name = 'TF1팀'
WHERE dept_id = 7;

SELECT * FROM department WHERE dept_id = 7;

-- 2. 부서 크기 수정
UPDATE department
SET size = 20
WHERE dept_id = 7;

SELECT * FROM department WHERE dept_id = 7;



-- 부서 구조 조회	(요구사항 코드: dept_003)
SELECT dept_code,
		 dept_name,
		 size 
FROM department;



-- 부서 활성화 상태 변경 (요구사항 코드: dept_004)
UPDATE department
SET use_yn = 'N'
WHERE dept_id = 7;

SELECT * FROM department WHERE dept_id = 7;



-- 부서 배정 (요구사항 코드: dept_assign_001)
DELIMITER $$
CREATE PROCEDURE emp_assign_department (
    IN p_emp_id BIGINT,
    IN p_dept_id BIGINT,
    IN p_admin_id BIGINT
)
BEGIN
    DECLARE v_emp_status VARCHAR(10);
    DECLARE v_current_dept BIGINT;

    -- 예외 발생 시 롤백
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '부서 배정 처리 중 오류가 발생했습니다.';
    END;

    -- 사원 상태 및 현재 부서 조회
    SELECT `status`, dept_id
    INTO v_emp_status, v_current_dept
    FROM employee
    WHERE emp_id = p_emp_id;

    START TRANSACTION;
    -- 1. 사원 부서 배정
    UPDATE employee
    SET
        dept_id = p_dept_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE emp_id = p_emp_id;

    -- 2. 부서 변경 이력 기록
    INSERT INTO department_change_history (
        emp_id,
        dept_id,
        admin_id
    ) VALUES (
        p_emp_id,
        p_dept_id,
        p_admin_id
    );
    COMMIT;
END$$
DELIMITER ;

CALL emp_assign_department(
    2,  -- emp_id
    1,  -- dept_id
    2  -- admin user_id
);



-- 부서 이동 (요구사항 코드: dept_assign_002)
DELIMITER $$
CREATE PROCEDURE emp_change_department (
    IN p_emp_id BIGINT,
    IN p_new_dept_id BIGINT,
    IN p_admin_id BIGINT
)
BEGIN
    -- 예외 발생 시 전체 롤백
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '부서 변경 처리 중 오류가 발생했습니다.';
    END;

    START TRANSACTION;
    -- 1. 사원 부서 변경
    UPDATE employee
    SET
        dept_id = p_new_dept_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE emp_id = p_emp_id;

    -- 2. 부서 이동 이력 기록
    INSERT INTO department_change_history (
        emp_id,
        dept_id,
        admin_id
    ) VALUES (
        p_emp_id,
        p_new_dept_id,
        p_admin_id
    );
    COMMIT;
END$$
DELIMITER ;

CALL emp_change_department(
    4,     
    3,      
    3
);



-- 부서 변경 이력 조회 (요구사항 코드: dept_assign_003)
SELECT
    h.history_id,
    e.emp_id,
    e.`name`            AS employee_name,
    d.dept_name         AS changed_dept_name,
    u.username,
    h.created_at        AS change_date
FROM department_change_history h
JOIN employee e ON h.emp_id = e.emp_id
JOIN department d ON h.dept_id = d.dept_id
JOIN `user` u ON h.admin_id = u.user_id
WHERE e.emp_id = 4
ORDER BY h.created_at DESC;



-- 직급 등록 (요구사항 코드: job_position_001)
INSERT INTO `job_position` (position_name, base_salary) VALUES
('인턴', 2500000),
('사원', 3200000),
('대리', 4000000),
('과장', 5000000),
('차장', 6300000),
('부장', 8000000);



-- 직급 정보 수정 (요구사항 코드: job_position_002) 
UPDATE job_position
SET base_salary = 7800000
WHERE position_name = '부장';



-- 직급 정보 조회 (요구사항 코드: job_position_003) 
SELECT *
FROM job_position;



-- 직급 배정 (요구사항 코드: position_assign_001)
DELIMITER $$
CREATE PROCEDURE emp_assign_position(
    IN p_emp_id BIGINT,
    IN p_position_id BIGINT,
    IN p_admin_id BIGINT
)
BEGIN
    DECLARE v_old_position BIGINT;

    -- 예외 시 롤백
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '직급 배정 중 오류가 발생했습니다.';
    END;

    -- 기존 직급 확인
    SELECT position_id INTO v_old_position
    FROM employee
    WHERE emp_id = p_emp_id;

    START TRANSACTION;
    -- 직원 직급 업데이트
    UPDATE employee
    SET position_id = p_position_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE emp_id = p_emp_id;

    -- 직급 이력 기록 (기존 직급이 NULL이든 아니든 기록)
    INSERT INTO position_change_history (
        emp_id,
		  position_id,
        admin_id
    ) VALUES (
        p_emp_id,
        p_position_id,
        p_admin_id
    );
    COMMIT;
END$$
DELIMITER ;

CALL emp_assign_position(
    2,      -- emp_id
    2,      -- position_id (예: 과장)
    2       -- admin user_id
);

-- 확인
SELECT * FROM employee;


-- 승진 처리 (요구사항 코드: position_assign_002)
DELIMITER $$
CREATE PROCEDURE promote_employee(
    IN p_emp_id BIGINT,
    IN p_admin_id BIGINT
)
BEGIN
    DECLARE v_current_position_id BIGINT;
    DECLARE v_new_position_id BIGINT DEFAULT NULL;
    DECLARE v_hire_date DATE;
    DECLARE v_years_worked INT;

    -- 예외 발생 시 전체 롤백
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '승진 처리 중 오류가 발생했습니다.';
    END;

    -- 현재 직급과 입사일 조회
    SELECT position_id, hire_date
    INTO v_current_position_id, v_hire_date
    FROM employee
    WHERE emp_id = p_emp_id;

    -- 입사 후 누적 연수 계산
    SET v_years_worked = TIMESTAMPDIFF(YEAR, v_hire_date, CURDATE());

    -- 승진 기준 적용
    IF v_current_position_id = 1 AND v_years_worked >= 0 THEN
        SET v_new_position_id = 2; -- 인턴 → 사원
    ELSEIF v_current_position_id = 2 AND v_years_worked >= 4 THEN
        SET v_new_position_id = 3; -- 사원 → 대리
    ELSEIF v_current_position_id = 3 AND v_years_worked >= 8 THEN
        SET v_new_position_id = 4; -- 대리 → 과장
    ELSEIF v_current_position_id = 4 AND v_years_worked >= 12 THEN
        SET v_new_position_id = 5; -- 과장 → 차장
    ELSEIF v_current_position_id = 5 AND v_years_worked >= 17 THEN
        SET v_new_position_id = 6; -- 차장 → 부장
    END IF;

    -- 승진 대상이 있을 때만 트랜잭션 처리
    IF v_new_position_id IS NOT NULL THEN
        START TRANSACTION;

        -- 직급 변경
        UPDATE employee
        SET position_id = v_new_position_id,
            updated_at = CURRENT_TIMESTAMP
        WHERE emp_id = p_emp_id;

        -- 변경 이력 기록
        INSERT INTO position_change_history (
            emp_id,
				position_id,
            admin_id
         ) VALUES (
				p_emp_id,
				v_new_position_id,
		      p_admin_id
			);
        COMMIT;
    END IF;
END$$
DELIMITER ;

-- 호출 예시
CALL promote_employee(2, 3);



-- 직급 변경 이력 조회 (요구사항 코드: position_assign_003)
SELECT *
FROM position_change_history
WHERE emp_id = 6;