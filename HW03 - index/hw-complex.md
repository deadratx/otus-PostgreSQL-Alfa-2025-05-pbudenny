# Домашняя работа по работе с составными индексами

## Дано
Для изучения работы индексов была использована большая демонстрационная база postgrespro.  
На базе выполнялся следующий запрос:
```SQL
explain (costs, verbose, format text, analyze)
select
  flights.flight_no,
  flights.scheduled_departure,
  flights.actual_departure,
  flights.actual_departure - flights.scheduled_departure AS departure_delay
from flights
where flights.departure_airport = 'DME'
  and flights.actual_departure is not null
  and flights.actual_departure - flights.scheduled_departure >= cast('00:30:00' as interval);
```

## Выполнение без индексов
План выполнения до создания каких-либо индексов:
```
"Seq Scan on bookings.flights  (cost=0.00..6400.67 rows=6600 width=39) (actual time=0.050..41.016 rows=983 loops=1)"
"  Output: flight_no, scheduled_departure, actual_departure, (actual_departure - scheduled_departure)"
"  Filter: ((flights.actual_departure IS NOT NULL) AND (flights.departure_airport = 'DME'::bpchar) AND ((flights.actual_departure - flights.scheduled_departure) >= '00:30:00'::interval))"
"  Rows Removed by Filter: 213884"
"Planning Time: 0.221 ms"
"Execution Time: 41.062 ms"
```
В этом случае произошло последовательное сканирование таблицы с фильтром из условия where.

## Выполнение с индексом
Для оптимизации запроса был создан индекса по полю scheduled_departure:
```SQL
create index on flights((actual_departure - scheduled_departure));
```

План выполнения запроса после создания индекса:
```
"Bitmap Heap Scan on bookings.flights  (cost=232.19..3034.71 rows=907 width=39) (actual time=3.408..10.065 rows=983 loops=1)"
"  Output: flight_no, scheduled_departure, actual_departure, (actual_departure - scheduled_departure)"
"  Recheck Cond: ((flights.actual_departure - flights.scheduled_departure) >= '00:30:00'::interval)"
"  Filter: (flights.departure_airport = 'DME'::bpchar)"
"  Rows Removed by Filter: 8918"
"  Heap Blocks: exact=2561"
"  ->  Bitmap Index Scan on flights_expr_idx  (cost=0.00..231.96 rows=10072 width=0) (actual time=2.946..2.946 rows=9901 loops=1)"
"        Index Cond: ((flights.actual_departure - flights.scheduled_departure) >= '00:30:00'::interval)"
"Planning Time: 0.608 ms"
"Execution Time: 10.148 ms"
```

В этом случае произошло следующее:
1. Объединение индекса flights_expr_idx по условию (flights.actual_departure - flights.scheduled_departure) >= '00:30:00'
2. Фильтрация полученного результата по условию departure_airport = 'DME'

Создание индекса увеличило скорость выполнения запроса в 4 раза.

## Выводы
Индексы можно эффективно использовать не только для одного или нескольких полей, но и для целых выражений.