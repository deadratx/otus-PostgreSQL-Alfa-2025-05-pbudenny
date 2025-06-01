# Создание БД и таблицы
```SQL
CREATE DATABASE hcm
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
```

```SQL
CREATE TABLE IF NOT EXISTS public.personnel
(
    id integer NOT NULL DEFAULT nextval('personnel_id_seq'::regclass),
    fio character(100) COLLATE pg_catalog."default"
)

WITH (
    autovacuum_enabled = TRUE
)
TABLESPACE pg_default;
```

```SQL
INSERT INTO personnel(fio) SELECT 'noname' FROM generate_series(1,1000000);
```