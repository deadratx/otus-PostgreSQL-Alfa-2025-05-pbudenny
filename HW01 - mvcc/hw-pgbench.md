# Домашняя работа по MVCC - PGBENCH

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
progress: 6.0 s, 922.3 tps, lat 7.204 ms stddev 4.389, 0 failed  
progress: 12.0 s, 1110.7 tps, lat 7.183 ms stddev 4.356, 0 failed  
progress: 18.0 s, 1054.0 tps, lat 7.587 ms stddev 4.362, 0 failed  
progress: 24.0 s, 1107.7 tps, lat 7.211 ms stddev 4.086, 0 failed  
progress: 30.0 s, 1114.2 tps, lat 7.170 ms stddev 3.855, 0 failed  
progress: 36.0 s, 1118.5 tps, lat 7.141 ms stddev 3.837, 0 failed  
progress: 42.0 s, 1123.5 tps, lat 7.107 ms stddev 3.872, 0 failed  
progress: 48.0 s, 1121.5 tps, lat 7.122 ms stddev 3.683, 0 failed  
progress: 54.0 s, 1110.0 tps, lat 7.193 ms stddev 4.072, 0 failed  
progress: 60.0 s, 1117.0 tps, lat 7.152 ms stddev 4.053, 0 failed  

number of transactions actually processed: 65413  
number of failed transactions: 0 (0.000%)  
latency average = 7.205 ms  
latency stddev = 4.057 ms  
initial connection time = 1003.028 ms  
tps = 1108.305994 (without initial connection time)  

### Параметры AUTOVACUUM
autovacuum_max_workers = 3  
autovacuum_naptime = 15s  
autovacuum_vacuum_threshold = 25  
autovacuum_vacuum_scale_factor = 0.05  
autovacuum_vacuum_cost_delay = 10  
autovacuum_vacuum_cost_limit = 1000  

## Выводы
Более агрессивные параметры autovacuum значительно увеличивают производительность. Прирост по TPS 40%. Снижение задержки около 28%.