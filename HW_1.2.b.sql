-- GROUP BY, HAVING, преобразования поля с типом DATE/TIME.
-- Средний объем сделок на ценную бумагу по часам
-- с ограничением, что в этот час по бумаге совершили больше чем 100 сделок

SELECT
    extract(HOUR from order_time) as order_hour,
    security_code,
    avg(volume)
FROM stock_orders
WHERE action = 2 and buysell = 'B'
GROUP BY order_hour, security_code
having count(DISTINCT trade_no) > 100



