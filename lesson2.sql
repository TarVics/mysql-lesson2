# mysql-lesson2
use tarvic;
# owu.linkpc.net

-- 1. Вибрати усіх клієнтів, чиє ім'я має менше ніж 6 символів.
select * from client where LENGTH(FirstName) < 6;

-- 2. Вибрати львівські відділення банку.
select * from department where DepartmentCity = 'Lviv';

-- 3. Вибрати клієнтів з вищою освітою та посортувати по прізвищу.
select * from client where Education = 'high' order by LastName;

-- 4. Виконати сортування у зворотньому порядку над таблицею Заявка і вивести 5 останніх елементів.
select * from application order by idApplication desc limit 5;

-- 5. Вивести усіх клієнтів, чиє прізвище закінчується на OV чи OVA.
select * from client where LastName like '%ov' or LastName like '%ova';

select * from client where LastName like '%ov'
union
select * from client where LastName like '%ova';

select * from client where right(LastName, 2) = 'ov' or right(LastName, 3) = 'ova';

select * from client where right(LastName, 2) = 'ov'
union
select * from client where right(LastName, 3) = 'ova';

select * from client where substr(LastName, length(LastName) - 1) = 'ov' or substr(LastName, length(LastName) - 2) = 'ova';

select * from client where substr(LastName, length(LastName) - 1) = 'ov'
union
select * from client where substr(LastName, length(LastName) - 2) = 'ova';

-- 6. Вивести клієнтів банку, які обслуговуються київськими відділеннями.
select c.* from client c
join department d on d.idDepartment = c.Department_idDepartment
where d.DepartmentCity = 'Kyiv';

select c.* from client c
where c.Department_idDepartment
in (select d.idDepartment from department d where d.DepartmentCity = 'Kyiv');

-- 7. Знайти унікальні імена клієнтів.
select distinct c.FirstName from client c;

-- 8. Вивести дані про клієнтів, які мають кредит більше ніж на 5000 гривень.
select c.* from client c
join application a on c.idClient = a.Client_idClient
where a.Currency = 'Gryvnia' and a.CreditState='Not returned' and a.Sum>5000;

select c.* from client c
where c.idClient in (
    select a.Client_idClient from application a
    where a.Currency = 'Gryvnia' and a.CreditState='Not returned' and a.Sum>5000);

-- 9. Порахувати кількість клієнтів усіх відділень та лише львівських відділень.
select d.idDepartment, d.DepartmentCity, count(*) from client c
join department d on d.idDepartment = c.Department_idDepartment
group by d.idDepartment
order by 2;

select d.idDepartment, d.DepartmentCity, count(*) from client c
join department d on d.idDepartment = c.Department_idDepartment
where d.DepartmentCity = 'Lviv'
group by d.idDepartment;

-- 10. Знайти кредити, які мають найбільшу суму для кожного клієнта окремо.

-- Припускаємо, що у стовпці application.Summ міститься сума кредиту у гривні
-- Якщо, кредит у валюті, то повинен виконуватись пошук курсу валюти на визначену дату

select c.*, max(a.Sum) max_summ
from client c
join application a on c.idClient = a.Client_idClient
group by c.idClient;

-- 11. Визначити кількість заявок на кредит для кожного клієнта.
select c.*, count(*)
from client c
join application a on c.idClient = a.Client_idClient
group by c.idClient;

-- 12. Визначити найбільший та найменший кредити.
select max(a.Sum), min(a.Sum) from application a;

-- 13. Порахувати кількість кредитів для клієнтів,які мають вищу освіту.
select c.*, count(*)
from client c
join application a on c.idClient = a.Client_idClient
where c.Education='high'
group by c.idClient;

-- 14. Вивести дані про клієнта, в якого середня сума кредитів найвища.
select c.*, avg(a.Sum) avg_gryvna
from client c
join application a on c.idClient = a.Client_idClient
group by c.idClient
order by avg_gryvna desc
limit 1;

-- 15. Вивести відділення, яке видало в кредити найбільше грошей
select d.*, sum(a.Sum) sum_gryvna
from department d
join client c on d.idDepartment = c.Department_idDepartment
join application a on c.idClient = a.Client_idClient
group by d.idDepartment
order by sum_gryvna desc
limit 1;

-- 16. Вивести відділення, яке видало найбільший кредит.
select d.*, max(a.Sum) max_gryvna
from department d
join client c on d.idDepartment = c.Department_idDepartment
join application a on c.idClient = a.Client_idClient
group by d.idDepartment
order by max_gryvna desc
limit 1;

-- 17. Усім клієнтам, які мають вищу освіту, встановити усі їхні кредити у розмірі 6000 грн.
update application a set
a.Currency = 'Gryvnia',
a.Sum = 6000
where a.Client_idClient in (select c.idClient from client c where c.Education='high');

-- 18. Усіх клієнтів київських відділень переселити до Києва.
update client c set
    c.City = 'Kyiv'
where c.City <> 'Kyiv' and c.Department_idDepartment in (
    select d.idDepartment from department d where d.DepartmentCity='Kyiv');

-- 19. Видалити усі кредити, які є повернені.
delete from application a where a.CreditState='Returned';

-- 20. Видалити кредити клієнтів, в яких друга літера прізвища є голосною.
delete from application a where a.Client_idClient in (
    select c.idClient from client c where substr(c.LastName, 2, 1) in ('A', 'E', 'I', 'O', 'U')
);

-- 21. Знайти львівські відділення, які видали кредитів на загальну суму більше ніж 5000
select d.*, sum(a.Sum) sum_gryvna
from department d
join client c on d.idDepartment = c.Department_idDepartment
join application a on c.idClient = a.Client_idClient
where d.DepartmentCity = 'Lviv'
group by d.idDepartment
having sum_gryvna > 5000;

-- 22. Знайти клієнтів, які повністю погасили кредити на суму більше ніж 5000
select c.*
  from client c
 where c.idClient in (
   select a.Client_idClient from application a where a.CreditState='Returned' and a.Sum > 5000
 );

-- 23. Знайти максимальний неповернений кредит.
select max(a.Sum) max_gryvna
from application a
where a.CreditState='Not returned';

-- 24. Знайти клієнта, сума кредиту якого найменша
select c.*, min(a.Sum) min_gryvna
 from client c
 join application a on c.idClient = a.Client_idClient
group by c.idClient
order by min_gryvna
limit 1;

-- 25. Знайти кредити, сума яких більша за середнє значення усіх кредитів
select a.*
  from application a
 where a.Sum > (select avg(a.Sum) from application a);

-- 26. Знайти клієнтів, які є з того самого міста, що і клієнт, який взяв найбільшу кількість кредитів
select c.*
from client c
join (
    select c.*, count(*) credit_count
    from client c
    join application a on c.idClient = a.Client_idClient
    group by c.idClient
    order by credit_count desc
    limit 1
) c0 on c0.City = c.City and c0.idClient <> c.idClient;

-- 27. Місто клієнта з найбільшою кількістю кредитів
select c.City from (
    select c.City, count(*) credit_count
      from client c
      join application a on c.idClient = a.Client_idClient
     group by c.idClient
     order by credit_count desc
     limit 1
) c;
