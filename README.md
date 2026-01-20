
# HRCore_project📝
<p align="center">
  <img src="https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/WDQlogo.png?raw=true" width="500px">
</p>

<div align="center">
흩어진 HR 업무를 하나로 
효율을 높이는 통합 HR 관리 플랫폼
  
***HRCORE_project***

</div>

## 📌 목차
1. [👩‍👩‍👦 팀원 소개](#team)
2. [🗃️ 프로젝트 개요](#overview)
3. [📊 WBS](#wbs)
4. [📄 요구사항 명세서](#req)
5. [📉 유스케이스 다이어그램](#usecase)
6. [📟 ERD](#erd)
7. [📔 테이블 명세서](#table)
8. [💻 SQL 산출물](#sql)
9. [🛠️ 향후 확장방향](#future)
10. [🎯 회고록](#retrospective)
---

## 👩‍👩‍👦 팀원 소개 <a id="team"></a>
|![이미지 설명](https://search.pstatic.net/sunny/?src=https%3A%2F%2Fkr-cdn.spooncast.net%2Fprofiles%2Ff%2FArlDKfnn9Qrp%2F9f30c88d-9987-4443-be94-6345fb2dab13.jpg&type=sc960_832) |![이미지 설명](https://i.namu.wiki/i/4xQD4LBkRRW5MdrFZj6vsSTZsN8kd1q_H4uXLi5D06yVH-u8NFtgCDglmR9e_8D2WFlwV8xn1-m1BWAQy_1Epw.webp)|![이미지 설명](https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyMzEwMDJfMTk5%2FMDAxNjk2MjQzMDA1NzIz.bQTDDIsp-bjgE13OvFoRsDnNv0GkFU1fJ0KL3gwnykUg.srdYObvEBVywhc-rcqnBo7T6h_99H1HY0s-ZTSzO--Yg.JPEG.kywcreamkorea2%2Fe57d336fa20df4b2a021c58f39049057.jpg&type=sc960_832)|![이미지 설명](https://i.namu.wiki/i/5XTI4-4KzG1GDEwZVvFcwT-48vLagDBSB9bW8IZBYmtgAwaV3rnUKzSP9hM_D6j5DJSCPb9iRe7a5wYiPfOUZw.webp)|![이미지 설명](https://mblogthumb-phinf.pstatic.net/MjAxNzAyMDNfMTM4/MDAxNDg2MDUyMzIwNDQ3.3bXoZMTQgPxyuQsjGsVuq0M4NnfUHNOow0srviDo1mAg.S-AjxImiYSNULYn7P_WMSFxDOI8O_jDfJV6Tz_2PqWIg.JPEG.xenom/image_5529839161486050882902.jpg?type=w800)|![이미지 설명](https://i.namu.wiki/i/o81kFfad6uoV0sN0iGSqA3hEKyIniZUhP7VBq2dI3WeyOFalhAEa_lQ_SY0GEbC_oJ4qzLlKokalWFk6cx86vg.webp)|
|------------------------|------------------------|------------------------|------------------------|------------------------|------------------------|
|     팀장 박선우         |        김가영           |       조하은          |         허진호          |        이민경          |        이서윤          |
---
## 🗃️ 프로젝트 개요 <a id="overview"></a>

<p align="center">
  <img src="https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/background/background2.png?raw=true" width="900px">
</p>

조직 규모가 작을 경우 엑셀이나 간단한 문서 관리만으로도 인사 및 근태 관리가 가능하지만, 인원이 증가하고 조직 구조가 복잡해질수록 근무 유형, 휴가 정책, 급여 산정 기준 등 인사 제도 역시 다양해지며 기존의 수동적인 관리 방식은 한계에 도달하게 된다.
특히 중소기업의 경우 전용 HR 시스템 도입이 어려워 인사·근태·급여 관리가 엑셀이나 수기 문서에 의존하는 경우가 많으며, 이로 인해 데이터 중복 및 입력 오류, 정책 적용의 불일치, 인사 변경 이력 관리의 어려움과 같은 문제가 반복적으로 발생한다.

또한 인사 정보가 여러 파일과 문서로 분산되어 관리될 경우 인사 담당자의 수작업 부담이 증가하고, 근태·휴가·급여 산정 기준이 명확하게 관리되지 않아 조직 운영의 투명성과 신뢰성을 저하시킬 수 있다. 승인 절차나 정책 변경 이력을 체계적으로 추적하기 어려운 점 역시 인사 관리의 중요한 문제로 작용한다.

본 프로젝트는 이러한 문제를 해결하기 위해 인사·근태·휴가·급여 데이터를 하나의 시스템으로 통합 관리할 수 있는 HR 관리 시스템의 데이터베이스 구조를 설계·구현하는 것을 목표로 한다. HR 관련 데이터를 중앙 집중적으로 관리함으로써 데이터의 일관성과 정확성을 확보하고, 표준화된 인사 정책 및 업무 프로세스를 통해 효율적인 인사 관리 체계를 구축하고자 한다.

특히 승인 및 변경 이력 기반의 데이터 구조를 설계하여 인사 데이터의 투명성과 추적 가능성을 확보하고, 근속연수 기반 연차 산정, 급여 항목 집계 등 반복적인 관리 업무를 시스템적으로 자동화할 수 있는 기반을 마련한다. 또한 향후 조직 규모 확대, 인사 정책 변경, 급여·세무 등 HR 서비스 기능 확장에 유연하게 대응할 수 있도록 확장성과 유지보수성을 고려한 구조를 설계하는 것을 지향한다.

이를 통해 본 프로젝트는 단순한 인사 정보 관리 수준을 넘어, 중소기업 환경에 적합한 통합 HR 관리 시스템 설계 모델을 제시하고 향후 종합 HR 그룹웨어로 발전할 수 있는 기반을 마련하고자 한다.

[참고자료]

(https://www.hankyung.com/article/202309268924i?utm_source=chatgpt.com)

(https://www.talkspirit.com/blog/why-hr-digital-transformation-is-essential-in-modern-businesses?utm_source=chatgpt.com)

(https://en.wikipedia.org/wiki/Human_resource_management_system?utm_source)

(https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/background/background1.jpg?raw=true)




## 📊 WBS <a id="wbs"></a>
![WBS](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/WBS.png?raw=true)

## 📄 요구사항 정의서 <a id="req"></a>
![요구사항 정의서](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/%EC%9A%94%EA%B5%AC%EC%82%AC%ED%95%AD%20%EC%A0%95%EC%9D%98%EC%84%9C.png?raw=true)
[요구사항정의서](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9A%94%EA%B5%AC%EC%82%AC%ED%95%AD%EC%A0%95%EC%9D%98%EC%84%9C.pdf)

## 📉 유스케이스 다이어그램 <a id="usecase"></a>
![](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/%EC%9C%A0%EC%8A%A4%EC%BC%80%EC%9D%B4%EC%8A%A4.png.jpg?raw=true)
[유스케이스 다이어그램_근태](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/%EC%9C%A0%EC%8A%A4%EC%BC%80%EC%9D%B4%EC%8A%A4_%EA%B7%BC%ED%83%9C.jpg?raw=true)
[유스케이스 다이어그램_급여](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/%EC%9C%A0%EC%8A%A4%EC%BC%80%EC%9D%B4%EC%8A%A4_%EA%B8%89%EC%97%AC.jpg?raw=true)
[유스케이스 다이어그램_인사](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/%EC%9C%A0%EC%8A%A4%EC%BC%80%EC%9D%B4%EC%8A%A4_%EC%8B%9C%EC%8A%A4%ED%85%9C.png?raw=true)

## 📟 ERD <a id="erd"></a>
![ERD](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/ERD/erd_%EC%B5%9C%EC%A2%85.png?raw=true)
[ERD](https://www.erdcloud.com/d/hLqoWtFvg3D66TXxy)

## 📔 테이블 명세서 <a id="table"></a>
![테이블명세서](https://github.com/beyond-sw-camp/be25-1st-WDQ-HRCore/blob/main/%EC%9D%B4%EB%AF%B8%EC%A7%80%20%ED%8C%8C%EC%9D%BC/%ED%85%8C%EC%9D%B4%EB%B8%94%EB%AA%85%EC%84%B8%EC%84%9C.png?raw=true)
[테이블 명세서](https://docs.google.com/spreadsheets/d/1bMPiAibxTx_nkmMtBs_68mXrzGxFVBBJmr9qm585SD8/edit?gid=1688343712#gid=1688343712)

## 💻 SQL 산출물 <a id="sql"></a>
<details>
  <summary>📌DDL</summary>
  
   <details>
     <summary>📌 인사관리 시스템</summary>
      <details>
        <summary>employee</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>user</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>emp_status_history</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>department</summary>
        
```sql
CREATE TABLE department (
    dept_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    dept_code VARCHAR(20) NOT NULL UNIQUE,
    dept_name VARCHAR(50) NOT NULL,
    size INT NOT NULL DEFAULT 0,
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
  </details>   
  <details>
        <summary>department_change_history</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>job_position</summary>
        
```sql
CREATE TABLE job_position (
    position_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE,
    base_salary INT NOT NULL CHECK (base_salary >= 0),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
  </details>   
  <details>
        <summary>position_change_history</summary>
        
```sql
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
```
  </details>   
   </details>
   
   <details>
     <summary>📌 근태관리 시스템</summary>
      <details>
        <summary>attendnce_record</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>attendnce_status</summary>
        
```sql
CREATE TABLE attendance_status (
    status_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    status_code VARCHAR(20) NOT NULL UNIQUE,
    status_name VARCHAR(50) NOT NULL,
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
  </details>   
  <details>
        <summary>work_type</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>overtime_record</summary>
        
```sql
CREATE TABLE overtime_record (
    overtime_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    work_date DATE NOT NULL,
    overtime_minutes INT CHECK (overtime_minutes >= 0),
    reason TEXT,
    reject_reason TEXT,
    approval_status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    overtime_type VARCHAR(20),
    decided_by BIGINT ,
    decided_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (decided_by) REFERENCES employee(emp_id),
    CHECK (
      (approval_status = 'PENDING')
      OR
      (approval_status = 'APPROVED')
      OR
      (approval_status = 'REJECTED')
    )
);
```
  </details>   
  <details>
        <summary>leave_type</summary>
        
```sql
CREATE TABLE leave_type (
    leave_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    leave_type_name VARCHAR(50) NOT NULL UNIQUE,
    annual_max_days INT CHECK (annual_max_days >= 0),
    use_yn CHAR(1) NOT NULL DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
  </details>   
  <details>
        <summary>leave_history</summary>
        
```sql
CREATE TABLE leave_history (
    leave_history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    leave_request_id BIGINT NOT NULL UNIQUE,
    use_days DECIMAL(3,1) CHECK (use_days >= 0),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leave_request_id) REFERENCES leave_request(leave_request_id)
);
```
  </details>
  <details>
        <summary>leave_request</summary>
        
```sql
CREATE TABLE leave_request (
    leave_request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT NOT NULL,
    leave_type_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    reject_reason TEXT, 
    use_days DECIMAL(3,1) CHECK (use_days >= 0),
    approval_status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    approved_by BIGINT NULL,
    approved_at DATETIME NULL,
    rejected_by BIGINT NULL,
    rejected_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_type(leave_type_id),
    -- 승인/반려가 동시에 들어가면 안 됨(가능하면 DB에서 방지)
    CHECK (
      (approval_status = 'PENDING'  AND approved_at IS NULL AND rejected_at IS NULL)
      OR
      (approval_status = 'APPROVED' AND approved_at IS NOT NULL AND rejected_at IS NULL)
      OR
      (approval_status = 'REJECTED' AND rejected_at IS NOT NULL AND approved_at IS NULL)
    )
);
```
  </details>
  <details>
        <summary>leave_annual_policy</summary>
        
```sql
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
```
  </details>  
   </details>
   
   <details>
    <summary>📌 급여관리 시스템</summary>
     <details>
        <summary>payslip</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>payslip_item</summary>
        
```sql
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
```
  </details>   
  <details>
        <summary>payslip_access</summary>
        
```sql
CREATE TABLE payslip_access (
    payslip_access_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payslip_id BIGINT NOT NULL UNIQUE,
    failed_count INT DEFAULT 0 CHECK (failed_count >= 0),
    unlock_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payslip_id) REFERENCES payslip(payslip_id)
);
```
  </details>   
  <details>
        <summary>payslip_item</summary>
        
```sql
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
```
  </details>     
   </details>
  
</details>

<details>
  <summary>📌테스트쿼리</summary>

  <details>
     <summary>📌인사관리 시스템</summary>
  </details>
  <details>
     <summary>📌근태관리 시스템</summary>
  </details>
  <details>
    <summary>📌 급여관리 시스템</summary>
   <details>
        <summary>급여 항목 등록 프로시저</summary>

```sql
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
```
  </details>   
   <details>
        <summary> 급여 항목 기준값 수정 프로시저</summary>
     
```sql
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
```
  </details>   
   <details>
        <summary> 급여 항목 활성화 상태 변경 프로시저</summary>
     
```sql
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
```
 </details>   
   <details>
        <summary> 급여 명세서 생성 프로시저</summary>
     
```sql
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
```
  </details>   
   <details>
        <summary> 급여 명세서 확정 프로시저</summary>
     
```sql
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
```
  </details>   
   <details>
        <summary> 급여 명세서 조회 프로시저</summary>
     
```sql
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
```
  </details>   
   <details>
        <summary> 본인용 급여 명세서 프로시저</summary>
     
```sql
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
```
  </details>     
   </details>
  
</details>

<details>
  <summary>📌핵심 기능 테스트</summary>

  <details>
     <summary>📌인사관리 시스템</summary>
  </details>
  <details>
     <summary>📌근태관리 시스템</summary>
  </details>
  <details>
    <summary>📌 급여관리 시스템</summary>
   <details>
        <summary>급여 항목 등록 </summary>

```sql
-- 급여 항목 등록
CALL pay_item_create('BASE_SALARY','기본급','EARN','RULE',NULL,'Y');
CALL pay_item_create('HEALTH_INSURANCE','건강보험','DEDUCT','RATE',9.5,'N');
CALL pay_item_create('NATIONAL_PENSION','국민연금','DEDUCT','RATE',7.19,'N');
CALL pay_item_create('EMPLOYMENT_INSURANCE','고용보험','DEDUCT','RATE',1.8,'N');
CALL pay_item_create('INDUSTRIAL_ACCIDENT_INSURANCE','산재보험','DEDUCT','RATE',1.2,'N');
CALL pay_item_create('ABSENCE_DEDUCT','결근 공제','DEDUCT','RATE',5.0,'N');
CALL pay_item_create('OVERTIME_EXTEND','연장근무 수당','EARN','RULE',NULL,'Y');
CALL pay_item_create('OVERTIME_NIGHT','야간근무 수당','EARN','RULE',NULL,'Y');
```
  </details>   
   <details>
        <summary> 산재보험 요율 변경</summary>
     
```sql
-- 산재보험 요율 변경
CALL pay_item_update_value('INDUSTRIAL_ACCIDENT_INSURANCE',1.25);
```
  </details>   
   <details>
        <summary> 산재보험 활성화 상태 변경</summary>
     
```sql
-- 산재보험 활성화 상태 변경
CALL pay_item_toggle_use('INDUSTRIAL_ACCIDENT_INSURANCE','Y');
```
 </details>   
   <details>
        <summary> 급여 명세서 생성 </summary>
     
```sql
-- 급여 명세서 생성
CALL payslip_create(3, '2026-01');
```
  </details>   
   <details>
        <summary> 급여 명세서 확정 </summary>
     
```sql
-- 급여 명세서 확정
CALL payslip_confirm(10);
```
  </details>   
   <details>
        <summary> 급여 명세서 조회 </summary>
     
```sql
-- 급여 명세서 조회
CALL payslip_view_admin(10);
```
  </details>   
   <details>
        <summary> 본인용 급여 명세서</summary>
     
```sql
-- 본인용 급여 명세서
CALL payslip_view_self(1, 1, '850814');
```
  </details>     
   </details>
  
</details>


## 🛠️ 향후 확장 방향 <a id="future"></a>

본 프로젝트는 HR 데이터의 통합 관리와 표준화된 업무 프로세스를 중심으로 HR 관리 시스템의 데이터베이스 구조를 설계하였다. 다만, 실제 운영 환경에 적용하기 위해서는 기능적·구조적 측면에서 다음과 같은 개선 및 확장 방향을 고려할 수 있다.

**1. HR 업무 자동화 기능 고도화**

현재 시스템은 승인 상태 및 변경 이력 관리가 가능한 구조를 기반으로 설계되었으나, 향후에는 근속연수에 따른 연차 자동 산정, 초과 근무 시간 집계, 급여 항목 자동 계산 등 반복적인 HR 업무를 시스템적으로 처리할 수 있도록 자동화 로직을 강화할 수 있다. 이를 통해 인사 담당자의 수작업 부담을 줄이고 데이터 처리의 정확성과 신뢰성을 더욱 향상시킬 수 있다.

**2. 역할 및 권한 기반 접근 제어(RBAC) 확장**

현 설계는 관리자 및 HR 담당자를 중심으로 한 권한 구조를 가정하고 있으나, 향후에는 일반 사원, 팀장, 관리자 등 사용자 역할에 따라 조회·입력·수정·승인 권한을 세분화하는 역할 기반 접근 제어(RBAC)를 도입할 수 있다. 이를 통해 인사 정보의 보안성을 강화하고 조직 내 권한 체계를 보다 명확하게 관리할 수 있다.

**3. 모듈화 기반 시스템 확장성 강화**

조직 규모 확대나 인사 정책 변경에 유연하게 대응하기 위해 평가 관리, 교육 이력 관리, 인사 발령 관리 등 추가적인 HR 기능을 독립적인 모듈 형태로 확장할 수 있는 구조로 발전시킬 수 있다. 이러한 모듈화 설계는 다양한 조직 환경에 적용 가능한 범용 HR 플랫폼으로의 확장을 가능하게 한다.

**4. 통계 및 분석 기능을 통한 의사결정 지원**

근태 현황, 휴가 사용 패턴, 부서별 인력 운영 현황 등을 분석하여 시각화된 통계 정보로 제공한다면, 관리자는 데이터 기반의 인사 전략 수립 및 인력 운영 의사결정을 보다 효율적으로 수행할 수 있을 것이다. 이를 통해 본 시스템은 단순 관리 도구를 넘어 의사결정 지원 시스템으로 발전할 수 있다.

**5. 외부 시스템 연계를 통한 활용 범위 확장**

급여 시스템, 회계 시스템, 전자결재 시스템 등 외부 시스템과의 연계를 통해 HR 데이터의 활용 범위를 확장할 수 있다. 이를 통해 조직 전반의 업무 흐름을 통합 관리할 수 있는 기반을 마련하고, HR 시스템의 실무 활용도를 더욱 높일 수 있다.

## 🎯회고록 <a id="retrospective"></a>

#### 🐨박선우(팀장) :
#### 🐶김가영 :
#### 🐵조하은 :
#### 🐱이민경 :
#### 🐸허진호 :
#### 🐰이서윤 :


