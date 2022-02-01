-- Удалить таблицу, если существует
DROP TABLE IF EXISTS public.stock_orders;

-- Создать таблицу
CREATE TABLE public.stock_orders
(
    no bigint NOT NULL, -- в таблице 15 123 693 строк
    security_code varchar(20),
    buysell char(1),
    ttime int, -- 10:00:00.000
    order_no bigint,
    action smallint, -- 0/1/2
    price numeric(15, 6), -- 6 знаков после запятой точно, перед запятой было 6, но я сделал больше
    volume bigint,
    trade_no bigint,
    trade_price numeric(15, 6)
)
WITH (
    OIDS=FALSE
)
TABLESPACE pg_default;

-- Владельцем сделать postgres
ALTER TABLE public.stock_orders
    OWNER to postgres;

-- Загрузить данные
\copy public.stock_orders FROM 'C:/Users/Public/OrderLog20151123.csv' DELIMITER ',' CSV HEADER;

-- Махинации со временем
ALTER TABLE public.stock_orders
    ADD COLUMN order_time time(3);

-- Слегка опасный костыль, на переход в формат time without time zone
-- Можно было и в запросах обрабатывать время, но я решил сделать это сразу при загрузке таблицы
UPDATE public.stock_orders
    SET order_time = to_timestamp('2015-11-23 ' || ttime::text, 'YYYY-MM-DD HH24MISSMS')::time(3);

ALTER TABLE public.stock_orders
    DROP COLUMN ttime;
