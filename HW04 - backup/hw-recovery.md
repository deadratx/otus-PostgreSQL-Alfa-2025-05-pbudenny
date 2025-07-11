# Домашняя работа по восстановлению базы данных на заданное время

Для данного сценария использовался вновь созданный кластер, в который были загруженные данные из бэкапа **main-hcm.sql**.

## 1. Подготовка
Для начала создадим каталоги для архивирования WAL файлов и хранения физического бэкапа:

```bash
sudo mkdir /full-backup
sudo chown -R postgres:postgres /full-backup/
sudo chmod 777 /full-backup/

sudo mkdir /archive-wal
sudo chown -R postgres:postgres /archive-wal/
sudo chmod 777 /archive-wal/
```

Теперь настроим параметры postgres:
```SQL
alter system set archive_mode = 'on';
alter system set archive_command = 'test ! -f /archive-wal/%f && cp %p /archive-wal/%f';
```

Чтобы параметры применились, перезапускаем сервис postgresql:

```bash
sudo systemctl restart postgresql
```

## 2. Создание полного бэкапа
Создаём полный физический бэкап:
```bash
sudo -u postgres pg_basebackup -p 5432 -v -D /full-backup
```

## 3. Выполняем обновление данных.
Сначала добавим корректные данные в таблицу employee.

```SQL
insert into employee (fio) values ('New one');
```

Запишем текущую метку времени:
```SQL
select now();
```
Метка времени = 2025-07-11 17:41:34.418513+03

Теперь "случайно" очистим фио всех сотрудников. Данное действие нам предстоит откатить с помощью восстановления из бэкапа.
```SQL
update employee set fio = '';
```

## 4. Выполняем процедуру восстановления.
Останавливаем службу postgresql:
```bash
sudo systemctl stop postgresql
```

Переносим текущее состояние данных в отдельный каталог:
```bash
sudo mkdir /old-data
sudo mv /var/lib/postgresql/17/main /old-data
sudo mkdir /var/lib/postgresql/17/main
```

После выполнения данных команд каталог /var/lib/postgresql/17/main будет пуст. Теперь туда нужно скопировать предварительно созданный бэкап:
```bash
sudo cp -a /full-backup/. /var/lib/postgresql/17/main
```

Теперь нужно заменить WAL файлы полного бэкапа на WAL файлы, полученные на момент остановки службы postgresql.
```bash
sudo rm -r /var/lib/postgresql/17/main/pg_wal/*
sudo cp -a /old-data/main/pg_wal/. /var/lib/postgresql/17/main/pg_wal
```

Далее необходимо настроить параметры восстановления. Для этого необходимо отредактировать файл postgresql.conf:
```bash
sudo nano /etc/postgresql/17/main/postgresql.conf
```

Добавляем в конец файла следующие строки:
```
restore_command = 'cp /archive-wal/%f "%p"'
recovery_target_time = '2025-07-11 17:41:34.418513+03'
```

Перед стартом службы postgresql, нам необходимо создать пустой файл recovery.signal в каталоге кластера main. Его наличие сообщит службе, что необходимо произвести восстановление на указанную метку времени.
```bash
sudo touch /var/lib/postgresql/17/main/recovery.signal
```

Поменяем владельца для каталога /var/lib/postgresql/17/main/ с его подкаталогами и предоставим необходимые права:
```bash
sudo chown -R postgres:postgres /var/lib/postgresql/17/main/
sudo chmod -R 750 /var/lib/postgresql/17/main/
```

Всё готово для запуска службы postgresql:
```bash
sudo systemctl start postgresql
```

## 5. Проверка после восстановления.
Таблица employee в базе данных hcm содержит 101 запись. Поле fio заполнено корректно.