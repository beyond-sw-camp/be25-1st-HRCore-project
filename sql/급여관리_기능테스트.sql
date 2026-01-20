-- 급여 항목 등록 (요구사항 코드: PAY_ITEM_001)
DELIMITER $$
CREATE PROCEDURE pay_item_create (
    IN p_pay_item_code VARCHAR(30),
    IN p_pay_item_name VARCHAR(100),
    IN p_item_type VARCHAR(10),   -- EARN / DEDUCT
    IN p_calc_type VARCHAR(10),   -- FIX / RATE / RULE
    IN p_calc_value DECIMAL(10,2),
    IN p_tax_yn CHAR(1)
)
BEGIN
    INSERT INTO pay_item (
        pay_item_code,
        pay_item_name,
        item_type,
        calc_type,
        calc_value,
        tax_yn
    ) VALUES (
        p_pay_item_code,
        p_pay_item_name,
        p_item_type,
        p_calc_type,
        p_calc_value,
        p_tax_yn
    );
END$$
DELIMITER ;

CALL pay_item_create('BASE_SALARY','기본급','EARN','RULE',NULL,'Y');
CALL pay_item_create('HEALTH_INSURANCE','건강보험','DEDUCT','RATE',9.5,'N');
CALL pay_item_create('NATIONAL_PENSION','국민연금','DEDUCT','RATE',7.19,'N');
CALL pay_item_create('EMPLOYMENT_INSURANCE','고용보험','DEDUCT','RATE',1.8,'N');
CALL pay_item_create('INDUSTRIAL_ACCIDENT_INSURANCE','산재보험','DEDUCT','RATE',1.2,'N');
CALL pay_item_create('ABSENCE_DEDUCT','결근 공제','DEDUCT','RATE',5.0,'N');



-- 급여 항목 기준값 수정 (요구사항 코드: PAY_ITEM_002)
DELIMITER $$
CREATE PROCEDURE pay_item_update_value (
    IN p_pay_item_code VARCHAR(30),
    IN p_calc_value DECIMAL(10,2)
)
BEGIN
    UPDATE pay_item
    SET calc_value = p_calc_value,
        updated_at = CURRENT_TIMESTAMP
    WHERE pay_item_code = p_pay_item_code
      AND use_yn = 'Y';
END$$
DELIMITER ;

-- 산재보험 요율 변경 (1.2 → 1.25)
CALL pay_item_update_value(
    'INDUSTRIAL_ACCIDENT_INSURANCE',
    1.25
);

-- 확인
SELECT * FROM pay_item WHERE pay_item_code = 'INDUSTRIAL_ACCIDENT_INSURANCE';



-- 급여 항목 활성화 상태 변경 (요구사항 코드: PAY_ITEM_003)
DELIMITER $$
CREATE PROCEDURE pay_item_toggle_use (
    IN p_pay_item_code VARCHAR(30),
    IN p_use_yn CHAR(1)   -- Y: 활성 / N: 비활성
)
BEGIN
    UPDATE pay_item
    SET use_yn = p_use_yn,
        updated_at = CURRENT_TIMESTAMP
    WHERE pay_item_code = p_pay_item_code;
END$$
DELIMITER ;

-- 산재보험 활성화 상태 변경
CALL pay_item_toggle_use(
    'INDUSTRIAL_ACCIDENT_INSURANCE',
    'Y'
);

-- 확인
SELECT * FROM pay_item WHERE pay_item_code = 'INDUSTRIAL_ACCIDENT_INSURANCE';



-- 급여 항목 조회 (요구사항 코드: PAY_ITEM_004)
-- 전체 조회
SELECT *
FROM pay_item;

-- 지급 항목만 조회
SELECT *
FROM pay_item
WHERE item_type = 'EARN';



