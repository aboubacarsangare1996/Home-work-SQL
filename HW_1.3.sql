WITH stock_orders AS (
    SELECT tt.*,
        CASE
            WHEN security_code ~ '.*P$'
                THEN 'preferred' -- насколько я понял, у привилегированных акций тикер заканчивается на 'P'
            WHEN security_code ~ '^\D.*\d$'
                THEN 'bond' -- у облигаций начинается на букву и заканчивается на цифру
            ELSE 'common' -- все остальное
        END     security_type
    FROM stock_orders tt
    WHERE tt.action = 2 -- только сделки
        AND order_time < '13:00' -- <============ ВОТ ЗДЕСЬ МЕНЯТЬ ВРЕМЯ '13:00'
        AND CASE
            WHEN security_code ~ '.*P$'
                THEN 'preferred' -- насколько я понял, у привилегированных акций тикер заканчивается на 'P'
            WHEN security_code ~ '^\D.*\d$'
                THEN 'bond' -- у облигаций начинается на букву и заканчивается на цифру
            ELSE 'common' -- все остальное
        END = 'common' -- <====================== ВОТ ЗДЕСЬ МЕНЯТЬ ТИП {'common', 'preferred', 'bond'}
),

trade_orders AS (
    WITH buy AS (
        SELECT
            security_code, -- код ценной бумаги
            order_no,      -- номер заявки (для сравнения)
            order_time,    -- время заявки (оно же время сделки, что странно)
            trade_no,      -- номер сделки
            trade_price    -- цена сделки
        FROM stock_orders
        WHERE buysell = 'B'
    ),
    sell AS (
        SELECT
            security_code, -- код ценной бумаги
            order_no,      -- номер заявки (для сравнения)
            order_time,    -- время заявки (оно же время сделки, хотя это странно)
            trade_no,      -- номер сделки
            trade_price    -- цена сделки
        FROM stock_orders
        WHERE buysell = 'S'
      )
SELECT
    buy.security_code,
    buy.trade_no,
    buy.order_time trade_time,
    buy.trade_price,
    CASE
        WHEN buy.order_no > sell.order_no THEN 'B'
        ELSE 'S'
    END     trade_buysell
FROM buy
JOIN sell
    ON buy.trade_no = sell.trade_no
),

tab1 as (
    with t11 as (
        SELECT
            security_code,
            MAX(trade_no) as trade_no,
            MAX(trade_time) as trade_time
        FROM trade_orders
        WHERE trade_buysell = 'B'
        GROUP BY security_code
    )
    SELECT
        t11.security_code,
        tro.trade_price as price_buy,
        t11.trade_no,
        t11.trade_time
    FROM t11
    LEFT JOIN trade_orders tro
        ON t11.security_code = tro.security_code
            AND t11.trade_no = tro.trade_no

),

tab2 as (
    WITH t21 as (
        SELECT
            security_code,
            trade_no,
            trade_time,
            trade_price
        FROM trade_orders
        WHERE trade_buysell = 'S'
    ),
    t22 AS (
        SELECT t21.security_code,
               MAX(t21.trade_no) trade_no,
               MAX(t21.trade_time) trade_time
        FROM t21
        JOIN tab1
            ON tab1.security_code = t21.security_code
            AND t21.trade_time <= tab1.trade_time
            AND t21.trade_no < tab1.trade_no
        GROUP BY t21.security_code
    )
    SELECT
        t22.security_code,
        tro.trade_price as price_sell,
        t22.trade_no,
        t22.trade_time
    FROM t22
    LEFT JOIN trade_orders tro
        ON t22.security_code = tro.security_code
            AND t22.trade_no = tro.trade_no
)

SELECT
    tab1.security_code,
    tab1.price_buy,
    tab2.price_sell,
	-- tab1.trade_time,
	-- tab2.trade_time,
    -- tab1.trade_time - tab2.trade_time,
    extract(EPOCH from (tab1.trade_time - tab2.trade_time)) * 1000 time_diff
FROM tab1
LEFT JOIN tab2
    ON tab1.security_code = tab2.security_code
