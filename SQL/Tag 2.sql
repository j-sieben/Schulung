-- Gruppenfunktionen
select count(*) as anzahl,
       sum(emp_salary) as gehalts_summe,
       median(emp_salary) as gehalts_median,
       max(emp_salary) gehalts_maximum,
       min(emp_salary) gehalts_minimum
  from hr_employees;
  
  
select listagg(emp_id, ', ') within group (order by emp_id) emp_list
  from hr_employees;
  
  
select emp_dep_id,
       count(*) as anzahl,
       sum(emp_salary) as gehalts_summe,
       median(emp_salary) as gehalts_median,
       max(emp_salary) gehalts_maximum,
       min(emp_salary) gehalts_minimum
  from hr_employees
 where emp_dep_id is not null
 group by emp_dep_id;
 
  
select emp_dep_id, substr(emp_job_id, 4),
       count(*) as anzahl,
       sum(emp_salary) as gehalts_summe,
       median(emp_salary) as gehalts_median,
       max(emp_salary) gehalts_maximum,
       min(emp_salary) gehalts_minimum
  from hr_employees
 where emp_dep_id is not null
 group by substr(emp_job_id, 4), emp_dep_id;
 

-- Wer verdient am wenigsten?
-- Falsche Lösung:
select emp_last_name, min(emp_salary) as mindestgehalt, count(*) as anzahl
  from hr_employees
 group by emp_last_name;
 

-- Gruppenfunktionen ignorieren NULL-Werte
select avg(emp_commission_pct)
  from hr_employees;

select count(*), count(emp_dep_id), count(distinct emp_job_id), count(emp_commission_pct)
  from hr_employees;

select emp_dep_id, count(*), count(emp_dep_id), count(distinct emp_job_id), count(emp_commission_pct)
  from hr_employees
 group by emp_dep_id;

-- Alle Abteilungen und die Anzahl der in ihnen arbeitenden Mitarbeiter
select dep_id, count(emp_id)
  from hr_departments
  left join hr_employees
    on dep_id = emp_dep_id
 group by dep_id;
 
 
-- Gehaltssumme und Durchschnittsgehalt pro Berufsgruppe
select substr(emp_job_id, 4), count(*), sum(emp_salary), round(avg(emp_salary), 2)
  from hr_employees
 group by substr(emp_job_id, 4);
 
 
-- Wie hoch ist die Gehaltssumme pro Abteilung mit Mitarbeitern, geben Sie den Namen der Abteilung und die Summe an.
select dep_id, dep_name, coalesce(sum(emp_salary), 0) as gehaltssumme
  from hr_departments
  left join hr_employees
    on dep_id = emp_dep_id
 group by dep_id, dep_name;
 

-- Mehrere Gruppierungen in einer Abfrage (nach Anteilung und Berufsgruppe)
select emp_dep_id, substr(emp_job_id, 4),
       count(*) as anzahl,
       sum(emp_salary) as gehalts_summe,
       median(emp_salary) as gehalts_median,
       max(emp_salary) gehalts_maximum,
       min(emp_salary) gehalts_minimum
  from hr_employees
 where emp_dep_id is not null
 group by emp_dep_id, substr(emp_job_id, 4)
 order by emp_dep_id, substr(emp_job_id, 4);
 

-- Zusätzliche Gruppierungen über ROLLUP und CUBE
select emp_dep_id, substr(emp_job_id, 4),
       count(*) as anzahl,
       sum(emp_salary) as gehalts_summe,
       median(emp_salary) as gehalts_median,
       max(emp_salary) gehalts_maximum,
       min(emp_salary) gehalts_minimum,
       grouping(emp_dep_id) dep_group,
       grouping(substr(emp_job_id, 4)) job_group
  from hr_employees
 where emp_dep_id is not null
 group by rollup(emp_dep_id, substr(emp_job_id, 4))
 order by emp_dep_id, substr(emp_job_id, 4);
 
 
select emp_dep_id, substr(emp_job_id, 4),
       count(*) as anzahl,
       sum(emp_salary) as gehalts_summe,
       median(emp_salary) as gehalts_median,
       max(emp_salary) gehalts_maximum,
       min(emp_salary) gehalts_minimum,
       grouping(emp_dep_id) dep_group,
       grouping(substr(emp_job_id, 4)) job_group
  from hr_employees
 where emp_dep_id is not null
 group by cube(substr(emp_job_id, 4), emp_dep_id)
 order by emp_dep_id, substr(emp_job_id, 4);
 

