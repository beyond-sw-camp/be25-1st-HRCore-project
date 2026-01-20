CREATE TABLE department (
    dept_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    dept_code VARCHAR(20) NOT NULL UNIQUE,
    dept_name VARCHAR(50) NOT NULL,
    size INT NOT NULL DEFAULT 0,
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE job_position (
    position_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE,
    base_salary INT NOT NULL CHECK (base_salary >= 0),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE work_type (
    work_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    work_type_code VARCHAR(20) NOT NULL UNIQUE,
    work_type_name VARCHAR(50) NOT NULL,
    start_time TIME,
    end_time TIME,
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attendance_status (
    status_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    status_code VARCHAR(20) NOT NULL UNIQUE,
    status_name VARCHAR(50) NOT NULL,
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leave_type (
    leave_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    leave_type_name VARCHAR(50) NOT NULL UNIQUE,
    annual_max_days INT CHECK (annual_max_days >= 0),
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leave_annual_policy (
    leave_annual_policy_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    leave_type_id BIGINT NOT NULL REFERENCES leave_type(leave_type_id),       
    min_years INT NOT NULL,              
    max_years INT NOT NULL,              
    annual_max_days INT NOT NULL,        
    use_yn CHAR(1) NOT NULL DEFAULT 'Y',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP  
);

CREATE TABLE pay_item (
    pay_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pay_item_code VARCHAR(30) NOT NULL UNIQUE,
    pay_item_name VARCHAR(100) NOT NULL,
    item_type VARCHAR(10) NOT NULL CHECK (item_type IN ('EARN','DEDUCT')),
    calc_type VARCHAR(10) NOT NULL CHECK (calc_type IN ('FIX','RATE','RULE')),
    calc_value DECIMAL(10,2),
    tax_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (tax_yn IN ('Y','N')),
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employee (
    emp_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    dept_id BIGINT,
    position_id BIGINT,
    email VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(20) NOT NULL,
    tel VARCHAR(20) UNIQUE,
    jumin VARCHAR(20) UNIQUE,
    bank_name VARCHAR(20),
    bank_account VARCHAR(30) UNIQUE,
    hire_date DATE NOT NULL,
    `status` VARCHAR(10) NOT NULL DEFAULT '재직' CHECK (status IN ('재직','휴직','퇴직')),
    resign_date DATE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    FOREIGN KEY (position_id) REFERENCES `job_position`(position_id)
);

CREATE TABLE user (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT,
    username VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` VARCHAR(20) NOT NULL DEFAULT 'USER',
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE department_change_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    dept_id BIGINT NOT NULL,
    admin_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    FOREIGN KEY (admin_id) REFERENCES `user`(user_id)
);

CREATE TABLE position_change_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    position_id BIGINT NOT NULL,
    admin_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (position_id) REFERENCES `job_position`(position_id),
    FOREIGN KEY (admin_id) REFERENCES `user`(user_id)
);

CREATE TABLE emp_status_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    admin_id BIGINT NOT NULL,
    change_status VARCHAR(10) NOT NULL,
    reason TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (admin_id) REFERENCES `user`(user_id)
);

CREATE TABLE attendance_record (
    attendance_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    work_type_id BIGINT,
    status_check_in BIGINT,
    status_check_out BIGINT,
    work_date DATE NOT NULL,
    check_in_time DATETIME,
    check_out_time DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (work_type_id) REFERENCES work_type(work_type_id),
    FOREIGN KEY (status_check_in) REFERENCES attendance_status(status_id),
    FOREIGN KEY (status_check_out) REFERENCES attendance_status(status_id),
    UNIQUE (emp_id, work_date)
);

CREATE TABLE overtime_record (
    overtime_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    work_date DATE NOT NULL,
    overtime_minutes INT CHECK (overtime_minutes >= 0),
    approval_status VARCHAR(20),
    approved_at DATETIME,
    overtime_type VARCHAR(20),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE leave_request (
    leave_request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    leave_type_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    use_days DECIMAL(3,1) CHECK (use_days >= 0),
    approval_status VARCHAR(20),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_type(leave_type_id)
);

CREATE TABLE leave_history (
    leave_history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    leave_request_id BIGINT NOT NULL UNIQUE,
    use_days DECIMAL(3,1) CHECK (use_days >= 0),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leave_request_id) REFERENCES leave_request(leave_request_id)
);

CREATE TABLE payslip (
    payslip_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    pay_ym CHAR(7) NOT NULL,
    total_pay DECIMAL(12,0),
    total_deduct DECIMAL(12,0),
    net_pay DECIMAL(12,0),
    `status` VARCHAR(15),
    confirmed_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (emp_id, pay_ym),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE payslip_item (
    payslip_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payslip_id BIGINT NOT NULL,
    pay_item_id BIGINT NOT NULL,
    amount DECIMAL(12,0),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payslip_id) REFERENCES payslip(payslip_id),
    FOREIGN KEY (pay_item_id) REFERENCES pay_item(pay_item_id)
);

CREATE TABLE payslip_access (
    payslip_access_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payslip_id BIGINT NOT NULL UNIQUE,
    failed_count INT DEFAULT 0 CHECK (failed_count >= 0),
    unlock_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payslip_id) REFERENCES payslip(payslip_id)
);