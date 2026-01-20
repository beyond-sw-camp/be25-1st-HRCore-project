-- 사원 등록
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

-- 사원 정보 수정
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

-- 퇴직 처리
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
    UPDATE employee
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

-- 부서 배정
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

-- 부서 이동 (요구사항 코드: dept_assign_002)
DELIMITER $$
CREATE OR REPLACE PROCEDURE emp_change_department (
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

