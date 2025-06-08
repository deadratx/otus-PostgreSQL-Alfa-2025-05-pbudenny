# Домашняя работа по работе с индексами

## Дано
Для изучения работы индексов была использована большая демонстрационная база postgrespro.  
На базе выполнялся следующий запрос:
```SQL
explain (costs, verbose, format text, analyze)
select
  flights.flight_no,
  flights.status,
  flights.scheduled_departure,
  flights.departure_airport,
  departure_airports_data.airport_name ->> 'ru' AS departure_airport_name,
  flights.scheduled_arrival,
  flights.arrival_airport,
  arrival_airports_data.airport_name ->> 'ru' AS arrival_airport_name
from flights
  inner join airports_data AS departure_airports_data
    on flights.departure_airport = departure_airports_data.airport_code
  inner join airports_data AS arrival_airports_data
    on flights.arrival_airport = arrival_airports_data.airport_code
where
  flights.departure_airport = 'DME'
  and flights.scheduled_departure between cast('2017-08-11 00:00:00+03' as timestamp with time zone) and cast('2017-08-17 23:59:59+03' as timestamp with time zone)
order by flights.scheduled_departure;
```

## Выполнение без индексов
План выполнения до создания каких-либо индексов:
```
"Nested Loop  (cost=5849.99..5901.62 rows=360 width=103) (actual time=207.736..216.465 rows=369 loops=1)"
"  Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, (departure_airports_data.airport_name ->> 'ru'::text), flights.scheduled_arrival, flights.arrival_airport, (arrival_airports_data.airport_name ->> 'ru'::text)"
"  ->  Gather Merge  (cost=5849.99..5891.02 rows=360 width=100) (actual time=207.676..215.966 rows=369 loops=1)"
"        Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, flights.scheduled_arrival, flights.arrival_airport, arrival_airports_data.airport_name"
"        Workers Planned: 1"
"        Workers Launched: 1"
"        ->  Sort  (cost=4849.98..4850.51 rows=212 width=100) (actual time=19.053..19.081 rows=184 loops=2)"
"              Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, flights.scheduled_arrival, flights.arrival_airport, arrival_airports_data.airport_name"
"              Sort Key: flights.scheduled_departure"
"              Sort Method: quicksort  Memory: 70kB"
"              Worker 0:  actual time=0.393..0.394 rows=0 loops=1"
"                Sort Method: quicksort  Memory: 25kB"
"              ->  Hash Join  (cost=5.34..4841.78 rows=212 width=100) (actual time=0.116..18.637 rows=184 loops=2)"
"                    Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, flights.scheduled_arrival, flights.arrival_airport, arrival_airports_data.airport_name"
"                    Inner Unique: true"
"                    Hash Cond: (flights.arrival_airport = arrival_airports_data.airport_code)"
"                    Worker 0:  actual time=0.010..0.011 rows=0 loops=1"
"                    ->  Parallel Seq Scan on bookings.flights  (cost=0.00..4835.87 rows=212 width=39) (actual time=0.015..18.348 rows=184 loops=2)"
"                          Output: flights.flight_id, flights.flight_no, flights.scheduled_departure, flights.scheduled_arrival, flights.departure_airport, flights.arrival_airport, flights.status, flights.aircraft_code, flights.actual_departure, flights.actual_arrival"
"                          Filter: ((flights.scheduled_departure >= '2017-08-11 00:00:00+03'::timestamp with time zone) AND (flights.scheduled_departure <= '2017-08-17 23:59:59+03'::timestamp with time zone) AND (flights.departure_airport = 'DME'::bpchar))"
"                          Rows Removed by Filter: 107249"
"                          Worker 0:  actual time=0.009..0.009 rows=0 loops=1"
"                    ->  Hash  (cost=4.04..4.04 rows=104 width=65) (actual time=0.157..0.158 rows=104 loops=1)"
"                          Output: arrival_airports_data.airport_name, arrival_airports_data.airport_code"
"                          Buckets: 1024  Batches: 1  Memory Usage: 18kB"
"                          ->  Seq Scan on bookings.airports_data arrival_airports_data  (cost=0.00..4.04 rows=104 width=65) (actual time=0.060..0.106 rows=104 loops=1)"
"                                Output: arrival_airports_data.airport_name, arrival_airports_data.airport_code"
"  ->  Materialize  (cost=0.00..4.30 rows=1 width=65) (actual time=0.000..0.000 rows=1 loops=369)"
"        Output: departure_airports_data.airport_name, departure_airports_data.airport_code"
"        ->  Seq Scan on bookings.airports_data departure_airports_data  (cost=0.00..4.30 rows=1 width=65) (actual time=0.045..0.058 rows=1 loops=1)"
"              Output: departure_airports_data.airport_name, departure_airports_data.airport_code"
"              Filter: (departure_airports_data.airport_code = 'DME'::bpchar)"
"              Rows Removed by Filter: 103"
"Planning Time: 0.567 ms"
"Execution Time: 216.542 ms"
```
![План запроса без индексов](https://github.com/deadratx/otus-PostgreSQL-Alfa-2025-05-pbudenny/blob/main/HW03%20-%20index/explain-dep-no-index.png)

В этом случае произошло следующее:
1. Последовательное сканирование таблицы airports_data с фильтром airport_code = 'DME'
2. Последовательное сканирование таблицы airports_data без фильтра
3. Последовательное сканирование таблицы flights с фильтром из условия where
4. Объединение результатов и сортировка
Полное время выполнения запроса составило 216.5 милисекунд.

## Выполнение с индексом
Для оптимизации запроса был создан индекса по полю scheduled_departure:
```SQL
create index on flights(scheduled_departure);
```

План выполнения запроса после создания индекса:
```
"Sort  (cost=2945.27..2946.17 rows=360 width=103) (actual time=4.550..4.593 rows=369 loops=1)"
"  Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, ((departure_airports_data.airport_name ->> 'ru'::text)), flights.scheduled_arrival, flights.arrival_airport, ((arrival_airports_data.airport_name ->> 'ru'::text))"
"  Sort Key: flights.scheduled_departure"
"  Sort Method: quicksort  Memory: 63kB"
"  ->  Nested Loop  (cost=66.48..2929.98 rows=360 width=103) (actual time=1.365..4.353 rows=369 loops=1)"
"        Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, (departure_airports_data.airport_name ->> 'ru'::text), flights.scheduled_arrival, flights.arrival_airport, (arrival_airports_data.airport_name ->> 'ru'::text)"
"        Inner Unique: true"
"        ->  Nested Loop  (cost=66.33..2897.37 rows=360 width=100) (actual time=1.327..3.724 rows=369 loops=1)"
"              Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, flights.scheduled_arrival, flights.arrival_airport, departure_airports_data.airport_name"
"              ->  Seq Scan on bookings.airports_data departure_airports_data  (cost=0.00..4.30 rows=1 width=65) (actual time=0.050..0.064 rows=1 loops=1)"
"                    Output: departure_airports_data.airport_code, departure_airports_data.airport_name, departure_airports_data.city, departure_airports_data.coordinates, departure_airports_data.timezone"
"                    Filter: (departure_airports_data.airport_code = 'DME'::bpchar)"
"                    Rows Removed by Filter: 103"
"              ->  Bitmap Heap Scan on bookings.flights  (cost=66.33..2889.47 rows=360 width=39) (actual time=1.272..3.580 rows=369 loops=1)"
"                    Output: flights.flight_id, flights.flight_no, flights.scheduled_departure, flights.scheduled_arrival, flights.departure_airport, flights.arrival_airport, flights.status, flights.aircraft_code, flights.actual_departure, flights.actual_arrival"
"                    Recheck Cond: ((flights.scheduled_departure >= '2017-08-11 00:00:00+03'::timestamp with time zone) AND (flights.scheduled_departure <= '2017-08-17 23:59:59+03'::timestamp with time zone))"
"                    Filter: (flights.departure_airport = 'DME'::bpchar)"
"                    Rows Removed by Filter: 3429"
"                    Heap Blocks: exact=1866"
"                    ->  Bitmap Index Scan on flights_scheduled_departure_idx  (cost=0.00..66.24 rows=3782 width=0) (actual time=0.918..0.918 rows=3798 loops=1)"
"                          Index Cond: ((flights.scheduled_departure >= '2017-08-11 00:00:00+03'::timestamp with time zone) AND (flights.scheduled_departure <= '2017-08-17 23:59:59+03'::timestamp with time zone))"
"        ->  Memoize  (cost=0.15..0.23 rows=1 width=65) (actual time=0.001..0.001 rows=1 loops=369)"
"              Output: arrival_airports_data.airport_name, arrival_airports_data.airport_code"
"              Cache Key: flights.arrival_airport"
"              Cache Mode: logical"
"              Hits: 316  Misses: 53  Evictions: 0  Overflows: 0  Memory Usage: 9kB"
"              ->  Index Scan using airports_data_pkey on bookings.airports_data arrival_airports_data  (cost=0.14..0.22 rows=1 width=65) (actual time=0.004..0.004 rows=1 loops=53)"
"                    Output: arrival_airports_data.airport_name, arrival_airports_data.airport_code"
"                    Index Cond: (arrival_airports_data.airport_code = flights.arrival_airport)"
"Planning Time: 0.624 ms"
"Execution Time: 4.819 ms"
```
![План запроса без индексов](https://github.com/deadratx/otus-PostgreSQL-Alfa-2025-05-pbudenny/blob/main/HW03%20-%20index/explain-dep-index.png)

В этом случае произошло следующее:
1. Индексное сканирование airports_data с условием airport_code = flights.arrival_airport
2. Объединение индексов flights_scheduled_departure_idx с условиями scheduled_departure >= '2017-08-11 00:00:00+03' и scheduled_departure <= '2017-08-17 23:59:59+03'airports_data без фильтра
3. Последовательное сканирование таблицы airports_data с фильтром airport_code = 'DME'
4. Объединение результатов и сортировка
Полное время выполнения запроса составило 4.8 милисекунд. Это на несколько порядков быстрее, нежели запрос без использования индекса.


## Использование функции над индексированным полем
Если изменить условие where и использовать функцию (например date_trunc) над индексированным полем, а не само поле напрямую, то индекс пересаёт использоваться в запросе:
```SQL
explain (costs, verbose, format text, analyze)
select
  flights.flight_no,
  flights.status,
  flights.scheduled_departure,
  flights.departure_airport,
  departure_airports_data.airport_name ->> 'ru' AS departure_airport_name,
  flights.scheduled_arrival,
  flights.arrival_airport,
  arrival_airports_data.airport_name ->> 'ru' AS arrival_airport_name
from flights
  inner join airports_data AS departure_airports_data
    on flights.departure_airport = departure_airports_data.airport_code
  inner join airports_data AS arrival_airports_data
    on flights.arrival_airport = arrival_airports_data.airport_code
where
  flights.departure_airport = 'DME'
  and date_trunc('day', flights.scheduled_departure) between cast('2017-08-11' as date) and cast('2017-08-17' as date)
order by flights.scheduled_departure;
```

```
"Nested Loop  (cost=6475.20..6493.44 rows=106 width=103) (actual time=225.990..237.465 rows=369 loops=1)"
"  Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, (departure_airports_data.airport_name ->> 'ru'::text), flights.scheduled_arrival, flights.arrival_airport, (arrival_airports_data.airport_name ->> 'ru'::text)"
"  ->  Gather Merge  (cost=6475.20..6487.28 rows=106 width=100) (actual time=225.910..236.731 rows=369 loops=1)"
"        Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, flights.scheduled_arrival, flights.arrival_airport, arrival_airports_data.airport_name"
"        Workers Planned: 1"
"        Workers Launched: 1"
"        ->  Sort  (cost=5475.19..5475.34 rows=62 width=100) (actual time=21.371..21.410 rows=184 loops=2)"
"              Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, flights.scheduled_arrival, flights.arrival_airport, arrival_airports_data.airport_name"
"              Sort Key: flights.scheduled_departure"
"              Sort Method: quicksort  Memory: 70kB"
"              Worker 0:  actual time=0.270..0.271 rows=0 loops=1"
"                Sort Method: quicksort  Memory: 25kB"
"              ->  Hash Join  (cost=5.34..5473.34 rows=62 width=100) (actual time=0.082..21.120 rows=184 loops=2)"
"                    Output: flights.flight_no, flights.status, flights.scheduled_departure, flights.departure_airport, flights.scheduled_arrival, flights.arrival_airport, arrival_airports_data.airport_name"
"                    Inner Unique: true"
"                    Hash Cond: (flights.arrival_airport = arrival_airports_data.airport_code)"
"                    Worker 0:  actual time=0.008..0.008 rows=0 loops=1"
"                    ->  Parallel Seq Scan on bookings.flights  (cost=0.00..5467.83 rows=62 width=39) (actual time=0.021..20.915 rows=184 loops=2)"
"                          Output: flights.flight_id, flights.flight_no, flights.scheduled_departure, flights.scheduled_arrival, flights.departure_airport, flights.arrival_airport, flights.status, flights.aircraft_code, flights.actual_departure, flights.actual_arrival"
"                          Filter: ((flights.departure_airport = 'DME'::bpchar) AND (date_trunc('day'::text, flights.scheduled_departure) >= '2017-08-11'::date) AND (date_trunc('day'::text, flights.scheduled_departure) <= '2017-08-17'::date))"
"                          Rows Removed by Filter: 107249"
"                          Worker 0:  actual time=0.006..0.006 rows=0 loops=1"
"                    ->  Hash  (cost=4.04..4.04 rows=104 width=65) (actual time=0.108..0.110 rows=104 loops=1)"
"                          Output: arrival_airports_data.airport_name, arrival_airports_data.airport_code"
"                          Buckets: 1024  Batches: 1  Memory Usage: 18kB"
"                          ->  Seq Scan on bookings.airports_data arrival_airports_data  (cost=0.00..4.04 rows=104 width=65) (actual time=0.039..0.072 rows=104 loops=1)"
"                                Output: arrival_airports_data.airport_name, arrival_airports_data.airport_code"
"  ->  Materialize  (cost=0.00..4.30 rows=1 width=65) (actual time=0.000..0.000 rows=1 loops=369)"
"        Output: departure_airports_data.airport_name, departure_airports_data.airport_code"
"        ->  Seq Scan on bookings.airports_data departure_airports_data  (cost=0.00..4.30 rows=1 width=65) (actual time=0.062..0.083 rows=1 loops=1)"
"              Output: departure_airports_data.airport_name, departure_airports_data.airport_code"
"              Filter: (departure_airports_data.airport_code = 'DME'::bpchar)"
"              Rows Removed by Filter: 103"
"Planning Time: 0.818 ms"
"Execution Time: 237.570 ms"
```

В этом случае произошло то же самое, что и без использования индекса.

## Выводы
Индексы могут значительно ускорить выполнение запросов, но необходимо следить используются ли индексы на самом деле, так как использовать функций от индексируемого поля может привести к последовательдному сканированию.