-- Durchschnittgeshälter aller Mitarbeiter je Abteilung, Durchschnittsgehalt aller Mitarbeiter
select emp_dep_id, round(avg(emp_salary), 2) as avg_sal, grouping(emp_dep_id) ist_gruppierung
  from hr_employees
 where emp_dep_id is not null
 group by rollup(emp_dep_id);
 
 
-- Filtern von Gruppenfunktionen
-- Zeige alle Abteilungen mit einem Durchschnittsgehalt von über 9000 Talern
select emp_dep_id, round(avg(emp_salary), 2) avg_salary
  from hr_employees
 where emp_dep_id is not null
 group by emp_dep_id
having avg(emp_salary) > 6000;


-- Unterabfragen
-- 1. Skalare Unterabfrage

-- Wer verdient am wenigsten?
-- 2 Fagen: 
-- - Wie hoch ist das Mindestgehalt
-- - Wer verdient es?
select min(emp_salary) min_sal
  from hr_employees;
  
select *
  from hr_employees
 where emp_salary = 2100;
  
select *
  from hr_employees
 where emp_salary = (
       select min(emp_salary) min_sal
         from hr_employees);
  
select *
  from hr_employees
 where emp_salary > (
       select avg(emp_salary) avg_sal
         from hr_employees);
 
select (select min(emp_salary) from hr_employees) min_sal
  from hr_employees;
  
select dbms_random.value random_val, (select dbms_random.value from dual) rnd_val
  from hr_employees;
  

-- Wer verdient am wenigsten in seiner Abteilung?
select emp_dep_id, emp_salary, 
       (select min(emp_salary) from hr_employees m where m.emp_dep_id = e.emp_dep_id) min_sal
  from hr_employees e
 order by emp_dep_id;
 
 
select *
  from hr_employees e
 where emp_salary = (
       select min(emp_salary) 
         from hr_employees m 
        where m.emp_dep_id = e.emp_dep_id);
 

-- 2. Unterabfrage, die eine Liste von Werten liefert
-- Wer gehört zu einer Berufsgruppe, die es in Abteilung 30 gibt, selbst aber nicht dort arbeitet?
select substr(emp_job_id, 4)
  from hr_employees
 where emp_dep_id = 30;

select *
  from hr_employees
 where emp_dep_id != 30
   and substr(emp_job_id, 4) in (
       select substr(emp_job_id, 4)
         from hr_employees
        where emp_dep_id = 30);
        
        
-- 3. Unterabfrage, die mehrere Spalten und mehrere Zeilen liefert
-- Erste Lösung:
-- Wer verdient in seiner Abteilung am wenigsten?
select *
  from hr_employees e
 where emp_salary = (
       select min(emp_salary) 
         from hr_employees m 
        where m.emp_dep_id = e.emp_dep_id);


-- Zweite Lösung:
select emp_dep_id as dep_id, min(emp_salary) min_salary, round(avg(emp_salary), 2) avg_salary
  from hr_employees
 where emp_dep_id is not null
 group by emp_dep_id;
 
 
select *
  from hr_employees e
  join (select emp_dep_id as dep_id, min(emp_salary) min_salary, round(avg(emp_salary), 2) avg_salary
          from hr_employees
         group by emp_dep_id) d
    on e.emp_dep_id = d.dep_id
 where e.emp_salary > d.avg_salary;
 

-- Auslagerung der Unterabfrage vor die Abfrage
with hr_dept_salaries as (
       select emp_dep_id as dep_id, min(emp_salary) min_salary, round(avg(emp_salary), 2) avg_salary
         from hr_employees
        where emp_dep_id is not null
        group by emp_dep_id),
     hr_job_salaries as (
       select substr(emp_job_id, 4) as job_id, min(emp_salary) min_salary, round(avg(emp_salary), 2) avg_salary
         from hr_employees
        where emp_dep_id is not null
        group by substr(emp_job_id, 4))
select *
  from hr_employees
  join hr_dept_salaries
    on emp_dep_id = dep_id
 where emp_salary > avg_salary;   
 
 
