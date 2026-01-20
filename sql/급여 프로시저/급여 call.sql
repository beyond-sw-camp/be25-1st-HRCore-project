-- 급여 항목 등록
CALL pay_item_create('BASE_SALARY','기본급','EARN','RULE',NULL,'Y');
CALL pay_item_create('HEALTH_INSURANCE','건강보험','DEDUCT','RATE',9.5,'N');
CALL pay_item_create('NATIONAL_PENSION','국민연금','DEDUCT','RATE',7.19,'N');
CALL pay_item_create('EMPLOYMENT_INSURANCE','고용보험','DEDUCT','RATE',1.8,'N');
CALL pay_item_create('INDUSTRIAL_ACCIDENT_INSURANCE','산재보험','DEDUCT','RATE',1.2,'N');
CALL pay_item_create('ABSENCE_DEDUCT','결근 공제','DEDUCT','RATE',5.0,'N');
CALL pay_item_create('OVERTIME_EXTEND','연장근무 수당','EARN','RULE',NULL,'Y');
CALL pay_item_create('OVERTIME_NIGHT','야간근무 수당','EARN','RULE',NULL,'Y');

-- 산재보험 요율 변경
CALL pay_item_update_value('INDUSTRIAL_ACCIDENT_INSURANCE',1.25);

-- 산재보험 활성화 상태 변경
CALL pay_item_toggle_use('INDUSTRIAL_ACCIDENT_INSURANCE','Y');

-- 급여 명세서 생성
CALL payslip_create(3, '2026-01');


-- 급여 명세서 확정
CALL payslip_confirm(10);

-- 급여 명세서 조회
CALL payslip_view_admin(10);

-- 본인용 급여 명세서
CALL payslip_view_self(1, 1, '850814');
