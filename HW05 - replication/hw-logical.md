# Домашняя работа по настройке логической репликации со мастера на четвёртую ноду.

Для настройки логической репликации была использована средняя демонстрационная база postgrespro.  
Настройка приосходила на одной физической машине, соответственно, никаких дополнительных настроек в конфигурационных файлах для доступа мастера и слейва друг к другу не потребовалось.

## 1. Создание четвёртого кластера.
Необходимо создать новый кластер, в который мы будем реплицировать одну из таблиц первого кластера.
```bash
sudo pg_createcluster 17 main2
sudo pg_ctlcluster 17 main2 start
```

## 2. Настройка первого кластера.
На первом кластере необходмо изменить параметр **WAL_LEVEL**
```SQL
ALTER SYSTEM SET wal_level = logical;
```

Чтобы параметр применился, нужно перезапустить кластер.
```bash
sudo pg_ctlcluster 17 main restart
```

Теперь необходимо создать публикацию.
```SQL
CREATE PUBLICATION demo_aircrafts FOR TABLE aircrafts_data;
 \dRp
```
|      Name      |  Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root |
| ---------------|----------|------------|---------|---------|---------|-----------|----------|
| demo_aircrafts | postgres | f          | t       | t       | t       | t         | f        |

Также нужно задать пароль для пользователя postgres.
```SQL
\password
```

## 3. Настройка нового кластера.
Для начала создадим базу данных и таблицу, в которую мы будем реплицировать данные.
```SQL
create database demo;
\c demo
create schema bookings;
create table bookings.aircrafts_data(aircraft_code character, model jsonb, range integer);
set search_path to bookings, public;
```

Теперь можно создать подписку.
```SQL
CREATE SUBSCRIPTION demo_aircrafts
CONNECTION 'host=localhost port=5432 user=postgres password=123pas dbname=demo'
PUBLICATION demo_aircrafts WITH (copy_data = true);
```

## 4. Проверка репликации и поиск ошибок.
Если при репликации возникнет ошибка, то её можно увидеть в логах. Например, могут отличаться типы данных в колонках.
```bash
tail -n 10 /var/log/postgresql/postgresql-17-main2.log
2025-07-24 19:16:28.029 MSK [1892] CONTEXT:  COPY aircrafts_data, line 1, column aircraft_code: "763"
2025-07-24 19:16:28.033 MSK [715] LOG:  background worker "logical replication tablesync worker" (PID 1892) exited with exit code 1
2025-07-24 19:16:33.267 MSK [1896] LOG:  logical replication table synchronization worker for subscription "demo_aircrafts", table "aircrafts_data" has started
2025-07-24 19:16:33.342 MSK [1896] ERROR:  value too long for type character(1)
2025-07-24 19:16:33.342 MSK [1896] CONTEXT:  COPY aircrafts_data, line 1, column aircraft_code: "763"
2025-07-24 19:16:33.346 MSK [715] LOG:  background worker "logical replication tablesync worker" (PID 1896) exited with exit code 1
2025-07-24 19:16:38.567 MSK [1899] LOG:  logical replication table synchronization worker for subscription "demo_aircrafts", table "aircrafts_data" has started
2025-07-24 19:16:38.655 MSK [1899] ERROR:  value too long for type character(1)
2025-07-24 19:16:38.655 MSK [1899] CONTEXT:  COPY aircrafts_data, line 1, column aircraft_code: "763"
2025-07-24 19:16:38.659 MSK [715] LOG:  background worker "logical replication tablesync worker" (PID 1899) exited with exit code 1
```

Исправим ошибку. Для этого удаляем подписку, меняем тип данных колонки и создаём подписку по новой.
```SQL
DROP SUBSCRIPTION demo_aircrafts;
ALTER TABLE aircrafts_data ALTER COLUMN aircraft_code TYPE character(3);

CREATE SUBSCRIPTION demo_aircrafts
CONNECTION 'host=localhost port=5432 user=postgres password=123pas dbname=demo'
PUBLICATION demo_aircrafts WITH (copy_data = true);
```

Проверяем, что данные в таблице появились.
```SQL
select * from aircrafts_data;
```
| aircraft_code |                           model                            | range |
|---------------|------------------------------------------------------------|-------|
| 763           | {"en": "Boeing 767-300", "ru": "Боинг 767-300"}            |  7900 |
| SU9           | {"en": "Sukhoi Superjet-100", "ru": "Сухой Суперджет-100"} |  3000 |
| 320           | {"en": "Airbus A320-200", "ru": "Аэробус A320-200"}        |  5700 |
| 321           | {"en": "Airbus A321-200", "ru": "Аэробус A321-200"}        |  5600 |
| 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"}        |  6700 |
| 733           | {"en": "Boeing 737-300", "ru": "Боинг 737-300"}            |  4200 |
| CN1           | {"en": "Cessna 208 Caravan", "ru": "Сессна 208 Караван"}   |  1200 |
| CR2           | {"en": "Bombardier CRJ-200", "ru": "Бомбардье CRJ-200"}    |  2700 |
| 773           | {"en": "Boeing 777-300", "ru": "Боинг 777-300"}            | 11201 |