# Домашняя работа по настройке каскадной репликации со слейва на треью ноду.

Для настройки каскадной репликации была использована средняя демонстрационная база postgrespro.  
Настройка происходила на одной физической машине, соответственно, никаких дополнительных настроек в конфигурационных файлах для доступа мастера и слейва друг к другу не потребовалось.

## 1. Создание третьего кластера и настройка репликации.
Необходимо создать третий кластер, который будет каскадной репликой.
```bash
sudo pg_createcluster 17 subreplica
sudo pg_ctlcluster 17 subreplica start
```

После создания нужно удалить все файлы кластера и загрузить туда физический бэкап первой реплики.
```bash
sudo rm -rf /var/lib/postgresql/17/subreplica
sudo -u postgres pg_basebackup -p 5433 -R -D /var/lib/postgresql/17/subreplica
sudo pg_ctlcluster 17 subreplica start
```

## 2. Проверка репликации
Чтобы проверить статус репликации на первой реплике, можно выполнить следующий запрос.
```SQL
select * from pg_stat_replication \gx
```
| Поле             | Значение                      |
|:---------------- |:----------------------------- |
| pid              | 2852                          |
| usesysid         | 10                            |
| usename          | postgres                      |
| application_name | 17/subreplica                 |
| client_addr      |                               |
| client_hostname  |                               |
| client_port      | -1                            |
| backend_start    | 2025-07-22 19:43:19.132101+03 |
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
| reply_time       | 2025-07-22 19:43:59.18984+03  |

Так же можно посмотреть статус репликации на реплике.
```SQL
select * from pg_stat_wal_receiver \gx
```
| Поле                  | Значение                      |
|:--------------------- |:----------------------------- |
| pid                   | 2851                          |
| status                | streaming                     |
| receive_start_lsn     | 0/25000000                    |
| receive_start_tli     | 1                             |
| written_lsn           | 0/250016B8                    |
| flushed_lsn           | 0/25000000                    |
| received_tli          | 1                             |
| last_msg_send_time    | 2025-07-22 19:44:19.150604+03 |
| last_msg_receipt_time | 2025-07-22 19:44:19.150634+03 |
| latest_end_lsn        | 0/250016B8                    |
| latest_end_time       | 2025-07-22 19:43:19.135397+03 |
| slot_name             |                               |
| sender_host           | /var/run/postgresql           |
| sender_port           | 5433                          |
| conninfo              | user=postgres passfile=/var/lib/postgresql/.pgpass channel_binding=prefer dbname=replication port=5433 fallback_application_name=17/subreplica sslmode=prefer sslnegotiation=postgres sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable |