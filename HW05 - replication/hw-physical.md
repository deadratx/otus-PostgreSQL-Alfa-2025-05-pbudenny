# Домашняя работа по настройке физической репликации между двумя нодами: мастер - слейв.

Для настройки репликации была использована средняя демонстрационная база postgrespro.  
Настройка происходила на одной физической машине, соответственно, никаких дополнительных настроек в конфигурационных файлах для доступа мастера и слейва друг к другу не потребовалось.

## 1. Создание второго кластера (слейв) и настройка репликации.
Необходимо создать второй кластер, который будет репликой основного.
```bash
sudo pg_createcluster 17 replica
sudo pg_ctlcluster 17 replica start
```

После создания нужно удалить все файлы кластера и загрузить туда физический бэкап основного.
```bash
sudo rm -rf /var/lib/postgresql/17/replica
sudo -u postgres pg_basebackup -p 5432 -R -D /var/lib/postgresql/17/replica
sudo pg_ctlcluster 17 replica start
```

Использование параметра **-R** добавить к бэкапу файл **standby.signal** и необходимые настройки в **postgresql.auto.conf**
```
primary_conninfo = 'user=postgres passfile=''/var/lib/postgresql/.pgpass'' channel_binding=prefer port=5432 sslmode=prefer sslnegotiation=postgres sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable'
```

## 2. Проверка репликации
Чтобы проверить статус репликации на основной кластере, можно выполнить следующий запрос.
```SQL
select * from pg_stat_replication \gx
```
| Поле             | Значение                      |
|:---------------- |:----------------------------- |
| pid              | 2867                          |
| usesysid         | 10                            |
| usename          | postgres                      |
| application_name | 17/replica                    |
| client_addr      |                               |
| client_hostname  |                               |
| client_port      | -1                            |
| backend_start    | 2025-07-19 16:06:53.03836+03  |
| backend_xmin     |                               |
| state            | streaming                     |
| sent_lsn         | 0/25000168                    |
| write_lsn        | 0/25000168                    |
| flush_lsn        | 0/25000168                    |
| replay_lsn       | 0/25000168                    |
| write_lag        |                               |
| flush_lag        |                               |
| replay_lag       |                               |
| sync_priority    | 0                             |
| sync_state       | async                         |
| reply_time       | 2025-07-19 16:15:21.977557+03 |

Так же можно посмотреть статус репликации на реплике.
```SQL
select * from pg_stat_wal_receiver \gx
```
| Поле                  | Значение                      |
|:--------------------- |:----------------------------- |
| pid                   | 2866                          |
| status                | streaming                     |
| receive_start_lsn     | 0/25000000                    |
| receive_start_tli     | 1                             |
| written_lsn           | 0/25000168                    |
| flushed_lsn           | 0/25000168                    |
| received_tli          | 1                             |
| last_msg_send_time    | 2025-07-19 16:37:24.948505+03 |
| last_msg_receipt_time | 2025-07-19 16:37:24.94865+03  |
| latest_end_lsn        | 0/25000168                    |
| latest_end_time       | 2025-07-19 16:10:21.357315+03 |
| slot_name             |                               |
| sender_host           | /var/run/postgresql           |
| sender_port           | 5432                          |
| conninfo              | user=postgres passfile=/var/lib/postgresql/.pgpass channel_binding=prefer dbname=replication port=5432 fallback_application_name=17/replica sslmode=prefer sslnegotiation=postgres sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable |

Теперь изменим одну запись в таблице **aircrafts_data**. Запись до изменения выглядит следующим образом.
```SQL
select * from aircrafts_data where aircraft_code = '773';
```
| aircraft_code |                      model                      | range |
|---------------|-------------------------------------------------|-------|
| 773           | {"en": "Boeing 777-300", "ru": "Боинг 777-300"} | 11100 |

Изменяем запись на мастере.
```SQL
update aircrafts_data set range = 11201 where aircraft_code = '773';
```

Проверяем на реплике.
```SQL
select * from aircrafts_data where aircraft_code = '773';
```
| aircraft_code |                      model                      | range |
|---------------|-------------------------------------------------|-------|
| 773           | {"en": "Boeing 777-300", "ru": "Боинг 777-300"} | 11201 |

В статусе репликации на мастере так же можно увидеть изменения.
```SQL
select * from pg_stat_replication \gx
```
| Поле             | Значение                      |
|:---------------- |:----------------------------- |
| pid              | 708                           |
| usesysid         | 10                            |
| usename          | postgres                      |
| application_name | 17/replica                    |
| client_addr      |                               |
| client_hostname  |                               |
| client_port      | -1                            |
| backend_start    | 2025-07-22 19:11:26.078422+03 |
| backend_xmin     |                               |
| state            | streaming                     |
| sent_lsn         | 0/250016B8                    |
| write_lsn        | 0/250016B8                    |
| flush_lsn        | 0/250016B8                    |
| replay_lsn       | 0/250016B8                    |
| write_lag        |                               |
| flush_lag        |                               |
| replay_lag       |                               |
| sync_priority    | 0                             |
| sync_state       | async                         |
| reply_time       | 2025-07-22 19:29:40.884784+03 |

Тоже самое и на реплике.
```SQL
select * from pg_stat_wal_receiver \gx
```
| Поле                  | Значение                      |
|:--------------------- |:----------------------------- |
| pid                   | 707                           |
| status                | streaming                     |
| receive_start_lsn     | 0/25000000                    |
| receive_start_tli     | 1                             |
| written_lsn           | 0/250016B8                    |
| flushed_lsn           | 0/250016B8                    |
| received_tli          | 1                             |
| last_msg_send_time    | 2025-07-22 19:33:57.251508+03 |
| last_msg_receipt_time | 2025-07-22 19:33:57.251624+03 |
| latest_end_lsn        | 0/250016B8                    |
| latest_end_time       | 2025-07-22 19:31:27.003554+03 |
| slot_name             |                               |
| sender_host           | /var/run/postgresql           |
| sender_port           | 5432                          |
| conninfo              | user=postgres passfile=/var/lib/postgresql/.pgpass channel_binding=prefer dbname=replication port=5432 fallback_application_name=17/replica sslmode=prefer sslnegotiation=postgres sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable |