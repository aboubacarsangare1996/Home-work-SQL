-- WITH, JOIN.
-- Сравнение заявочных цен
with buys AS (
    SELECT
        security_code,
        order_no,
        order_time,
        price,
        trade_no,
        trade_price
    FROM public.stock_orders
    WHERE buysell = 'B'
        AND action = 2
),
sells AS (
    SELECT
        security_code,
        order_no,
        order_time,
        price,
        trade_no,
        trade_price
    FROM public.stock_orders
    WHERE buysell = 'S'
        AND action = 2
)
SELECT
    buys.security_code,
    buys.trade_no,
    buys.order_no buy_order_no,
    buys.price buy_price,
    sells.order_no sell_order_no,
    sells.price sell_price,
    buys.trade_price,

    abs(sells.price - buys.price) price_diff

FROM buys JOIN sells ON
    buys.trade_no = sells.trade_no