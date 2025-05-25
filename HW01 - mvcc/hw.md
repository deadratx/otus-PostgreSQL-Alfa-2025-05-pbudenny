# Домашняя работа по MVCC

## Запуск PGBENCH

Параметры запуска: -c 8 -P 6 -T 60

## Первый запуск
### Результат
progress: 6.0 s, 694.7 tps, lat 9.264 ms stddev 5.389, 0 failed
progress: 12.0 s, 879.0 tps, lat 9.079 ms stddev 4.794, 0 failed
progress: 18.0 s, 845.0 tps, lat 9.464 ms stddev 7.164, 0 failed
progress: 24.0 s, 815.5 tps, lat 9.794 ms stddev 5.578, 0 failed
progress: 30.0 s, 788.8 tps, lat 10.121 ms stddev 5.654, 0 failed
progress: 36.0 s, 667.7 tps, lat 11.966 ms stddev 10.705, 0 failed
progress: 42.0 s, 769.0 tps, lat 10.386 ms stddev 6.784, 0 failed
progress: 48.0 s, 851.2 tps, lat 9.383 ms stddev 5.026, 0 failed
progress: 54.0 s, 843.7 tps, lat 9.467 ms stddev 5.610, 0 failed

progress: 60.0 s, 606.0 tps, lat 13.167 ms stddev 8.736, 0 failed
number of transactions actually processed: 46574
number of failed transactions: 0 (0.000%)
latency average = 10.094 ms
latency stddev = 6.729 ms
initial connection time = 1158.903 ms
tps = 791.117631 (without initial connection time)

### Параметры AUTOVACUUM
autovacuum_max_workers = 3
autovacuum_naptime = 1min
autovacuum_vacuum_threshold = 50
autovacuum_vacuum_scale_factor = 0.2
autovacuum_vacuum_cost_delay = 2ms
autovacuum_vacuum_cost_limit = 200

## Второй запуск
### Результат
progress: 6.0 s, 950.5 tps, lat 6.989 ms stddev 4.165, 0 failed
progress: 12.0 s, 1097.0 tps, lat 7.280 ms stddev 3.887, 0 failed
progress: 18.0 s, 1102.3 tps, lat 7.242 ms stddev 4.029, 0 failed
progress: 24.0 s, 1111.2 tps, lat 7.194 ms stddev 3.936, 0 failed
progress: 30.0 s, 1106.2 tps, lat 7.221 ms stddev 3.862, 0 failed
progress: 36.0 s, 1055.8 tps, lat 7.564 ms stddev 4.143, 0 failed
progress: 42.0 s, 942.1 tps, lat 8.467 ms stddev 5.318, 0 failed
progress: 48.0 s, 988.7 tps, lat 8.072 ms stddev 4.488, 0 failed
progress: 54.0 s, 970.3 tps, lat 8.226 ms stddev 4.856, 0 failed
progress: 60.0 s, 1003.0 tps, lat 7.958 ms stddev 4.467, 0 failed

number of transactions actually processed: 61972
number of failed transactions: 0 (0.000%)
latency average = 7.602 ms
latency stddev = 4.341 ms
initial connection time = 1003.954 ms
tps = 1050.166444 (without initial connection time)

### Параметры AUTOVACUUM
autovacuum_max_workers = 3
autovacuum_naptime = 15s
autovacuum_vacuum_threshold = 25
autovacuum_vacuum_scale_factor = 0.05
autovacuum_vacuum_cost_delay = 10
autovacuum_vacuum_cost_limit = 1000