-- Ablage der Unterabfrage als View in der Datenbank
create or replace view hr_dept_salaries as 
select emp_dep_id as dep_id, min(emp_salary) min_salary, round(avg(emp_salary), 2) avg_salary
  from hr_employees
 where emp_dep_id is not null
 group by emp_dep_id;
  
  
select *
  from hr_employees
  join hr_dept_salaries
    on emp_dep_id = dep_id
 where emp_salary > avg_salary;
 

create materialized view hr_dept_salaries_mv
  refresh complete on demand
 start with sysdate
  next trunc(sysdate) + interval '1' day
as
select emp_dep_id as dep_id, min(emp_salary) min_salary, round(avg(emp_salary), 2) avg_salary
  from hr_employees
 where emp_dep_id is not null
 group by emp_dep_id;
 
begin
  dbms_refresh.refresh('"HR"."HR_DEPT_SALARIES_MV"');
end;
/

select *
  from hr_dept_salaries_mv;
  

-- Zeige alle Abteilungen mit mindestens drei Mitarbeitern
select dep_id, dep_name, count(*) anzahl
  from hr_employees
  join hr_departments
    on emp_dep_id = dep_id
 group by dep_id, dep_name
having count(*) >= 3;


-- TOP-n-Analyse: Zeige die 5 bestverdienenden Mitarbeiter
-- Schlechteste Lösung: Einfache Sortierung der Tabelle
select emp_id, emp_last_name, emp_salary
  from hr_employees
 order by emp_salary desc;


-- Besser: Einschränkung auf 5 Zeilen, damit Order by Stopkey-Verfahren genutzt werden kann
select *
  from (select emp_id, emp_last_name, emp_salary
          from hr_employees
         order by emp_salary desc)
 where rownum < 6;


-- Nochmals besser: Vermeidung der Sortierung durch analytische Funktion
select *
  from (select emp_id, emp_last_name, emp_salary,
               row_number() over (order by emp_salary desc) sal_rank
          from hr_employees)
 where sal_rank < 6;
 
 
-- Modernere Syntax: Fetch-Rows-Klausel ab Version 12c
select emp_id, emp_last_name, emp_salary
  from hr_employees
 order by emp_salary desc
 fetch first 5 rows only;


-- Datumsverarbeitung
-- Datum ist eine Binärstruktur, die für den Benutzer aufbereitet dargestellt wird
select emp_hire_date, dump(emp_hire_date)
  from hr_employees;
  
select sysdate
  from dual;
  
-- Umwandlung in eine Zeichenkette ist ein Downcycling und sollte stets vermieden werden
select emp_hire_date, to_char(emp_hire_date, 'dd.mm.yyyy hh24:mi:ss') datum
  from hr_employees
 order by emp_hire_date;
 
-- Wie viele Mitarbeiter wurden pro Quartal eingestellt?
select to_char(emp_hire_date, 'Q/YYYY') quartal, count(*) anzahl
  from hr_employees
 group by to_char(emp_hire_date, 'Q/YYYY')
 order by quartal;
 

-- Vergröberung eines Datums mittels Abrunden
select round(12345.789, -1), trunc(12345.789, -3)
  from dual;

select sysdate, trunc(sysdate, 'Y') -- MI, HH, DD, IW, Q und Y
  from dual;
  
select trunc(emp_hire_date, 'Q') quartal, count(*) anzahl
  from hr_employees
 group by trunc(emp_hire_date, 'Q')
 order by quartal;
 

-- ISO-Datumsformat: 2023-08-09 15:49:39
select date '2023-05-13',
       timestamp '2023-05-13 10:00:00 Europe/Berlin',
       interval '09 15:49:39' day to second intervall
  from dual;
  
select interval '10:00' hour to minute,
       interval '1' second
  from dual;


select trunc(sysdate, 'IW') - interval '7' day woche_von,
       trunc(sysdate, 'IW') - interval '1' second woche_bis,
       trunc(sysdate, 'MM') - interval '1' month monat_von,
       trunc(sysdate, 'MM') - interval '1' second monat_bis
  from dual;
  
-- Wie alt ist ein Kunde?
select trunc(months_between(sysdate, date '2005-08-10') / 12) kunde_alter
  from dual;
  
select emp_hire_date, next_day(add_months(emp_hire_date, 6), 'MON') - interval '11' hour
  from hr_employees;
  
select last_day(trunc(sysdate))
  from dual;
