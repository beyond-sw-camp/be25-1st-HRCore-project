-- 사원 등록
CALL register_employee_with_user('admin01.dev@company.com','인사담당자01','010-2345-5678','850814-1358901','신한','317-6688-415622','2021-02-05');
CALL register_employee_with_user('test01.dev@company.com','테스트사원01','010-1275-5378','960105-1653427','국민','127-2589-413677','2024-02-04');
CALL register_employee_with_user('test02.dev@company.com','테스트사원02','010-1375-5778','950104-1653427','농협','137-2589-413677','2023-02-04');
CALL register_employee_with_user('test03.dev@company.com','테스트사원03','010-1475-5778','940104-1653427','하나','157-2589-413677','2022-02-04');
CALL register_employee_with_user('test04.dev@company.com','테스트사원04','010-1575-5778','930104-1653427','우리','167-2589-413677','2021-02-04');

-- 사원의 이메일이 변경될 시 (트랜잭션 발생)
CALL update_employee_info(5,'test04_update.dev@company.com','테스트사원05','010-1234-5678',NULL,NULL,NULL,NULL);
-- 사원의 연락처 + 계좌만 변경될 시 (트랜잭션 미발생)
CALL update_employee_info(2,NULL,NULL,'010-9999-8888',NULL,NULL,'국민은행','123-456-789012');

CALL emp_leave(2,2,'개인 사유로 인한 휴직');

CALL emp_return(2,2,'휴직 종료 및 복직');

CALL emp_retire(5,2,'정년 퇴직');

CALL emp_assign_department(1,1,1);
CALL emp_assign_department(2,1,2);

CALL emp_change_department(2,2,2);

CALL emp_assign_position(1,4,1);
CALL emp_assign_position(2,2,2);
CALL emp_assign_position(3,2,2);

CALL promote_employee(3, 2);
