# Домашняя работа по работе с GIN индексами

## Дано
Для изучения работы индексов была использована большая демонстрационная база postgrespro.  
На базе выполнялся следующий запрос:
```SQL
explain (costs, verbose, format text, analyze)
select 
  passenger_id,
  passenger_name,
  contact_data ->> 'email' AS email
from tickets
where contact_data ? 'email';
```

## Выполнение без индексов
План выполнения до создания каких-либо индексов:
```
"Seq Scan on bookings.tickets  (cost=0.00..90329.32 rows=1608760 width=60) (actual time=0.043..1085.007 rows=1601080 loops=1)"
"  Output: passenger_id, passenger_name, (contact_data ->> 'email'::text)"
"  Filter: (tickets.contact_data ? 'email'::text)"
"  Rows Removed by Filter: 1348777"
"Planning Time: 1.085 ms"
"Execution Time: 1155.973 ms"
```

В этом случае произошло последовательное сканирование таблицы с фильтром из условия where.

## Выполнение с индексом
Для оптимизации запроса был создан индекса по полю scheduled_departure:
```SQL
create index on tickets using gin (contact_data);
```

План выполнения запроса после создания индекса:
```
"Bitmap Heap Scan on bookings.tickets  (cost=10900.86..84471.18 rows=1608688 width=60) (actual time=169.888..1152.243 rows=1601080 loops=1)"
"  Output: passenger_id, passenger_name, (contact_data ->> 'email'::text)"
"  Recheck Cond: (tickets.contact_data ? 'email'::text)"
"  Heap Blocks: exact=49415"
"  ->  Bitmap Index Scan on tickets_contact_data_idx  (cost=0.00..10498.68 rows=1608688 width=0) (actual time=159.578..159.578 rows=1601080 loops=1)"
"        Index Cond: (tickets.contact_data ? 'email'::text)"
"Planning Time: 1.019 ms"
"Execution Time: 1217.537 ms"
```

В этом случае произошло следующее объединение индекса tickets_contact_data_idx по условию, что json в поле contact_data содержит ключ 'email'. При этом время выполнения оказалось даже немного больше, чем при последовательном сканировании. Возомжно, что это связано с тем, что запрос выбирает чуть более половины записей из таблицы tickets.

## Выводы
Индексы можно использовать даже для составных данных, например jsonb. Однако в некоторых случаях их использование не приводит к оптимизации выполнения запросов. 