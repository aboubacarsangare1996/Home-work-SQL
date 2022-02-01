-- DISTINCT, WHERE, ORDER BY
-- Ценные бумаги по которым кидали заявки на покупку за первый час
SELECT DISTINCT security_code
FROM stock_orders
WHERE order_time >= '10:00' AND order_time < '11:00'
    AND buysell = 'B'
    AND action = 1
ORDER BY security_code desc




