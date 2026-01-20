-- 급여 항목 등록
DELIMITER $$
CREATE PROCEDURE pay_item_create (
    IN p_pay_item_code VARCHAR(30),
    IN p_pay_item_name VARCHAR(100),
    IN p_item_type VARCHAR(10),   
    IN p_calc_type VARCHAR(10),  
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

-- 급여 항목 기준값 수정
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

-- 급여 항목 활성화 상태 변경
DELIMITER $$
CREATE PROCEDURE pay_item_toggle_use (
    IN p_pay_item_code VARCHAR(30),
    IN p_use_yn CHAR(1)  
)
BEGIN
    UPDATE pay_item
    SET use_yn = p_use_yn,
        updated_at = CURRENT_TIMESTAMP
    WHERE pay_item_code = p_pay_item_code;
END$$
DELIMITER ;

-- 급여 명세서 생성
DELIMITER $$
CREATE OR REPLACE PROCEDURE payslip_create (
    IN p_emp_id BIGINT,
    IN p_pay_ym CHAR(7)  
)
BEGIN
    DECLARE v_payslip_id BIGINT;
    DECLARE v_base_salary DECIMAL(12,0);
    DECLARE v_hourly_rate DECIMAL(12,2);
    DECLARE v_total_pay DECIMAL(12,0) DEFAULT 0;
    DECLARE v_total_deduct DECIMAL(12,0) DEFAULT 0;
    DECLARE v_absence_count INT DEFAULT 0;
    DECLARE v_late_count INT DEFAULT 0;
    DECLARE v_early_count INT DEFAULT 0;
    DECLARE v_total_absence INT DEFAULT 0;
    DECLARE v_absence_item_id BIGINT;
    DECLARE v_extend_item_id BIGINT;
    DECLARE v_night_item_id BIGINT;

    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    
    IF NOT EXISTS (
        SELECT 1
        FROM employee
        WHERE emp_id = p_emp_id
          AND status = '재직'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '재직 중인 사원만 급여 명세서를 생성할 수 있습니다.';
    END IF;

    
    IF EXISTS (
        SELECT 1
        FROM payslip
        WHERE emp_id = p_emp_id
          AND pay_ym = p_pay_ym
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 생성된 급여 명세서가 있습니다.';
    END IF;

    
    SELECT jp.base_salary
    INTO v_base_salary
    FROM employee e
    JOIN job_position jp
      ON e.position_id = jp.position_id
    WHERE e.emp_id = p_emp_id;

    
    SET v_hourly_rate = v_base_salary / 209;

    
    INSERT INTO payslip (emp_id, pay_ym, status)
    VALUES (p_emp_id, p_pay_ym, 'CREATED');
    SET v_payslip_id = LAST_INSERT_ID();

    
    INSERT INTO payslip_item (payslip_id, pay_item_id, amount)
    SELECT v_payslip_id, pi.pay_item_id, v_base_salary
    FROM pay_item pi
    WHERE pi.pay_item_code = 'BASE_SALARY'
      AND pi.use_yn = 'Y';
    SET v_total_pay = v_base_salary;

   
    SELECT pay_item_id INTO v_extend_item_id
    FROM pay_item
    WHERE pay_item_code = 'OVERTIME_EXTEND'
      AND use_yn = 'Y'
    LIMIT 1;

    SELECT pay_item_id INTO v_night_item_id
    FROM pay_item
    WHERE pay_item_code = 'OVERTIME_NIGHT'
      AND use_yn = 'Y'
    LIMIT 1;

 
    INSERT INTO payslip_item (payslip_id, pay_item_id, amount)
    SELECT
        v_payslip_id, v_extend_item_id,
        ROUND(v_hourly_rate * 1.5 * overtime_minutes / 60, 0)
    FROM overtime_record
    WHERE emp_id = p_emp_id
      AND DATE_FORMAT(work_date, '%Y-%m') = p_pay_ym
      AND approval_status = 'APPROVED'
      AND overtime_type = 'EXTEND';


    SET v_total_pay = v_total_pay + IFNULL((
        SELECT SUM(ROUND(v_hourly_rate * 1.5 * overtime_minutes / 60, 0))
        FROM overtime_record
        WHERE emp_id = p_emp_id
          AND DATE_FORMAT(work_date, '%Y-%m') = p_pay_ym
          AND approval_status = 'APPROVED'
          AND overtime_type = 'EXTEND'
    ), 0);

   
    INSERT INTO payslip_item (payslip_id, pay_item_id, amount)
    SELECT
        v_payslip_id, v_night_item_id,
        ROUND(v_hourly_rate * 2 * overtime_minutes / 60, 0)
    FROM overtime_record
    WHERE emp_id = p_emp_id
      AND DATE_FORMAT(work_date, '%Y-%m') = p_pay_ym
      AND approval_status = 'APPROVED'
      AND overtime_type = 'NIGHT';

   
    SET v_total_pay = v_total_pay + IFNULL((
        SELECT SUM(ROUND(v_hourly_rate * 2 * overtime_minutes / 60, 0))
        FROM overtime_record
        WHERE emp_id = p_emp_id
          AND DATE_FORMAT(work_date, '%Y-%m') = p_pay_ym
          AND approval_status = 'APPROVED'
          AND overtime_type = 'NIGHT'
    ), 0);

   
    INSERT INTO payslip_item (payslip_id, pay_item_id, amount)
    SELECT v_payslip_id, pi.pay_item_id, ROUND(v_base_salary * pi.calc_value / 100, 0)
    FROM pay_item pi
    WHERE pi.item_type = 'DEDUCT'
      AND pi.calc_type = 'RATE'
      AND pi.pay_item_code != 'ABSENCE_DEDUCT'
      AND pi.use_yn = 'Y';

    
    SELECT
        SUM(CASE WHEN s_in.status_code = 'ABSENT' OR s_out.status_code = 'ABSENT' THEN 1 ELSE 0 END),
        SUM(CASE WHEN s_in.status_code = 'LATE' THEN 1 ELSE 0 END),
        SUM(CASE WHEN s_out.status_code = 'EARLY' THEN 1 ELSE 0 END)
    INTO v_absence_count, v_late_count, v_early_count
    FROM attendance_record ar
    LEFT JOIN attendance_status s_in  ON ar.status_check_in  = s_in.status_id
    LEFT JOIN attendance_status s_out ON ar.status_check_out = s_out.status_id
    WHERE ar.emp_id = p_emp_id
      AND DATE_FORMAT(ar.work_date, '%Y-%m') = p_pay_ym;

    SET v_total_absence = v_absence_count + FLOOR((v_late_count + v_early_count)/2);


    SELECT pay_item_id
    INTO v_absence_item_id
    FROM pay_item
    WHERE pay_item_code = 'ABSENCE_DEDUCT'
      AND use_yn = 'Y'
    LIMIT 1;

    IF v_total_absence > 0 AND v_absence_item_id IS NOT NULL THEN
        INSERT INTO payslip_item (payslip_id, pay_item_id, amount)
        VALUES (v_payslip_id, v_absence_item_id, ROUND(v_base_salary * 0.05 * v_total_absence, 0));
    END IF;

  
    SELECT IFNULL(SUM(amount), 0)
    INTO v_total_deduct
    FROM payslip_item
    WHERE payslip_id = v_payslip_id
      AND pay_item_id IN (SELECT pay_item_id FROM pay_item WHERE item_type='DEDUCT');

   
    UPDATE payslip
    SET total_pay    = v_total_pay,
        total_deduct = v_total_deduct,
        net_pay      = ROUND(v_total_pay - v_total_deduct, 0),
        updated_at   = CURRENT_TIMESTAMP
    WHERE payslip_id = v_payslip_id;

    
    INSERT INTO payslip_access (payslip_id, failed_count)
    VALUES (v_payslip_id, 0);

    COMMIT;
END$$
DELIMITER ;

-- 급여 명세서 확정
DELIMITER $$
CREATE OR REPLACE PROCEDURE payslip_confirm (
    IN p_payslip_id BIGINT
)
BEGIN
    DECLARE v_status VARCHAR(20);

 
    SELECT status
      INTO v_status
      FROM payslip
     WHERE payslip_id = p_payslip_id;

  
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '존재하지 않는 급여 명세서입니다.';
    END IF;

 
    IF v_status = 'CONFIRMED' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 확정된 급여 명세서입니다.';
    END IF;


    UPDATE payslip
       SET status = 'CONFIRMED',
           confirmed_at = CURRENT_TIMESTAMP
     WHERE payslip_id = p_payslip_id;
END $$
DELIMITER ;

-- 급여 명세서 조회
DELIMITER $$
CREATE OR REPLACE PROCEDURE payslip_view_admin (
    IN p_payslip_id BIGINT
)
BEGIN
  
    IF NOT EXISTS (
        SELECT 1
        FROM payslip
        WHERE payslip_id = p_payslip_id
          AND status = 'CONFIRMED'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '확정된 급여 명세서만 조회할 수 있습니다';
    END IF;

    
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

   
    INSERT INTO payslip_access (payslip_id)
    VALUES (p_payslip_id)
    ON DUPLICATE KEY UPDATE
        updated_at = CURRENT_TIMESTAMP;

   
    SELECT SUBSTRING(jumin, 1, 6)
    INTO v_birth_pwd_db
    FROM employee
    WHERE emp_id = p_emp_id;

    
    SELECT failed_count, unlock_at
    INTO v_failed, v_unlock_at
    FROM payslip_access
    WHERE payslip_id = p_payslip_id
    FOR UPDATE;

 
    IF v_unlock_at IS NOT NULL AND v_unlock_at > NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '비밀번호 입력 실패로 잠금 상태입니다';
    END IF;

  
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
		  
		  
        COMMIT;
			
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '생년월일이 일치하지 않습니다';
    END IF;

   
    UPDATE payslip_access
    SET failed_count = 0,
        unlock_at = NULL,
        updated_at = CURRENT_TIMESTAMP
    WHERE payslip_id = p_payslip_id;

 
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
