with stock_orders AS (
     SELECT tt.*,
            CASE
                WHEN security_code ~ '.*P$'
                    THEN 'preferred' -- насколько я понял, у привилегированных акций тикер заканчивается на ''P''
                WHEN security_code ~ '^\D.*\d$'
                    THEN 'bond' -- у облигаций начинается на букву и заканчивается на цифру
                ELSE 'common' -- все остальное
                END security_type
     FROM stock_orders tt
     WHERE action = 2 and
 ),

 trade_orders AS (
     WITH buy AS (
         SELECT security_code, -- код ценной бумаги
                order_no,      -- номер заявки (для сравнения)
                order_time,    -- время заявки (оно же время сделки, что странно)
                trade_no,      -- номер сделки
                trade_price    -- цена сделки
         FROM stock_orders
         WHERE buysell = ''B'
     ),
      sell AS (
          SELECT security_code, -- код ценной бумаги
                 order_no,      -- номер заявки (для сравнения)
                 order_time,    -- время заявки (оно же время сделки, хотя это странно)
                 trade_no,      -- номер сделки
                 trade_price    -- цена сделки
          FROM stock_orders
          WHERE buysell = ''S''
      )
     SELECT buy.security_code,
            buy.trade_no,
            CASE
                WHEN buy.order_no > sell.order_no THEN ''B''
                ELSE ''S''
                END        trade_buysell,
            buy.order_time trade_time,
            buy.trade_price

     FROM buy
              JOIN sell ON
         buy.trade_no = sell.trade_no
 )

select * from trade_orders