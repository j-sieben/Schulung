-- Grundlagen von SQL
select *
  from hr_employees;
  
select *
  from hr_departments;

-- Projektion
select emp_job_id, emp_first_name, emp_last_name
  from hr_employees;
  
select emp_id, emp_id
  from hr_employees;
  
select emp_id, emp_last_name
  from hr_employees e;
  
-- Ausgabe von Konstanten statt Spaltenwerten
select 17, 'Willi'
  from hr_departments;
  
select emp_first_name || ' ' || emp_last_name as mitarbeiter
  from hr_employees;
  
select 'cp E:\' || emp_first_name || '\' || emp_last_name || ' C:\Briefe\' || emp_last_name || '.doc'
  from hr_employees;

-- Filtern über die WHERE-Klausel
select *
  from hr_employees
 where emp_dep_id = 30;

select *
  from hr_employees
 where emp_dep_id != 30;

select *
  from hr_employees
 where emp_dep_id is null;

select *
  from hr_employees
 where emp_dep_id is null
   and emp_last_name = 'Grant';
   
-- Verwendung von OR und AND: Klammern setzen!
select *
  from hr_employees
 where (emp_job_id = 'AD_VP'
    or emp_job_id = 'AD_PRES')
   and emp_salary > 17000;
   
-- IN-Operator
select *
  from hr_employees
 where emp_job_id in ('AD_VP', 'AD_PRES')
   and emp_salary > 17000;

-- Diskussion: NULL-Wert in Wertelisten
select *
  from hr_employees
 where emp_job_id in ('AD_VP', 'AD_PRES');
 
select *
  from hr_employees
 where emp_job_id not in ('AD_VP', 'AD_PRES');

select *
  from hr_employees
 where emp_job_id in ('AD_VP', 'AD_PRES', null);
 
select *
  from hr_employees
 where emp_job_id not in ('AD_VP', 'AD_PRES', null);

/*
  a or b or null
  not(a or b or null) <=> not and not b and not null
*/

-- Zeilenfunktionen: Funktionen für Zeichenketten
select upper(emp_first_name) as vorname, 
       lower(emp_last_name) as nachname,
       initcap(emp_email) as email
  from hr_employees
 where emp_last_name = 'Pataballa';
 

select upper(emp_first_name) as vorname, 
       lower(emp_last_name) as nachname,
       initcap(emp_email) as email
  from hr_employees
 where lower(emp_last_name) = lower('PaTabaLLa');


select mitarbeiter, position,
       substr(mitarbeiter, 1, position - 1) vorname,
       substr(mitarbeiter, position + 2) nachname
  from namen;
  

-- Joins
-- Inner Join
select *
  from hr_employees
  join hr_departments
    on emp_dep_id = dep_id;
    
    
-- Oracle-proprietär, sollte nicht mehr verwendet werden
select *
  from hr_employees, hr_departments
 where emp_dep_id = dep_id;


-- Outer Join
select *
  from hr_employees 
  left join hr_departments
    on emp_dep_id = dep_id;


select *
  from hr_departments
  left join hr_employees
    on dep_id = emp_dep_id;
    
    
select *
  from hr_employees
  join hr_jobs
    on emp_job_id = job_id
  left join hr_departments
    on emp_dep_id = dep_id;


-- Oracle proprietäre Schreibweise
select *
  from hr_departments, hr_employees
 where dep_id = emp_dep_id (+);
 

-- Exotischere Joins
-- FULL-Join (Outer Join für beide Tabellen
select *
  from hr_employees
  full join hr_departments
    on emp_dep_id = dep_id;


-- Kartesisches Produkt
select *
  from hr_employees
 cross join hr_departments;
 

-- "Anti"-Join
select *
  from hr_employees
  full join hr_departments
    on emp_dep_id = dep_id
 where dep_id is null
    or emp_id is null;
    

-- Semi-Join
select *
  from hr_departments
 where exists (
       select null
         from hr_employees
        where emp_dep_id = dep_id);


-- Aufgaben
-- Wer arbeitet in Deutschland?
select emp_id as mitarbeiternummer,
       emp_first_name || ', ' || emp_last_name as mitarbeiter, 
       dep_name as abteilung, 
       loc_city as ort
  from hr_employees
  join hr_departments
    on emp_dep_id = dep_id
  join hr_locations
    on dep_loc_id = loc_id
  join hr_countries
    on loc_cou_id = cou_id
 where cou_name = 'Germany';
 

-- Zeigen Sie _alle_ Mitarbeiter, die Berufsbezeichnung und den Namen der Abteilung
-- zeigen Sie nur Mitarbeiter mit einem Gehalt größer 5000 Taler
select *
  from hr_employees
  join hr_jobs
    on emp_job_id = job_id
  left join hr_departments
    on emp_dep_id = dep_id
 where emp_salary > 5000;


-- Zeige alle Abteilungen, in denen Mitarbeiter arbeiten
-- 1. Lösung
select distinct dep_id, dep_name
  from hr_departments
  join hr_employees
    on dep_id = emp_dep_id;
    
    
-- 2. Lösung mit Semi-Join
select dep_id, dep_name
  from hr_departments
 where exists (
       select null
         from hr_employees
        where emp_dep_id = dep_id);