-- 급여 명세서 생성 (요구사항hrcore_dbhrcore_db 코드: PAYSLIP_001)
DELIMITER $$
CREATE OR REPLACE PROCEDURE payslip_create (
    IN p_emp_id BIGINT,
    IN p_pay_ym CHAR(7)   -- 'YYYY-MM'
)
BEGIN
    DECLARE v_payslip_id BIGINT;
    DECLARE v_base_salary DECIMAL(12,0);
    DECLARE v_total_pay DECIMAL(12,0) DEFAULT 0;
    DECLARE v_total_deduct DECIMAL(12,0) DEFAULT 0;

    -- 예외 발생 시 롤백
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 재직 여부 확인
    IF NOT EXISTS (
        SELECT 1
        FROM employee
        WHERE emp_id = p_emp_id
          AND status = '재직'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '재직 중인 사원만 급여 명세서를 생성할 수 있습니다.';
    END IF;
    
	 -- 중복 payslip 체크
	 IF EXISTS (
  		 SELECT 1
       FROM payslip
       WHERE emp_id = p_emp_id
        AND pay_ym = p_pay_ym
	 ) THEN
	     SIGNAL SQLSTATE '45000'
	     SET MESSAGE_TEXT = '이미 생성된 급여 명세서가 있습니다.';
  	 END IF; 
  	 
    -- 기본급 조회 (직급 기준)
    SELECT jp.base_salary
    INTO v_base_salary
    FROM employee e
    JOIN job_position jp
      ON e.position_id = jp.position_id
    WHERE e.emp_id = p_emp_id;

    -- payslip 생성
    INSERT INTO payslip (
        emp_id,
        pay_ym,
        status
    ) VALUES (
        p_emp_id,
        p_pay_ym,
        'CREATED'
    );

    SET v_payslip_id = LAST_INSERT_ID();

    -- 기본급 항목 저장
    INSERT INTO payslip_item (
        payslip_id,
        pay_item_id,
        amount
    )
    SELECT
        v_payslip_id,
        pi.pay_item_id,
        v_base_salary
    FROM pay_item pi
    WHERE pi.pay_item_code = 'BASE_SALARY'
      AND pi.use_yn = 'Y';

    SET v_total_pay = v_base_salary;

    -- 공제 항목 계산 (RATE 기준)
    INSERT INTO payslip_item (
        payslip_id,
        pay_item_id,
        amount
    )
    SELECT
        v_payslip_id,
        pi.pay_item_id,
        ROUND(v_base_salary * pi.calc_value / 100, 0)
    FROM pay_item pi
    WHERE pi.item_type = 'DEDUCT'
      AND pi.calc_type = 'RATE'
      AND pi.use_yn = 'Y';

    -- 총 공제액 계산
    SELECT IFNULL(SUM(amount), 0)
    INTO v_total_deduct
    FROM payslip_item
    WHERE payslip_id = v_payslip_id
    	AND pay_item_id IN (SELECT pay_item_id FROM pay_item WHERE item_type='DEDUCT');

    -- payslip 금액 확정
    UPDATE payslip
    SET total_pay    = v_total_pay,
        total_deduct = v_total_deduct,
        net_pay = ROUND(v_total_pay - v_total_deduct, 0),
        updated_at   = CURRENT_TIMESTAMP
    WHERE payslip_id = v_payslip_id;

    -- 급여 명세 접근 정보 생성
    INSERT INTO payslip_access (
        payslip_id,
        failed_count
    ) VALUES (
        v_payslip_id,
        0
    );
    COMMIT;
END$$
DELIMITER ;

CALL payslip_create(2, '2026-01');

-- 확인
SELECT * FROM employee;
SELECT * FROM payslip;
SELECT * FROM payslip_item;
SELECT * FROM payslip_access;



-- 급여 명세서 확정 (요구사항 코드: PAYSLIP_002) 
DELIMITER $$
CREATE OR REPLACE PROCEDURE payslip_confirm (
    IN p_payslip_id BIGINT
)
BEGIN
    DECLARE v_status VARCHAR(20);

    -- 현재 상태 확인
    SELECT status
      INTO v_status
      FROM payslip
     WHERE payslip_id = p_payslip_id;

    -- 존재 여부 체크
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '존재하지 않는 급여 명세서입니다.';
    END IF;

    -- 이미 확정된 경우
    IF v_status = 'CONFIRMED' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 확정된 급여 명세서입니다.';
    END IF;

    -- 급여 확정 처리
    UPDATE payslip
       SET status = 'CONFIRMED',
           confirmed_at = CURRENT_TIMESTAMP
     WHERE payslip_id = p_payslip_id;
END $$
DELIMITER ;

CALL payslip_confirm(1);

-- 확인
SELECT * FROM payslip;



-- 급여 명세서 조회 (요구사항 코드: PAYSLIP_003) 
-- 관리자용 급여 명세서 조회 기능
DELIMITER $$
CREATE OR REPLACE PROCEDURE payslip_view_admin (
    IN p_payslip_id BIGINT
)
BEGIN
    -- 확정 여부 확인
    IF NOT EXISTS (
        SELECT 1
        FROM payslip
        WHERE payslip_id = p_payslip_id
          AND status = 'CONFIRMED'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '확정된 급여 명세서만 조회할 수 있습니다';
    END IF;

    -- 급여 명세서 요약
    SELECT
        p.payslip_id,
        p.emp_id,
        e.name,
        d.dept_name,
        pos.position_name,
        p.pay_ym,
        p.total_pay,
        p.total_deduct,
        p.net_pay
    FROM payslip p
    JOIN employee e ON p.emp_id = e.emp_id
    JOIN job_position pos ON e.position_id = pos.position_id
    JOIN department d ON e.dept_id = d.dept_id
    WHERE p.payslip_id = p_payslip_id;

    -- 급여 항목
    SELECT
        pi.pay_item_id,
        pit.pay_item_name,
        pit.item_type,
        pi.amount
    FROM payslip_item pi
    JOIN pay_item pit ON pi.pay_item_id = pit.pay_item_id
    WHERE pi.payslip_id = p_payslip_id
    ORDER BY pit.item_type DESC, pi.pay_item_id ASC;
END$$
DELIMITER ;

CALL payslip_view_admin(1);



-- 본인용 급여 명세서
DELIMITER $$
CREATE OR REPLACE PROCEDURE payslip_view_self (
    IN p_payslip_id BIGINT,
    IN p_emp_id     BIGINT,
    IN p_birth_pwd  CHAR(6)
)
BEGIN
    DECLARE v_failed        INT;
    DECLARE v_unlock_at     DATETIME;
    DECLARE v_birth_pwd_db  CHAR(6);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 본인 + 확정 명세서 검증
    IF NOT EXISTS (
        SELECT 1
        FROM payslip
        WHERE payslip_id = p_payslip_id
          AND emp_id = p_emp_id
          AND status = 'CONFIRMED'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '본인의 확정된 급여 명세서만 조회할 수 있습니다';
    END IF;

    -- payslip_access 레코드 보장
    INSERT INTO payslip_access (payslip_id)
    VALUES (p_payslip_id)
    ON DUPLICATE KEY UPDATE
        updated_at = CURRENT_TIMESTAMP;

    -- 사원 생년월일 조회
    SELECT SUBSTRING(jumin, 1, 6)
    INTO v_birth_pwd_db
    FROM employee
    WHERE emp_id = p_emp_id;

    -- 접근 정보 조회
    SELECT failed_count, unlock_at
    INTO v_failed, v_unlock_at
    FROM payslip_access
    WHERE payslip_id = p_payslip_id
    FOR UPDATE;

    -- 잠금 상태 확인
    IF v_unlock_at IS NOT NULL AND v_unlock_at > NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '비밀번호 입력 실패로 잠금 상태입니다';
    END IF;

    -- 생년월일 검증
    IF v_birth_pwd_db <> p_birth_pwd THEN
        UPDATE payslip_access
        SET failed_count = failed_count + 1,
            unlock_at = CASE
                WHEN failed_count + 1 >= 5
                THEN DATE_ADD(NOW(), INTERVAL 30 MINUTE)
                ELSE unlock_at
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE payslip_id = p_payslip_id;
		  
		  -- 실패 기록은 반드시 남겨야 하므로 커밋
        COMMIT;
			
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '생년월일이 일치하지 않습니다';
    END IF;

    -- 성공 시 실패 횟수 초기화
    UPDATE payslip_access
    SET failed_count = 0,
        unlock_at = NULL,
        updated_at = CURRENT_TIMESTAMP
    WHERE payslip_id = p_payslip_id;

    -- 급여 명세서 요약
 	 SELECT
		  e.`name`,	
		  d.dept_name,
		  pos.position_name,
	     p.pay_ym,
	     p.total_pay,
	     p.total_deduct,
	     p.net_pay
	 FROM payslip p
	 JOIN employee e ON p.emp_id = e.emp_id
	 JOIN job_position pos ON e.position_id = pos.position_id
	 JOIN department d ON e.dept_id = d.dept_id
	 WHERE p.payslip_id = p_payslip_id;
		
	 -- 급여 항목
 	 SELECT
	     pit.pay_item_name,
	     pit.item_type,
	     pi.amount
	 FROM payslip_item pi
	 JOIN pay_item pit ON pi.pay_item_id = pit.pay_item_id
	 WHERE pi.payslip_id = p_payslip_id
	 ORDER BY pit.item_type DESC, pi.pay_item_id ASC;
    COMMIT;
END$$
DELIMITER ;

CALL payslip_view_self(1, 1, '850814');

SELECT * FROM payslip_access WHERE payslip_id = 1;