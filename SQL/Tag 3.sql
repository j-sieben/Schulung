-- Fallunterscheidungen
-- einfache Falluntescheidung
select emp_id, emp_last_name, emp_job_id, emp_salary,
       case substr(emp_job_id, 4)
         when 'CLERK' then emp_salary + 50
         when 'MAN' then emp_salary * 1.04
         when 'MGR' then emp_salary * 1.05
       else emp_salary * 1.03 end new_salary
  from hr_employees;
  
-- Oracle-proprietär
select emp_id, emp_last_name, emp_job_id, emp_salary,
       decode(substr(emp_job_id, 4),
         'CLERK', emp_salary + 50,
         'MAN', emp_salary * 1.04,
         'MGR', emp_salary * 1.05,
         emp_salary * 1.03) new_salary
  from hr_employees;
  
-- auswertende Fallunterscheidung
select emp_id, emp_last_name, emp_job_id, emp_salary,
       case 
         when substr(emp_job_id, 4) = 'CLERK' and emp_salary > 3000 then emp_salary + 50
         when substr(emp_job_id, 4) = 'CLERK' then emp_salary + 120
         when emp_hire_date < date '2004-01-01' then emp_salary * 1.04
         when substr(emp_job_id, 4) = 'MGR' then emp_salary * 1.05
       else emp_salary * 1.03 end new_salary
  from hr_employees;


-- Analytische Funktionen
select emp_last_name, emp_dep_id, emp_salary,
       sum(emp_salary) over (partition by emp_dep_id order by emp_salary, emp_last_name) cum_dept_sal,
       sum(emp_salary) over (order by emp_dep_id, emp_salary, emp_last_name) cum_sal,
       round(ratio_to_report(emp_salary) over (partition by emp_dep_id) * 100, 2) pct_dept_sal,
       round(ratio_to_report(emp_salary) over () * 100, 2) pct_sal,
       emp_salary - lag(emp_salary) over (partition by emp_dep_id order by emp_salary, emp_last_name) diff_dept_sal
  from hr_employees
 order by emp_dep_id, emp_salary, emp_last_name;


select emp_dep_id, substr(emp_job_id, 4) emp_job_group, sum(emp_salary) sum_sal,
       sum(sum(emp_salary)) over (partition by emp_dep_id) dept_salary,
       sum(sum(emp_salary)) over (partition by substr(emp_job_id, 4)) job_salary,
       sum(sum(emp_salary)) over () tot_salary,
       rank() over (order by sum(emp_salary) desc) dept_sal_rank
  from hr_employees
 where emp_dep_id is not null
 group by emp_dep_id, substr(emp_job_id, 4)
 order by emp_dep_id, substr(emp_job_id, 4);


select aktie, handelstag, schlusskurs,
       avg(schlusskurs) over (
         partition by aktie
         order by handelstag
         range between interval '30' day preceding and current row) kurs_30_tage,
       avg(schlusskurs) over (
         partition by aktie
         order by handelstag
         range between interval '200' day preceding and current row) kurs_200_tage
  from aktienkurse;


-- Datenmanipulation (DML), Rechtesituation
insert into hr_employees (emp_id, emp_first_name, emp_last_name, emp_email, emp_phone_number, emp_dep_id,
                          emp_hire_date, emp_job_id, emp_salary, emp_commission_pct, emp_mgr_id, emp_is_manager) 
values (300, 'Willi', 'Müller', 'WMUELLER', '123.456.789', 50,
        trunc(sysdate), 'IT_PROG', 3500, null, 105, 'N');

insert into hr_employees (emp_id, emp_first_name, emp_last_name, emp_email, emp_phone_number, emp_dep_id,
                          emp_hire_date, emp_job_id, emp_salary, emp_commission_pct, emp_mgr_id, emp_is_manager) 
select 300 emp_id, 'Willi' emp_first_name, 'Müller', 'WMUELLER', '123.456.789', 50,
       trunc(sysdate), 'IT_PROG', 3500, null, (select emp_id from hr_employees where emp_last_name = 'Pataballa'), 'N'
  from dual
union all
select 301 emp_id, 'Peter' emp_first_name, 'Schmitz', 'PSCHMITZ', '123.456.790', 50,
       trunc(sysdate), 'IT_PROG', 3500, null, 105, 'N'
  from dual;

update hr_employees
   set emp_last_name = upper(emp_last_name),
       emp_first_name = upper(emp_first_name)
 where emp_dep_id = 30;
 
select *
  from hr_employees
 where emp_dep_id = 30;
       
select *
  from hr_employees;

delete from hr_employees
 where emp_dep_id = 30;
