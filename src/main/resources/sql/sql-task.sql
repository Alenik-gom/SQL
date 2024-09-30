-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса
select model, fare_conditions, count(seat_no) as seats_number
from aircrafts
left join seats on aircrafts.aircraft_code = seats.aircraft_code
group by model , fare_conditions
order by model;


-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест)
select model,  count(seat_no)  as seats_number
from aircrafts
left join seats on aircrafts.aircraft_code = seats.aircraft_code
group by model
order by seats_number desc
limit 3;


-- 3. Найти все рейсы, которые задерживались более 2 часов
   --- берем все статусы (по условию нет оговорок): есть 1 рейс в статусе cancelled - по нему тоже есть задержка,
   -- и 3 - все еще задерживаются с вылетом (статус delayed)
   -- забержівалісь как с вылетом, так и с прилетом
select  flight_id, ( actual_departure  - scheduled_departure ) as delay_departure,
(actual_arrival - scheduled_arrival) as  delay_arrival
from flights
where (( actual_departure  - scheduled_departure ) > '02:00:00'
     or (actual_arrival - scheduled_arrival) > '02:00:00');


-- 4. Найти последние 10 билетов, купленные в бизнес-классе , с указанием имени пассажира и контактных данных
select  t.passenger_name, t.contact_data
from bookings b
inner join tickets t ON b.book_ref = t.book_ref
inner join ticket_flights tf on t.ticket_no =tf.ticket_no
where tf.fare_conditions = 'Business'
order by b.book_date desc
limit 10;

-- 5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе
  --- включены, также рейсы, по которым даже нет никакой брони (напр, рейс 530)
  -- выбираем рейсы, по котором ЕСТЬ бронь бизнес-исключаем их из общего списка рейсов
select flight_id
from flights
where flight_id not in (
    select flight_id
    from ticket_flights
    where fare_conditions = 'Business'
    group by flight_id);

-- 6. Получить список аэропортов (airport_name) и городов (city), в
-- которых есть рейсы с задержкой по вылету
    -- предположим, что не текущая задержка,  а были ли в целом задержки (сверим время
    -- вылета -план\факт)
select distinct a.airport_name, a.city
from flights f
inner join airports a on f.departure_airport = a.airport_code
where ( actual_departure  - scheduled_departure ) > '00:00:00';
    -- если по смотреть только по статусу - задержан:
    select distinct a.airport_name, a.city
      from flights f
      inner join airports a on f.departure_airport = a.airport_code
      where f.status = 'Delayed';

-- 7. Получить список аэропортов (airport_name) и количество рейсов,
-- вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
    -- left join - вдруг у какого аэропорта нет полетов
select distinct a.airport_name,  count (flight_id) as number_flights
from airports a
left join flights f  on f.departure_airport = a.airport_code
group by a.airport_name
order by count (flight_id) desc


-- 8. Найти все рейсы, у которых запланированное время прибытия
--(scheduled_arrival) было изменено и новое время прибытия
-- (actual_arrival) не совпадает с запланированным
select flight_id
from flights
where (( actual_arrival  - scheduled_arrival) > '00:00:00' or ( actual_arrival  - scheduled_arrival) < '00:00:00')



-- 9. Вывести код, модель самолета и места не эконом класса для
-- самолета &quot;Аэробус A321-200&quot; с сортировкой по местам
select a.aircraft_code, a.model, s.seat_no
from aircrafts a
inner join seats s on a.aircraft_code = s.aircraft_code
where a.model = 'Аэробус A321-200' and s.fare_conditions <> 'Economy'
order by seat_no


-- 10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
select airport_code ,airport_name, city
from airports
where city in (
    select city
    from airports
    group by city
    having count (airport_code) > 1 )

--11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
select t.passenger_id
from bookings b
inner join tickets t on b.book_ref = t.book_ref
group by passenger_id
having  sum (b.total_amount) > (select avg (total_amount) from bookings)

-- 12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву,на который еще не завершилась регистрация
SELECT flight_id, scheduled_departure
FROM flights
WHERE departure_airport in (select airport_code from airports where city = 'Екатеринбург') and
arrival_airport in (select airport_code from airports where city = 'Москва')
      AND status IN ('On Time', 'Delayed')
ORDER BY scheduled_departure asc
limit 1

-- 13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
-- билетов, равных минимуму и максимуму, много:
select ticket_no, amount
from ticket_flights
where ( amount = (select max(amount) from ticket_flights)  or
amount  = (select min(amount) from ticket_flights))

-- 14. Написать DDL таблицы Customers, должны быть поля id,
--firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE Customers (
    id INT PRIMARY KEY,
    firstName VARCHAR(255) NOT NULL,
    lastName VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL
)

-- 15. Написать DDL таблицы Orders, должен быть id, customerId,
-- quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE Orders (
    id INT PRIMARY KEY,
    customerId INT,
    quantity INT,
    CONSTRAINT fk_customer
        FOREIGN KEY (customerId) REFERENCES Customers(id)
);


--16. Написать 5 insert в эти таблицы
INSERT INTO Customers (id, firstName, lastName, email, phone) VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '123-456-7890'),
(2, 'Jane', 'Doe', 'jane.doe@example.com', '123-456-7891'),
(3, 'Alice', 'Smith', 'alice.smith@example.com', '123-456-7892'),
(4, 'Bob', 'Brown', 'bob.brown@example.com', '123-456-7893'),
(5, 'Charlie', 'Davis', 'charlie.davis@example.com', '123-456-7894')

INSERT INTO Orders (id, customerId, quantity) VALUES
(1, 1, 10),
(2, 2, 15),
(3, 3, 5),
(4, 4, 20),
(5, 5, 7)

--17. Удалить таблицы
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;